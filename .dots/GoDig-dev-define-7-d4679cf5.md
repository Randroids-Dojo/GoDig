---
title: "implement: Define 7 underground layer types"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T02:00:39.013590-06:00"
---

## Description

Create LayerData .tres files for all 7 underground layer types with their depth boundaries, hardness ranges, ore spawns, and color palettes.

## Context

From GAME_DESIGN_SUMMARY.md, layers define the vertical progression:

| Layer | Depth | Hardness | Ores | Hazards |
|-------|-------|----------|------|---------|
| Topsoil | 0-50m | 10-15 | Coal, Copper | None |
| Subsoil | 50-200m | 15-25 | Iron, Tin | Water pools |
| Stone | 200-500m | 30-50 | Silver, Gold | Caves |
| Deep Stone | 500-1km | 50-80 | Platinum, Gems | Lava, gas |
| Crystal | 1-2km | 80-120 | Mythril, Diamond | Enemies |
| Magma | 2-5km | 120-180 | Adamantine | Heat damage |
| Void | 5km+ | 200+ | Void Crystals | Unknown |

For MVP, focus on first 3-4 layers (Topsoil through Deep Stone).

## Affected Files

- `resources/layers/topsoil.tres` - NEW
- `resources/layers/subsoil.tres` - NEW
- `resources/layers/stone.tres` - NEW
- `resources/layers/deep_stone.tres` - NEW (stretch goal for MVP)
- `scripts/autoload/data_registry.gd` - Add `_load_all_layers()` method

## Implementation Notes

### LayerData Resource Structure

```gdscript
# resources/layers/layer_data.gd
class_name LayerData extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var min_depth: int = 0      # Start depth (meters/blocks)
@export var max_depth: int = 100    # End depth (-1 for infinite)

@export_group("Block Properties")
@export var base_hardness: int = 10
@export var hardness_variance: int = 5  # +/- random variation
@export var primary_tile_type: int = 0   # TileTypes.Type enum

@export_group("Visual")
@export var background_color: Color = Color.DARK_OLIVE_GREEN
@export var accent_color: Color = Color.OLIVE_DRAB
@export var tint_modulate: Color = Color.WHITE  # Applied to tiles

@export_group("Spawns")
@export var ore_ids: Array[String] = []  # Which ores can spawn
@export var ore_density: float = 0.1     # Chance per block
```

### MVP Layer Definitions

**Topsoil (0-50m)**
- id: "topsoil"
- hardness: 10-15
- ores: ["coal", "copper"]
- color: Brown (#8B4513)

**Subsoil (50-200m)**
- id: "subsoil"
- hardness: 15-25
- ores: ["coal", "copper", "iron"]
- color: Dark brown (#5D3A1A)

**Stone (200-500m)**
- id: "stone"
- hardness: 30-50
- ores: ["iron", "silver", "gold"]
- color: Gray (#808080)

**Deep Stone (500-1000m)** - stretch for MVP
- id: "deep_stone"
- hardness: 50-80
- ores: ["silver", "gold", "ruby"]
- color: Dark blue-gray (#2F4F4F)

### DataRegistry Integration

```gdscript
var layers: Dictionary = {}  # id -> LayerData
var _layers_by_depth: Array = []  # Sorted by min_depth

func get_layer_at_depth(depth: int) -> LayerData:
    for layer in _layers_by_depth:
        if depth >= layer.min_depth and (layer.max_depth == -1 or depth < layer.max_depth):
            return layer
    return _layers_by_depth[-1]  # Return deepest layer as fallback
```

## Verify

- [ ] Build succeeds
- [ ] All layer .tres files load without errors
- [ ] DataRegistry.get_layer("topsoil") returns valid LayerData
- [ ] DataRegistry.get_layer_at_depth(0) returns topsoil
- [ ] DataRegistry.get_layer_at_depth(100) returns subsoil
- [ ] DataRegistry.get_layer_at_depth(300) returns stone
- [ ] Each layer has correct depth boundaries
- [ ] Each layer has correct ore_ids array
- [ ] Hardness values match design spec
