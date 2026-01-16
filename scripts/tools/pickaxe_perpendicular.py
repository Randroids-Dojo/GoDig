#!/opt/homebrew/bin/python3.11
"""
Perpendicular Pickaxe Design - Iteration 3

Key insight: A REAL pickaxe has the head PERPENDICULAR to the handle.
The head should extend significantly above AND below the handle line.

This is more important than validator scores - it needs to LOOK like a pickaxe.
"""

from PIL import Image, ImageDraw
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent.parent
COMPONENTS_DIR = PROJECT_ROOT / "resources" / "sprites" / "components"

# Same colors as primer for fair comparison
COLORS = {
    "wood_hi": (180, 120, 60),
    "wood": (139, 90, 43),
    "wood_lo": (100, 60, 25),

    "metal_hi": (200, 200, 210),
    "metal": (130, 130, 145),
    "metal_lo": (60, 60, 70),

    "gleam": (255, 255, 255),
    "transparent": (0, 0, 0, 0),
}


def create_perpendicular_pickaxe() -> Image.Image:
    """
    Create compact perpendicular pickaxe - T-shape that fits in frame.

    Shortened design to prevent clipping when arm rotates.
    Total width: 36 pixels (24 handle + 12 head)
    """
    img = Image.new('RGBA', (36, 24), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # === WOODEN HANDLE ===
    handle_length = 24
    handle_top = 9
    handle_bottom = 14

    # Main handle with 3-tone shading
    draw.rectangle([0, handle_top, handle_length, handle_bottom], fill=COLORS["wood"])
    draw.rectangle([0, handle_top, handle_length, handle_top + 1], fill=COLORS["wood_hi"])
    draw.rectangle([0, handle_bottom - 1, handle_length, handle_bottom], fill=COLORS["wood_lo"])

    # Handle grip end
    draw.rectangle([0, handle_top - 1, 3, handle_bottom + 1], fill=COLORS["wood_lo"])
    draw.rectangle([1, handle_top, 2, handle_bottom], fill=COLORS["wood"])

    # Wood grain lines
    for x in range(5, handle_length - 2, 4):
        draw.line([(x, handle_top + 1), (x, handle_bottom - 1)], fill=COLORS["wood_lo"])

    # === PERPENDICULAR METAL HEAD (T-shape) ===
    head_x = handle_length - 2  # = 22
    head_width = 4
    head_top = 2
    head_bottom = 21

    # Vertical bar of the T
    draw.rectangle([head_x, head_top, head_x + head_width, head_bottom], fill=COLORS["metal"])
    draw.rectangle([head_x, head_top, head_x + 1, head_bottom], fill=COLORS["metal_lo"])
    draw.rectangle([head_x + head_width - 1, head_top, head_x + head_width, head_bottom], fill=COLORS["metal_hi"])

    # Top pointed tip
    top_center = head_x + head_width // 2
    draw.polygon([
        (head_x + 1, head_top),
        (top_center, 0),
        (head_x + head_width - 1, head_top)
    ], fill=COLORS["metal_lo"])
    img.putpixel((top_center, 0), COLORS["gleam"])

    # Bottom pointed tip
    draw.polygon([
        (head_x + 1, head_bottom),
        (top_center, 23),
        (head_x + head_width - 1, head_bottom)
    ], fill=COLORS["metal_lo"])

    # === SHORT HORIZONTAL SPIKE (the pick point) ===
    handle_center = (handle_top + handle_bottom) // 2  # = 11
    spike_length = 8  # Short spike to fit in frame
    for dx in range(head_width, spike_length):
        x = head_x + dx
        if x >= img.width:
            break
        thickness = max(1, 2 - dx // 3)
        for dy in range(-thickness, thickness + 1):
            y = handle_center + dy
            if 0 <= y < img.height:
                if dy <= 0:
                    img.putpixel((x, y), COLORS["metal_hi"])
                else:
                    img.putpixel((x, y), COLORS["metal_lo"])

    # Sharp gleam at spike tip
    if head_x + spike_length - 1 < img.width:
        img.putpixel((head_x + spike_length - 1, handle_center), COLORS["gleam"])

    # === COLLAR (where head meets handle) ===
    draw.rectangle([head_x - 2, handle_center - 3, head_x, handle_center + 3], fill=COLORS["metal_lo"])

    return img


def main():
    print("Creating perpendicular pickaxe...")
    pickaxe = create_perpendicular_pickaxe()
    pickaxe.save(COMPONENTS_DIR / "pickaxe.png")
    print(f"Saved: pickaxe.png ({pickaxe.size})")

    import sys
    sys.path.insert(0, 'scripts/tools')
    from component_validator import validate_component
    from pickaxe_validator import validate_pickaxe

    print("\nScores:")
    comp = validate_component(COMPONENTS_DIR / "pickaxe.png")
    pick = validate_pickaxe()
    print(f"  Component: {comp.overall:.2f}")
    print(f"  Pickaxe: {pick.overall:.2f}")
    print(f"    Silhouette: {pick.silhouette_clarity:.2f}")
    print(f"    Vertical: {pick.vertical_extent:.2f}")


if __name__ == "__main__":
    main()
