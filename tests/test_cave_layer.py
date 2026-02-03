"""
CaveLayerManager tests for GoDig endless digging game.

Tests verify that CaveLayerManager:
1. Exists as an autoload singleton
2. Manages two-layer cave system (front/back)
3. Handles treasure room generation
4. Tracks revealed positions
5. Supports save/load
"""
import pytest
from helpers import PATHS


# Path to cave layer manager
CAVE_LAYER_PATH = PATHS.get("cave_layer_manager", "/root/CaveLayerManager")


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_cave_layer_manager_exists(game):
    """CaveLayerManager autoload should exist."""
    result = await game.node_exists(CAVE_LAYER_PATH)
    assert result.get("exists") is True, "CaveLayerManager autoload should exist"


# =============================================================================
# BACK LAYER QUERY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_back_layer_returns_bool(game):
    """has_back_layer should return a boolean."""
    result = await game.call(CAVE_LAYER_PATH, "has_back_layer", [{"x": 100, "y": 100}])
    assert isinstance(result, bool), f"has_back_layer should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_is_back_layer_revealed_returns_bool(game):
    """is_back_layer_revealed should return a boolean."""
    result = await game.call(CAVE_LAYER_PATH, "is_back_layer_revealed", [{"x": 100, "y": 100}])
    assert isinstance(result, bool), f"is_back_layer_revealed should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_is_back_layer_entrance_returns_bool(game):
    """is_back_layer_entrance should return a boolean."""
    result = await game.call(CAVE_LAYER_PATH, "is_back_layer_entrance", [{"x": 100, "y": 100}])
    assert isinstance(result, bool), f"is_back_layer_entrance should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_get_back_content_type_returns_int(game):
    """get_back_content_type should return an integer."""
    result = await game.call(CAVE_LAYER_PATH, "get_back_content_type", [{"x": 100, "y": 100}])
    assert isinstance(result, int), f"get_back_content_type should return int, got {type(result)}"


@pytest.mark.asyncio
async def test_get_treasure_room_can_be_null(game):
    """get_treasure_room should return null for positions without treasure."""
    result = await game.call(CAVE_LAYER_PATH, "get_treasure_room", [{"x": 0, "y": 0}])
    # May be null/None or a dictionary
    assert result is None or isinstance(result, dict), f"get_treasure_room should return null or dict, got {type(result)}"


# =============================================================================
# TREASURE ROOM CONSTANT TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_treasure_rooms_exist(game):
    """TREASURE_ROOMS constant should exist and be accessible via stats."""
    result = await game.call(CAVE_LAYER_PATH, "get_stats")
    # Indirectly verify by checking stats includes treasure_rooms count
    assert "treasure_rooms" in result, "stats should have treasure_rooms"


# =============================================================================
# STATS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_stats_returns_dict(game):
    """get_stats should return a dictionary."""
    result = await game.call(CAVE_LAYER_PATH, "get_stats")
    assert result is not None, "get_stats should return a value"
    assert isinstance(result, dict), f"get_stats should return dict, got {type(result)}"


@pytest.mark.asyncio
async def test_get_stats_has_back_layer_chunks(game):
    """get_stats should include back_layer_chunks."""
    result = await game.call(CAVE_LAYER_PATH, "get_stats")
    assert "back_layer_chunks" in result, "stats should have back_layer_chunks"
    assert isinstance(result["back_layer_chunks"], int), "back_layer_chunks should be int"


@pytest.mark.asyncio
async def test_get_stats_has_revealed_positions(game):
    """get_stats should include revealed_positions."""
    result = await game.call(CAVE_LAYER_PATH, "get_stats")
    assert "revealed_positions" in result, "stats should have revealed_positions"
    assert isinstance(result["revealed_positions"], int), "revealed_positions should be int"


@pytest.mark.asyncio
async def test_get_stats_has_temp_revealed(game):
    """get_stats should include temp_revealed."""
    result = await game.call(CAVE_LAYER_PATH, "get_stats")
    assert "temp_revealed" in result, "stats should have temp_revealed"


@pytest.mark.asyncio
async def test_get_stats_has_treasure_rooms(game):
    """get_stats should include treasure_rooms count."""
    result = await game.call(CAVE_LAYER_PATH, "get_stats")
    assert "treasure_rooms" in result, "stats should have treasure_rooms"


@pytest.mark.asyncio
async def test_get_stats_has_hidden_passages(game):
    """get_stats should include hidden_passages."""
    result = await game.call(CAVE_LAYER_PATH, "get_stats")
    assert "hidden_passages" in result, "stats should have hidden_passages"


@pytest.mark.asyncio
async def test_get_stats_has_reveal_active(game):
    """get_stats should include reveal_active."""
    result = await game.call(CAVE_LAYER_PATH, "get_stats")
    assert "reveal_active" in result, "stats should have reveal_active"


@pytest.mark.asyncio
async def test_get_stats_has_reveal_time_remaining(game):
    """get_stats should include reveal_time_remaining."""
    result = await game.call(CAVE_LAYER_PATH, "get_stats")
    assert "reveal_time_remaining" in result, "stats should have reveal_time_remaining"


# =============================================================================
# COLLECT/DISCOVER TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_collect_treasure_room_returns_array(game):
    """collect_treasure_room should return an array."""
    result = await game.call(CAVE_LAYER_PATH, "collect_treasure_room", [{"x": 0, "y": 0}])
    assert result is not None, "collect_treasure_room should return a value"
    assert isinstance(result, list), f"collect_treasure_room should return array, got {type(result)}"


@pytest.mark.asyncio
async def test_collect_treasure_room_empty_for_nonexistent(game):
    """collect_treasure_room should return empty array for position without treasure."""
    result = await game.call(CAVE_LAYER_PATH, "collect_treasure_room", [{"x": -999, "y": -999}])
    assert result == [], f"Should return empty array for nonexistent treasure, got {result}"


@pytest.mark.asyncio
async def test_discover_passage_returns_dict(game):
    """discover_passage should return a dictionary."""
    result = await game.call(CAVE_LAYER_PATH, "discover_passage", [{"x": 0, "y": 0}])
    assert result is not None, "discover_passage should return a value"
    assert isinstance(result, dict), f"discover_passage should return dict, got {type(result)}"


@pytest.mark.asyncio
async def test_discover_passage_empty_for_nonexistent(game):
    """discover_passage should return empty dict for position without passage."""
    result = await game.call(CAVE_LAYER_PATH, "discover_passage", [{"x": -999, "y": -999}])
    assert result == {}, f"Should return empty dict for nonexistent passage, got {result}"


# =============================================================================
# RESET TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_reset_completes(game):
    """reset should complete without error."""
    result = await game.call(CAVE_LAYER_PATH, "reset")
    assert result is None or isinstance(result, (bool, dict)), "reset should complete"


@pytest.mark.asyncio
async def test_reset_clears_state(game):
    """reset should clear all state."""
    await game.call(CAVE_LAYER_PATH, "reset")
    stats = await game.call(CAVE_LAYER_PATH, "get_stats")
    assert stats["back_layer_chunks"] == 0, "back_layer_chunks should be 0 after reset"
    assert stats["revealed_positions"] == 0, "revealed_positions should be 0 after reset"
    assert stats["reveal_active"] is False, "reveal_active should be false after reset"


# =============================================================================
# SAVE/LOAD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_save_data_returns_dict(game):
    """get_save_data should return a dictionary."""
    result = await game.call(CAVE_LAYER_PATH, "get_save_data")
    assert result is not None, "get_save_data should return a value"
    assert isinstance(result, dict), f"get_save_data should return dict, got {type(result)}"


@pytest.mark.asyncio
async def test_get_save_data_has_revealed_positions(game):
    """get_save_data should include revealed_positions."""
    result = await game.call(CAVE_LAYER_PATH, "get_save_data")
    assert "revealed_positions" in result, "save data should have revealed_positions"


@pytest.mark.asyncio
async def test_get_save_data_has_collected_rooms(game):
    """get_save_data should include collected_rooms."""
    result = await game.call(CAVE_LAYER_PATH, "get_save_data")
    assert "collected_rooms" in result, "save data should have collected_rooms"


@pytest.mark.asyncio
async def test_get_save_data_has_discovered_passages(game):
    """get_save_data should include discovered_passages."""
    result = await game.call(CAVE_LAYER_PATH, "get_save_data")
    assert "discovered_passages" in result, "save data should have discovered_passages"


@pytest.mark.asyncio
async def test_load_save_data_completes(game):
    """load_save_data should complete without error."""
    save_data = {
        "revealed_positions": [],
        "collected_rooms": [],
        "discovered_passages": []
    }
    result = await game.call(CAVE_LAYER_PATH, "load_save_data", [save_data])
    assert result is None or isinstance(result, (bool, dict)), "load_save_data should complete"


# =============================================================================
# SIGNAL TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_back_layer_revealed_signal(game):
    """CaveLayerManager should have back_layer_revealed signal."""
    has_signal = await game.call(CAVE_LAYER_PATH, "has_signal", ["back_layer_revealed"])
    assert has_signal is True, "CaveLayerManager should have back_layer_revealed signal"


@pytest.mark.asyncio
async def test_has_back_layer_hidden_signal(game):
    """CaveLayerManager should have back_layer_hidden signal."""
    has_signal = await game.call(CAVE_LAYER_PATH, "has_signal", ["back_layer_hidden"])
    assert has_signal is True, "CaveLayerManager should have back_layer_hidden signal"


@pytest.mark.asyncio
async def test_has_treasure_room_found_signal(game):
    """CaveLayerManager should have treasure_room_found signal."""
    has_signal = await game.call(CAVE_LAYER_PATH, "has_signal", ["treasure_room_found"])
    assert has_signal is True, "CaveLayerManager should have treasure_room_found signal"


@pytest.mark.asyncio
async def test_has_hidden_passage_discovered_signal(game):
    """CaveLayerManager should have hidden_passage_discovered signal."""
    has_signal = await game.call(CAVE_LAYER_PATH, "has_signal", ["hidden_passage_discovered"])
    assert has_signal is True, "CaveLayerManager should have hidden_passage_discovered signal"


@pytest.mark.asyncio
async def test_has_back_layer_item_used_signal(game):
    """CaveLayerManager should have back_layer_item_used signal."""
    has_signal = await game.call(CAVE_LAYER_PATH, "has_signal", ["back_layer_item_used"])
    assert has_signal is True, "CaveLayerManager should have back_layer_item_used signal"


@pytest.mark.asyncio
async def test_has_back_layer_entrance_nearby_signal(game):
    """CaveLayerManager should have back_layer_entrance_nearby signal."""
    has_signal = await game.call(CAVE_LAYER_PATH, "has_signal", ["back_layer_entrance_nearby"])
    assert has_signal is True, "CaveLayerManager should have back_layer_entrance_nearby signal"


# =============================================================================
# INITIAL STATE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_initial_state_no_revealed(game):
    """Initial state should have no revealed positions (after reset)."""
    await game.call(CAVE_LAYER_PATH, "reset")
    result = await game.call(CAVE_LAYER_PATH, "is_back_layer_revealed", [{"x": 0, "y": 0}])
    assert result is False, "Position should not be revealed initially"


@pytest.mark.asyncio
async def test_initial_state_reveal_not_active(game):
    """Initial state should not have active reveal (after reset)."""
    await game.call(CAVE_LAYER_PATH, "reset")
    stats = await game.call(CAVE_LAYER_PATH, "get_stats")
    assert stats["reveal_active"] is False, "reveal_active should be false initially"
