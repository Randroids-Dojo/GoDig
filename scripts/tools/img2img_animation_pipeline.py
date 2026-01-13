#!/opt/homebrew/bin/python3.11
"""
Img2Img Animation Pipeline for GoDig

Uses img2img from a base frame to create consistent animation frames.
This approach maintains pixel-level consistency by starting from the same
base image and using low denoise values.

Strategy:
1. Take a reference character image
2. Generate a clean "base frame" using IP-Adapter
3. Use img2img with low denoise (0.3-0.5) to create pose variations
4. Each frame starts from the SAME base, ensuring consistency

This is more effective than txt2img because:
- Base colors/proportions are preserved
- Only the pose changes vary
- Much higher frame-to-frame consistency
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
OUTPUT_DIR = SPRITES_DIR / "img2img_animation"


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


def create_img2img_workflow(
    base_image_name: str,
    reference_image_name: str,
    prompt: str,
    seed: int,
    denoise: float = 0.4,
    ipadapter_weight: float = 0.95
) -> dict:
    """
    Create img2img workflow that:
    1. Loads the base image as the starting latent
    2. Uses IP-Adapter with reference for character consistency
    3. Applies low denoise to preserve base structure
    """
    return {
        # Load checkpoint
        "1": {
            "class_type": "CheckpointLoaderSimple",
            "inputs": {"ckpt_name": "v1-5-pruned-emaonly.safetensors"}
        },
        # Load IP-Adapter
        "2": {
            "class_type": "IPAdapterUnifiedLoader",
            "inputs": {"model": ["1", 0], "preset": "PLUS (high strength)"}
        },
        # Load reference image for IP-Adapter
        "3": {
            "class_type": "LoadImage",
            "inputs": {"image": reference_image_name}
        },
        # Load base image (starting point for img2img)
        "4": {
            "class_type": "LoadImage",
            "inputs": {"image": base_image_name}
        },
        # Apply IP-Adapter
        "5": {
            "class_type": "IPAdapter",
            "inputs": {
                "model": ["2", 0],
                "ipadapter": ["2", 1],
                "image": ["3", 0],
                "weight": ipadapter_weight,
                "start_at": 0.0,
                "end_at": 1.0,
                "weight_type": "standard"
            }
        },
        # Encode base image to latent (for img2img)
        "6": {
            "class_type": "VAEEncode",
            "inputs": {
                "pixels": ["4", 0],
                "vae": ["1", 2]
            }
        },
        # Positive prompt
        "7": {
            "class_type": "CLIPTextEncode",
            "inputs": {
                "text": prompt,
                "clip": ["1", 1]
            }
        },
        # Negative prompt
        "8": {
            "class_type": "CLIPTextEncode",
            "inputs": {
                "text": "blurry, realistic, 3d render, photo, different character, "
                       "wrong colors, deformed, bad anatomy, extra limbs, "
                       "inconsistent style, different proportions",
                "clip": ["1", 1]
            }
        },
        # KSampler with low denoise for img2img
        "9": {
            "class_type": "KSampler",
            "inputs": {
                "model": ["5", 0],
                "positive": ["7", 0],
                "negative": ["8", 0],
                "latent_image": ["6", 0],  # Start from base image latent
                "seed": seed,
                "steps": 25,
                "cfg": 7.0,
                "sampler_name": "euler",
                "scheduler": "normal",
                "denoise": denoise  # Low denoise preserves base
            }
        },
        # VAE Decode
        "10": {
            "class_type": "VAEDecode",
            "inputs": {
                "samples": ["9", 0],
                "vae": ["1", 2]
            }
        },
        # Save Image
        "11": {
            "class_type": "SaveImage",
            "inputs": {
                "images": ["10", 0],
                "filename_prefix": "img2img_frame"
            }
        }
    }


def queue_and_wait(workflow: dict, timeout: int = 300) -> dict:
    """Queue workflow and wait for completion."""
    data = json.dumps({
        "prompt": workflow,
        "client_id": "img2img_pipeline"
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
        time.sleep(1)

    raise TimeoutError("Generation timed out")


def download_image(filename: str, subfolder: str = "", folder_type: str = "output") -> bytes:
    """Download image from ComfyUI."""
    params = urllib.parse.urlencode({
        "filename": filename,
        "subfolder": subfolder,
        "type": folder_type
    })
    return urllib.request.urlopen(f"{COMFYUI_URL}/view?{params}").read()


def generate_base_frame(reference_path: Path, output_path: Path) -> Path:
    """Generate a clean base frame from reference using txt2img + IP-Adapter."""
    print("Generating base frame...")

    ref_name = upload_image(reference_path)

    # High quality base frame generation
    workflow = {
        "1": {
            "class_type": "CheckpointLoaderSimple",
            "inputs": {"ckpt_name": "v1-5-pruned-emaonly.safetensors"}
        },
        "2": {
            "class_type": "IPAdapterUnifiedLoader",
            "inputs": {"model": ["1", 0], "preset": "PLUS (high strength)"}
        },
        "3": {
            "class_type": "LoadImage",
            "inputs": {"image": ref_name}
        },
        "4": {
            "class_type": "IPAdapter",
            "inputs": {
                "model": ["2", 0],
                "ipadapter": ["2", 1],
                "image": ["3", 0],
                "weight": 0.98,  # Very high weight for base
                "start_at": 0.0,
                "end_at": 1.0,
                "weight_type": "standard"
            }
        },
        "5": {
            "class_type": "CLIPTextEncode",
            "inputs": {
                "text": "pixel art miner character, standing ready pose, holding pickaxe, "
                       "facing right, game sprite, centered, clean edges, white background, "
                       "blue jeans, tan skin, bald head",
                "clip": ["1", 1]
            }
        },
        "6": {
            "class_type": "CLIPTextEncode",
            "inputs": {
                "text": "blurry, realistic, 3d, photo, multiple characters, text, watermark, "
                       "deformed, bad anatomy, wrong colors, black background",
                "clip": ["1", 1]
            }
        },
        "7": {
            "class_type": "EmptyLatentImage",
            "inputs": {"width": 512, "height": 512, "batch_size": 1}
        },
        "8": {
            "class_type": "KSampler",
            "inputs": {
                "model": ["4", 0],
                "positive": ["5", 0],
                "negative": ["6", 0],
                "latent_image": ["7", 0],
                "seed": 42,
                "steps": 40,
                "cfg": 7.5,
                "sampler_name": "euler",
                "scheduler": "normal",
                "denoise": 1.0
            }
        },
        "9": {
            "class_type": "VAEDecode",
            "inputs": {"samples": ["8", 0], "vae": ["1", 2]}
        },
        "10": {
            "class_type": "SaveImage",
            "inputs": {"images": ["9", 0], "filename_prefix": "base_frame"}
        }
    }

    result = queue_and_wait(workflow)
    outputs = result.get("outputs", {})

    if "10" in outputs:
        images = outputs["10"].get("images", [])
        if images:
            img_info = images[0]
            img_data = download_image(
                img_info["filename"],
                img_info.get("subfolder", ""),
                img_info.get("type", "output")
            )
            with open(output_path, 'wb') as f:
                f.write(img_data)
            print(f"  Base frame saved: {output_path}")
            return output_path

    raise RuntimeError("Failed to generate base frame")


def generate_animation_frames(
    reference_path: Path,
    base_frame_path: Path,
    output_dir: Path,
    denoise_values: list[float] = None
) -> list[Path]:
    """
    Generate animation frames using img2img from base frame.

    Uses varying denoise values to control how much the pose changes:
    - Lower denoise (0.2-0.3): Very similar to base, subtle changes
    - Medium denoise (0.4-0.5): Moderate pose changes
    - Higher denoise (0.6-0.7): More dramatic pose changes
    """
    output_dir.mkdir(parents=True, exist_ok=True)

    # Upload images
    ref_name = upload_image(reference_path)
    base_name = upload_image(base_frame_path)

    # Animation frame definitions with appropriate denoise values
    # Lower denoise = more similar to base, higher = more change
    frames = [
        {"name": "ready", "denoise": 0.25,
         "prompt": "pixel art miner, standing ready stance, pickaxe held at side vertically, "
                  "relaxed pose, facing right, game sprite, centered, clean edges, white background"},

        {"name": "windup_1", "denoise": 0.35,
         "prompt": "pixel art miner, beginning wind up, lifting pickaxe slightly, "
                  "arms starting to raise, facing right, game sprite, centered, clean edges, white background"},

        {"name": "windup_2", "denoise": 0.40,
         "prompt": "pixel art miner, mid wind up, pickaxe raised to shoulder height, "
                  "arms bent, facing right, game sprite, centered, clean edges, white background"},

        {"name": "windup_full", "denoise": 0.45,
         "prompt": "pixel art miner, full wind up, pickaxe raised high overhead, "
                  "arms extended up, facing right, game sprite, centered, clean edges, white background"},

        {"name": "swing_start", "denoise": 0.45,
         "prompt": "pixel art miner, beginning swing, pickaxe starting to come down, "
                  "dynamic action pose, facing right, game sprite, centered, clean edges, white background"},

        {"name": "swing_mid", "denoise": 0.40,
         "prompt": "pixel art miner, mid swing, pickaxe at chest level swinging down, "
                  "powerful motion, facing right, game sprite, centered, clean edges, white background"},

        {"name": "swing_low", "denoise": 0.35,
         "prompt": "pixel art miner, low swing, pickaxe near ground level, "
                  "arms extended forward, facing right, game sprite, centered, clean edges, white background"},

        {"name": "impact", "denoise": 0.30,
         "prompt": "pixel art miner, impact pose, pickaxe hitting ground, "
                  "slight crouch, follow through, facing right, game sprite, centered, clean edges, white background"},
    ]

    output_paths = []
    base_seed = 12345

    for i, frame_def in enumerate(frames):
        print(f"\nGenerating frame {i+1}/8: {frame_def['name']} (denoise: {frame_def['denoise']})")

        output_path = output_dir / f"frame_{i:02d}_{frame_def['name']}.png"

        workflow = create_img2img_workflow(
            base_image_name=base_name,
            reference_image_name=ref_name,
            prompt=frame_def["prompt"],
            seed=base_seed + i,
            denoise=frame_def["denoise"],
            ipadapter_weight=0.95
        )

        result = queue_and_wait(workflow)
        outputs = result.get("outputs", {})

        if "11" in outputs:
            images = outputs["11"].get("images", [])
            if images:
                img_info = images[0]
                img_data = download_image(
                    img_info["filename"],
                    img_info.get("subfolder", ""),
                    img_info.get("type", "output")
                )
                with open(output_path, 'wb') as f:
                    f.write(img_data)
                output_paths.append(output_path)
                print(f"  Saved: {output_path}")

    return output_paths


def process_and_create_spritesheet(
    frame_paths: list[Path],
    output_path: Path,
    frame_size: tuple[int, int] = (128, 128)
) -> Path:
    """Process frames (remove bg, resize) and create sprite sheet."""
    print("\nProcessing frames...")

    processed_frames = []

    for path in frame_paths:
        print(f"  Processing {path.name}...")

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

    sprite_sheet.save(output_path, "PNG")
    print(f"\nSprite sheet saved: {output_path}")
    print(f"  Size: {sprite_sheet.size}")

    return output_path


def main():
    import argparse

    parser = argparse.ArgumentParser(description="Img2Img animation pipeline")
    parser.add_argument("reference", help="Path to reference character image")
    parser.add_argument("--output", default=None, help="Output directory")

    args = parser.parse_args()

    reference_path = Path(args.reference)
    if not reference_path.exists():
        reference_path = SPRITES_DIR / args.reference
        if not reference_path.exists():
            print(f"Error: Reference not found: {args.reference}")
            sys.exit(1)

    output_dir = Path(args.output) if args.output else OUTPUT_DIR
    output_dir.mkdir(parents=True, exist_ok=True)

    # Check ComfyUI
    try:
        urllib.request.urlopen(f"{COMFYUI_URL}/system_stats")
    except Exception:
        print("Error: ComfyUI is not running!")
        sys.exit(1)

    print("=" * 60)
    print("IMG2IMG ANIMATION PIPELINE")
    print("=" * 60)

    # Step 1: Generate base frame
    base_frame_path = output_dir / "base_frame.png"
    generate_base_frame(reference_path, base_frame_path)

    # Step 2: Generate animation frames using img2img
    frame_paths = generate_animation_frames(
        reference_path, base_frame_path, output_dir
    )

    # Step 3: Process and create sprite sheet
    spritesheet_path = SPRITES_DIR / "miner_swing_img2img.png"
    process_and_create_spritesheet(frame_paths, spritesheet_path)

    print("\n" + "=" * 60)
    print("PIPELINE COMPLETE")
    print("=" * 60)


if __name__ == "__main__":
    main()
