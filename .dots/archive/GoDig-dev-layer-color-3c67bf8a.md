---
title: "implement: Layer color palettes"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-16T02:00:41.400384-06:00\""
closed-at: "2026-01-19T19:34:38.759830-06:00"
close-reason: Layer colors in layer resources
---

## Description

Define distinct color palettes for each underground layer. Provides visual feedback on depth progression and creates unique atmosphere per zone.

## Context

- Color progression: warm browns -> neutral grays -> cool blues -> hot reds -> mysterious purple
- Each layer should feel visually distinct
- Colors stored in LayerData resources for easy tweaking
- Applied via block tinting and/or TileSet atlas selection

## Affected Files

- `resources/layers/*.tres` - Add color palette properties
- `resources/layers/layer_data.gd` - Add color exports
- `scripts/world/dirt_block.gd` or TileMap - Apply layer colors

## Implementation Notes

### LayerData Color Properties

```gdscript
# layer_data.gd additions
@export_group("Visual")
@export var primary_color: Color = Color.WHITE  # Main block tint
@export var secondary_color: Color = Color.WHITE  # Variation/accent
@export var ambient_color: Color = Color.WHITE  # Background/lighting hint
@export var ore_tint: Color = Color.WHITE  # Tint applied to ores in this layer
```

### Layer Color Palettes

| Layer | Depth | Primary | Secondary | Ambient | Notes |
|-------|-------|---------|-----------|---------|-------|
| Topsoil | 0-50m | #8B6914 (brown) | #6B5310 (dark brown) | #FFF8DC (cornsilk) | Warm earth tones |
| Subsoil | 50-200m | #9C6B42 (sienna) | #7A5333 (darker) | #DEB887 (burlywood) | Reddish brown clay |
| Stone | 200-500m | #808080 (gray) | #696969 (dim gray) | #A9A9A9 (dark gray) | Neutral rock |
| Deep Stone | 500-1000m | #4A4A4A (dark gray) | #363636 (charcoal) | #2F2F2F (very dark) | Getting darker |
| Crystal Caves | 1000-1500m | #4169E1 (royal blue) | #1E90FF (dodger blue) | #6495ED (cornflower) | Cool, crystalline |
| Magma Zone | 1500-2500m | #8B0000 (dark red) | #B22222 (firebrick) | #FF4500 (orange-red) | Hot, dangerous |
| Void Depths | 2500m+ | #2E0854 (dark purple) | #1A0033 (near black) | #4B0082 (indigo) | Mysterious end-game |

### Block Color Application

Option A: Tint existing blocks (simple)
```gdscript
# dirt_block.gd
func set_layer(layer: LayerData) -> void:
    # Apply primary color as tint
    modulate = layer.primary_color

    # Random variation between primary and secondary
    if randf() > 0.7:
        modulate = layer.secondary_color
```

Option B: TileSet atlas per layer (more work, better visual)
```gdscript
# Each layer has its own row in the tileset atlas
# tile_types.gd
func get_tile_atlas_row(layer_id: String) -> int:
    match layer_id:
        "topsoil": return 0
        "subsoil": return 1
        "stone": return 2
        # etc
```

### Ore Color Integration

Ores should still be recognizable across layers:
```gdscript
func get_ore_display_color(ore: OreData, layer: LayerData) -> Color:
    # Blend ore color with layer tint
    var ore_color := ore.color
    var layer_tint := layer.ore_tint
    return ore_color.blend(layer_tint)
```

### Visual Examples

**Topsoil (0-50m)**:
```
Brown dirt blocks, occasional darker patches
Feels like digging in garden soil
```

**Crystal Caves (1000-1500m)**:
```
Blue-tinted rock with occasional sparkle
Crystalline structures visible
Eerie but beautiful
```

**Magma Zone (1500-2500m)**:
```
Red/orange blocks, pulsing glow effect
Lava veins visible
Dangerous atmosphere
```

### Data-Driven Configuration

Store in LayerData .tres files:
```
# resources/layers/crystal_caves.tres
[resource]
script = ExtResource("layer_data.gd")
id = "crystal_caves"
display_name = "Crystal Caves"
min_depth = 1000
max_depth = 1500
primary_color = Color(0.255, 0.412, 0.882, 1)  # #4169E1
secondary_color = Color(0.118, 0.565, 1, 1)     # #1E90FF
ambient_color = Color(0.392, 0.584, 0.929, 1)   # #6495ED
```

## Edge Cases

- Transition zones: Blend colors between adjacent layers
- Ore visibility: Ensure ores remain distinguishable against layer colors
- Accessibility: Colors should have sufficient contrast (see colorblind mode)
- Night mode: Consider darker variants for eye comfort

## Verify

- [ ] Build succeeds
- [ ] Topsoil blocks appear brown/earth-toned
- [ ] Stone layer blocks appear gray
- [ ] Crystal caves have blue tint
- [ ] Magma zone has red/orange tint
- [ ] Layer transitions blend colors smoothly
- [ ] Ores remain visible against layer backgrounds
- [ ] Colors match the intended atmosphere for each layer
- [ ] Performance acceptable with color modulation
