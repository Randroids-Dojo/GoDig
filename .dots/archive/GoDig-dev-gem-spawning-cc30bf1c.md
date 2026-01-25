---
title: "implement: Gem spawning system"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-16T00:38:22.817517-06:00\""
closed-at: "2026-01-24T21:46:46.003795+00:00"
close-reason: "Implemented: gems folder with ruby, emerald, sapphire, diamond resources"
---

## Description

Add gem spawning to the world generation. Gems are rare individual finds (not veins like ores) with depth-dependent spawn rates. Each gem type has its own spawn depth range and value tier.

## Context

Gems provide high-value finds that reward deeper exploration. Unlike ores which form veins, gems spawn as single isolated blocks, making them exciting discoveries. The existing OreData/GemData system in DataRegistry can be extended for gems.

## Affected Files

- `scripts/world/dirt_grid.gd` - Add gem spawn check in block generation
- `resources/gems/*.tres` - Gem data files (ruby exists, add others)
- `scripts/autoload/data_registry.gd` - Load gem data, add `get_gem_at_depth()` helper
- `resources/items/*.tres` - Add gem item definitions (if not using unified OreData)

## Implementation Notes

### Gem Types and Properties

| Gem | Min Depth | Max Depth | Spawn Chance | Sell Value |
|-----|-----------|-----------|--------------|------------|
| Ruby | 100 | -1 | 0.5% | 100 |
| Sapphire | 200 | -1 | 0.4% | 150 |
| Emerald | 300 | -1 | 0.3% | 200 |
| Diamond | 500 | -1 | 0.1% | 500 |
| Amethyst | 50 | 400 | 0.6% | 50 |

### Gem Spawn Logic

Gems are checked AFTER ore spawn fails. This ensures ores and gems don't compete.

```gdscript
# In DirtGrid._determine_block_content() or similar
func _determine_block_content(grid_pos: Vector2i) -> String:
    var depth := grid_pos.y - GameManager.SURFACE_ROW

    # First check for ore (existing logic)
    var ore_id := _determine_ore_spawn(grid_pos, depth)
    if not ore_id.is_empty():
        return ore_id

    # Then check for gem (independent chance)
    var gem_id := _determine_gem_spawn(grid_pos, depth)
    if not gem_id.is_empty():
        return gem_id

    return ""  # Plain dirt/stone


func _determine_gem_spawn(grid_pos: Vector2i, depth: int) -> String:
    # Get all gems that can spawn at this depth
    var valid_gems := DataRegistry.get_gems_at_depth(depth)
    if valid_gems.is_empty():
        return ""

    # Hash-based deterministic random per position
    var hash := _position_hash(grid_pos)
    var roll := fmod(hash, 10000.0) / 10000.0  # 0.0 to 1.0

    # Check each gem's spawn chance
    var cumulative := 0.0
    for gem in valid_gems:
        cumulative += gem.spawn_chance  # e.g., 0.005 for 0.5%
        if roll < cumulative:
            return gem.id

    return ""
```

### DataRegistry Gem Helpers

```gdscript
# data_registry.gd (additions)
var gems: Dictionary = {}  # gem_id -> GemData

func _load_all_gems() -> void:
    _load_resources_from_directory("res://resources/gems/", gems)

func get_gems_at_depth(depth: int) -> Array:
    var result := []
    for gem in gems.values():
        if gem.can_spawn_at_depth(depth):
            result.append(gem)
    return result

func get_gem(id: String) -> GemData:
    return gems.get(id)
```

### Gem Data Resource

If not unifying with OreData, gems can use the same structure:

```gdscript
# resources/gems/gem_data.gd (or use OreData)
class_name GemData extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var icon: Texture2D
@export var color: Color = Color.WHITE

@export_group("Generation")
@export var min_depth: int = 0
@export var max_depth: int = -1  # -1 = no max
@export var spawn_chance: float = 0.005  # 0.5%

@export_group("Economy")
@export var sell_value: int = 100
@export var max_stack: int = 99
@export var rarity: String = "rare"

func can_spawn_at_depth(depth: int) -> bool:
    if depth < min_depth:
        return false
    if max_depth > 0 and depth > max_depth:
        return false
    return true
```

### Visual Distinction

Gems should look distinct from ores:
- Brighter, more saturated colors
- Optional sparkle particle effect (separate dot: GoDig-dev-gem-sparkle)
- Different tile atlas region or tint

## Edge Cases

- Multiple gems valid at same depth: Use cumulative probability (first wins)
- Gem at exact depth boundary: Include if depth >= min_depth
- Gem and ore both valid: Ore takes priority (checked first)
- Very deep (>1000m): All gems available, Diamond most valuable

## Verify

- [ ] Build succeeds
- [ ] Gems do NOT spawn above their min_depth
- [ ] Gems appear as single blocks (not veins)
- [ ] Gem spawn rate is approximately correct (test 1000 blocks)
- [ ] Deeper gems are rarer
- [ ] Mining gem block adds gem to inventory
- [ ] Gem sell values are correct in shop
- [ ] Gems use correct colors/icons in inventory
