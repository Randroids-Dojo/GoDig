#!/opt/homebrew/bin/python3.11
"""
Pickaxe Optimizer

Search for the optimal parameters that maximize the overall pickaxe score.
"""

from PIL import Image, ImageDraw
from pathlib import Path
import sys

PROJECT_ROOT = Path(__file__).parent.parent.parent
COMPONENTS_DIR = PROJECT_ROOT / "resources" / "sprites" / "components"

sys.path.insert(0, str(Path(__file__).parent))
from pickaxe_validator import validate_pickaxe

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


def create_parametric_pickaxe(
    handle_length: int = 32,
    head_top: int = 4,
    head_bottom: int = 20,
    head_width: int = 5,
    point_length: int = 14
) -> Image.Image:
    """Create a pickaxe with configurable parameters."""
    img = Image.new('RGBA', (52, 24), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    center_y = 11

    # === WOODEN HANDLE ===
    draw.rectangle([0, center_y - 2, handle_length, center_y + 3], fill=COLORS["wood"])
    draw.rectangle([0, center_y - 2, handle_length, center_y], fill=COLORS["wood_hi"])
    draw.rectangle([0, center_y + 1, handle_length, center_y + 3], fill=COLORS["wood_lo"])

    # Handle end
    draw.rectangle([0, center_y - 3, 3, center_y + 4], fill=COLORS["wood_lo"])
    draw.rectangle([1, center_y - 2, 2, center_y + 3], fill=COLORS["wood"])

    # Wood grain
    for x in range(5, handle_length - 2, 4):
        draw.line([(x, center_y - 1), (x, center_y + 2)], fill=COLORS["wood_lo"])

    # === PERPENDICULAR METAL HEAD ===
    head_x = handle_length - 2

    # Vertical bar
    draw.rectangle([head_x, head_top, head_x + head_width, head_bottom], fill=COLORS["metal"])
    draw.rectangle([head_x, head_top, head_x + 1, head_bottom], fill=COLORS["metal_lo"])
    draw.rectangle([head_x + head_width - 1, head_top, head_x + head_width, head_bottom], fill=COLORS["metal_hi"])

    # Top point
    mid_x = head_x + head_width // 2
    if head_top > 0:
        draw.polygon([
            (head_x + 1, head_top),
            (mid_x, max(0, head_top - 1)),
            (head_x + head_width - 1, head_top)
        ], fill=COLORS["metal_lo"])
        draw.point((mid_x, max(0, head_top - 1)), fill=COLORS["gleam"])

    # Bottom point
    if head_bottom < 23:
        draw.polygon([
            (head_x + 1, head_bottom),
            (mid_x, min(23, head_bottom + 1)),
            (head_x + head_width - 1, head_bottom)
        ], fill=COLORS["metal_lo"])

    # === PICK POINT extending right ===
    for dx in range(head_width + 1, head_width + point_length):
        x = head_x + dx
        if x >= img.width:
            break
        thickness = max(1, 3 - dx // 5)
        for dy in range(-thickness, thickness + 1):
            y = center_y + dy
            if 0 <= y < img.height:
                if dy <= 0:
                    img.putpixel((x, y), COLORS["metal_hi"])
                else:
                    img.putpixel((x, y), COLORS["metal_lo"])

    # Sharp tip
    tip_x = head_x + head_width + point_length - 2
    if tip_x < img.width:
        img.putpixel((tip_x, center_y), COLORS["gleam"])

    # === COLLAR ===
    draw.rectangle([head_x - 2, center_y - 3, head_x, center_y + 4], fill=COLORS["metal_lo"])

    return img


def search_optimal_params():
    """Grid search for optimal parameters."""
    best_score = 0
    best_params = {}
    results = []

    print("Searching for optimal perpendicular pickaxe parameters...")
    print("="*60)

    # Grid search
    for handle_length in [30, 32, 34]:
        for head_top in [2, 3, 4, 5]:
            for head_bottom in [18, 19, 20, 21]:
                for head_width in [4, 5, 6]:
                    for point_length in [12, 14, 16]:
                        params = {
                            "handle_length": handle_length,
                            "head_top": head_top,
                            "head_bottom": head_bottom,
                            "head_width": head_width,
                            "point_length": point_length
                        }

                        pickaxe = create_parametric_pickaxe(**params)
                        pickaxe.save(COMPONENTS_DIR / "pickaxe_test.png")
                        score = validate_pickaxe(COMPONENTS_DIR / "pickaxe_test.png")

                        results.append((params, score.overall, score))

                        if score.overall > best_score:
                            best_score = score.overall
                            best_params = params
                            best_subscores = score

    # Cleanup
    (COMPONENTS_DIR / "pickaxe_test.png").unlink(missing_ok=True)

    # Sort and show top 10
    results.sort(key=lambda x: x[1], reverse=True)

    print("\nTop 10 configurations:")
    for i, (params, overall, subscores) in enumerate(results[:10]):
        print(f"\n{i+1}. Score: {overall:.3f}")
        print(f"   Params: handle={params['handle_length']}, head_top={params['head_top']}, "
              f"head_bottom={params['head_bottom']}, width={params['head_width']}, point={params['point_length']}")
        print(f"   Sil={subscores.silhouette_clarity:.2f}, Ratio={subscores.handle_head_ratio:.2f}, "
              f"Colors={subscores.color_separation:.2f}, Vert={subscores.vertical_extent:.2f}")

    print("\n" + "="*60)
    print(f"BEST CONFIGURATION: {best_score:.3f}")
    print(f"Parameters: {best_params}")
    print("="*60)

    return best_params, best_score


def main():
    best_params, best_score = search_optimal_params()

    # Create and save the best configuration
    best_pickaxe = create_parametric_pickaxe(**best_params)
    best_pickaxe.save(COMPONENTS_DIR / "pickaxe_optimized.png")

    print(f"\nSaved optimized pickaxe to: pickaxe_optimized.png")

    # Compare with primer
    from improved_sprite_builder import create_pickaxe_component
    primer = create_pickaxe_component()
    primer.save(COMPONENTS_DIR / "pickaxe_primer_temp.png")
    primer_score = validate_pickaxe(COMPONENTS_DIR / "pickaxe_primer_temp.png")
    (COMPONENTS_DIR / "pickaxe_primer_temp.png").unlink()

    print(f"\nPrimer score: {primer_score.overall:.3f}")
    print(f"Optimized score: {best_score:.3f}")

    if best_score >= primer_score.overall:
        print("\n*** OPTIMIZED DESIGN MATCHES OR BEATS PRIMER! ***")
    else:
        print(f"\n*** Primer still wins by {primer_score.overall - best_score:.3f} ***")


if __name__ == "__main__":
    main()
