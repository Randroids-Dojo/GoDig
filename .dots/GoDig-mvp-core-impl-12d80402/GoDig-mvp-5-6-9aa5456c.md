---
title: "implement: 5-6 ore types with depth rarity"
status: open
priority: 0
issue-type: task
created-at: "2026-01-16T00:34:22.341291-06:00"
after:
  - GoDig-mvp-3-4-42c5e3a3
---

## Description

Implement 5 ores (Coal, Copper, Iron, Silver, Gold) plus 1 gem type (Ruby). Each ore appears only within specific depth ranges and spawns in natural-looking veins using noise-based generation.

## Context

Ores are the core collectible resource. Players dig to find ores, sell them for coins, and buy better tools. Depth-gating creates progression - you must go deeper to find rarer, more valuable ores.

## Affected Files

- `resources/ores/ore_data.gd` - NEW: Resource class for ore definitions
- `resources/ores/coal.tres` - NEW: Ore definition
- `resources/ores/copper.tres` - NEW: Ore definition
- `resources/ores/iron.tres` - NEW: Ore definition
- `resources/ores/silver.tres` - NEW: Ore definition
- `resources/ores/gold.tres` - NEW: Ore definition
- `resources/gems/ruby.tres` - NEW: Gem definition
- `scripts/world/ore_generator.gd` - NEW: Noise-based ore placement
- `scripts/world/dirt_grid.gd` - MODIFY: Integrate ore generation
- `scripts/autoload/data_registry.gd` - MODIFY: Load ore definitions

## Implementation Notes

### OreData Resource

```gdscript
class_name OreData extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var min_depth: int = 0
@export var max_depth: int = 500  # -1 for infinite
@export var spawn_threshold: float = 0.75  # Higher = rarer
@export var noise_frequency: float = 0.05  # Cluster size
@export var vein_size_min: int = 2
@export var vein_size_max: int = 6
@export var sell_value: int = 1
@export var max_stack: int = 99
@export var tile_atlas_coords: Vector2i = Vector2i.ZERO
@export var color: Color = Color.WHITE
@export var rarity: String = "common"
```

### Ore Definitions (MVP)

| Ore | Depth Range | Threshold | Vein Size | Sell Value |
|-----|-------------|-----------|-----------|------------|
| Coal | 0-500m | 0.75 | 3-8 | 1 |
| Copper | 10-300m | 0.78 | 2-6 | 5 |
| Iron | 50-600m | 0.82 | 2-5 | 10 |
| Silver | 200-800m | 0.88 | 2-4 | 25 |
| Gold | 300-1000m | 0.92 | 1-3 | 100 |
| Ruby | 500m+ | 0.97 | 1-2 | 500 |

### OreGenerator

```gdscript
extends Node

var ore_noises: Dictionary = {}  # One FastNoiseLite per ore

func _ready():
    _initialize_noises()

func _initialize_noises():
    var base_seed = GameManager.world_seed
    for ore_id in DataRegistry.ores.keys():
        var ore = DataRegistry.get_ore(ore_id)
        var noise = FastNoiseLite.new()
        noise.seed = base_seed + ore_id.hash()
        noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
        noise.frequency = ore.noise_frequency
        ore_noises[ore_id] = noise
```

### Ore Placement Check

```gdscript
func should_place_ore(world_pos: Vector2i, ore_id: String) -> bool:
    var ore = DataRegistry.get_ore(ore_id)
    var depth = world_pos.y - GameManager.SURFACE_ROW

    # Check depth bounds
    if depth < ore.min_depth:
        return false
    if ore.max_depth > 0 and depth > ore.max_depth:
        return false

    # Get noise value (-1 to 1, normalize to 0-1)
    var noise = ore_noises[ore_id]
    var noise_value = (noise.get_noise_2d(world_pos.x, world_pos.y) + 1) / 2.0

    return noise_value > ore.spawn_threshold
```

### Vein Expansion (Random Walk)

When an ore placement is triggered, expand it into a natural vein:

```gdscript
func generate_vein(start_pos: Vector2i, ore_id: String) -> Array[Vector2i]:
    var ore = DataRegistry.get_ore(ore_id)
    var vein_size = randi_range(ore.vein_size_min, ore.vein_size_max)
    var positions: Array[Vector2i] = [start_pos]

    var directions = [
        Vector2i(1, 0), Vector2i(-1, 0),
        Vector2i(0, 1), Vector2i(0, -1),
    ]

    var current = start_pos
    for i in range(vein_size - 1):
        var dir = directions[randi() % directions.size()]
        current = current + dir
        if current not in positions:
            positions.append(current)

    return positions
```

### Generation Priority

Rarer ores take priority to avoid being overwritten:

```gdscript
func get_ore_at_position(world_pos: Vector2i) -> String:
    # Check rarest first (Gold, Silver, Iron, Copper, Coal)
    var priority_order = ["ruby", "gold", "silver", "iron", "copper", "coal"]

    for ore_id in priority_order:
        if should_place_ore(world_pos, ore_id):
            return ore_id

    return ""  # No ore
```

### Integration with Grid Generation

When generating blocks in dirt_grid.gd:

```gdscript
func _create_block(grid_pos: Vector2i) -> void:
    var ore_id = OreGenerator.get_ore_at_position(grid_pos)

    if ore_id != "":
        # Create ore block
        _create_ore_block(grid_pos, ore_id)
    else:
        # Create normal terrain block
        _create_terrain_block(grid_pos)
```

### Drop on Destroy

When ore block is destroyed, add to inventory:

```gdscript
func _on_block_destroyed(grid_pos: Vector2i, ore_id: String):
    var ore = DataRegistry.get_ore(ore_id)
    var item = ItemData.from_ore(ore)
    var overflow = InventoryManager.add_item(item, 1)
    if overflow > 0:
        # Show "Inventory Full" notification
        pass
```

## Edge Cases

- Ore can appear on layer boundaries (check both layer's ore list)
- Veins should not extend past world boundaries
- Same position can only have one ore type (priority system)
- Gems are single tiles, not veins (vein_size 1-2)

## Verify

- [ ] Build succeeds with no errors
- [ ] OreData resources load in DataRegistry
- [ ] Coal appears only at depth 0-500m
- [ ] Gold appears only at depth 300m+
- [ ] Ore veins form natural 2-8 block clusters
- [ ] Rarer ores (gold, silver) appear less frequently
- [ ] Destroying ore block adds item to inventory
- [ ] Ruby (gem) appears as single blocks at 500m+
