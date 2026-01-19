---
title: "research: ItemData vs OreData unification"
status: open
priority: 1
issue-type: task
created-at: "2026-01-18T23:35:22.977689-06:00"
---

InventoryManager uses ItemData, DataRegistry has OreData. Are these the same? Should ore drops create ItemData instances? How does the item registry work for from_dict()? Check resources/items/ structure and reconcile with ores/gems resources.

## Research Findings

See `GoDig-research-ore-spawning-bdc2945d` for full analysis. Summary:

### Current State

Two parallel resource systems with duplicated data:
- `OreData` in `resources/ores/` - 5 ores + 1 gem
- `ItemData` in `resources/items/` - 6 items with matching IDs

Overlapping fields: id, display_name, sell_value, max_stack, rarity, min_depth

### Recommended Solution: OreData extends ItemData

1. **Modify OreData** to extend ItemData instead of Resource
2. **Move ore .tres files** from `resources/ores/` to `resources/items/` (or keep separate, doesn't matter)
3. **Remove duplicate ItemData .tres files** for ores
4. **Update DataRegistry** to load ores into both `ores` and `items` dictionaries
5. **Test level** can use `DataRegistry.get_ore(item_id)` directly since OreData IS-A ItemData

### Implementation Details

```gdscript
# ore_data.gd
class_name OreData extends ItemData

## Generation parameters (not in ItemData)
@export_group("Generation")
@export var spawn_threshold: float = 0.75
@export var noise_frequency: float = 0.05
@export var vein_size_min: int = 2
@export var vein_size_max: int = 6

## Mining parameters (not in ItemData)
@export_group("Mining")
@export var hardness: int = 2
@export var required_tool_tier: int = 0

## Visual (not in ItemData)
@export var color: Color = Color.WHITE
@export var tile_atlas_coords: Vector2i = Vector2i.ZERO
```

Fields that move to ItemData base class (already there):
- id, display_name, icon, category, max_stack, sell_value, rarity, min_depth, description

### Benefits

- Single source of truth for sell_value, rarity, etc.
- OreData can be used directly with InventoryManager
- Non-mineable items (consumables, tools) stay as plain ItemData
- DataRegistry can return OreData from get_item() for ore IDs
