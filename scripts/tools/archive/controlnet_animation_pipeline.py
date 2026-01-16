#!/opt/homebrew/bin/python3.11
"""
ControlNet + IP-Adapter Animation Pipeline

Uses ControlNet (OpenPose) for POSE control and IP-Adapter for CHARACTER consistency.
This combination allows generating animation frames with distinct poses while
maintaining consistent character appearance.

Workflow:
1. Load reference character image (for IP-Adapter)
2. Load pose reference images (for ControlNet)
3. Generate each frame with both conditioning:
   - ControlNet guides the POSE from skeleton reference
   - IP-Adapter maintains CHARACTER appearance from reference
4. Post-process and create sprite sheet

Requirements:
    - ComfyUI with ControlNet aux preprocessors
    - IP-Adapter Plus custom nodes
    - OpenPose ControlNet model (control_v11p_sd15_openpose.pth)
    - SD 1.5 checkpoint
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
OUTPUT_DIR = SPRITES_DIR / "controlnet_animation"


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


def create_controlnet_ipadapter_workflow(
    reference_image_name: str,
    pose_image_name: str,
    prompt: str,
    seed: int,
    controlnet_strength: float = 0.8,
    ipadapter_weight: float = 0.95
) -> dict:
    """
    Create workflow combining ControlNet (pose) + IP-Adapter (character).

    The key insight is:
    - ControlNet controls WHERE body parts are (pose/skeleton)
    - IP-Adapter controls WHAT the character looks like (appearance)
    """
    return {
        # Load checkpoint (outputs: MODEL, CLIP, VAE)
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

        # Load reference image (for IP-Adapter character appearance)
        "4": {
            "class_type": "LoadImage",
            "inputs": {"image": reference_image_name}
        },

        # Load pose image (for ControlNet pose guidance)
        "5": {
            "class_type": "LoadImage",
            "inputs": {"image": pose_image_name}
        },

        # Apply IP-Adapter to model (character appearance)
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

        # Apply ControlNet to model (pose guidance)
        "7": {
            "class_type": "ControlNetApply",
            "inputs": {
                "conditioning": ["8", 0],  # Positive prompt
                "control_net": ["2", 0],
                "image": ["5", 0],
                "strength": controlnet_strength
            }
        },

        # Positive prompt encoding
        "8": {
            "class_type": "CLIPTextEncode",
            "inputs": {
                "text": prompt,
                "clip": ["1", 1]
            }
        },

        # Negative prompt encoding - aggressive consistency enforcement
        "9": {
            "class_type": "CLIPTextEncode",
            "inputs": {
                "text": "blurry, realistic, 3d render, photo, multiple characters, "
                       "deformed, bad anatomy, wrong proportions, extra limbs, "
                       "mutated, ugly, text, watermark, signature, "
                       "background, scene, environment, floor, ground, sky, "
                       "frame, border, different style, inconsistent",
                "clip": ["1", 1]
            }
        },

        # Empty latent
        "10": {
            "class_type": "EmptyLatentImage",
            "inputs": {"width": 512, "height": 512, "batch_size": 1}
        },

        # KSampler with both ControlNet and IP-Adapter conditioning
        "11": {
            "class_type": "KSampler",
            "inputs": {
                "model": ["6", 0],  # IP-Adapter conditioned model
                "positive": ["7", 0],  # ControlNet conditioned positive
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
                "filename_prefix": "controlnet_frame"
            }
        }
    }


def queue_and_wait(workflow: dict, timeout: int = 600) -> dict:
    """Queue workflow and wait for completion."""
    data = json.dumps({
        "prompt": workflow,
        "client_id": "controlnet_pipeline"
    }).encode('utf-8')

    req = urllib.request.Request(
        f"{COMFYUI_URL}/prompt",
        data=data,
        headers={"Content-Type": "application/json"}
    )

    response = json.loads(urllib.request.urlopen(req).read())
    prompt_id = response.get("prompt_id")

    if not prompt_id:
        # Check for errors
        if "error" in response:
            raise RuntimeError(f"ComfyUI error: {response['error']}")
        raise RuntimeError(f"No prompt_id in response: {response}")

    print(f"    Queued: {prompt_id}")

    start = time.time()
    while time.time() - start < timeout:
        url = f"{COMFYUI_URL}/history/{prompt_id}"
        history = json.loads(urllib.request.urlopen(url).read())
        if prompt_id in history:
            return history[prompt_id]
        time.sleep(2)

    raise TimeoutError(f"Generation timed out after {timeout}s")


def download_image(filename: str, subfolder: str = "", folder_type: str = "output") -> bytes:
    """Download image from ComfyUI."""
    params = urllib.parse.urlencode({
        "filename": filename,
        "subfolder": subfolder,
        "type": folder_type
    })
    return urllib.request.urlopen(f"{COMFYUI_URL}/view?{params}").read()


def generate_animation():
    """Generate animation frames using ControlNet + IP-Adapter."""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Check for pose references
    pose_files = sorted(POSE_DIR.glob("pose_*.png"))
    if not pose_files:
        print(f"Error: No pose references found in {POSE_DIR}")
        print("Run create_pose_references.py first!")
        sys.exit(1)

    # Reference character image
    reference_path = SPRITES_DIR / "miner_swing.png"
    if not reference_path.exists():
        print(f"Error: Reference image not found: {reference_path}")
        sys.exit(1)

    print("=" * 60)
    print("CONTROLNET + IP-ADAPTER ANIMATION PIPELINE")
    print("=" * 60)

    # Upload reference image
    print("\nUploading reference character...")
    ref_name = upload_image(reference_path)
    print(f"  Uploaded as: {ref_name}")

    # Base prompt (consistent across all frames) - emphasize consistency
    base_prompt = (
        "pixel art miner character, game sprite, centered, clean edges, "
        "solid white background, blue jeans, tan skin, bald head, holding pickaxe, "
        "simple pixel art style, 8-bit aesthetic, consistent style, "
        "single character, no scene, no environment"
    )

    # Generate frames
    output_paths = []
    base_seed = 42

    for i, pose_path in enumerate(pose_files):
        frame_name = pose_path.stem.replace("pose_", "")
        print(f"\nFrame {i+1}/{len(pose_files)}: {frame_name}")

        # Upload pose image
        print(f"  Uploading pose: {pose_path.name}")
        pose_name = upload_image(pose_path)

        # Create and run workflow
        # Use same seed for consistency, lower ControlNet to let IP-Adapter dominate
        print(f"  Generating with ControlNet + IP-Adapter...")
        workflow = create_controlnet_ipadapter_workflow(
            reference_image_name=ref_name,
            pose_image_name=pose_name,
            prompt=base_prompt,
            seed=base_seed,  # Same seed for all frames
            controlnet_strength=0.5,  # Lower - let IP-Adapter dominate
            ipadapter_weight=0.98     # Very strong character preservation
        )

        try:
            result = queue_and_wait(workflow)

            # Get output image
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

                    output_path = OUTPUT_DIR / f"frame_{i:02d}_{frame_name}.png"
                    with open(output_path, 'wb') as f:
                        f.write(img_data)

                    output_paths.append(output_path)
                    print(f"  Saved: {output_path}")
        except Exception as e:
            print(f"  Error: {e}")
            continue

    if not output_paths:
        print("\nNo frames generated!")
        sys.exit(1)

    # Post-process and create sprite sheet
    print("\n" + "=" * 60)
    print("POST-PROCESSING")
    print("=" * 60)

    processed_frames = []
    frame_size = (128, 128)

    for path in output_paths:
        print(f"Processing {path.name}...")

        with open(path, 'rb') as f:
            img_data = f.read()

        # Remove background
        nobg_data = remove(img_data)

        # Resize
        img = Image.open(io.BytesIO(nobg_data))
        img = img.resize(frame_size, Image.Resampling.NEAREST)

        processed_frames.append(img)

    # Create sprite sheet
    num_frames = len(processed_frames)
    sheet_width = frame_size[0] * num_frames
    sheet_height = frame_size[1]

    sprite_sheet = Image.new('RGBA', (sheet_width, sheet_height), (0, 0, 0, 0))

    for i, frame in enumerate(processed_frames):
        sprite_sheet.paste(frame, (i * frame_size[0], 0))

    sheet_path = SPRITES_DIR / "miner_swing_controlnet.png"
    sprite_sheet.save(sheet_path, "PNG")

    print("\n" + "=" * 60)
    print("COMPLETE")
    print("=" * 60)
    print(f"Sprite sheet: {sheet_path}")
    print(f"Frames: {num_frames}")
    print(f"Size: {sprite_sheet.size}")

    return sheet_path


if __name__ == "__main__":
    # Check ComfyUI
    try:
        urllib.request.urlopen(f"{COMFYUI_URL}/system_stats")
    except Exception:
        print("Error: ComfyUI is not running!")
        print("Start it with: cd ~/ComfyUI && /opt/homebrew/bin/python3.11 main.py")
        sys.exit(1)

    generate_animation()
