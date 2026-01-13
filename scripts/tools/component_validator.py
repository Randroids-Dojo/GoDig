#!/opt/homebrew/bin/python3.11
"""
Component Quality Validator

Validates and scores sprite components for quality metrics:
- Pixel density (non-transparent pixels vs total area)
- Color palette coherence (limited, consistent colors)
- Edge definition (clear silhouette, no noise)
- Proportions (appropriate for pixel art scale)
- Shading (presence of highlights/shadows)
"""

from PIL import Image
from pathlib import Path
from dataclasses import dataclass
from typing import Optional
import math

PROJECT_ROOT = Path(__file__).parent.parent.parent
COMPONENTS_DIR = PROJECT_ROOT / "resources" / "sprites" / "components"
PRIMER_DIR = PROJECT_ROOT / "resources" / "sprites" / "components_primer"


@dataclass
class ComponentScore:
    """Quality scores for a component."""
    name: str
    pixel_density: float  # 0-1: ratio of non-transparent pixels
    color_count: int  # Number of unique colors
    color_coherence: float  # 0-1: how well colors form a palette
    edge_clarity: float  # 0-1: clear edges vs noisy/aliased
    shading_quality: float  # 0-1: presence of light/dark variations
    overall: float  # Weighted average

    def __str__(self):
        return (
            f"{self.name}:\n"
            f"  Pixel Density: {self.pixel_density:.2f}\n"
            f"  Color Count: {self.color_count}\n"
            f"  Color Coherence: {self.color_coherence:.2f}\n"
            f"  Edge Clarity: {self.edge_clarity:.2f}\n"
            f"  Shading Quality: {self.shading_quality:.2f}\n"
            f"  OVERALL: {self.overall:.2f}"
        )


def analyze_pixel_density(img: Image.Image) -> float:
    """Calculate ratio of non-transparent pixels."""
    if img.mode != 'RGBA':
        img = img.convert('RGBA')

    pixels = list(img.getdata())
    non_transparent = sum(1 for p in pixels if p[3] > 128)
    total = len(pixels)

    return non_transparent / total if total > 0 else 0


def analyze_colors(img: Image.Image) -> tuple[int, float]:
    """Analyze color palette.

    Returns:
        color_count: Number of unique opaque colors
        coherence: How well colors form a coherent palette (0-1)
    """
    if img.mode != 'RGBA':
        img = img.convert('RGBA')

    # Get unique opaque colors
    pixels = list(img.getdata())
    opaque_colors = set()
    for p in pixels:
        if p[3] > 128:  # Opaque enough
            # Quantize to reduce near-duplicates
            r, g, b = p[0] // 8 * 8, p[1] // 8 * 8, p[2] // 8 * 8
            opaque_colors.add((r, g, b))

    color_count = len(opaque_colors)

    # Coherence: fewer colors = more coherent for pixel art
    # Ideal is 4-12 colors for small sprites
    if color_count <= 4:
        coherence = 0.8  # Might be too simple
    elif color_count <= 8:
        coherence = 1.0  # Perfect for pixel art
    elif color_count <= 12:
        coherence = 0.9
    elif color_count <= 16:
        coherence = 0.7
    elif color_count <= 24:
        coherence = 0.5
    else:
        coherence = max(0.2, 1.0 - (color_count - 24) * 0.02)

    return color_count, coherence


def analyze_edges(img: Image.Image) -> float:
    """Analyze edge clarity.

    Checks for:
    - Clear silhouette (no stray pixels)
    - No anti-aliasing artifacts (pixel art should be crisp)
    """
    if img.mode != 'RGBA':
        img = img.convert('RGBA')

    width, height = img.size
    pixels = img.load()

    # Count boundary pixels vs interior pixels
    boundary_count = 0
    clean_boundary_count = 0

    for y in range(height):
        for x in range(width):
            alpha = pixels[x, y][3]

            if alpha > 128:  # This pixel is opaque
                # Check if it's a boundary pixel
                is_boundary = False
                neighbor_alphas = []

                for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < width and 0 <= ny < height:
                        neighbor_alphas.append(pixels[nx, ny][3])
                    else:
                        is_boundary = True  # Edge of image

                if any(a <= 128 for a in neighbor_alphas):
                    is_boundary = True

                if is_boundary:
                    boundary_count += 1
                    # Clean boundary = fully opaque (255) not semi-transparent
                    if alpha >= 250:
                        clean_boundary_count += 1

    if boundary_count == 0:
        return 1.0

    return clean_boundary_count / boundary_count


def analyze_shading(img: Image.Image) -> float:
    """Analyze shading quality.

    Good pixel art has:
    - Light and dark variations of base colors
    - Highlights and shadows
    """
    if img.mode != 'RGBA':
        img = img.convert('RGBA')

    pixels = list(img.getdata())
    opaque_pixels = [p for p in pixels if p[3] > 128]

    if len(opaque_pixels) < 10:
        return 0.5  # Too small to judge

    # Calculate luminance for each pixel
    luminances = []
    for r, g, b, a in opaque_pixels:
        lum = 0.299 * r + 0.587 * g + 0.114 * b
        luminances.append(lum)

    if not luminances:
        return 0.0

    min_lum = min(luminances)
    max_lum = max(luminances)
    lum_range = max_lum - min_lum

    # Calculate standard deviation
    mean_lum = sum(luminances) / len(luminances)
    variance = sum((l - mean_lum) ** 2 for l in luminances) / len(luminances)
    std_dev = math.sqrt(variance)

    # Score based on luminance range and variation
    # Good pixel art should have reasonable contrast
    if lum_range < 30:
        range_score = 0.3  # Too flat
    elif lum_range < 60:
        range_score = 0.6
    elif lum_range < 120:
        range_score = 1.0  # Good contrast
    else:
        range_score = 0.8  # Very high contrast

    # Standard deviation indicates varied shading
    if std_dev < 10:
        var_score = 0.3
    elif std_dev < 25:
        var_score = 0.7
    elif std_dev < 50:
        var_score = 1.0
    else:
        var_score = 0.8

    return (range_score + var_score) / 2


def validate_component(img_path: Path) -> ComponentScore:
    """Validate a single component image."""
    img = Image.open(img_path)
    name = img_path.stem

    pixel_density = analyze_pixel_density(img)
    color_count, color_coherence = analyze_colors(img)
    edge_clarity = analyze_edges(img)
    shading_quality = analyze_shading(img)

    # Weighted overall score
    # Edge clarity and color coherence are most important for pixel art
    overall = (
        pixel_density * 0.1 +
        color_coherence * 0.3 +
        edge_clarity * 0.3 +
        shading_quality * 0.3
    )

    return ComponentScore(
        name=name,
        pixel_density=pixel_density,
        color_count=color_count,
        color_coherence=color_coherence,
        edge_clarity=edge_clarity,
        shading_quality=shading_quality,
        overall=overall
    )


def validate_all_components(components_dir: Path = COMPONENTS_DIR) -> dict[str, ComponentScore]:
    """Validate all components in a directory."""
    scores = {}

    for png_file in components_dir.glob("*.png"):
        # Skip frame previews
        if png_file.stem.startswith("frame_"):
            continue
        scores[png_file.stem] = validate_component(png_file)

    return scores


def compare_component_sets(dir_a: Path, dir_b: Path) -> dict:
    """Compare two sets of components."""
    scores_a = validate_all_components(dir_a)
    scores_b = validate_all_components(dir_b)

    comparison = {}
    for name in scores_a:
        if name in scores_b:
            diff = scores_b[name].overall - scores_a[name].overall
            comparison[name] = {
                "score_a": scores_a[name].overall,
                "score_b": scores_b[name].overall,
                "diff": diff,
                "improved": diff > 0,
                "details_a": scores_a[name],
                "details_b": scores_b[name]
            }

    return comparison


def print_validation_report(scores: dict[str, ComponentScore]):
    """Print a validation report."""
    print("=" * 60)
    print("COMPONENT VALIDATION REPORT")
    print("=" * 60)

    total_score = 0
    for name, score in sorted(scores.items()):
        print(f"\n{score}")
        total_score += score.overall

    if scores:
        avg_score = total_score / len(scores)
        print(f"\n{'=' * 60}")
        print(f"AVERAGE OVERALL SCORE: {avg_score:.2f}")
        print("=" * 60)


def main():
    """Validate current components."""
    scores = validate_all_components()
    print_validation_report(scores)


if __name__ == "__main__":
    main()
