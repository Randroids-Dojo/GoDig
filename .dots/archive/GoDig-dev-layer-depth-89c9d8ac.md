---
title: "implement: Layer depth boundaries"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-16T02:00:40.076661-06:00\""
closed-at: "2026-01-19T11:25:25.000068-06:00"
close-reason: LayerData class and all 4 layer .tres files already exist with depth boundaries
blocks:
  - GoDig-dev-define-7-d4679cf5
---

## Description

Create the LayerData resource class that defines the depth boundaries and properties for each underground layer.

## Context

The world is divided into vertical layers, each with distinct visuals, hardness, and ore spawns. The LayerData resource stores these properties so the terrain generator can query them by depth.

From GAME_DESIGN_SUMMARY.md:

| Layer | Depth | Hardness | Primary Color |
|-------|-------|----------|---------------|
| Topsoil | 0-50m | 10-15 | Brown (#8B4513) |
| Subsoil | 50-200m | 15-25 | Dark brown (#5D3A1A) |
| Stone | 200-500m | 30-50 | Gray (#808080) |
| Deep Stone | 500-1km | 50-80 | Dark blue-gray (#2F4F4F) |

## Affected Files

- `resources/layers/layer_data.gd` - NEW: LayerData resource class
- May already exist (check first)

## Implementation Notes

### LayerData Resource Class

```gdscript
# resources/layers/layer_data.gd
class_name LayerData extends Resource

@export var id: String = ""
@export var display_name: String = ""

@export_group("Depth")
@export var min_depth: int = 0      # Start depth (blocks from surface)
@export var max_depth: int = 100    # End depth (-1 for infinite)

@export_group("Block Properties")
@export var base_hardness: int = 10
@export var hardness_variance: int = 5  # Random +/- variation
@export var primary_tile_type: int = 0   # TileTypes.Type enum value

@export_group("Visual")
@export var background_color: Color = Color.SADDLE_BROWN
@export var accent_color: Color = Color.SIENNA
@export var tint_modulate: Color = Color.WHITE  # Tile tint

@export_group("Spawns")
@export var ore_ids: Array[String] = []  # Which ores can spawn here
@export var ore_density: float = 0.1     # Base spawn chance per block


## Get hardness for a block in this layer (with variance)
func get_hardness(rng: RandomNumberGenerator = null) -> int:
    if hardness_variance == 0:
        return base_hardness
    if rng:
        return base_hardness + rng.randi_range(-hardness_variance, hardness_variance)
    return base_hardness + randi_range(-hardness_variance, hardness_variance)


## Check if an ore can spawn in this layer
func can_spawn_ore(ore_id: String) -> bool:
    return ore_id in ore_ids
```

### Depth Boundary Design Notes

- Depths are measured in blocks (1 block = 1 meter visually)
- Surface is at depth 0, increases downward
- max_depth of -1 means infinite (for the deepest layer)
- Layers should have small overlap zones for smooth transitions (optional)

## Verify

- [ ] Build succeeds
- [ ] LayerData resource class compiles without errors
- [ ] Can create a .tres file using LayerData
- [ ] `get_hardness()` returns value within variance range
- [ ] `can_spawn_ore()` correctly checks ore_ids array
- [ ] All @export properties appear in Godot inspector
