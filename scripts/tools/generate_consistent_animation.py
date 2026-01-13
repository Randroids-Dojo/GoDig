#!/opt/homebrew/bin/python3.11
"""
Consistent Character Animation Generator for GoDig
Uses ComfyUI + IP-Adapter to maintain character consistency across animation frames.

Requirements:
    - ComfyUI running at http://127.0.0.1:8188
    - IP-Adapter Plus custom nodes installed
    - Models: SD 1.5, IP-Adapter Plus, CLIP Vision

Usage:
    # First, start ComfyUI server:
    cd ~/ComfyUI && python3.11 main.py

    # Then run this script:
    python generate_consistent_animation.py reference.png "swing animation" 4
"""

import json
import urllib.request
import urllib.parse
import time
import base64
import sys
from pathlib import Path
from typing import Optional
from PIL import Image
import io

COMFYUI_URL = "http://127.0.0.1:8188"
PROJECT_ROOT = Path(__file__).parent.parent.parent
SPRITES_DIR = PROJECT_ROOT / "resources" / "sprites"


def upload_image(image_path: Path) -> str:
    """Upload an image to ComfyUI and return the filename."""
    with open(image_path, 'rb') as f:
        image_data = f.read()

    # Create multipart form data
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
        headers={
            'Content-Type': f'multipart/form-data; boundary={boundary}'
        },
        method='POST'
    )

    response = json.loads(urllib.request.urlopen(req).read())
    return response.get("name", filename)


def create_ipadapter_workflow(
    reference_image_name: str,
    prompt: str,
    negative_prompt: str = "blurry, realistic, 3d render, photo",
    width: int = 512,
    height: int = 512,
    seed: int = 42,
    ipadapter_weight: float = 0.85
) -> dict:
    """Create a ComfyUI workflow with IP-Adapter for consistent character generation."""

    workflow = {
        # Load checkpoint (outputs: MODEL, CLIP, VAE)
        "1": {
            "class_type": "CheckpointLoaderSimple",
            "inputs": {
                "ckpt_name": "v1-5-pruned-emaonly.safetensors"
            }
        },
        # Load IP-Adapter with unified loader (outputs: MODEL, IPADAPTER)
        "2": {
            "class_type": "IPAdapterUnifiedLoader",
            "inputs": {
                "model": ["1", 0],
                "preset": "PLUS (high strength)"
            }
        },
        # Load reference image (uploaded via API)
        "3": {
            "class_type": "LoadImage",
            "inputs": {
                "image": reference_image_name
            }
        },
        # Apply IP-Adapter with reference image
        "4": {
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
        # Encode positive prompt
        "5": {
            "class_type": "CLIPTextEncode",
            "inputs": {
                "text": f"pixel art {prompt}, game sprite, centered, clean edges",
                "clip": ["1", 1]
            }
        },
        # Encode negative prompt
        "6": {
            "class_type": "CLIPTextEncode",
            "inputs": {
                "text": negative_prompt,
                "clip": ["1", 1]
            }
        },
        # Empty latent
        "7": {
            "class_type": "EmptyLatentImage",
            "inputs": {
                "width": width,
                "height": height,
                "batch_size": 1
            }
        },
        # KSampler - use IP-Adapter conditioned model
        "8": {
            "class_type": "KSampler",
            "inputs": {
                "model": ["4", 0],
                "positive": ["5", 0],
                "negative": ["6", 0],
                "latent_image": ["7", 0],
                "seed": seed,
                "steps": 25,
                "cfg": 7.0,
                "sampler_name": "euler",
                "scheduler": "normal",
                "denoise": 1.0
            }
        },
        # VAE Decode
        "9": {
            "class_type": "VAEDecode",
            "inputs": {
                "samples": ["8", 0],
                "vae": ["1", 2]
            }
        },
        # Save Image
        "10": {
            "class_type": "SaveImage",
            "inputs": {
                "images": ["9", 0],
                "filename_prefix": "consistent_char"
            }
        }
    }

    return workflow


def queue_prompt(workflow: dict, client_id: str = "godig") -> str:
    """Queue a workflow and return the prompt ID."""
    data = json.dumps({
        "prompt": workflow,
        "client_id": client_id
    }).encode('utf-8')

    req = urllib.request.Request(
        f"{COMFYUI_URL}/prompt",
        data=data,
        headers={"Content-Type": "application/json"}
    )

    response = json.loads(urllib.request.urlopen(req).read())
    return response.get("prompt_id")


def get_history(prompt_id: str) -> dict:
    """Get the history for a prompt."""
    url = f"{COMFYUI_URL}/history/{prompt_id}"
    response = urllib.request.urlopen(url)
    return json.loads(response.read())


def wait_for_completion(prompt_id: str, timeout: int = 300) -> dict:
    """Wait for a prompt to complete."""
    start_time = time.time()

    while time.time() - start_time < timeout:
        history = get_history(prompt_id)

        if prompt_id in history:
            return history[prompt_id]

        time.sleep(1)

    raise TimeoutError(f"Prompt {prompt_id} did not complete within {timeout}s")


def download_image(filename: str, subfolder: str = "", folder_type: str = "output") -> bytes:
    """Download an image from ComfyUI."""
    params = urllib.parse.urlencode({
        "filename": filename,
        "subfolder": subfolder,
        "type": folder_type
    })

    url = f"{COMFYUI_URL}/view?{params}"
    response = urllib.request.urlopen(url)
    return response.read()


def generate_consistent_frames(
    reference_image_path: Path,
    frame_descriptions: list[str],
    output_dir: Path,
    base_seed: int = 42,
    ipadapter_weight: float = 0.85
) -> list[Path]:
    """
    Generate multiple animation frames with consistent character appearance.

    Args:
        reference_image_path: Path to the reference character image
        frame_descriptions: List of descriptions for each frame
        output_dir: Directory to save output frames
        base_seed: Base random seed
        ipadapter_weight: IP-Adapter influence (0.7-1.0 recommended)

    Returns:
        List of paths to generated frames
    """
    output_dir.mkdir(parents=True, exist_ok=True)

    # Upload reference image to ComfyUI
    print(f"Uploading reference image: {reference_image_path}")
    reference_name = upload_image(reference_image_path)
    print(f"  Uploaded as: {reference_name}")

    output_paths = []

    for i, description in enumerate(frame_descriptions):
        print(f"\nGenerating frame {i+1}/{len(frame_descriptions)}: {description}")

        # Create workflow
        workflow = create_ipadapter_workflow(
            reference_image_name=reference_name,
            prompt=description,
            seed=base_seed + i,
            ipadapter_weight=ipadapter_weight,
            width=512,
            height=512
        )

        # Queue and wait
        prompt_id = queue_prompt(workflow)
        print(f"  Queued prompt: {prompt_id}")

        result = wait_for_completion(prompt_id)

        # Get output image
        outputs = result.get("outputs", {})
        if "10" in outputs:  # SaveImage node
            images = outputs["10"].get("images", [])
            if images:
                image_info = images[0]
                image_data = download_image(
                    image_info["filename"],
                    image_info.get("subfolder", ""),
                    image_info.get("type", "output")
                )

                # Save locally
                output_path = output_dir / f"frame_{i+1:02d}.png"
                with open(output_path, 'wb') as f:
                    f.write(image_data)

                print(f"  Saved: {output_path}")
                output_paths.append(output_path)

    return output_paths


def main():
    import argparse

    parser = argparse.ArgumentParser(
        description="Generate consistent character animation frames",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    # Generate 4 frames of miner swing animation
    %(prog)s miner_swing.png "miner swinging pickaxe" 4

    # Use existing reference with custom frames
    %(prog)s ref.png --frames "idle pose" "walking" "running" "jumping"
        """
    )
    parser.add_argument("reference", help="Path to reference character image")
    parser.add_argument("action", nargs="?", default="idle", help="Action description")
    parser.add_argument("num_frames", nargs="?", type=int, default=4, help="Number of frames")
    parser.add_argument("--frames", nargs="+", help="Custom frame descriptions")
    parser.add_argument("--output", default=None, help="Output directory")
    parser.add_argument("--weight", type=float, default=0.85, help="IP-Adapter weight (0.7-1.0)")
    parser.add_argument("--seed", type=int, default=42, help="Base random seed")

    args = parser.parse_args()

    reference_path = Path(args.reference)
    if not reference_path.exists():
        # Try in sprites directory
        reference_path = SPRITES_DIR / args.reference
        if not reference_path.exists():
            print(f"Error: Reference image not found: {args.reference}")
            sys.exit(1)

    # Generate frame descriptions
    if args.frames:
        frame_descriptions = args.frames
    else:
        # Auto-generate frame descriptions
        frame_descriptions = [
            f"{args.action}, frame {i+1} of {args.num_frames}"
            for i in range(args.num_frames)
        ]

    output_dir = Path(args.output) if args.output else SPRITES_DIR / "animation"

    try:
        # Check if ComfyUI is running
        urllib.request.urlopen(f"{COMFYUI_URL}/system_stats")
    except Exception:
        print("Error: ComfyUI is not running!")
        print("Start it with: cd ~/ComfyUI && /opt/homebrew/bin/python3.11 main.py")
        sys.exit(1)

    # Generate frames
    output_paths = generate_consistent_frames(
        reference_image_path=reference_path,
        frame_descriptions=frame_descriptions,
        output_dir=output_dir,
        base_seed=args.seed,
        ipadapter_weight=args.weight
    )

    print(f"\n✅ Generated {len(output_paths)} frames in {output_dir}")


if __name__ == "__main__":
    main()
