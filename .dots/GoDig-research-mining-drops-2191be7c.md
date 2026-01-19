---
title: "research: Mining drops to inventory"
status: done
priority: 0
issue-type: task
created-at: "2026-01-18T23:35:22.745725-06:00"
---

When player destroys a block, what happens? Currently block_destroyed signal fires but nothing adds to inventory. Need to connect: dirt_block destruction -> determine drop -> add to InventoryManager. Should use ItemData or OreData? Where does the drop logic live (DirtBlock, Player, or separate system)?

## Research Findings (Verified 2026-01-19)

### Current Implementation Status: COMPLETE

Mining drops to inventory is already fully implemented. The system works correctly.

### Implementation Details

**Data Flow:**
1. `DirtGrid._determine_ore_spawn(pos)` - Called when row is generated, stores ore ID in `_ore_map[pos]`
2. `DirtGrid.hit_block(pos)` - When block destroyed, emits `block_dropped(pos, ore_id)` signal
3. `TestLevel._on_block_dropped(grid_pos, item_id)` - Receives signal, looks up item, adds to inventory
4. `InventoryManager.add_item(item, 1)` - Adds the item to player inventory

**Signal Chain:**
```
Player.trigger_dig()
  -> dirt_grid.hit_block(target_pos)
  -> block destroyed
  -> DirtGrid.block_dropped.emit(pos, ore_id)
  -> TestLevel._on_block_dropped(pos, item_id)
  -> DataRegistry.get_item(item_id)
  -> InventoryManager.add_item(item, 1)
```

**Visual Feedback:**
- `InventoryManager.item_added` signal emitted when item added
- `TestLevel._on_item_added()` creates floating text showing item name and quantity
- Text color matches ore color from `DataRegistry.get_ore(item.id).color`

**Key Files:**
- `scripts/world/dirt_grid.gd` - Manages ore map and emits block_dropped signal
- `scripts/test_level.gd` - Connects signal to inventory system
- `scripts/autoload/inventory_manager.gd` - Stores items in slots

### Answer to Research Questions

1. **What happens when player destroys a block?**
   - DirtGrid.hit_block() checks if block health <= 0
   - If destroyed, looks up ore_id from _ore_map dictionary
   - Emits block_dropped(pos, ore_id) - ore_id is empty string for plain dirt
   - TestLevel handler adds item to inventory if ore_id is not empty

2. **Should use ItemData or OreData?**
   - Currently uses ItemData via DataRegistry.get_item()
   - This will change to use OreData directly after GoDig-implement-unify-oredata-8388f176

3. **Where does drop logic live?**
   - Drop determination: DirtGrid._determine_ore_spawn() (at generation time)
   - Drop emission: DirtGrid.hit_block() (at destruction time)
   - Drop handling: TestLevel._on_block_dropped() (scene controller)
   - Storage: InventoryManager.add_item()

### No Further Work Needed

This research confirms the system is working correctly. The only improvement needed is the OreData/ItemData unification covered in a separate implementation dot.
