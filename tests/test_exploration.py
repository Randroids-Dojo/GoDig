"""
ExplorationManager tests for GoDig endless digging game.

Tests verify that ExplorationManager:
1. Exists as an autoload singleton
2. Tracks explored areas correctly
3. Has proper visibility states
4. Supports save/load of exploration data
5. Handles surface visibility correctly
"""
import pytest
from helpers import PATHS


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_exploration_manager_exists(game):
    """ExplorationManager autoload should exist."""
    result = await game.node_exists(PATHS["exploration_manager"])
    assert result.get("exists") is True, "ExplorationManager autoload should exist"


# =============================================================================
# CONSTANT TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_vision_radius_configured(game):
    """VISION_RADIUS constant should be configured."""
    result = await game.get_property(PATHS["exploration_manager"], "VISION_RADIUS")
    assert result is not None, "VISION_RADIUS should exist"
    assert isinstance(result, int), f"VISION_RADIUS should be int, got {type(result)}"
    assert result > 0, f"VISION_RADIUS should be positive, got {result}"
    assert result <= 20, f"VISION_RADIUS should be reasonable, got {result}"


# =============================================================================
# INITIAL STATE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_initial_explored_count_zero(game):
    """ExplorationManager should have zero explored count after reset."""
    # Reset to ensure clean state
    await game.call(PATHS["exploration_manager"], "reset")

    count = await game.call(PATHS["exploration_manager"], "get_explored_count")
    assert count == 0, f"Should have 0 explored count after reset, got {count}"


# =============================================================================
# SURFACE VISIBILITY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_surface_always_explored(game):
    """Surface positions (y < surface_row) should always be explored."""
    # Surface positions should always be explored
    surface_pos = {"x": 0, "y": -1}
    result = await game.call(PATHS["exploration_manager"], "is_explored", [surface_pos])
    assert result is True, "Surface positions should always be explored"


@pytest.mark.asyncio
async def test_surface_always_visible(game):
    """Surface positions should always be visible."""
    surface_pos = {"x": 0, "y": -1}
    result = await game.call(PATHS["exploration_manager"], "is_visible", [surface_pos])
    assert result is True, "Surface positions should always be visible"


@pytest.mark.asyncio
async def test_surface_visibility_state_is_full(game):
    """Surface positions should have full visibility state (2)."""
    surface_pos = {"x": 0, "y": -1}
    state = await game.call(PATHS["exploration_manager"], "get_visibility_state", [surface_pos])
    assert state == 2, f"Surface visibility state should be 2 (full), got {state}"


# =============================================================================
# VISIBILITY STATE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_unexplored_visibility_state(game):
    """Unexplored deep positions should have visibility state 0."""
    # Reset to ensure clean state
    await game.call(PATHS["exploration_manager"], "reset")

    # A deep unexplored position
    deep_pos = {"x": 100, "y": 1000}
    state = await game.call(PATHS["exploration_manager"], "get_visibility_state", [deep_pos])
    assert state == 0, f"Unexplored deep position should have state 0, got {state}"


@pytest.mark.asyncio
async def test_visibility_states_valid_range(game):
    """get_visibility_state should return 0, 1, or 2."""
    # Test multiple positions
    positions = [
        {"x": 0, "y": -1},  # Surface
        {"x": 0, "y": 50},  # Underground
        {"x": 100, "y": 500},  # Deep underground
    ]

    for pos in positions:
        state = await game.call(PATHS["exploration_manager"], "get_visibility_state", [pos])
        assert state in [0, 1, 2], f"Visibility state should be 0, 1, or 2, got {state}"


# =============================================================================
# BLOCK MODULATE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_block_modulate_returns_color(game):
    """get_block_modulate should return a color value."""
    pos = {"x": 0, "y": 50}
    color = await game.call(PATHS["exploration_manager"], "get_block_modulate", [pos])
    assert color is not None, "get_block_modulate should return a value"


@pytest.mark.asyncio
async def test_surface_block_modulate_is_white(game):
    """Surface block modulate should be white (Color.WHITE)."""
    surface_pos = {"x": 0, "y": -1}
    color = await game.call(PATHS["exploration_manager"], "get_block_modulate", [surface_pos])
    # Color.WHITE = (1, 1, 1, 1)
    # The result may be a dictionary like {"r": 1, "g": 1, "b": 1, "a": 1}
    if isinstance(color, dict):
        assert color.get("r", 0) >= 0.99, f"White color should have r=1, got {color}"
        assert color.get("g", 0) >= 0.99, f"White color should have g=1, got {color}"
        assert color.get("b", 0) >= 0.99, f"White color should have b=1, got {color}"


# =============================================================================
# MARK EXPLORED TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_mark_block_mined(game):
    """mark_block_mined should mark position as explored."""
    # Reset first
    await game.call(PATHS["exploration_manager"], "reset")

    # Mark a block as mined
    pos = {"x": 10, "y": 20}
    await game.call(PATHS["exploration_manager"], "mark_block_mined", [pos])

    # Check it's now explored
    is_explored = await game.call(PATHS["exploration_manager"], "is_explored", [pos])
    assert is_explored is True, "Mined block should be marked as explored"


@pytest.mark.asyncio
async def test_mark_ladder_placed(game):
    """mark_ladder_placed should mark position and adjacent positions as explored."""
    # Reset first
    await game.call(PATHS["exploration_manager"], "reset")

    # Mark a ladder position
    pos = {"x": 15, "y": 25}
    await game.call(PATHS["exploration_manager"], "mark_ladder_placed", [pos])

    # Check the ladder position is explored
    is_explored = await game.call(PATHS["exploration_manager"], "is_explored", [pos])
    assert is_explored is True, "Ladder position should be explored"

    # Check adjacent positions are also explored
    adjacent_pos = {"x": 14, "y": 25}
    is_adjacent_explored = await game.call(PATHS["exploration_manager"], "is_explored", [adjacent_pos])
    assert is_adjacent_explored is True, "Adjacent to ladder should be explored"


# =============================================================================
# EXPLORED COUNT TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_explored_count_increases_with_mining(game):
    """get_explored_count should increase when blocks are marked as mined."""
    # Reset first
    await game.call(PATHS["exploration_manager"], "reset")

    initial_count = await game.call(PATHS["exploration_manager"], "get_explored_count")

    # Mark some blocks as mined
    for i in range(5):
        pos = {"x": i, "y": 100}
        await game.call(PATHS["exploration_manager"], "mark_block_mined", [pos])

    final_count = await game.call(PATHS["exploration_manager"], "get_explored_count")
    assert final_count > initial_count, f"Count should increase after mining, was {initial_count}, now {final_count}"
    assert final_count >= 5, f"Should have at least 5 explored, got {final_count}"


# =============================================================================
# SAVE/LOAD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_save_data_returns_dict(game):
    """get_save_data should return a dictionary."""
    data = await game.call(PATHS["exploration_manager"], "get_save_data")
    assert data is not None, "get_save_data should return a value"
    assert isinstance(data, dict), f"get_save_data should return dict, got {type(data)}"


@pytest.mark.asyncio
async def test_save_data_preserves_exploration(game):
    """Save data should capture explored positions."""
    # Reset first
    await game.call(PATHS["exploration_manager"], "reset")

    # Mark some positions as explored
    pos = {"x": 50, "y": 50}
    await game.call(PATHS["exploration_manager"], "mark_block_mined", [pos])

    # Get save data
    save_data = await game.call(PATHS["exploration_manager"], "get_save_data")

    # Should have some data (chunk keys)
    assert len(save_data) > 0, "Save data should contain explored chunks"


@pytest.mark.asyncio
async def test_load_save_data_restores_exploration(game):
    """load_save_data should restore exploration state."""
    # Reset first
    await game.call(PATHS["exploration_manager"], "reset")

    # Mark a position
    pos = {"x": 75, "y": 75}
    await game.call(PATHS["exploration_manager"], "mark_block_mined", [pos])

    # Save the data
    save_data = await game.call(PATHS["exploration_manager"], "get_save_data")

    # Reset (clear state)
    await game.call(PATHS["exploration_manager"], "reset")

    # Verify position is no longer explored
    is_explored_before = await game.call(PATHS["exploration_manager"], "is_explored", [pos])
    assert is_explored_before is False, "Position should not be explored after reset"

    # Load the saved data
    await game.call(PATHS["exploration_manager"], "load_save_data", [save_data])

    # Verify position is explored again
    is_explored_after = await game.call(PATHS["exploration_manager"], "is_explored", [pos])
    assert is_explored_after is True, "Position should be explored after load"


# =============================================================================
# RESET TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_reset_clears_exploration(game):
    """reset() should clear all exploration data."""
    # Mark some positions
    for i in range(3):
        pos = {"x": i, "y": 200}
        await game.call(PATHS["exploration_manager"], "mark_block_mined", [pos])

    # Reset
    await game.call(PATHS["exploration_manager"], "reset")

    # Check explored count is 0
    count = await game.call(PATHS["exploration_manager"], "get_explored_count")
    assert count == 0, f"Explored count should be 0 after reset, got {count}"


# =============================================================================
# SIGNAL EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_area_revealed_signal(game):
    """ExplorationManager should have area_revealed signal."""
    has_signal = await game.call(PATHS["exploration_manager"], "has_signal", ["area_revealed"])
    assert has_signal is True, "ExplorationManager should have area_revealed signal"


@pytest.mark.asyncio
async def test_has_exploration_updated_signal(game):
    """ExplorationManager should have exploration_updated signal."""
    has_signal = await game.call(PATHS["exploration_manager"], "has_signal", ["exploration_updated"])
    assert has_signal is True, "ExplorationManager should have exploration_updated signal"


# =============================================================================
# UPDATE PLAYER POSITION TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_update_player_position_callable(game):
    """update_player_position should be callable without error."""
    # This just verifies the method exists and is callable
    world_pos = {"x": 100.0, "y": 200.0}
    result = await game.call(PATHS["exploration_manager"], "update_player_position", [world_pos])
    # Method is void, should not throw
    assert result is None or result is True or result is False, "update_player_position should complete"


@pytest.mark.asyncio
async def test_player_position_reveals_nearby(game):
    """Updating player position should reveal nearby areas."""
    # Reset first
    await game.call(PATHS["exploration_manager"], "reset")

    initial_count = await game.call(PATHS["exploration_manager"], "get_explored_count")

    # Update player position (will reveal area within vision radius)
    world_pos = {"x": 500.0, "y": 600.0}
    await game.call(PATHS["exploration_manager"], "update_player_position", [world_pos])

    final_count = await game.call(PATHS["exploration_manager"], "get_explored_count")
    assert final_count > initial_count, f"Moving player should reveal tiles, was {initial_count}, now {final_count}"
