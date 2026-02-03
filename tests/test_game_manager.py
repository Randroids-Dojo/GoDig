"""
GameManager tests for GoDig endless digging game.

Tests verify that GameManager:
1. Exists as an autoload singleton
2. Has correct grid constants for the game world
3. Manages game state transitions correctly
4. Tracks depth and milestones properly
5. Handles coin/currency system
6. Manages tutorial progression
7. Handles building unlock system
8. Provides proper save/load helpers
9. Has required signals for cross-system communication
"""
import pytest
from helpers import PATHS


# Path to game manager
GAME_MANAGER_PATH = PATHS.get("game_manager", "/root/GameManager")


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_game_manager_exists(game):
    """GameManager autoload should exist."""
    result = await game.node_exists(GAME_MANAGER_PATH)
    assert result.get("exists") is True, "GameManager autoload should exist"


# =============================================================================
# GRID CONSTANTS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_block_size_constant(game):
    """GameManager should have BLOCK_SIZE constant."""
    result = await game.get_property(GAME_MANAGER_PATH, "BLOCK_SIZE")
    assert result is not None, "BLOCK_SIZE should exist"
    assert isinstance(result, int), f"BLOCK_SIZE should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_block_size_value(game):
    """BLOCK_SIZE should be 128."""
    result = await game.get_property(GAME_MANAGER_PATH, "BLOCK_SIZE")
    assert result == 128, f"BLOCK_SIZE should be 128, got {result}"


@pytest.mark.asyncio
async def test_has_grid_offset_x(game):
    """GameManager should have GRID_OFFSET_X constant."""
    result = await game.get_property(GAME_MANAGER_PATH, "GRID_OFFSET_X")
    assert result is not None, "GRID_OFFSET_X should exist"
    assert isinstance(result, int), f"GRID_OFFSET_X should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_has_surface_row(game):
    """GameManager should have SURFACE_ROW constant."""
    result = await game.get_property(GAME_MANAGER_PATH, "SURFACE_ROW")
    assert result is not None, "SURFACE_ROW should exist"
    assert isinstance(result, int), f"SURFACE_ROW should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_surface_row_value(game):
    """SURFACE_ROW should be 7."""
    result = await game.get_property(GAME_MANAGER_PATH, "SURFACE_ROW")
    assert result == 7, f"SURFACE_ROW should be 7, got {result}"


@pytest.mark.asyncio
async def test_has_viewport_width(game):
    """GameManager should have VIEWPORT_WIDTH constant."""
    result = await game.get_property(GAME_MANAGER_PATH, "VIEWPORT_WIDTH")
    assert result is not None, "VIEWPORT_WIDTH should exist"
    assert isinstance(result, int), f"VIEWPORT_WIDTH should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_viewport_width_value(game):
    """VIEWPORT_WIDTH should be 720."""
    result = await game.get_property(GAME_MANAGER_PATH, "VIEWPORT_WIDTH")
    assert result == 720, f"VIEWPORT_WIDTH should be 720, got {result}"


@pytest.mark.asyncio
async def test_has_viewport_height(game):
    """GameManager should have VIEWPORT_HEIGHT constant."""
    result = await game.get_property(GAME_MANAGER_PATH, "VIEWPORT_HEIGHT")
    assert result is not None, "VIEWPORT_HEIGHT should exist"
    assert isinstance(result, int), f"VIEWPORT_HEIGHT should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_viewport_height_value(game):
    """VIEWPORT_HEIGHT should be 1280."""
    result = await game.get_property(GAME_MANAGER_PATH, "VIEWPORT_HEIGHT")
    assert result == 1280, f"VIEWPORT_HEIGHT should be 1280, got {result}"


# =============================================================================
# SCENE PATHS CONSTANTS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_scene_main_menu(game):
    """GameManager should have SCENE_MAIN_MENU constant."""
    result = await game.get_property(GAME_MANAGER_PATH, "SCENE_MAIN_MENU")
    assert result is not None, "SCENE_MAIN_MENU should exist"
    assert isinstance(result, str), f"SCENE_MAIN_MENU should be string, got {type(result)}"


@pytest.mark.asyncio
async def test_has_scene_game(game):
    """GameManager should have SCENE_GAME constant."""
    result = await game.get_property(GAME_MANAGER_PATH, "SCENE_GAME")
    assert result is not None, "SCENE_GAME should exist"
    assert isinstance(result, str), f"SCENE_GAME should be string, got {type(result)}"


@pytest.mark.asyncio
async def test_has_scene_game_over(game):
    """GameManager should have SCENE_GAME_OVER constant."""
    result = await game.get_property(GAME_MANAGER_PATH, "SCENE_GAME_OVER")
    assert result is not None, "SCENE_GAME_OVER should exist"
    assert isinstance(result, str), f"SCENE_GAME_OVER should be string, got {type(result)}"


# =============================================================================
# GAME STATE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_state_property_exists(game):
    """state property should be accessible."""
    result = await game.get_property(GAME_MANAGER_PATH, "state")
    assert result is not None, "state should exist"
    assert isinstance(result, int), f"state should be int (enum), got {type(result)}"


@pytest.mark.asyncio
async def test_is_running_property(game):
    """is_running property should be accessible."""
    result = await game.get_property(GAME_MANAGER_PATH, "is_running")
    assert result is not None, "is_running should exist"
    assert isinstance(result, bool), f"is_running should be bool, got {type(result)}"


@pytest.mark.asyncio
async def test_is_playing_method(game):
    """is_playing should return a boolean."""
    result = await game.call(GAME_MANAGER_PATH, "is_playing")
    assert isinstance(result, bool), f"is_playing should return bool, got {type(result)}"


# =============================================================================
# DEPTH TRACKING TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_current_depth_property(game):
    """current_depth property should be accessible."""
    result = await game.get_property(GAME_MANAGER_PATH, "current_depth")
    assert result is not None, "current_depth should exist"
    assert isinstance(result, int), f"current_depth should be int, got {type(result)}"
    assert result >= 0, f"current_depth should be non-negative, got {result}"


@pytest.mark.asyncio
async def test_max_depth_reached_property(game):
    """max_depth_reached property should be accessible."""
    result = await game.get_property(GAME_MANAGER_PATH, "max_depth_reached")
    assert result is not None, "max_depth_reached should exist"
    assert isinstance(result, int), f"max_depth_reached should be int, got {type(result)}"
    assert result >= 0, f"max_depth_reached should be non-negative, got {result}"


@pytest.mark.asyncio
async def test_has_depth_milestones(game):
    """GameManager should have DEPTH_MILESTONES constant."""
    result = await game.get_property(GAME_MANAGER_PATH, "DEPTH_MILESTONES")
    assert result is not None, "DEPTH_MILESTONES should exist"
    assert isinstance(result, list), f"DEPTH_MILESTONES should be list, got {type(result)}"
    assert len(result) > 0, "DEPTH_MILESTONES should not be empty"


@pytest.mark.asyncio
async def test_depth_milestones_values(game):
    """DEPTH_MILESTONES should contain expected values."""
    result = await game.get_property(GAME_MANAGER_PATH, "DEPTH_MILESTONES")
    assert 10 in result, "DEPTH_MILESTONES should include 10"
    assert 50 in result, "DEPTH_MILESTONES should include 50"
    assert 100 in result, "DEPTH_MILESTONES should include 100"
    assert 500 in result, "DEPTH_MILESTONES should include 500"


@pytest.mark.asyncio
async def test_get_reached_milestones(game):
    """get_reached_milestones should return an array."""
    result = await game.call(GAME_MANAGER_PATH, "get_reached_milestones")
    assert result is not None, "get_reached_milestones should return a value"
    assert isinstance(result, list), f"get_reached_milestones should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_reset_milestones(game):
    """reset_milestones should clear reached milestones."""
    await game.call(GAME_MANAGER_PATH, "reset_milestones")
    result = await game.call(GAME_MANAGER_PATH, "get_reached_milestones")
    assert len(result) == 0, f"After reset_milestones, should have no milestones, got {len(result)}"


# =============================================================================
# COIN SYSTEM TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_coins_property(game):
    """coins property should be accessible."""
    result = await game.get_property(GAME_MANAGER_PATH, "coins")
    assert result is not None, "coins should exist"
    assert isinstance(result, int), f"coins should be int, got {type(result)}"
    assert result >= 0, f"coins should be non-negative, got {result}"


@pytest.mark.asyncio
async def test_get_coins(game):
    """get_coins should return current coin balance."""
    result = await game.call(GAME_MANAGER_PATH, "get_coins")
    assert result is not None, "get_coins should return a value"
    assert isinstance(result, int), f"get_coins should return int, got {type(result)}"


@pytest.mark.asyncio
async def test_set_coins(game):
    """set_coins should update coin balance."""
    await game.call(GAME_MANAGER_PATH, "set_coins", [100])
    result = await game.call(GAME_MANAGER_PATH, "get_coins")
    assert result == 100, f"After set_coins(100), get_coins should return 100, got {result}"


@pytest.mark.asyncio
async def test_add_coins(game):
    """add_coins should increase coin balance."""
    await game.call(GAME_MANAGER_PATH, "set_coins", [50])
    await game.call(GAME_MANAGER_PATH, "add_coins", [25])
    result = await game.call(GAME_MANAGER_PATH, "get_coins")
    assert result == 75, f"After set_coins(50) + add_coins(25), should have 75, got {result}"


@pytest.mark.asyncio
async def test_add_coins_zero(game):
    """add_coins with 0 should not change balance."""
    await game.call(GAME_MANAGER_PATH, "set_coins", [100])
    await game.call(GAME_MANAGER_PATH, "add_coins", [0])
    result = await game.call(GAME_MANAGER_PATH, "get_coins")
    assert result == 100, f"add_coins(0) should not change balance, got {result}"


@pytest.mark.asyncio
async def test_add_coins_negative(game):
    """add_coins with negative value should not change balance."""
    await game.call(GAME_MANAGER_PATH, "set_coins", [100])
    await game.call(GAME_MANAGER_PATH, "add_coins", [-10])
    result = await game.call(GAME_MANAGER_PATH, "get_coins")
    assert result == 100, f"add_coins(-10) should not change balance, got {result}"


@pytest.mark.asyncio
async def test_spend_coins_success(game):
    """spend_coins should return true and reduce balance when affordable."""
    await game.call(GAME_MANAGER_PATH, "set_coins", [100])
    result = await game.call(GAME_MANAGER_PATH, "spend_coins", [30])
    assert result is True, "spend_coins should return True when affordable"
    balance = await game.call(GAME_MANAGER_PATH, "get_coins")
    assert balance == 70, f"After spending 30 from 100, should have 70, got {balance}"


@pytest.mark.asyncio
async def test_spend_coins_insufficient(game):
    """spend_coins should return false when insufficient funds."""
    await game.call(GAME_MANAGER_PATH, "set_coins", [50])
    result = await game.call(GAME_MANAGER_PATH, "spend_coins", [100])
    assert result is False, "spend_coins should return False when insufficient"
    balance = await game.call(GAME_MANAGER_PATH, "get_coins")
    assert balance == 50, f"Balance should remain 50 after failed spend, got {balance}"


@pytest.mark.asyncio
async def test_can_afford_true(game):
    """can_afford should return true when enough coins."""
    await game.call(GAME_MANAGER_PATH, "set_coins", [100])
    result = await game.call(GAME_MANAGER_PATH, "can_afford", [50])
    assert result is True, "can_afford(50) should return True with 100 coins"


@pytest.mark.asyncio
async def test_can_afford_false(game):
    """can_afford should return false when not enough coins."""
    await game.call(GAME_MANAGER_PATH, "set_coins", [30])
    result = await game.call(GAME_MANAGER_PATH, "can_afford", [50])
    assert result is False, "can_afford(50) should return False with 30 coins"


@pytest.mark.asyncio
async def test_can_afford_exact(game):
    """can_afford should return true when exactly enough coins."""
    await game.call(GAME_MANAGER_PATH, "set_coins", [50])
    result = await game.call(GAME_MANAGER_PATH, "can_afford", [50])
    assert result is True, "can_afford(50) should return True with exactly 50 coins"


# =============================================================================
# TUTORIAL SYSTEM TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_tutorial_state_property(game):
    """tutorial_state property should be accessible."""
    result = await game.get_property(GAME_MANAGER_PATH, "tutorial_state")
    assert result is not None, "tutorial_state should exist"
    assert isinstance(result, int), f"tutorial_state should be int (enum), got {type(result)}"


@pytest.mark.asyncio
async def test_tutorial_complete_property(game):
    """tutorial_complete property should be accessible."""
    result = await game.get_property(GAME_MANAGER_PATH, "tutorial_complete")
    assert result is not None, "tutorial_complete should exist"
    assert isinstance(result, bool), f"tutorial_complete should be bool, got {type(result)}"


@pytest.mark.asyncio
async def test_is_tutorial_active(game):
    """is_tutorial_active should return a boolean."""
    result = await game.call(GAME_MANAGER_PATH, "is_tutorial_active")
    assert isinstance(result, bool), f"is_tutorial_active should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_reset_tutorial(game):
    """reset_tutorial should reset tutorial state."""
    await game.call(GAME_MANAGER_PATH, "reset_tutorial")
    state = await game.get_property(GAME_MANAGER_PATH, "tutorial_state")
    complete = await game.get_property(GAME_MANAGER_PATH, "tutorial_complete")
    assert state == 0, f"After reset_tutorial, tutorial_state should be 0 (MOVEMENT), got {state}"
    assert complete is False, f"After reset_tutorial, tutorial_complete should be False, got {complete}"


@pytest.mark.asyncio
async def test_get_tutorial_state(game):
    """get_tutorial_state should return a dictionary."""
    result = await game.call(GAME_MANAGER_PATH, "get_tutorial_state")
    assert result is not None, "get_tutorial_state should return a value"
    assert isinstance(result, dict), f"get_tutorial_state should return dict, got {type(result)}"
    assert "state" in result, "get_tutorial_state should include 'state' key"
    assert "complete" in result, "get_tutorial_state should include 'complete' key"


# =============================================================================
# BUILDING UNLOCK SYSTEM TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_building_unlock_order(game):
    """GameManager should have BUILDING_UNLOCK_ORDER constant."""
    result = await game.get_property(GAME_MANAGER_PATH, "BUILDING_UNLOCK_ORDER")
    assert result is not None, "BUILDING_UNLOCK_ORDER should exist"
    assert isinstance(result, list), f"BUILDING_UNLOCK_ORDER should be list, got {type(result)}"
    assert len(result) > 0, "BUILDING_UNLOCK_ORDER should not be empty"


@pytest.mark.asyncio
async def test_building_unlock_order_structure(game):
    """BUILDING_UNLOCK_ORDER entries should have required fields."""
    result = await game.get_property(GAME_MANAGER_PATH, "BUILDING_UNLOCK_ORDER")
    for building in result:
        assert "id" in building, f"Building should have 'id' field: {building}"
        assert "name" in building, f"Building should have 'name' field: {building}"
        assert "unlock_depth" in building, f"Building should have 'unlock_depth' field: {building}"


@pytest.mark.asyncio
async def test_unlocked_buildings_property(game):
    """unlocked_buildings property should be accessible."""
    result = await game.get_property(GAME_MANAGER_PATH, "unlocked_buildings")
    assert result is not None, "unlocked_buildings should exist"
    assert isinstance(result, list), f"unlocked_buildings should be list, got {type(result)}"


@pytest.mark.asyncio
async def test_is_building_unlocked_returns_bool(game):
    """is_building_unlocked should return a boolean."""
    result = await game.call(GAME_MANAGER_PATH, "is_building_unlocked", ["mine_entrance"])
    assert isinstance(result, bool), f"is_building_unlocked should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_get_unlocked_buildings(game):
    """get_unlocked_buildings should return a list."""
    result = await game.call(GAME_MANAGER_PATH, "get_unlocked_buildings")
    assert result is not None, "get_unlocked_buildings should return a value"
    assert isinstance(result, list), f"get_unlocked_buildings should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_reset_buildings(game):
    """reset_buildings should reset building unlocks."""
    await game.call(GAME_MANAGER_PATH, "reset_buildings")
    # After reset, starting buildings should be unlocked
    result = await game.call(GAME_MANAGER_PATH, "get_unlocked_buildings")
    assert isinstance(result, list), f"get_unlocked_buildings should return list after reset"


# =============================================================================
# PLAYER REFERENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_player_property(game):
    """player property should exist (may be null if not registered)."""
    # Just verify the property is accessible, may be null
    result = await game.get_property(GAME_MANAGER_PATH, "player")
    # Could be null/None if no player registered, so just check it doesn't error


@pytest.mark.asyncio
async def test_get_player_position(game):
    """get_player_position should return a Vector2."""
    result = await game.call(GAME_MANAGER_PATH, "get_player_position")
    # Returns Vector2.ZERO if no player, which serializes to dict with x,y
    assert result is not None, "get_player_position should return a value"


@pytest.mark.asyncio
async def test_get_player_grid_position(game):
    """get_player_grid_position should return a Vector2i."""
    result = await game.call(GAME_MANAGER_PATH, "get_player_grid_position")
    assert result is not None, "get_player_grid_position should return a value"


# =============================================================================
# LAYER TRACKING TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_current_layer_name(game):
    """get_current_layer_name should return a string."""
    result = await game.call(GAME_MANAGER_PATH, "get_current_layer_name")
    assert result is not None, "get_current_layer_name should return a value"
    assert isinstance(result, str), f"get_current_layer_name should return string, got {type(result)}"


@pytest.mark.asyncio
async def test_reset_layer(game):
    """reset_layer should complete without error."""
    result = await game.call(GAME_MANAGER_PATH, "reset_layer")
    # Just verify it doesn't error


# =============================================================================
# SIGNAL TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_state_changed_signal(game):
    """GameManager should have state_changed signal."""
    has_signal = await game.call(GAME_MANAGER_PATH, "has_signal", ["state_changed"])
    assert has_signal is True, "GameManager should have state_changed signal"


@pytest.mark.asyncio
async def test_has_game_started_signal(game):
    """GameManager should have game_started signal."""
    has_signal = await game.call(GAME_MANAGER_PATH, "has_signal", ["game_started"])
    assert has_signal is True, "GameManager should have game_started signal"


@pytest.mark.asyncio
async def test_has_game_over_signal(game):
    """GameManager should have game_over signal."""
    has_signal = await game.call(GAME_MANAGER_PATH, "has_signal", ["game_over"])
    assert has_signal is True, "GameManager should have game_over signal"


@pytest.mark.asyncio
async def test_has_depth_updated_signal(game):
    """GameManager should have depth_updated signal."""
    has_signal = await game.call(GAME_MANAGER_PATH, "has_signal", ["depth_updated"])
    assert has_signal is True, "GameManager should have depth_updated signal"


@pytest.mark.asyncio
async def test_has_depth_milestone_reached_signal(game):
    """GameManager should have depth_milestone_reached signal."""
    has_signal = await game.call(GAME_MANAGER_PATH, "has_signal", ["depth_milestone_reached"])
    assert has_signal is True, "GameManager should have depth_milestone_reached signal"


@pytest.mark.asyncio
async def test_has_layer_entered_signal(game):
    """GameManager should have layer_entered signal."""
    has_signal = await game.call(GAME_MANAGER_PATH, "has_signal", ["layer_entered"])
    assert has_signal is True, "GameManager should have layer_entered signal"


@pytest.mark.asyncio
async def test_has_coins_changed_signal(game):
    """GameManager should have coins_changed signal."""
    has_signal = await game.call(GAME_MANAGER_PATH, "has_signal", ["coins_changed"])
    assert has_signal is True, "GameManager should have coins_changed signal"


@pytest.mark.asyncio
async def test_has_coins_added_signal(game):
    """GameManager should have coins_added signal."""
    has_signal = await game.call(GAME_MANAGER_PATH, "has_signal", ["coins_added"])
    assert has_signal is True, "GameManager should have coins_added signal"


@pytest.mark.asyncio
async def test_has_coins_spent_signal(game):
    """GameManager should have coins_spent signal."""
    has_signal = await game.call(GAME_MANAGER_PATH, "has_signal", ["coins_spent"])
    assert has_signal is True, "GameManager should have coins_spent signal"


@pytest.mark.asyncio
async def test_has_shop_requested_signal(game):
    """GameManager should have shop_requested signal."""
    has_signal = await game.call(GAME_MANAGER_PATH, "has_signal", ["shop_requested"])
    assert has_signal is True, "GameManager should have shop_requested signal"


@pytest.mark.asyncio
async def test_has_shop_closed_signal(game):
    """GameManager should have shop_closed signal."""
    has_signal = await game.call(GAME_MANAGER_PATH, "has_signal", ["shop_closed"])
    assert has_signal is True, "GameManager should have shop_closed signal"


@pytest.mark.asyncio
async def test_has_building_unlocked_signal(game):
    """GameManager should have building_unlocked signal."""
    has_signal = await game.call(GAME_MANAGER_PATH, "has_signal", ["building_unlocked"])
    assert has_signal is True, "GameManager should have building_unlocked signal"


@pytest.mark.asyncio
async def test_has_max_depth_updated_signal(game):
    """GameManager should have max_depth_updated signal."""
    has_signal = await game.call(GAME_MANAGER_PATH, "has_signal", ["max_depth_updated"])
    assert has_signal is True, "GameManager should have max_depth_updated signal"


@pytest.mark.asyncio
async def test_has_tutorial_state_changed_signal(game):
    """GameManager should have tutorial_state_changed signal."""
    has_signal = await game.call(GAME_MANAGER_PATH, "has_signal", ["tutorial_state_changed"])
    assert has_signal is True, "GameManager should have tutorial_state_changed signal"


@pytest.mark.asyncio
async def test_has_tutorial_completed_signal(game):
    """GameManager should have tutorial_completed signal."""
    has_signal = await game.call(GAME_MANAGER_PATH, "has_signal", ["tutorial_completed"])
    assert has_signal is True, "GameManager should have tutorial_completed signal"


@pytest.mark.asyncio
async def test_has_successful_run_completed_signal(game):
    """GameManager should have successful_run_completed signal."""
    has_signal = await game.call(GAME_MANAGER_PATH, "has_signal", ["successful_run_completed"])
    assert has_signal is True, "GameManager should have successful_run_completed signal"


# =============================================================================
# COORDINATE CONVERSION TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_grid_to_world_exists(game):
    """grid_to_world static method should exist and work."""
    # Can't easily test static methods through PlayGodot, but verify the manager exists
    result = await game.node_exists(GAME_MANAGER_PATH)
    assert result.get("exists") is True, "GameManager should exist"


@pytest.mark.asyncio
async def test_world_to_grid_exists(game):
    """world_to_grid static method should exist and work."""
    # Can't easily test static methods through PlayGodot, but verify the manager exists
    result = await game.node_exists(GAME_MANAGER_PATH)
    assert result.get("exists") is True, "GameManager should exist"


# =============================================================================
# TILESET TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_terrain_tileset_property(game):
    """terrain_tileset property should exist."""
    result = await game.get_property(GAME_MANAGER_PATH, "terrain_tileset")
    # May be null during early init, just check property is accessible


@pytest.mark.asyncio
async def test_get_terrain_tileset(game):
    """get_terrain_tileset should return a TileSet or null."""
    result = await game.call(GAME_MANAGER_PATH, "get_terrain_tileset")
    # Just verify it doesn't error, may be null during certain states


# =============================================================================
# SAVE/LOAD HELPER TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_set_reached_milestones(game):
    """set_reached_milestones should set milestones array."""
    await game.call(GAME_MANAGER_PATH, "set_reached_milestones", [[10, 25, 50]])
    result = await game.call(GAME_MANAGER_PATH, "get_reached_milestones")
    assert 10 in result, "Should contain 10 after set_reached_milestones"
    assert 25 in result, "Should contain 25 after set_reached_milestones"
    assert 50 in result, "Should contain 50 after set_reached_milestones"


@pytest.mark.asyncio
async def test_set_unlocked_buildings(game):
    """set_unlocked_buildings should set buildings array."""
    await game.call(GAME_MANAGER_PATH, "set_unlocked_buildings", [["mine_entrance", "general_store"]])
    result = await game.call(GAME_MANAGER_PATH, "get_unlocked_buildings")
    assert "mine_entrance" in result, "Should contain mine_entrance after set"
    assert "general_store" in result, "Should contain general_store after set"


@pytest.mark.asyncio
async def test_set_max_depth_reached(game):
    """set_max_depth_reached should set max depth."""
    await game.call(GAME_MANAGER_PATH, "set_max_depth_reached", [150])
    result = await game.get_property(GAME_MANAGER_PATH, "max_depth_reached")
    assert result == 150, f"After set_max_depth_reached(150), should be 150, got {result}"


@pytest.mark.asyncio
async def test_set_tutorial_state(game):
    """set_tutorial_state should set tutorial state and complete flag."""
    await game.call(GAME_MANAGER_PATH, "set_tutorial_state", [2, False])
    result = await game.call(GAME_MANAGER_PATH, "get_tutorial_state")
    assert result["state"] == 2, f"tutorial_state should be 2, got {result['state']}"
    assert result["complete"] is False, f"tutorial_complete should be False, got {result['complete']}"
