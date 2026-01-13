#!/opt/homebrew/bin/python3.11
"""
Improved Composable Sprite Builder - Iteration 1

Improvements over baseline:
- Better proportions (larger character, more detail room)
- Enhanced shading with 3-tone approach (base, shadow, highlight)
- Cleaner pixel placement with anti-aliasing avoided
- Better color palette with more variation
- More detailed body and head
"""

from PIL import Image, ImageDraw
from pathlib import Path
import math

PROJECT_ROOT = Path(__file__).parent.parent.parent
SPRITES_DIR = PROJECT_ROOT / "resources" / "sprites"
COMPONENTS_DIR = SPRITES_DIR / "components"
OUTPUT_DIR = SPRITES_DIR

# Frame size
FRAME_WIDTH = 128
FRAME_HEIGHT = 128

# Enhanced pixel art palette with 3-tone shading
COLORS = {
    # Skin tones (3 levels)
    "skin_highlight": (255, 218, 185),
    "skin": (228, 180, 140),
    "skin_shadow": (180, 130, 100),

    # Jeans (3 levels)
    "jeans_highlight": (80, 100, 160),
    "jeans": (60, 80, 140),
    "jeans_shadow": (35, 50, 100),

    # Shirt (3 levels)
    "shirt_highlight": (100, 100, 110),
    "shirt": (75, 75, 85),
    "shirt_shadow": (50, 50, 60),

    # Pickaxe handle (wood)
    "wood_highlight": (180, 120, 60),
    "wood": (139, 90, 43),
    "wood_shadow": (100, 60, 25),

    # Pickaxe head (metal)
    "metal_highlight": (200, 200, 210),
    "metal": (120, 120, 130),
    "metal_shadow": (60, 60, 70),

    # Belt/boots
    "leather": (50, 35, 25),
    "leather_highlight": (70, 50, 35),

    # Outlines and details
    "outline": (25, 25, 30),
    "eye_white": (255, 255, 255),

    "transparent": (0, 0, 0, 0),
}


def create_body_component() -> Image.Image:
    """Create improved body (torso + legs) component with 3-tone shading."""
    # Larger canvas for more detail
    img = Image.new('RGBA', (52, 68), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # === TORSO ===
    # Main torso block with shading (light from right)
    # Shadow side (left)
    draw.rectangle([16, 2, 20, 26], fill=COLORS["shirt_shadow"])
    # Mid tone
    draw.rectangle([20, 2, 28, 26], fill=COLORS["shirt"])
    # Highlight side (right)
    draw.rectangle([28, 2, 34, 26], fill=COLORS["shirt_highlight"])

    # Shoulder areas
    draw.rectangle([12, 4, 16, 12], fill=COLORS["shirt_shadow"])
    draw.rectangle([34, 4, 38, 12], fill=COLORS["shirt_highlight"])

    # Collar detail
    draw.rectangle([22, 2, 28, 5], fill=COLORS["skin_shadow"])

    # === BELT ===
    draw.rectangle([16, 26, 34, 30], fill=COLORS["leather"])
    draw.rectangle([28, 26, 34, 30], fill=COLORS["leather_highlight"])
    # Belt buckle
    draw.rectangle([23, 27, 27, 29], fill=COLORS["metal_highlight"])

    # === LEGS ===
    # Left leg (in shadow)
    draw.rectangle([16, 30, 24, 52], fill=COLORS["jeans_shadow"])
    draw.rectangle([18, 30, 24, 52], fill=COLORS["jeans"])

    # Right leg (in light)
    draw.rectangle([26, 30, 34, 52], fill=COLORS["jeans"])
    draw.rectangle([30, 30, 34, 52], fill=COLORS["jeans_highlight"])

    # Knee highlights
    draw.rectangle([20, 38, 22, 41], fill=COLORS["jeans_highlight"])
    draw.rectangle([30, 38, 32, 41], fill=COLORS["jeans_highlight"])

    # === BOOTS ===
    # Left boot
    draw.rectangle([14, 52, 25, 58], fill=COLORS["leather"])
    draw.rectangle([14, 52, 17, 58], fill=COLORS["outline"])
    # Right boot
    draw.rectangle([25, 52, 36, 58], fill=COLORS["leather"])
    draw.rectangle([33, 52, 36, 58], fill=COLORS["leather_highlight"])

    # Boot soles
    draw.rectangle([14, 56, 25, 58], fill=COLORS["outline"])
    draw.rectangle([25, 56, 36, 58], fill=COLORS["outline"])

    return img


def create_head_component() -> Image.Image:
    """Create improved head component with better facial features."""
    img = Image.new('RGBA', (36, 36), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # === HEAD SHAPE ===
    # Base head (bald, oval shape)
    # Shadow side
    draw.ellipse([4, 4, 16, 32], fill=COLORS["skin_shadow"])
    # Main
    draw.ellipse([8, 4, 28, 32], fill=COLORS["skin"])
    # Highlight
    draw.ellipse([16, 4, 30, 28], fill=COLORS["skin_highlight"])

    # Top of head highlight
    draw.ellipse([12, 4, 24, 14], fill=COLORS["skin_highlight"])

    # === FACIAL FEATURES ===
    # Eyes (with whites)
    # Left eye
    draw.rectangle([10, 14, 14, 19], fill=COLORS["eye_white"])
    draw.rectangle([11, 15, 13, 18], fill=COLORS["outline"])
    # Right eye
    draw.rectangle([18, 14, 22, 19], fill=COLORS["eye_white"])
    draw.rectangle([19, 15, 21, 18], fill=COLORS["outline"])

    # Eyebrows
    draw.rectangle([9, 12, 14, 14], fill=COLORS["skin_shadow"])
    draw.rectangle([18, 12, 23, 14], fill=COLORS["skin_shadow"])

    # Nose
    draw.rectangle([15, 18, 17, 22], fill=COLORS["skin_shadow"])
    draw.point((17, 21), fill=COLORS["skin_highlight"])

    # Mouth
    draw.rectangle([13, 24, 19, 25], fill=COLORS["skin_shadow"])
    draw.point((16, 24), fill=COLORS["outline"])

    # === EAR ===
    draw.rectangle([27, 16, 31, 24], fill=COLORS["skin"])
    draw.rectangle([28, 18, 30, 22], fill=COLORS["skin_shadow"])

    # Chin shadow
    draw.ellipse([10, 26, 22, 32], fill=COLORS["skin_shadow"])

    return img


def create_arm_component() -> Image.Image:
    """Create improved arm component with better shading."""
    # Arm pointing RIGHT (0 degrees)
    img = Image.new('RGBA', (44, 18), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # === UPPER ARM (SHIRT) ===
    # Shadow
    draw.rectangle([0, 5, 6, 13], fill=COLORS["shirt_shadow"])
    # Main
    draw.rectangle([6, 4, 18, 14], fill=COLORS["shirt"])
    # Highlight
    draw.rectangle([12, 4, 18, 8], fill=COLORS["shirt_highlight"])

    # === FOREARM (SKIN) ===
    # Shadow
    draw.rectangle([18, 5, 24, 13], fill=COLORS["skin_shadow"])
    # Main
    draw.rectangle([24, 5, 36, 13], fill=COLORS["skin"])
    # Highlight
    draw.rectangle([30, 5, 36, 9], fill=COLORS["skin_highlight"])

    # === HAND ===
    draw.rectangle([36, 4, 42, 14], fill=COLORS["skin"])
    draw.rectangle([38, 4, 42, 8], fill=COLORS["skin_highlight"])
    # Fingers
    draw.rectangle([40, 6, 44, 12], fill=COLORS["skin"])
    draw.rectangle([40, 8, 44, 10], fill=COLORS["skin_shadow"])

    # Wrist line
    draw.line([(36, 5), (36, 13)], fill=COLORS["skin_shadow"])

    return img


def create_pickaxe_component() -> Image.Image:
    """Create improved pickaxe component with detailed metal head."""
    img = Image.new('RGBA', (52, 24), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # === HANDLE ===
    # Shadow side
    draw.rectangle([0, 10, 34, 12], fill=COLORS["wood_shadow"])
    # Main
    draw.rectangle([0, 8, 34, 10], fill=COLORS["wood"])
    # Highlight
    draw.rectangle([0, 6, 34, 8], fill=COLORS["wood_highlight"])

    # Handle grip texture
    for x in range(2, 32, 4):
        draw.line([(x, 7), (x, 11)], fill=COLORS["wood_shadow"])

    # === PICKAXE HEAD ===
    # Main head shape (pointed on both ends)
    head_points = [
        (32, 8),   # Left attachment
        (38, 2),   # Upper left
        (48, 6),   # Upper right point
        (52, 10),  # Far right tip
        (48, 14),  # Lower right
        (38, 18),  # Lower left
        (32, 12),  # Left attachment bottom
    ]
    draw.polygon(head_points, fill=COLORS["metal"])

    # Top highlight
    draw.polygon([
        (34, 8), (40, 3), (48, 7), (42, 10), (34, 10)
    ], fill=COLORS["metal_highlight"])

    # Bottom shadow
    draw.polygon([
        (34, 12), (40, 16), (48, 13), (42, 11), (34, 11)
    ], fill=COLORS["metal_shadow"])

    # Sharp edge highlight on tip
    draw.line([(50, 8), (52, 10), (50, 12)], fill=(255, 255, 255))

    # Top spike detail
    draw.polygon([
        (36, 4), (40, 0), (44, 4), (40, 6)
    ], fill=COLORS["metal_shadow"])
    draw.line([(38, 2), (42, 2)], fill=COLORS["metal_highlight"])

    # Attachment ring
    draw.ellipse([30, 7, 34, 13], fill=COLORS["metal_shadow"])
    draw.ellipse([31, 8, 33, 12], fill=COLORS["wood"])

    return img


def rotate_image(img: Image.Image, angle: float, center: tuple = None) -> Image.Image:
    """Rotate image around a point, expanding canvas as needed."""
    if center is None:
        center = (img.width // 2, img.height // 2)

    rotated = img.rotate(angle, resample=Image.Resampling.NEAREST,
                         expand=True, center=center)
    return rotated


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

    # Calculate positions (centered in frame)
    body_x = (FRAME_WIDTH - body.width) // 2 + body_offset[0]
    body_y = FRAME_HEIGHT - body.height - 8 + body_offset[1]

    # Combine arm and pickaxe, then rotate
    arm_pickaxe = Image.new('RGBA', (96, 28), COLORS["transparent"])
    arm_pickaxe.paste(arm, (0, 5), arm)
    arm_pickaxe.paste(pickaxe, (40, 2), pickaxe)

    # Rotate around the shoulder pivot point
    pivot_x, pivot_y = 4, 14

    rotated = arm_pickaxe.rotate(arm_angle, resample=Image.Resampling.NEAREST,
                                  expand=True, center=(pivot_x, pivot_y))

    # Shoulder attachment point on body
    shoulder_x = body_x + body.width - 14
    shoulder_y = body_y + 8

    # Calculate rotation offset
    angle_rad = math.radians(arm_angle)
    if arm_angle >= 0:
        offset_x = int(pivot_x * (1 - math.cos(angle_rad)) + pivot_y * math.sin(angle_rad))
        offset_y = int(pivot_y * (1 - math.cos(angle_rad)) - pivot_x * math.sin(angle_rad))
    else:
        offset_x = int(pivot_x * (1 - math.cos(angle_rad)) - pivot_y * math.sin(-angle_rad))
        offset_y = int(-pivot_x * math.sin(-angle_rad))

    arm_x = shoulder_x - pivot_x - offset_x
    arm_y = shoulder_y - pivot_y - offset_y

    # Layer based on arm position
    if arm_angle > 60:
        frame.paste(rotated, (arm_x, arm_y), rotated)
        frame.paste(body, (body_x, body_y), body)
    else:
        frame.paste(body, (body_x, body_y), body)
        frame.paste(rotated, (arm_x, arm_y), rotated)

    # Head always on top
    head_x = body_x + (body.width - head.width) // 2
    head_y = body_y - head.height + 10
    frame.paste(head, (head_x, head_y), head)

    return frame


# Pose definitions for pickaxe swing animation
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

    print("Generating improved components...")

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
    """Build complete sprite sheet from components and poses."""
    num_frames = len(SWING_POSES)
    sheet_width = FRAME_WIDTH * num_frames
    sheet_height = FRAME_HEIGHT

    sheet = Image.new('RGBA', (sheet_width, sheet_height), COLORS["transparent"])

    print(f"\nAssembling {num_frames} frames...")

    for i, pose in enumerate(SWING_POSES):
        print(f"  Frame {i}: {pose['name']} (arm_angle={pose['arm_angle']}°)")

        frame = assemble_frame(
            body=body,
            head=head,
            arm=arm,
            pickaxe=pickaxe,
            arm_angle=pose["arm_angle"],
            body_offset=pose["body_offset"]
        )

        sheet.paste(frame, (i * FRAME_WIDTH, 0), frame)
        frame.save(COMPONENTS_DIR / f"frame_{i:02d}_{pose['name']}.png")

    return sheet


def main():
    print("=" * 60)
    print("IMPROVED COMPOSABLE SPRITE BUILDER - ITERATION 1")
    print("=" * 60)

    body, head, arm, pickaxe = generate_components()
    sheet = build_sprite_sheet(body, head, arm, pickaxe)

    output_path = OUTPUT_DIR / "miner_swing_composable.png"
    sheet.save(output_path)

    print(f"\n{'='*60}")
    print("BUILD COMPLETE")
    print(f"{'='*60}")
    print(f"Sprite sheet: {output_path}")
    print(f"Size: {sheet.size}")
    print(f"Frames: {len(SWING_POSES)}")


if __name__ == "__main__":
    main()
