#!/opt/homebrew/bin/python3.11
"""
Improved Composable Sprite Builder - Iteration 2

Further improvements:
- Better pixel density on body (fill gaps)
- Add subtle outline to components for definition
- Improved belt and boot detail
- Better arm muscle definition
- More detailed pickaxe
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

# Enhanced pixel art palette
COLORS = {
    # Skin tones
    "skin_highlight": (255, 218, 185),
    "skin": (228, 180, 140),
    "skin_shadow": (180, 130, 100),
    "skin_deep_shadow": (150, 100, 75),

    # Jeans
    "jeans_highlight": (80, 100, 160),
    "jeans": (60, 80, 140),
    "jeans_shadow": (35, 50, 100),
    "jeans_deep": (25, 35, 70),

    # Shirt
    "shirt_highlight": (100, 100, 110),
    "shirt": (75, 75, 85),
    "shirt_shadow": (50, 50, 60),
    "shirt_deep": (35, 35, 45),

    # Wood
    "wood_highlight": (180, 120, 60),
    "wood": (139, 90, 43),
    "wood_shadow": (100, 60, 25),
    "wood_deep": (70, 40, 15),

    # Metal
    "metal_highlight": (220, 220, 230),
    "metal": (150, 150, 160),
    "metal_shadow": (90, 90, 100),
    "metal_deep": (50, 50, 60),

    # Leather
    "leather_highlight": (80, 55, 40),
    "leather": (55, 40, 30),
    "leather_shadow": (35, 25, 18),

    # Details
    "outline": (20, 20, 25),
    "eye_white": (250, 250, 250),
    "eye_pupil": (30, 30, 35),

    "transparent": (0, 0, 0, 0),
}


def create_body_component() -> Image.Image:
    """Create body with improved density and detail."""
    img = Image.new('RGBA', (52, 68), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # === TORSO - fuller shape ===
    # Back layer (shadow)
    draw.rectangle([14, 0, 38, 28], fill=COLORS["shirt_shadow"])

    # Main torso block
    draw.rectangle([16, 2, 36, 26], fill=COLORS["shirt"])

    # Shading - left side darker
    draw.rectangle([16, 2, 22, 26], fill=COLORS["shirt_shadow"])
    draw.rectangle([16, 2, 18, 26], fill=COLORS["shirt_deep"])

    # Highlight - right side
    draw.rectangle([30, 2, 36, 26], fill=COLORS["shirt_highlight"])

    # Shoulder masses
    draw.rectangle([10, 4, 16, 14], fill=COLORS["shirt_shadow"])
    draw.rectangle([36, 4, 42, 14], fill=COLORS["shirt"])
    draw.rectangle([38, 4, 42, 12], fill=COLORS["shirt_highlight"])

    # Neck/collar area
    draw.rectangle([22, 0, 30, 4], fill=COLORS["skin_shadow"])
    draw.rectangle([24, 0, 28, 3], fill=COLORS["skin"])

    # Chest detail (shirt folds)
    draw.line([(26, 8), (26, 20)], fill=COLORS["shirt_shadow"])
    draw.line([(28, 6), (32, 18)], fill=COLORS["shirt_highlight"])

    # === BELT - more detailed ===
    draw.rectangle([14, 26, 38, 32], fill=COLORS["leather"])
    draw.rectangle([14, 26, 20, 32], fill=COLORS["leather_shadow"])
    draw.rectangle([32, 26, 38, 32], fill=COLORS["leather_highlight"])

    # Belt buckle
    draw.rectangle([22, 27, 30, 31], fill=COLORS["metal"])
    draw.rectangle([24, 28, 28, 30], fill=COLORS["metal_highlight"])
    draw.rectangle([22, 30, 30, 31], fill=COLORS["metal_shadow"])

    # === LEGS - fuller with seams ===
    # Left leg
    draw.rectangle([14, 32, 26, 54], fill=COLORS["jeans"])
    draw.rectangle([14, 32, 18, 54], fill=COLORS["jeans_shadow"])
    draw.rectangle([14, 32, 16, 54], fill=COLORS["jeans_deep"])
    draw.rectangle([22, 32, 26, 54], fill=COLORS["jeans_highlight"])

    # Right leg
    draw.rectangle([26, 32, 38, 54], fill=COLORS["jeans"])
    draw.rectangle([26, 32, 30, 54], fill=COLORS["jeans_shadow"])
    draw.rectangle([34, 32, 38, 54], fill=COLORS["jeans_highlight"])

    # Knee details
    draw.rectangle([18, 40, 24, 44], fill=COLORS["jeans_highlight"])
    draw.rectangle([30, 40, 36, 44], fill=COLORS["jeans_highlight"])

    # Inner seam
    draw.line([(25, 32), (25, 54)], fill=COLORS["jeans_deep"])
    draw.line([(27, 32), (27, 54)], fill=COLORS["jeans_deep"])

    # === BOOTS - chunky work boots ===
    # Left boot
    draw.rectangle([12, 54, 27, 62], fill=COLORS["leather"])
    draw.rectangle([12, 54, 16, 62], fill=COLORS["leather_shadow"])
    draw.rectangle([22, 54, 27, 60], fill=COLORS["leather_highlight"])
    draw.rectangle([10, 58, 27, 62], fill=COLORS["outline"])  # Sole
    draw.rectangle([12, 60, 27, 62], fill=COLORS["leather_shadow"])  # Sole top

    # Right boot
    draw.rectangle([25, 54, 40, 62], fill=COLORS["leather"])
    draw.rectangle([25, 54, 30, 62], fill=COLORS["leather_shadow"])
    draw.rectangle([35, 54, 40, 60], fill=COLORS["leather_highlight"])
    draw.rectangle([25, 58, 42, 62], fill=COLORS["outline"])  # Sole
    draw.rectangle([25, 60, 40, 62], fill=COLORS["leather_shadow"])

    # Boot details (laces)
    for y in range(55, 58):
        draw.point((20, y), fill=COLORS["leather_shadow"])
        draw.point((33, y), fill=COLORS["leather_highlight"])

    return img


def create_head_component() -> Image.Image:
    """Create head with better facial definition."""
    img = Image.new('RGBA', (36, 36), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # === HEAD SHAPE - rounder, more defined ===
    # Shadow base
    draw.ellipse([4, 4, 32, 32], fill=COLORS["skin_shadow"])

    # Main head
    draw.ellipse([6, 4, 30, 30], fill=COLORS["skin"])

    # Highlight area (forehead and right cheek)
    draw.ellipse([12, 4, 28, 18], fill=COLORS["skin_highlight"])
    draw.ellipse([18, 10, 28, 24], fill=COLORS["skin_highlight"])

    # Brow ridge shadow
    draw.rectangle([8, 12, 26, 15], fill=COLORS["skin_shadow"])

    # === EYES ===
    # Left eye
    draw.rectangle([9, 15, 14, 20], fill=COLORS["eye_white"])
    draw.rectangle([10, 16, 13, 19], fill=COLORS["eye_pupil"])
    draw.point((11, 17), fill=COLORS["eye_white"])  # Highlight

    # Right eye
    draw.rectangle([18, 15, 23, 20], fill=COLORS["eye_white"])
    draw.rectangle([19, 16, 22, 19], fill=COLORS["eye_pupil"])
    draw.point((20, 17), fill=COLORS["eye_white"])  # Highlight

    # Eyebrows
    draw.rectangle([8, 13, 14, 15], fill=COLORS["skin_deep_shadow"])
    draw.rectangle([18, 13, 24, 15], fill=COLORS["skin_deep_shadow"])

    # === NOSE ===
    draw.rectangle([15, 18, 17, 23], fill=COLORS["skin_shadow"])
    draw.point((17, 22), fill=COLORS["skin_highlight"])
    draw.point((15, 22), fill=COLORS["skin_deep_shadow"])

    # === MOUTH ===
    draw.rectangle([12, 25, 20, 26], fill=COLORS["skin_shadow"])
    draw.rectangle([14, 26, 18, 27], fill=COLORS["skin_deep_shadow"])

    # === EAR ===
    draw.ellipse([27, 15, 32, 25], fill=COLORS["skin"])
    draw.ellipse([28, 17, 31, 23], fill=COLORS["skin_shadow"])

    # Jaw shadow
    draw.ellipse([8, 24, 24, 32], fill=COLORS["skin_shadow"])

    # Subtle stubble/shadow on jaw
    for x in range(10, 22, 2):
        for y in range(26, 30, 2):
            draw.point((x, y), fill=COLORS["skin_deep_shadow"])

    return img


def create_arm_component() -> Image.Image:
    """Create arm with muscle definition."""
    img = Image.new('RGBA', (44, 20), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # === UPPER ARM (SHIRT SLEEVE) ===
    # Base
    draw.rectangle([0, 6, 20, 16], fill=COLORS["shirt"])
    # Shadow (bottom)
    draw.rectangle([0, 12, 20, 16], fill=COLORS["shirt_shadow"])
    draw.rectangle([0, 14, 8, 16], fill=COLORS["shirt_deep"])
    # Highlight (top)
    draw.rectangle([4, 6, 20, 10], fill=COLORS["shirt_highlight"])

    # Sleeve hem
    draw.rectangle([18, 6, 20, 16], fill=COLORS["shirt_shadow"])

    # === FOREARM (SKIN) ===
    # Base
    draw.rectangle([20, 6, 36, 14], fill=COLORS["skin"])
    # Shadow
    draw.rectangle([20, 12, 36, 14], fill=COLORS["skin_shadow"])
    draw.rectangle([20, 6, 24, 14], fill=COLORS["skin_shadow"])
    # Highlight (muscle)
    draw.rectangle([26, 6, 34, 10], fill=COLORS["skin_highlight"])

    # Muscle definition
    draw.line([(28, 8), (32, 12)], fill=COLORS["skin_shadow"])

    # === HAND ===
    draw.rectangle([36, 5, 44, 15], fill=COLORS["skin"])
    draw.rectangle([38, 5, 44, 9], fill=COLORS["skin_highlight"])
    draw.rectangle([36, 11, 40, 15], fill=COLORS["skin_shadow"])

    # Fingers gripping
    draw.rectangle([40, 7, 44, 13], fill=COLORS["skin"])
    draw.rectangle([42, 8, 44, 12], fill=COLORS["skin_shadow"])

    # Wrist crease
    draw.line([(36, 7), (36, 13)], fill=COLORS["skin_shadow"])

    return img


def create_pickaxe_component() -> Image.Image:
    """Create detailed pickaxe."""
    img = Image.new('RGBA', (56, 26), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # === HANDLE ===
    # Main handle body
    draw.rectangle([0, 10, 36, 16], fill=COLORS["wood"])

    # Handle shading
    draw.rectangle([0, 10, 36, 12], fill=COLORS["wood_highlight"])
    draw.rectangle([0, 14, 36, 16], fill=COLORS["wood_shadow"])

    # Handle end cap
    draw.rectangle([0, 9, 4, 17], fill=COLORS["wood_shadow"])
    draw.rectangle([1, 10, 3, 16], fill=COLORS["wood_deep"])

    # Wood grain lines
    for x in range(6, 34, 5):
        draw.line([(x, 11), (x, 15)], fill=COLORS["wood_shadow"])
        draw.line([(x+1, 11), (x+1, 15)], fill=COLORS["wood_highlight"])

    # === PICKAXE HEAD ===
    # Main head mass
    draw.polygon([
        (34, 10), (40, 4), (52, 8), (56, 13), (52, 18), (40, 22), (34, 16)
    ], fill=COLORS["metal"])

    # Top face (highlight)
    draw.polygon([
        (36, 10), (42, 5), (52, 9), (48, 12), (36, 12)
    ], fill=COLORS["metal_highlight"])

    # Bottom face (shadow)
    draw.polygon([
        (36, 14), (42, 20), (52, 17), (48, 14), (36, 14)
    ], fill=COLORS["metal_shadow"])

    # Tip highlight (sharp edge)
    draw.line([(54, 10), (56, 13), (54, 16)], fill=(255, 255, 255))
    draw.line([(53, 11), (55, 13), (53, 15)], fill=COLORS["metal_highlight"])

    # Top spike
    draw.polygon([
        (38, 6), (44, 0), (48, 4), (42, 8)
    ], fill=COLORS["metal_shadow"])
    draw.polygon([
        (40, 4), (44, 1), (46, 4), (42, 6)
    ], fill=COLORS["metal"])
    draw.point((44, 1), fill=COLORS["metal_highlight"])

    # Bottom spike (smaller)
    draw.polygon([
        (38, 20), (44, 26), (48, 22), (42, 18)
    ], fill=COLORS["metal_deep"])
    draw.polygon([
        (40, 21), (44, 24), (46, 22), (42, 19)
    ], fill=COLORS["metal_shadow"])

    # Collar/attachment
    draw.ellipse([32, 9, 38, 17], fill=COLORS["metal_shadow"])
    draw.ellipse([33, 10, 37, 16], fill=COLORS["metal"])
    draw.ellipse([34, 11, 36, 15], fill=COLORS["wood"])

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
    body_y = FRAME_HEIGHT - body.height - 6 + body_offset[1]

    # Combine arm and pickaxe
    arm_pickaxe = Image.new('RGBA', (100, 30), COLORS["transparent"])
    arm_pickaxe.paste(arm, (0, 5), arm)
    arm_pickaxe.paste(pickaxe, (42, 2), pickaxe)

    pivot_x, pivot_y = 4, 15

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
    head_y = body_y - head.height + 12
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

    print("Generating improved components (v2)...")

    body = create_body_component()
    body.save(COMPONENTS_DIR / "body.png")
    print(f"  Saved: body.png ({body.size})")

    head = create_head_component()
    head.save(COMPONENTS_DIR / "head.png")
    print(f"  Saved: head.png ({head.size})")

    arm = create_arm_component()
    arm.save(COMPONENTS_DIR / "arm.png")
    print(f"  Saved: arm.png ({arm.size})")

    pickaxe = create_pickaxe_component()
    pickaxe.save(COMPONENTS_DIR / "pickaxe.png")
    print(f"  Saved: pickaxe.png ({pickaxe.size})")

    return body, head, arm, pickaxe


def build_sprite_sheet(body, head, arm, pickaxe) -> Image.Image:
    """Build sprite sheet."""
    num_frames = len(SWING_POSES)
    sheet = Image.new('RGBA', (FRAME_WIDTH * num_frames, FRAME_HEIGHT), COLORS["transparent"])

    print(f"\nAssembling {num_frames} frames...")

    for i, pose in enumerate(SWING_POSES):
        print(f"  Frame {i}: {pose['name']}")
        frame = assemble_frame(body, head, arm, pickaxe, pose["arm_angle"], pose["body_offset"])
        sheet.paste(frame, (i * FRAME_WIDTH, 0), frame)
        frame.save(COMPONENTS_DIR / f"frame_{i:02d}_{pose['name']}.png")

    return sheet


def main():
    print("=" * 60)
    print("IMPROVED SPRITE BUILDER - ITERATION 2")
    print("=" * 60)

    body, head, arm, pickaxe = generate_components()
    sheet = build_sprite_sheet(body, head, arm, pickaxe)

    output_path = OUTPUT_DIR / "miner_swing_composable.png"
    sheet.save(output_path)

    print(f"\n{'='*60}")
    print("BUILD COMPLETE")
    print(f"Sprite sheet: {output_path}")


if __name__ == "__main__":
    main()
