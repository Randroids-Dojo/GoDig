#!/opt/homebrew/bin/python3.11
"""
Iconic Pickaxe Design - Iteration 2

Based on pixel art principles:
1. Clear silhouette is key
2. Each pixel matters at small sizes
3. Low color count for coherence

Classic pickaxe characteristics:
- Horizontal handle
- Head perpendicular to handle (T-shape)
- One or two pointed ends
- Clear wood vs metal separation
"""

from PIL import Image, ImageDraw
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent.parent
COMPONENTS_DIR = PROJECT_ROOT / "resources" / "sprites" / "components"

# Minimal palette - only 5 colors
COLORS = {
    "wood_light": (170, 115, 55),
    "wood_dark": (110, 70, 30),
    "metal_light": (180, 180, 195),
    "metal_dark": (80, 80, 95),
    "white": (255, 255, 255),
    "transparent": (0, 0, 0, 0),
}


def create_iconic_pickaxe() -> Image.Image:
    """
    Create a clear, iconic pickaxe with unmistakable T-shape.

    Design: Classic mining pick with dual points
    - Handle runs left to right
    - Head is a vertical bar with pointed top and bottom
    """
    img = Image.new('RGBA', (52, 24), COLORS["transparent"])

    # Work pixel by pixel for maximum control
    pixels = img.load()

    center_y = 11  # Vertical center

    # === WOODEN HANDLE ===
    # Draw handle from x=0 to x=33
    for x in range(0, 34):
        # Handle is 4 pixels tall, centered
        for y in range(center_y - 1, center_y + 3):
            if y == center_y - 1 or y == center_y:
                pixels[x, y] = COLORS["wood_light"]
            else:
                pixels[x, y] = COLORS["wood_dark"]

    # Handle end cap (darker)
    for y in range(center_y - 2, center_y + 4):
        if center_y - 2 <= y <= center_y + 3:
            pixels[0, y] = COLORS["wood_dark"]
            pixels[1, y] = COLORS["wood_dark"]

    # === METAL HEAD - Clear T-shape ===
    head_x = 32  # Where head starts

    # Vertical bar of the T (extends from top to bottom)
    for y in range(2, 22):
        for x in range(head_x, head_x + 6):
            if x < head_x + 2:
                pixels[x, y] = COLORS["metal_dark"]
            elif x > head_x + 3:
                pixels[x, y] = COLORS["metal_light"]
            else:
                pixels[x, y] = COLORS["metal_light"] if y < 12 else COLORS["metal_dark"]

    # Top point
    for dy, width in enumerate([4, 3, 2, 1]):
        y = 1 - dy
        if y >= 0:
            start_x = head_x + 1 + (4 - width) // 2
            for x in range(start_x, start_x + width):
                if x < img.width:
                    pixels[x, y] = COLORS["metal_light"] if dy < 2 else COLORS["metal_dark"]

    # Top spike tip
    pixels[head_x + 3, 0] = COLORS["white"]

    # Bottom point
    for dy, width in enumerate([4, 3, 2, 1]):
        y = 22 + dy
        if y < 24:
            start_x = head_x + 1 + (4 - width) // 2
            for x in range(start_x, start_x + width):
                if x < img.width:
                    pixels[x, y] = COLORS["metal_dark"]

    # === HORIZONTAL PICK POINT (extends right) ===
    # Main point extending from center of head
    for x in range(head_x + 5, 52):
        thickness = max(1, 4 - (x - head_x - 5) // 4)
        for dy in range(-thickness, thickness + 1):
            y = center_y + dy
            if 0 <= y < 24:
                if dy < 0:
                    pixels[x, y] = COLORS["metal_light"]
                else:
                    pixels[x, y] = COLORS["metal_dark"]

    # Sharp tip
    pixels[51, center_y] = COLORS["white"]
    pixels[50, center_y] = COLORS["metal_light"]

    # === COLLAR where handle meets head ===
    for y in range(center_y - 2, center_y + 4):
        pixels[head_x - 1, y] = COLORS["metal_dark"]
        pixels[head_x, y] = COLORS["metal_dark"]

    return img


def main():
    print("Creating iconic pickaxe design...")
    pickaxe = create_iconic_pickaxe()
    pickaxe.save(COMPONENTS_DIR / "pickaxe.png")
    print(f"Saved: pickaxe.png ({pickaxe.size})")

    import sys
    sys.path.insert(0, 'scripts/tools')
    from component_validator import validate_component
    from pickaxe_validator import validate_pickaxe

    print("\nComponent Validator:")
    comp_score = validate_component(COMPONENTS_DIR / "pickaxe.png")
    print(f"  Overall: {comp_score.overall:.2f}")
    print(f"  Colors: {comp_score.color_count}")

    print("\nPickaxe Validator:")
    pick_score = validate_pickaxe()
    print(f"  Overall: {pick_score.overall:.2f}")
    print(f"  Silhouette: {pick_score.silhouette_clarity:.2f}")
    print(f"  Vertical: {pick_score.vertical_extent:.2f}")


if __name__ == "__main__":
    main()
