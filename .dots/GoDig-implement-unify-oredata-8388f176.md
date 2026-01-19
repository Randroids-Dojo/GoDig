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

### CRITICAL: The `category` Field

The shop UI (`scripts/ui/shop.gd`, lines 73-74 and 163) explicitly checks:
```gdscript
if slot.item.category not in ["ore", "gem"]:
    continue
```

This means **every OreData .tres file MUST include the `category` field** after the refactoring, or the shop will not display them as sellable items.

### Step 1: Modify ore_data.gd

```gdscript
class_name OreData extends ItemData  # <-- Changed from Resource

## Generation parameters (OreData-specific)
@export_group("Generation")
@export var spawn_threshold: float = 0.75
@export_range(0.01, 0.5) var noise_frequency: float = 0.05
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

# Keep helper methods: can_spawn_at_depth(), get_random_vein_size()
```

**Fields to REMOVE from ore_data.gd (inherited from ItemData):**
- `id`, `display_name`, `icon` (base identity)
- `max_stack`, `sell_value`, `rarity`, `min_depth`, `description` (economy/UI)
- `tier` (redundant with `rarity` string - remove entirely)

Note: Keep `max_depth` in OreData since ItemData doesn't have it.

### Step 2: Update OreData .tres Files

For each ore .tres file in `resources/ores/` and `resources/gems/`:

1. **Add required ItemData fields:**
```tres
category = "ore"  # or "gem" for ruby
description = "A common fuel source found near the surface."
```

2. **Remove the `tier` field** (use `rarity` instead, which is inherited)

3. **Keep all existing fields** - they will be a mix of inherited (id, display_name, etc.) and OreData-specific (spawn_threshold, color, etc.)

Example updated coal.tres:
```tres
[gd_resource type="Resource" script_class="OreData" load_steps=2 format=3]

[ext_resource type="Script" path="res://resources/ores/ore_data.gd" id="1_ore_data"]

[resource]
script = ExtResource("1_ore_data")
# Inherited from ItemData:
id = "coal"
display_name = "Coal"
category = "ore"
max_stack = 99
sell_value = 1
rarity = "common"
min_depth = 0
description = "A common fuel source found near the surface."
# OreData-specific:
color = Color(0.2, 0.2, 0.2, 1)
tile_atlas_coords = Vector2i(0, 1)
max_depth = 500
spawn_threshold = 0.75
noise_frequency = 0.08
vein_size_min = 3
vein_size_max = 8
hardness = 2
required_tool_tier = 0
```

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
- [ ] `resources/items/` no longer contains ore/gem .tres files (6 files deleted)
- [ ] `DataRegistry.get_item("coal")` returns the OreData resource
- [ ] `DataRegistry.get_ore("coal")` still works
- [ ] Mining a coal block adds coal to inventory
- [ ] **Shop displays mined ores in sell tab** (critical - tests category field)
- [ ] Shop "Sell All" button includes ores and gems
- [ ] Shop can sell coal using the ore's sell_value
- [ ] InventoryManager.from_dict() correctly loads saved ore items
- [ ] Floating text on pickup shows correct ore color
