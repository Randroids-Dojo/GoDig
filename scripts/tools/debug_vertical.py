#!/opt/homebrew/bin/python3.11
"""Debug vertical extent calculation for perpendicular design."""

from PIL import Image
from pathlib import Path
import sys

PROJECT_ROOT = Path(__file__).parent.parent.parent
COMPONENTS_DIR = PROJECT_ROOT / "resources" / "sprites" / "components"

sys.path.insert(0, str(Path(__file__).parent))
from pickaxe_perpendicular import create_perpendicular_pickaxe
from improved_sprite_builder import create_pickaxe_component as create_primer


def debug_vertical(name, img):
    """Debug vertical extent for an image."""
    if img.mode != 'RGBA':
        img = img.convert('RGBA')

    width, height = img.size
    pixels = img.load()

    # Find handle center (left half)
    left_half_y = []
    for y in range(height):
        for x in range(width // 2):
            if pixels[x, y][3] > 128:
                left_half_y.append(y)

    handle_center = sum(left_half_y) / len(left_half_y) if left_half_y else height / 2

    # Find head extent (right third)
    head_start_x = int(width * 0.6)
    head_min_y, head_max_y = height, 0

    for y in range(height):
        for x in range(head_start_x, width):
            if pixels[x, y][3] > 128:
                head_min_y = min(head_min_y, y)
                head_max_y = max(head_max_y, y)

    extends_above = handle_center - head_min_y
    extends_below = head_max_y - handle_center

    balance = min(extends_above, extends_below) / max(extends_above, extends_below)
    score = 0.5 + (balance * 0.5)

    print(f"\n{name}:")
    print(f"  Image size: {width}x{height}")
    print(f"  Handle center Y: {handle_center:.1f}")
    print(f"  Head min Y: {head_min_y}")
    print(f"  Head max Y: {head_max_y}")
    print(f"  Extends above: {extends_above:.1f}")
    print(f"  Extends below: {extends_below:.1f}")
    print(f"  Balance: {balance:.3f}")
    print(f"  Vertical score: {score:.3f}")

    return score


def main():
    print("="*60)
    print("DEBUGGING VERTICAL EXTENT")
    print("="*60)

    primer = create_primer()
    perp = create_perpendicular_pickaxe()

    debug_vertical("Primer", primer)
    debug_vertical("Perpendicular", perp)


if __name__ == "__main__":
    main()
