"""
Inventory system tests for GoDig endless digging game.

Tests InventoryManager add/remove/stack logic per MVP spec.
Verifies slot-based storage, stacking, and capacity limits.

Note: Uses ID-based helper methods since PlayGodot cannot serialize Resource objects.
"""
import pytest
from helpers import PATHS


# =============================================================================
# ADD ITEM TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_add_item_to_empty_inventory(game):
    """Adding an item to empty inventory should occupy a slot."""
    # Clear inventory to ensure clean state
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Add 1 coal to inventory using ID-based method
    remaining = await game.call(PATHS["inventory_manager"], "add_item_by_id", ["coal", 1])
    assert remaining == 0, f"add_item should return 0 (all fit), got {remaining}"

    # Verify slot is now used
    used_slots = await game.call(PATHS["inventory_manager"], "get_used_slots")
    assert used_slots == 1, f"Should have 1 used slot, got {used_slots}"


@pytest.mark.asyncio
async def test_add_item_stacks_existing(game):
    """Adding the same item type should stack in existing slot."""
    # Clear inventory
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Add 5 copper
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["copper", 5])

    # Add 10 more copper - should stack
    remaining = await game.call(PATHS["inventory_manager"], "add_item_by_id", ["copper", 10])
    assert remaining == 0, f"All copper should fit, got remaining {remaining}"

    # Should still be only 1 slot used (stacked)
    used_slots = await game.call(PATHS["inventory_manager"], "get_used_slots")
    assert used_slots == 1, f"Should have 1 used slot (stacked), got {used_slots}"

    # Verify total count
    count = await game.call(PATHS["inventory_manager"], "get_item_count_by_id", ["copper"])
    assert count == 15, f"Should have 15 copper total, got {count}"


@pytest.mark.asyncio
async def test_add_item_creates_new_slot_when_stack_full(game):
    """Exceeding max_stack should create a new slot."""
    # Clear inventory
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Add 99 iron (fills one stack - max_stack is 99)
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["iron", 99])

    # Add 10 more - should create new slot
    remaining = await game.call(PATHS["inventory_manager"], "add_item_by_id", ["iron", 10])
    assert remaining == 0, f"All iron should fit, got remaining {remaining}"

    # Should now have 2 slots used
    used_slots = await game.call(PATHS["inventory_manager"], "get_used_slots")
    assert used_slots == 2, f"Should have 2 used slots, got {used_slots}"

    # Total count should be 109
    count = await game.call(PATHS["inventory_manager"], "get_item_count_by_id", ["iron"])
    assert count == 109, f"Should have 109 iron total, got {count}"


@pytest.mark.asyncio
async def test_add_different_items_use_different_slots(game):
    """Different item types should use separate slots."""
    # Clear inventory
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Add each item type
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["coal", 5])
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["copper", 5])
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["iron", 5])

    # Should have 3 slots used
    used_slots = await game.call(PATHS["inventory_manager"], "get_used_slots")
    assert used_slots == 3, f"Should have 3 used slots, got {used_slots}"


# =============================================================================
# INVENTORY FULL TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_inventory_full_returns_remaining(game):
    """Attempting to add to full inventory returns overflow amount."""
    # Clear inventory
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Fill all 8 slots with coal (8 slots * 99 per stack = 792)
    for _ in range(8):
        await game.call(PATHS["inventory_manager"], "add_item_by_id", ["coal", 99])

    # Verify all slots used
    used_slots = await game.call(PATHS["inventory_manager"], "get_used_slots")
    assert used_slots == 8, f"Should have 8 used slots, got {used_slots}"

    # Verify no space left
    has_space = await game.call(PATHS["inventory_manager"], "has_space")
    assert has_space is False, "Inventory should be full"

    # Try to add more - should return the amount that didn't fit
    remaining = await game.call(PATHS["inventory_manager"], "add_item_by_id", ["coal", 10])
    assert remaining == 10, f"Should return 10 as overflow, got {remaining}"


@pytest.mark.asyncio
async def test_inventory_partial_overflow(game):
    """Adding more than space allows returns only the overflow."""
    # Clear inventory
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Fill 7 slots completely (693 copper)
    for _ in range(7):
        await game.call(PATHS["inventory_manager"], "add_item_by_id", ["copper", 99])

    # Add 50 to 8th slot
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["copper", 50])

    # Now we have 743 copper, slot 8 has 50/99
    # Space remaining: 49 in slot 8
    # Try to add 60 - only 49 should fit
    remaining = await game.call(PATHS["inventory_manager"], "add_item_by_id", ["copper", 60])
    assert remaining == 11, f"Should return 11 as overflow (60-49=11), got {remaining}"


# =============================================================================
# GET ITEM COUNT TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_item_count_across_slots(game):
    """get_item_count returns total across multiple slots."""
    # Clear inventory
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Add 200 silver (should span 3 slots: 99 + 99 + 2)
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["silver", 200])

    # Verify count
    count = await game.call(PATHS["inventory_manager"], "get_item_count_by_id", ["silver"])
    assert count == 200, f"Should have 200 silver total, got {count}"

    # Verify slots used
    used_slots = await game.call(PATHS["inventory_manager"], "get_used_slots")
    assert used_slots == 3, f"Should have 3 slots (99+99+2), got {used_slots}"


@pytest.mark.asyncio
async def test_get_item_count_returns_zero_for_missing(game):
    """get_item_count returns 0 for items not in inventory."""
    # Clear inventory
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Add only coal
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["coal", 5])

    # Check count for gold (not added)
    count = await game.call(PATHS["inventory_manager"], "get_item_count_by_id", ["gold"])
    assert count == 0, f"Should have 0 gold, got {count}"


# =============================================================================
# REMOVE ITEM TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_remove_item_decrements(game):
    """Removing partial quantity decreases count."""
    # Clear inventory
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Add 20 gold
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["gold", 20])

    # Remove 5
    success = await game.call(PATHS["inventory_manager"], "remove_item_by_id", ["gold", 5])
    assert success is True, "remove_item should return True on success"

    # Verify count decreased
    count = await game.call(PATHS["inventory_manager"], "get_item_count_by_id", ["gold"])
    assert count == 15, f"Should have 15 gold after removing 5, got {count}"


@pytest.mark.asyncio
async def test_remove_item_fails_when_not_enough(game):
    """Removing more than available returns False."""
    # Clear inventory
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Add 10 iron
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["iron", 10])

    # Try to remove 20 - should fail
    success = await game.call(PATHS["inventory_manager"], "remove_item_by_id", ["iron", 20])
    assert success is False, "remove_item should return False when not enough"

    # Count should be unchanged
    count = await game.call(PATHS["inventory_manager"], "get_item_count_by_id", ["iron"])
    assert count == 10, f"Count should be unchanged at 10, got {count}"


@pytest.mark.asyncio
async def test_slot_clears_when_empty(game):
    """Removing all items from a slot clears it."""
    # Clear inventory
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Add 5 ruby
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["ruby", 5])

    # Verify slot is used
    used_slots = await game.call(PATHS["inventory_manager"], "get_used_slots")
    assert used_slots == 1, f"Should have 1 used slot, got {used_slots}"

    # Remove all 5
    success = await game.call(PATHS["inventory_manager"], "remove_item_by_id", ["ruby", 5])
    assert success is True, "Should successfully remove all ruby"

    # Slot should now be empty
    used_slots = await game.call(PATHS["inventory_manager"], "get_used_slots")
    assert used_slots == 0, f"Slot should be cleared, got {used_slots} used"


# =============================================================================
# REMOVE ALL OF ITEM TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_remove_all_of_item(game):
    """remove_all_of_item removes from all slots and returns total."""
    # Clear inventory
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Add 150 copper (2 slots: 99 + 51)
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["copper", 150])

    # Verify 2 slots used
    used_slots = await game.call(PATHS["inventory_manager"], "get_used_slots")
    assert used_slots == 2, f"Should have 2 slots, got {used_slots}"

    # Remove all copper
    removed = await game.call(PATHS["inventory_manager"], "remove_all_of_item_by_id", ["copper"])
    assert removed == 150, f"Should return 150 removed, got {removed}"

    # Verify empty
    used_slots = await game.call(PATHS["inventory_manager"], "get_used_slots")
    assert used_slots == 0, f"Should have 0 slots after remove_all, got {used_slots}"

    count = await game.call(PATHS["inventory_manager"], "get_item_count_by_id", ["copper"])
    assert count == 0, f"Should have 0 copper, got {count}"


# =============================================================================
# INVENTORY UPGRADE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_upgrade_capacity(game):
    """upgrade_capacity increases max slots."""
    # Clear inventory
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Verify starting capacity
    total = await game.call(PATHS["inventory_manager"], "get_total_slots")
    assert total == 8, f"Should start with 8 slots, got {total}"

    # Upgrade to 12 slots
    await game.call(PATHS["inventory_manager"], "upgrade_capacity", [12])

    # Verify new capacity
    total = await game.call(PATHS["inventory_manager"], "get_total_slots")
    assert total == 12, f"Should now have 12 slots, got {total}"


@pytest.mark.asyncio
async def test_upgrade_capacity_ignores_downgrade(game):
    """upgrade_capacity ignores attempts to decrease capacity."""
    # Get current capacity
    current = await game.call(PATHS["inventory_manager"], "get_total_slots")

    # Try to "downgrade" to 4 slots
    await game.call(PATHS["inventory_manager"], "upgrade_capacity", [4])

    # Capacity should be unchanged
    after = await game.call(PATHS["inventory_manager"], "get_total_slots")
    assert after >= current, f"Capacity should not decrease: was {current}, now {after}"


# =============================================================================
# SERIALIZATION TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_inventory_to_dict(game):
    """to_dict serializes inventory correctly."""
    # Clear inventory
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Add items
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["coal", 10])
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["iron", 5])

    # Get serialized dict
    data = await game.call(PATHS["inventory_manager"], "to_dict")
    assert data is not None, "to_dict should return a dictionary"
    assert "slots" in data, "Serialized data should have 'slots' key"
    assert "max_slots" in data, "Serialized data should have 'max_slots' key"


@pytest.mark.asyncio
async def test_get_inventory_dict(game):
    """get_inventory_dict returns item_id -> quantity mapping."""
    # Clear inventory
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Add items
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["coal", 25])
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["copper", 30])

    # Get inventory dict
    inv_dict = await game.call(PATHS["inventory_manager"], "get_inventory_dict")
    assert inv_dict is not None, "get_inventory_dict should return a dictionary"
    assert inv_dict.get("coal") == 25, f"Should have 25 coal, got {inv_dict.get('coal')}"
    assert inv_dict.get("copper") == 30, f"Should have 30 copper, got {inv_dict.get('copper')}"


# =============================================================================
# CLEAR ALL TEST
# =============================================================================

@pytest.mark.asyncio
async def test_clear_all(game):
    """clear_all empties entire inventory."""
    # Add various items
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["coal", 50])
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["iron", 30])
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["gold", 10])

    # Verify items present
    used_before = await game.call(PATHS["inventory_manager"], "get_used_slots")
    assert used_before > 0, "Should have items before clear"

    # Clear all
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Verify empty
    used_after = await game.call(PATHS["inventory_manager"], "get_used_slots")
    assert used_after == 0, f"Should have 0 slots after clear_all, got {used_after}"

    has_space = await game.call(PATHS["inventory_manager"], "has_space")
    assert has_space is True, "Should have space after clear_all"


# =============================================================================
# DEATH PENALTY HELPER TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_total_item_count_empty(game):
    """get_total_item_count returns 0 for empty inventory."""
    # Clear inventory
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Get total count
    total = await game.call(PATHS["inventory_manager"], "get_total_item_count")
    assert total == 0, f"Empty inventory should have 0 total items, got {total}"


@pytest.mark.asyncio
async def test_get_total_item_count_single_type(game):
    """get_total_item_count returns correct sum for single item type."""
    # Clear inventory
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Add 50 coal
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["coal", 50])

    # Get total count
    total = await game.call(PATHS["inventory_manager"], "get_total_item_count")
    assert total == 50, f"Should have 50 total items, got {total}"


@pytest.mark.asyncio
async def test_get_total_item_count_multiple_types(game):
    """get_total_item_count returns correct sum across multiple item types."""
    # Clear inventory
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Add various items
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["coal", 25])
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["copper", 30])
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["iron", 15])

    # Get total count (25 + 30 + 15 = 70)
    total = await game.call(PATHS["inventory_manager"], "get_total_item_count")
    assert total == 70, f"Should have 70 total items (25+30+15), got {total}"


@pytest.mark.asyncio
async def test_get_total_item_count_multiple_slots_same_type(game):
    """get_total_item_count counts across multiple slots of same item."""
    # Clear inventory
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Add 200 copper (should span 3 slots: 99 + 99 + 2)
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["copper", 200])

    # Get total count
    total = await game.call(PATHS["inventory_manager"], "get_total_item_count")
    assert total == 200, f"Should have 200 total items across 3 slots, got {total}"


@pytest.mark.asyncio
async def test_remove_random_item_empty_inventory(game):
    """remove_random_item returns False for empty inventory."""
    # Clear inventory
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Try to remove random item
    removed = await game.call(PATHS["inventory_manager"], "remove_random_item")
    assert removed is False, "remove_random_item should return False on empty inventory"


@pytest.mark.asyncio
async def test_remove_random_item_decrements_count(game):
    """remove_random_item decrements total item count by 1."""
    # Clear inventory
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Add 10 items
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["coal", 10])

    # Get initial count
    before = await game.call(PATHS["inventory_manager"], "get_total_item_count")
    assert before == 10, f"Should start with 10 items, got {before}"

    # Remove random item
    removed = await game.call(PATHS["inventory_manager"], "remove_random_item")
    assert removed is True, "remove_random_item should return True"

    # Verify count decreased by 1
    after = await game.call(PATHS["inventory_manager"], "get_total_item_count")
    assert after == 9, f"Should have 9 items after removing 1, got {after}"


@pytest.mark.asyncio
async def test_remove_random_item_clears_slot_when_empty(game):
    """remove_random_item clears slot when last item is removed."""
    # Clear inventory
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Add just 1 item
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["gold", 1])

    # Verify 1 slot used
    used = await game.call(PATHS["inventory_manager"], "get_used_slots")
    assert used == 1, f"Should have 1 slot used, got {used}"

    # Remove the single item
    removed = await game.call(PATHS["inventory_manager"], "remove_random_item")
    assert removed is True, "Should successfully remove item"

    # Verify slot is now empty
    used = await game.call(PATHS["inventory_manager"], "get_used_slots")
    assert used == 0, f"Slot should be cleared, got {used} used"


@pytest.mark.asyncio
async def test_remove_random_items_multiple(game):
    """remove_random_items removes multiple items correctly."""
    # Clear inventory
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Add 20 items
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["iron", 20])

    # Remove 5 random items
    removed_count = await game.call(PATHS["inventory_manager"], "remove_random_items", [5])
    assert removed_count == 5, f"Should have removed 5 items, got {removed_count}"

    # Verify 15 remain
    total = await game.call(PATHS["inventory_manager"], "get_total_item_count")
    assert total == 15, f"Should have 15 items remaining, got {total}"


@pytest.mark.asyncio
async def test_remove_random_items_stops_when_empty(game):
    """remove_random_items stops early if inventory empties."""
    # Clear inventory
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Add only 3 items
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["ruby", 3])

    # Try to remove 10 items (more than available)
    removed_count = await game.call(PATHS["inventory_manager"], "remove_random_items", [10])
    assert removed_count == 3, f"Should have removed only 3 items, got {removed_count}"

    # Verify inventory is empty
    total = await game.call(PATHS["inventory_manager"], "get_total_item_count")
    assert total == 0, f"Inventory should be empty, got {total}"
