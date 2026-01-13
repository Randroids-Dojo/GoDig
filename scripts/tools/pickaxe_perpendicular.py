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

    center_y = 11  # Vertical center

    # === WOODEN HANDLE ===
    # Match primer length for color balance
    handle_length = 34

    # Thicker handle for more wood pixels
    draw.rectangle([0, center_y - 3, handle_length, center_y + 3], fill=COLORS["wood"])
    draw.rectangle([0, center_y - 3, handle_length, center_y - 1], fill=COLORS["wood_hi"])
    draw.rectangle([0, center_y + 1, handle_length, center_y + 3], fill=COLORS["wood_lo"])

    # Handle end
    draw.rectangle([0, center_y - 4, 4, center_y + 4], fill=COLORS["wood_lo"])
    draw.rectangle([1, center_y - 3, 3, center_y + 3], fill=COLORS["wood"])

    # Wood grain
    for x in range(6, handle_length - 2, 4):
        draw.line([(x, center_y - 2), (x, center_y + 2)], fill=COLORS["wood_lo"])

    # === PERPENDICULAR METAL HEAD ===
    head_x = handle_length - 2
    head_width = 5  # Narrower head

    # Vertical bar - extends above and below handle
    draw.rectangle([head_x, 2, head_x + head_width, 22], fill=COLORS["metal"])

    # Shading on vertical bar
    draw.rectangle([head_x, 2, head_x + 2, 22], fill=COLORS["metal_lo"])  # Left shadow
    draw.rectangle([head_x + head_width - 2, 2, head_x + head_width, 22], fill=COLORS["metal_hi"])  # Right

    # Top pointed end
    top_point_x = head_x + head_width // 2
    draw.polygon([
        (head_x + 1, 2),
        (top_point_x, 0),
        (head_x + head_width - 1, 2)
    ], fill=COLORS["metal_lo"])
    draw.point((top_point_x, 0), fill=COLORS["gleam"])

    # Bottom pointed end
    draw.polygon([
        (head_x + 1, 22),
        (top_point_x, 24),
        (head_x + head_width - 1, 22)
    ], fill=COLORS["metal_lo"])

    # === PICK POINT extending right ===
    for dx in range(head_width, 16):
        x = head_x + dx
        if x >= img.width:
            break
        thickness = max(1, 3 - dx // 4)
        for dy in range(-thickness, thickness + 1):
            y = center_y + dy
            if 0 <= y < img.height:
                if dy <= 0:
                    img.putpixel((x, y), COLORS["metal_hi"])
                else:
                    img.putpixel((x, y), COLORS["metal_lo"])

    # Sharp tip
    if head_x + 14 < img.width:
        img.putpixel((head_x + 14, center_y), COLORS["gleam"])

    # === COLLAR ===
    draw.rectangle([head_x - 2, center_y - 4, head_x, center_y + 4], fill=COLORS["metal_lo"])

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
