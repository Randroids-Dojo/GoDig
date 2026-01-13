#!/opt/homebrew/bin/python3.11
"""Debug silhouette calculation."""

from PIL import Image
from pathlib import Path
import sys

PROJECT_ROOT = Path(__file__).parent.parent.parent
COMPONENTS_DIR = PROJECT_ROOT / "resources" / "sprites" / "components"

sys.path.insert(0, str(Path(__file__).parent))
from pickaxe_perpendicular import create_perpendicular_pickaxe
from improved_sprite_builder import create_pickaxe_component as create_primer


def debug_silhouette(name, img):
    """Debug silhouette for an image."""
    if img.mode != 'RGBA':
        img = img.convert('RGBA')

    width, height = img.size
    pixels = img.load()

    # Find bounding box
    min_x, max_x = width, 0
    min_y, max_y = height, 0

    for y in range(height):
        for x in range(width):
            if pixels[x, y][3] > 128:
                min_x = min(min_x, x)
                max_x = max(max_x, x)
                min_y = min(min_y, y)
                max_y = max(max_y, y)

    actual_width = max_x - min_x
    actual_height = max_y - min_y

    # Check right third for vertical extent (head area)
    head_start_x = min_x + int(actual_width * 0.6)

    head_min_y, head_max_y = height, 0
    for y in range(height):
        for x in range(head_start_x, max_x + 1):
            if x < width and pixels[x, y][3] > 128:
                head_min_y = min(head_min_y, y)
                head_max_y = max(head_max_y, y)

    head_height = head_max_y - head_min_y

    # Check left portion for handle
    handle_end_x = min_x + int(actual_width * 0.5)

    handle_heights = []
    for x in range(min_x, handle_end_x):
        col_min_y, col_max_y = height, 0
        for y in range(height):
            if pixels[x, y][3] > 128:
                col_min_y = min(col_min_y, y)
                col_max_y = max(col_max_y, y)
        if col_max_y > col_min_y:
            handle_heights.append(col_max_y - col_min_y)

    avg_handle_height = sum(handle_heights) / len(handle_heights) if handle_heights else 0

    # Calculate score
    if avg_handle_height > 0 and head_height > 0:
        height_ratio = head_height / avg_handle_height
        if height_ratio >= 2.0:
            silhouette_score = min(1.0, height_ratio / 3.0)
        else:
            silhouette_score = height_ratio / 2.0
    else:
        silhouette_score = 0.3

    print(f"\n{name}:")
    print(f"  Bounding box: ({min_x},{min_y}) to ({max_x},{max_y})")
    print(f"  Actual size: {actual_width}x{actual_height}")
    print(f"  Head start X: {head_start_x}")
    print(f"  Head height: {head_height} (y={head_min_y} to y={head_max_y})")
    print(f"  Avg handle height: {avg_handle_height:.1f}")
    print(f"  Height ratio: {head_height / avg_handle_height if avg_handle_height > 0 else 0:.2f}")
    print(f"  Silhouette score: {silhouette_score:.3f}")


def main():
    print("="*60)
    print("DEBUGGING SILHOUETTE")
    print("="*60)

    primer = create_primer()
    perp = create_perpendicular_pickaxe()

    debug_silhouette("Primer", primer)
    debug_silhouette("Perpendicular", perp)


if __name__ == "__main__":
    main()
