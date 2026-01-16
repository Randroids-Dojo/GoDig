#!/opt/homebrew/bin/python3.11
"""
Pickaxe Improvement - Iteration 6

Improve the pickaxe with:
- Better metal sheen
- Cleaner shape
- Maintain color count under 8
"""

from PIL import Image, ImageDraw
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent.parent
COMPONENTS_DIR = PROJECT_ROOT / "resources" / "sprites" / "components"

COLORS = {
    # Wood handle
    "wood_highlight": (180, 120, 60),
    "wood": (139, 90, 43),
    "wood_shadow": (100, 60, 25),

    # Metal head
    "metal_highlight": (220, 220, 235),
    "metal": (140, 140, 155),
    "metal_shadow": (70, 70, 85),

    # Sharp edge gleam
    "gleam": (255, 255, 255),

    "transparent": (0, 0, 0, 0),
}


def create_improved_pickaxe() -> Image.Image:
    """Create pickaxe with better shading and shape."""
    img = Image.new('RGBA', (54, 24), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # === HANDLE ===
    # Main handle body - 3 tone shading
    draw.rectangle([0, 10, 34, 14], fill=COLORS["wood"])
    draw.rectangle([0, 9, 34, 11], fill=COLORS["wood_highlight"])
    draw.rectangle([0, 13, 34, 15], fill=COLORS["wood_shadow"])

    # Handle end cap
    draw.rectangle([0, 8, 4, 16], fill=COLORS["wood_shadow"])
    draw.rectangle([1, 9, 3, 15], fill=COLORS["wood"])

    # Wood grain texture
    for x in range(8, 32, 6):
        draw.line([(x, 10), (x, 14)], fill=COLORS["wood_shadow"])

    # === PICKAXE HEAD ===
    # Main head shape
    head_points = [
        (32, 10),   # Left attach
        (38, 4),    # Upper corner
        (50, 8),    # Upper tip approach
        (54, 12),   # Tip
        (50, 16),   # Lower tip approach
        (38, 20),   # Lower corner
        (32, 14),   # Left attach bottom
    ]
    draw.polygon(head_points, fill=COLORS["metal"])

    # Top face highlight
    draw.polygon([
        (34, 10), (40, 5), (50, 9), (46, 11), (34, 11)
    ], fill=COLORS["metal_highlight"])

    # Bottom shadow
    draw.polygon([
        (34, 13), (40, 18), (50, 15), (46, 13), (34, 13)
    ], fill=COLORS["metal_shadow"])

    # Tip gleam (sharp edge)
    draw.line([(52, 10), (54, 12), (52, 14)], fill=COLORS["gleam"])
    draw.point((53, 12), fill=COLORS["gleam"])

    # === TOP SPIKE ===
    draw.polygon([
        (36, 6), (42, 0), (46, 4), (40, 8)
    ], fill=COLORS["metal_shadow"])
    draw.polygon([
        (38, 4), (42, 1), (44, 4), (40, 6)
    ], fill=COLORS["metal"])
    # Spike tip gleam
    draw.point((42, 1), fill=COLORS["metal_highlight"])

    # === COLLAR (metal ring where head meets handle) ===
    draw.ellipse([30, 9, 36, 15], fill=COLORS["metal_shadow"])
    draw.ellipse([31, 10, 35, 14], fill=COLORS["metal"])
    draw.point((33, 11), fill=COLORS["metal_highlight"])

    return img


def main():
    print("Generating improved pickaxe...")

    pickaxe = create_improved_pickaxe()
    pickaxe.save(COMPONENTS_DIR / "pickaxe.png")
    print(f"Saved: pickaxe.png ({pickaxe.size})")


if __name__ == "__main__":
    main()
