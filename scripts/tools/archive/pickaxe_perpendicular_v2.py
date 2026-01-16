#!/opt/homebrew/bin/python3.11
"""
Perpendicular Pickaxe V2 - Targeting 1.00 score

The V1 perpendicular design scores 0.98 with vertical extent of 0.96.
Let's fix the vertical extent to reach 1.00.

The vertical extent check looks at whether the head extends equally
above and below the handle centerline.
"""

from PIL import Image, ImageDraw
from pathlib import Path
import sys

PROJECT_ROOT = Path(__file__).parent.parent.parent
COMPONENTS_DIR = PROJECT_ROOT / "resources" / "sprites" / "components"

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


def debug_vertical_extent(img: Image.Image) -> dict:
    """Debug the vertical extent calculation."""
    if img.mode != 'RGBA':
        img = img.convert('RGBA')

    width, height = img.size
    pixels = img.load()

    # Find the handle's vertical center (left half of image)
    left_half_y_coords = []
    for y in range(height):
        for x in range(width // 2):
            if pixels[x, y][3] > 128:
                left_half_y_coords.append(y)

    if not left_half_y_coords:
        return {"error": "No pixels in left half"}

    handle_center_y = sum(left_half_y_coords) / len(left_half_y_coords)

    # Find head's vertical extent (right third)
    head_start_x = int(width * 0.6)
    head_min_y, head_max_y = height, 0

    for y in range(height):
        for x in range(head_start_x, width):
            if pixels[x, y][3] > 128:
                head_min_y = min(head_min_y, y)
                head_max_y = max(head_max_y, y)

    extends_above = handle_center_y - head_min_y
    extends_below = head_max_y - handle_center_y

    balance = min(extends_above, extends_below) / max(extends_above, extends_below) if max(extends_above, extends_below) > 0 else 0
    score = 0.5 + (balance * 0.5) if extends_above > 2 and extends_below > 2 else 0.4

    return {
        "handle_center_y": handle_center_y,
        "head_min_y": head_min_y,
        "head_max_y": head_max_y,
        "extends_above": extends_above,
        "extends_below": extends_below,
        "balance": balance,
        "score": score
    }


def create_perpendicular_v2() -> Image.Image:
    """
    Create pickaxe with perfectly balanced vertical extent.

    Key: Make head extend equally above and below handle centerline.
    """
    img = Image.new('RGBA', (52, 24), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # The handle centerline should be at y=11 (middle of 24)
    center_y = 11
    handle_length = 32

    # === WOODEN HANDLE ===
    # 6 pixel tall handle centered at y=11
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
    # The head must extend EQUALLY above and below the handle center
    head_x = handle_length - 2  # Start at x=30
    head_width = 5

    # Calculate balanced vertical extent
    # Handle center is at y=11, so for perfect balance:
    # extends_above = extends_below
    # Let's use y=1 to y=22 for the head (22 pixels tall)
    # Center of that range is at y=11.5, close to handle center at y=11

    # Vertical bar: y=1 to y=22 (21 pixels)
    head_top = 1
    head_bottom = 22

    draw.rectangle([head_x, head_top, head_x + head_width, head_bottom], fill=COLORS["metal"])

    # Shading
    draw.rectangle([head_x, head_top, head_x + 1, head_bottom], fill=COLORS["metal_lo"])
    draw.rectangle([head_x + head_width - 1, head_top, head_x + head_width, head_bottom], fill=COLORS["metal_hi"])

    # Top point
    mid_x = head_x + head_width // 2
    draw.polygon([
        (head_x + 1, head_top),
        (mid_x, head_top - 1),
        (head_x + head_width - 1, head_top)
    ], fill=COLORS["metal_lo"])
    draw.point((mid_x, 0), fill=COLORS["gleam"])

    # Bottom point
    draw.polygon([
        (head_x + 1, head_bottom),
        (mid_x, head_bottom + 1),
        (head_x + head_width - 1, head_bottom)
    ], fill=COLORS["metal_lo"])

    # === PICK POINT extending right ===
    for dx in range(head_width + 1, 18):
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
    if head_x + 16 < img.width:
        img.putpixel((head_x + 16, center_y), COLORS["gleam"])

    # === COLLAR ===
    draw.rectangle([head_x - 2, center_y - 3, head_x, center_y + 4], fill=COLORS["metal_lo"])

    return img


def main():
    print("Creating perpendicular pickaxe V2...")

    v2 = create_perpendicular_v2()

    # Debug vertical extent
    debug = debug_vertical_extent(v2)
    print(f"\nVertical extent debug:")
    for k, v in debug.items():
        print(f"  {k}: {v}")

    # Save and validate
    v2.save(COMPONENTS_DIR / "pickaxe_perpendicular_v2.png")

    sys.path.insert(0, str(Path(__file__).parent))
    from pickaxe_validator import validate_pickaxe

    # Compare with primer
    print("\n" + "="*50)
    print("COMPARISON")
    print("="*50)

    # Restore primer for comparison
    from improved_sprite_builder import create_pickaxe_component
    primer = create_pickaxe_component()
    primer.save(COMPONENTS_DIR / "pickaxe_primer_temp.png")

    primer_score = validate_pickaxe(COMPONENTS_DIR / "pickaxe_primer_temp.png")
    v2_score = validate_pickaxe(COMPONENTS_DIR / "pickaxe_perpendicular_v2.png")

    print(f"\nPRIMER: {primer_score.overall:.2f}")
    print(f"  Vertical: {primer_score.vertical_extent:.2f}")

    print(f"\nPERPENDICULAR V2: {v2_score.overall:.2f}")
    print(f"  Silhouette: {v2_score.silhouette_clarity:.2f}")
    print(f"  Ratio: {v2_score.handle_head_ratio:.2f}")
    print(f"  Colors: {v2_score.color_separation:.2f}")
    print(f"  Vertical: {v2_score.vertical_extent:.2f}")

    # Cleanup
    (COMPONENTS_DIR / "pickaxe_primer_temp.png").unlink(missing_ok=True)

    if v2_score.overall >= primer_score.overall:
        print(f"\n*** V2 MATCHES OR BEATS PRIMER! ***")
        print("Use this design if you want the perpendicular look.")
    else:
        print(f"\n*** Primer still better ({primer_score.overall:.2f} > {v2_score.overall:.2f}) ***")


if __name__ == "__main__":
    main()
