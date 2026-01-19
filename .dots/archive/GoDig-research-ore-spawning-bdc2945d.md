---
title: "research: Ore spawning integration"
status: closed
priority: 0
issue-type: task
created-at: "\"\\\"2026-01-18T23:35:22.628926-06:00\\\"\""
closed-at: "2026-01-18T23:47:58.786638-06:00"
close-reason: "Completed research: documented current ore spawning architecture, identified ItemData/OreData duplication issue, created 4 implementation tasks for improvements"
---

How should ores spawn in blocks? DirtBlock currently uses DataRegistry for hardness/color but doesn't check for ores. Need to decide: Should each block have a chance to BE an ore? Or should ores be separate entities? How does hit_block() integrate with OreData? How should visual appearance change for ore blocks?

## Research Findings

### Current Architecture (Already Implemented)

Ore spawning is **already integrated** in the codebase. The system works as follows:

1. **OreData Resource** (`resources/ores/ore_data.gd`)
   - Defines ore properties: id, display_name, color, min_depth, max_depth, spawn_threshold, noise_frequency, vein_size, sell_value, hardness, etc.
   - Existing ores: coal, copper, iron, silver, gold (in `resources/ores/`)
   - Existing gems: ruby (in `resources/gems/`)

2. **DirtGrid Ore Spawning** (`scripts/world/dirt_grid.gd`)
   - `_ore_map: Dictionary[Vector2i, String ore_id]` tracks which blocks contain ores
   - `_determine_ore_spawn(pos)` is called when generating each block
   - Uses depth-gating via `DataRegistry.get_ores_at_depth(depth)`
   - Uses noise-based spawning with `spawn_threshold` (higher = rarer)
   - Rarest ores checked first (sorted by threshold descending)
   - Visual tinting applied via `_apply_ore_visual(pos, ore)` - blends 50% ore color with layer color

3. **Mining Drops** (`scripts/world/dirt_grid.gd`)
   - `block_dropped` signal emits `(grid_pos, item_id)` when block is destroyed
   - `item_id` is empty string for plain dirt, or ore ID for ore blocks
   - `_ore_map` entry is cleaned up on block destruction

4. **Inventory Integration** (`scripts/test_level.gd`)
   - `_on_block_dropped()` calls `DataRegistry.get_item(item_id)` to get ItemData
   - `InventoryManager.add_item(item, 1)` adds to inventory

### Dual Resource Issue (ItemData vs OreData)

The system has a **duplication problem**:
- `OreData` in `resources/ores/` defines generation/spawning parameters
- `ItemData` in `resources/items/` defines inventory/economy parameters
- Both have matching IDs (coal, copper, iron, silver, gold, ruby)
- Both have overlapping fields: id, display_name, sell_value, max_stack, rarity, min_depth

**Current flow**: OreData generates blocks -> drops item_id -> DataRegistry.get_item() loads ItemData -> added to inventory

This means:
- Spawning uses OreData (hardness, threshold, noise, etc.)
- Inventory uses ItemData (max_stack, sell_value, category, etc.)
- Changes to sell_value must be made in BOTH files to stay in sync

### Recommendations

**Option A: Keep Dual Resources (Current)**
- Pros: Clear separation of concerns, ItemData can include non-mined items (consumables, tools)
- Cons: Duplication, risk of desync between OreData.sell_value and ItemData.sell_value

**Option B: Unify into ItemData**
- Add generation fields to ItemData (min_depth, max_depth, spawn_threshold, noise_frequency, etc.)
- Remove OreData class entirely
- Pros: Single source of truth, no duplication
- Cons: ItemData becomes bloated, non-spawnable items have unused fields

**Option C: OreData extends ItemData (Recommended)**
- Make OreData inherit from ItemData
- OreData adds only generation-specific fields
- Change `_ore_map` to store OreData directly (or keep as ID, retrieve OreData for inventory)
- Pros: Single source of truth for economy data, clear inheritance hierarchy
- Cons: Slightly more complex class structure

### What's Missing / Needs Improvement

1. **Ore Visual Distinctiveness**: Currently uses simple color lerp. Consider:
   - TileSet atlas for ore textures (OreData.tile_atlas_coords exists but unused)
   - Particle effects for rare ores
   - Animated sparkle for gems

2. **Ore Hardness Integration**: OreData.hardness exists but DirtBlock uses layer hardness only
   - Should ore blocks have OreData.hardness added to/replacing layer hardness?

3. **Tool Tier Gating**: OreData.required_tool_tier exists but not checked
   - Should player be unable to mine gold with tier 0 pickaxe?

4. **Vein Generation**: OreData.vein_size_min/max exist but not used
   - Current system spawns ores independently per-block
   - True veins would cluster adjacent ore blocks

5. **Drop Feedback**: No floating text or particle when ore drops
   - InventoryManager.item_added signal exists but nothing listens to it

## Related Tasks

- `GoDig-research-itemdata-vs-c373f473` - Deep dive on unification
- `GoDig-dev-integrate-ores-3f8b9c4b` - Implementation task for ore generation
- `GoDig-dev-ore-depth-a250ad1b` - Depth gating logic
- `GoDig-dev-hybrid-ore-90c9e92f` - Noise + vein expansion hybrid
- `GoDig-dev-floating-pickup-8e654b1e` - Visual feedback on pickup

## New Implementation Tasks Created

Based on this research, the following new tasks were created:

1. `GoDig-implement-unify-oredata-8388f176` - Make OreData extend ItemData (priority 1)
2. `GoDig-implement-use-ore-7c6502b1` - Use ore hardness in DirtBlock (priority 2)
3. `GoDig-implement-tool-tier-cbc16732` - Tool tier gating for ores (priority 2)
4. `GoDig-implement-ore-drop-48fe8162` - Floating text on ore pickup (priority 3)
