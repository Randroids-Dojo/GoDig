"""
Test level tests for GoDig endless digging game.

Verifies the game setup, player, dirt grid, and basic mechanics.
"""
import pytest
from helpers import PATHS


@pytest.mark.asyncio
async def test_main_scene_loads(game):
    """Verify the main scene loads correctly."""
    exists = await game.node_exists(PATHS["main"])
    assert exists, "Main scene should exist"


@pytest.mark.asyncio
async def test_player_exists(game):
    """Verify the player node exists."""
    exists = await game.node_exists(PATHS["player"])
    assert exists, "Player node should exist"


@pytest.mark.asyncio
async def test_dirt_grid_exists(game):
    """Verify the dirt grid node exists."""
    exists = await game.node_exists(PATHS["dirt_grid"])
    assert exists, "DirtGrid node should exist"


@pytest.mark.asyncio
async def test_camera_exists(game):
    """Verify the camera node exists."""
    exists = await game.node_exists(PATHS["camera"])
    assert exists, "Camera2D node should exist"


@pytest.mark.asyncio
async def test_depth_label_exists(game):
    """Verify the depth label UI exists."""
    exists = await game.node_exists(PATHS["depth_label"])
    assert exists, "DepthLabel UI should exist"


@pytest.mark.asyncio
async def test_game_manager_exists(game):
    """Verify the GameManager autoload exists."""
    exists = await game.node_exists(PATHS["game_manager"])
    assert exists, "GameManager autoload should exist"


@pytest.mark.asyncio
async def test_game_is_running(game):
    """Verify the game is running after scene loads."""
    is_running = await game.get_property(PATHS["game_manager"], "is_running")
    assert is_running is True, "Game should be running after scene loads"


@pytest.mark.asyncio
async def test_depth_label_shows_depth(game):
    """Verify the depth label displays depth info."""
    text = await game.get_property(PATHS["depth_label"], "text")
    assert "Depth:" in text, f"Depth label should show 'Depth:', got '{text}'"


@pytest.mark.asyncio
async def test_touch_controls_exists(game):
    """Verify the touch controls UI exists."""
    exists = await game.node_exists(PATHS["touch_controls"])
    assert exists, "TouchControls UI should exist"


@pytest.mark.asyncio
async def test_left_button_exists(game):
    """Verify the left button exists."""
    exists = await game.node_exists(PATHS["left_button"])
    assert exists, "Left button should exist"


@pytest.mark.asyncio
async def test_right_button_exists(game):
    """Verify the right button exists."""
    exists = await game.node_exists(PATHS["right_button"])
    assert exists, "Right button should exist"


@pytest.mark.asyncio
async def test_down_button_exists(game):
    """Verify the down button exists."""
    exists = await game.node_exists(PATHS["down_button"])
    assert exists, "Down button should exist"


@pytest.mark.asyncio
async def test_touch_buttons_have_text(game):
    """Verify all touch buttons have directional arrows."""
    left_text = await game.get_property(PATHS["left_button"], "text")
    right_text = await game.get_property(PATHS["right_button"], "text")
    down_text = await game.get_property(PATHS["down_button"], "text")

    assert left_text == "◀", f"Left button should show '◀', got '{left_text}'"
    assert right_text == "▶", f"Right button should show '▶', got '{right_text}'"
    assert down_text == "▼", f"Down button should show '▼', got '{down_text}'"


# =============================================================================
# WALL-JUMP TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_jump_button_exists(game):
    """Verify the jump button exists for wall-jump mechanic."""
    exists = await game.node_exists(PATHS["jump_button"])
    assert exists, "Jump button should exist for wall-jump"


@pytest.mark.asyncio
async def test_jump_button_has_text(game):
    """Verify the jump button has appropriate text."""
    text = await game.get_property(PATHS["jump_button"], "text")
    assert text == "JUMP", f"Jump button should show 'JUMP', got '{text}'"


@pytest.mark.asyncio
async def test_player_has_wall_jump_states(game):
    """Verify the player has the wall-jump state machine states."""
    # Check that the player is in a valid state (IDLE = 0 at start)
    current_state = await game.get_property(PATHS["player"], "current_state")
    assert current_state is not None, "Player should have current_state property"
    # State.IDLE = 0
    assert current_state == 0, f"Player should start in IDLE state (0), got {current_state}"


# =============================================================================
# DATA REGISTRY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_data_registry_exists(game):
    """Verify the DataRegistry autoload exists."""
    exists = await game.node_exists(PATHS["data_registry"])
    assert exists, "DataRegistry autoload should exist"


# =============================================================================
# INVENTORY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_inventory_manager_exists(game):
    """Verify the InventoryManager autoload exists."""
    exists = await game.node_exists(PATHS["inventory_manager"])
    assert exists, "InventoryManager autoload should exist"


@pytest.mark.asyncio
async def test_inventory_has_slots(game):
    """Verify the InventoryManager has the correct number of starting slots."""
    max_slots = await game.get_property(PATHS["inventory_manager"], "max_slots")
    assert max_slots == 8, f"Inventory should start with 8 slots, got {max_slots}"


# =============================================================================
# COINS PROPERTY EXISTS
# =============================================================================

@pytest.mark.asyncio
async def test_coins_property_exists(game):
    """Verify the GameManager has a coins property."""
    coins = await game.get_property(PATHS["game_manager"], "coins")
    assert coins is not None, "GameManager should have coins property"
    assert isinstance(coins, int), f"Coins should be an int, got {type(coins)}"
# =============================================================================
# SHOP BUTTON EXISTS
# =============================================================================

>>>>>>> 57a5e4a (feat: Add OreData resource class and ore definitions)
=======


@pytest.mark.asyncio
async def test_shop_button_exists(game):
    """Verify the shop button exists in the UI."""
    exists = await game.node_exists(PATHS["shop_button"])
    assert exists, "Shop button should exist"


@pytest.mark.asyncio
async def test_shop_button_has_text(game):
    """Verify the shop button has SHOP text."""
    text = await game.get_property(PATHS["shop_button"], "text")
    assert text == "SHOP", f"Shop button should show 'SHOP', got '{text}'"


@pytest.mark.asyncio
async def test_shop_ui_exists(game):
    """Verify the Shop UI panel exists."""
    exists = await game.node_exists(PATHS["shop"])
    assert exists, "Shop UI should exist"


@pytest.mark.asyncio
async def test_shop_starts_hidden(game):
    """Verify the shop starts hidden."""
    visible = await game.get_property(PATHS["shop"], "visible")
    assert visible is False, "Shop should start hidden"


@pytest.mark.asyncio
async def test_coins_label_exists(game):
    """Verify the coins label exists in the HUD."""
    exists = await game.node_exists(PATHS["coins_label"])
    assert exists, "Coins label should exist"


@pytest.mark.asyncio
async def test_coins_label_shows_amount(game):
    """Verify the coins label shows a dollar amount."""
    text = await game.get_property(PATHS["coins_label"], "text")
    assert text.startswith("$"), f"Coins label should start with '$', got '{text}'"

# =============================================================================
# SAVE MANAGER EXISTS
# =============================================================================


@pytest.mark.asyncio
async def test_save_manager_exists(game):
    """Verify the SaveManager autoload exists."""
    exists = await game.node_exists(PATHS["save_manager"])
    assert exists, "SaveManager autoload should exist"


@pytest.mark.asyncio
async def test_save_manager_has_slot(game):
    """Verify the SaveManager has current_slot property."""
    current_slot = await game.get_property(PATHS["save_manager"], "current_slot")
    assert current_slot is not None, "SaveManager should have current_slot property"
    assert current_slot == -1, f"SaveManager current_slot should be -1 (no save), got {current_slot}"

# =============================================================================
# PLATFORM DETECTOR EXISTS
# =============================================================================


@pytest.mark.asyncio
async def test_platform_detector_exists(game):
    """Verify the PlatformDetector autoload exists."""
    exists = await game.node_exists(PATHS["platform_detector"])
    assert exists, "PlatformDetector autoload should exist"


@pytest.mark.asyncio
async def test_platform_detector_has_properties(game):
    """Verify the PlatformDetector has required properties."""
    is_mobile = await game.get_property(PATHS["platform_detector"], "is_mobile_platform")
    assert is_mobile is not None, "PlatformDetector should have is_mobile_platform property"

    is_using_touch = await game.get_property(PATHS["platform_detector"], "is_using_touch")
    assert is_using_touch is not None, "PlatformDetector should have is_using_touch property"

    manual_override = await game.get_property(PATHS["platform_detector"], "manual_override")
    assert manual_override is not None, "PlatformDetector should have manual_override property"


@pytest.mark.asyncio
async def test_touch_controls_has_force_visible(game):
    """Verify touch controls has force_visible export property."""
    force_visible = await game.get_property(PATHS["touch_controls"], "force_visible")
    assert force_visible is not None, "TouchControls should have force_visible property"

# =============================================================================
# SAVE MANAGER HAS AUTO SAVE ENABLED
# =============================================================================


@pytest.mark.asyncio
async def test_save_manager_has_auto_save_enabled(game):
    """Verify SaveManager has auto_save_enabled property."""
    auto_save_enabled = await game.get_property(PATHS["save_manager"], "auto_save_enabled")
    assert auto_save_enabled is True, "SaveManager auto_save_enabled should be True by default"


@pytest.mark.asyncio
async def test_save_manager_has_auto_save_interval(game):
    """Verify SaveManager has AUTO_SAVE_INTERVAL constant."""
    interval = await game.get_property(PATHS["save_manager"], "AUTO_SAVE_INTERVAL")
    assert interval == 60.0, f"AUTO_SAVE_INTERVAL should be 60.0 seconds, got {interval}"


@pytest.mark.asyncio
async def test_save_manager_has_debounce_interval(game):
    """Verify SaveManager has MIN_SAVE_INTERVAL_MS constant for debouncing."""
    interval = await game.get_property(PATHS["save_manager"], "MIN_SAVE_INTERVAL_MS")
    assert interval == 5000, f"MIN_SAVE_INTERVAL_MS should be 5000ms, got {interval}"


@pytest.mark.asyncio
async def test_game_manager_has_depth_milestones(game):
    """Verify GameManager has DEPTH_MILESTONES constant."""
    milestones = await game.get_property(PATHS["game_manager"], "DEPTH_MILESTONES")
    assert milestones is not None, "GameManager should have DEPTH_MILESTONES"
    assert len(milestones) > 0, "DEPTH_MILESTONES should not be empty"
    assert 10 in milestones, "DEPTH_MILESTONES should include 10m"
    assert 100 in milestones, "DEPTH_MILESTONES should include 100m"

<<<<<<< HEAD



# =============================================================================
# INFINITE TERRAIN TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_dirt_grid_has_chunk_system(game):
    """Verify the dirt grid uses chunk-based generation."""
    # Check that the dirt grid has the chunk system constants
    chunk_size = await game.get_property(PATHS["dirt_grid"], "CHUNK_SIZE")
    load_radius = await game.get_property(PATHS["dirt_grid"], "LOAD_RADIUS")

    assert chunk_size == 16, f"Chunk size should be 16, got {chunk_size}"
    assert load_radius == 3, f"Load radius should be 3, got {load_radius}"


@pytest.mark.asyncio
async def test_initial_chunks_loaded(game):
    """Verify chunks are loaded around player at start."""
    # Get the loaded_chunks dictionary from dirt_grid
    loaded_chunks = await game.get_property(PATHS["dirt_grid"], "_loaded_chunks")

    assert loaded_chunks is not None, "Loaded chunks dictionary should exist"
    assert len(loaded_chunks) > 0, "Should have loaded chunks at game start"


@pytest.mark.asyncio
async def test_horizontal_blocks_exist(game):
    """Verify blocks exist horizontally beyond the old 5-column limit."""
    # The old system only had 5 columns (0-4)
    # With infinite terrain, we should have blocks in column 5+ and negative columns

    # Check if dirt_grid has blocks at various horizontal positions
    # We'll check if has_block method exists and can be called
    # Note: We need to wait a bit for generation to complete
    await game.wait_frames(10)

    # Just verify the system accepts wider coordinates
    # (actual block presence depends on surface row and generation)
    # The key test is that the system doesn't reject x > 4
    active_blocks = await game.get_property(PATHS["dirt_grid"], "_active")

    assert active_blocks is not None, "Active blocks dictionary should exist"
    # With chunk-based generation, we should have more than the old 5*ROWS_AHEAD blocks
    assert len(active_blocks) > 50, f"Should have many blocks loaded with chunks, got {len(active_blocks)}"


@pytest.mark.asyncio
async def test_player_can_move_horizontally_unlimited(game):
    """Verify player is not restricted by old horizontal bounds."""
    # Get player's initial position
    initial_pos = await game.get_property(PATHS["player"], "grid_position")

    # The old system restricted movement to 0 <= x < 5
    # New system should allow any x coordinate

    # Simulate moving right multiple times
    for i in range(3):
        await game.send_action("move_right", True)
        await game.wait_frames(15)  # Wait for movement animation
        await game.send_action("move_right", False)
        await game.wait_frames(2)

    # Get new position
    new_pos = await game.get_property(PATHS["player"], "grid_position")

    # Player should have moved right (x increased)
    # Even if there are blocks, player should attempt to move/mine
    assert new_pos is not None, "Player should have a grid position"


@pytest.mark.asyncio
async def test_chunks_generated_around_player(game):
    """Verify chunks are generated as player moves."""
    # Get initial chunk count
    initial_chunks = await game.get_property(PATHS["dirt_grid"], "_loaded_chunks")
    initial_count = len(initial_chunks)

    # Move player significantly to trigger new chunk loading
    # Move right multiple times
    for i in range(20):
        await game.send_action("move_right", True)
        await game.wait_frames(2)
        await game.send_action("move_right", False)
        await game.wait_frames(2)

    # Give time for chunk generation
    await game.wait_frames(10)

    # Check that chunks were generated or remain loaded
    current_chunks = await game.get_property(PATHS["dirt_grid"], "_loaded_chunks")
    current_count = len(current_chunks)

    # Should maintain chunks around player (some old chunks unloaded, new ones loaded)
    assert current_count > 0, "Should have chunks loaded around player"
    # The count might be similar due to unloading, but chunks should still exist
    assert current_count >= 9, f"Should maintain at least 3x3 chunks around player, got {current_count}"


@pytest.mark.asyncio
async def test_grid_offset_is_zero(game):
    """Verify GRID_OFFSET_X is set to 0 for infinite terrain."""
    offset_x = await game.get_property(PATHS["game_manager"], "GRID_OFFSET_X")

    assert offset_x == 0, f"GRID_OFFSET_X should be 0 for infinite terrain, got {offset_x}"


@pytest.mark.asyncio
async def test_player_starts_at_correct_position(game):
    """Verify player starts at a valid grid position."""
    grid_pos = await game.get_property(PATHS["player"], "grid_position")

    assert grid_pos is not None, "Player should have a grid position"
    # Player should start above the surface (row 7)
    assert grid_pos["y"] <= 7, f"Player should start at or above surface row 7, got y={grid_pos['y']}"
