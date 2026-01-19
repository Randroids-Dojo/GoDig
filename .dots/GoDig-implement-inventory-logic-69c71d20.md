---
title: "implement: Inventory logic unit tests"
status: open
priority: 1
issue-type: task
created-at: "2026-01-18T23:32:50.230796-06:00"
---

## Description

Add PlayGodot tests verifying InventoryManager add/remove/stack logic from the Basic Inventory spec (GoDig-mvp-basic-inventory-851ca931).

## Context

The InventoryManager autoload exists and has been implemented, but the Verify criteria from the spec are not covered by tests. These tests ensure the inventory logic works correctly.

## Affected Files

- `tests/test_inventory.py` - NEW: Inventory-specific tests
- `tests/helpers.py` - MAY MODIFY: Add inventory helper constants

## Implementation Notes

### Required Tests

1. **test_add_item_to_empty_inventory** - Call add_item, verify slot has item
2. **test_add_item_stacks_existing** - Add same item twice, verify quantity stacks
3. **test_add_item_creates_new_slot** - Fill first stack, add more, verify new slot used
4. **test_inventory_full_signal** - Fill all slots, add more, verify returns > 0
5. **test_get_item_count_across_slots** - Items in multiple slots, verify total
6. **test_remove_item_decrements** - Remove partial, verify quantity decreases
7. **test_slot_clears_when_empty** - Remove all, verify slot.item == null

### PlayGodot Pattern

```python
@pytest.mark.asyncio
async def test_add_item_to_empty_inventory(game):
    # Create test item via DataRegistry or direct method
    result = await game.call_method(PATHS['inventory_manager'], 
                                     'add_item', [item_data, 1])
    count = await game.get_property(PATHS['inventory_manager'], 
                                     'get_used_slots')
    assert count == 1
```

### Notes

- May need to create test item resources or use a test helper
- InventoryManager.add_item returns remaining amount (0 = success)
- Tests should reset inventory state between runs

## Verify

- [ ] Build succeeds
- [ ] All 7 inventory tests pass
- [ ] Tests use async/await pattern correctly
- [ ] CI workflow passes with new tests
