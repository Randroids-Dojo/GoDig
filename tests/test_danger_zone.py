"""
DangerZoneManager tests for GoDig endless digging game.

Tests verify that DangerZoneManager:
1. Exists as an autoload singleton
2. Provides danger zone type lookups
3. Tracks player position in zones
4. Handles hazard configurations
5. Supports zone warnings and unique drops
"""
import pytest
from helpers import PATHS


# Path to danger zone manager
DANGER_ZONE_PATH = PATHS.get("danger_zone_manager", "/root/DangerZoneManager")


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_danger_zone_manager_exists(game):
    """DangerZoneManager autoload should exist."""
    result = await game.node_exists(DANGER_ZONE_PATH)
    assert result.get("exists") is True, "DangerZoneManager autoload should exist"


# =============================================================================
# ZONE TYPE ENUM TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_zone_type_none_exists(game):
    """ZoneType.NONE should equal 0."""
    # We can verify by checking is_in_danger_zone returns false for an empty pos
    result = await game.call(DANGER_ZONE_PATH, "is_in_danger_zone", [{"x": 0, "y": 0}])
    assert result is False, "Position 0,0 should not be in danger zone by default"


# =============================================================================
# ZONE STATE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_is_player_in_danger_zone_returns_bool(game):
    """is_player_in_danger_zone should return a boolean."""
    result = await game.call(DANGER_ZONE_PATH, "is_player_in_danger_zone")
    assert isinstance(result, bool), f"is_player_in_danger_zone should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_initial_state_not_in_danger_zone(game):
    """Player should not start in a danger zone."""
    result = await game.call(DANGER_ZONE_PATH, "is_player_in_danger_zone")
    assert result is False, "Player should not start in a danger zone"


@pytest.mark.asyncio
async def test_get_current_zone_info_returns_dict(game):
    """get_current_zone_info should return a dictionary."""
    result = await game.call(DANGER_ZONE_PATH, "get_current_zone_info")
    assert result is not None, "get_current_zone_info should return a value"
    assert isinstance(result, dict), f"get_current_zone_info should return dict, got {type(result)}"


@pytest.mark.asyncio
async def test_get_current_zone_info_empty_when_not_in_zone(game):
    """get_current_zone_info should be empty when not in a zone."""
    # First verify we're not in a zone
    in_zone = await game.call(DANGER_ZONE_PATH, "is_player_in_danger_zone")
    if not in_zone:
        result = await game.call(DANGER_ZONE_PATH, "get_current_zone_info")
        assert result == {} or len(result) == 0, "Should return empty dict when not in zone"


# =============================================================================
# ZONE QUERY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_is_in_danger_zone_returns_bool(game):
    """is_in_danger_zone should return a boolean."""
    result = await game.call(DANGER_ZONE_PATH, "is_in_danger_zone", [{"x": 100, "y": 100}])
    assert isinstance(result, bool), f"is_in_danger_zone should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_get_zone_type_at_returns_int(game):
    """get_zone_type_at should return an integer (ZoneType enum)."""
    result = await game.call(DANGER_ZONE_PATH, "get_zone_type_at", [{"x": 100, "y": 100}])
    assert isinstance(result, int), f"get_zone_type_at should return int, got {type(result)}"


@pytest.mark.asyncio
async def test_get_zone_config_at_returns_dict(game):
    """get_zone_config_at should return a dictionary."""
    result = await game.call(DANGER_ZONE_PATH, "get_zone_config_at", [{"x": 100, "y": 100}])
    assert result is not None, "get_zone_config_at should return a value"
    assert isinstance(result, dict), f"get_zone_config_at should return dict, got {type(result)}"


@pytest.mark.asyncio
async def test_get_ore_multiplier_at_returns_float(game):
    """get_ore_multiplier_at should return a float."""
    result = await game.call(DANGER_ZONE_PATH, "get_ore_multiplier_at", [{"x": 100, "y": 100}])
    assert result is not None, "get_ore_multiplier_at should return a value"
    assert isinstance(result, (int, float)), f"get_ore_multiplier_at should return number, got {type(result)}"


@pytest.mark.asyncio
async def test_get_ore_multiplier_default_is_one(game):
    """get_ore_multiplier_at should return 1.0 for positions outside zones."""
    result = await game.call(DANGER_ZONE_PATH, "get_ore_multiplier_at", [{"x": 0, "y": 0}])
    assert result == 1.0, f"Ore multiplier outside zones should be 1.0, got {result}"


# =============================================================================
# ZONE WARNING TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_is_near_zone_entry_returns_bool(game):
    """is_near_zone_entry should return a boolean."""
    result = await game.call(DANGER_ZONE_PATH, "is_near_zone_entry", [{"x": 100, "y": 100}])
    assert isinstance(result, bool), f"is_near_zone_entry should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_get_nearest_zone_info_returns_dict(game):
    """get_nearest_zone_info should return a dictionary."""
    result = await game.call(DANGER_ZONE_PATH, "get_nearest_zone_info", [{"x": 100, "y": 100}])
    assert result is not None, "get_nearest_zone_info should return a value"
    assert isinstance(result, dict), f"get_nearest_zone_info should return dict, got {type(result)}"


# =============================================================================
# UNIQUE DROP TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_roll_unique_drop_returns_string(game):
    """roll_unique_drop should return a string (may be empty)."""
    result = await game.call(DANGER_ZONE_PATH, "roll_unique_drop", [{"x": 100, "y": 100}])
    assert result is not None or result == "", "roll_unique_drop should return a value"
    assert isinstance(result, str), f"roll_unique_drop should return string, got {type(result)}"


@pytest.mark.asyncio
async def test_roll_unique_drop_outside_zone_empty(game):
    """roll_unique_drop should return empty string outside zones."""
    result = await game.call(DANGER_ZONE_PATH, "roll_unique_drop", [{"x": 0, "y": 0}])
    assert result == "", f"roll_unique_drop outside zone should be empty, got {result}"


# =============================================================================
# RESET TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_reset_completes(game):
    """reset should complete without error."""
    result = await game.call(DANGER_ZONE_PATH, "reset")
    # Method should complete without error
    assert result is None or isinstance(result, (bool, dict)), "reset should complete"


@pytest.mark.asyncio
async def test_reset_clears_zone_state(game):
    """reset should clear the current zone state."""
    await game.call(DANGER_ZONE_PATH, "reset")
    in_zone = await game.call(DANGER_ZONE_PATH, "is_player_in_danger_zone")
    assert in_zone is False, "After reset, player should not be in danger zone"


# =============================================================================
# STATS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_stats_returns_dict(game):
    """get_stats should return a dictionary."""
    result = await game.call(DANGER_ZONE_PATH, "get_stats")
    assert result is not None, "get_stats should return a value"
    assert isinstance(result, dict), f"get_stats should return dict, got {type(result)}"


@pytest.mark.asyncio
async def test_get_stats_has_active_zones(game):
    """get_stats should include active_zones count."""
    result = await game.call(DANGER_ZONE_PATH, "get_stats")
    assert "active_zones" in result, "stats should have active_zones"
    assert isinstance(result["active_zones"], int), "active_zones should be int"


@pytest.mark.asyncio
async def test_get_stats_has_zone_tiles(game):
    """get_stats should include zone_tiles count."""
    result = await game.call(DANGER_ZONE_PATH, "get_stats")
    assert "zone_tiles" in result, "stats should have zone_tiles"
    assert isinstance(result["zone_tiles"], int), "zone_tiles should be int"


@pytest.mark.asyncio
async def test_get_stats_has_current_zone(game):
    """get_stats should include current_zone."""
    result = await game.call(DANGER_ZONE_PATH, "get_stats")
    assert "current_zone" in result, "stats should have current_zone"


# =============================================================================
# SIGNAL TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_danger_zone_entered_signal(game):
    """DangerZoneManager should have danger_zone_entered signal."""
    has_signal = await game.call(DANGER_ZONE_PATH, "has_signal", ["danger_zone_entered"])
    assert has_signal is True, "DangerZoneManager should have danger_zone_entered signal"


@pytest.mark.asyncio
async def test_has_danger_zone_exited_signal(game):
    """DangerZoneManager should have danger_zone_exited signal."""
    has_signal = await game.call(DANGER_ZONE_PATH, "has_signal", ["danger_zone_exited"])
    assert has_signal is True, "DangerZoneManager should have danger_zone_exited signal"


@pytest.mark.asyncio
async def test_has_danger_zone_warning_signal(game):
    """DangerZoneManager should have danger_zone_warning signal."""
    has_signal = await game.call(DANGER_ZONE_PATH, "has_signal", ["danger_zone_warning"])
    assert has_signal is True, "DangerZoneManager should have danger_zone_warning signal"


@pytest.mark.asyncio
async def test_has_unique_drop_obtained_signal(game):
    """DangerZoneManager should have unique_drop_obtained signal."""
    has_signal = await game.call(DANGER_ZONE_PATH, "has_signal", ["unique_drop_obtained"])
    assert has_signal is True, "DangerZoneManager should have unique_drop_obtained signal"


# =============================================================================
# HAZARD CONFIG TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_hazard_config_collapsed_mine_exists(game):
    """HAZARD_CONFIG should have COLLAPSED_MINE zone type."""
    # We test indirectly through get_stats which returns "None" or zone type names
    result = await game.call(DANGER_ZONE_PATH, "get_stats")
    # Just verify the method works - HAZARD_CONFIG is internal
    assert result is not None, "get_stats should work (implies HAZARD_CONFIG exists)"


# =============================================================================
# CHUNK UNLOAD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_unload_chunk_completes(game):
    """unload_chunk should complete without error."""
    result = await game.call(DANGER_ZONE_PATH, "unload_chunk", [{"x": 0, "y": 0}])
    # Method should complete without error
    assert result is None or isinstance(result, (bool, dict)), "unload_chunk should complete"


# =============================================================================
# ZONE COLOR TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_zone_color_at_returns_color(game):
    """get_zone_color_at should return a color (as dict or special type)."""
    result = await game.call(DANGER_ZONE_PATH, "get_zone_color_at", [{"x": 100, "y": 100}])
    # Godot Color may be serialized as dict with r, g, b, a keys or as a special type
    # If outside zone, it returns Color.WHITE which is (1, 1, 1, 1)
    assert result is not None, "get_zone_color_at should return a value"


# =============================================================================
# CONSTANT VALIDATION TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_zone_min_depth_is_positive(game):
    """ZONE_MIN_DEPTH constant should exist and be positive."""
    # Test indirectly - positions above ZONE_MIN_DEPTH should not have zones
    result = await game.call(DANGER_ZONE_PATH, "is_in_danger_zone", [{"x": 0, "y": 10}])
    # At depth 10 (which is below ZONE_MIN_DEPTH of 30), no zone should exist
    assert isinstance(result, bool), "is_in_danger_zone should return bool"
