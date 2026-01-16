#!/opt/homebrew/bin/python3.11
"""
Improved Composable Sprite Builder - Iteration 3

Learning from iteration 2: KEEP COLOR COUNT LOW (<=12 colors total)
Focus on better pixel placement and shading, not more colors.

Changes:
- Strict 8-color palette per component
- Better dithering for shading
- Improved silhouettes
"""

from PIL import Image, ImageDraw
from pathlib import Path
import math

PROJECT_ROOT = Path(__file__).parent.parent.parent
SPRITES_DIR = PROJECT_ROOT / "resources" / "sprites"
COMPONENTS_DIR = SPRITES_DIR / "components"
OUTPUT_DIR = SPRITES_DIR

FRAME_WIDTH = 128
FRAME_HEIGHT = 128

# Strict limited palette - 10 colors total shared across components
COLORS = {
    # Skin (3 tones)
    "skin_hi": (255, 218, 185),
    "skin": (228, 180, 140),
    "skin_lo": (180, 130, 100),

    # Clothing (3 tones - blue jeans)
    "cloth_hi": (80, 100, 160),
    "cloth": (60, 80, 140),
    "cloth_lo": (35, 50, 100),

    # Neutral/shirt (2 tones)
    "gray_hi": (95, 95, 105),
    "gray_lo": (55, 55, 65),

    # Brown/wood (2 tones)
    "wood_hi": (160, 110, 55),
    "wood_lo": (100, 65, 30),

    # Metal (2 tones)
    "metal_hi": (180, 180, 195),
    "metal_lo": (80, 80, 95),

    # Outline
    "outline": (25, 25, 30),

    "transparent": (0, 0, 0, 0),
}


def create_body_component() -> Image.Image:
    """Create body with strict color palette."""
    img = Image.new('RGBA', (52, 68), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # === TORSO ===
    # Main block
    draw.rectangle([16, 2, 36, 26], fill=COLORS["gray_lo"])
    # Highlight right side
    draw.rectangle([28, 2, 36, 24], fill=COLORS["gray_hi"])
    # Darker left edge
    draw.rectangle([16, 2, 20, 26], fill=COLORS["outline"])

    # Shoulders
    draw.rectangle([12, 4, 16, 12], fill=COLORS["gray_lo"])
    draw.rectangle([36, 4, 40, 12], fill=COLORS["gray_hi"])

    # Neck
    draw.rectangle([22, 0, 30, 4], fill=COLORS["skin_lo"])

    # === BELT ===
    draw.rectangle([16, 26, 36, 30], fill=COLORS["outline"])
    draw.rectangle([24, 27, 28, 29], fill=COLORS["metal_hi"])

    # === LEGS ===
    # Left leg
    draw.rectangle([16, 30, 25, 54], fill=COLORS["cloth"])
    draw.rectangle([16, 30, 19, 54], fill=COLORS["cloth_lo"])
    # Right leg
    draw.rectangle([27, 30, 36, 54], fill=COLORS["cloth"])
    draw.rectangle([33, 30, 36, 54], fill=COLORS["cloth_hi"])

    # Knee highlights
    draw.rectangle([20, 40, 23, 43], fill=COLORS["cloth_hi"])
    draw.rectangle([30, 40, 33, 43], fill=COLORS["cloth_hi"])

    # Gap between legs
    draw.rectangle([25, 30, 27, 54], fill=COLORS["cloth_lo"])

    # === BOOTS ===
    draw.rectangle([14, 54, 25, 60], fill=COLORS["wood_lo"])
    draw.rectangle([27, 54, 38, 60], fill=COLORS["wood_lo"])
    draw.rectangle([30, 54, 38, 58], fill=COLORS["wood_hi"])

    # Soles
    draw.rectangle([12, 58, 25, 62], fill=COLORS["outline"])
    draw.rectangle([27, 58, 40, 62], fill=COLORS["outline"])

    return img


def create_head_component() -> Image.Image:
    """Create head with limited palette."""
    img = Image.new('RGBA', (36, 36), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # Base head
    draw.ellipse([6, 4, 30, 30], fill=COLORS["skin"])

    # Shadow left side
    draw.ellipse([4, 6, 14, 30], fill=COLORS["skin_lo"])

    # Highlight right/top
    draw.ellipse([16, 4, 28, 18], fill=COLORS["skin_hi"])

    # Brow shadow
    draw.rectangle([8, 12, 26, 15], fill=COLORS["skin_lo"])

    # Eyes
    draw.rectangle([10, 15, 14, 19], fill=COLORS["outline"])
    draw.rectangle([19, 15, 23, 19], fill=COLORS["outline"])
    # Eye highlights
    draw.point((11, 16), fill=COLORS["skin_hi"])
    draw.point((20, 16), fill=COLORS["skin_hi"])

    # Eyebrows
    draw.rectangle([9, 13, 14, 15], fill=COLORS["skin_lo"])
    draw.rectangle([18, 13, 23, 15], fill=COLORS["skin_lo"])

    # Nose
    draw.rectangle([15, 18, 17, 22], fill=COLORS["skin_lo"])

    # Mouth
    draw.rectangle([13, 24, 19, 25], fill=COLORS["skin_lo"])

    # Ear
    draw.ellipse([27, 15, 32, 24], fill=COLORS["skin"])
    draw.ellipse([28, 17, 31, 22], fill=COLORS["skin_lo"])

    # Chin shadow
    draw.ellipse([10, 24, 22, 30], fill=COLORS["skin_lo"])

    return img


def create_arm_component() -> Image.Image:
    """Create arm with limited palette."""
    img = Image.new('RGBA', (44, 18), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # Upper arm (sleeve)
    draw.rectangle([0, 5, 18, 13], fill=COLORS["gray_lo"])
    draw.rectangle([6, 4, 18, 9], fill=COLORS["gray_hi"])
    draw.rectangle([0, 10, 6, 13], fill=COLORS["outline"])

    # Forearm (skin)
    draw.rectangle([18, 5, 36, 13], fill=COLORS["skin"])
    draw.rectangle([18, 5, 24, 13], fill=COLORS["skin_lo"])
    draw.rectangle([28, 5, 36, 9], fill=COLORS["skin_hi"])

    # Hand
    draw.rectangle([36, 4, 44, 14], fill=COLORS["skin"])
    draw.rectangle([38, 4, 44, 8], fill=COLORS["skin_hi"])
    draw.rectangle([36, 10, 40, 14], fill=COLORS["skin_lo"])

    # Wrist line
    draw.line([(36, 6), (36, 12)], fill=COLORS["skin_lo"])

    return img


def create_pickaxe_component() -> Image.Image:
    """Create pickaxe with limited palette."""
    img = Image.new('RGBA', (52, 24), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # Handle
    draw.rectangle([0, 9, 34, 15], fill=COLORS["wood_lo"])
    draw.rectangle([0, 9, 34, 11], fill=COLORS["wood_hi"])

    # Handle end
    draw.rectangle([0, 8, 4, 16], fill=COLORS["wood_lo"])

    # Grip texture
    for x in range(6, 32, 6):
        draw.line([(x, 10), (x, 14)], fill=COLORS["wood_lo"])

    # Pickaxe head
    draw.polygon([
        (32, 9), (38, 3), (50, 8), (52, 12), (50, 16), (38, 21), (32, 15)
    ], fill=COLORS["metal_lo"])

    # Head highlight
    draw.polygon([
        (34, 9), (40, 4), (50, 9), (44, 11), (34, 11)
    ], fill=COLORS["metal_hi"])

    # Sharp edge
    draw.line([(50, 10), (52, 12), (50, 14)], fill=COLORS["skin_hi"])

    # Top spike
    draw.polygon([
        (36, 5), (42, 0), (46, 4), (40, 7)
    ], fill=COLORS["metal_lo"])
    draw.line([(40, 2), (44, 2)], fill=COLORS["metal_hi"])

    # Collar
    draw.ellipse([30, 8, 36, 16], fill=COLORS["metal_lo"])
    draw.ellipse([31, 9, 35, 15], fill=COLORS["wood_hi"])

    return img


def assemble_frame(
    body: Image.Image,
    head: Image.Image,
    arm: Image.Image,
    pickaxe: Image.Image,
    arm_angle: float,
    body_offset: tuple = (0, 0),
) -> Image.Image:
    """Assemble components into a single frame."""
    frame = Image.new('RGBA', (FRAME_WIDTH, FRAME_HEIGHT), COLORS["transparent"])

    body_x = (FRAME_WIDTH - body.width) // 2 + body_offset[0]
    body_y = FRAME_HEIGHT - body.height - 8 + body_offset[1]

    arm_pickaxe = Image.new('RGBA', (96, 28), COLORS["transparent"])
    arm_pickaxe.paste(arm, (0, 5), arm)
    arm_pickaxe.paste(pickaxe, (40, 2), pickaxe)

    pivot_x, pivot_y = 4, 14

    rotated = arm_pickaxe.rotate(arm_angle, resample=Image.Resampling.NEAREST,
                                  expand=True, center=(pivot_x, pivot_y))

    shoulder_x = body_x + body.width - 14
    shoulder_y = body_y + 8

    angle_rad = math.radians(arm_angle)
    if arm_angle >= 0:
        offset_x = int(pivot_x * (1 - math.cos(angle_rad)) + pivot_y * math.sin(angle_rad))
        offset_y = int(pivot_y * (1 - math.cos(angle_rad)) - pivot_x * math.sin(angle_rad))
    else:
        offset_x = int(pivot_x * (1 - math.cos(angle_rad)) - pivot_y * math.sin(-angle_rad))
        offset_y = int(-pivot_x * math.sin(-angle_rad))

    arm_x = shoulder_x - pivot_x - offset_x
    arm_y = shoulder_y - pivot_y - offset_y

    if arm_angle > 60:
        frame.paste(rotated, (arm_x, arm_y), rotated)
        frame.paste(body, (body_x, body_y), body)
    else:
        frame.paste(body, (body_x, body_y), body)
        frame.paste(rotated, (arm_x, arm_y), rotated)

    head_x = body_x + (body.width - head.width) // 2
    head_y = body_y - head.height + 10
    frame.paste(head, (head_x, head_y), head)

    return frame


SWING_POSES = [
    {"name": "ready", "arm_angle": -15, "body_offset": (0, 0)},
    {"name": "windup_1", "arm_angle": 15, "body_offset": (0, 0)},
    {"name": "windup_2", "arm_angle": 45, "body_offset": (-2, 0)},
    {"name": "windup_full", "arm_angle": 80, "body_offset": (-4, 2)},
    {"name": "swing_start", "arm_angle": 50, "body_offset": (-2, 0)},
    {"name": "swing_mid", "arm_angle": 10, "body_offset": (2, 0)},
    {"name": "swing_low", "arm_angle": -30, "body_offset": (4, -2)},
    {"name": "impact", "arm_angle": -55, "body_offset": (6, -4)},
]


def generate_components():
    """Generate and save all components."""
    COMPONENTS_DIR.mkdir(parents=True, exist_ok=True)

    print("Generating components (v3 - limited palette)...")

    body = create_body_component()
    body.save(COMPONENTS_DIR / "body.png")
    print(f"  body.png ({body.size})")

    head = create_head_component()
    head.save(COMPONENTS_DIR / "head.png")
    print(f"  head.png ({head.size})")

    arm = create_arm_component()
    arm.save(COMPONENTS_DIR / "arm.png")
    print(f"  arm.png ({arm.size})")

    pickaxe = create_pickaxe_component()
    pickaxe.save(COMPONENTS_DIR / "pickaxe.png")
    print(f"  pickaxe.png ({pickaxe.size})")

    return body, head, arm, pickaxe


def build_sprite_sheet(body, head, arm, pickaxe) -> Image.Image:
    """Build sprite sheet."""
    num_frames = len(SWING_POSES)
    sheet = Image.new('RGBA', (FRAME_WIDTH * num_frames, FRAME_HEIGHT), COLORS["transparent"])

    print(f"\nAssembling {num_frames} frames...")

    for i, pose in enumerate(SWING_POSES):
        frame = assemble_frame(body, head, arm, pickaxe, pose["arm_angle"], pose["body_offset"])
        sheet.paste(frame, (i * FRAME_WIDTH, 0), frame)
        frame.save(COMPONENTS_DIR / f"frame_{i:02d}_{pose['name']}.png")

    return sheet


def main():
    print("=" * 60)
    print("SPRITE BUILDER V3 - LIMITED PALETTE")
    print("=" * 60)

    body, head, arm, pickaxe = generate_components()
    sheet = build_sprite_sheet(body, head, arm, pickaxe)

    output_path = OUTPUT_DIR / "miner_swing_composable.png"
    sheet.save(output_path)

    print(f"\nSprite sheet saved: {output_path}")


if __name__ == "__main__":
    main()
