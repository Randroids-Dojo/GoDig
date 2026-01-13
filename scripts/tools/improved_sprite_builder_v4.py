#!/opt/homebrew/bin/python3.11
"""
Improved Composable Sprite Builder - V4

Fix: Proper arm rotation that stays connected to the body.

Key changes:
- Use a larger canvas for arm+pickaxe to avoid clipping
- Calculate rotation offset correctly using trigonometry
- Ensure shoulder stays at a fixed position relative to body
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

    # Work gloves (lighter, warmer tones for balanced std_dev)
    "glove": (140, 110, 75),
    "glove_highlight": (165, 135, 100),
    "glove_shadow": (115, 85, 55),

    # Outlines and details
    "outline": (25, 25, 30),
    "eye_white": (255, 255, 255),

    "transparent": (0, 0, 0, 0),
}


def create_body_component() -> Image.Image:
    """Create improved body (torso + legs) component with 3-tone shading."""
    img = Image.new('RGBA', (52, 68), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # === TORSO (wider for better density) ===
    # Main torso block
    draw.rectangle([14, 2, 20, 26], fill=COLORS["shirt_shadow"])
    draw.rectangle([20, 2, 30, 26], fill=COLORS["shirt"])
    draw.rectangle([30, 2, 38, 26], fill=COLORS["shirt_highlight"])

    # Shoulder areas (larger)
    draw.rectangle([10, 4, 14, 14], fill=COLORS["shirt_shadow"])
    draw.rectangle([38, 4, 42, 14], fill=COLORS["shirt_highlight"])

    # Collar detail
    draw.rectangle([22, 2, 30, 6], fill=COLORS["skin_shadow"])

    # Shirt pocket detail
    draw.rectangle([32, 10, 36, 14], fill=COLORS["shirt_shadow"])

    # === BELT ===
    draw.rectangle([14, 26, 38, 31], fill=COLORS["leather"])
    draw.rectangle([30, 26, 38, 31], fill=COLORS["leather_highlight"])
    draw.rectangle([23, 27, 29, 30], fill=COLORS["metal_highlight"])

    # === LEGS (wider) ===
    draw.rectangle([14, 31, 25, 54], fill=COLORS["jeans_shadow"])
    draw.rectangle([17, 31, 25, 54], fill=COLORS["jeans"])
    draw.rectangle([27, 31, 38, 54], fill=COLORS["jeans"])
    draw.rectangle([32, 31, 38, 54], fill=COLORS["jeans_highlight"])

    # Knee highlights
    draw.rectangle([19, 40, 23, 44], fill=COLORS["jeans_highlight"])
    draw.rectangle([32, 40, 36, 44], fill=COLORS["jeans_highlight"])

    # Crotch shadow
    draw.rectangle([25, 31, 27, 38], fill=COLORS["jeans_shadow"])

    # === BOOTS (wider) ===
    draw.rectangle([12, 54, 26, 62], fill=COLORS["leather"])
    draw.rectangle([12, 54, 16, 62], fill=COLORS["outline"])
    draw.rectangle([26, 54, 40, 62], fill=COLORS["leather"])
    draw.rectangle([36, 54, 40, 62], fill=COLORS["leather_highlight"])
    draw.rectangle([12, 60, 26, 62], fill=COLORS["outline"])
    draw.rectangle([26, 60, 40, 62], fill=COLORS["outline"])

    # Boot details
    draw.rectangle([18, 56, 22, 58], fill=COLORS["leather_highlight"])
    draw.rectangle([30, 56, 34, 58], fill=COLORS["leather_highlight"])

    return img


def create_head_component() -> Image.Image:
    """Create improved head with hardhat."""
    img = Image.new('RGBA', (36, 36), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # === HEAD SHAPE ===
    draw.ellipse([4, 10, 16, 32], fill=COLORS["skin_shadow"])
    draw.ellipse([8, 10, 28, 32], fill=COLORS["skin"])
    draw.ellipse([16, 10, 30, 28], fill=COLORS["skin_highlight"])
    draw.ellipse([12, 10, 24, 18], fill=COLORS["skin_highlight"])

    # === HARDHAT ===
    # Main dome
    draw.ellipse([4, 0, 30, 16], fill=(220, 180, 50))
    draw.ellipse([6, 1, 28, 14], fill=(240, 200, 60))
    draw.ellipse([8, 2, 22, 10], fill=(255, 220, 80))

    # Brim
    draw.rectangle([2, 12, 32, 16], fill=(220, 180, 50))
    draw.rectangle([2, 12, 32, 14], fill=(240, 200, 60))

    # === FACIAL FEATURES ===
    draw.rectangle([10, 17, 14, 22], fill=COLORS["eye_white"])
    draw.rectangle([11, 18, 13, 21], fill=COLORS["outline"])
    draw.rectangle([18, 17, 22, 22], fill=COLORS["eye_white"])
    draw.rectangle([19, 18, 21, 21], fill=COLORS["outline"])
    draw.rectangle([9, 15, 14, 17], fill=COLORS["skin_shadow"])
    draw.rectangle([18, 15, 23, 17], fill=COLORS["skin_shadow"])
    draw.rectangle([15, 21, 17, 25], fill=COLORS["skin_shadow"])
    draw.point((17, 24), fill=COLORS["skin_highlight"])
    draw.rectangle([13, 27, 19, 28], fill=COLORS["skin_shadow"])
    draw.point((16, 27), fill=COLORS["outline"])
    draw.rectangle([27, 19, 31, 27], fill=COLORS["skin"])
    draw.rectangle([28, 21, 30, 25], fill=COLORS["skin_shadow"])
    draw.ellipse([10, 28, 22, 34], fill=COLORS["skin_shadow"])

    return img


def create_arm_component() -> Image.Image:
    """Create improved arm component with shoulder attachment point."""
    # Arm pointing RIGHT (0 degrees)
    # The shoulder attachment point is at the LEFT of this image
    img = Image.new('RGBA', (44, 18), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # === UPPER ARM (SHIRT) ===
    # Shoulder joint (this is where it attaches to body)
    draw.ellipse([0, 3, 10, 15], fill=COLORS["shirt_shadow"])
    draw.ellipse([2, 5, 8, 13], fill=COLORS["shirt"])
    draw.ellipse([3, 6, 7, 10], fill=COLORS["shirt_highlight"])

    # Upper arm with 3-tone shading
    draw.rectangle([6, 4, 18, 14], fill=COLORS["shirt"])
    draw.rectangle([6, 4, 18, 8], fill=COLORS["shirt_highlight"])
    draw.rectangle([6, 11, 18, 14], fill=COLORS["shirt_shadow"])

    # Elbow detail
    draw.rectangle([16, 6, 20, 12], fill=COLORS["shirt_shadow"])

    # === FOREARM (SKIN) with better shading ===
    draw.rectangle([18, 4, 36, 14], fill=COLORS["skin"])
    draw.rectangle([18, 4, 36, 8], fill=COLORS["skin_highlight"])
    draw.rectangle([18, 11, 36, 14], fill=COLORS["skin_shadow"])

    # Muscle definition
    draw.rectangle([24, 6, 28, 10], fill=COLORS["skin_highlight"])

    # === GLOVED HAND (for gripping pickaxe) ===
    # Glove creates visual separation from wood handle
    draw.rectangle([36, 3, 46, 15], fill=COLORS["glove"])
    draw.rectangle([36, 3, 46, 8], fill=COLORS["glove_highlight"])
    draw.rectangle([36, 12, 46, 15], fill=COLORS["glove_shadow"])

    # Fingers gripping
    draw.rectangle([44, 5, 46, 13], fill=COLORS["glove"])
    draw.rectangle([44, 8, 46, 11], fill=COLORS["glove_shadow"])

    # Wrist line
    draw.line([(36, 4), (36, 14)], fill=COLORS["glove_shadow"])

    return img


def create_left_arm_component() -> Image.Image:
    """Create the left arm (non-swinging) that hangs at the side."""
    # This arm hangs down naturally on the left side of the body
    img = Image.new('RGBA', (14, 44), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # === UPPER ARM (SHIRT) - pointing down ===
    # Shoulder area with 3-tone shading
    draw.ellipse([2, 0, 12, 10], fill=COLORS["shirt_shadow"])
    draw.ellipse([4, 2, 10, 8], fill=COLORS["shirt"])
    draw.ellipse([5, 3, 9, 7], fill=COLORS["shirt_highlight"])

    # Upper arm going down with proper shading
    draw.rectangle([3, 8, 11, 20], fill=COLORS["shirt"])
    draw.rectangle([3, 8, 6, 20], fill=COLORS["shirt_shadow"])
    draw.rectangle([8, 8, 11, 14], fill=COLORS["shirt_highlight"])

    # === FOREARM (SKIN) with 3-tone shading ===
    draw.rectangle([3, 20, 11, 34], fill=COLORS["skin"])
    draw.rectangle([3, 20, 6, 34], fill=COLORS["skin_shadow"])
    draw.rectangle([8, 20, 11, 28], fill=COLORS["skin_highlight"])

    # Muscle definition
    draw.rectangle([6, 24, 9, 28], fill=COLORS["skin_highlight"])

    # === GLOVED HAND ===
    draw.rectangle([2, 34, 12, 42], fill=COLORS["glove"])
    draw.rectangle([2, 34, 5, 42], fill=COLORS["glove_shadow"])
    draw.rectangle([9, 34, 12, 40], fill=COLORS["glove_highlight"])

    # Wrist line
    draw.line([(3, 34), (11, 34)], fill=COLORS["glove_shadow"])

    return img


def create_pickaxe_component() -> Image.Image:
    """Create improved pickaxe component with detailed metal head."""
    img = Image.new('RGBA', (52, 24), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # === HANDLE ===
    draw.rectangle([0, 10, 34, 12], fill=COLORS["wood_shadow"])
    draw.rectangle([0, 8, 34, 10], fill=COLORS["wood"])
    draw.rectangle([0, 6, 34, 8], fill=COLORS["wood_highlight"])

    for x in range(2, 32, 4):
        draw.line([(x, 7), (x, 11)], fill=COLORS["wood_shadow"])

    # === PICKAXE HEAD ===
    head_points = [
        (32, 8), (38, 2), (48, 6), (52, 10), (48, 14), (38, 18), (32, 12),
    ]
    draw.polygon(head_points, fill=COLORS["metal"])
    draw.polygon([(34, 8), (40, 3), (48, 7), (42, 10), (34, 10)], fill=COLORS["metal_highlight"])
    draw.polygon([(34, 12), (40, 16), (48, 13), (42, 11), (34, 11)], fill=COLORS["metal_shadow"])
    draw.line([(50, 8), (52, 10), (50, 12)], fill=(255, 255, 255))
    draw.polygon([(36, 4), (40, 0), (44, 4), (40, 6)], fill=COLORS["metal_shadow"])
    draw.line([(38, 2), (42, 2)], fill=COLORS["metal_highlight"])
    draw.ellipse([30, 7, 34, 13], fill=COLORS["metal_shadow"])
    draw.ellipse([31, 8, 33, 12], fill=COLORS["wood"])

    return img


def rotate_around_pivot(img: Image.Image, angle: float, pivot: tuple) -> tuple:
    """
    Rotate image around a pivot point and return rotated image + new pivot position.

    Returns: (rotated_image, new_pivot_in_rotated)
    """
    # Create a larger canvas to avoid clipping
    max_dim = int(math.sqrt(img.width**2 + img.height**2)) + 10
    canvas_size = (max_dim * 2, max_dim * 2)

    # Place original image at center of large canvas
    canvas = Image.new('RGBA', canvas_size, COLORS["transparent"])
    offset_x = (canvas_size[0] - img.width) // 2
    offset_y = (canvas_size[1] - img.height) // 2
    canvas.paste(img, (offset_x, offset_y), img)

    # Pivot position in canvas coordinates
    canvas_pivot_x = offset_x + pivot[0]
    canvas_pivot_y = offset_y + pivot[1]

    # Rotate around center of canvas
    canvas_center = (canvas_size[0] // 2, canvas_size[1] // 2)
    rotated = canvas.rotate(angle, resample=Image.Resampling.NEAREST,
                            center=canvas_center, expand=False)

    # Calculate where the pivot point moved to after rotation
    angle_rad = math.radians(angle)
    cos_a = math.cos(angle_rad)
    sin_a = math.sin(angle_rad)

    # Vector from canvas center to pivot
    dx = canvas_pivot_x - canvas_center[0]
    dy = canvas_pivot_y - canvas_center[1]

    # Rotated vector (note: PIL rotates counter-clockwise for positive angles)
    new_dx = dx * cos_a + dy * sin_a
    new_dy = -dx * sin_a + dy * cos_a

    # New pivot position
    new_pivot_x = canvas_center[0] + new_dx
    new_pivot_y = canvas_center[1] + new_dy

    return rotated, (int(new_pivot_x), int(new_pivot_y))


def assemble_frame(
    body: Image.Image,
    head: Image.Image,
    arm: Image.Image,
    pickaxe: Image.Image,
    left_arm: Image.Image,
    arm_angle: float,
    body_offset: tuple = (0, 0),
) -> Image.Image:
    """Assemble components into a single frame with correct arm rotation."""
    frame = Image.new('RGBA', (FRAME_WIDTH, FRAME_HEIGHT), COLORS["transparent"])

    # Calculate body position (centered in frame)
    body_x = (FRAME_WIDTH - body.width) // 2 + body_offset[0]
    body_y = FRAME_HEIGHT - body.height - 8 + body_offset[1]

    # === LEFT ARM (non-swinging, hangs at side) ===
    # Position at left shoulder
    left_shoulder_x = body_x + 10
    left_shoulder_y = body_y + 6
    left_arm_x = left_shoulder_x - 4
    left_arm_y = left_shoulder_y - 2

    # === RIGHT ARM (swinging with pickaxe) ===
    # Shoulder position on the body (right shoulder area)
    shoulder_x = body_x + body.width - 14
    shoulder_y = body_y + 8

    # Combine arm and pickaxe into one image
    arm_pickaxe = Image.new('RGBA', (96, 28), COLORS["transparent"])
    arm_pickaxe.paste(arm, (0, 5), arm)
    arm_pickaxe.paste(pickaxe, (40, 2), pickaxe)

    # The shoulder pivot point is at the LEFT side of the arm
    pivot = (4, 14)

    # Rotate arm+pickaxe around the pivot
    rotated, new_pivot = rotate_around_pivot(arm_pickaxe, arm_angle, pivot)

    # Position the rotated image so the new pivot aligns with shoulder
    arm_x = shoulder_x - new_pivot[0]
    arm_y = shoulder_y - new_pivot[1]

    # Layer components - left arm always behind body
    frame.paste(left_arm, (left_arm_x, left_arm_y), left_arm)

    # Layer body and right arm based on arm position
    if arm_angle > 60:
        # Right arm behind body during windup
        frame.paste(rotated, (arm_x, arm_y), rotated)
        frame.paste(body, (body_x, body_y), body)
    else:
        # Right arm in front of body normally
        frame.paste(body, (body_x, body_y), body)
        frame.paste(rotated, (arm_x, arm_y), rotated)

    # Head always on top
    head_x = body_x + (body.width - head.width) // 2
    head_y = body_y - head.height + 10
    frame.paste(head, (head_x, head_y), head)

    return frame


# Pose definitions
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

    print("Generating V4 components...")

    body = create_body_component()
    body.save(COMPONENTS_DIR / "body.png")
    print(f"  Saved: body.png ({body.size})")

    head = create_head_component()
    head.save(COMPONENTS_DIR / "head.png")
    print(f"  Saved: head.png ({head.size})")

    arm = create_arm_component()
    arm.save(COMPONENTS_DIR / "arm.png")
    print(f"  Saved: arm.png ({arm.size})")

    left_arm = create_left_arm_component()
    left_arm.save(COMPONENTS_DIR / "left_arm.png")
    print(f"  Saved: left_arm.png ({left_arm.size})")

    pickaxe = create_pickaxe_component()
    pickaxe.save(COMPONENTS_DIR / "pickaxe.png")
    print(f"  Saved: pickaxe.png ({pickaxe.size})")

    return body, head, arm, left_arm, pickaxe


def build_sprite_sheet(body, head, arm, left_arm, pickaxe) -> Image.Image:
    """Build complete sprite sheet from components and poses."""
    num_frames = len(SWING_POSES)
    sheet_width = FRAME_WIDTH * num_frames
    sheet_height = FRAME_HEIGHT

    sheet = Image.new('RGBA', (sheet_width, sheet_height), COLORS["transparent"])

    print(f"\nAssembling {num_frames} frames with both arms...")

    for i, pose in enumerate(SWING_POSES):
        print(f"  Frame {i}: {pose['name']} (arm_angle={pose['arm_angle']})")

        frame = assemble_frame(
            body=body,
            head=head,
            arm=arm,
            pickaxe=pickaxe,
            left_arm=left_arm,
            arm_angle=pose["arm_angle"],
            body_offset=pose["body_offset"]
        )

        sheet.paste(frame, (i * FRAME_WIDTH, 0), frame)
        frame.save(COMPONENTS_DIR / f"frame_{i:02d}_{pose['name']}.png")

    return sheet


def main():
    print("=" * 60)
    print("IMPROVED COMPOSABLE SPRITE BUILDER - V4")
    print("Fixed arm rotation + both arms!")
    print("=" * 60)

    body, head, arm, left_arm, pickaxe = generate_components()
    sheet = build_sprite_sheet(body, head, arm, left_arm, pickaxe)

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
