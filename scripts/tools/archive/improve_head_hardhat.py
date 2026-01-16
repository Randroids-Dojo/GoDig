#!/opt/homebrew/bin/python3.11
"""
Head Improvement - Iteration 5

Add a simple hardhat/mining helmet to make the character
more clearly identifiable as a miner.

Must maintain:
- Color coherence (keep under 8 colors)
- Edge clarity (1.00)
- High shading quality
"""

from PIL import Image, ImageDraw
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent.parent
COMPONENTS_DIR = PROJECT_ROOT / "resources" / "sprites" / "components"

# Use same palette with one addition for helmet
COLORS = {
    "skin_highlight": (255, 218, 185),
    "skin": (228, 180, 140),
    "skin_shadow": (180, 130, 100),

    # Yellow hardhat colors
    "helmet_highlight": (255, 220, 60),
    "helmet": (230, 190, 30),
    "helmet_shadow": (180, 145, 20),

    "outline": (25, 25, 30),
    "eye_white": (255, 255, 255),

    "transparent": (0, 0, 0, 0),
}


def create_head_with_helmet() -> Image.Image:
    """Create head with a simple hardhat."""
    img = Image.new('RGBA', (36, 38), COLORS["transparent"])  # Slightly taller for helmet
    draw = ImageDraw.Draw(img)

    # === HARDHAT (top layer drawn first as base) ===
    # Helmet dome
    draw.ellipse([4, 0, 32, 14], fill=COLORS["helmet"])
    # Highlight
    draw.ellipse([10, 1, 26, 10], fill=COLORS["helmet_highlight"])
    # Shadow
    draw.ellipse([4, 8, 16, 14], fill=COLORS["helmet_shadow"])

    # Helmet brim
    draw.rectangle([2, 10, 34, 14], fill=COLORS["helmet"])
    draw.rectangle([2, 10, 12, 14], fill=COLORS["helmet_shadow"])
    draw.rectangle([24, 10, 34, 13], fill=COLORS["helmet_highlight"])

    # === HEAD (below helmet) ===
    # Base head
    draw.ellipse([6, 10, 30, 34], fill=COLORS["skin"])

    # Shadow left side
    draw.ellipse([4, 12, 14, 34], fill=COLORS["skin_shadow"])

    # Highlight right/cheek
    draw.ellipse([18, 14, 28, 26], fill=COLORS["skin_highlight"])

    # Brow shadow (under helmet brim)
    draw.rectangle([8, 14, 26, 18], fill=COLORS["skin_shadow"])

    # === EYES ===
    # Left eye
    draw.rectangle([10, 18, 14, 22], fill=COLORS["eye_white"])
    draw.rectangle([11, 19, 13, 21], fill=COLORS["outline"])

    # Right eye
    draw.rectangle([19, 18, 23, 22], fill=COLORS["eye_white"])
    draw.rectangle([20, 19, 22, 21], fill=COLORS["outline"])

    # Eye highlights
    draw.point((11, 19), fill=COLORS["eye_white"])
    draw.point((20, 19), fill=COLORS["eye_white"])

    # Eyebrows (subtle under brim shadow)
    draw.rectangle([9, 16, 14, 18], fill=COLORS["skin_shadow"])
    draw.rectangle([18, 16, 23, 18], fill=COLORS["skin_shadow"])

    # === NOSE ===
    draw.rectangle([15, 22, 17, 26], fill=COLORS["skin_shadow"])

    # === MOUTH ===
    draw.rectangle([13, 28, 19, 29], fill=COLORS["skin_shadow"])

    # === EAR ===
    draw.ellipse([27, 18, 32, 28], fill=COLORS["skin"])
    draw.ellipse([28, 20, 31, 26], fill=COLORS["skin_shadow"])

    # Chin shadow
    draw.ellipse([10, 28, 22, 34], fill=COLORS["skin_shadow"])

    return img


def main():
    print("Generating head with hardhat...")

    head = create_head_with_helmet()
    head.save(COMPONENTS_DIR / "head.png")
    print(f"Saved: head.png ({head.size})")


if __name__ == "__main__":
    main()
