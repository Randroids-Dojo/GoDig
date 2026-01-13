#!/opt/homebrew/bin/python3.11
"""
Debug the handle/head ratio detection to understand why primer scores 0.20.
"""

from PIL import Image
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent.parent
COMPONENTS_DIR = PROJECT_ROOT / "resources" / "sprites" / "components"


def debug_proportions(img_path: Path):
    """Debug version of analyze_proportions with verbose output."""
    img = Image.open(img_path).convert('RGBA')
    width, height = img.size
    pixels = img.load()

    print(f"Image size: {width}x{height}")

    # Find horizontal extent
    min_x, max_x = width, 0
    for y in range(height):
        for x in range(width):
            if pixels[x, y][3] > 128:
                min_x = min(min_x, x)
                max_x = max(max_x, x)

    print(f"Horizontal extent: x={min_x} to x={max_x}")

    total_length = max_x - min_x
    print(f"Total length: {total_length}")

    # Scan from right to find where head ends
    center_y = height // 2
    print(f"Center Y: {center_y}")

    head_start = max_x
    for x in range(max_x, min_x, -1):
        # Check if this column has significant vertical extent
        col_pixels = sum(1 for y in range(height) if pixels[x, y][3] > 128)
        if col_pixels < 3:  # Transition to handle
            head_start = x
            print(f"  x={x}: {col_pixels} pixels (HEAD ENDS)")
            break
        else:
            if x > max_x - 5 or x < min_x + 5 or x % 5 == 0:
                print(f"  x={x}: {col_pixels} pixels")

    head_length = max_x - head_start
    print(f"\nHead detected: x={head_start} to x={max_x}")
    print(f"Head length: {head_length}")

    ratio = head_length / total_length if total_length > 0 else 0
    print(f"\nRatio: {ratio:.3f}")
    print(f"Ideal range: 0.25-0.40 (scores 1.0)")
    print(f"Acceptable range: 0.15-0.55 (scores 0.7)")

    if 0.25 <= ratio <= 0.45:
        score = 1.0
    elif 0.15 <= ratio <= 0.55:
        score = 0.7
    elif ratio > 0:
        score = 0.4
    else:
        score = 0.2

    print(f"\nFinal ratio score: {score}")
    return ratio, score


def main():
    print("="*60)
    print("DEBUGGING PRIMER RATIO DETECTION")
    print("="*60)
    debug_proportions(COMPONENTS_DIR / "pickaxe.png")


if __name__ == "__main__":
    main()
