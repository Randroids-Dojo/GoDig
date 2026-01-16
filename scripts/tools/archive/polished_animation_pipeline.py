#!/opt/homebrew/bin/python3.11
"""
Polished Animation Pipeline - Combining All Learnings

This pipeline combines:
1. ControlNet (OpenPose) for pose control
2. IP-Adapter for character consistency
3. Multi-candidate generation per frame
4. LLM evaluation for quality control
5. Iterative refinement

Strategy:
- Generate N candidates per frame with varying seeds
- Evaluate each candidate for quality and consistency
- Select the best candidates
- Check cross-frame consistency
- Regenerate problematic frames with adjusted parameters
"""

import json
import urllib.request
import urllib.parse
import time
import sys
from pathlib import Path
from PIL import Image
from rembg import remove
import io

COMFYUI_URL = "http://127.0.0.1:8188"
PROJECT_ROOT = Path(__file__).parent.parent.parent
SPRITES_DIR = PROJECT_ROOT / "resources" / "sprites"
POSE_DIR = SPRITES_DIR / "pose_references"
OUTPUT_DIR = SPRITES_DIR / "polished_animation"

# Number of candidates per frame
CANDIDATES_PER_FRAME = 3


def upload_image(image_path: Path) -> str:
    """Upload an image to ComfyUI."""
    with open(image_path, 'rb') as f:
        image_data = f.read()

    boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW'
    filename = image_path.name

    body = (
        f'--{boundary}\r\n'
        f'Content-Disposition: form-data; name="image"; filename="{filename}"\r\n'
        f'Content-Type: image/png\r\n\r\n'
    ).encode('utf-8') + image_data + f'\r\n--{boundary}--\r\n'.encode('utf-8')

    req = urllib.request.Request(
        f"{COMFYUI_URL}/upload/image",
        data=body,
        headers={'Content-Type': f'multipart/form-data; boundary={boundary}'},
        method='POST'
    )

    response = json.loads(urllib.request.urlopen(req).read())
    return response.get("name", filename)


def create_workflow(
    reference_image_name: str,
    pose_image_name: str,
    prompt: str,
    negative_prompt: str,
    seed: int,
    controlnet_strength: float = 0.6,
    ipadapter_weight: float = 0.97
) -> dict:
    """
    Create ControlNet + IP-Adapter workflow with tuned parameters.
    """
    return {
        # Load checkpoint
        "1": {
            "class_type": "CheckpointLoaderSimple",
            "inputs": {"ckpt_name": "v1-5-pruned-emaonly.safetensors"}
        },

        # Load ControlNet model
        "2": {
            "class_type": "ControlNetLoader",
            "inputs": {"control_net_name": "control_v11p_sd15_openpose.pth"}
        },

        # Load IP-Adapter
        "3": {
            "class_type": "IPAdapterUnifiedLoader",
            "inputs": {"model": ["1", 0], "preset": "PLUS (high strength)"}
        },

        # Load reference image
        "4": {
            "class_type": "LoadImage",
            "inputs": {"image": reference_image_name}
        },

        # Load pose image
        "5": {
            "class_type": "LoadImage",
            "inputs": {"image": pose_image_name}
        },

        # Apply IP-Adapter
        "6": {
            "class_type": "IPAdapter",
            "inputs": {
                "model": ["3", 0],
                "ipadapter": ["3", 1],
                "image": ["4", 0],
                "weight": ipadapter_weight,
                "start_at": 0.0,
                "end_at": 1.0,
                "weight_type": "standard"
            }
        },

        # Positive prompt
        "8": {
            "class_type": "CLIPTextEncode",
            "inputs": {
                "text": prompt,
                "clip": ["1", 1]
            }
        },

        # Apply ControlNet
        "7": {
            "class_type": "ControlNetApply",
            "inputs": {
                "conditioning": ["8", 0],
                "control_net": ["2", 0],
                "image": ["5", 0],
                "strength": controlnet_strength
            }
        },

        # Negative prompt
        "9": {
            "class_type": "CLIPTextEncode",
            "inputs": {
                "text": negative_prompt,
                "clip": ["1", 1]
            }
        },

        # Empty latent
        "10": {
            "class_type": "EmptyLatentImage",
            "inputs": {"width": 512, "height": 512, "batch_size": 1}
        },

        # KSampler
        "11": {
            "class_type": "KSampler",
            "inputs": {
                "model": ["6", 0],
                "positive": ["7", 0],
                "negative": ["9", 0],
                "latent_image": ["10", 0],
                "seed": seed,
                "steps": 30,
                "cfg": 7.5,
                "sampler_name": "euler",
                "scheduler": "normal",
                "denoise": 1.0
            }
        },

        # VAE Decode
        "12": {
            "class_type": "VAEDecode",
            "inputs": {
                "samples": ["11", 0],
                "vae": ["1", 2]
            }
        },

        # Save Image
        "13": {
            "class_type": "SaveImage",
            "inputs": {
                "images": ["12", 0],
                "filename_prefix": "polished_frame"
            }
        }
    }


def queue_and_wait(workflow: dict, timeout: int = 300) -> dict:
    """Queue workflow and wait for completion."""
    data = json.dumps({
        "prompt": workflow,
        "client_id": "polished_pipeline"
    }).encode('utf-8')

    req = urllib.request.Request(
        f"{COMFYUI_URL}/prompt",
        data=data,
        headers={"Content-Type": "application/json"}
    )

    response = json.loads(urllib.request.urlopen(req).read())
    prompt_id = response.get("prompt_id")

    if not prompt_id:
        if "error" in response:
            raise RuntimeError(f"ComfyUI error: {response['error']}")
        raise RuntimeError(f"No prompt_id: {response}")

    start = time.time()
    while time.time() - start < timeout:
        url = f"{COMFYUI_URL}/history/{prompt_id}"
        history = json.loads(urllib.request.urlopen(url).read())
        if prompt_id in history:
            return history[prompt_id]
        time.sleep(2)

    raise TimeoutError("Generation timed out")


def download_image(filename: str, subfolder: str = "", folder_type: str = "output") -> bytes:
    """Download image from ComfyUI."""
    params = urllib.parse.urlencode({
        "filename": filename,
        "subfolder": subfolder,
        "type": folder_type
    })
    return urllib.request.urlopen(f"{COMFYUI_URL}/view?{params}").read()


def generate_candidates():
    """Generate multiple candidates per frame for LLM evaluation."""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Check for pose references
    pose_files = sorted(POSE_DIR.glob("pose_*.png"))
    if not pose_files:
        print(f"Error: No pose references found in {POSE_DIR}")
        sys.exit(1)

    # Reference character image
    reference_path = SPRITES_DIR / "miner_swing.png"
    if not reference_path.exists():
        print(f"Error: Reference image not found: {reference_path}")
        sys.exit(1)

    print("=" * 70)
    print("POLISHED ANIMATION PIPELINE - CANDIDATE GENERATION")
    print("=" * 70)

    # Upload reference
    print("\nUploading reference character...")
    ref_name = upload_image(reference_path)
    print(f"  Uploaded as: {ref_name}")

    # Prompts optimized for consistency
    base_prompt = (
        "pixel art miner character, game sprite, centered composition, "
        "solid white background, blue denim jeans, tan skin tone, bald head, "
        "holding black pickaxe, simple pixel art style, 8-bit retro aesthetic, "
        "single character only, no scene, no environment, clean edges, "
        "consistent proportions, facing right"
    )

    negative_prompt = (
        "blurry, realistic, 3d render, photograph, multiple characters, "
        "deformed, bad anatomy, wrong proportions, extra limbs, mutated, "
        "ugly, text, watermark, signature, background elements, "
        "scene, environment, floor, ground, sky, frame, border, "
        "different style, inconsistent, black background, gradient background, "
        "realistic proportions, detailed background, landscape"
    )

    # Frame definitions
    frames = [
        {"name": "ready", "pose_idx": 0},
        {"name": "windup_1", "pose_idx": 1},
        {"name": "windup_2", "pose_idx": 2},
        {"name": "windup_full", "pose_idx": 3},
        {"name": "swing_start", "pose_idx": 4},
        {"name": "swing_mid", "pose_idx": 5},
        {"name": "swing_low", "pose_idx": 6},
        {"name": "impact", "pose_idx": 7},
    ]

    # Generate candidates
    all_candidates = {}
    base_seed = 12345

    for frame_idx, frame_def in enumerate(frames):
        frame_name = frame_def["name"]
        pose_path = pose_files[frame_def["pose_idx"]]

        print(f"\n{'='*60}")
        print(f"Frame {frame_idx + 1}/8: {frame_name}")
        print(f"{'='*60}")

        # Upload pose
        pose_name = upload_image(pose_path)

        candidates = []
        for c in range(CANDIDATES_PER_FRAME):
            seed = base_seed + frame_idx * 100 + c * 17  # Varied seeds

            print(f"  Candidate {c + 1}/{CANDIDATES_PER_FRAME} (seed={seed})...")

            workflow = create_workflow(
                reference_image_name=ref_name,
                pose_image_name=pose_name,
                prompt=base_prompt,
                negative_prompt=negative_prompt,
                seed=seed,
                controlnet_strength=0.55,  # Balanced
                ipadapter_weight=0.97      # Strong consistency
            )

            try:
                result = queue_and_wait(workflow)
                outputs = result.get("outputs", {})

                if "13" in outputs:
                    images = outputs["13"].get("images", [])
                    if images:
                        img_info = images[0]
                        img_data = download_image(
                            img_info["filename"],
                            img_info.get("subfolder", ""),
                            img_info.get("type", "output")
                        )

                        output_path = OUTPUT_DIR / f"frame_{frame_idx:02d}_{frame_name}_c{c}.png"
                        with open(output_path, 'wb') as f:
                            f.write(img_data)

                        candidates.append({
                            "path": output_path,
                            "seed": seed,
                            "candidate_idx": c
                        })
                        print(f"    Saved: {output_path.name}")

            except Exception as e:
                print(f"    Error: {e}")
                continue

        all_candidates[frame_name] = candidates

    print("\n" + "=" * 70)
    print("CANDIDATE GENERATION COMPLETE")
    print("=" * 70)
    print(f"\nGenerated {sum(len(v) for v in all_candidates.values())} total candidates")
    print(f"Output directory: {OUTPUT_DIR}")

    # Save metadata for evaluation
    metadata_path = OUTPUT_DIR / "candidates_metadata.json"
    with open(metadata_path, 'w') as f:
        json.dump({
            frame: [{"path": str(c["path"]), "seed": c["seed"]} for c in cands]
            for frame, cands in all_candidates.items()
        }, f, indent=2)

    print(f"Metadata saved: {metadata_path}")
    return all_candidates


if __name__ == "__main__":
    # Check ComfyUI
    try:
        urllib.request.urlopen(f"{COMFYUI_URL}/system_stats")
    except Exception:
        print("Error: ComfyUI is not running!")
        sys.exit(1)

    generate_candidates()
