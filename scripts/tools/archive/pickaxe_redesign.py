#!/opt/homebrew/bin/python3.11
"""
Pickaxe Redesign - Focus on Classic Mining Pickaxe Shape

A mining pickaxe should have:
- Long wooden handle (2/3 of total length)
- Metal head in T-shape with one pointed end
- Clear distinction between handle and head
- The head should extend above AND below the handle line
"""

from PIL import Image, ImageDraw
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent.parent
COMPONENTS_DIR = PROJECT_ROOT / "resources" / "sprites" / "components"

# Strict limited palette
COLORS = {
    # Wood handle (warm browns)
    "wood_hi": (180, 120, 60),
    "wood": (140, 90, 45),
    "wood_lo": (100, 60, 28),

    # Metal head (cool grays)
    "metal_hi": (200, 200, 215),
    "metal": (130, 130, 145),
    "metal_lo": (70, 70, 85),

    # Gleam
    "gleam": (255, 255, 255),

    "transparent": (0, 0, 0, 0),
}


def create_classic_pickaxe() -> Image.Image:
    """
    Create a classic mining pickaxe with clear T-shape.

    Layout (52x24 canvas):
    - Handle: x=0 to x=34 (center of canvas vertically)
    - Head: x=30 to x=52, extends from y=2 to y=22 (full T-shape)
    """
    img = Image.new('RGBA', (52, 24), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    center_y = 12  # Vertical center of canvas

    # === WOODEN HANDLE ===
    # Main handle body - horizontal bar
    handle_top = center_y - 3
    handle_bottom = center_y + 3

    # 3-tone shading
    draw.rectangle([0, handle_top, 34, handle_bottom], fill=COLORS["wood"])
    draw.rectangle([0, handle_top, 34, handle_top + 2], fill=COLORS["wood_hi"])
    draw.rectangle([0, handle_bottom - 2, 34, handle_bottom], fill=COLORS["wood_lo"])

    # Handle end cap (left side)
    draw.rectangle([0, handle_top - 1, 4, handle_bottom + 1], fill=COLORS["wood_lo"])
    draw.rectangle([1, handle_top, 3, handle_bottom], fill=COLORS["wood"])

    # Wood grain texture
    for x in range(8, 32, 6):
        draw.line([(x, handle_top + 1), (x, handle_bottom - 1)], fill=COLORS["wood_lo"])

    # === METAL HEAD - Classic T-shape ===
    head_left = 30
    head_right = 52

    # Main vertical bar of head (the T crossbar)
    # Extends from top to bottom of canvas
    draw.rectangle([head_left, 2, head_left + 8, 22], fill=COLORS["metal"])

    # Left side shadow
    draw.rectangle([head_left, 2, head_left + 2, 22], fill=COLORS["metal_lo"])

    # Right side highlight
    draw.rectangle([head_left + 6, 2, head_left + 8, 22], fill=COLORS["metal_hi"])

    # === POINTED TIP (extends right from the T) ===
    # Main point shape
    tip_points = [
        (head_left + 6, center_y - 4),   # Top of tip base
        (head_right, center_y),           # Sharp point
        (head_left + 6, center_y + 4),   # Bottom of tip base
    ]
    draw.polygon(tip_points, fill=COLORS["metal"])

    # Tip highlight (top edge)
    draw.line([
        (head_left + 8, center_y - 3),
        (head_right - 2, center_y)
    ], fill=COLORS["metal_hi"])

    # Tip shadow (bottom edge)
    draw.line([
        (head_left + 8, center_y + 3),
        (head_right - 2, center_y)
    ], fill=COLORS["metal_lo"])

    # Sharp edge gleam
    draw.point((head_right - 1, center_y), fill=COLORS["gleam"])
    draw.point((head_right - 2, center_y), fill=COLORS["metal_hi"])

    # === TOP SPIKE of the T ===
    top_spike_points = [
        (head_left + 2, 2),      # Left base
        (head_left + 4, 0),      # Top point
        (head_left + 6, 2),      # Right base
    ]
    draw.polygon(top_spike_points, fill=COLORS["metal"])
    draw.point((head_left + 4, 1), fill=COLORS["metal_hi"])

    # === BOTTOM SPIKE of the T ===
    bottom_spike_points = [
        (head_left + 2, 22),     # Left base
        (head_left + 4, 24),     # Bottom point
        (head_left + 6, 22),     # Right base
    ]
    draw.polygon(bottom_spike_points, fill=COLORS["metal_lo"])

    # === COLLAR (where head meets handle) ===
    collar_y_top = center_y - 4
    collar_y_bottom = center_y + 4
    draw.rectangle([head_left - 2, collar_y_top, head_left + 2, collar_y_bottom], fill=COLORS["metal_lo"])
    draw.rectangle([head_left - 1, collar_y_top + 1, head_left + 1, collar_y_bottom - 1], fill=COLORS["metal"])

    return img


def main():
    print("Creating classic pickaxe design...")
    pickaxe = create_classic_pickaxe()
    pickaxe.save(COMPONENTS_DIR / "pickaxe.png")
    print(f"Saved: pickaxe.png ({pickaxe.size})")

    # Validate
    from pickaxe_validator import validate_pickaxe
    score = validate_pickaxe()
    print(f"\n{score}")


if __name__ == "__main__":
    main()
