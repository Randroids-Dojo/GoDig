---
title: "research: ItemData vs OreData unification"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"2026-01-18T23:35:22.977689-06:00\\\"\""
closed-at: "2026-01-19T11:43:51.251334-06:00"
close-reason: Verified current data flow, documented critical category field requirement, updated implementation spec with complete steps and verification checklist
---

InventoryManager uses ItemData, DataRegistry has OreData. Are these the same? Should ore drops create ItemData instances? How does the item registry work for from_dict()? Check resources/items/ structure and reconcile with ores/gems resources.

## Research Findings

### Current State (Verified 2026-01-19)

Two parallel resource systems with duplicated data:
- `OreData` in `resources/ores/` - 5 ores (coal, copper, iron, silver, gold)
- `OreData` in `resources/gems/` - 1 gem (ruby)
- `ItemData` in `resources/items/` - 6 items with matching IDs (coal, copper, iron, silver, gold, ruby)

**Data Flow:**
1. `DirtGrid._determine_ore_spawn()` uses `DataRegistry.get_ore()` to get OreData for generation
2. `DirtGrid.hit_block()` emits `block_dropped(pos, ore_id)` with the ore's ID string
3. `TestLevel._on_block_dropped()` calls `DataRegistry.get_item(item_id)` to get ItemData for inventory
4. `InventoryManager.add_item()` expects `ItemData` type
5. `Shop._refresh_sell_tab()` checks `slot.item.category` (from ItemData) for "ore" or "gem"

**Critical Field: `category`**
The shop explicitly checks `slot.item.category in ["ore", "gem"]` (shop.gd:73-74, 163) to determine sellable items. OreData currently lacks this field, relying on duplicate ItemData files to provide it.

**Overlapping fields:**
- Both have: `id`, `display_name`, `icon`, `sell_value`, `max_stack`, `rarity`, `min_depth`
- OreData adds: `color`, `tile_atlas_coords`, `spawn_threshold`, `noise_frequency`, `vein_size_min/max`, `max_depth`, `tier`, `hardness`, `required_tool_tier`
- ItemData adds: `category`, `description`

**Problem:**
- Maintenance burden (sell_value, rarity must match in two files)
- Risk of desync between OreData and ItemData definitions
- Wasted memory loading duplicate data

### Recommended Solution: OreData extends ItemData

1. **Modify OreData** to extend ItemData instead of Resource
2. **Add inherited fields to ore .tres files**: `category` ("ore" or "gem") and `description`
3. **Remove duplicate ItemData .tres files** for ores (coal, copper, iron, silver, gold, ruby)
4. **Update DataRegistry** to load ores into `items` dictionary too
5. **Remove `tier` from OreData** (already have `rarity` string which serves same purpose)

### Implementation Details

```gdscript
# ore_data.gd - AFTER refactoring
class_name OreData extends ItemData

## Generation parameters (OreData-specific)
@export_group("Generation")
@export var spawn_threshold: float = 0.75
@export var noise_frequency: float = 0.05
@export var vein_size_min: int = 2
@export var vein_size_max: int = 6
@export var max_depth: int = -1  # -1 = no limit (ItemData only has min_depth)

## Mining parameters (OreData-specific)
@export_group("Mining")
@export var hardness: int = 2
@export var required_tool_tier: int = 0

## Visual (OreData-specific)
@export_group("Visual")
@export var color: Color = Color.WHITE
@export var tile_atlas_coords: Vector2i = Vector2i.ZERO
```

**Fields inherited from ItemData:**
- `id`, `display_name`, `icon`, `category`, `max_stack`, `sell_value`, `rarity`, `min_depth`, `description`

**Fields to REMOVE from OreData:**
- `id`, `display_name`, `icon`, `max_stack`, `sell_value`, `rarity`, `min_depth` (inherited)
- `tier` (redundant with `rarity`)

### DataRegistry Update

```gdscript
func _load_all_ores() -> void:
    _load_ores_from_directory("res://resources/ores/")
    _load_ores_from_directory("res://resources/gems/")

    # Register ores as items too (OreData IS-A ItemData)
    for ore_id in ores:
        items[ore_id] = ores[ore_id]

    _ores_by_depth = ores.values()
    _ores_by_depth.sort_custom(func(a, b): return a.min_depth < b.min_depth)
```

### Benefits

- Single source of truth for sell_value, rarity, etc.
- OreData can be used directly with InventoryManager (no lookup conversion)
- Shop.gd works unchanged (OreData will have `category` field)
- Non-mineable items (consumables, tools) stay as plain ItemData
- Saves memory (6 fewer Resource objects)

### Created Implementation Spec

See `GoDig-implement-unify-oredata-8388f176` for detailed implementation steps and verification checklist.
