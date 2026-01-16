#!/opt/homebrew/bin/python3.11
"""Generate comprehensive asset quality report.

Creates a markdown report summarizing all validation metrics.
"""

from pathlib import Path
from datetime import datetime
import sys

PROJECT_ROOT = Path(__file__).parent.parent.parent
sys.path.insert(0, str(Path(__file__).parent))

from component_validator import validate_all_components
from pickaxe_validator import validate_pickaxe
from animation_validator import analyze_frame_metrics


def generate_report() -> str:
    """Generate comprehensive markdown report."""
    
    # Gather all metrics
    component_scores = validate_all_components()
    pickaxe_score = validate_pickaxe()
    animation_metrics = analyze_frame_metrics()
    
    # Calculate summary stats
    avg_score = sum(s.overall for s in component_scores.values()) / len(component_scores)
    
    # Build report
    lines = [
        "# Asset Quality Report",
        f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M')}",
        "",
        "## Summary",
        "",
        f"| Metric | Score |",
        f"|--------|-------|",
        f"| Component Average | **{avg_score:.2f}** |",
        f"| Pickaxe Validator | **{pickaxe_score.overall:.2f}** |",
        f"| Animation Quality | **{animation_metrics['overall']:.2f}** |",
        "",
        "## Component Details",
        "",
        "| Component | Overall | Coherence | Shading | Edge | Density |",
        "|-----------|---------|-----------|---------|------|---------|",
    ]
    
    for name, score in sorted(component_scores.items(), key=lambda x: -x[1].overall):
        lines.append(
            f"| {name} | {score.overall:.2f} | {score.color_coherence:.2f} | "
            f"{score.shading_quality:.2f} | {score.edge_clarity:.2f} | {score.pixel_density:.2f} |"
        )
    
    lines.extend([
        "",
        "## Pickaxe-Specific Metrics",
        "",
        "| Metric | Score |",
        "|--------|-------|",
        f"| Silhouette Clarity | {pickaxe_score.silhouette_clarity:.2f} |",
        f"| Handle/Head Ratio | {pickaxe_score.handle_head_ratio:.2f} |",
        f"| Color Separation | {pickaxe_score.color_separation:.2f} |",
        f"| Vertical Extent | {pickaxe_score.vertical_extent:.2f} |",
        "",
        "## Animation Metrics",
        "",
        f"- **Frames**: {animation_metrics['frame_count']}",
        f"- **Pixel Consistency**: {animation_metrics['pixel_consistency']:.2f}",
        f"- **Color Consistency**: {animation_metrics['color_consistency']:.2f}",
        f"- **Avg pixels/frame**: {animation_metrics['details']['mean_pixels']:.0f}",
        "",
        "## Quality Targets",
        "",
        "| Target | Status |",
        "|--------|--------|",
        f"| Pickaxe looks like pickaxe | {'✅ Achieved' if pickaxe_score.overall >= 0.95 else '⚠️ In Progress'} |",
        f"| Component avg ≥ 0.90 | {'✅ Achieved' if avg_score >= 0.90 else '⚠️ In Progress'} |",
        f"| All coherence = 1.00 | {'✅ Achieved' if all(s.color_coherence >= 0.99 for s in component_scores.values()) else '⚠️ In Progress'} |",
        f"| Animation quality ≥ 0.90 | {'✅ Achieved' if animation_metrics['overall'] >= 0.90 else '⚠️ In Progress'} |",
        "",
    ])
    
    return "\n".join(lines)


def main():
    report = generate_report()
    
    # Print to console
    print(report)
    
    # Save to file
    output_path = PROJECT_ROOT / "docs" / "ASSET_QUALITY_REPORT.md"
    with open(output_path, 'w') as f:
        f.write(report)
    print(f"\nReport saved to: {output_path}")


if __name__ == "__main__":
    main()
