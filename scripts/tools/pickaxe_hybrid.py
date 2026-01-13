#!/opt/homebrew/bin/python3.11
"""
Hybrid Pickaxe Design - Iteration 4

Strategy: Keep primer's excellent color separation (1.00) while
improving the handle/head ratio (currently 0.20).

The primer's weak point is the ratio - the head needs to be more
clearly defined as 25-40% of total length.

Key insight: The validator looks for a head transition where
vertical extent changes. Make this more pronounced.
"""

from PIL import Image, ImageDraw
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent.parent
COMPONENTS_DIR = PROJECT_ROOT / "resources" / "sprites" / "components"

# EXACT same colors as primer
COLORS = {
    "wood_highlight": (180, 120, 60),
    "wood": (139, 90, 43),
    "wood_shadow": (100, 60, 25),

    "metal_highlight": (200, 200, 210),
    "metal": (120, 120, 130),
    "metal_shadow": (60, 60, 70),

    "transparent": (0, 0, 0, 0),
}


def create_hybrid_pickaxe() -> Image.Image:
    """
    Create pickaxe that:
    - Maintains primer's color balance for 1.00 color separation
    - Has clearly defined head ~30% of total length
    - Keeps strong vertical extent
    """
    img = Image.new('RGBA', (52, 24), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # Total width usage: ~50 pixels
    # Target: head should be ~15 pixels (30% of 50)

    # === HANDLE (similar to primer but shorter to improve ratio) ===
    # Primer handle goes 0-34, we'll go 0-32
    handle_end = 32

    # Three-tone shading like primer
    draw.rectangle([0, 10, handle_end, 12], fill=COLORS["wood_shadow"])
    draw.rectangle([0, 8, handle_end, 10], fill=COLORS["wood"])
    draw.rectangle([0, 6, handle_end, 8], fill=COLORS["wood_highlight"])

    # Handle grip texture
    for x in range(2, handle_end - 2, 4):
        draw.line([(x, 7), (x, 11)], fill=COLORS["wood_shadow"])

    # === PICKAXE HEAD - Clearer definition with perpendicular element ===
    head_start = handle_end - 2

    # Create a more defined head shape that the validator can detect
    # The key is having clear vertical extent change at the head

    # Main head body - wider and taller than handle
    head_points = [
        (head_start, 6),      # Upper left (above handle line)
        (head_start + 8, 2),  # Upper curve
        (head_start + 16, 8), # Upper right tip area
        (head_start + 18, 10), # Far right tip
        (head_start + 16, 12), # Lower right tip area
        (head_start + 8, 18),  # Lower curve
        (head_start, 14),      # Lower left (below handle line)
    ]
    draw.polygon(head_points, fill=COLORS["metal"])

    # Top highlight surface
    draw.polygon([
        (head_start + 2, 6),
        (head_start + 10, 3),
        (head_start + 16, 8),
        (head_start + 10, 10),
        (head_start + 2, 10)
    ], fill=COLORS["metal_highlight"])

    # Bottom shadow surface
    draw.polygon([
        (head_start + 2, 12),
        (head_start + 10, 16),
        (head_start + 16, 12),
        (head_start + 10, 11),
        (head_start + 2, 11)
    ], fill=COLORS["metal_shadow"])

    # Sharp tip highlight
    draw.line([(head_start + 17, 9), (head_start + 18, 10), (head_start + 17, 11)],
              fill=(255, 255, 255))

    # === TOP SPIKE - More pronounced perpendicular element ===
    draw.polygon([
        (head_start + 4, 4),   # Base left
        (head_start + 8, 0),   # Top point
        (head_start + 12, 4),  # Base right
        (head_start + 8, 6)    # Bottom
    ], fill=COLORS["metal_shadow"])
    draw.line([(head_start + 6, 2), (head_start + 10, 2)], fill=COLORS["metal_highlight"])

    # === ATTACHMENT COLLAR ===
    draw.ellipse([head_start - 2, 7, head_start + 2, 13], fill=COLORS["metal_shadow"])
    draw.ellipse([head_start - 1, 8, head_start + 1, 12], fill=COLORS["wood"])

    return img


def analyze_color_balance(img: Image.Image) -> dict:
    """Analyze wood vs metal pixel ratio."""
    pixels = list(img.getdata())

    wood_count = 0
    metal_count = 0

    wood_colors = [COLORS["wood_highlight"], COLORS["wood"], COLORS["wood_shadow"]]
    metal_colors = [COLORS["metal_highlight"], COLORS["metal"], COLORS["metal_shadow"]]

    for p in pixels:
        if p[3] > 128:  # Opaque
            rgb = (p[0], p[1], p[2])
            if rgb in wood_colors or any(abs(rgb[0]-w[0])<10 and abs(rgb[1]-w[1])<10 for w in wood_colors):
                wood_count += 1
            elif rgb in metal_colors or any(abs(rgb[0]-m[0])<15 and abs(rgb[1]-m[1])<15 for m in metal_colors):
                metal_count += 1

    total = wood_count + metal_count
    return {
        "wood": wood_count,
        "metal": metal_count,
        "total": total,
        "wood_ratio": wood_count / total if total > 0 else 0,
        "metal_ratio": metal_count / total if total > 0 else 0
    }


def main():
    print("Creating hybrid pickaxe (iteration 4)...")

    # Load primer for comparison
    primer = Image.open(COMPONENTS_DIR / "pickaxe.png")
    primer_balance = analyze_color_balance(primer)
    print(f"\nPrimer color balance:")
    print(f"  Wood: {primer_balance['wood_ratio']:.2%}")
    print(f"  Metal: {primer_balance['metal_ratio']:.2%}")

    # Create hybrid
    hybrid = create_hybrid_pickaxe()
    hybrid_balance = analyze_color_balance(hybrid)
    print(f"\nHybrid color balance:")
    print(f"  Wood: {hybrid_balance['wood_ratio']:.2%}")
    print(f"  Metal: {hybrid_balance['metal_ratio']:.2%}")

    # Save hybrid temporarily
    hybrid.save(COMPONENTS_DIR / "pickaxe_hybrid.png")

    # Validate
    import sys
    sys.path.insert(0, str(Path(__file__).parent))
    from pickaxe_validator import validate_pickaxe
    from component_validator import validate_component

    print("\n" + "="*50)
    print("VALIDATION COMPARISON")
    print("="*50)

    primer_score = validate_pickaxe(COMPONENTS_DIR / "pickaxe.png")
    hybrid_score = validate_pickaxe(COMPONENTS_DIR / "pickaxe_hybrid.png")

    print(f"\nPRIMER: {primer_score.overall:.2f}")
    print(f"  Silhouette: {primer_score.silhouette_clarity:.2f}")
    print(f"  Ratio: {primer_score.handle_head_ratio:.2f}")
    print(f"  Colors: {primer_score.color_separation:.2f}")
    print(f"  Vertical: {primer_score.vertical_extent:.2f}")

    print(f"\nHYBRID: {hybrid_score.overall:.2f}")
    print(f"  Silhouette: {hybrid_score.silhouette_clarity:.2f}")
    print(f"  Ratio: {hybrid_score.handle_head_ratio:.2f}")
    print(f"  Colors: {hybrid_score.color_separation:.2f}")
    print(f"  Vertical: {hybrid_score.vertical_extent:.2f}")

    # Decide whether to replace primer
    if hybrid_score.overall > primer_score.overall:
        print(f"\n*** HYBRID WINS ({hybrid_score.overall:.2f} > {primer_score.overall:.2f}) ***")
        print("Replacing primer with hybrid...")
        hybrid.save(COMPONENTS_DIR / "pickaxe.png")
        # Backup primer
        primer.save(COMPONENTS_DIR / "pickaxe_primer_backup.png")
        print("Done! (primer backed up to pickaxe_primer_backup.png)")
    else:
        print(f"\n*** PRIMER WINS ({primer_score.overall:.2f} >= {hybrid_score.overall:.2f}) ***")
        print("Keeping primer as-is")
        # Clean up
        import os
        os.remove(COMPONENTS_DIR / "pickaxe_hybrid.png")


if __name__ == "__main__":
    main()
