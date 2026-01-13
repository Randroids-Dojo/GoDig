#!/opt/homebrew/bin/python3.11
"""
Enhanced Pickaxe - Keep shape, improve contrast and details

Based on primer design, with:
- Stronger metal head contrast
- More prominent top spike
- Better color separation
"""

from PIL import Image, ImageDraw
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent.parent
COMPONENTS_DIR = PROJECT_ROOT / "resources" / "sprites" / "components"

# Same palette as improved_sprite_builder.py
COLORS = {
    # Wood
    "wood_highlight": (180, 120, 60),
    "wood": (139, 90, 43),
    "wood_shadow": (100, 60, 25),

    # Metal - ENHANCED contrast
    "metal_highlight": (220, 220, 235),  # Brighter
    "metal": (130, 130, 145),
    "metal_shadow": (55, 55, 70),  # Darker

    "transparent": (0, 0, 0, 0),
}


def create_enhanced_pickaxe() -> Image.Image:
    """Create pickaxe based on primer design with enhanced contrast."""
    img = Image.new('RGBA', (52, 24), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # === HANDLE (same as primer) ===
    draw.rectangle([0, 10, 34, 12], fill=COLORS["wood_shadow"])
    draw.rectangle([0, 8, 34, 10], fill=COLORS["wood"])
    draw.rectangle([0, 6, 34, 8], fill=COLORS["wood_highlight"])

    # Grip texture
    for x in range(2, 32, 4):
        draw.line([(x, 7), (x, 11)], fill=COLORS["wood_shadow"])

    # === PICKAXE HEAD (same shape, enhanced shading) ===
    head_points = [
        (32, 8),   # Left attachment
        (38, 2),   # Upper left
        (48, 6),   # Upper right point
        (52, 10),  # Far right tip
        (48, 14),  # Lower right
        (38, 18),  # Lower left
        (32, 12),  # Left attachment bottom
    ]
    draw.polygon(head_points, fill=COLORS["metal"])

    # ENHANCED top highlight - larger area
    draw.polygon([
        (33, 8), (40, 2), (49, 6), (44, 9), (33, 9)
    ], fill=COLORS["metal_highlight"])

    # ENHANCED bottom shadow - larger area
    draw.polygon([
        (33, 11), (40, 17), (49, 14), (44, 11), (33, 11)
    ], fill=COLORS["metal_shadow"])

    # Sharp edge highlight on tip - brighter
    draw.line([(50, 8), (52, 10), (50, 12)], fill=(255, 255, 255))
    draw.line([(49, 9), (51, 10), (49, 11)], fill=COLORS["metal_highlight"])

    # === TOP SPIKE - more prominent ===
    draw.polygon([
        (35, 4), (40, -1), (45, 4), (40, 6)
    ], fill=COLORS["metal_shadow"])
    # Spike highlight
    draw.line([(37, 2), (40, 0)], fill=COLORS["metal_highlight"])
    draw.line([(40, 0), (43, 2)], fill=COLORS["metal"])

    # === ATTACHMENT RING ===
    draw.ellipse([30, 7, 34, 13], fill=COLORS["metal_shadow"])
    draw.ellipse([31, 8, 33, 12], fill=COLORS["wood"])

    return img


def main():
    print("Creating enhanced pickaxe...")
    pickaxe = create_enhanced_pickaxe()
    pickaxe.save(COMPONENTS_DIR / "pickaxe.png")
    print(f"Saved: pickaxe.png ({pickaxe.size})")

    # Validate
    import sys
    sys.path.insert(0, 'scripts/tools')
    from component_validator import validate_component
    from pickaxe_validator import validate_pickaxe

    print("\nComponent Validator:")
    comp_score = validate_component(COMPONENTS_DIR / "pickaxe.png")
    print(f"  Overall: {comp_score.overall:.2f}")

    print("\nPickaxe Validator:")
    pick_score = validate_pickaxe()
    print(pick_score)


if __name__ == "__main__":
    main()
