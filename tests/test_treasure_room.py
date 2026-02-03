"""
TreasureRoomManager tests for GoDig endless digging game.

Tests verify that TreasureRoomManager:
1. Exists as an autoload singleton
2. Has proper room type configuration
3. Tracks discovered and looted rooms
4. Supports save/load of room data
5. Has required signals
"""
import pytest
from helpers import PATHS


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_treasure_room_manager_exists(game):
    """TreasureRoomManager autoload should exist."""
    result = await game.node_exists(PATHS["treasure_room_manager"])
    assert result.get("exists") is True, "TreasureRoomManager autoload should exist"


# =============================================================================
# CONSTANT TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_room_config_exists(game):
    """ROOM_CONFIG constant should be configured."""
    result = await game.get_property(PATHS["treasure_room_manager"], "ROOM_CONFIG")
    assert result is not None, "ROOM_CONFIG should exist"
    assert isinstance(result, dict), f"ROOM_CONFIG should be dict, got {type(result)}"


@pytest.mark.asyncio
async def test_min_room_distance_configured(game):
    """MIN_ROOM_DISTANCE constant should be configured."""
    result = await game.get_property(PATHS["treasure_room_manager"], "MIN_ROOM_DISTANCE")
    assert result is not None, "MIN_ROOM_DISTANCE should exist"
    assert isinstance(result, (int, float)), f"MIN_ROOM_DISTANCE should be number, got {type(result)}"
    assert result > 0, f"MIN_ROOM_DISTANCE should be positive, got {result}"


@pytest.mark.asyncio
async def test_max_rooms_per_chunk_configured(game):
    """MAX_ROOMS_PER_CHUNK constant should be configured."""
    result = await game.get_property(PATHS["treasure_room_manager"], "MAX_ROOMS_PER_CHUNK")
    assert result is not None, "MAX_ROOMS_PER_CHUNK should exist"
    assert isinstance(result, int), f"MAX_ROOMS_PER_CHUNK should be int, got {type(result)}"
    assert result >= 1, f"MAX_ROOMS_PER_CHUNK should be at least 1, got {result}"


# =============================================================================
# INITIAL STATE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_initial_discovered_empty_after_reset(game):
    """TreasureRoomManager should have no discovered rooms after reset."""
    # Reset to ensure clean state
    await game.call(PATHS["treasure_room_manager"], "reset")

    stats = await game.call(PATHS["treasure_room_manager"], "get_stats")
    assert stats.get("total_discovered") == 0, f"Should have 0 discovered rooms after reset, got {stats.get('total_discovered')}"


@pytest.mark.asyncio
async def test_initial_looted_empty_after_reset(game):
    """TreasureRoomManager should have no looted rooms after reset."""
    # Reset to ensure clean state
    await game.call(PATHS["treasure_room_manager"], "reset")

    stats = await game.call(PATHS["treasure_room_manager"], "get_stats")
    assert stats.get("total_looted") == 0, f"Should have 0 looted rooms after reset, got {stats.get('total_looted')}"


# =============================================================================
# ROOM POSITION QUERY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_is_room_position_returns_false_for_empty(game):
    """is_room_position should return false for positions without rooms."""
    # Reset to ensure clean state
    await game.call(PATHS["treasure_room_manager"], "reset")

    pos = {"x": 1000, "y": 1000}
    result = await game.call(PATHS["treasure_room_manager"], "is_room_position", [pos])
    assert result is False, "is_room_position should return false for empty position"


@pytest.mark.asyncio
async def test_get_room_at_returns_empty_for_no_room(game):
    """get_room_at should return empty dict for positions without rooms."""
    # Reset to ensure clean state
    await game.call(PATHS["treasure_room_manager"], "reset")

    pos = {"x": 2000, "y": 2000}
    result = await game.call(PATHS["treasure_room_manager"], "get_room_at", [pos])
    assert result is not None, "get_room_at should return a value"
    assert isinstance(result, dict), f"get_room_at should return dict, got {type(result)}"
    # Empty dict means no room
    assert len(result) == 0, f"Should return empty dict for no room, got {len(result)} keys"


@pytest.mark.asyncio
async def test_get_room_center_returns_invalid_for_no_room(game):
    """get_room_center should return (-1, -1) for positions without rooms."""
    # Reset to ensure clean state
    await game.call(PATHS["treasure_room_manager"], "reset")

    pos = {"x": 3000, "y": 3000}
    result = await game.call(PATHS["treasure_room_manager"], "get_room_center", [pos])
    # Should return Vector2i(-1, -1) which may serialize as dict
    if isinstance(result, dict):
        assert result.get("x") == -1, f"Should return x=-1 for no room, got {result.get('x')}"
        assert result.get("y") == -1, f"Should return y=-1 for no room, got {result.get('y')}"


# =============================================================================
# ROOM STATE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_is_room_discovered_returns_false_for_undiscovered(game):
    """is_room_discovered should return false for undiscovered room positions."""
    # Reset to ensure clean state
    await game.call(PATHS["treasure_room_manager"], "reset")

    pos = {"x": 100, "y": 100}
    result = await game.call(PATHS["treasure_room_manager"], "is_room_discovered", [pos])
    assert result is False, "is_room_discovered should return false for undiscovered position"


@pytest.mark.asyncio
async def test_is_room_looted_returns_false_for_unlooted(game):
    """is_room_looted should return false for unlooted room positions."""
    # Reset to ensure clean state
    await game.call(PATHS["treasure_room_manager"], "reset")

    pos = {"x": 200, "y": 200}
    result = await game.call(PATHS["treasure_room_manager"], "is_room_looted", [pos])
    assert result is False, "is_room_looted should return false for unlooted position"


# =============================================================================
# GET ALL ROOMS TEST
# =============================================================================

@pytest.mark.asyncio
async def test_get_all_room_positions_returns_array(game):
    """get_all_room_positions should return an array."""
    result = await game.call(PATHS["treasure_room_manager"], "get_all_room_positions")
    assert result is not None, "get_all_room_positions should return a value"
    assert isinstance(result, list), f"get_all_room_positions should return array, got {type(result)}"


@pytest.mark.asyncio
async def test_get_all_room_positions_empty_after_reset(game):
    """get_all_room_positions should return empty array after reset."""
    # Reset to ensure clean state
    await game.call(PATHS["treasure_room_manager"], "reset")

    result = await game.call(PATHS["treasure_room_manager"], "get_all_room_positions")
    assert len(result) == 0, f"Should have no rooms after reset, got {len(result)}"


# =============================================================================
# STATISTICS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_stats_returns_dict(game):
    """get_stats should return a dictionary with statistics."""
    stats = await game.call(PATHS["treasure_room_manager"], "get_stats")
    assert stats is not None, "get_stats should return a value"
    assert isinstance(stats, dict), f"get_stats should return dict, got {type(stats)}"


@pytest.mark.asyncio
async def test_get_stats_has_required_fields(game):
    """get_stats should have required statistical fields."""
    stats = await game.call(PATHS["treasure_room_manager"], "get_stats")

    assert "total_discovered" in stats, "Stats should include total_discovered"
    assert "total_looted" in stats, "Stats should include total_looted"
    assert "active_rooms" in stats, "Stats should include active_rooms"
    assert "rooms_by_type" in stats, "Stats should include rooms_by_type"


@pytest.mark.asyncio
async def test_stats_rooms_by_type_is_dict(game):
    """get_stats rooms_by_type should be a dictionary."""
    stats = await game.call(PATHS["treasure_room_manager"], "get_stats")
    rooms_by_type = stats.get("rooms_by_type")
    assert rooms_by_type is not None, "rooms_by_type should exist"
    assert isinstance(rooms_by_type, dict), f"rooms_by_type should be dict, got {type(rooms_by_type)}"


# =============================================================================
# SAVE/LOAD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_save_data_returns_dict(game):
    """get_save_data should return a dictionary."""
    data = await game.call(PATHS["treasure_room_manager"], "get_save_data")
    assert data is not None, "get_save_data should return a value"
    assert isinstance(data, dict), f"get_save_data should return dict, got {type(data)}"


@pytest.mark.asyncio
async def test_get_save_data_has_required_fields(game):
    """get_save_data should have required fields."""
    data = await game.call(PATHS["treasure_room_manager"], "get_save_data")

    assert "discovered_rooms" in data, "Save data should include discovered_rooms"
    assert "looted_rooms" in data, "Save data should include looted_rooms"


@pytest.mark.asyncio
async def test_save_data_arrays_are_lists(game):
    """Save data arrays should be lists."""
    data = await game.call(PATHS["treasure_room_manager"], "get_save_data")

    discovered = data.get("discovered_rooms")
    assert isinstance(discovered, list), f"discovered_rooms should be list, got {type(discovered)}"

    looted = data.get("looted_rooms")
    assert isinstance(looted, list), f"looted_rooms should be list, got {type(looted)}"


@pytest.mark.asyncio
async def test_load_save_data_callable(game):
    """load_save_data should be callable without error."""
    # Create minimal save data
    save_data = {
        "discovered_rooms": [],
        "looted_rooms": [],
    }
    result = await game.call(PATHS["treasure_room_manager"], "load_save_data", [save_data])
    # Method is void, should not throw
    assert result is None or result is True or result is False, "load_save_data should complete"


# =============================================================================
# RESET TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_reset_clears_all_state(game):
    """reset() should clear all room tracking state."""
    # Reset
    await game.call(PATHS["treasure_room_manager"], "reset")

    # Check stats are zeroed
    stats = await game.call(PATHS["treasure_room_manager"], "get_stats")
    assert stats.get("total_discovered") == 0, "Discovered should be 0 after reset"
    assert stats.get("total_looted") == 0, "Looted should be 0 after reset"
    assert stats.get("active_rooms") == 0, "Active rooms should be 0 after reset"


# =============================================================================
# SIGNAL EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_room_discovered_signal(game):
    """TreasureRoomManager should have room_discovered signal."""
    has_signal = await game.call(PATHS["treasure_room_manager"], "has_signal", ["room_discovered"])
    assert has_signal is True, "TreasureRoomManager should have room_discovered signal"


@pytest.mark.asyncio
async def test_has_room_generated_signal(game):
    """TreasureRoomManager should have room_generated signal."""
    has_signal = await game.call(PATHS["treasure_room_manager"], "has_signal", ["room_generated"])
    assert has_signal is True, "TreasureRoomManager should have room_generated signal"


@pytest.mark.asyncio
async def test_has_room_looted_signal(game):
    """TreasureRoomManager should have room_looted signal."""
    has_signal = await game.call(PATHS["treasure_room_manager"], "has_signal", ["room_looted"])
    assert has_signal is True, "TreasureRoomManager should have room_looted signal"


# =============================================================================
# ROOM SPAWN CHECK TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_check_room_spawn_returns_minus_one_for_shallow(game):
    """check_room_spawn should return -1 for shallow depths."""
    # Reset to ensure clean state
    await game.call(PATHS["treasure_room_manager"], "reset")

    cave_pos = {"x": 0, "y": 10}
    depth = 10  # Too shallow
    world_seed = 12345
    chunk_pos = {"x": 0, "y": 0}

    result = await game.call(PATHS["treasure_room_manager"], "check_room_spawn", [cave_pos, depth, world_seed, chunk_pos])
    assert result == -1, f"check_room_spawn should return -1 for shallow depth, got {result}"


@pytest.mark.asyncio
async def test_check_room_spawn_returns_valid_for_deep(game):
    """check_room_spawn should return valid result for deep positions."""
    # Reset to ensure clean state
    await game.call(PATHS["treasure_room_manager"], "reset")

    cave_pos = {"x": 100, "y": 500}
    depth = 500  # Very deep
    world_seed = 12345
    chunk_pos = {"x": 6, "y": 31}

    result = await game.call(PATHS["treasure_room_manager"], "check_room_spawn", [cave_pos, depth, world_seed, chunk_pos])
    # Should return -1 (no spawn) or a valid room type (0, 1, or 2)
    assert result >= -1 and result <= 2, f"check_room_spawn should return valid result, got {result}"
