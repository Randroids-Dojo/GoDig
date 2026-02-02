"""
Tests for layer depth, hardness, data registry, and game systems.

Verifies the 7 underground layer types and game subsystems work correctly.
"""
import pytest
from helpers import PATHS


# =============================================================================
# AUTOLOAD MANAGER EXISTENCE TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_game_manager_exists(game):
    """Verify GameManager autoload is running."""
    exists = await game.node_exists(PATHS["game_manager"])
    assert exists, "GameManager autoload should exist"


@pytest.mark.asyncio
async def test_data_registry_exists(game):
    """Verify DataRegistry autoload is running."""
    exists = await game.node_exists(PATHS["data_registry"])
    assert exists, "DataRegistry autoload should exist"


@pytest.mark.asyncio
async def test_inventory_manager_exists(game):
    """Verify InventoryManager autoload is running."""
    exists = await game.node_exists(PATHS["inventory_manager"])
    assert exists, "InventoryManager autoload should exist"


@pytest.mark.asyncio
async def test_save_manager_exists(game):
    """Verify SaveManager autoload is running."""
    exists = await game.node_exists(PATHS["save_manager"])
    assert exists, "SaveManager autoload should exist"


@pytest.mark.asyncio
async def test_player_data_exists(game):
    """Verify PlayerData autoload is running."""
    exists = await game.node_exists(PATHS["player_data"])
    assert exists, "PlayerData autoload should exist"


@pytest.mark.asyncio
async def test_settings_manager_exists(game):
    """Verify SettingsManager autoload is running."""
    exists = await game.node_exists(PATHS["settings_manager"])
    assert exists, "SettingsManager autoload should exist"


@pytest.mark.asyncio
async def test_platform_detector_exists(game):
    """Verify PlatformDetector autoload is running."""
    exists = await game.node_exists(PATHS["platform_detector"])
    assert exists, "PlatformDetector autoload should exist"


@pytest.mark.asyncio
async def test_player_stats_exists(game):
    """Verify PlayerStats autoload is running."""
    exists = await game.node_exists(PATHS["player_stats"])
    assert exists, "PlayerStats autoload should exist"


@pytest.mark.asyncio
async def test_haptic_feedback_exists(game):
    """Verify HapticFeedback autoload is running."""
    exists = await game.node_exists(PATHS["haptic_feedback"])
    assert exists, "HapticFeedback autoload should exist"


# =============================================================================
# GAME SCENE STRUCTURE TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_main_node_exists(game):
    """Verify Main scene node exists."""
    exists = await game.node_exists(PATHS["main"])
    assert exists, "Main scene node should exist"


@pytest.mark.asyncio
async def test_player_exists(game):
    """Verify Player node exists."""
    exists = await game.node_exists(PATHS["player"])
    assert exists, "Player node should exist"


@pytest.mark.asyncio
async def test_dirt_grid_exists(game):
    """Verify DirtGrid node exists."""
    exists = await game.node_exists(PATHS["dirt_grid"])
    assert exists, "DirtGrid node should exist"


@pytest.mark.asyncio
async def test_hud_exists(game):
    """Verify HUD node exists."""
    exists = await game.node_exists(PATHS["hud"])
    assert exists, "HUD node should exist"


@pytest.mark.asyncio
async def test_shop_exists(game):
    """Verify Shop UI node exists."""
    exists = await game.node_exists(PATHS["shop"])
    assert exists, "Shop UI should exist"


# =============================================================================
# GAME MANAGER PROPERTY TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_game_manager_has_block_size(game):
    """Verify GameManager has BLOCK_SIZE constant."""
    block_size = await game.get_property(PATHS["game_manager"], "BLOCK_SIZE")
    assert block_size == 128, f"BLOCK_SIZE should be 128, got {block_size}"


@pytest.mark.asyncio
async def test_game_manager_has_surface_row(game):
    """Verify GameManager has SURFACE_ROW constant."""
    surface_row = await game.get_property(PATHS["game_manager"], "SURFACE_ROW")
    assert surface_row == 7, f"SURFACE_ROW should be 7, got {surface_row}"


@pytest.mark.asyncio
async def test_game_manager_has_coins(game):
    """Verify GameManager tracks coins."""
    coins = await game.get_property(PATHS["game_manager"], "coins")
    assert coins is not None, "GameManager should have coins property"
    assert isinstance(coins, int), f"coins should be int, got {type(coins)}"


@pytest.mark.asyncio
async def test_game_manager_has_current_depth(game):
    """Verify GameManager tracks current depth."""
    depth = await game.get_property(PATHS["game_manager"], "current_depth")
    assert depth is not None, "GameManager should have current_depth property"
    assert isinstance(depth, int), f"current_depth should be int, got {type(depth)}"


# =============================================================================
# DIRT GRID PROPERTY TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_dirt_grid_has_block_size(game):
    """Verify DirtGrid has BLOCK_SIZE constant."""
    block_size = await game.get_property(PATHS["dirt_grid"], "BLOCK_SIZE")
    assert block_size == 128, f"BLOCK_SIZE should be 128, got {block_size}"


@pytest.mark.asyncio
async def test_dirt_grid_has_chunk_size(game):
    """Verify DirtGrid has CHUNK_SIZE constant."""
    chunk_size = await game.get_property(PATHS["dirt_grid"], "CHUNK_SIZE")
    assert chunk_size == 16, f"CHUNK_SIZE should be 16, got {chunk_size}"


@pytest.mark.asyncio
async def test_dirt_grid_has_pool_size(game):
    """Verify DirtGrid has POOL_SIZE constant."""
    pool_size = await game.get_property(PATHS["dirt_grid"], "POOL_SIZE")
    assert pool_size == 400, f"POOL_SIZE should be 400, got {pool_size}"


@pytest.mark.asyncio
async def test_dirt_grid_has_load_radius(game):
    """Verify DirtGrid has LOAD_RADIUS constant."""
    load_radius = await game.get_property(PATHS["dirt_grid"], "LOAD_RADIUS")
    assert load_radius == 2, f"LOAD_RADIUS should be 2, got {load_radius}"


# =============================================================================
# PLAYER DATA PROPERTY TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_player_data_has_equipped_tool(game):
    """Verify PlayerData tracks equipped tool."""
    tool_id = await game.get_property(PATHS["player_data"], "equipped_tool_id")
    assert tool_id is not None, "PlayerData should have equipped_tool_id"
    assert isinstance(tool_id, str), f"equipped_tool_id should be string, got {type(tool_id)}"


@pytest.mark.asyncio
async def test_player_data_has_max_depth_reached(game):
    """Verify PlayerData tracks max depth reached."""
    max_depth = await game.get_property(PATHS["player_data"], "max_depth_reached")
    assert max_depth is not None, "PlayerData should have max_depth_reached"
    assert isinstance(max_depth, int), f"max_depth_reached should be int, got {type(max_depth)}"


@pytest.mark.asyncio
async def test_player_data_has_current_dive_max_depth(game):
    """Verify PlayerData tracks current dive max depth for sell multiplier."""
    dive_depth = await game.get_property(PATHS["player_data"], "current_dive_max_depth")
    assert dive_depth is not None, "PlayerData should have current_dive_max_depth"
    assert isinstance(dive_depth, int), f"current_dive_max_depth should be int, got {type(dive_depth)}"


@pytest.mark.asyncio
async def test_player_data_has_depth_sell_multiplier_method(game):
    """Verify PlayerData provides depth-based sell multiplier."""
    has_method = await game.call(PATHS["player_data"], "has_method", ["get_depth_sell_multiplier"])
    assert has_method, "PlayerData should have get_depth_sell_multiplier method"


@pytest.mark.asyncio
async def test_depth_sell_multiplier_formula(game):
    """Verify depth sell multiplier returns correct value at surface.

    Formula: 1.0 + (dive_depth / 100)
    At surface (depth 0), multiplier should be 1.0
    """
    multiplier = await game.call(PATHS["player_data"], "get_depth_sell_multiplier")
    assert multiplier is not None, "get_depth_sell_multiplier should return a value"
    # At fresh game start, dive depth is 0, so multiplier should be 1.0
    assert multiplier == 1.0, f"Multiplier at surface should be 1.0, got {multiplier}"


# =============================================================================
# INVENTORY MANAGER PROPERTY TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_inventory_manager_has_max_slots(game):
    """Verify InventoryManager has max_slots property."""
    max_slots = await game.get_property(PATHS["inventory_manager"], "max_slots")
    assert max_slots is not None, "InventoryManager should have max_slots"
    assert max_slots >= 8, f"Should have at least 8 slots, got {max_slots}"


# =============================================================================
# SETTINGS MANAGER PROPERTY TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_settings_manager_has_text_size_level(game):
    """Verify SettingsManager has text_size_level property."""
    level = await game.get_property(PATHS["settings_manager"], "text_size_level")
    assert level is not None, "SettingsManager should have text_size_level"
    assert isinstance(level, int), f"text_size_level should be int, got {type(level)}"


@pytest.mark.asyncio
async def test_settings_manager_has_colorblind_mode(game):
    """Verify SettingsManager has colorblind_mode property."""
    mode = await game.get_property(PATHS["settings_manager"], "colorblind_mode")
    assert mode is not None, "SettingsManager should have colorblind_mode"
    assert isinstance(mode, int), f"colorblind_mode should be int, got {type(mode)}"


@pytest.mark.asyncio
async def test_settings_manager_has_haptics_enabled(game):
    """Verify SettingsManager has haptics_enabled property."""
    enabled = await game.get_property(PATHS["settings_manager"], "haptics_enabled")
    assert enabled is not None, "SettingsManager should have haptics_enabled"
    assert isinstance(enabled, bool), f"haptics_enabled should be bool, got {type(enabled)}"


@pytest.mark.asyncio
async def test_settings_manager_has_reduced_motion(game):
    """Verify SettingsManager has reduced_motion property."""
    enabled = await game.get_property(PATHS["settings_manager"], "reduced_motion")
    assert enabled is not None, "SettingsManager should have reduced_motion"
    assert isinstance(enabled, bool), f"reduced_motion should be bool, got {type(enabled)}"


@pytest.mark.asyncio
async def test_settings_manager_has_hand_mode(game):
    """Verify SettingsManager has hand_mode property."""
    mode = await game.get_property(PATHS["settings_manager"], "hand_mode")
    assert mode is not None, "SettingsManager should have hand_mode"
    assert isinstance(mode, int), f"hand_mode should be int, got {type(mode)}"


# =============================================================================
# HUD COMPONENT TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_health_bar_exists(game):
    """Verify health bar exists in HUD."""
    exists = await game.node_exists(PATHS["health_bar"])
    assert exists, "Health bar should exist in HUD"


@pytest.mark.asyncio
async def test_coins_label_exists(game):
    """Verify coins label exists in HUD."""
    exists = await game.node_exists(PATHS["coins_label"])
    assert exists, "Coins label should exist in HUD"


@pytest.mark.asyncio
async def test_depth_label_exists(game):
    """Verify depth label exists in HUD."""
    exists = await game.node_exists(PATHS["depth_label"])
    assert exists, "Depth label should exist in HUD"


@pytest.mark.asyncio
async def test_pause_button_exists(game):
    """Verify pause button exists in HUD."""
    exists = await game.node_exists(PATHS["pause_button"])
    assert exists, "Pause button should exist in HUD"


# =============================================================================
# SHOP UI TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_shop_starts_hidden(game):
    """Verify shop starts invisible."""
    visible = await game.get_property(PATHS["shop"], "visible")
    assert visible is False, "Shop should start hidden"


# =============================================================================
# PLAYER TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_player_has_collision_shape(game):
    """Verify player has collision shape."""
    exists = await game.node_exists(PATHS["player_collision"])
    assert exists, "Player should have collision shape"


@pytest.mark.asyncio
async def test_player_has_sprite(game):
    """Verify player has animated sprite."""
    exists = await game.node_exists(PATHS["player_sprite"])
    assert exists, "Player should have animated sprite"


# =============================================================================
# SURFACE AREA TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_surface_exists(game):
    """Verify Surface node exists."""
    exists = await game.node_exists(PATHS["surface"])
    assert exists, "Surface node should exist"
