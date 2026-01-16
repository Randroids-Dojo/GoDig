#!/opt/homebrew/bin/python3.11
"""
Targeted Body Improvement - Iteration 4

Only modifies the body component, keeping all others from primer.
Goal: Improve body score from 0.87 to 0.90+

Focus areas:
- Increase shading quality (currently 0.90)
- Maintain color coherence (currently 1.00 with 11 colors)
- Keep edge clarity perfect (1.00)
"""

from PIL import Image, ImageDraw
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent.parent
COMPONENTS_DIR = PROJECT_ROOT / "resources" / "sprites" / "components"

# Use EXACT same palette as v1 to maintain coherence
COLORS = {
    "skin_highlight": (255, 218, 185),
    "skin": (228, 180, 140),
    "skin_shadow": (180, 130, 100),

    "jeans_highlight": (80, 100, 160),
    "jeans": (60, 80, 140),
    "jeans_shadow": (35, 50, 100),

    "shirt_highlight": (100, 100, 110),
    "shirt": (75, 75, 85),
    "shirt_shadow": (50, 50, 60),

    "leather": (50, 35, 25),
    "leather_highlight": (70, 50, 35),

    "metal_highlight": (200, 200, 210),

    "outline": (25, 25, 30),

    "transparent": (0, 0, 0, 0),
}


def create_improved_body() -> Image.Image:
    """Create body with improved shading contrast."""
    img = Image.new('RGBA', (52, 68), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # === TORSO with stronger contrast ===
    # Deep shadow left edge
    draw.rectangle([14, 2, 18, 26], fill=COLORS["shirt_shadow"])
    # Shadow side
    draw.rectangle([18, 2, 22, 26], fill=COLORS["shirt_shadow"])
    # Mid tone
    draw.rectangle([22, 2, 30, 26], fill=COLORS["shirt"])
    # Highlight side (right)
    draw.rectangle([30, 2, 36, 26], fill=COLORS["shirt_highlight"])

    # Shoulder areas with shading
    draw.rectangle([10, 4, 14, 12], fill=COLORS["shirt_shadow"])
    draw.rectangle([36, 4, 42, 12], fill=COLORS["shirt_highlight"])

    # Collar/neck
    draw.rectangle([22, 0, 30, 4], fill=COLORS["skin_shadow"])
    draw.rectangle([24, 1, 28, 3], fill=COLORS["skin"])

    # Shirt fold detail (adds visual interest without new colors)
    draw.line([(26, 8), (26, 22)], fill=COLORS["shirt_shadow"])
    draw.line([(32, 6), (32, 22)], fill=COLORS["shirt_highlight"])

    # === BELT with contrast ===
    draw.rectangle([14, 26, 38, 30], fill=COLORS["leather"])
    draw.rectangle([32, 26, 38, 30], fill=COLORS["leather_highlight"])
    draw.rectangle([14, 26, 18, 30], fill=COLORS["outline"])

    # Belt buckle
    draw.rectangle([24, 27, 28, 29], fill=COLORS["metal_highlight"])

    # === LEGS with stronger shading ===
    # Left leg (more shadow)
    draw.rectangle([14, 30, 25, 54], fill=COLORS["jeans"])
    draw.rectangle([14, 30, 18, 54], fill=COLORS["jeans_shadow"])
    draw.rectangle([22, 30, 25, 54], fill=COLORS["jeans_highlight"])

    # Right leg
    draw.rectangle([27, 30, 38, 54], fill=COLORS["jeans"])
    draw.rectangle([27, 30, 30, 54], fill=COLORS["jeans_shadow"])
    draw.rectangle([34, 30, 38, 54], fill=COLORS["jeans_highlight"])

    # Stronger knee highlights
    draw.rectangle([19, 40, 23, 44], fill=COLORS["jeans_highlight"])
    draw.rectangle([32, 40, 36, 44], fill=COLORS["jeans_highlight"])

    # Inner leg shadow
    draw.line([(25, 30), (25, 54)], fill=COLORS["jeans_shadow"])
    draw.line([(27, 30), (27, 54)], fill=COLORS["jeans_shadow"])

    # === BOOTS with contrast ===
    # Left boot
    draw.rectangle([12, 54, 26, 60], fill=COLORS["leather"])
    draw.rectangle([12, 54, 16, 60], fill=COLORS["outline"])
    draw.rectangle([22, 54, 26, 58], fill=COLORS["leather_highlight"])

    # Right boot
    draw.rectangle([26, 54, 40, 60], fill=COLORS["leather"])
    draw.rectangle([34, 54, 40, 58], fill=COLORS["leather_highlight"])

    # Soles
    draw.rectangle([10, 58, 26, 62], fill=COLORS["outline"])
    draw.rectangle([26, 58, 42, 62], fill=COLORS["outline"])

    return img


def main():
    print("Generating improved body component only...")

    body = create_improved_body()
    body.save(COMPONENTS_DIR / "body.png")
    print(f"Saved: body.png ({body.size})")


if __name__ == "__main__":
    main()
