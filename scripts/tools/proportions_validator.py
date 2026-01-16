#!/opt/homebrew/bin/python3.11
"""
Proportions Validator

Validates body part proportions for consistency and anatomical correctness:
- Arm thickness consistency (left vs right)
- Body part size ratios (head:body, arm:body)
- Limb length consistency
- Component bounds checking
"""

from PIL import Image
from pathlib import Path
from dataclasses import dataclass
from typing import Optional
import math

PROJECT_ROOT = Path(__file__).parent.parent.parent
COMPONENTS_DIR = PROJECT_ROOT / "resources" / "sprites" / "components"


@dataclass
class ProportionScore:
    """Proportion validation scores."""
    arm_thickness_ratio: float  # 1.0 = perfect match, <1.0 = mismatch
    arm_length_ratio: float  # 1.0 = perfect match
    head_body_ratio: float  # Ideal ~0.4-0.6 for stylized characters
    bounds_valid: bool  # All content within image bounds
    overall: float
    details: dict

    def __str__(self):
        status = "PASS" if self.overall >= 0.8 else "FAIL"
        return (
            f"Proportion Validation [{status}]:\n"
            f"  Arm thickness ratio: {self.arm_thickness_ratio:.2f} (1.0 = matching)\n"
            f"  Arm length ratio: {self.arm_length_ratio:.2f} (1.0 = matching)\n"
            f"  Head/body ratio: {self.head_body_ratio:.2f} (ideal: 0.4-0.6)\n"
            f"  Bounds valid: {self.bounds_valid}\n"
            f"  OVERALL: {self.overall:.2f}"
        )


def get_content_dimensions(img: Image.Image) -> tuple[int, int, int, int]:
    """Get actual content bounds (non-transparent area)."""
    if img.mode != 'RGBA':
        img = img.convert('RGBA')

    bbox = img.getbbox()
    if bbox is None:
        return 0, 0, 0, 0

    x1, y1, x2, y2 = bbox
    width = x2 - x1
    height = y2 - y1
    return width, height, x1, y1


def measure_limb_thickness(img: Image.Image, orientation: str = "horizontal") -> float:
    """Measure the thickness of a limb component.

    For horizontal arms: measures vertical extent (thickness)
    For vertical arms: measures horizontal extent (thickness)
    """
    if img.mode != 'RGBA':
        img = img.convert('RGBA')

    bbox = img.getbbox()
    if bbox is None:
        return 0

    x1, y1, x2, y2 = bbox

    if orientation == "horizontal":
        return y2 - y1  # Vertical extent = thickness
    else:
        return x2 - x1  # Horizontal extent = thickness


def measure_limb_length(img: Image.Image, orientation: str = "horizontal") -> float:
    """Measure the length of a limb component."""
    if img.mode != 'RGBA':
        img = img.convert('RGBA')

    bbox = img.getbbox()
    if bbox is None:
        return 0

    x1, y1, x2, y2 = bbox

    if orientation == "horizontal":
        return x2 - x1  # Horizontal extent = length
    else:
        return y2 - y1  # Vertical extent = length


def check_bounds(img: Image.Image) -> tuple[bool, str]:
    """Check if all content is within image bounds.

    Returns (valid, message).
    """
    if img.mode != 'RGBA':
        img = img.convert('RGBA')

    width, height = img.size
    bbox = img.getbbox()

    if bbox is None:
        return True, "Empty image"

    x1, y1, x2, y2 = bbox

    issues = []
    if x1 < 0:
        issues.append(f"content starts at x={x1}")
    if y1 < 0:
        issues.append(f"content starts at y={y1}")
    if x2 > width:
        issues.append(f"content extends to x={x2}, image width={width}")
    if y2 > height:
        issues.append(f"content extends to y={y2}, image height={height}")

    if issues:
        return False, "; ".join(issues)
    return True, "OK"


def validate_proportions(components_dir: Path = COMPONENTS_DIR) -> ProportionScore:
    """Validate proportions of all components."""
    details = {}

    # Load components
    arm_path = components_dir / "arm.png"
    left_arm_path = components_dir / "left_arm.png"
    body_path = components_dir / "body.png"
    head_path = components_dir / "head.png"

    # Check bounds for all components
    bounds_issues = []
    for path in [arm_path, left_arm_path, body_path, head_path]:
        if path.exists():
            img = Image.open(path)
            valid, msg = check_bounds(img)
            if not valid:
                bounds_issues.append(f"{path.stem}: {msg}")

    bounds_valid = len(bounds_issues) == 0
    details["bounds_issues"] = bounds_issues

    # Measure arm proportions
    if arm_path.exists() and left_arm_path.exists():
        arm = Image.open(arm_path)
        left_arm = Image.open(left_arm_path)

        # Right arm is horizontal, left arm is vertical
        right_thickness = measure_limb_thickness(arm, "horizontal")
        left_thickness = measure_limb_thickness(left_arm, "vertical")

        right_length = measure_limb_length(arm, "horizontal")
        left_length = measure_limb_length(left_arm, "vertical")

        details["right_arm"] = {"thickness": right_thickness, "length": right_length}
        details["left_arm"] = {"thickness": left_thickness, "length": left_length}

        # Calculate ratio (smaller / larger to get 0-1 range)
        if right_thickness > 0 and left_thickness > 0:
            arm_thickness_ratio = min(right_thickness, left_thickness) / max(right_thickness, left_thickness)
        else:
            arm_thickness_ratio = 0

        if right_length > 0 and left_length > 0:
            arm_length_ratio = min(right_length, left_length) / max(right_length, left_length)
        else:
            arm_length_ratio = 0
    else:
        arm_thickness_ratio = 0.5
        arm_length_ratio = 0.5

    # Measure head/body ratio
    if head_path.exists() and body_path.exists():
        head = Image.open(head_path)
        body = Image.open(body_path)

        head_w, head_h, _, _ = get_content_dimensions(head)
        body_w, body_h, _, _ = get_content_dimensions(body)

        details["head"] = {"width": head_w, "height": head_h}
        details["body"] = {"width": body_w, "height": body_h}

        # Head height compared to body height
        if body_h > 0:
            head_body_ratio = head_h / body_h
        else:
            head_body_ratio = 0
    else:
        head_body_ratio = 0.5

    # Score head/body ratio (ideal is 0.4-0.6 for stylized characters)
    if 0.4 <= head_body_ratio <= 0.6:
        head_ratio_score = 1.0
    elif 0.3 <= head_body_ratio <= 0.7:
        head_ratio_score = 0.8
    else:
        head_ratio_score = 0.5

    # Calculate overall score
    overall = (
        arm_thickness_ratio * 0.3 +
        arm_length_ratio * 0.2 +
        head_ratio_score * 0.2 +
        (1.0 if bounds_valid else 0.0) * 0.3
    )

    return ProportionScore(
        arm_thickness_ratio=arm_thickness_ratio,
        arm_length_ratio=arm_length_ratio,
        head_body_ratio=head_body_ratio,
        bounds_valid=bounds_valid,
        overall=overall,
        details=details
    )


def main():
    """Run proportion validation."""
    print("=" * 60)
    print("PROPORTION VALIDATION")
    print("=" * 60)

    score = validate_proportions()
    print(score)

    print("\nDetails:")
    for key, value in score.details.items():
        print(f"  {key}: {value}")


if __name__ == "__main__":
    main()
