#!/opt/homebrew/bin/python3.11
"""
Curved Pickaxe Design

Classic mining pickaxe with curved head that arcs toward the striking point.
- Handle: 2/3 of length
- Head: Curved arc with pointed tip
- Top spike for balance
"""

from PIL import Image, ImageDraw
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent.parent
COMPONENTS_DIR = PROJECT_ROOT / "resources" / "sprites" / "components"

COLORS = {
    # Wood (warm browns)
    "wood_hi": (180, 120, 60),
    "wood": (140, 90, 45),
    "wood_lo": (95, 58, 25),

    # Metal (cool grays with slight blue)
    "metal_hi": (195, 195, 210),
    "metal": (125, 125, 140),
    "metal_lo": (65, 65, 80),

    # Gleam
    "gleam": (255, 255, 255),

    "transparent": (0, 0, 0, 0),
}


def create_curved_pickaxe() -> Image.Image:
    """Create pickaxe with curved head design."""
    img = Image.new('RGBA', (52, 24), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    center_y = 11  # Slightly above center

    # === WOODEN HANDLE ===
    handle_top = center_y - 2
    handle_bottom = center_y + 3

    # Main handle
    draw.rectangle([0, handle_top, 32, handle_bottom], fill=COLORS["wood"])
    draw.rectangle([0, handle_top, 32, handle_top + 1], fill=COLORS["wood_hi"])
    draw.rectangle([0, handle_bottom - 1, 32, handle_bottom], fill=COLORS["wood_lo"])

    # Handle end cap
    draw.rectangle([0, handle_top - 1, 3, handle_bottom + 1], fill=COLORS["wood_lo"])
    draw.rectangle([1, handle_top, 2, handle_bottom], fill=COLORS["wood"])

    # Wood grain
    for x in range(6, 30, 5):
        draw.line([(x, handle_top + 1), (x, handle_bottom - 1)], fill=COLORS["wood_lo"])

    # === METAL HEAD - Curved design ===
    head_attach_x = 30

    # Main curved head body - thicker at attachment, curves to point
    # Using multiple polygons to create curved appearance

    # Core head mass
    draw.polygon([
        (head_attach_x, center_y - 4),    # Top attach
        (head_attach_x + 6, center_y - 5),  # Curve up
        (head_attach_x + 14, center_y - 3), # Peak
        (head_attach_x + 20, center_y + 2), # Curve down to tip
        (head_attach_x + 18, center_y + 4), # Under tip
        (head_attach_x + 10, center_y + 3), # Under curve
        (head_attach_x, center_y + 2),      # Bottom attach
    ], fill=COLORS["metal"])

    # Top surface highlight
    draw.polygon([
        (head_attach_x + 2, center_y - 3),
        (head_attach_x + 8, center_y - 4),
        (head_attach_x + 14, center_y - 2),
        (head_attach_x + 8, center_y - 1),
        (head_attach_x + 2, center_y - 1),
    ], fill=COLORS["metal_hi"])

    # Bottom shadow
    draw.polygon([
        (head_attach_x + 2, center_y + 1),
        (head_attach_x + 12, center_y + 2),
        (head_attach_x + 18, center_y + 3),
        (head_attach_x + 12, center_y + 4),
        (head_attach_x + 2, center_y + 2),
    ], fill=COLORS["metal_lo"])

    # Sharp tip
    draw.polygon([
        (head_attach_x + 18, center_y),
        (head_attach_x + 22, center_y + 2),  # Tip point
        (head_attach_x + 18, center_y + 4),
    ], fill=COLORS["metal"])
    draw.point((head_attach_x + 21, center_y + 2), fill=COLORS["gleam"])
    draw.point((head_attach_x + 20, center_y + 1), fill=COLORS["metal_hi"])

    # === TOP SPIKE (smaller, for balance) ===
    draw.polygon([
        (head_attach_x + 4, center_y - 5),   # Base left
        (head_attach_x + 6, center_y - 8),   # Top point
        (head_attach_x + 8, center_y - 5),   # Base right
    ], fill=COLORS["metal_lo"])
    draw.line([
        (head_attach_x + 5, center_y - 6),
        (head_attach_x + 7, center_y - 6)
    ], fill=COLORS["metal"])
    draw.point((head_attach_x + 6, center_y - 7), fill=COLORS["metal_hi"])

    # === COLLAR ===
    draw.rectangle([head_attach_x - 2, center_y - 3, head_attach_x + 1, center_y + 2], fill=COLORS["metal_lo"])
    draw.rectangle([head_attach_x - 1, center_y - 2, head_attach_x, center_y + 1], fill=COLORS["metal"])

    return img


def main():
    print("Creating curved pickaxe design...")
    pickaxe = create_curved_pickaxe()
    pickaxe.save(COMPONENTS_DIR / "pickaxe.png")
    print(f"Saved: pickaxe.png ({pickaxe.size})")

    # Validate both ways
    import sys
    sys.path.insert(0, 'scripts/tools')
    from component_validator import validate_component
    from pickaxe_validator import validate_pickaxe

    print("\nComponent Validator:")
    comp_score = validate_component(COMPONENTS_DIR / "pickaxe.png")
    print(f"  Overall: {comp_score.overall:.2f}")

    print("\nPickaxe Validator:")
    pick_score = validate_pickaxe()
    print(f"  Overall: {pick_score.overall:.2f}")


if __name__ == "__main__":
    main()
