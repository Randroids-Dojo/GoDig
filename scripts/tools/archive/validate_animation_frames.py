#!/opt/homebrew/bin/python3.11
"""
Validate Animation Frames - LLM-assisted pose and sequence validation.

This script validates generated animation frames against expected poses.
Run this BEFORE creating the final sprite sheet to catch pose issues.

Usage:
    python validate_animation_frames.py <frames_directory>

The script will:
1. Load each frame image
2. Print validation criteria for LLM to evaluate
3. Output a validation report
"""

import sys
from pathlib import Path
from animation_validator import (
    get_pose_expectations,
    create_validation_prompt,
    create_sequence_validation_prompt,
    ValidationResult
)

PROJECT_ROOT = Path(__file__).parent.parent.parent
SPRITES_DIR = PROJECT_ROOT / "resources" / "sprites"


def print_frame_validation_prompt(frame_idx: int, frame_path: Path):
    """Print validation prompt for a single frame."""
    poses = get_pose_expectations()
    if frame_idx >= len(poses):
        print(f"ERROR: No pose expectation for frame {frame_idx}")
        return

    pose = poses[frame_idx]

    print(f"\n{'='*60}")
    print(f"VALIDATING FRAME {frame_idx}: {pose.frame_name}")
    print(f"{'='*60}")
    print(f"Image: {frame_path.name}")
    print(f"\n{create_validation_prompt(frame_idx, pose)}")
    print(f"\n>>> VIEW THE IMAGE AND ANSWER:")
    print(f"    Is the pickaxe in position: {pose.pickaxe_position}?")
    print(f"    [PASS / FAIL / WARNING]")


def print_sequence_validation():
    """Print sequence validation prompt."""
    print(f"\n{'='*70}")
    print("SEQUENCE VALIDATION - ALL FRAMES TOGETHER")
    print(f"{'='*70}")
    print(create_sequence_validation_prompt())


def print_validation_summary_template():
    """Print a template for recording validation results."""
    poses = get_pose_expectations()

    print(f"\n{'='*70}")
    print("VALIDATION RESULTS TEMPLATE")
    print(f"{'='*70}")
    print("\nCopy and fill in this template:\n")
    print("```")
    print("FRAME VALIDATION RESULTS:")
    for i, pose in enumerate(poses):
        print(f"  Frame {i} ({pose.frame_name}): [ ] PASS  [ ] FAIL  [ ] WARNING")
        print(f"    Expected pickaxe: {pose.pickaxe_position}")
        print(f"    Actual pickaxe: _________________")
        print(f"    Issues: _________________________")
    print("")
    print("SEQUENCE VALIDATION:")
    print("  [ ] PASS - Animation shows clear swing motion")
    print("  [ ] FAIL - Animation does NOT show swing motion")
    print("  Issues: _________________________________")
    print("")
    print("MOTION VALIDATION:")
    print("  [ ] PASS - Clear progressive motion between frames")
    print("  [ ] FAIL - Frames look too similar / no motion")
    print("  Issues: _________________________________")
    print("")
    print("OVERALL: [ ] APPROVED  [ ] NEEDS REGENERATION")
    print("```")


def validate_directory(frames_dir: Path):
    """Validate all frames in a directory."""
    if not frames_dir.exists():
        print(f"ERROR: Directory not found: {frames_dir}")
        sys.exit(1)

    # Find frame files
    frame_files = sorted(frames_dir.glob("*.png"))
    if not frame_files:
        print(f"ERROR: No PNG files found in {frames_dir}")
        sys.exit(1)

    print("=" * 70)
    print("ANIMATION FRAME VALIDATION")
    print("=" * 70)
    print(f"\nDirectory: {frames_dir}")
    print(f"Frames found: {len(frame_files)}")

    poses = get_pose_expectations()

    # Print validation for each frame
    for i, frame_path in enumerate(frame_files[:8]):  # Max 8 frames
        print_frame_validation_prompt(i, frame_path)

    # Print sequence validation
    print_sequence_validation()

    # Print summary template
    print_validation_summary_template()


def main():
    if len(sys.argv) < 2:
        # Default to polished_animation/selected directory
        frames_dir = SPRITES_DIR / "polished_animation" / "selected"
    else:
        frames_dir = Path(sys.argv[1])

    validate_directory(frames_dir)


if __name__ == "__main__":
    main()
