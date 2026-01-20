---
title: "implement: Core mechanics integration tests"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-16T00:47:55.565950-06:00\""
closed-at: "2026-01-19T19:35:43.586802-06:00"
close-reason: Core mechanics integration exists
---

## Description

Create comprehensive PlayGodot integration tests for the core game loop: movement, mining, collecting, selling, and save/load cycle.

## Context

- Automated tests catch regressions during development
- Core mechanics are critical path - must always work
- Uses PlayGodot framework for Godot testing
- See AGENTS.md for test patterns

## Affected Files

- `tests/test_core_mechanics.py` - NEW: Core loop tests
- `tests/helpers.py` - Add new node paths if needed

## Implementation Notes

### Test File Structure

```python
# tests/test_core_mechanics.py
import pytest
from tests.helpers import PATHS

@pytest.mark.asyncio
class TestCoreLoop:
    """Integration tests for the core game loop."""

    async def test_player_can_move_horizontally(self, game):
        """Player moves left and right on empty tiles."""
        # Get initial position
        initial_x = await game.get_property(PATHS["player"], "grid_position:x")

        # Simulate movement input
        await game.call_method(PATHS["player"], "set_touch_direction", [1, 0])
        await game.wait(0.3)

        # Check position changed
        new_x = await game.get_property(PATHS["player"], "grid_position:x")
        assert new_x == initial_x + 1, "Player should move right"

    async def test_player_can_mine_block(self, game):
        """Player can mine a block below them."""
        # Position player above a block
        player_grid = await game.get_property(PATHS["player"], "grid_position")

        # Check block exists below
        block_below = [player_grid[0], player_grid[1] + 1]
        has_block = await game.call_method(PATHS["dirt_grid"], "has_block", block_below)
        assert has_block, "Block should exist below player"

        # Mine the block
        await game.call_method(PATHS["player"], "_try_move_or_mine", [0, 1])
        await game.wait(1.0)  # Wait for mining animation

        # Check block destroyed
        has_block_after = await game.call_method(PATHS["dirt_grid"], "has_block", block_below)
        assert not has_block_after, "Block should be destroyed"
```

### Player Movement Tests

```python
async def test_player_falls_when_no_ground(self, game):
    """Player enters falling state when ground removed."""
    # Mine block below player
    # ... setup ...
    state = await game.get_property(PATHS["player"], "current_state")
    assert state == Player.State.FALLING

async def test_player_cannot_walk_through_walls(self, game):
    """Player blocked by solid blocks."""
    # Try to move into solid block
    # ... setup ...
    # Position should not change
```

### Mining Integration Tests

```python
async def test_mining_drops_ore_to_inventory(self, game):
    """Mining ore block adds item to inventory."""
    # Setup: Find or create ore block at known position
    # Mine the block
    # Check inventory contains ore
    count = await game.call_method(PATHS["inventory_manager"], "get_item_count_by_id", "copper")
    assert count > 0

async def test_harder_blocks_take_more_hits(self, game):
    """Stone takes more hits than dirt."""
    # Mine dirt block, count frames
    # Mine stone block, count frames
    # Assert stone took longer
```

### Inventory Tests

```python
async def test_inventory_full_prevents_pickup(self, game):
    """Full inventory rejects new items."""
    # Fill inventory
    for i in range(8):
        await game.call_method(PATHS["inventory_manager"], "add_item_by_id", "copper", 99)

    # Try to add more
    leftover = await game.call_method(PATHS["inventory_manager"], "add_item_by_id", "copper", 1)
    assert leftover == 1, "Should return leftover when full"

async def test_inventory_stacking(self, game):
    """Same items stack in inventory."""
    await game.call_method(PATHS["inventory_manager"], "add_item_by_id", "coal", 5)
    await game.call_method(PATHS["inventory_manager"], "add_item_by_id", "coal", 3)
    count = await game.call_method(PATHS["inventory_manager"], "get_item_count_by_id", "coal")
    assert count == 8
```

### Save/Load Cycle Tests

```python
async def test_save_preserves_inventory(self, game):
    """Inventory contents survive save/load."""
    # Add items
    await game.call_method(PATHS["inventory_manager"], "add_item_by_id", "gold", 10)

    # Save
    await game.call_method(PATHS["save_manager"], "save_game")

    # Clear inventory
    await game.call_method(PATHS["inventory_manager"], "clear_all")

    # Load
    await game.call_method(PATHS["save_manager"], "load_game")

    # Verify
    count = await game.call_method(PATHS["inventory_manager"], "get_item_count_by_id", "gold")
    assert count == 10

async def test_save_preserves_player_position(self, game):
    """Player position survives save/load."""
    # Move player
    # Save
    # Change position
    # Load
    # Verify original position restored
```

### Test Helpers Addition

```python
# tests/helpers.py
PATHS = {
    "player": "/root/TestLevel/Player",
    "dirt_grid": "/root/TestLevel/DirtGrid",
    "inventory_manager": "/root/InventoryManager",
    "game_manager": "/root/GameManager",
    "save_manager": "/root/SaveManager",
    "data_registry": "/root/DataRegistry",
}
```

### Running Tests

```bash
# Run all core mechanics tests
python3 -m pytest tests/test_core_mechanics.py -v

# Run specific test
python3 -m pytest tests/test_core_mechanics.py::TestCoreLoop::test_player_can_mine_block -v
```

## Edge Cases to Test

- Mining at world boundary
- Inventory full during mining
- Save during active mining state
- Load with missing item data
- Player position outside loaded chunks

## Verify

- [ ] Build succeeds
- [ ] All movement tests pass
- [ ] All mining tests pass
- [ ] All inventory tests pass
- [ ] All save/load tests pass
- [ ] Tests run in CI pipeline
- [ ] No flaky tests (run 3x to verify)
- [ ] Tests complete in reasonable time (<30s total)
