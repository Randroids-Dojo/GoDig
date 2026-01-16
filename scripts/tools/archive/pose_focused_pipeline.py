#!/opt/homebrew/bin/python3.11
"""
Pose-Focused Animation Pipeline

Key changes from previous attempts:
- LOWER IP-Adapter weight (0.6) to allow pose variation
- HIGHER ControlNet strength (0.8) to enforce poses
- Frame-specific prompts describing exact pickaxe position
- Validation against pose checklist
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
OUTPUT_DIR = SPRITES_DIR / "pose_focused_animation"

# Frame-specific prompts with EXPLICIT pickaxe positions
FRAME_PROMPTS = [
    {
        "name": "ready",
        "prompt": "pixel art miner, PICKAXE HELD LOW at side near hip, relaxed standing pose, "
                  "arms down, pickaxe resting, facing right",
        "pickaxe_expected": "LOW - at side"
    },
    {
        "name": "windup_1",
        "prompt": "pixel art miner, PICKAXE RISING upward, arms lifting pickaxe from side, "
                  "beginning backswing motion, facing right",
        "pickaxe_expected": "RISING - mid height"
    },
    {
        "name": "windup_2",
        "prompt": "pixel art miner, PICKAXE AT SHOULDER HEIGHT, arms bent raising pickaxe, "
                  "coiling for swing, leaning back slightly, facing right",
        "pickaxe_expected": "MID-HIGH - shoulder level"
    },
    {
        "name": "windup_full",
        "prompt": "pixel art miner, PICKAXE RAISED HIGH OVERHEAD above head, arms extended up, "
                  "maximum backswing position, leaning back, facing right",
        "pickaxe_expected": "HIGH - above head"
    },
    {
        "name": "swing_start",
        "prompt": "pixel art miner, PICKAXE COMING DOWN from overhead, beginning downswing, "
                  "arms driving forward, weight shifting forward, facing right",
        "pickaxe_expected": "DESCENDING - from overhead"
    },
    {
        "name": "swing_mid",
        "prompt": "pixel art miner, PICKAXE IN FRONT at chest height, mid-swing motion, "
                  "arms extended forward, powerful swing pose, facing right",
        "pickaxe_expected": "MID-FRONT - chest level"
    },
    {
        "name": "swing_low",
        "prompt": "pixel art miner, PICKAXE LOW approaching ground, arms extended down and forward, "
                  "follow-through motion, bent forward, facing right",
        "pickaxe_expected": "LOW-FRONT - near ground"
    },
    {
        "name": "impact",
        "prompt": "pixel art miner, PICKAXE AT GROUND LEVEL hitting ground, impact pose, "
                  "arms fully extended down, bent over, follow-through complete, facing right",
        "pickaxe_expected": "GROUND - at ground level"
    },
]

# Common prompt elements
STYLE_SUFFIX = (
    ", game sprite, blue jeans, tan skin, bald head, simple pixel art style, "
    "8-bit aesthetic, white background, centered, clean edges, single character"
)

NEGATIVE_PROMPT = (
    "blurry, realistic, 3d, photograph, multiple characters, deformed, "
    "wrong pose, pickaxe in wrong position, background scene, environment, "
    "floor, ground texture, sky, dark background, frame, border"
)


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
    seed: int,
    controlnet_strength: float = 0.8,  # HIGH - enforce poses
    ipadapter_weight: float = 0.6      # LOW - allow variation
) -> dict:
    """Create workflow with pose-focused parameters."""
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
                "text": prompt + STYLE_SUFFIX,
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
                "text": NEGATIVE_PROMPT,
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
                "filename_prefix": "pose_focused"
            }
        }
    }


def queue_and_wait(workflow: dict, timeout: int = 300) -> dict:
    """Queue workflow and wait for completion."""
    data = json.dumps({
        "prompt": workflow,
        "client_id": "pose_focused_pipeline"
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


def generate_frames():
    """Generate animation frames with pose-focused parameters."""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    pose_files = sorted(POSE_DIR.glob("pose_*.png"))
    if len(pose_files) < 8:
        print(f"Error: Need 8 pose references, found {len(pose_files)}")
        sys.exit(1)

    reference_path = SPRITES_DIR / "miner_swing.png"
    if not reference_path.exists():
        print(f"Error: Reference not found: {reference_path}")
        sys.exit(1)

    print("=" * 70)
    print("POSE-FOCUSED ANIMATION PIPELINE")
    print("=" * 70)
    print("\nKey parameters:")
    print("  - IP-Adapter weight: 0.6 (LOW - allows pose variation)")
    print("  - ControlNet strength: 0.8 (HIGH - enforces poses)")
    print("  - Frame-specific prompts with explicit pickaxe positions")

    # Upload reference
    print("\nUploading reference...")
    ref_name = upload_image(reference_path)

    # Generate 2 candidates per frame
    candidates_per_frame = 2
    base_seed = 77777

    for frame_idx, frame_def in enumerate(FRAME_PROMPTS):
        pose_path = pose_files[frame_idx]

        print(f"\n{'='*60}")
        print(f"Frame {frame_idx}: {frame_def['name']}")
        print(f"Expected: {frame_def['pickaxe_expected']}")
        print(f"{'='*60}")

        pose_name = upload_image(pose_path)

        for c in range(candidates_per_frame):
            seed = base_seed + frame_idx * 100 + c * 13
            print(f"  Candidate {c+1}/{candidates_per_frame} (seed={seed})...")

            workflow = create_workflow(
                reference_image_name=ref_name,
                pose_image_name=pose_name,
                prompt=frame_def["prompt"],
                seed=seed,
                controlnet_strength=0.8,
                ipadapter_weight=0.6
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

                        output_path = OUTPUT_DIR / f"frame_{frame_idx:02d}_{frame_def['name']}_c{c}.png"
                        with open(output_path, 'wb') as f:
                            f.write(img_data)
                        print(f"    Saved: {output_path.name}")

            except Exception as e:
                print(f"    Error: {e}")

    print("\n" + "=" * 70)
    print("GENERATION COMPLETE")
    print(f"Output: {OUTPUT_DIR}")
    print("=" * 70)
    print("\nNow validate each frame against expected pickaxe positions!")


if __name__ == "__main__":
    try:
        urllib.request.urlopen(f"{COMFYUI_URL}/system_stats")
    except Exception:
        print("Error: ComfyUI is not running!")
        sys.exit(1)

    generate_frames()
