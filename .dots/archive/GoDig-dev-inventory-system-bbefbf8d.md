---
title: "implement: Inventory system tests"
status: closed
priority: 2
issue-type: task
created-at: "2026-01-16T01:04:04.543580-06:00"
close-reason: Implemented in tests/test_inventory.py with 26+ tests covering add/remove/stack/capacity/serialization
---

## Description

Create PlayGodot integration tests for the inventory system. Tests should verify add/remove/stack behavior, inventory full detection, capacity upgrades, and sell-all functionality.

## Context

InventoryManager singleton is implemented with:
- Slot-based storage with stacking
- Limited capacity (8-30 slots, upgradeable)
- Signals: `inventory_changed`, `inventory_full`, `item_added`
- Save/load serialization

Tests use PlayGodot to run the game and interact with autoloads via `game.get_property()` and `game.call_method()`.

## Affected Files

- `tests/test_inventory.py` - NEW: Inventory system tests
- `tests/helpers.py` - Add inventory paths and helper methods

## Implementation Notes

### Test Helper Paths

```python
# tests/helpers.py
PATHS = {
    # ... existing paths ...
    "inventory_manager": "/root/InventoryManager",
    "data_registry": "/root/DataRegistry",
}
```

### Test: Add Single Item

```python
@pytest.mark.asyncio
async def test_add_item_by_id(game):
    """Test adding a single item by ID."""
    # Clear inventory first
    await game.call_method(PATHS["inventory_manager"], "clear_all")

    # Add coal
    remaining = await game.call_method(
        PATHS["inventory_manager"],
        "add_item_by_id",
        "coal", 1
    )

    assert remaining == 0, "Should have no remaining items"

    count = await game.call_method(
        PATHS["inventory_manager"],
        "get_item_count_by_id",
        "coal"
    )
    assert count == 1, "Should have 1 coal in inventory"
```

### Test: Item Stacking

```python
@pytest.mark.asyncio
async def test_item_stacking(game):
    """Test that items stack correctly."""
    await game.call_method(PATHS["inventory_manager"], "clear_all")

    # Add 50 coal in two batches
    await game.call_method(PATHS["inventory_manager"], "add_item_by_id", "coal", 25)
    await game.call_method(PATHS["inventory_manager"], "add_item_by_id", "coal", 25)

    count = await game.call_method(
        PATHS["inventory_manager"],
        "get_item_count_by_id",
        "coal"
    )
    assert count == 50, "Should have 50 coal total"

    # Should only use 1 slot (assuming max_stack >= 50)
    used_slots = await game.call_method(
        PATHS["inventory_manager"],
        "get_used_slots"
    )
    assert used_slots == 1, "50 items should fit in 1 slot"
```

### Test: Inventory Full

```python
@pytest.mark.asyncio
async def test_inventory_full(game):
    """Test inventory full detection."""
    await game.call_method(PATHS["inventory_manager"], "clear_all")

    # Get slot count
    max_slots = await game.get_property(PATHS["inventory_manager"], "max_slots")

    # Fill all slots
    for i in range(max_slots):
        # Add different items to use separate slots
        item_id = ["coal", "copper", "iron", "silver", "gold", "diamond"][i % 6]
        await game.call_method(PATHS["inventory_manager"], "add_item_by_id", item_id, 99)

    # Try to add more
    has_space = await game.call_method(PATHS["inventory_manager"], "has_space")
    assert has_space == False, "Inventory should be full"
```

### Test: Remove Item

```python
@pytest.mark.asyncio
async def test_remove_item(game):
    """Test removing items from inventory."""
    await game.call_method(PATHS["inventory_manager"], "clear_all")

    # Add then remove
    await game.call_method(PATHS["inventory_manager"], "add_item_by_id", "copper", 10)
    success = await game.call_method(
        PATHS["inventory_manager"],
        "remove_item_by_id",
        "copper", 5
    )

    assert success == True, "Should successfully remove items"

    count = await game.call_method(
        PATHS["inventory_manager"],
        "get_item_count_by_id",
        "copper"
    )
    assert count == 5, "Should have 5 copper remaining"
```

### Test: Cannot Remove More Than Exists

```python
@pytest.mark.asyncio
async def test_cannot_remove_more_than_exists(game):
    """Test that removing more items than exist fails."""
    await game.call_method(PATHS["inventory_manager"], "clear_all")

    await game.call_method(PATHS["inventory_manager"], "add_item_by_id", "iron", 5)

    success = await game.call_method(
        PATHS["inventory_manager"],
        "remove_item_by_id",
        "iron", 10
    )

    assert success == False, "Should fail to remove more than exists"

    # Inventory should be unchanged
    count = await game.call_method(
        PATHS["inventory_manager"],
        "get_item_count_by_id",
        "iron"
    )
    assert count == 5, "Should still have 5 iron"
```

### Test: Capacity Upgrade

```python
@pytest.mark.asyncio
async def test_capacity_upgrade(game):
    """Test inventory capacity upgrade."""
    await game.call_method(PATHS["inventory_manager"], "clear_all")

    initial_slots = await game.get_property(PATHS["inventory_manager"], "max_slots")

    # Upgrade capacity
    await game.call_method(PATHS["inventory_manager"], "upgrade_capacity", initial_slots + 2)

    new_slots = await game.get_property(PATHS["inventory_manager"], "max_slots")
    assert new_slots == initial_slots + 2, "Should have 2 more slots"
```

### Test: Sell All

```python
@pytest.mark.asyncio
async def test_remove_all_of_item(game):
    """Test removing all instances of a specific item."""
    await game.call_method(PATHS["inventory_manager"], "clear_all")

    # Add some items
    await game.call_method(PATHS["inventory_manager"], "add_item_by_id", "coal", 50)
    await game.call_method(PATHS["inventory_manager"], "add_item_by_id", "copper", 25)

    # Remove all coal
    removed = await game.call_method(
        PATHS["inventory_manager"],
        "remove_all_of_item_by_id",
        "coal"
    )

    assert removed == 50, "Should remove 50 coal"

    coal_count = await game.call_method(
        PATHS["inventory_manager"],
        "get_item_count_by_id",
        "coal"
    )
    assert coal_count == 0, "Should have no coal left"

    # Copper should be unaffected
    copper_count = await game.call_method(
        PATHS["inventory_manager"],
        "get_item_count_by_id",
        "copper"
    )
    assert copper_count == 25, "Should still have 25 copper"
```

### Test: Save and Load

```python
@pytest.mark.asyncio
async def test_inventory_save_load(game):
    """Test inventory serialization."""
    await game.call_method(PATHS["inventory_manager"], "clear_all")

    # Add items
    await game.call_method(PATHS["inventory_manager"], "add_item_by_id", "gold", 15)
    await game.call_method(PATHS["inventory_manager"], "add_item_by_id", "diamond", 3)

    # Get save dict
    save_dict = await game.call_method(PATHS["inventory_manager"], "get_inventory_dict")

    # Clear and restore
    await game.call_method(PATHS["inventory_manager"], "clear_all")
    await game.call_method(PATHS["inventory_manager"], "load_from_dict", save_dict)

    # Verify
    gold = await game.call_method(PATHS["inventory_manager"], "get_item_count_by_id", "gold")
    diamond = await game.call_method(PATHS["inventory_manager"], "get_item_count_by_id", "diamond")

    assert gold == 15, "Gold should be restored"
    assert diamond == 3, "Diamond should be restored"
```

## Verify

- [ ] All tests pass locally with `python3 -m pytest tests/test_inventory.py -v`
- [ ] Tests clean up after themselves (clear_all at start)
- [ ] Tests don't depend on execution order
- [ ] CI pipeline runs tests successfully
