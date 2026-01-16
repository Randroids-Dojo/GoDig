# Asset Generation Learnings

This document captures key learnings from iterating on the miner sprite components.

## Validation Approach

### Multi-Level Validation
We found success with **multiple validators targeting different aspects**:

1. **Component Validator** (`scripts/tools/component_validator.py`)
   - General quality metrics: pixel density, color count, coherence, edge clarity, shading
   - Good for overall sprite quality assessment
   - Target: 0.85+ overall score

2. **Asset-Specific Validator** (`scripts/tools/pickaxe_validator.py`)
   - Domain-specific metrics for the asset type
   - For pickaxe: silhouette clarity, handle/head ratio, color separation, vertical extent
   - Weighted scoring based on what makes the asset "look right"
   - Target: 0.95+ for recognizable assets

### Key Validator Insights

**Silhouette Clarity**
- Compare head height to handle height
- Ratio of 3.0+ gives perfect score
- Thinner handles improve the ratio

**Vertical Extent (for tools)**
- Measure how balanced the head extends above/below handle centerline
- Perfect balance (1:1 ratio) = 1.00 score
- Calculate handle center from left-half pixel average Y position

**Handle/Head Ratio Detection**
- Use relative change detection (30% increase in vertical extent marks transition)
- Absolute thresholds (< 3 pixels) don't work for all designs

**Color Separation**
- Good ratio: ~60% warm (wood) / ~40% cool (metal)
- Measure by comparing (R-B) warmth values

## Design Principles That Worked

### Color Palette
- **3-tone shading** per material: highlight, base, shadow
- **2-tone shading** works well for secondary materials (shirt on body/arms)
- Skin: (255,218,185), (228,180,140), (180,130,100)
- Metal: (200,200,210), (120,120,130), (60,60,70)
- Wood: (180,120,60), (139,90,43), (100,60,25)
- Work gloves: (165,135,100), (140,110,75), (115,85,55) - distinct from skin and wood
- **Target ≤8 colors per component** for color coherence score of 1.00

### Shading Quality
- **Luminance range**: 60-120 is optimal (good contrast without extremes)
- **Standard deviation**: 25-50 is optimal (varied but not chaotic)
- Too high std_dev (>50) gets penalized
- Too flat (<30 range) gets penalized

### Shading Trade-offs
- Arms have high luminance range (174) due to bright skin vs dark shirt
- This is an acceptable trade-off for visual separation between materials
- Attempting to reduce contrast would make the arm less readable
- **Accept ~0.80 shading quality** when material separation requires high contrast

### Variance Optimization
- Low std dev (<25) reduces shading score to 0.70
- To increase variance: add pixels at luminance extremes
- **Body V-neck trick**: Enlarged collar/neck adds bright skin pixels (L=142)
- This increased body std dev from 22 to 26+, improving shading from 0.85 to 1.00

### Pickaxe-Specific Learnings
1. **Perpendicular T-shape** looks more like a classic pickaxe than arrow/axe shape
2. Handle should be thin enough that head/handle height ratio ≥ 3.0
3. Head must extend equally above and below handle centerline for vertical balance
4. Include both vertical bar AND horizontal spike for T-shape recognition

### Sprite Assembly
- Use **pivot point rotation** for arm/tool movement
- Calculate rotation offset using trigonometry, not expand=True heuristics
- Layer order matters: back arm → body → front arm → head

## Common Pitfalls to Avoid

1. **Too many colors** - Keep palette limited (7-11 colors per component)
2. **Unbalanced proportions** - Always calculate and verify ratios
3. **Poor color separation** - Ensure materials are visually distinct
4. **Chaotic shading** - Std dev should be 25-50, not higher
5. **Clipping during rotation** - Use large canvas for rotated elements

## Asset Generation Pipeline

### Recommended Workflow

1. **Create initial design** based on reference
2. **Run validators** to get baseline scores
3. **Identify lowest scoring metric**
4. **Create debug scripts** to understand the specific issue
5. **Iterate on design** targeting the weak metric
6. **Verify all metrics** remain acceptable
7. **Run primer validator** to check for regressions
8. **Promote to primer** only if scores equal or better

### Primer System

The primer system prevents quality regressions:

```bash
# Validate current vs primer
python scripts/tools/primer_validator.py

# Promote current to primer (if better/equal)
python scripts/tools/primer_validator.py --promote
```

### Unified Validation

Run all validators at once:

```bash
# Full report
python scripts/tools/validate_all.py

# Quick summary
python scripts/tools/validate_all.py --quick

# Strict mode (exit code 1 on failure)
python scripts/tools/validate_all.py --strict
```

### Generate Report

Create comprehensive markdown report:

```bash
python scripts/tools/generate_asset_report.py
```

### File Organization
```
scripts/tools/
├── component_validator.py       # General quality validator
├── pickaxe_validator.py         # Pickaxe-specific validator
├── animation_validator.py       # Animation frame validator
├── primer_validator.py          # Regression prevention
├── validate_all.py              # Unified validation command
├── generate_asset_report.py     # Markdown report generator
├── improved_sprite_builder_v4.py # Main sprite assembly
├── pickaxe_perpendicular.py     # Pickaxe design generator
└── archive/                     # Old iterations (30 files preserved)

resources/sprites/components/
├── body.png
├── head.png
├── arm.png
├── left_arm.png
├── pickaxe.png
├── frame_XX_<pose>.png          # Assembled animation frames
└── primer/                      # Best version backups
    ├── body.png
    ├── head.png
    └── ...
```

## Metrics Summary

| Component | Current Score | Key Metrics | Notes |
|-----------|--------------|-------------|-------|
| Body | **0.95** | Coherence 1.00, Shading 1.00 | 8 colors, enlarged V-neck |
| Head | **0.93** | Coherence 1.00, Shading 0.90 | 8 colors |
| Arm | **0.90** | Coherence 1.00, Shading 0.80 | 8 colors (2-tone shirt) |
| Left Arm | **0.91** | Coherence 1.00, Shading 0.80 | 8 colors (2-tone shirt) |
| Pickaxe | **0.91** | Coherence 1.00, Shading 0.90 | 7 colors |
| **Average** | **0.92** | All coherence 1.00 | Clean components |

### Pickaxe-Specific Score
| Metric | Score |
|--------|-------|
| Silhouette Clarity | 1.00 |
| Handle/Head Ratio | 1.00 |
| Color Separation | 1.00 |
| Vertical Extent | 1.00 |
| **Overall** | **1.00** |

## Future Improvements

- Add visual comparison tool that shows designs side-by-side with scores
- Create automated A/B testing framework
- Build parameter sweep optimizer for new assets
- Add human preference validation (in-game testing)
