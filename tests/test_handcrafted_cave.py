"""
HandcraftedCaveManager tests for GoDig endless digging game.

Tests verify that HandcraftedCaveManager:
1. Exists as an autoload singleton
2. Has proper signals for cave placement events
3. Has configuration constants
4. Has check/query methods for tiles
5. Has reset functionality
6. Get_stats returns expected data

Based on Spelunky's procedural generation approach with pre-designed
room templates and procedural placement.
"""
import pytest
from helpers import PATHS


# Path to handcrafted cave manager
HANDCRAFTED_PATH = PATHS.get("handcrafted_cave_manager", "/root/HandcraftedCaveManager")


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_handcrafted_cave_manager_exists(game):
    """HandcraftedCaveManager autoload should exist."""
    result = await game.node_exists(HANDCRAFTED_PATH)
    assert result.get("exists") is True, "HandcraftedCaveManager autoload should exist"


# =============================================================================
# SIGNAL TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_handcrafted_cave_placed_signal(game):
    """HandcraftedCaveManager should have handcrafted_cave_placed signal."""
    has_signal = await game.call(HANDCRAFTED_PATH, "has_signal", ["handcrafted_cave_placed"])
    assert has_signal is True, "HandcraftedCaveManager should have handcrafted_cave_placed signal"


@pytest.mark.asyncio
async def test_has_treasure_room_placed_signal(game):
    """HandcraftedCaveManager should have treasure_room_placed signal."""
    has_signal = await game.call(HANDCRAFTED_PATH, "has_signal", ["treasure_room_placed"])
    assert has_signal is True, "HandcraftedCaveManager should have treasure_room_placed signal"


@pytest.mark.asyncio
async def test_has_special_tile_generated_signal(game):
    """HandcraftedCaveManager should have special_tile_generated signal."""
    has_signal = await game.call(HANDCRAFTED_PATH, "has_signal", ["special_tile_generated"])
    assert has_signal is True, "HandcraftedCaveManager should have special_tile_generated signal"


# =============================================================================
# CONSTANT TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_handcrafted_chance_base_constant(game):
    """HANDCRAFTED_CHANCE_BASE should be configured."""
    result = await game.get_property(HANDCRAFTED_PATH, "HANDCRAFTED_CHANCE_BASE")
    assert result is not None, "HANDCRAFTED_CHANCE_BASE should exist"
    assert 0.0 < result < 1.0, f"HANDCRAFTED_CHANCE_BASE should be between 0 and 1, got {result}"


@pytest.mark.asyncio
async def test_handcrafted_max_chance_constant(game):
    """HANDCRAFTED_MAX_CHANCE should be configured."""
    result = await game.get_property(HANDCRAFTED_PATH, "HANDCRAFTED_MAX_CHANCE")
    assert result is not None, "HANDCRAFTED_MAX_CHANCE should exist"
    assert 0.0 < result < 1.0, f"HANDCRAFTED_MAX_CHANCE should be between 0 and 1, got {result}"


@pytest.mark.asyncio
async def test_min_handcrafted_distance_constant(game):
    """MIN_HANDCRAFTED_DISTANCE should be configured."""
    result = await game.get_property(HANDCRAFTED_PATH, "MIN_HANDCRAFTED_DISTANCE")
    assert result is not None, "MIN_HANDCRAFTED_DISTANCE should exist"
    assert result > 0, f"MIN_HANDCRAFTED_DISTANCE should be positive, got {result}"


@pytest.mark.asyncio
async def test_chunk_size_constant(game):
    """CHUNK_SIZE should be configured."""
    result = await game.get_property(HANDCRAFTED_PATH, "CHUNK_SIZE")
    assert result is not None, "CHUNK_SIZE should exist"
    assert result > 0, f"CHUNK_SIZE should be positive, got {result}"


# =============================================================================
# METHOD EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_check_handcrafted_placement_method(game):
    """HandcraftedCaveManager should have check_handcrafted_placement method."""
    result = await game.call(HANDCRAFTED_PATH, "has_method", ["check_handcrafted_placement"])
    assert result is True, "HandcraftedCaveManager should have check_handcrafted_placement method"


@pytest.mark.asyncio
async def test_has_generate_cave_from_template_method(game):
    """HandcraftedCaveManager should have generate_cave_from_template method."""
    result = await game.call(HANDCRAFTED_PATH, "has_method", ["generate_cave_from_template"])
    assert result is True, "HandcraftedCaveManager should have generate_cave_from_template method"


@pytest.mark.asyncio
async def test_has_is_handcrafted_tile_method(game):
    """HandcraftedCaveManager should have is_handcrafted_tile method."""
    result = await game.call(HANDCRAFTED_PATH, "has_method", ["is_handcrafted_tile"])
    assert result is True, "HandcraftedCaveManager should have is_handcrafted_tile method"


@pytest.mark.asyncio
async def test_has_get_handcrafted_tile_method(game):
    """HandcraftedCaveManager should have get_handcrafted_tile method."""
    result = await game.call(HANDCRAFTED_PATH, "has_method", ["get_handcrafted_tile"])
    assert result is True, "HandcraftedCaveManager should have get_handcrafted_tile method"


@pytest.mark.asyncio
async def test_has_should_be_empty_method(game):
    """HandcraftedCaveManager should have should_be_empty method."""
    result = await game.call(HANDCRAFTED_PATH, "has_method", ["should_be_empty"])
    assert result is True, "HandcraftedCaveManager should have should_be_empty method"


@pytest.mark.asyncio
async def test_has_should_be_weak_method(game):
    """HandcraftedCaveManager should have should_be_weak method."""
    result = await game.call(HANDCRAFTED_PATH, "has_method", ["should_be_weak"])
    assert result is True, "HandcraftedCaveManager should have should_be_weak method"


@pytest.mark.asyncio
async def test_has_should_be_secret_method(game):
    """HandcraftedCaveManager should have should_be_secret method."""
    result = await game.call(HANDCRAFTED_PATH, "has_method", ["should_be_secret"])
    assert result is True, "HandcraftedCaveManager should have should_be_secret method"


@pytest.mark.asyncio
async def test_has_should_spawn_ore_method(game):
    """HandcraftedCaveManager should have should_spawn_ore method."""
    result = await game.call(HANDCRAFTED_PATH, "has_method", ["should_spawn_ore"])
    assert result is True, "HandcraftedCaveManager should have should_spawn_ore method"


@pytest.mark.asyncio
async def test_has_should_spawn_treasure_method(game):
    """HandcraftedCaveManager should have should_spawn_treasure method."""
    result = await game.call(HANDCRAFTED_PATH, "has_method", ["should_spawn_treasure"])
    assert result is True, "HandcraftedCaveManager should have should_spawn_treasure method"


@pytest.mark.asyncio
async def test_has_should_spawn_ladder_method(game):
    """HandcraftedCaveManager should have should_spawn_ladder method."""
    result = await game.call(HANDCRAFTED_PATH, "has_method", ["should_spawn_ladder"])
    assert result is True, "HandcraftedCaveManager should have should_spawn_ladder method"


@pytest.mark.asyncio
async def test_has_should_spawn_enemy_method(game):
    """HandcraftedCaveManager should have should_spawn_enemy method."""
    result = await game.call(HANDCRAFTED_PATH, "has_method", ["should_spawn_enemy"])
    assert result is True, "HandcraftedCaveManager should have should_spawn_enemy method"


@pytest.mark.asyncio
async def test_has_is_platform_method(game):
    """HandcraftedCaveManager should have is_platform method."""
    result = await game.call(HANDCRAFTED_PATH, "has_method", ["is_platform"])
    assert result is True, "HandcraftedCaveManager should have is_platform method"


@pytest.mark.asyncio
async def test_has_unload_chunk_method(game):
    """HandcraftedCaveManager should have unload_chunk method."""
    result = await game.call(HANDCRAFTED_PATH, "has_method", ["unload_chunk"])
    assert result is True, "HandcraftedCaveManager should have unload_chunk method"


@pytest.mark.asyncio
async def test_has_reset_method(game):
    """HandcraftedCaveManager should have reset method."""
    result = await game.call(HANDCRAFTED_PATH, "has_method", ["reset"])
    assert result is True, "HandcraftedCaveManager should have reset method"


@pytest.mark.asyncio
async def test_has_get_stats_method(game):
    """HandcraftedCaveManager should have get_stats method."""
    result = await game.call(HANDCRAFTED_PATH, "has_method", ["get_stats"])
    assert result is True, "HandcraftedCaveManager should have get_stats method"


@pytest.mark.asyncio
async def test_has_get_save_data_method(game):
    """HandcraftedCaveManager should have get_save_data method."""
    result = await game.call(HANDCRAFTED_PATH, "has_method", ["get_save_data"])
    assert result is True, "HandcraftedCaveManager should have get_save_data method"


@pytest.mark.asyncio
async def test_has_load_save_data_method(game):
    """HandcraftedCaveManager should have load_save_data method."""
    result = await game.call(HANDCRAFTED_PATH, "has_method", ["load_save_data"])
    assert result is True, "HandcraftedCaveManager should have load_save_data method"


# =============================================================================
# GET_STATS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_stats_returns_dict(game):
    """get_stats should return a dictionary."""
    result = await game.call(HANDCRAFTED_PATH, "get_stats")
    assert result is not None, "get_stats should return a value"
    assert isinstance(result, dict), f"get_stats should return dict, got {type(result)}"


@pytest.mark.asyncio
async def test_get_stats_has_active_caves(game):
    """get_stats should include active_caves count."""
    result = await game.call(HANDCRAFTED_PATH, "get_stats")
    assert "active_caves" in result, "stats should have active_caves"
    assert isinstance(result["active_caves"], int), "active_caves should be int"


@pytest.mark.asyncio
async def test_get_stats_has_placed_positions(game):
    """get_stats should include placed_positions count."""
    result = await game.call(HANDCRAFTED_PATH, "get_stats")
    assert "placed_positions" in result, "stats should have placed_positions"
    assert isinstance(result["placed_positions"], int), "placed_positions should be int"


@pytest.mark.asyncio
async def test_get_stats_has_library_templates(game):
    """get_stats should include library_templates count."""
    result = await game.call(HANDCRAFTED_PATH, "get_stats")
    assert "library_templates" in result, "stats should have library_templates"
    assert isinstance(result["library_templates"], int), "library_templates should be int"


# =============================================================================
# RESET TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_reset_clears_active_caves(game):
    """reset should clear active_caves."""
    await game.call(HANDCRAFTED_PATH, "reset")
    stats = await game.call(HANDCRAFTED_PATH, "get_stats")
    assert stats["active_caves"] == 0, f"active_caves should be 0 after reset, got {stats['active_caves']}"


@pytest.mark.asyncio
async def test_reset_clears_placed_positions(game):
    """reset should clear placed_positions."""
    await game.call(HANDCRAFTED_PATH, "reset")
    stats = await game.call(HANDCRAFTED_PATH, "get_stats")
    assert stats["placed_positions"] == 0, f"placed_positions should be 0 after reset, got {stats['placed_positions']}"


# =============================================================================
# TILE QUERY TESTS (on positions without caves)
# =============================================================================

@pytest.mark.asyncio
async def test_is_handcrafted_tile_false_for_empty_position(game):
    """is_handcrafted_tile should return false for position without cave."""
    await game.call(HANDCRAFTED_PATH, "reset")
    result = await game.call(HANDCRAFTED_PATH, "is_handcrafted_tile", [{"x": 9999, "y": 9999}])
    assert result is False, "is_handcrafted_tile should be false for position without cave"


@pytest.mark.asyncio
async def test_get_handcrafted_tile_empty_for_position_without_cave(game):
    """get_handcrafted_tile should return empty string for position without cave."""
    await game.call(HANDCRAFTED_PATH, "reset")
    result = await game.call(HANDCRAFTED_PATH, "get_handcrafted_tile", [{"x": 9999, "y": 9999}])
    assert result == "", f"get_handcrafted_tile should return empty string, got '{result}'"


@pytest.mark.asyncio
async def test_should_be_empty_false_for_position_without_cave(game):
    """should_be_empty should return false for position without cave."""
    await game.call(HANDCRAFTED_PATH, "reset")
    result = await game.call(HANDCRAFTED_PATH, "should_be_empty", [{"x": 9999, "y": 9999}])
    assert result is False, "should_be_empty should be false for position without cave"


@pytest.mark.asyncio
async def test_should_be_weak_false_for_position_without_cave(game):
    """should_be_weak should return false for position without cave."""
    await game.call(HANDCRAFTED_PATH, "reset")
    result = await game.call(HANDCRAFTED_PATH, "should_be_weak", [{"x": 9999, "y": 9999}])
    assert result is False, "should_be_weak should be false for position without cave"


@pytest.mark.asyncio
async def test_should_spawn_ore_false_for_position_without_cave(game):
    """should_spawn_ore should return false for position without cave."""
    await game.call(HANDCRAFTED_PATH, "reset")
    result = await game.call(HANDCRAFTED_PATH, "should_spawn_ore", [{"x": 9999, "y": 9999}])
    assert result is False, "should_spawn_ore should be false for position without cave"


@pytest.mark.asyncio
async def test_should_spawn_treasure_false_for_position_without_cave(game):
    """should_spawn_treasure should return false for position without cave."""
    await game.call(HANDCRAFTED_PATH, "reset")
    result = await game.call(HANDCRAFTED_PATH, "should_spawn_treasure", [{"x": 9999, "y": 9999}])
    assert result is False, "should_spawn_treasure should be false for position without cave"


# =============================================================================
# CHECK_HANDCRAFTED_PLACEMENT TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_check_handcrafted_placement_returns_dict(game):
    """check_handcrafted_placement should return a dictionary."""
    result = await game.call(HANDCRAFTED_PATH, "check_handcrafted_placement", [{"x": 0, "y": 5}, 100, 12345])
    assert result is not None, "check_handcrafted_placement should return a value"
    assert isinstance(result, dict), f"check_handcrafted_placement should return dict, got {type(result)}"


@pytest.mark.asyncio
async def test_check_handcrafted_placement_has_should_place(game):
    """check_handcrafted_placement result should have should_place field."""
    result = await game.call(HANDCRAFTED_PATH, "check_handcrafted_placement", [{"x": 0, "y": 5}, 100, 12345])
    assert "should_place" in result, "Result should have should_place field"
    assert isinstance(result["should_place"], bool), "should_place should be boolean"


@pytest.mark.asyncio
async def test_check_handcrafted_placement_shallow_returns_no_place(game):
    """check_handcrafted_placement should not place at shallow depths (< 20)."""
    result = await game.call(HANDCRAFTED_PATH, "check_handcrafted_placement", [{"x": 0, "y": 0}, 10, 12345])
    assert result["should_place"] is False, "Should not place cave at depth < 20"


# =============================================================================
# SAVE/LOAD TESTS (caves regenerate deterministically)
# =============================================================================

@pytest.mark.asyncio
async def test_get_save_data_returns_dict(game):
    """get_save_data should return a dictionary."""
    result = await game.call(HANDCRAFTED_PATH, "get_save_data")
    assert result is not None, "get_save_data should return a value"
    assert isinstance(result, dict), f"get_save_data should return dict, got {type(result)}"


@pytest.mark.asyncio
async def test_load_save_data_completes(game):
    """load_save_data should complete without error."""
    result = await game.call(HANDCRAFTED_PATH, "load_save_data", [{}])
    # Caves regenerate deterministically, so this is mostly a no-op
    assert result is None or isinstance(result, (bool, dict)), "load_save_data should complete"
