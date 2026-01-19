---
title: "implement: Inventory add/remove/stack logic"
status: closed
priority: 1
issue-type: task
created-at: "\"2026-01-16T00:38:32.800257-06:00\""
closed-at: "2026-01-19T11:25:55.825752-06:00"
close-reason: Already done - documented in spec
---

## Status: ALREADY IMPLEMENTED

The inventory add/remove/stack logic is fully implemented in `scripts/autoload/inventory_manager.gd`:

### Features Implemented:

1. **Slot-based storage** with InventorySlot inner class
2. **Stacking logic** - items stack up to max_stack per slot
3. **add_item()** - First tries to stack with existing items, then uses empty slots
4. **remove_item()** - LIFO removal with slot cleanup
5. **inventory_full signal** - Emitted when items cannot fit
6. **item_added signal** - Emitted with item and amount for UI feedback
7. **get_item_count()** - Count total of specific item across all slots
8. **Serialization** - to_dict() and from_dict() for save/load

### Key Code:

```gdscript
func add_item(item: ItemData, amount: int = 1) -> int:
    # First pass: Try to stack with existing slots of same item
    for slot in slots:
        if slot.item != null and slot.item.id == item.id:
            var space: int = slot.space_remaining()
            var to_add: int = mini(space, remaining)
            # ...

    # Second pass: Use empty slots
    if remaining > 0:
        for slot in slots:
            if slot.is_empty():
                # ...

    # Signal if couldn't fit everything
    if remaining > 0:
        inventory_full.emit()

    return remaining
```

## Verify

- [x] Items stack up to max_stack per slot
- [x] add_item returns leftover amount
- [x] inventory_full signal fires when full
- [x] item_added signal fires on successful add
- [x] remove_item correctly decrements and clears slots
- [x] Serialization works for save/load
