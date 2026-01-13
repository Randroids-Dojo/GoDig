#!/opt/homebrew/bin/python3.11
"""
Create OpenPose Reference Images for Animation

Generates stick figure pose images that can be used with ControlNet
to guide animation frame generation with consistent poses.

OpenPose keypoint format (COCO 18-point):
0: Nose, 1: Neck, 2: RShoulder, 3: RElbow, 4: RWrist
5: LShoulder, 6: LElbow, 7: LWrist, 8: RHip, 9: RKnee
10: RAnkle, 11: LHip, 12: LKnee, 13: LAnkle, 14: REye
15: LEye, 16: REar, 17: LEar
"""

from PIL import Image, ImageDraw
from pathlib import Path
import math

OUTPUT_DIR = Path("resources/sprites/pose_references")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Image dimensions
WIDTH = 512
HEIGHT = 512

# Colors for different body parts
COLORS = {
    "body": (255, 0, 0),      # Red
    "left_arm": (0, 255, 0),  # Green
    "right_arm": (0, 0, 255), # Blue
    "left_leg": (255, 255, 0),# Yellow
    "right_leg": (255, 0, 255),# Magenta
    "head": (0, 255, 255),    # Cyan
}

# Line thickness
LINE_WIDTH = 8
POINT_RADIUS = 6


def draw_pose(draw, keypoints, connections, colors):
    """Draw OpenPose skeleton on image."""
    # Draw connections (limbs)
    for conn, color in connections:
        p1, p2 = conn
        if keypoints[p1] and keypoints[p2]:
            x1, y1 = keypoints[p1]
            x2, y2 = keypoints[p2]
            draw.line([(x1, y1), (x2, y2)], fill=color, width=LINE_WIDTH)

    # Draw keypoints
    for point in keypoints:
        if point:
            x, y = point
            draw.ellipse(
                [(x - POINT_RADIUS, y - POINT_RADIUS),
                 (x + POINT_RADIUS, y + POINT_RADIUS)],
                fill=(255, 255, 255)
            )


def create_pose_image(keypoints, filename):
    """Create and save a pose reference image."""
    img = Image.new('RGB', (WIDTH, HEIGHT), (0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Define connections with colors
    connections = [
        # Body
        ((0, 1), COLORS["head"]),     # Nose to Neck
        ((1, 8), COLORS["body"]),     # Neck to RHip
        ((1, 11), COLORS["body"]),    # Neck to LHip
        ((8, 11), COLORS["body"]),    # RHip to LHip

        # Right arm
        ((1, 2), COLORS["right_arm"]),  # Neck to RShoulder
        ((2, 3), COLORS["right_arm"]),  # RShoulder to RElbow
        ((3, 4), COLORS["right_arm"]),  # RElbow to RWrist

        # Left arm
        ((1, 5), COLORS["left_arm"]),   # Neck to LShoulder
        ((5, 6), COLORS["left_arm"]),   # LShoulder to LElbow
        ((6, 7), COLORS["left_arm"]),   # LElbow to LWrist

        # Right leg
        ((8, 9), COLORS["right_leg"]),   # RHip to RKnee
        ((9, 10), COLORS["right_leg"]),  # RKnee to RAnkle

        # Left leg
        ((11, 12), COLORS["left_leg"]),  # LHip to LKnee
        ((12, 13), COLORS["left_leg"]),  # LKnee to LAnkle
    ]

    draw_pose(draw, keypoints, connections, COLORS)

    output_path = OUTPUT_DIR / filename
    img.save(output_path, "PNG")
    print(f"Saved: {output_path}")
    return output_path


def lerp(a, b, t):
    """Linear interpolation between two points."""
    return (
        int(a[0] + (b[0] - a[0]) * t),
        int(a[1] + (b[1] - a[1]) * t)
    )


def rotate_point(point, center, angle_deg):
    """Rotate a point around a center by angle in degrees."""
    angle_rad = math.radians(angle_deg)
    cos_a, sin_a = math.cos(angle_rad), math.sin(angle_rad)
    dx, dy = point[0] - center[0], point[1] - center[1]
    return (
        int(center[0] + dx * cos_a - dy * sin_a),
        int(center[1] + dx * sin_a + dy * cos_a)
    )


def create_swing_animation_poses():
    """Create 8 poses for a pickaxe swing animation."""

    # Base body position (center of image, facing right)
    cx, cy = 256, 280  # Center body

    # Base skeleton positions
    base = {
        "nose": (cx + 10, cy - 90),
        "neck": (cx, cy - 70),
        "r_shoulder": (cx + 20, cy - 60),
        "l_shoulder": (cx - 20, cy - 60),
        "r_hip": (cx + 15, cy + 20),
        "l_hip": (cx - 15, cy + 20),
        "r_knee": (cx + 20, cy + 80),
        "l_knee": (cx - 20, cy + 80),
        "r_ankle": (cx + 25, cy + 140),
        "l_ankle": (cx - 25, cy + 140),
    }

    # Define 8 frames of swing animation
    # Arms will move from down (ready) -> up (wind-up) -> down (swing) -> follow through
    frames = []

    # Frame 0: Ready stance - arms down at sides
    frames.append({
        "name": "ready",
        "r_elbow": (cx + 40, cy - 30),
        "r_wrist": (cx + 50, cy + 10),  # Pickaxe down at side
        "l_elbow": (cx - 35, cy - 20),
        "l_wrist": (cx - 45, cy + 20),
        "crouch": 0,
    })

    # Frame 1: Start wind-up - arms beginning to raise
    frames.append({
        "name": "windup_1",
        "r_elbow": (cx + 50, cy - 50),
        "r_wrist": (cx + 70, cy - 30),
        "l_elbow": (cx - 30, cy - 40),
        "l_wrist": (cx - 20, cy - 50),
        "crouch": 5,
    })

    # Frame 2: Mid wind-up - arms at shoulder height
    frames.append({
        "name": "windup_2",
        "r_elbow": (cx + 50, cy - 80),
        "r_wrist": (cx + 80, cy - 70),
        "l_elbow": (cx - 20, cy - 60),
        "l_wrist": (cx + 20, cy - 80),
        "crouch": 10,
    })

    # Frame 3: Full wind-up - pickaxe raised high overhead
    frames.append({
        "name": "windup_full",
        "r_elbow": (cx + 30, cy - 110),
        "r_wrist": (cx + 60, cy - 140),  # High up
        "l_elbow": (cx, cy - 90),
        "l_wrist": (cx + 40, cy - 130),
        "crouch": 15,
    })

    # Frame 4: Start swing down
    frames.append({
        "name": "swing_start",
        "r_elbow": (cx + 50, cy - 80),
        "r_wrist": (cx + 90, cy - 60),
        "l_elbow": (cx + 10, cy - 70),
        "l_wrist": (cx + 70, cy - 50),
        "crouch": 10,
    })

    # Frame 5: Mid swing - pickaxe coming down
    frames.append({
        "name": "swing_mid",
        "r_elbow": (cx + 60, cy - 40),
        "r_wrist": (cx + 100, cy - 10),
        "l_elbow": (cx + 30, cy - 30),
        "l_wrist": (cx + 80, cy + 10),
        "crouch": 5,
    })

    # Frame 6: Low swing - about to hit
    frames.append({
        "name": "swing_low",
        "r_elbow": (cx + 60, cy),
        "r_wrist": (cx + 100, cy + 50),
        "l_elbow": (cx + 40, cy + 10),
        "l_wrist": (cx + 90, cy + 60),
        "crouch": 15,
    })

    # Frame 7: Impact - pickaxe at ground
    frames.append({
        "name": "impact",
        "r_elbow": (cx + 50, cy + 20),
        "r_wrist": (cx + 90, cy + 80),  # Near ground
        "l_elbow": (cx + 30, cy + 30),
        "l_wrist": (cx + 80, cy + 90),
        "crouch": 25,
    })

    # Generate pose images
    for i, frame in enumerate(frames):
        crouch = frame["crouch"]

        # Build keypoints array (18 points, COCO format)
        keypoints = [None] * 18

        # Head
        keypoints[0] = base["nose"]
        keypoints[1] = base["neck"]

        # Right arm
        keypoints[2] = base["r_shoulder"]
        keypoints[3] = frame["r_elbow"]
        keypoints[4] = frame["r_wrist"]

        # Left arm
        keypoints[5] = base["l_shoulder"]
        keypoints[6] = frame["l_elbow"]
        keypoints[7] = frame["l_wrist"]

        # Right leg (add crouch offset)
        keypoints[8] = base["r_hip"]
        keypoints[9] = (base["r_knee"][0], base["r_knee"][1] + crouch)
        keypoints[10] = (base["r_ankle"][0], base["r_ankle"][1] + crouch)

        # Left leg
        keypoints[11] = base["l_hip"]
        keypoints[12] = (base["l_knee"][0], base["l_knee"][1] + crouch)
        keypoints[13] = (base["l_ankle"][0], base["l_ankle"][1] + crouch)

        # Face points (optional)
        keypoints[14] = (base["nose"][0] + 8, base["nose"][1] - 5)  # REye
        keypoints[15] = (base["nose"][0] - 8, base["nose"][1] - 5)  # LEye

        create_pose_image(keypoints, f"pose_{i:02d}_{frame['name']}.png")

    print(f"\nGenerated {len(frames)} pose reference images in {OUTPUT_DIR}")


if __name__ == "__main__":
    create_swing_animation_poses()
