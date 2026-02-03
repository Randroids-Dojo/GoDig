"""
SecretLayerManager tests for GoDig endless digging game.

Tests verify that SecretLayerManager:
1. Exists as an autoload singleton
2. Has proper signals for secret discovery events
3. Has configuration constants for secret walls
4. Has check/query methods for secret walls
5. Has reset functionality
6. Has save/load functionality
7. get_stats returns expected data

Based on Animal Well's approach to layered discovery.
"""
import pytest
from helpers import PATHS


# Path to secret layer manager
SECRET_PATH = PATHS.get("secret_layer_manager", "/root/SecretLayerManager")


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_secret_layer_manager_exists(game):
    """SecretLayerManager autoload should exist."""
    result = await game.node_exists(SECRET_PATH)
    assert result.get("exists") is True, "SecretLayerManager autoload should exist"


# =============================================================================
# SIGNAL TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_secret_wall_detected_signal(game):
    """SecretLayerManager should have secret_wall_detected signal."""
    has_signal = await game.call(SECRET_PATH, "has_signal", ["secret_wall_detected"])
    assert has_signal is True, "SecretLayerManager should have secret_wall_detected signal"


@pytest.mark.asyncio
async def test_has_secret_wall_broken_signal(game):
    """SecretLayerManager should have secret_wall_broken signal."""
    has_signal = await game.call(SECRET_PATH, "has_signal", ["secret_wall_broken"])
    assert has_signal is True, "SecretLayerManager should have secret_wall_broken signal"


@pytest.mark.asyncio
async def test_has_layer2_discovery_signal(game):
    """SecretLayerManager should have layer2_discovery signal."""
    has_signal = await game.call(SECRET_PATH, "has_signal", ["layer2_discovery"])
    assert has_signal is True, "SecretLayerManager should have layer2_discovery signal"


@pytest.mark.asyncio
async def test_has_rare_secret_found_signal(game):
    """SecretLayerManager should have rare_secret_found signal."""
    has_signal = await game.call(SECRET_PATH, "has_signal", ["rare_secret_found"])
    assert has_signal is True, "SecretLayerManager should have rare_secret_found signal"


@pytest.mark.asyncio
async def test_has_secret_hint_shown_signal(game):
    """SecretLayerManager should have secret_hint_shown signal."""
    has_signal = await game.call(SECRET_PATH, "has_signal", ["secret_hint_shown"])
    assert has_signal is True, "SecretLayerManager should have secret_hint_shown signal"


# =============================================================================
# CONSTANT TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_secret_wall_config_exists(game):
    """SECRET_WALL_CONFIG should exist and be a dictionary."""
    result = await game.get_property(SECRET_PATH, "SECRET_WALL_CONFIG")
    assert result is not None, "SECRET_WALL_CONFIG should exist"
    assert isinstance(result, dict), f"SECRET_WALL_CONFIG should be dict, got {type(result)}"


@pytest.mark.asyncio
async def test_secret_wall_config_has_wall_types(game):
    """SECRET_WALL_CONFIG should have expected wall types."""
    result = await game.get_property(SECRET_PATH, "SECRET_WALL_CONFIG")
    expected_types = ["weak_spot", "cracked", "hollow", "ancient"]
    for wall_type in expected_types:
        assert wall_type in result, f"SECRET_WALL_CONFIG should have '{wall_type}'"


@pytest.mark.asyncio
async def test_hidden_room_rewards_exists(game):
    """HIDDEN_ROOM_REWARDS should exist and be a dictionary."""
    result = await game.get_property(SECRET_PATH, "HIDDEN_ROOM_REWARDS")
    assert result is not None, "HIDDEN_ROOM_REWARDS should exist"
    assert isinstance(result, dict), f"HIDDEN_ROOM_REWARDS should be dict, got {type(result)}"


@pytest.mark.asyncio
async def test_hidden_room_rewards_has_tiers(game):
    """HIDDEN_ROOM_REWARDS should have depth tier definitions."""
    result = await game.get_property(SECRET_PATH, "HIDDEN_ROOM_REWARDS")
    expected_tiers = ["shallow", "medium", "deep", "abyssal"]
    for tier in expected_tiers:
        assert tier in result, f"HIDDEN_ROOM_REWARDS should have '{tier}' tier"


@pytest.mark.asyncio
async def test_chunk_size_constant(game):
    """CHUNK_SIZE should be configured."""
    result = await game.get_property(SECRET_PATH, "CHUNK_SIZE")
    assert result is not None, "CHUNK_SIZE should exist"
    assert result > 0, f"CHUNK_SIZE should be positive, got {result}"


# =============================================================================
# METHOD EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_check_secret_wall_spawn_method(game):
    """SecretLayerManager should have check_secret_wall_spawn method."""
    result = await game.call(SECRET_PATH, "has_method", ["check_secret_wall_spawn"])
    assert result is True, "SecretLayerManager should have check_secret_wall_spawn method"


@pytest.mark.asyncio
async def test_has_register_secret_wall_method(game):
    """SecretLayerManager should have register_secret_wall method."""
    result = await game.call(SECRET_PATH, "has_method", ["register_secret_wall"])
    assert result is True, "SecretLayerManager should have register_secret_wall method"


@pytest.mark.asyncio
async def test_has_is_secret_wall_method(game):
    """SecretLayerManager should have is_secret_wall method."""
    result = await game.call(SECRET_PATH, "has_method", ["is_secret_wall"])
    assert result is True, "SecretLayerManager should have is_secret_wall method"


@pytest.mark.asyncio
async def test_has_get_secret_wall_method(game):
    """SecretLayerManager should have get_secret_wall method."""
    result = await game.call(SECRET_PATH, "has_method", ["get_secret_wall"])
    assert result is True, "SecretLayerManager should have get_secret_wall method"


@pytest.mark.asyncio
async def test_has_get_wall_hint_type_method(game):
    """SecretLayerManager should have get_wall_hint_type method."""
    result = await game.call(SECRET_PATH, "has_method", ["get_wall_hint_type"])
    assert result is True, "SecretLayerManager should have get_wall_hint_type method"


@pytest.mark.asyncio
async def test_has_player_near_secret_method(game):
    """SecretLayerManager should have player_near_secret method."""
    result = await game.call(SECRET_PATH, "has_method", ["player_near_secret"])
    assert result is True, "SecretLayerManager should have player_near_secret method"


@pytest.mark.asyncio
async def test_has_on_secret_wall_broken_method(game):
    """SecretLayerManager should have on_secret_wall_broken method."""
    result = await game.call(SECRET_PATH, "has_method", ["on_secret_wall_broken"])
    assert result is True, "SecretLayerManager should have on_secret_wall_broken method"


@pytest.mark.asyncio
async def test_has_get_secret_hints_in_chunk_method(game):
    """SecretLayerManager should have get_secret_hints_in_chunk method."""
    result = await game.call(SECRET_PATH, "has_method", ["get_secret_hints_in_chunk"])
    assert result is True, "SecretLayerManager should have get_secret_hints_in_chunk method"


@pytest.mark.asyncio
async def test_has_unload_chunk_method(game):
    """SecretLayerManager should have unload_chunk method."""
    result = await game.call(SECRET_PATH, "has_method", ["unload_chunk"])
    assert result is True, "SecretLayerManager should have unload_chunk method"


@pytest.mark.asyncio
async def test_has_reset_method(game):
    """SecretLayerManager should have reset method."""
    result = await game.call(SECRET_PATH, "has_method", ["reset"])
    assert result is True, "SecretLayerManager should have reset method"


@pytest.mark.asyncio
async def test_has_get_save_data_method(game):
    """SecretLayerManager should have get_save_data method."""
    result = await game.call(SECRET_PATH, "has_method", ["get_save_data"])
    assert result is True, "SecretLayerManager should have get_save_data method"


@pytest.mark.asyncio
async def test_has_load_save_data_method(game):
    """SecretLayerManager should have load_save_data method."""
    result = await game.call(SECRET_PATH, "has_method", ["load_save_data"])
    assert result is True, "SecretLayerManager should have load_save_data method"


@pytest.mark.asyncio
async def test_has_get_stats_method(game):
    """SecretLayerManager should have get_stats method."""
    result = await game.call(SECRET_PATH, "has_method", ["get_stats"])
    assert result is True, "SecretLayerManager should have get_stats method"


@pytest.mark.asyncio
async def test_has_should_show_hint_method(game):
    """SecretLayerManager should have should_show_hint method."""
    result = await game.call(SECRET_PATH, "has_method", ["should_show_hint"])
    assert result is True, "SecretLayerManager should have should_show_hint method"


# =============================================================================
# GET_STATS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_stats_returns_dict(game):
    """get_stats should return a dictionary."""
    result = await game.call(SECRET_PATH, "get_stats")
    assert result is not None, "get_stats should return a value"
    assert isinstance(result, dict), f"get_stats should return dict, got {type(result)}"


@pytest.mark.asyncio
async def test_get_stats_has_active_secrets(game):
    """get_stats should include active_secrets count."""
    result = await game.call(SECRET_PATH, "get_stats")
    assert "active_secrets" in result, "stats should have active_secrets"
    assert isinstance(result["active_secrets"], int), "active_secrets should be int"


@pytest.mark.asyncio
async def test_get_stats_has_broken_walls(game):
    """get_stats should include broken_walls count."""
    result = await game.call(SECRET_PATH, "get_stats")
    assert "broken_walls" in result, "stats should have broken_walls"
    assert isinstance(result["broken_walls"], int), "broken_walls should be int"


@pytest.mark.asyncio
async def test_get_stats_has_walls_broken_total(game):
    """get_stats should include walls_broken_total."""
    result = await game.call(SECRET_PATH, "get_stats")
    assert "walls_broken_total" in result, "stats should have walls_broken_total"
    assert isinstance(result["walls_broken_total"], int), "walls_broken_total should be int"


@pytest.mark.asyncio
async def test_get_stats_has_hidden_rooms_found(game):
    """get_stats should include hidden_rooms_found."""
    result = await game.call(SECRET_PATH, "get_stats")
    assert "hidden_rooms_found" in result, "stats should have hidden_rooms_found"
    assert isinstance(result["hidden_rooms_found"], int), "hidden_rooms_found should be int"


@pytest.mark.asyncio
async def test_get_stats_has_layer2_discoveries(game):
    """get_stats should include layer2_discoveries count."""
    result = await game.call(SECRET_PATH, "get_stats")
    assert "layer2_discoveries" in result, "stats should have layer2_discoveries"
    assert isinstance(result["layer2_discoveries"], int), "layer2_discoveries should be int"


# =============================================================================
# RESET TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_reset_clears_stats(game):
    """reset should clear all statistics."""
    await game.call(SECRET_PATH, "reset")
    stats = await game.call(SECRET_PATH, "get_stats")
    assert stats["active_secrets"] == 0, "active_secrets should be 0 after reset"
    assert stats["broken_walls"] == 0, "broken_walls should be 0 after reset"
    assert stats["walls_broken_total"] == 0, "walls_broken_total should be 0 after reset"
    assert stats["hidden_rooms_found"] == 0, "hidden_rooms_found should be 0 after reset"


# =============================================================================
# QUERY TESTS (on positions without secrets)
# =============================================================================

@pytest.mark.asyncio
async def test_is_secret_wall_false_for_normal_position(game):
    """is_secret_wall should return false for position without secret."""
    await game.call(SECRET_PATH, "reset")
    result = await game.call(SECRET_PATH, "is_secret_wall", [{"x": 9999, "y": 9999}])
    assert result is False, "is_secret_wall should be false for position without secret"


@pytest.mark.asyncio
async def test_get_secret_wall_empty_for_normal_position(game):
    """get_secret_wall should return empty dict for position without secret."""
    await game.call(SECRET_PATH, "reset")
    result = await game.call(SECRET_PATH, "get_secret_wall", [{"x": 9999, "y": 9999}])
    assert result == {} or result is None or (isinstance(result, dict) and len(result) == 0), \
        f"get_secret_wall should return empty for position without secret, got {result}"


@pytest.mark.asyncio
async def test_get_wall_hint_type_empty_for_normal_position(game):
    """get_wall_hint_type should return empty string for position without secret."""
    await game.call(SECRET_PATH, "reset")
    result = await game.call(SECRET_PATH, "get_wall_hint_type", [{"x": 9999, "y": 9999}])
    assert result == "", f"get_wall_hint_type should return empty string, got '{result}'"


@pytest.mark.asyncio
async def test_should_show_hint_false_for_normal_position(game):
    """should_show_hint should return false for position without secret."""
    await game.call(SECRET_PATH, "reset")
    result = await game.call(SECRET_PATH, "should_show_hint", [{"x": 9999, "y": 9999}])
    assert result is False, "should_show_hint should be false for position without secret"


# =============================================================================
# CHECK_SECRET_WALL_SPAWN TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_check_secret_wall_spawn_returns_dict(game):
    """check_secret_wall_spawn should return a dictionary."""
    result = await game.call(SECRET_PATH, "check_secret_wall_spawn", [{"x": 0, "y": 100}, 100, 12345, True])
    assert result is not None, "check_secret_wall_spawn should return a value"
    assert isinstance(result, dict), f"check_secret_wall_spawn should return dict, got {type(result)}"


@pytest.mark.asyncio
async def test_check_secret_wall_spawn_has_is_secret(game):
    """check_secret_wall_spawn result should have is_secret field."""
    result = await game.call(SECRET_PATH, "check_secret_wall_spawn", [{"x": 0, "y": 100}, 100, 12345, True])
    assert "is_secret" in result, "Result should have is_secret field"
    assert isinstance(result["is_secret"], bool), "is_secret should be boolean"


@pytest.mark.asyncio
async def test_check_secret_wall_spawn_has_wall_type(game):
    """check_secret_wall_spawn result should have wall_type field."""
    result = await game.call(SECRET_PATH, "check_secret_wall_spawn", [{"x": 0, "y": 100}, 100, 12345, True])
    assert "wall_type" in result, "Result should have wall_type field"


@pytest.mark.asyncio
async def test_check_secret_wall_spawn_has_has_room(game):
    """check_secret_wall_spawn result should have has_room field."""
    result = await game.call(SECRET_PATH, "check_secret_wall_spawn", [{"x": 0, "y": 100}, 100, 12345, True])
    assert "has_room" in result, "Result should have has_room field"


@pytest.mark.asyncio
async def test_check_secret_wall_spawn_not_adjacent_returns_no_secret(game):
    """check_secret_wall_spawn should not create secret if not adjacent to cave."""
    result = await game.call(SECRET_PATH, "check_secret_wall_spawn", [{"x": 0, "y": 100}, 100, 12345, False])
    assert result["is_secret"] is False, "Should not create secret when not adjacent to cave"


# =============================================================================
# SAVE/LOAD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_save_data_returns_dict(game):
    """get_save_data should return a dictionary."""
    result = await game.call(SECRET_PATH, "get_save_data")
    assert result is not None, "get_save_data should return a value"
    assert isinstance(result, dict), f"get_save_data should return dict, got {type(result)}"


@pytest.mark.asyncio
async def test_get_save_data_has_required_fields(game):
    """get_save_data should include all required persistence fields."""
    result = await game.call(SECRET_PATH, "get_save_data")
    required_fields = ["broken_walls", "layer2_discoveries", "walls_broken_count", "hidden_rooms_found"]
    for field in required_fields:
        assert field in result, f"Save data should include '{field}'"


@pytest.mark.asyncio
async def test_load_save_data_restores_stats(game):
    """load_save_data should restore statistics."""
    # Reset first
    await game.call(SECRET_PATH, "reset")

    # Load save data
    test_data = {
        "broken_walls": [[10, 20], [30, 40]],
        "layer2_discoveries": {"discovery_1": True},
        "walls_broken_count": 5,
        "hidden_rooms_found": 3
    }
    await game.call(SECRET_PATH, "load_save_data", [test_data])

    # Verify state was restored
    stats = await game.call(SECRET_PATH, "get_stats")
    assert stats["walls_broken_total"] == 5, f"walls_broken_total should be 5, got {stats['walls_broken_total']}"
    assert stats["hidden_rooms_found"] == 3, f"hidden_rooms_found should be 3, got {stats['hidden_rooms_found']}"
    assert stats["broken_walls"] == 2, f"broken_walls should be 2, got {stats['broken_walls']}"


# =============================================================================
# GET_SECRET_HINTS_IN_CHUNK TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_secret_hints_in_chunk_returns_array(game):
    """get_secret_hints_in_chunk should return an array."""
    await game.call(SECRET_PATH, "reset")
    result = await game.call(SECRET_PATH, "get_secret_hints_in_chunk", [{"x": 0, "y": 10}])
    assert result is not None, "get_secret_hints_in_chunk should return a value"
    assert isinstance(result, list), f"get_secret_hints_in_chunk should return array, got {type(result)}"


@pytest.mark.asyncio
async def test_get_secret_hints_in_chunk_empty_after_reset(game):
    """get_secret_hints_in_chunk should return empty array after reset."""
    await game.call(SECRET_PATH, "reset")
    result = await game.call(SECRET_PATH, "get_secret_hints_in_chunk", [{"x": 0, "y": 10}])
    assert len(result) == 0, f"Should return empty array after reset, got {len(result)} hints"
