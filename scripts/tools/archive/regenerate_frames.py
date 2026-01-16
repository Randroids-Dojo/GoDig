#!/opt/homebrew/bin/python3.11
"""
Regenerate problematic frames with adjusted parameters.
"""

import json
import urllib.request
import urllib.parse
import time
import sys
from pathlib import Path

COMFYUI_URL = "http://127.0.0.1:8188"
PROJECT_ROOT = Path(__file__).parent.parent.parent
SPRITES_DIR = PROJECT_ROOT / "resources" / "sprites"
POSE_DIR = SPRITES_DIR / "pose_references"
OUTPUT_DIR = SPRITES_DIR / "polished_animation" / "regen"


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
    controlnet_strength: float,
    ipadapter_weight: float
) -> dict:
    """Create workflow with specified parameters."""
    return {
        "1": {
            "class_type": "CheckpointLoaderSimple",
            "inputs": {"ckpt_name": "v1-5-pruned-emaonly.safetensors"}
        },
        "2": {
            "class_type": "ControlNetLoader",
            "inputs": {"control_net_name": "control_v11p_sd15_openpose.pth"}
        },
        "3": {
            "class_type": "IPAdapterUnifiedLoader",
            "inputs": {"model": ["1", 0], "preset": "PLUS (high strength)"}
        },
        "4": {
            "class_type": "LoadImage",
            "inputs": {"image": reference_image_name}
        },
        "5": {
            "class_type": "LoadImage",
            "inputs": {"image": pose_image_name}
        },
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
        "8": {
            "class_type": "CLIPTextEncode",
            "inputs": {
                "text": prompt,
                "clip": ["1", 1]
            }
        },
        "7": {
            "class_type": "ControlNetApply",
            "inputs": {
                "conditioning": ["8", 0],
                "control_net": ["2", 0],
                "image": ["5", 0],
                "strength": controlnet_strength
            }
        },
        "9": {
            "class_type": "CLIPTextEncode",
            "inputs": {
                "text": negative_prompt,
                "clip": ["1", 1]
            }
        },
        "10": {
            "class_type": "EmptyLatentImage",
            "inputs": {"width": 512, "height": 512, "batch_size": 1}
        },
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
        "12": {
            "class_type": "VAEDecode",
            "inputs": {
                "samples": ["11", 0],
                "vae": ["1", 2]
            }
        },
        "13": {
            "class_type": "SaveImage",
            "inputs": {
                "images": ["12", 0],
                "filename_prefix": "regen_frame"
            }
        }
    }


def queue_and_wait(workflow: dict, timeout: int = 300) -> dict:
    """Queue workflow and wait for completion."""
    data = json.dumps({
        "prompt": workflow,
        "client_id": "regen_pipeline"
    }).encode('utf-8')

    req = urllib.request.Request(
        f"{COMFYUI_URL}/prompt",
        data=data,
        headers={"Content-Type": "application/json"}
    )

    response = json.loads(urllib.request.urlopen(req).read())
    prompt_id = response.get("prompt_id")

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


def regenerate_frames():
    """Regenerate frames 5 and 7 with adjusted parameters."""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Frames to regenerate
    frames_to_regen = [
        {"idx": 5, "name": "swing_mid", "pose_file": "pose_05_swing_mid.png"},
        {"idx": 7, "name": "impact", "pose_file": "pose_07_impact.png"},
    ]

    pose_files = sorted(POSE_DIR.glob("pose_*.png"))
    reference_path = SPRITES_DIR / "miner_swing.png"

    print("=" * 60)
    print("REGENERATING PROBLEMATIC FRAMES")
    print("=" * 60)

    # Upload reference
    print("\nUploading reference...")
    ref_name = upload_image(reference_path)

    # Optimized prompts - emphasize isolation
    base_prompt = (
        "pixel art miner character, isolated sprite, NO BACKGROUND, "
        "solid white background only, blue denim jeans, tan skin, bald head, "
        "holding black pickaxe, simple pixel art style, 8-bit aesthetic, "
        "single character, centered, clean edges, sprite sheet style, "
        "transparent background compatible"
    )

    negative_prompt = (
        "background, scene, environment, floor, ground, sky, wall, "
        "frame, border, shadow, gradient, texture, pattern, "
        "realistic, 3d, photograph, multiple characters, "
        "deformed, blurry, artifacts, noise, dark background, "
        "landscape, indoor, outdoor, room, building"
    )

    # Generate more candidates with varied parameters
    candidates_per_frame = 5

    for frame_def in frames_to_regen:
        frame_idx = frame_def["idx"]
        frame_name = frame_def["name"]
        pose_file = frame_def["pose_file"]

        print(f"\n{'='*50}")
        print(f"Regenerating Frame {frame_idx}: {frame_name}")
        print(f"{'='*50}")

        pose_path = POSE_DIR / pose_file
        pose_name = upload_image(pose_path)

        # Try different parameter combinations
        param_sets = [
            {"cn": 0.4, "ip": 0.98, "seed_base": 20000},  # Lower ControlNet
            {"cn": 0.35, "ip": 0.99, "seed_base": 30000}, # Even lower ControlNet
            {"cn": 0.5, "ip": 0.97, "seed_base": 40000},  # Balanced
            {"cn": 0.3, "ip": 0.99, "seed_base": 50000},  # Very low ControlNet
            {"cn": 0.45, "ip": 0.98, "seed_base": 60000}, # Medium
        ]

        for c, params in enumerate(param_sets):
            seed = params["seed_base"] + frame_idx * 10 + c
            print(f"  Candidate {c+1}/5 (CN={params['cn']}, IP={params['ip']}, seed={seed})...")

            workflow = create_workflow(
                reference_image_name=ref_name,
                pose_image_name=pose_name,
                prompt=base_prompt,
                negative_prompt=negative_prompt,
                seed=seed,
                controlnet_strength=params["cn"],
                ipadapter_weight=params["ip"]
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

                        output_path = OUTPUT_DIR / f"regen_{frame_idx:02d}_{frame_name}_c{c}.png"
                        with open(output_path, 'wb') as f:
                            f.write(img_data)
                        print(f"    Saved: {output_path.name}")

            except Exception as e:
                print(f"    Error: {e}")

    print("\n" + "=" * 60)
    print("REGENERATION COMPLETE")
    print(f"Output: {OUTPUT_DIR}")
    print("=" * 60)


if __name__ == "__main__":
    try:
        urllib.request.urlopen(f"{COMFYUI_URL}/system_stats")
    except Exception:
        print("Error: ComfyUI is not running!")
        sys.exit(1)

    regenerate_frames()
