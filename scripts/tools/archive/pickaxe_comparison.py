#!/opt/homebrew/bin/python3.11
"""
Pickaxe Visual Comparison Tool

Creates a side-by-side comparison image of all pickaxe designs with their scores.
"""

from PIL import Image, ImageDraw, ImageFont
from pathlib import Path
import sys

PROJECT_ROOT = Path(__file__).parent.parent.parent
COMPONENTS_DIR = PROJECT_ROOT / "resources" / "sprites" / "components"
OUTPUT_DIR = PROJECT_ROOT / "resources" / "sprites"

sys.path.insert(0, str(Path(__file__).parent))
from pickaxe_validator import validate_pickaxe
from improved_sprite_builder import create_pickaxe_component as create_primer


def create_all_designs() -> dict:
    """Generate all pickaxe designs and return as dict."""
    designs = {}

    # Primer (current best)
    designs["Primer (1.00)"] = create_primer()

    # Perpendicular
    from pickaxe_perpendicular import create_perpendicular_pickaxe
    designs["Perpendicular"] = create_perpendicular_pickaxe()

    # Iconic
    from pickaxe_iconic import create_iconic_pickaxe
    designs["Iconic"] = create_iconic_pickaxe()

    # Curved
    from pickaxe_curved import create_curved_pickaxe
    designs["Curved"] = create_curved_pickaxe()

    # Enhanced
    from pickaxe_enhanced import create_enhanced_pickaxe
    designs["Enhanced"] = create_enhanced_pickaxe()

    return designs


def create_comparison_image(designs: dict, scale: int = 4) -> Image.Image:
    """Create side-by-side comparison at larger scale for visibility."""
    num_designs = len(designs)

    # Each cell: scaled image + label
    cell_width = 52 * scale + 20
    cell_height = 24 * scale + 60
    padding = 10

    img_width = num_designs * cell_width + (num_designs + 1) * padding
    img_height = cell_height + 2 * padding

    # Create comparison canvas
    comparison = Image.new('RGBA', (img_width, img_height), (40, 40, 45, 255))
    draw = ImageDraw.Draw(comparison)

    x_offset = padding
    for name, pickaxe in designs.items():
        # Scale up the pickaxe
        scaled = pickaxe.resize((52 * scale, 24 * scale), Image.Resampling.NEAREST)

        # Draw background for this cell
        cell_x = x_offset
        cell_y = padding
        draw.rectangle([cell_x, cell_y, cell_x + cell_width - 1, cell_y + cell_height - 1],
                      fill=(60, 60, 65, 255), outline=(80, 80, 90, 255))

        # Paste scaled pickaxe
        img_x = cell_x + (cell_width - scaled.width) // 2
        img_y = cell_y + 10
        comparison.paste(scaled, (img_x, img_y), scaled)

        # Save temporarily and validate
        temp_path = COMPONENTS_DIR / "pickaxe_temp.png"
        pickaxe.save(temp_path)
        score = validate_pickaxe(temp_path)
        temp_path.unlink()

        # Draw label with score
        label = f"{name}"
        score_text = f"Score: {score.overall:.2f}"

        # Simple text rendering (centered)
        label_y = img_y + scaled.height + 8
        for i, char in enumerate(label[:15]):  # Limit length
            cx = cell_x + 10 + i * 8
            draw.rectangle([cx, label_y, cx + 6, label_y + 10], fill=(200, 200, 210))

        # Score line
        score_y = label_y + 14
        for i, char in enumerate(score_text):
            cx = cell_x + 10 + i * 8
            color = (100, 255, 100) if score.overall >= 0.95 else (255, 200, 100) if score.overall >= 0.85 else (255, 100, 100)
            draw.rectangle([cx, score_y, cx + 6, score_y + 8], fill=color)

        x_offset += cell_width + padding

    return comparison


def main():
    print("Creating pickaxe comparison image...")

    designs = create_all_designs()
    print(f"Generated {len(designs)} designs")

    comparison = create_comparison_image(designs, scale=6)

    output_path = OUTPUT_DIR / "pickaxe_comparison.png"
    comparison.save(output_path)
    print(f"Saved comparison to: {output_path}")

    # Also print scores
    print("\n" + "="*60)
    print("PICKAXE DESIGN SCORES")
    print("="*60)

    for name, pickaxe in designs.items():
        temp_path = COMPONENTS_DIR / "pickaxe_temp.png"
        pickaxe.save(temp_path)
        score = validate_pickaxe(temp_path)
        temp_path.unlink()

        print(f"\n{name}:")
        print(f"  Overall: {score.overall:.2f}")
        print(f"  Silhouette: {score.silhouette_clarity:.2f}")
        print(f"  Ratio: {score.handle_head_ratio:.2f}")
        print(f"  Colors: {score.color_separation:.2f}")
        print(f"  Vertical: {score.vertical_extent:.2f}")


if __name__ == "__main__":
    main()
