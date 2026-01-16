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
    """Create body (torso + legs) with optimized 8-color palette.

    Enlarged collar/neck area to increase luminance variance (std dev >= 25).
    """
    img = Image.new('RGBA', (52, 68), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # Using 2-tone shading to stay within 8 colors total:
    # shirt (2), jeans (2), leather (2), skin (1), outline (1) = 8

    # === TORSO (2-tone shirt) ===
    draw.rectangle([14, 2, 26, 26], fill=COLORS["shirt_shadow"])
    draw.rectangle([26, 2, 38, 26], fill=COLORS["shirt"])

    # Shoulder areas
    draw.rectangle([10, 4, 14, 14], fill=COLORS["shirt_shadow"])
    draw.rectangle([38, 4, 42, 14], fill=COLORS["shirt"])

    # Enlarged collar/neck area (V-neck style for more skin visibility)
    # This adds ~50 more skin pixels to increase shading variance
    draw.rectangle([20, 0, 32, 6], fill=COLORS["skin_shadow"])
    draw.polygon([(22, 6), (26, 12), (30, 6)], fill=COLORS["skin_shadow"])

    # === BELT ===
    draw.rectangle([14, 26, 38, 31], fill=COLORS["leather"])
    draw.rectangle([23, 27, 29, 30], fill=COLORS["leather_highlight"])

    # === LEGS (2-tone jeans) ===
    draw.rectangle([14, 31, 25, 54], fill=COLORS["jeans_shadow"])
    draw.rectangle([27, 31, 38, 54], fill=COLORS["jeans"])

    # Crotch shadow
    draw.rectangle([25, 31, 27, 38], fill=COLORS["jeans_shadow"])

    # === BOOTS (extended to bottom of body frame) ===
    draw.rectangle([12, 54, 26, 67], fill=COLORS["leather"])
    draw.rectangle([12, 54, 16, 67], fill=COLORS["outline"])
    draw.rectangle([26, 54, 40, 67], fill=COLORS["leather"])
    draw.rectangle([12, 65, 26, 67], fill=COLORS["outline"])  # Boot soles
    draw.rectangle([26, 65, 40, 67], fill=COLORS["outline"])

    # Boot highlights
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
    """Create improved arm component with shoulder attachment point.

    Proportions exactly matched to left arm (11px thickness):
    - shirt (2): shirt, shirt_shadow
    - skin (3): skin_highlight, skin, skin_shadow
    - glove (3): glove_highlight, glove, glove_shadow
    """
    # Arm pointing RIGHT (0 degrees)
    # The shoulder attachment point is at the LEFT of this image
    # Thickness: 11 pixels (y=1 to y=11, matching left arm exactly)
    img = Image.new('RGBA', (42, 13), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # === UPPER ARM (SHIRT) - 2-tone shading ===
    # Shoulder joint (this is where it attaches to body)
    draw.ellipse([0, 1, 8, 11], fill=COLORS["shirt_shadow"])
    draw.ellipse([2, 3, 6, 9], fill=COLORS["shirt"])

    # Upper arm with 2-tone shading
    draw.rectangle([5, 1, 16, 10], fill=COLORS["shirt"])
    draw.rectangle([5, 8, 16, 10], fill=COLORS["shirt_shadow"])

    # Elbow detail
    draw.rectangle([14, 3, 18, 9], fill=COLORS["shirt_shadow"])

    # === FOREARM (SKIN) with shading ===
    draw.rectangle([16, 1, 32, 10], fill=COLORS["skin"])
    draw.rectangle([16, 1, 32, 4], fill=COLORS["skin_highlight"])
    draw.rectangle([16, 8, 32, 10], fill=COLORS["skin_shadow"])

    # Muscle definition
    draw.rectangle([22, 3, 26, 7], fill=COLORS["skin_highlight"])

    # === GLOVED HAND (for gripping pickaxe) ===
    # Slimmer glove to match arm proportions exactly
    draw.rectangle([32, 1, 41, 11], fill=COLORS["glove"])
    draw.rectangle([32, 1, 41, 5], fill=COLORS["glove_highlight"])
    draw.rectangle([32, 9, 41, 11], fill=COLORS["glove_shadow"])

    # Wrist line
    draw.line([(32, 2), (32, 10)], fill=COLORS["glove_shadow"])

    return img


def create_left_arm_component() -> Image.Image:
    """Create the left arm (non-swinging) that hangs at the side.

    Optimized to use 8 colors (2-tone shirt like body):
    - shirt (2): shirt, shirt_shadow
    - skin (3): skin_highlight, skin, skin_shadow
    - glove (3): glove_highlight, glove, glove_shadow
    """
    # This arm hangs down naturally on the left side of the body
    img = Image.new('RGBA', (14, 44), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # === UPPER ARM (SHIRT) - 2-tone shading ===
    # Shoulder area
    draw.ellipse([2, 0, 12, 10], fill=COLORS["shirt_shadow"])
    draw.ellipse([4, 2, 10, 8], fill=COLORS["shirt"])

    # Upper arm going down with 2-tone shading (matching body optimization)
    draw.rectangle([3, 8, 11, 20], fill=COLORS["shirt"])
    draw.rectangle([3, 8, 6, 20], fill=COLORS["shirt_shadow"])

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
    """Create compact perpendicular pickaxe - T-shape that fits in frame.

    Shortened design to prevent clipping when arm rotates.
    Total width: 36 pixels (26 handle + 10 head)
    """
    img = Image.new('RGBA', (36, 24), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # === WOODEN HANDLE ===
    handle_length = 24
    handle_top = 9
    handle_bottom = 14

    # Main handle with 3-tone shading
    draw.rectangle([0, handle_top, handle_length, handle_bottom], fill=COLORS["wood"])
    draw.rectangle([0, handle_top, handle_length, handle_top + 1], fill=COLORS["wood_highlight"])
    draw.rectangle([0, handle_bottom - 1, handle_length, handle_bottom], fill=COLORS["wood_shadow"])

    # Handle grip end
    draw.rectangle([0, handle_top - 1, 3, handle_bottom + 1], fill=COLORS["wood_shadow"])
    draw.rectangle([1, handle_top, 2, handle_bottom], fill=COLORS["wood"])

    # Wood grain lines
    for x in range(5, handle_length - 2, 4):
        draw.line([(x, handle_top + 1), (x, handle_bottom - 1)], fill=COLORS["wood_shadow"])

    # === PERPENDICULAR METAL HEAD (T-shape) ===
    head_x = handle_length - 2  # = 28
    head_width = 4
    head_top = 2
    head_bottom = 21

    # Vertical bar of the T
    draw.rectangle([head_x, head_top, head_x + head_width, head_bottom], fill=COLORS["metal"])
    draw.rectangle([head_x, head_top, head_x + 1, head_bottom], fill=COLORS["metal_shadow"])
    draw.rectangle([head_x + head_width - 1, head_top, head_x + head_width, head_bottom], fill=COLORS["metal_highlight"])

    # Top pointed tip
    top_center = head_x + head_width // 2
    draw.polygon([
        (head_x + 1, head_top),
        (top_center, 0),
        (head_x + head_width - 1, head_top)
    ], fill=COLORS["metal_shadow"])
    img.putpixel((top_center, 0), (255, 255, 255))  # Gleam on top

    # Bottom pointed tip
    draw.polygon([
        (head_x + 1, head_bottom),
        (top_center, 23),
        (head_x + head_width - 1, head_bottom)
    ], fill=COLORS["metal_shadow"])

    # === SHORT HORIZONTAL SPIKE (the pick point) ===
    handle_center = (handle_top + handle_bottom) // 2  # = 11
    spike_length = 8  # Short spike to fit in frame
    for dx in range(head_width, spike_length):
        x = head_x + dx
        if x >= img.width:
            break
        thickness = max(1, 2 - dx // 3)
        for dy in range(-thickness, thickness + 1):
            y = handle_center + dy
            if 0 <= y < img.height:
                if dy <= 0:
                    img.putpixel((x, y), COLORS["metal_highlight"])
                else:
                    img.putpixel((x, y), COLORS["metal_shadow"])

    # Sharp gleam at spike tip
    if head_x + spike_length - 1 < img.width:
        img.putpixel((head_x + spike_length - 1, handle_center), (255, 255, 255))

    # === COLLAR (where head meets handle) ===
    draw.rectangle([head_x - 2, handle_center - 3, head_x, handle_center + 3], fill=COLORS["metal_shadow"])

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

    # Calculate body position (shifted left to give room for pickaxe swing)
    # -24 offset moves body left so pickaxe head stays in frame
    body_x = (FRAME_WIDTH - body.width) // 2 - 24 + body_offset[0]
    # Position body so feet touch the bottom of the frame
    # body.height = 68, boots end at y=62 within body, so body_y should put feet at y=127
    body_y = FRAME_HEIGHT - body.height + body_offset[1]

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
    # Arm is 42x13, pickaxe is 36x24, combined with pickaxe at hand position
    arm_pickaxe = Image.new('RGBA', (70, 26), COLORS["transparent"])
    arm_pickaxe.paste(arm, (0, 7), arm)  # Arm centered vertically
    arm_pickaxe.paste(pickaxe, (34, 1), pickaxe)  # Pickaxe at hand position

    # The shoulder pivot point is at the LEFT side of the arm
    pivot = (4, 12)

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
