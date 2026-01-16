#!/opt/homebrew/bin/python3.11
"""Primer Validation System.

Ensures asset quality never regresses by comparing against primer (best) versions.

Usage:
    python primer_validator.py           # Validate current vs primer
    python primer_validator.py --promote # Promote current to primer if better
"""

from pathlib import Path
import shutil
import sys

PROJECT_ROOT = Path(__file__).parent.parent.parent
COMPONENTS_DIR = PROJECT_ROOT / "resources" / "sprites" / "components"
PRIMER_DIR = COMPONENTS_DIR / "primer"

sys.path.insert(0, str(Path(__file__).parent))
from component_validator import validate_component


def get_component_score(component_path: Path) -> float:
    """Get overall score for a component."""
    if not component_path.exists():
        return 0.0
    result = validate_component(component_path)
    return result.overall


def validate_against_primer() -> dict:
    """Compare current components against primer versions."""
    results = {}
    
    components = ['body', 'head', 'arm', 'left_arm', 'pickaxe']
    
    for name in components:
        current_path = COMPONENTS_DIR / f"{name}.png"
        primer_path = PRIMER_DIR / f"{name}.png"
        
        current_score = get_component_score(current_path)
        primer_score = get_component_score(primer_path) if primer_path.exists() else 0.0
        
        diff = current_score - primer_score
        status = "✓ BETTER" if diff > 0.001 else ("= SAME" if abs(diff) < 0.001 else "✗ WORSE")
        
        results[name] = {
            'current': current_score,
            'primer': primer_score,
            'diff': diff,
            'status': status
        }
    
    return results


def promote_to_primer(force: bool = False) -> bool:
    """Promote current components to primer if they're better or equal."""
    results = validate_against_primer()
    
    # Check if any are worse
    any_worse = any(r['diff'] < -0.001 for r in results.values())
    
    if any_worse and not force:
        print("ERROR: Some components are WORSE than primer. Use --force to override.")
        return False
    
    # Copy all components to primer
    PRIMER_DIR.mkdir(exist_ok=True)
    for name in results.keys():
        src = COMPONENTS_DIR / f"{name}.png"
        dst = PRIMER_DIR / f"{name}.png"
        if src.exists():
            shutil.copy2(src, dst)
    
    print("Promoted current components to primer.")
    return True


def print_report(results: dict):
    """Print validation report."""
    print("=" * 60)
    print("PRIMER VALIDATION REPORT")
    print("=" * 60)
    print()
    
    total_current = 0
    total_primer = 0
    
    for name, data in results.items():
        status_icon = "✓" if data['diff'] >= -0.001 else "✗"
        print(f"{status_icon} {name}:")
        print(f"    Current: {data['current']:.3f}")
        print(f"    Primer:  {data['primer']:.3f}")
        print(f"    Diff:    {data['diff']:+.3f} {data['status']}")
        print()
        total_current += data['current']
        total_primer += data['primer']
    
    avg_current = total_current / len(results)
    avg_primer = total_primer / len(results)
    avg_diff = avg_current - avg_primer
    
    print("-" * 60)
    print(f"AVERAGE: Current={avg_current:.3f}, Primer={avg_primer:.3f}, Diff={avg_diff:+.3f}")
    
    if avg_diff >= 0:
        print("STATUS: ✓ Current is EQUAL OR BETTER than primer")
    else:
        print("STATUS: ✗ Current is WORSE than primer - REGRESSION DETECTED")
    print("=" * 60)


def main():
    if not PRIMER_DIR.exists():
        print("No primer directory found. Creating from current components...")
        promote_to_primer(force=True)
        return
    
    results = validate_against_primer()
    print_report(results)
    
    if '--promote' in sys.argv:
        print()
        promote_to_primer(force='--force' in sys.argv)


if __name__ == "__main__":
    main()
