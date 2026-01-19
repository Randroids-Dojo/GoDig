---
title: "implement: Unify OreData and ItemData resources"
status: open
priority: 1
issue-type: task
created-at: "2026-01-18T23:46:04.458128-06:00"
---

Make OreData extend ItemData, remove duplicate .tres files, update DataRegistry to load ores as items too. See GoDig-research-itemdata-vs-c373f473 for full spec.

## Description

Unify the OreData and ItemData resource classes to eliminate duplication. Ores should inherit from ItemData so they can be used directly in the inventory system without maintaining parallel .tres files.

## Context

Currently the codebase has:
- 5 OreData .tres files in `resources/ores/` (coal, copper, iron, silver, gold)
- 1 OreData .tres file in `resources/gems/` (ruby)
- 6 ItemData .tres files in `resources/items/` with matching IDs and duplicated sell_value, rarity, etc.

This creates a maintenance burden and risk of desync. The fix is inheritance: OreData extends ItemData.

## Affected Files

- `resources/ores/ore_data.gd` - Change to extend ItemData
- `resources/ores/*.tres` - Update to include ItemData fields (category, description)
- `resources/gems/*.tres` - Update to include ItemData fields
- `resources/items/*.tres` - DELETE the 6 ore/gem files (coal, copper, iron, silver, gold, ruby)
- `scripts/autoload/data_registry.gd` - Load ores into `items` dictionary too
- `scripts/test_level.gd` - Use `DataRegistry.get_ore()` instead of `get_item()` (optional but cleaner)

## Implementation Notes

### Step 1: Modify ore_data.gd

```gdscript
class_name OreData extends ItemData  # <-- Changed from Resource

## Generation parameters (OreData-specific)
@export_group("Generation")
@export var spawn_threshold: float = 0.75
# ... rest of generation fields stay the same

## Mining parameters (OreData-specific)
@export_group("Mining")
@export var hardness: int = 2
@export var required_tool_tier: int = 0

## Visual (OreData-specific)
@export var color: Color = Color.WHITE
@export var tile_atlas_coords: Vector2i = Vector2i.ZERO

# Remove: id, display_name, icon, max_stack, sell_value, tier, rarity, min_depth, max_depth
# These are now inherited from ItemData
```

Note: Keep `max_depth` in OreData since ItemData doesn't have it (ItemData has min_depth only for UI hints).

### Step 2: Update OreData .tres Files

Add missing ItemData fields to each ore .tres:
```
category = "ore"
description = "..."
```

Remove duplicate fields that are now in ItemData (they'll be inherited).

### Step 3: Update DataRegistry

```gdscript
func _load_all_ores() -> void:
    _load_ores_from_directory("res://resources/ores/")
    _load_ores_from_directory("res://resources/gems/")

    # Also register ores as items for inventory compatibility
    for ore_id in ores:
        items[ore_id] = ores[ore_id]  # OreData IS-A ItemData

    _ores_by_depth = ores.values()
    _ores_by_depth.sort_custom(func(a, b): return a.min_depth < b.min_depth)
```

### Step 4: Delete Duplicate ItemData Files

Remove these files from `resources/items/`:
- coal.tres
- copper.tres
- iron.tres
- silver.tres
- gold.tres
- ruby.tres

### Step 5: Update test_level.gd (Optional Cleanup)

Can simplify `_on_block_dropped()` since ore IS-A item now:
```gdscript
func _on_block_dropped(grid_pos: Vector2i, item_id: String) -> void:
    if item_id.is_empty():
        return

    # OreData extends ItemData, so get_ore() returns something usable by InventoryManager
    var ore = DataRegistry.get_ore(item_id)
    if ore == null:
        push_warning("[TestLevel] Unknown ore dropped: %s" % item_id)
        return

    var leftover := InventoryManager.add_item(ore, 1)
    # ... rest stays the same
```

## Verify

- [ ] Build succeeds with no GDScript errors
- [ ] OreData.gd compiles with `extends ItemData`
- [ ] All ore .tres files load without errors in Godot editor
- [ ] `resources/items/` no longer contains ore/gem .tres files
- [ ] `DataRegistry.get_item("coal")` returns the OreData resource
- [ ] `DataRegistry.get_ore("coal")` still works
- [ ] Mining a coal block adds coal to inventory
- [ ] Shop can sell coal using the ore's sell_value
- [ ] InventoryManager.from_dict() correctly loads saved ore items
