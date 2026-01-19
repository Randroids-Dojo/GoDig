---
title: "implement: InventoryManager death penalty helpers"
status: open
priority: 1
issue-type: task
created-at: "2026-01-19T10:52:39.950447-06:00"
blocks:
  - GoDig-implement-death-and-fd4aaba6
---

## Description

Add two new methods to InventoryManager that the death/respawn system needs for calculating and applying inventory loss penalties.

## Context

The death system (GoDig-implement-death-and-fd4aaba6) requires:
- Knowing total items in inventory for percentage calculation
- Removing random items as death penalty (10-30% based on depth)

These methods don't exist in the current InventoryManager implementation.

## Affected Files

- `scripts/autoload/inventory_manager.gd` - Add two new methods

## Implementation Notes

Add these methods to `inventory_manager.gd`:

```gdscript
## Get total count of all items across all slots (for death penalty calculation)
func get_total_item_count() -> int:
    var total := 0
    for slot in slots:
        if not slot.is_empty():
            total += slot.quantity
    return total


## Remove one random item from inventory (for death penalty)
## Returns true if an item was removed, false if inventory was empty
func remove_random_item() -> bool:
    # Find all non-empty slots
    var occupied: Array = []
    for i in range(slots.size()):
        if not slots[i].is_empty():
            occupied.append(i)

    if occupied.is_empty():
        return false

    # Pick a random slot
    var target_idx: int = occupied[randi() % occupied.size()]
    var slot = slots[target_idx]

    # Remove one item
    slot.quantity -= 1
    if slot.quantity <= 0:
        slot.clear()

    inventory_changed.emit()
    return true
```

## Verify

- [ ] Build succeeds
- [ ] `get_total_item_count()` returns 0 for empty inventory
- [ ] `get_total_item_count()` returns correct sum across multiple slots
- [ ] `remove_random_item()` returns false for empty inventory
- [ ] `remove_random_item()` decrements quantity by 1
- [ ] `remove_random_item()` clears slot when quantity reaches 0
- [ ] `inventory_changed` signal fires after `remove_random_item()`
- [ ] Calling `remove_random_item()` multiple times removes multiple items
