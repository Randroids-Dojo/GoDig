#!/opt/homebrew/bin/python3.11
"""Unified validation command - runs all validators and reports pass/fail.

Usage:
    python validate_all.py           # Run all validations
    python validate_all.py --quick   # Quick summary only
    python validate_all.py --strict  # Fail if any metric below target
"""

from pathlib import Path
import sys

PROJECT_ROOT = Path(__file__).parent.parent.parent
sys.path.insert(0, str(Path(__file__).parent))

from component_validator import validate_all_components
from pickaxe_validator import validate_pickaxe
from animation_validator import analyze_frame_metrics, analyze_motion


# Quality targets
TARGETS = {
    'component_avg': 0.90,
    'pickaxe': 0.95,
    'animation': 0.90,
    'coherence': 1.00,
}


def run_all_validations():
    """Run all validations and return results."""
    results = {}
    
    # Component validation
    components = validate_all_components()
    avg = sum(s.overall for s in components.values()) / len(components)
    all_coherent = all(s.color_coherence >= 0.99 for s in components.values())
    
    results['components'] = {
        'scores': {name: s.overall for name, s in components.items()},
        'average': avg,
        'all_coherent': all_coherent,
        'pass': avg >= TARGETS['component_avg'] and all_coherent,
    }
    
    # Pickaxe validation
    pickaxe = validate_pickaxe()
    results['pickaxe'] = {
        'score': pickaxe.overall,
        'pass': pickaxe.overall >= TARGETS['pickaxe'],
    }
    
    # Animation validation
    anim = analyze_frame_metrics()
    motion = analyze_motion()
    results['animation'] = {
        'consistency': anim['overall'],
        'motion': motion['motion_score'] if motion else 0,
        'pass': anim['overall'] >= TARGETS['animation'],
    }
    
    # Overall pass/fail
    results['overall_pass'] = all([
        results['components']['pass'],
        results['pickaxe']['pass'],
        results['animation']['pass'],
    ])
    
    return results


def print_quick_summary(results):
    """Print quick pass/fail summary."""
    status = "✅ PASS" if results['overall_pass'] else "❌ FAIL"
    print(f"\n{status} - All Validations")
    print(f"  Components: {results['components']['average']:.2f} ({'✓' if results['components']['pass'] else '✗'})")
    print(f"  Pickaxe:    {results['pickaxe']['score']:.2f} ({'✓' if results['pickaxe']['pass'] else '✗'})")
    print(f"  Animation:  {results['animation']['consistency']:.2f} ({'✓' if results['animation']['pass'] else '✗'})")


def print_full_report(results):
    """Print detailed validation report."""
    print("=" * 60)
    print("UNIFIED VALIDATION REPORT")
    print("=" * 60)
    
    # Components
    print("\n📦 COMPONENTS")
    for name, score in sorted(results['components']['scores'].items(), key=lambda x: -x[1]):
        status = "✓" if score >= TARGETS['component_avg'] else "✗"
        print(f"  {status} {name}: {score:.2f}")
    print(f"  Average: {results['components']['average']:.2f}")
    print(f"  Coherence: {'✓ All 1.00' if results['components']['all_coherent'] else '✗ Some < 1.00'}")
    
    # Pickaxe
    print("\n⛏️  PICKAXE")
    print(f"  Score: {results['pickaxe']['score']:.2f}")
    print(f"  Target: {TARGETS['pickaxe']:.2f}")
    
    # Animation
    print("\n🎬 ANIMATION")
    print(f"  Consistency: {results['animation']['consistency']:.2f}")
    print(f"  Motion: {results['animation']['motion']:.2f}")
    
    # Overall
    print("\n" + "=" * 60)
    if results['overall_pass']:
        print("✅ ALL VALIDATIONS PASSED")
    else:
        print("❌ SOME VALIDATIONS FAILED")
    print("=" * 60)


def main():
    results = run_all_validations()
    
    if '--quick' in sys.argv:
        print_quick_summary(results)
    else:
        print_full_report(results)
    
    # Exit with error code if validation failed
    if '--strict' in sys.argv and not results['overall_pass']:
        sys.exit(1)
    
    return results['overall_pass']


if __name__ == "__main__":
    main()
