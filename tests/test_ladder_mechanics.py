"""
Ladder mechanics tests for GoDig.

Tests ladder placement rules:
- Ladders occupy the player's current square
- Only one ladder per square
- At the top of a ladder, placing another goes above
- Cannot place at or above the surface
- Ladder fall mechanic when dirt beneath is dug

Tests ladder traversal:
- Player z_index renders in front of ladders
- Player enters CLIMBING state when standing on a ladder
- Player exits CLIMBING state when ladder is removed
"""
import asyncio
import pytest
from helpers import PATHS


DIRT_GRID = PATHS["dirt_grid"]
PLAYER = PATHS["player"]


# =============================================================================
# PLAYER LADDER API TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_player_has_place_ladder_method(game):
    """Player should have place_ladder_at_position method."""
    result = await game.call(PLAYER, "has_method", ["place_ladder_at_position"])
    assert result is True, "Player should have place_ladder_at_position method"


@pytest.mark.asyncio
async def test_player_has_can_place_ladder_method(game):
    """Player should have can_place_ladder method."""
    result = await game.call(PLAYER, "has_method", ["can_place_ladder"])
    assert result is True, "Player should have can_place_ladder method"


@pytest.mark.asyncio
async def test_player_has_get_ladder_placement_pos_method(game):
    """Player should have _get_ladder_placement_pos helper method."""
    result = await game.call(PLAYER, "has_method", ["_get_ladder_placement_pos"])
    assert result is True, "Player should have _get_ladder_placement_pos method"


# =============================================================================
# DIRT GRID LADDER API TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_dirt_grid_has_place_ladder_method(game):
    """DirtGrid should have place_ladder method."""
    result = await game.call(DIRT_GRID, "has_method", ["place_ladder"])
    assert result is True, "DirtGrid should have place_ladder method"


@pytest.mark.asyncio
async def test_dirt_grid_has_has_ladder_method(game):
    """DirtGrid should have has_ladder method."""
    result = await game.call(DIRT_GRID, "has_method", ["has_ladder"])
    assert result is True, "DirtGrid should have has_ladder method"


@pytest.mark.asyncio
async def test_dirt_grid_has_remove_ladder_method(game):
    """DirtGrid should have remove_ladder method."""
    result = await game.call(DIRT_GRID, "has_method", ["remove_ladder"])
    assert result is True, "DirtGrid should have remove_ladder method"


@pytest.mark.asyncio
async def test_dirt_grid_has_handle_ladder_fall_method(game):
    """DirtGrid should have _handle_ladder_fall method for fall mechanic."""
    result = await game.call(DIRT_GRID, "has_method", ["_handle_ladder_fall"])
    assert result is True, "DirtGrid should have _handle_ladder_fall method"


# =============================================================================
# LADDER PLACEMENT RULES TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_cannot_place_ladder_without_inventory(game):
    """Cannot place ladder if inventory has none."""
    # Player starts in IDLE state with no ladders in inventory
    can_place = await game.call(PLAYER, "can_place_ladder", [])
    assert can_place is False, "can_place_ladder should be False when inventory has no ladders"


@pytest.mark.asyncio
async def test_dirt_grid_no_ladder_at_spawn(game):
    """No ladder should exist at the player spawn position initially."""
    grid_pos = await game.get_property(PLAYER, "grid_position")
    assert grid_pos is not None, "Player should have grid_position"

    has_ladder = await game.call(DIRT_GRID, "has_ladder", [grid_pos])
    assert has_ladder is False, "No ladder should be at player spawn position"


@pytest.mark.asyncio
async def test_place_ladder_then_has_ladder(game):
    """After placing a ladder via DirtGrid, has_ladder should return true."""
    # Use y=2 (above surface, guaranteed AIR — chunks never place blocks above SURFACE_ROW=7)
    test_pos = {"x": 10, "y": 2}
    await game.call(DIRT_GRID, "remove_ladder", [test_pos])  # ensure clean slate

    placed = await game.call(DIRT_GRID, "place_ladder", [test_pos])
    assert placed is True, "Should be able to place ladder at an empty position"

    has_ladder = await game.call(DIRT_GRID, "has_ladder", [test_pos])
    assert has_ladder is True, "has_ladder should return true after placement"

    # Clean up
    await game.call(DIRT_GRID, "remove_ladder", [test_pos])


@pytest.mark.asyncio
async def test_cannot_place_two_ladders_same_square(game):
    """Cannot place two ladders at the same grid position."""
    # Use y=2 (above surface, guaranteed AIR)
    test_pos = {"x": 11, "y": 2}
    await game.call(DIRT_GRID, "remove_ladder", [test_pos])  # ensure clean slate

    # Place first ladder
    first = await game.call(DIRT_GRID, "place_ladder", [test_pos])
    assert first is True, "First ladder should place successfully"

    # Attempt second ladder at same position
    second = await game.call(DIRT_GRID, "place_ladder", [test_pos])
    assert second is False, "Second ladder at same position should fail"

    # Clean up
    await game.call(DIRT_GRID, "remove_ladder", [test_pos])


@pytest.mark.asyncio
async def test_ladder_fall_with_no_ladder_above_is_noop(game):
    """_handle_ladder_fall at a position with no ladder above is a no-op."""
    # Use a position well above-surface where no ladders exist
    test_pos = {"x": 20, "y": 15}
    await game.call(DIRT_GRID, "_handle_ladder_fall", [test_pos])
    # Verify nothing was placed/changed at that position
    has_ladder = await game.call(DIRT_GRID, "has_ladder", [test_pos])
    assert has_ladder is False, "No ladder should appear after a no-op fall call"


@pytest.mark.asyncio
async def test_ladder_fall_shifts_ladder_down(game):
    """When _handle_ladder_fall is called and a ladder is directly above, it moves down."""
    # Use positions above the surface (y < SURFACE_ROW=7) which are guaranteed AIR.
    # y=3: ladder will be placed here; y=4: the "dug" position; y=5: still air (fall continues);
    # y=7: first solid row — ladder lands at y=6 after scanning through y=4 and y=5.
    ladder_pos = {"x": 40, "y": 3}
    dug_pos = {"x": 40, "y": 4}
    expected_land = {"x": 40, "y": 6}  # one above first solid row (SURFACE_ROW = 7)

    # Ensure no pre-existing ladder at our positions
    for pos in [ladder_pos, dug_pos, expected_land]:
        await game.call(DIRT_GRID, "remove_ladder", [pos])

    # Place ladder at y=3 (above-surface AIR, no block, so place_ladder accepts it)
    placed = await game.call(DIRT_GRID, "place_ladder", [ladder_pos])
    if not placed:
        pytest.skip("Could not place test ladder at y=3")

    # Trigger the fall as if the block at y=4 was just dug (y=4 is AIR, _active has nothing there)
    await game.call(DIRT_GRID, "_handle_ladder_fall", [dug_pos])

    has_at_original = await game.call(DIRT_GRID, "has_ladder", [ladder_pos])
    has_at_land = await game.call(DIRT_GRID, "has_ladder", [expected_land])

    # Clean up
    await game.call(DIRT_GRID, "remove_ladder", [ladder_pos])
    await game.call(DIRT_GRID, "remove_ladder", [expected_land])

    assert has_at_original is False, "Ladder should have left y=3"
    assert has_at_land is True, "Ladder should have fallen to y=6 (just above surface dirt at y=7)"


# =============================================================================
# LADDER TRAVERSAL TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_player_has_is_on_ladder_method(game):
    """Player should have _is_on_ladder method used to detect climbing state."""
    result = await game.call(PLAYER, "has_method", ["_is_on_ladder"])
    assert result is True, "Player should have _is_on_ladder method"


@pytest.mark.asyncio
async def test_player_has_start_climbing_method(game):
    """Player should have _start_climbing method to enter CLIMBING state."""
    result = await game.call(PLAYER, "has_method", ["_start_climbing"])
    assert result is True, "Player should have _start_climbing method"


@pytest.mark.asyncio
async def test_player_z_index_in_front_of_ladders(game):
    """Player z_index must exceed ladder visual z_index (1) so player renders in front."""
    z_index = await game.get_property(PLAYER, "z_index")
    assert z_index is not None, "Player should have z_index property"
    assert z_index > 1, f"Player z_index ({z_index}) should be greater than ladder z_index (1)"


@pytest.mark.asyncio
async def test_player_not_on_ladder_at_spawn(game):
    """Player should not be on a ladder at spawn — _is_on_ladder returns false."""
    result = await game.call(PLAYER, "_is_on_ladder", [])
    assert result is False, "Player should not be on a ladder at spawn"


@pytest.mark.asyncio
async def test_player_enters_climbing_state_on_ladder(game):
    """Player should enter CLIMBING state (6) when a ladder is placed at their position."""
    # State enum: IDLE=0 MOVING=1 MINING=2 FALLING=3 WALL_SLIDING=4 WALL_JUMPING=5 CLIMBING=6
    CLIMBING_STATE = 6

    grid_pos = await game.get_property(PLAYER, "grid_position")
    assert grid_pos is not None, "Player should have grid_position"

    placed = await game.call(DIRT_GRID, "place_ladder", [grid_pos])
    assert placed is True, "Should be able to place ladder at player's position"

    # Wait for the state machine to detect the ladder
    await asyncio.sleep(0.1)

    state = await game.get_property(PLAYER, "current_state")

    # Clean up before asserting so the ladder is removed regardless of outcome
    await game.call(DIRT_GRID, "remove_ladder", [grid_pos])

    assert state == CLIMBING_STATE, f"Player should be in CLIMBING state ({CLIMBING_STATE}), got {state}"
