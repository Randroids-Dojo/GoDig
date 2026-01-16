#!/opt/homebrew/bin/python3.11
"""
Sprite Generation Tool for GoDig
Generates 2D game sprites using MFLUX Z-Image-Turbo and processes them for Godot.

Requirements:
    pip install mflux rembg pillow onnxruntime

Usage:
    python generate_sprite.py miner_swing "miner character swinging a pickaxe" --seed 42
"""

import subprocess
import sys
from pathlib import Path
from PIL import Image
import argparse
import tempfile
from typing import Optional, Tuple

# Paths
MFLUX_BIN = Path("/opt/homebrew/bin/mflux-generate-z-image-turbo")
PROJECT_ROOT = Path(__file__).parent.parent.parent
SPRITES_DIR = PROJECT_ROOT / "resources" / "sprites"


def generate_image(prompt: str, output_path: Path, width: int = 256, height: int = 256,
                   steps: int = 9, seed: Optional[int] = None) -> Path:
    """Generate an image using MFLUX Z-Image-Turbo (no auth required)."""
    cmd = [
        str(MFLUX_BIN),
        "--prompt", prompt,
        "--steps", str(steps),
        "--width", str(width),
        "--height", str(height),
        "--output", str(output_path),
        "--quantize", "4",  # Lower memory usage (6GB vs 24GB)
    ]

    if seed is not None:
        cmd.extend(["--seed", str(seed)])

    print(f"Generating: {prompt[:60]}...")
    result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode != 0:
        print(f"Error: {result.stderr}")
        raise RuntimeError(f"MFLUX failed: {result.stderr}")

    print(f"Generated: {output_path}")
    return output_path


def remove_background(input_path: Path, output_path: Path) -> Path:
    """Remove background from image using rembg (Python library)."""
    from rembg import remove

    print("Removing background...")

    with open(input_path, 'rb') as f:
        input_data = f.read()

    output_data = remove(input_data)

    with open(output_path, 'wb') as f:
        f.write(output_data)

    print(f"Background removed: {output_path}")
    return output_path


def resize_sprite(input_path: Path, output_path: Path, size: Tuple[int, int]) -> Path:
    """Resize sprite using nearest-neighbor interpolation (pixel art friendly)."""
    image = Image.open(input_path)
    resized = image.resize(size, Image.Resampling.NEAREST)
    resized.save(output_path, "PNG")
    print(f"Resized to {size}: {output_path}")
    return output_path


def generate_sprite(
    name: str,
    description: str,
    style: str = "pixel art",
    size: Tuple[int, int] = (128, 128),
    remove_bg: bool = True,
    seed: Optional[int] = None,
) -> Path:
    """
    Generate a complete game sprite.

    Args:
        name: Output filename (without extension)
        description: What the sprite should depict
        style: Art style (default: "pixel art")
        size: Final sprite dimensions
        remove_bg: Whether to remove background
        seed: Random seed for reproducibility

    Returns:
        Path to the generated sprite
    """
    # Ensure output directory exists
    SPRITES_DIR.mkdir(parents=True, exist_ok=True)

    # Build the prompt
    prompt = f"{style} {description}, game sprite, centered, clean edges"

    # Generate at larger size for better quality, then resize
    gen_width = max(size[0] * 2, 256)
    gen_height = max(size[1] * 2, 256)

    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)

        # Step 1: Generate raw image
        raw_path = tmp_path / f"{name}_raw.png"
        generate_image(prompt, raw_path, gen_width, gen_height, seed=seed)

        # Step 2: Remove background if requested
        if remove_bg:
            nobg_path = tmp_path / f"{name}_nobg.png"
            remove_background(raw_path, nobg_path)
            current_path = nobg_path
        else:
            current_path = raw_path

        # Step 3: Resize to final dimensions
        final_path = SPRITES_DIR / f"{name}.png"
        resize_sprite(current_path, final_path, size)

    return final_path


def main():
    parser = argparse.ArgumentParser(
        description="Generate game sprites for GoDig",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    %(prog)s miner "miner character swinging pickaxe" --seed 42
    %(prog)s sword "medieval sword weapon" --width 64 --height 64
    %(prog)s background "underground cave scene" --no-remove-bg --width 720 --height 1280
        """
    )
    parser.add_argument("name", help="Output filename (without extension)")
    parser.add_argument("description", help="Description of the sprite")
    parser.add_argument("--style", default="pixel art", help="Art style (default: pixel art)")
    parser.add_argument("--width", type=int, default=128, help="Sprite width (default: 128)")
    parser.add_argument("--height", type=int, default=128, help="Sprite height (default: 128)")
    parser.add_argument("--no-remove-bg", action="store_true", help="Skip background removal")
    parser.add_argument("--seed", type=int, help="Random seed for reproducibility")

    args = parser.parse_args()

    try:
        result = generate_sprite(
            name=args.name,
            description=args.description,
            style=args.style,
            size=(args.width, args.height),
            remove_bg=not args.no_remove_bg,
            seed=args.seed,
        )
        print(f"\nSprite saved to: {result}")
    except Exception as e:
        print(f"Error generating sprite: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
