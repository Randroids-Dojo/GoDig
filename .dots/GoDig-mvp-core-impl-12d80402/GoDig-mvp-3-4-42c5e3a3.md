---
title: "implement: 3-4 layer types with hardness"
status: closed
priority: 0
issue-type: task
created-at: "\"\\\"2026-01-16T00:34:21.393081-06:00\\\"\""
closed-at: "2026-01-18T23:18:55.149632-06:00"
close-reason: Implemented 4 layer types (topsoil/subsoil/stone/deep_stone) with depth-based hardness and colors. Created LayerData resource, DataRegistry autoload, 4 .tres definitions. All 17 tests pass.
---

## Description

Create 4 distinct underground layer types with increasing hardness. Each layer has unique visual identity and requires better tools to mine efficiently.

## Context

Layer progression is the backbone of the game's difficulty curve. Topsoil is easy, Deep Stone requires upgraded tools. This creates natural progression gates without blocking players completely.

## Affected Files

- `resources/layers/layer_data.gd` - NEW: Resource class for layer definitions
- `resources/layers/topsoil.tres` - NEW: Layer definition file
- `resources/layers/subsoil.tres` - NEW: Layer definition file
- `resources/layers/stone.tres` - NEW: Layer definition file
- `resources/layers/deep_stone.tres` - NEW: Layer definition file
- `scripts/world/dirt_block.gd` - MODIFY: Support block types with hardness
- `scripts/world/dirt_grid.gd` - MODIFY: Assign block types based on depth
- `scripts/autoload/data_registry.gd` - NEW: Load all layer definitions at startup

## Implementation Notes

### LayerData Resource

```gdscript
class_name LayerData extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var min_depth: int = 0
@export var max_depth: int = 50
@export var base_hardness: float = 10.0
@export var color_primary: Color = Color.BROWN
@export var color_accent: Color = Color.TAN
@export var tile_atlas_coords: Vector2i = Vector2i.ZERO
```

### Layer Definitions (MVP)

| Layer | Depth | Hardness | Color | Hits to Break (Tier 1 tool) |
|-------|-------|----------|-------|----------------------------|
| Topsoil | 0-50m | 10-15 | Brown | 1-2 |
| Subsoil | 50-200m | 15-25 | Dark brown | 2-3 |
| Stone | 200-500m | 30-50 | Gray | 3-5 |
| Deep Stone | 500m+ | 50-80 | Dark gray | 5-8 |

### Break Time Formula

```gdscript
func calculate_break_time(block_hardness: float, tool_damage: float) -> int:
    # Returns number of hits needed
    return ceil(block_hardness / tool_damage)
```

### Depth-Based Layer Selection

```gdscript
func get_layer_at_depth(depth: int) -> LayerData:
    for layer in DataRegistry.layers:
        if depth >= layer.min_depth and depth < layer.max_depth:
            return layer
    return DataRegistry.get_layer("deep_stone")  # Default deepest

func get_block_hardness(grid_pos: Vector2i) -> float:
    var depth = grid_pos.y - GameManager.SURFACE_ROW
    var layer = get_layer_at_depth(depth)

    # Add some variance within layer
    var variance = randf_range(0.9, 1.1)
    return layer.base_hardness * variance
```

### Transition Zones

Between layers, blend properties:
- At depth 45-55: Mix Topsoil/Subsoil colors and hardness
- Random chance of either block type in transition zone

```gdscript
func is_transition_zone(depth: int, layer: LayerData) -> bool:
    var transition_range = 10
    return depth >= layer.max_depth - transition_range and depth < layer.max_depth
```

### Visual Differentiation

Each layer needs:
1. Different base tile sprite (in TileSet)
2. Different color modulation
3. (v1.0) Different particle effects on break

### Refactor DirtBlock

Current dirt_block.gd has fixed health. Change to:

```gdscript
@export var block_type: String = "topsoil"
var max_health: float
var current_health: float

func _ready():
    var layer = DataRegistry.get_layer(block_type)
    max_health = layer.base_hardness
    current_health = max_health
    _update_visual(layer)

func _update_visual(layer: LayerData):
    modulate = layer.color_primary
    # Or set tile atlas coords if using TileMap
```

## Edge Cases

- Depth 0 = surface (no digging)
- Negative depths invalid (player cannot go above surface)
- Hardness variance should be deterministic (use position as seed)

## Verify

- [ ] Build succeeds with no errors
- [ ] LayerData resources load correctly in DataRegistry
- [ ] Topsoil blocks at depth 0-50m have correct hardness
- [ ] Stone blocks at depth 200-500m require more hits to break
- [ ] Block colors change visually between layers
- [ ] Transition zones show mixed block types
- [ ] Break time formula correctly uses block hardness and tool damage
