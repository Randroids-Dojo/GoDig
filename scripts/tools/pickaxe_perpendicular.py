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
    Create pickaxe with properly perpendicular head.

    The head will be a vertical bar that extends well above
    and below the horizontal handle line.
    """
    # Canvas size matched to primer (52x24)
    img = Image.new('RGBA', (52, 24), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # Handle center positioned for perfect vertical balance
    # Handle from y=8 to y=13 gives center at y=10.5
    # Head from y=0 to y=21 gives extends_above = extends_below = 10.5
    # Thinner handle (5px) improves silhouette ratio: 21/5 = 4.2 > 3.0

    # === WOODEN HANDLE ===
    handle_length = 34
    handle_top = 8
    handle_bottom = 13

    # Main handle with 3-tone shading
    draw.rectangle([0, handle_top, handle_length, handle_bottom], fill=COLORS["wood"])
    draw.rectangle([0, handle_top, handle_length, handle_top + 1], fill=COLORS["wood_hi"])
    draw.rectangle([0, handle_bottom - 1, handle_length, handle_bottom], fill=COLORS["wood_lo"])

    # Handle end (slightly taller for grip)
    draw.rectangle([0, handle_top - 1, 4, handle_bottom + 1], fill=COLORS["wood_lo"])
    draw.rectangle([1, handle_top, 3, handle_bottom], fill=COLORS["wood"])

    # Wood grain
    for x in range(6, handle_length - 2, 4):
        draw.line([(x, handle_top + 1), (x, handle_bottom - 1)], fill=COLORS["wood_lo"])

    # === PERPENDICULAR METAL HEAD ===
    head_x = handle_length - 2
    head_width = 5
    head_top = 1
    head_bottom = 20  # Head from y=1 to y=20, tip at y=0 and y=21

    # Vertical bar
    draw.rectangle([head_x, head_top, head_x + head_width, head_bottom], fill=COLORS["metal"])

    # Shading on vertical bar
    draw.rectangle([head_x, head_top, head_x + 2, head_bottom], fill=COLORS["metal_lo"])
    draw.rectangle([head_x + head_width - 2, head_top, head_x + head_width, head_bottom], fill=COLORS["metal_hi"])

    # Top pointed end
    top_point_x = head_x + head_width // 2
    draw.polygon([
        (head_x + 1, head_top),
        (top_point_x, 0),
        (head_x + head_width - 1, head_top)
    ], fill=COLORS["metal_lo"])
    draw.point((top_point_x, 0), fill=COLORS["gleam"])

    # Bottom pointed end
    draw.polygon([
        (head_x + 1, head_bottom),
        (top_point_x, 21),
        (head_x + head_width - 1, head_bottom)
    ], fill=COLORS["metal_lo"])

    # === PICK POINT extending right ===
    handle_center = (handle_top + handle_bottom) // 2  # = 10
    for dx in range(head_width, 16):
        x = head_x + dx
        if x >= img.width:
            break
        thickness = max(1, 3 - dx // 4)
        for dy in range(-thickness, thickness + 1):
            y = handle_center + dy
            if 0 <= y < img.height:
                if dy <= 0:
                    img.putpixel((x, y), COLORS["metal_hi"])
                else:
                    img.putpixel((x, y), COLORS["metal_lo"])

    # Sharp tip
    if head_x + 14 < img.width:
        img.putpixel((head_x + 14, handle_center), COLORS["gleam"])

    # === COLLAR ===
    draw.rectangle([head_x - 2, handle_center - 4, head_x, handle_center + 4], fill=COLORS["metal_lo"])

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
