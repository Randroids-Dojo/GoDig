#!/usr/bin/env python3
"""
Texture validator for GoDig terrain tiles.

Validates generated terrain textures for:
- Color palette adherence (3-4 tone shading)
- Pixel density and variation
- Edge quality (no hard seams)
- Noise quality (not too uniform, not too chaotic)

Run: python3 scripts/tools/texture_validator.py [--atlas PATH]
"""

import os
from PIL import Image
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass
from collections import Counter
import math


# Tile configuration
TILE_SIZE = 128
COLS = 6
ROWS = 3


@dataclass
class TileMetrics:
    """Quality metrics for a single tile."""
    name: str
    position: Tuple[int, int]
    unique_colors: int
    color_distribution: Dict[Tuple[int, int, int], float]
    edge_contrast: float
    noise_variance: float
    palette_adherence: float


@dataclass
class ValidationResult:
    """Overall validation result."""
    passed: bool
    score: float  # 0-1
    metrics: List[TileMetrics]
    issues: List[str]


def extract_tile(atlas: Image.Image, col: int, row: int) -> Image.Image:
    """Extract a single tile from the atlas."""
    x = col * TILE_SIZE
    y = row * TILE_SIZE
    return atlas.crop((x, y, x + TILE_SIZE, y + TILE_SIZE))


def analyze_colors(tile: Image.Image) -> Tuple[int, Dict[Tuple[int, int, int], float]]:
    """Analyze color usage in a tile."""
    pixels = list(tile.getdata())
    total = len(pixels)

    # Count colors (ignoring alpha)
    color_counts = Counter()
    for pixel in pixels:
        if len(pixel) == 4 and pixel[3] == 0:  # Skip transparent
            continue
        rgb = pixel[:3]
        color_counts[rgb] += 1

    unique = len(color_counts)
    distribution = {color: count / total for color, count in color_counts.items()}

    return unique, distribution


def calculate_edge_contrast(tile: Image.Image) -> float:
    """Calculate contrast at tile edges (lower is better for seamless tiling)."""
    width, height = tile.size
    pixels = tile.load()

    total_diff = 0
    count = 0

    # Check left-right edge contrast
    for y in range(height):
        left = pixels[0, y][:3]
        right = pixels[width - 1, y][:3]
        diff = sum(abs(left[i] - right[i]) for i in range(3)) / 3
        total_diff += diff
        count += 1

    # Check top-bottom edge contrast
    for x in range(width):
        top = pixels[x, 0][:3]
        bottom = pixels[x, height - 1][:3]
        diff = sum(abs(top[i] - bottom[i]) for i in range(3)) / 3
        total_diff += diff
        count += 1

    return total_diff / count if count > 0 else 0


def calculate_noise_variance(tile: Image.Image) -> float:
    """Calculate variance of luminance values (texture complexity)."""
    pixels = list(tile.getdata())

    luminances = []
    for pixel in pixels:
        if len(pixel) == 4 and pixel[3] == 0:
            continue
        # Calculate luminance
        lum = 0.299 * pixel[0] + 0.587 * pixel[1] + 0.114 * pixel[2]
        luminances.append(lum)

    if not luminances:
        return 0

    mean = sum(luminances) / len(luminances)
    variance = sum((l - mean) ** 2 for l in luminances) / len(luminances)

    return math.sqrt(variance)  # Return standard deviation


def calculate_palette_adherence(
    distribution: Dict[Tuple[int, int, int], float],
    expected_colors: int = 4
) -> float:
    """
    Score how well the tile adheres to a limited palette.
    Higher score = better adherence to pixel art principles.
    """
    # Ideal: 3-6 colors making up 95%+ of pixels
    sorted_colors = sorted(distribution.values(), reverse=True)

    # Get coverage of top N colors
    if len(sorted_colors) >= expected_colors:
        top_coverage = sum(sorted_colors[:expected_colors])
    else:
        top_coverage = sum(sorted_colors)

    # Score based on coverage and total colors
    coverage_score = min(1.0, top_coverage / 0.9)  # 90% coverage = perfect

    # Penalty for too many colors
    color_count = len(sorted_colors)
    if color_count <= 6:
        count_score = 1.0
    elif color_count <= 12:
        count_score = 0.8
    elif color_count <= 20:
        count_score = 0.6
    else:
        count_score = max(0.3, 1.0 - (color_count - 20) * 0.02)

    return (coverage_score + count_score) / 2


# Tile names for reference
TILE_NAMES = {
    (0, 0): "Dirt", (1, 0): "Clay", (2, 0): "Stone",
    (3, 0): "Granite", (4, 0): "Basalt", (5, 0): "Obsidian",
    (0, 1): "Coal", (1, 1): "Copper", (2, 1): "Iron",
    (3, 1): "Silver", (4, 1): "Gold", (5, 1): "Diamond",
    (0, 2): "Ladder", (1, 2): "Air", (2, 2): "Ruby",
    (3, 2): "Emerald", (4, 2): "Sapphire", (5, 2): "Amethyst",
}


def validate_atlas(atlas_path: str) -> ValidationResult:
    """Validate the entire terrain atlas."""
    atlas = Image.open(atlas_path).convert("RGBA")

    metrics = []
    issues = []
    scores = []

    print(f"Validating terrain atlas: {atlas_path}")
    print(f"Atlas size: {atlas.size[0]}x{atlas.size[1]}")
    print("-" * 60)

    for row in range(ROWS):
        for col in range(COLS):
            name = TILE_NAMES.get((col, row), f"Unknown [{col},{row}]")

            # Skip air tile
            if name == "Air":
                print(f"  {name}: Skipped (transparent)")
                continue

            tile = extract_tile(atlas, col, row)
            unique_colors, distribution = analyze_colors(tile)
            edge_contrast = calculate_edge_contrast(tile)
            noise_var = calculate_noise_variance(tile)
            palette_score = calculate_palette_adherence(distribution)

            tile_metrics = TileMetrics(
                name=name,
                position=(col, row),
                unique_colors=unique_colors,
                color_distribution=distribution,
                edge_contrast=edge_contrast,
                noise_variance=noise_var,
                palette_adherence=palette_score
            )
            metrics.append(tile_metrics)

            # Calculate overall tile score
            tile_score = palette_score

            # Adjust for edge contrast (lower is better)
            if edge_contrast < 20:
                tile_score = min(1.0, tile_score + 0.1)
            elif edge_contrast > 50:
                tile_score = max(0.0, tile_score - 0.1)
                issues.append(f"{name}: High edge contrast ({edge_contrast:.1f})")

            # Adjust for noise variance (we want some but not too much)
            if 10 < noise_var < 50:
                tile_score = min(1.0, tile_score + 0.05)
            elif noise_var < 5:
                issues.append(f"{name}: Low texture variance ({noise_var:.1f})")
            elif noise_var > 60:
                issues.append(f"{name}: High texture variance ({noise_var:.1f})")

            scores.append(tile_score)

            # Print tile metrics
            status = "PASS" if tile_score >= 0.7 else "WARN" if tile_score >= 0.5 else "FAIL"
            print(f"  {name}: {status} (score: {tile_score:.2f})")
            print(f"    Colors: {unique_colors}, Palette: {palette_score:.2f}, "
                  f"Edge: {edge_contrast:.1f}, Noise: {noise_var:.1f}")

    print("-" * 60)

    # Overall result
    avg_score = sum(scores) / len(scores) if scores else 0
    passed = avg_score >= 0.7 and len([s for s in scores if s < 0.5]) == 0

    print(f"\nOverall Score: {avg_score:.2f}")
    print(f"Result: {'PASSED' if passed else 'FAILED'}")

    if issues:
        print(f"\nIssues found ({len(issues)}):")
        for issue in issues:
            print(f"  - {issue}")

    return ValidationResult(
        passed=passed,
        score=avg_score,
        metrics=metrics,
        issues=issues
    )


def compare_atlases(path1: str, path2: str) -> None:
    """Compare two terrain atlases side by side."""
    result1 = validate_atlas(path1)
    print("\n" + "=" * 60 + "\n")
    result2 = validate_atlas(path2)

    print("\n" + "=" * 60)
    print("COMPARISON SUMMARY")
    print("=" * 60)
    print(f"Atlas 1: {path1}")
    print(f"  Score: {result1.score:.2f}, Issues: {len(result1.issues)}")
    print(f"Atlas 2: {path2}")
    print(f"  Score: {result2.score:.2f}, Issues: {len(result2.issues)}")

    if result2.score > result1.score:
        print(f"\nAtlas 2 is better by {(result2.score - result1.score):.2f} points")
    elif result1.score > result2.score:
        print(f"\nAtlas 1 is better by {(result1.score - result2.score):.2f} points")
    else:
        print("\nBoth atlases have the same score")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Validate terrain textures")
    parser.add_argument("--atlas", type=str, help="Path to terrain atlas",
                        default="resources/tileset/terrain_atlas.png")
    parser.add_argument("--compare", type=str, help="Compare with another atlas")

    args = parser.parse_args()

    # Resolve path
    if not os.path.isabs(args.atlas):
        script_dir = os.path.dirname(__file__)
        project_root = os.path.dirname(os.path.dirname(script_dir))
        atlas_path = os.path.join(project_root, args.atlas)
    else:
        atlas_path = args.atlas

    if args.compare:
        compare_atlases(atlas_path, args.compare)
    else:
        validate_atlas(atlas_path)
