# Asset Generation Tools

Quick reference for the miner sprite asset generation pipeline.

## Quick Start

```bash
# Validate everything
python scripts/tools/validate_all.py --quick

# Generate sprite sheet
python scripts/tools/improved_sprite_builder_v4.py

# Generate quality report
python scripts/tools/generate_asset_report.py
```

## Validators

| Tool | Purpose | Target |
|------|---------|--------|
| `validate_all.py` | Run all validators | All pass |
| `component_validator.py` | Sprite quality metrics | ≥0.90 |
| `pickaxe_validator.py` | Pickaxe recognition | ≥0.95 |
| `animation_validator.py` | Frame consistency | ≥0.90 |
| `primer_validator.py` | Regression check | No worse |

## Generators

| Tool | Purpose |
|------|---------|
| `improved_sprite_builder_v4.py` | Main sprite assembly |
| `pickaxe_perpendicular.py` | T-shape pickaxe design |

## Current Scores

```
Components: 0.92 average (all coherence 1.00)
Pickaxe:    1.00 (perfect T-shape recognition)
Animation:  0.95 (8 frames, good motion)
```

## Workflow

1. Make changes to components
2. Run `python scripts/tools/validate_all.py`
3. If pass, run `python scripts/tools/primer_validator.py --promote`
4. Generate report with `python scripts/tools/generate_asset_report.py`

See `docs/ASSET_GENERATION_LEARNINGS.md` for detailed documentation.
