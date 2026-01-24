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
├── texture_validator.py         # Terrain texture validator
├── primer_validator.py          # Regression prevention
├── validate_all.py              # Unified validation command
├── generate_asset_report.py     # Markdown report generator
├── generate_dirt_textures.py    # Terrain atlas generator
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

resources/tileset/
├── terrain_atlas.png            # Generated terrain atlas (768x384)
└── terrain.tres                 # Godot TileSet resource
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

## Terrain Texture Generation

### Overview

Terrain tiles (dirt, stone, ores, gems) use **procedural generation** rather than AI-based generation. This approach provides:
- Perfect reproducibility via seeds
- Fast iteration (< 1 second per atlas)
- No external dependencies (pure Python + Pillow)
- Consistent quality across all tiles

### Key Techniques

**1. Multi-Tone Palettes**
Each material uses 3-4 colors for proper pixel art shading:
```python
MaterialPalette(
    base=(139, 90, 43),    # Main color
    light=(169, 120, 73),  # Highlight
    dark=(99, 60, 23),     # Shadow
    accent=(79, 50, 18)    # Optional detail
)
```

**2. Layered Value Noise**
Combine multiple octaves for natural-looking variation:
- 3 octaves with decreasing amplitude (1.0, 0.5, 0.25)
- Scale decreases per octave (16, 8, 4 pixels)
- Smooth interpolation with cubic hermite

**3. Ordered Dithering (Bayer 4x4)**
Apply dithering for authentic pixel art aesthetic:
```python
bayer_4x4 = [
    [0, 8, 2, 10],
    [12, 4, 14, 6],
    [3, 11, 1, 9],
    [15, 7, 13, 5]
]
```

**4. Edge Darkening**
Darken pixels near tile edges for depth perception:
- 4-pixel border gradient
- Factor: 0.7 at edge → 1.0 at interior

**5. Detail Elements**
- **Terrain tiles**: Small rock details (3-8px ellipses)
- **Ore tiles**: Vein patterns with bright highlights
- **Gem tiles**: Hexagonal crystal formations with facets

### Terrain Texture Validator

The texture validator (`scripts/tools/texture_validator.py`) checks:

| Metric | Target | Notes |
|--------|--------|-------|
| Unique Colors | 15-25 | Limited palette after dithering |
| Palette Adherence | ≥0.70 | Top 4 colors cover 70%+ pixels |
| Edge Contrast | <30 | Low contrast for seamless tiling |
| Noise Variance | 10-50 | Good texture without chaos |

### Current Terrain Scores

| Tile | Score | Colors | Edge | Noise |
|------|-------|--------|------|-------|
| Dirt | 0.94 | 20 | 13.3 | 19.1 |
| Clay | 0.94 | 20 | 18.5 | 20.0 |
| Stone | 0.95 | 18 | 19.5 | 25.2 |
| Granite | 0.94 | 20 | 16.4 | 22.4 |
| Basalt | 0.94 | 20 | 13.6 | 17.1 |
| Obsidian | 0.95 | 15 | 10.9 | 12.0 |
| **Average** | **0.95** | - | - | - |

### Iteration Workflow

```bash
# Generate with different seeds
python scripts/tools/generate_dirt_textures.py --seed 42
python scripts/tools/generate_dirt_textures.py --seed 777

# Validate results
python scripts/tools/texture_validator.py

# Compare two atlases
python scripts/tools/texture_validator.py --compare path/to/other_atlas.png

# Generate single tile for testing
python scripts/tools/generate_dirt_textures.py --single dirt --seed 123
```

### Why Procedural vs AI for Terrain

| Approach | Terrain Tiles | Character Sprites |
|----------|---------------|-------------------|
| **Procedural** | ✅ Best choice | Limited use |
| **Composable** | N/A | ✅ Best choice |
| **AI (MFLUX)** | Overkill | Static assets only |

Terrain tiles benefit from:
- Seamless tiling (procedural guarantees this)
- Consistent style across all tiles
- Fast regeneration for iteration
- Deterministic results for version control

---

## Future Improvements

- Add visual comparison tool that shows designs side-by-side with scores
- Create automated A/B testing framework
- Build parameter sweep optimizer for new assets
- Add human preference validation (in-game testing)
- Add seamless tiling validation for terrain textures
- Create texture variation system (same material, different seed per instance)
