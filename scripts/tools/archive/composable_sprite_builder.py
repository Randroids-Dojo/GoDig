#!/opt/homebrew/bin/python3.11
"""
Composable Sprite Builder

Generates character components and assembles them into animation frames.
Output is a static sprite sheet - no runtime overhead.

Components:
- body: Torso and legs (static)
- head: Character head (static)
- arm: Arm that holds pickaxe (rotatable)
- pickaxe: Tool (attached to arm)

The assembly tool rotates/positions components per frame definition,
composites them, and outputs a final sprite sheet.
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

# Colors (pixel art palette)
COLORS = {
    "skin": (228, 180, 140),
    "skin_dark": (198, 150, 110),
    "jeans": (60, 80, 140),
    "jeans_dark": (40, 60, 110),
    "shirt": (80, 80, 90),
    "shirt_dark": (60, 60, 70),
    "pickaxe_handle": (139, 90, 43),
    "pickaxe_head": (60, 60, 65),
    "pickaxe_edge": (180, 180, 190),
    "outline": (30, 30, 35),
    "transparent": (0, 0, 0, 0),
}


def create_body_component() -> Image.Image:
    """Create the body (torso + legs) component."""
    # Larger canvas for the body
    img = Image.new('RGBA', (48, 64), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # Torso (shirt)
    # Main torso block
    draw.rectangle([16, 0, 31, 24], fill=COLORS["shirt"])
    draw.rectangle([17, 0, 30, 23], fill=COLORS["shirt"])
    # Darker side
    draw.rectangle([16, 0, 18, 24], fill=COLORS["shirt_dark"])

    # Shoulder areas (where arms attach)
    draw.rectangle([12, 2, 16, 10], fill=COLORS["shirt"])
    draw.rectangle([31, 2, 35, 10], fill=COLORS["shirt"])

    # Legs (jeans)
    # Left leg
    draw.rectangle([16, 24, 22, 48], fill=COLORS["jeans"])
    draw.rectangle([16, 24, 18, 48], fill=COLORS["jeans_dark"])
    # Right leg
    draw.rectangle([25, 24, 31, 48], fill=COLORS["jeans"])
    draw.rectangle([25, 24, 27, 48], fill=COLORS["jeans_dark"])

    # Feet
    draw.rectangle([14, 48, 23, 54], fill=COLORS["outline"])
    draw.rectangle([24, 48, 33, 54], fill=COLORS["outline"])

    # Belt
    draw.rectangle([16, 23, 31, 26], fill=COLORS["outline"])

    return img


def create_head_component() -> Image.Image:
    """Create the head component."""
    img = Image.new('RGBA', (32, 32), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # Head shape (bald)
    draw.ellipse([4, 4, 28, 28], fill=COLORS["skin"])
    # Darker side
    draw.ellipse([4, 4, 12, 28], fill=COLORS["skin_dark"])

    # Face features
    # Eyes
    draw.rectangle([18, 12, 21, 16], fill=COLORS["outline"])
    draw.rectangle([10, 12, 13, 16], fill=COLORS["outline"])

    # Simple mouth/expression line
    draw.line([12, 20, 20, 20], fill=COLORS["outline"], width=1)

    # Ear
    draw.rectangle([25, 14, 28, 20], fill=COLORS["skin_dark"])

    return img


def create_arm_component() -> Image.Image:
    """Create the arm component (upper arm + forearm as one piece)."""
    # Arm is drawn pointing RIGHT (0 degrees), will be rotated
    img = Image.new('RGBA', (40, 16), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # Upper arm (shoulder to elbow)
    draw.rectangle([0, 4, 18, 12], fill=COLORS["shirt"])
    draw.rectangle([0, 4, 4, 12], fill=COLORS["shirt_dark"])

    # Forearm (elbow to wrist) - skin
    draw.rectangle([18, 5, 36, 11], fill=COLORS["skin"])
    draw.rectangle([18, 5, 22, 11], fill=COLORS["skin_dark"])

    # Hand
    draw.rectangle([36, 4, 40, 12], fill=COLORS["skin"])

    return img


def create_pickaxe_component() -> Image.Image:
    """Create the pickaxe component."""
    img = Image.new('RGBA', (48, 20), COLORS["transparent"])
    draw = ImageDraw.Draw(img)

    # Handle (horizontal, pointing right)
    draw.rectangle([0, 8, 32, 12], fill=COLORS["pickaxe_handle"])
    draw.rectangle([0, 8, 32, 9], fill=COLORS["outline"])  # Top edge

    # Pickaxe head (at the end of handle)
    # Main head block
    draw.polygon([
        (32, 4), (44, 0), (48, 8), (44, 16), (32, 12)
    ], fill=COLORS["pickaxe_head"])

    # Sharp edge highlight
    draw.line([(44, 2), (48, 8), (44, 14)], fill=COLORS["pickaxe_edge"], width=2)

    # Point at top
    draw.polygon([(36, 4), (44, 0), (40, 6)], fill=COLORS["pickaxe_head"])

    return img


def rotate_image(img: Image.Image, angle: float, center: tuple = None) -> Image.Image:
    """Rotate image around a point, expanding canvas as needed."""
    if center is None:
        center = (img.width // 2, img.height // 2)

    # Rotate with expansion
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
    body_y = FRAME_HEIGHT - body.height - 10 + body_offset[1]

    # Combine arm and pickaxe, then rotate
    arm_pickaxe = Image.new('RGBA', (88, 24), COLORS["transparent"])
    arm_pickaxe.paste(arm, (0, 4), arm)
    arm_pickaxe.paste(pickaxe, (36, 2), pickaxe)

    # Rotate around the shoulder pivot point (left edge of arm)
    # We need to calculate where the shoulder ends up after rotation
    pivot_x, pivot_y = 4, 12  # Shoulder position in arm_pickaxe image

    rotated = arm_pickaxe.rotate(arm_angle, resample=Image.Resampling.NEAREST,
                                  expand=True, center=(pivot_x, pivot_y))

    # Shoulder attachment point on body
    shoulder_x = body_x + body.width - 12
    shoulder_y = body_y + 6

    # Calculate rotation offset
    angle_rad = math.radians(arm_angle)
    # After rotation with expand, the pivot moves
    if arm_angle >= 0:
        offset_x = int(pivot_x * (1 - math.cos(angle_rad)) + pivot_y * math.sin(angle_rad))
        offset_y = int(pivot_y * (1 - math.cos(angle_rad)) - pivot_x * math.sin(angle_rad))
    else:
        offset_x = int(pivot_x * (1 - math.cos(angle_rad)) - pivot_y * math.sin(-angle_rad))
        offset_y = int(-pivot_x * math.sin(-angle_rad))

    arm_x = shoulder_x - pivot_x - offset_x
    arm_y = shoulder_y - pivot_y - offset_y

    # Paste arm BEHIND body for back positions, IN FRONT for forward positions
    if arm_angle > 60:
        # Arm behind body (wind-up)
        frame.paste(rotated, (arm_x, arm_y), rotated)
        frame.paste(body, (body_x, body_y), body)
    else:
        # Arm in front of body (swing)
        frame.paste(body, (body_x, body_y), body)
        frame.paste(rotated, (arm_x, arm_y), rotated)

    # Paste head (always on top)
    head_x = body_x + (body.width - head.width) // 2
    head_y = body_y - head.height + 8
    frame.paste(head, (head_x, head_y), head)

    return frame


# Pose definitions for pickaxe swing animation
# arm_angle: positive = up/back, negative = down/forward
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

    print("Generating components...")

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

        # Paste frame into sheet
        sheet.paste(frame, (i * FRAME_WIDTH, 0), frame)

        # Also save individual frame for inspection
        frame.save(COMPONENTS_DIR / f"frame_{i:02d}_{pose['name']}.png")

    return sheet


def main():
    print("=" * 60)
    print("COMPOSABLE SPRITE BUILDER")
    print("=" * 60)

    # Generate components
    body, head, arm, pickaxe = generate_components()

    # Build sprite sheet
    sheet = build_sprite_sheet(body, head, arm, pickaxe)

    # Save sprite sheet
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
