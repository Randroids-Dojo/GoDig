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
- Skin: (255,218,185), (228,180,140), (180,130,100)
- Metal: (200,200,210), (120,120,130), (60,60,70)
- Wood: (180,120,60), (139,90,43), (100,60,25)
- Work gloves: Distinct from both skin and wood for visual separation

### Shading Quality
- **Luminance range**: 60-120 is optimal (good contrast without extremes)
- **Standard deviation**: 25-50 is optimal (varied but not chaotic)
- Too high std_dev (>50) gets penalized
- Too flat (<30 range) gets penalized

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
7. **Keep primer backup** of best-scoring design
8. **Only replace primer** if new design scores equal or higher

### File Organization
```
scripts/tools/
├── component_validator.py      # General quality validator
├── <asset>_validator.py        # Asset-specific validator
├── <asset>_<variant>.py        # Design variant generators
├── improved_sprite_builder.py  # Main sprite assembly
└── debug_<aspect>.py           # Debug/analysis scripts

resources/sprites/components/
├── body.png
├── head.png
├── arm.png
├── left_arm.png
├── <asset>.png
└── frame_XX_<pose>.png         # Assembled animation frames
```

## Metrics Summary

| Component | Target Score | Key Metrics |
|-----------|-------------|-------------|
| Body | 0.89+ | Pixel density 0.45+, Shading 0.90 |
| Head | 0.93+ | Color coherence 1.00, Shading 0.90 |
| Arms | 0.87+ | Shading quality key limiter (std_dev balance) |
| Pickaxe | 0.91+ | Color coherence 1.00, Shading 0.90 |
| **Average** | **0.90+** | Clean components directory |

## Future Improvements

- Add visual comparison tool that shows designs side-by-side with scores
- Create automated A/B testing framework
- Build parameter sweep optimizer for new assets
- Add human preference validation (in-game testing)
