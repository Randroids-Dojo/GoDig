---
title: "implement: Auto-pickup on dig"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-16T00:38:32.805332-06:00\""
closed-at: "2026-01-19T11:25:55.532633-06:00"
close-reason: Already done - documented in spec
---

## Status: ALREADY IMPLEMENTED

Auto-pickup is implemented in `scripts/test_level.gd`:

### Implementation:

1. `dirt_grid.block_dropped` signal fires when block is destroyed
2. `_on_block_dropped()` receives grid_pos and item_id
3. Looks up item from DataRegistry
4. Calls `InventoryManager.add_item(item, 1)`
5. Handles inventory full case

### Code:

```gdscript
# test_level.gd
func _ready() -> void:
    # Connect mining drops to inventory
    dirt_grid.block_dropped.connect(_on_block_dropped)

func _on_block_dropped(grid_pos: Vector2i, item_id: String) -> void:
    if item_id.is_empty():
        return  # Plain dirt, no drop

    var item = DataRegistry.get_item(item_id)
    if item == null:
        push_warning("[TestLevel] Unknown item dropped: %s" % item_id)
        return

    var leftover := InventoryManager.add_item(item, 1)
    if leftover > 0:
        print("[TestLevel] Inventory full, could not add %s" % item.display_name)
```

## Verify

- [x] Mining ore block adds item to inventory
- [x] Plain dirt blocks don't add items
- [x] Inventory full is handled gracefully
- [x] Unknown item IDs are logged as warnings
