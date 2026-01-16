#!/opt/homebrew/bin/python3.11
"""
Arm Improvement - Iteration 7

Improve the arm with better shading and muscle definition.
Keep same color palette.
"""

from PIL import Image, ImageDraw
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent.parent
COMPONENTS_DIR = PROJECT_ROOT / "resources" / "sprites" / "components"

COLORS = {
    "skin_highlight": (255, 218, 185),
    "skin": (228, 180, 140),
    "skin_shadow": (180, 130, 100),

    "shirt_highlight": (100, 100, 110),
    "shirt": (75, 75, 85),
    "shirt_shadow": (50, 50, 60),

    "transparent": (0, 0, 0, 0),
}


def create_improved_arm() -> Image.Image:
    """Create arm with improved shading."""
    img = Image.new('RGBA', (44, 18), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # === UPPER ARM (SHIRT SLEEVE) ===
    # Base
    draw.rectangle([0, 4, 18, 14], fill=COLORS["shirt"])
    # Top highlight
    draw.rectangle([4, 4, 18, 8], fill=COLORS["shirt_highlight"])
    # Bottom shadow
    draw.rectangle([0, 10, 14, 14], fill=COLORS["shirt_shadow"])
    # Left edge shadow
    draw.rectangle([0, 4, 4, 14], fill=COLORS["shirt_shadow"])

    # Sleeve hem
    draw.rectangle([16, 4, 18, 14], fill=COLORS["shirt_shadow"])

    # === FOREARM (SKIN) ===
    # Base
    draw.rectangle([18, 5, 36, 13], fill=COLORS["skin"])
    # Shadow at sleeve transition
    draw.rectangle([18, 5, 22, 13], fill=COLORS["skin_shadow"])
    # Top highlight
    draw.rectangle([26, 5, 36, 9], fill=COLORS["skin_highlight"])
    # Bottom shadow (under arm)
    draw.rectangle([22, 11, 34, 13], fill=COLORS["skin_shadow"])

    # === HAND ===
    draw.rectangle([36, 4, 44, 14], fill=COLORS["skin"])
    # Top highlight
    draw.rectangle([38, 4, 44, 8], fill=COLORS["skin_highlight"])
    # Palm shadow
    draw.rectangle([36, 10, 42, 14], fill=COLORS["skin_shadow"])

    # Finger grip area
    draw.rectangle([40, 6, 44, 12], fill=COLORS["skin"])
    draw.rectangle([42, 7, 44, 11], fill=COLORS["skin_shadow"])

    # Wrist crease
    draw.line([(36, 6), (36, 12)], fill=COLORS["skin_shadow"])

    return img


def main():
    print("Generating improved arm...")
    arm = create_improved_arm()
    arm.save(COMPONENTS_DIR / "arm.png")
    print(f"Saved: arm.png ({arm.size})")


if __name__ == "__main__":
    main()
