#!/opt/homebrew/bin/python3.11
"""
Pickaxe-Specific Validator

Validates pickaxe components for:
- Recognizable T-shape silhouette
- Clear distinction between handle and head
- Proper proportions (head should be ~1/3 of total length)
- Metal vs wood color separation
"""

from PIL import Image
from pathlib import Path
from dataclasses import dataclass
import math

PROJECT_ROOT = Path(__file__).parent.parent.parent
COMPONENTS_DIR = PROJECT_ROOT / "resources" / "sprites" / "components"


@dataclass
class PickaxeScore:
    """Quality scores for pickaxe."""
    silhouette_clarity: float  # 0-1: how clear is the T-shape
    handle_head_ratio: float   # 0-1: is head ~1/3 of total length
    color_separation: float    # 0-1: distinct wood vs metal colors
    vertical_extent: float     # 0-1: does head extend above and below handle
    overall: float

    def __str__(self):
        return (
            f"Pickaxe Score:\n"
            f"  Silhouette Clarity: {self.silhouette_clarity:.2f}\n"
            f"  Handle/Head Ratio: {self.handle_head_ratio:.2f}\n"
            f"  Color Separation: {self.color_separation:.2f}\n"
            f"  Vertical Extent: {self.vertical_extent:.2f}\n"
            f"  OVERALL: {self.overall:.2f}"
        )


def analyze_silhouette(img: Image.Image) -> float:
    """
    Analyze if the pickaxe has a clear T-shape silhouette.

    A good pickaxe should have:
    - Horizontal handle section (narrow vertically)
    - Vertical head section at one end (extends above and below handle)
    """
    if img.mode != 'RGBA':
        img = img.convert('RGBA')

    width, height = img.size
    pixels = img.load()

    # Find bounding box of opaque pixels
    min_x, max_x = width, 0
    min_y, max_y = height, 0

    for y in range(height):
        for x in range(width):
            if pixels[x, y][3] > 128:
                min_x = min(min_x, x)
                max_x = max(max_x, x)
                min_y = min(min_y, y)
                max_y = max(max_y, y)

    if max_x <= min_x or max_y <= min_y:
        return 0.0

    actual_width = max_x - min_x
    actual_height = max_y - min_y

    # For a pickaxe, width should be > height (horizontal orientation)
    # And there should be vertical extent at the right side (head)

    # Check right third for vertical extent (the head area)
    head_start_x = min_x + int(actual_width * 0.6)

    head_min_y, head_max_y = height, 0
    for y in range(height):
        for x in range(head_start_x, max_x + 1):
            if x < width and pixels[x, y][3] > 128:
                head_min_y = min(head_min_y, y)
                head_max_y = max(head_max_y, y)

    head_height = head_max_y - head_min_y if head_max_y > head_min_y else 0

    # Check left portion for handle (should be narrower)
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

    # Good T-shape: head should be significantly taller than handle
    if avg_handle_height > 0 and head_height > 0:
        height_ratio = head_height / avg_handle_height
        # Ideal: head is 2-4x taller than handle
        if height_ratio >= 2.0:
            silhouette_score = min(1.0, height_ratio / 3.0)
        else:
            silhouette_score = height_ratio / 2.0
    else:
        silhouette_score = 0.3

    return silhouette_score


def analyze_proportions(img: Image.Image) -> float:
    """Check if head is approximately 1/3 of total length."""
    if img.mode != 'RGBA':
        img = img.convert('RGBA')

    width, height = img.size
    pixels = img.load()

    # Find horizontal extent
    min_x, max_x = width, 0
    for y in range(height):
        for x in range(width):
            if pixels[x, y][3] > 128:
                min_x = min(min_x, x)
                max_x = max(max_x, x)

    if max_x <= min_x:
        return 0.0

    total_length = max_x - min_x

    # Find where the "head" starts (where vertical extent increases)
    center_y = height // 2

    # Scan from right to find where head ends
    head_start = max_x
    for x in range(max_x, min_x, -1):
        # Check if this column has significant vertical extent
        col_pixels = sum(1 for y in range(height) if pixels[x, y][3] > 128)
        if col_pixels < 3:  # Transition to handle
            head_start = x
            break

    head_length = max_x - head_start

    # Ideal ratio: head is 25-40% of total length
    ratio = head_length / total_length if total_length > 0 else 0

    if 0.25 <= ratio <= 0.45:
        return 1.0
    elif 0.15 <= ratio <= 0.55:
        return 0.7
    elif ratio > 0:
        return 0.4
    else:
        return 0.2


def analyze_color_separation(img: Image.Image) -> float:
    """Check if wood and metal colors are clearly distinct."""
    if img.mode != 'RGBA':
        img = img.convert('RGBA')

    pixels = list(img.getdata())
    opaque_colors = []

    for p in pixels:
        if p[3] > 128:
            opaque_colors.append((p[0], p[1], p[2]))

    if len(opaque_colors) < 10:
        return 0.5

    # Group colors by hue/saturation to identify wood (warm/brown) vs metal (cool/gray)
    warm_count = 0  # Brown/wood colors
    cool_count = 0  # Gray/metal colors

    for r, g, b in opaque_colors:
        # Simple heuristic: wood is warmer (more red/yellow), metal is cooler (more gray)
        warmth = (r - b) + (g - b) * 0.5

        if warmth > 20:
            warm_count += 1
        elif warmth < -10 or (abs(r - g) < 20 and abs(g - b) < 20):
            cool_count += 1

    total = warm_count + cool_count
    if total == 0:
        return 0.3

    # Good separation: both wood and metal are present in reasonable amounts
    warm_ratio = warm_count / len(opaque_colors)
    cool_ratio = cool_count / len(opaque_colors)

    # Ideal: ~60% wood (handle), ~40% metal (head)
    if 0.3 <= warm_ratio <= 0.7 and 0.2 <= cool_ratio <= 0.5:
        return 1.0
    elif warm_ratio > 0.1 and cool_ratio > 0.1:
        return 0.7
    else:
        return 0.4


def analyze_vertical_extent(img: Image.Image) -> float:
    """Check if head extends above and below the handle centerline."""
    if img.mode != 'RGBA':
        img = img.convert('RGBA')

    width, height = img.size
    pixels = img.load()

    # Find the handle's vertical center (left half of image)
    left_half_y_coords = []
    for y in range(height):
        for x in range(width // 2):
            if pixels[x, y][3] > 128:
                left_half_y_coords.append(y)

    if not left_half_y_coords:
        return 0.3

    handle_center_y = sum(left_half_y_coords) / len(left_half_y_coords)

    # Find head's vertical extent (right third)
    head_start_x = int(width * 0.6)
    head_min_y, head_max_y = height, 0

    for y in range(height):
        for x in range(head_start_x, width):
            if pixels[x, y][3] > 128:
                head_min_y = min(head_min_y, y)
                head_max_y = max(head_max_y, y)

    if head_max_y <= head_min_y:
        return 0.3

    # Check if head extends both above and below handle center
    extends_above = handle_center_y - head_min_y
    extends_below = head_max_y - handle_center_y

    # Good pickaxe: head extends roughly equally above and below
    if extends_above > 2 and extends_below > 2:
        balance = min(extends_above, extends_below) / max(extends_above, extends_below)
        return 0.5 + (balance * 0.5)
    elif extends_above > 0 or extends_below > 0:
        return 0.4
    else:
        return 0.2


def validate_pickaxe(img_path: Path = None) -> PickaxeScore:
    """Validate pickaxe component."""
    if img_path is None:
        img_path = COMPONENTS_DIR / "pickaxe.png"

    img = Image.open(img_path)

    silhouette = analyze_silhouette(img)
    proportions = analyze_proportions(img)
    colors = analyze_color_separation(img)
    vertical = analyze_vertical_extent(img)

    # Weight vertical extent MOST heavily - perpendicular head is key to pickaxe look
    # A pickaxe's defining feature is the vertical head perpendicular to handle
    overall = (
        silhouette * 0.20 +
        proportions * 0.10 +
        colors * 0.20 +
        vertical * 0.50  # Increased - this is what makes it look like a pickaxe
    )

    return PickaxeScore(
        silhouette_clarity=silhouette,
        handle_head_ratio=proportions,
        color_separation=colors,
        vertical_extent=vertical,
        overall=overall
    )


def main():
    score = validate_pickaxe()
    print(score)


if __name__ == "__main__":
    main()
