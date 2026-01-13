#!/opt/homebrew/bin/python3.11
"""
Animation Validator - LLM-based validation for sprite animations.

This module provides validation that the generated frames actually match
the intended animation, not just visual quality checks.

Validation Levels:
1. POSE VALIDATION - Does each frame match its expected pose?
2. SEQUENCE VALIDATION - Do the frames form a coherent animation?
3. MOTION VALIDATION - Is there actual movement between frames?
"""

from pathlib import Path
from dataclasses import dataclass
from enum import Enum
from typing import Optional
import json


class ValidationResult(Enum):
    PASS = "pass"
    FAIL = "fail"
    WARNING = "warning"


@dataclass
class PoseExpectation:
    """Expected pose for a frame."""
    frame_name: str
    description: str
    key_elements: list[str]  # What MUST be visible/positioned correctly
    pickaxe_position: str    # Where the pickaxe should be
    body_position: str       # Body posture expectation


@dataclass
class FrameValidation:
    """Validation result for a single frame."""
    frame_idx: int
    frame_name: str
    pose_correct: ValidationResult
    pose_issues: list[str]
    quality_score: float  # 0-1
    notes: str


@dataclass
class AnimationValidation:
    """Validation result for the entire animation."""
    frames: list[FrameValidation]
    sequence_valid: ValidationResult
    motion_detected: ValidationResult
    overall_result: ValidationResult
    summary: str
    recommendations: list[str]


# Define expected poses for pickaxe swing animation
SWING_ANIMATION_POSES = [
    PoseExpectation(
        frame_name="ready",
        description="Standing ready, pickaxe held at side or resting",
        key_elements=["pickaxe visible", "standing upright", "relaxed stance"],
        pickaxe_position="LOW - at side, near waist/hip level, or resting on shoulder",
        body_position="Standing straight, weight centered"
    ),
    PoseExpectation(
        frame_name="windup_1",
        description="Beginning wind-up, pickaxe starting to rise",
        key_elements=["pickaxe rising", "arms beginning to lift"],
        pickaxe_position="RISING - moving from low to mid height",
        body_position="Slight lean back, preparing for swing"
    ),
    PoseExpectation(
        frame_name="windup_2",
        description="Mid wind-up, pickaxe at shoulder height",
        key_elements=["pickaxe at shoulder level", "arms bent"],
        pickaxe_position="MID-HIGH - at or above shoulder level",
        body_position="Leaning back, coiling for power"
    ),
    PoseExpectation(
        frame_name="windup_full",
        description="Full wind-up, pickaxe raised overhead",
        key_elements=["pickaxe ABOVE head", "arms extended up"],
        pickaxe_position="HIGH - ABOVE the head, at peak of backswing",
        body_position="Leaning back, maximum coil"
    ),
    PoseExpectation(
        frame_name="swing_start",
        description="Beginning downswing, pickaxe starting to come down",
        key_elements=["pickaxe descending", "forward momentum"],
        pickaxe_position="DESCENDING - moving from overhead toward front",
        body_position="Starting to lean forward, weight shifting"
    ),
    PoseExpectation(
        frame_name="swing_mid",
        description="Mid-swing, pickaxe in front of body",
        key_elements=["pickaxe in front", "arms extended forward"],
        pickaxe_position="MID-FRONT - in front of body, around chest/waist height",
        body_position="Leaning forward, driving the swing"
    ),
    PoseExpectation(
        frame_name="swing_low",
        description="Low swing, pickaxe approaching ground",
        key_elements=["pickaxe low", "near ground level"],
        pickaxe_position="LOW-FRONT - below waist, approaching ground",
        body_position="Bent forward, following through"
    ),
    PoseExpectation(
        frame_name="impact",
        description="Impact, pickaxe at ground level",
        key_elements=["pickaxe at ground", "impact pose"],
        pickaxe_position="GROUND - at or near ground level, extended forward",
        body_position="Bent forward, follow-through complete"
    ),
]


def get_pose_expectations() -> list[PoseExpectation]:
    """Return the expected poses for swing animation."""
    return SWING_ANIMATION_POSES


def create_validation_prompt(frame_idx: int, pose: PoseExpectation) -> str:
    """Create a prompt for LLM to validate a frame against expected pose."""
    return f"""Validate this animation frame against the expected pose.

FRAME {frame_idx}: {pose.frame_name}

EXPECTED POSE:
- Description: {pose.description}
- Pickaxe Position: {pose.pickaxe_position}
- Body Position: {pose.body_position}
- Key Elements: {', '.join(pose.key_elements)}

VALIDATION CRITERIA:
1. Is the pickaxe in the CORRECT position for this frame?
   - For frame {frame_idx} ({pose.frame_name}), pickaxe should be: {pose.pickaxe_position}

2. Does the body posture match expectations?

3. Are all key elements visible and correct?

Rate the pose accuracy:
- PASS: Pose clearly matches the expected position
- FAIL: Pose is significantly wrong (e.g., pickaxe in wrong position)
- WARNING: Pose is close but not quite right

Be STRICT about pickaxe position - this is critical for the animation to read correctly.
"""


def create_sequence_validation_prompt() -> str:
    """Create a prompt for validating the animation sequence as a whole."""
    return """Validate this animation sequence as a complete pickaxe swing.

A CORRECT pickaxe swing animation should show:
1. READY: Pickaxe at rest (low/side position)
2. WINDUP: Pickaxe rises UP and BACK (overhead at peak)
3. SWING: Pickaxe comes DOWN in an arc toward the ground
4. IMPACT: Pickaxe reaches ground level, extended forward

CRITICAL CHECKS:
1. Does the pickaxe actually MOVE through the sequence?
2. Does the pickaxe go from LOW → HIGH → LOW (not stay in one place)?
3. Is there a clear overhead position in the windup frames?
4. Does the pickaxe reach ground level in the impact frame?

FAIL the animation if:
- Pickaxe stays in roughly the same position across all frames
- There's no clear overhead backswing
- Pickaxe never reaches ground level
- The motion doesn't read as a "swing at the ground"

Be STRICT - the animation must clearly show swinging a pickaxe DOWN at the ground.
"""


def create_motion_check_prompt() -> str:
    """Create a prompt for checking actual motion between frames."""
    return """Check for actual MOTION between frames.

Compare consecutive frames and verify:
1. Is there VISIBLE CHANGE in pickaxe position between frames?
2. Is there VISIBLE CHANGE in arm/body position between frames?
3. Do the changes follow a logical sequence (up then down)?

RED FLAGS (indicate failed animation):
- Pickaxe in same position across 3+ consecutive frames
- No visible arm movement between frames
- All frames look nearly identical
- Motion is random rather than sequential

A good animation should show PROGRESSIVE CHANGE from frame to frame.
"""


def print_validation_checklist():
    """Print the validation checklist for manual LLM evaluation."""
    print("=" * 70)
    print("ANIMATION VALIDATION CHECKLIST")
    print("=" * 70)
    print("\nUse this checklist when evaluating generated animation frames:\n")

    print("1. POSE VALIDATION (check each frame):")
    print("-" * 50)
    for i, pose in enumerate(SWING_ANIMATION_POSES):
        print(f"\n   Frame {i} ({pose.frame_name}):")
        print(f"   Expected pickaxe: {pose.pickaxe_position}")
        print(f"   [ ] Pickaxe position correct?")
        print(f"   [ ] Body posture matches?")

    print("\n\n2. SEQUENCE VALIDATION:")
    print("-" * 50)
    print("   [ ] Pickaxe goes from LOW → HIGH → LOW?")
    print("   [ ] Clear overhead position in windup frames (2-3)?")
    print("   [ ] Pickaxe reaches ground in impact frame (7)?")
    print("   [ ] Motion reads as 'swinging at ground'?")

    print("\n\n3. MOTION VALIDATION:")
    print("-" * 50)
    print("   [ ] Visible change between consecutive frames?")
    print("   [ ] Progressive motion (not random)?")
    print("   [ ] No 3+ frames with pickaxe in same position?")

    print("\n\n4. OVERALL ASSESSMENT:")
    print("-" * 50)
    print("   [ ] Would a player recognize this as 'swinging pickaxe'?")
    print("   [ ] Does the animation convey POWER and IMPACT?")
    print("=" * 70)


def save_validation_config(output_path: Path):
    """Save pose expectations as JSON for use in automated validation."""
    config = {
        "animation_type": "pickaxe_swing",
        "frame_count": 8,
        "poses": [
            {
                "frame_idx": i,
                "frame_name": p.frame_name,
                "description": p.description,
                "pickaxe_position": p.pickaxe_position,
                "body_position": p.body_position,
                "key_elements": p.key_elements
            }
            for i, p in enumerate(SWING_ANIMATION_POSES)
        ],
        "validation_criteria": {
            "pose_validation": "Each frame must match expected pickaxe position",
            "sequence_validation": "Pickaxe must travel LOW → HIGH → LOW",
            "motion_validation": "Visible progressive change between frames"
        },
        "failure_conditions": [
            "Pickaxe stays in same position across all frames",
            "No clear overhead backswing (frames 2-3)",
            "Pickaxe never reaches ground level (frame 7)",
            "Motion doesn't read as downward swing"
        ]
    }

    with open(output_path, 'w') as f:
        json.dump(config, f, indent=2)

    print(f"Validation config saved to: {output_path}")


if __name__ == "__main__":
    print_validation_checklist()

    # Save config for future use
    config_path = Path(__file__).parent.parent.parent / "resources" / "sprites" / "swing_animation_validation.json"
    save_validation_config(config_path)
