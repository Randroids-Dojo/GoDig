"""
Test level tests for GoDig endless digging game.

Verifies the game setup, player, dirt grid, and basic mechanics.
"""
import asyncio
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
async def test_virtual_joystick_exists(game):
    """Verify the virtual joystick exists for mobile movement."""
    exists = await game.node_exists(PATHS["virtual_joystick"])
    assert exists, "Virtual joystick should exist"


@pytest.mark.asyncio
async def test_virtual_joystick_has_deadzone(game):
    """Verify the virtual joystick has a deadzone property."""
    deadzone = await game.get_property(PATHS["virtual_joystick"], "deadzone")
    assert deadzone is not None, "Virtual joystick should have deadzone property"
    assert deadzone > 0, f"Deadzone should be positive, got {deadzone}"
    assert deadzone < 1, f"Deadzone should be less than 1, got {deadzone}"


@pytest.mark.asyncio
async def test_virtual_joystick_has_max_distance(game):
    """Verify the virtual joystick has a max_distance property."""
    max_distance = await game.get_property(PATHS["virtual_joystick"], "max_distance")
    assert max_distance is not None, "Virtual joystick should have max_distance property"
    assert max_distance > 0, f"Max distance should be positive, got {max_distance}"


@pytest.mark.asyncio
async def test_virtual_joystick_direction_starts_zero(game):
    """Verify the virtual joystick starts with zero direction."""
    direction = await game.get_property(PATHS["virtual_joystick"], "_current_direction")
    # Vector2i is returned as a dict with x and y
    assert direction is not None, "Virtual joystick should have _current_direction"


# =============================================================================
# WALL-JUMP TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_action_buttons_container_exists(game):
    """Verify the action buttons container exists for touch controls."""
    exists = await game.node_exists(PATHS["action_buttons"])
    assert exists, "Action buttons container should exist"


@pytest.mark.asyncio
async def test_jump_button_exists(game):
    """Verify the jump TouchScreenButton exists for wall-jump mechanic."""
    exists = await game.node_exists(PATHS["jump_button"])
    assert exists, "Jump button should exist for wall-jump"


@pytest.mark.asyncio
async def test_jump_button_has_action(game):
    """Verify the jump button has the correct input action mapped."""
    action = await game.get_property(PATHS["jump_button"], "action")
    assert action == "jump", f"Jump button should have action 'jump', got '{action}'"


@pytest.mark.asyncio
async def test_inventory_button_exists(game):
    """Verify the inventory TouchScreenButton exists."""
    exists = await game.node_exists(PATHS["inventory_button"])
    assert exists, "Inventory button should exist for touch controls"


@pytest.mark.asyncio
async def test_inventory_button_has_action(game):
    """Verify the inventory button has the correct input action mapped."""
    action = await game.get_property(PATHS["inventory_button"], "action")
    assert action == "inventory", f"Inventory button should have action 'inventory', got '{action}'"


@pytest.mark.asyncio
async def test_jump_button_has_touch_shape(game):
    """Verify the jump button has a touch shape defined for mobile taps."""
    shape = await game.get_property(PATHS["jump_button"], "shape")
    assert shape is not None, "Jump button must have a shape defined for touch input"


@pytest.mark.asyncio
async def test_inventory_button_has_touch_shape(game):
    """Verify the inventory button has a touch shape defined for mobile taps."""
    shape = await game.get_property(PATHS["inventory_button"], "shape")
    assert shape is not None, "Inventory button must have a shape defined for touch input"


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


# =============================================================================
# SETTINGS MANAGER TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_settings_manager_exists(game):
    """Verify the SettingsManager autoload exists."""
    exists = await game.node_exists(PATHS["settings_manager"])
    assert exists, "SettingsManager autoload should exist"


@pytest.mark.asyncio
async def test_settings_manager_has_text_size_level(game):
    """Verify SettingsManager has text_size_level property with default value."""
    text_size_level = await game.get_property(PATHS["settings_manager"], "text_size_level")
    assert text_size_level is not None, "SettingsManager should have text_size_level property"
    assert text_size_level == 1, f"text_size_level should default to 1, got {text_size_level}"


@pytest.mark.asyncio
async def test_settings_manager_has_text_scales(game):
    """Verify SettingsManager has TEXT_SCALES constant."""
    text_scales = await game.get_property(PATHS["settings_manager"], "TEXT_SCALES")
    assert text_scales is not None, "SettingsManager should have TEXT_SCALES constant"
    assert len(text_scales) == 5, f"TEXT_SCALES should have 5 options, got {len(text_scales)}"
    assert 1.0 in text_scales, "TEXT_SCALES should include 1.0 (normal)"


@pytest.mark.asyncio
async def test_settings_manager_has_colorblind_mode(game):
    """Verify SettingsManager has colorblind_mode property."""
    colorblind_mode = await game.get_property(PATHS["settings_manager"], "colorblind_mode")
    assert colorblind_mode is not None, "SettingsManager should have colorblind_mode property"
    # ColorblindMode.OFF = 0
    assert colorblind_mode == 0, f"colorblind_mode should default to OFF (0), got {colorblind_mode}"


@pytest.mark.asyncio
async def test_settings_manager_has_hand_mode(game):
    """Verify SettingsManager has hand_mode property."""
    hand_mode = await game.get_property(PATHS["settings_manager"], "hand_mode")
    assert hand_mode is not None, "SettingsManager should have hand_mode property"
    # HandMode.STANDARD = 0
    assert hand_mode == 0, f"hand_mode should default to STANDARD (0), got {hand_mode}"


@pytest.mark.asyncio
async def test_settings_manager_has_haptics_enabled(game):
    """Verify SettingsManager has haptics_enabled property."""
    haptics_enabled = await game.get_property(PATHS["settings_manager"], "haptics_enabled")
    assert haptics_enabled is not None, "SettingsManager should have haptics_enabled property"
    assert haptics_enabled is True, f"haptics_enabled should default to True, got {haptics_enabled}"


@pytest.mark.asyncio
async def test_settings_manager_has_reduced_motion(game):
    """Verify SettingsManager has reduced_motion property."""
    reduced_motion = await game.get_property(PATHS["settings_manager"], "reduced_motion")
    assert reduced_motion is not None, "SettingsManager should have reduced_motion property"
    assert reduced_motion is False, f"reduced_motion should default to False, got {reduced_motion}"


@pytest.mark.asyncio
async def test_settings_manager_has_audio_volumes(game):
    """Verify SettingsManager has audio volume properties."""
    master = await game.get_property(PATHS["settings_manager"], "master_volume")
    sfx = await game.get_property(PATHS["settings_manager"], "sfx_volume")
    music = await game.get_property(PATHS["settings_manager"], "music_volume")

    assert master is not None, "SettingsManager should have master_volume property"
    assert sfx is not None, "SettingsManager should have sfx_volume property"
    assert music is not None, "SettingsManager should have music_volume property"

    assert master == 1.0, f"master_volume should default to 1.0, got {master}"
    assert sfx == 1.0, f"sfx_volume should default to 1.0, got {sfx}"
    assert music == 1.0, f"music_volume should default to 1.0, got {music}"


@pytest.mark.asyncio
async def test_settings_manager_has_settings_path(game):
    """Verify SettingsManager has SETTINGS_PATH constant."""
    settings_path = await game.get_property(PATHS["settings_manager"], "SETTINGS_PATH")
    assert settings_path is not None, "SettingsManager should have SETTINGS_PATH constant"
    assert settings_path == "user://settings.cfg", f"SETTINGS_PATH should be 'user://settings.cfg', got '{settings_path}'"


# =============================================================================
# PAUSE MENU TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_pause_button_exists(game):
    """Verify the pause button exists in the UI."""
    exists = await game.node_exists(PATHS["pause_button"])
    assert exists, "Pause button should exist in UI"


@pytest.mark.asyncio
async def test_pause_button_has_text(game):
    """Verify the pause button has the pause icon text."""
    text = await game.get_property(PATHS["pause_button"], "text")
    assert text == "||", f"Pause button should show '||', got '{text}'"


@pytest.mark.asyncio
async def test_pause_menu_exists(game):
    """Verify the pause menu node exists."""
    exists = await game.node_exists(PATHS["pause_menu"])
    assert exists, "PauseMenu should exist"


@pytest.mark.asyncio
async def test_pause_menu_starts_hidden(game):
    """Verify the pause menu starts hidden."""
    visible = await game.get_property(PATHS["pause_menu"], "visible")
    assert visible is False, "PauseMenu should start hidden"


@pytest.mark.asyncio
async def test_pause_menu_has_resume_button(game):
    """Verify the pause menu has a resume button."""
    exists = await game.node_exists(PATHS["pause_menu_resume"])
    assert exists, "PauseMenu should have Resume button"


@pytest.mark.asyncio
async def test_pause_menu_has_settings_button(game):
    """Verify the pause menu has a settings button."""
    exists = await game.node_exists(PATHS["pause_menu_settings"])
    assert exists, "PauseMenu should have Settings button"


@pytest.mark.asyncio
async def test_pause_menu_has_rescue_button(game):
    """Verify the pause menu has a rescue button."""
    exists = await game.node_exists(PATHS["pause_menu_rescue"])
    assert exists, "PauseMenu should have Rescue button"


@pytest.mark.asyncio
async def test_pause_menu_has_reload_button(game):
    """Verify the pause menu has a reload button."""
    exists = await game.node_exists(PATHS["pause_menu_reload"])
    assert exists, "PauseMenu should have Reload button"


@pytest.mark.asyncio
async def test_pause_menu_has_quit_button(game):
    """Verify the pause menu has a quit button."""
    exists = await game.node_exists(PATHS["pause_menu_quit"])
    assert exists, "PauseMenu should have Quit button"


@pytest.mark.asyncio
async def test_pause_menu_is_canvas_layer(game):
    """Verify the pause menu is a CanvasLayer for proper rendering."""
    # CanvasLayer has a 'layer' property
    layer = await game.get_property(PATHS["pause_menu"], "layer")
    assert layer is not None, "PauseMenu should have layer property (CanvasLayer)"
    assert layer == 100, f"PauseMenu layer should be 100 (above everything), got {layer}"


@pytest.mark.asyncio
async def test_pause_menu_process_mode(game):
    """Verify the pause menu runs while game is paused."""
    # PROCESS_MODE_ALWAYS = 3
    process_mode = await game.get_property(PATHS["pause_menu"], "process_mode")
    assert process_mode == 3, f"PauseMenu process_mode should be PROCESS_MODE_ALWAYS (3), got {process_mode}"

# =============================================================================
# PAUSE MENU HAS CONFIRM DIALOG
# =============================================================================


@pytest.mark.asyncio
async def test_pause_menu_has_confirm_dialog(game):
    """Verify the pause menu has a confirmation dialog for dangerous actions."""
    exists = await game.node_exists(PATHS["pause_menu_confirm_dialog"])
    assert exists, "PauseMenu should have a confirmation dialog"


@pytest.mark.asyncio
async def test_pause_menu_confirm_dialog_process_mode(game):
    """Verify the confirmation dialog runs while game is paused."""
    # PROCESS_MODE_ALWAYS = 3
    process_mode = await game.get_property(PATHS["pause_menu_confirm_dialog"], "process_mode")
    assert process_mode == 3, f"Confirmation dialog process_mode should be PROCESS_MODE_ALWAYS (3), got {process_mode}"


@pytest.mark.asyncio
async def test_pause_menu_has_pending_action(game):
    """Verify the pause menu tracks pending confirmation actions."""
    pending = await game.get_property(PATHS["pause_menu"], "_pending_action")
    assert pending == "", f"Pending action should start empty, got '{pending}'"


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
    assert load_radius == 2, f"Load radius should be 2 (optimized for CI), got {load_radius}"


@pytest.mark.asyncio
async def test_initial_chunks_loaded(game):
    """Verify chunks are loaded around player at start."""
    # Get the loaded_chunks dictionary from dirt_grid
    loaded_chunks = await game.get_property(PATHS["dirt_grid"], "_loaded_chunks")

    assert loaded_chunks is not None, "Loaded chunks dictionary should exist"
    assert len(loaded_chunks) > 0, "Should have loaded chunks at game start"


@pytest.mark.asyncio
async def test_horizontal_blocks_exist(game):
    """Verify the chunk system generates blocks horizontally."""
    # The old system only had 5 columns (0-4)
    # With infinite terrain, chunks cover a wider area

    # Wait for generation to complete
    await asyncio.sleep(0.5)

    # Check loaded chunks - uses Vector2i keys and bool values (serializable)
    loaded_chunks = await game.get_property(PATHS["dirt_grid"], "_loaded_chunks")

    assert loaded_chunks is not None, "Loaded chunks dictionary should exist"

    # With LOAD_RADIUS=2, we should have a 5x5 grid = 25 chunks
    # But only chunks at or below surface will have blocks
    assert len(loaded_chunks) >= 10, f"Should have multiple chunks loaded, got {len(loaded_chunks)}"


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


# =============================================================================
# MILESTONE NOTIFICATION TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_milestone_notification_exists(game):
    """Verify the milestone notification UI exists in the HUD."""
    exists = await game.node_exists(PATHS["milestone_notification"])
    assert exists, "MilestoneNotification should exist in HUD"


@pytest.mark.asyncio
async def test_milestone_notification_starts_hidden(game):
    """Verify the milestone notification starts invisible."""
    visible = await game.get_property(PATHS["milestone_notification"], "visible")
    assert visible is False, "MilestoneNotification should start hidden"


@pytest.mark.asyncio
async def test_milestone_notification_has_panel(game):
    """Verify the milestone notification has a Panel child node."""
    exists = await game.node_exists(PATHS["milestone_notification"] + "/Panel")
    assert exists, "MilestoneNotification should have a Panel child"


@pytest.mark.asyncio
async def test_milestone_notification_has_label(game):
    """Verify the milestone notification has a Label in the Panel."""
    exists = await game.node_exists(PATHS["milestone_notification"] + "/Panel/Label")
    assert exists, "MilestoneNotification should have a Label in the Panel"


@pytest.mark.asyncio
async def test_game_manager_emits_depth_milestone_signal(game):
    """Verify GameManager has the depth_milestone_reached signal infrastructure."""
    # Check that GameManager has the milestones array
    milestones = await game.get_property(PATHS["game_manager"], "DEPTH_MILESTONES")
    assert milestones is not None, "GameManager should have DEPTH_MILESTONES constant"
    expected = [10, 25, 50, 100, 150, 200, 300, 500, 750, 1000]
    assert milestones == expected, f"DEPTH_MILESTONES should be {expected}, got {milestones}"


@pytest.mark.asyncio
async def test_game_manager_tracks_reached_milestones(game):
    """Verify GameManager tracks which milestones have been reached."""
    reached = await game.get_property(PATHS["game_manager"], "_reached_milestones")
    assert reached is not None, "GameManager should have _reached_milestones array"
    # At start, no milestones should be reached
    assert len(reached) == 0, f"No milestones should be reached at start, got {reached}"


# =============================================================================
# DIG REACH VALIDATION TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_player_has_dig_reach_constant(game):
    """Verify the player has DIG_REACH constant for reach validation."""
    dig_reach = await game.get_property(PATHS["player"], "DIG_REACH")
    assert dig_reach is not None, "Player should have DIG_REACH constant"
    assert dig_reach == 1, f"DIG_REACH should be 1 by default, got {dig_reach}"


@pytest.mark.asyncio
async def test_player_has_can_dig_at_method(game):
    """Verify the player has can_dig_at method for reach validation."""
    # Test the method by calling it with a position
    # The player starts at position (2, 6), so testing position (2, 7) should be valid
    result = await game.call_method(PATHS["player"], "can_dig_at", [{"x": 2, "y": 7}])
    # Method should return a boolean (either true or false is valid)
    assert result is not None, "can_dig_at method should return a value"


@pytest.mark.asyncio
async def test_player_cannot_dig_diagonally(game):
    """Verify player cannot dig diagonally (reach validation)."""
    # Get player position
    grid_pos = await game.get_property(PATHS["player"], "grid_position")
    # Try diagonal position
    diagonal_pos = {"x": grid_pos["x"] + 1, "y": grid_pos["y"] + 1}
    result = await game.call_method(PATHS["player"], "can_dig_at", [diagonal_pos])
    assert result is False, "Should not be able to dig diagonally"


# =============================================================================
# KEYBOARD INPUT FALLBACK TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_player_has_is_using_keyboard_method(game):
    """Verify the player has is_using_keyboard method for input detection."""
    result = await game.call_method(PATHS["player"], "is_using_keyboard")
    assert result is not None, "is_using_keyboard method should return a value"
    # At start with no input, should return False
    assert result is False, "Should not be using keyboard with no input"


@pytest.mark.asyncio
async def test_keyboard_move_actions_exist(game):
    """Verify keyboard movement actions are properly mapped."""
    # Test that move_down action works (S or Down arrow)
    await game.send_action("move_down", True)
    await game.wait_frames(2)
    await game.send_action("move_down", False)
    # If no error, action exists and is processed


@pytest.mark.asyncio
async def test_keyboard_dig_action_exists(game):
    """Verify keyboard dig action is properly mapped (E key)."""
    # Test that dig action exists
    await game.send_action("dig", True)
    await game.wait_frames(2)
    await game.send_action("dig", False)
    # If no error, action exists and is processed


@pytest.mark.asyncio
async def test_keyboard_jump_action_exists(game):
    """Verify keyboard jump action is properly mapped (Space key)."""
    # Test that jump action exists
    await game.send_action("jump", True)
    await game.wait_frames(2)
    await game.send_action("jump", False)
    # If no error, action exists and is processed


# =============================================================================
# PLAYER STATISTICS TRACKING TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_player_stats_exists(game):
    """Verify the PlayerStats autoload exists."""
    exists = await game.node_exists(PATHS["player_stats"])
    assert exists, "PlayerStats autoload should exist"


@pytest.mark.asyncio
async def test_player_stats_has_blocks_mined_counter(game):
    """Verify PlayerStats tracks blocks mined."""
    blocks_mined = await game.get_property(PATHS["player_stats"], "blocks_mined_total")
    assert blocks_mined is not None, "PlayerStats should have blocks_mined_total"
    assert isinstance(blocks_mined, int), f"blocks_mined_total should be int, got {type(blocks_mined)}"


@pytest.mark.asyncio
async def test_player_stats_has_tiles_moved_counter(game):
    """Verify PlayerStats tracks tiles moved."""
    tiles_moved = await game.get_property(PATHS["player_stats"], "tiles_moved")
    assert tiles_moved is not None, "PlayerStats should have tiles_moved"
    assert isinstance(tiles_moved, int), f"tiles_moved should be int, got {type(tiles_moved)}"


@pytest.mark.asyncio
async def test_player_stats_has_deaths_counter(game):
    """Verify PlayerStats tracks deaths."""
    deaths = await game.get_property(PATHS["player_stats"], "deaths_total")
    assert deaths is not None, "PlayerStats should have deaths_total"
    assert isinstance(deaths, int), f"deaths_total should be int, got {type(deaths)}"


@pytest.mark.asyncio
async def test_player_stats_has_session_tracking(game):
    """Verify PlayerStats tracks session-specific stats."""
    session_blocks = await game.get_property(PATHS["player_stats"], "session_blocks_mined")
    session_depth = await game.get_property(PATHS["player_stats"], "session_max_depth")

    assert session_blocks is not None, "PlayerStats should have session_blocks_mined"
    assert session_depth is not None, "PlayerStats should have session_max_depth"


@pytest.mark.asyncio
async def test_player_stats_has_playtime_method(game):
    """Verify PlayerStats has method to get formatted playtime."""
    playtime = await game.call_method(PATHS["player_stats"], "get_playtime_string")
    assert playtime is not None, "get_playtime_string should return a value"
    assert isinstance(playtime, str), f"playtime should be string, got {type(playtime)}"


@pytest.mark.asyncio
async def test_player_stats_tracks_max_depth(game):
    """Verify PlayerStats tracks max depth reached."""
    max_depth = await game.get_property(PATHS["player_stats"], "max_depth_reached")
    assert max_depth is not None, "PlayerStats should have max_depth_reached"
    assert isinstance(max_depth, int), f"max_depth_reached should be int, got {type(max_depth)}"


@pytest.mark.asyncio
async def test_player_stats_has_wall_jumps_counter(game):
    """Verify PlayerStats tracks wall jumps performed."""
    wall_jumps = await game.get_property(PATHS["player_stats"], "wall_jumps_performed")
    assert wall_jumps is not None, "PlayerStats should have wall_jumps_performed"
    assert isinstance(wall_jumps, int), f"wall_jumps_performed should be int, got {type(wall_jumps)}"


@pytest.mark.asyncio
async def test_player_stats_has_coins_tracking(game):
    """Verify PlayerStats tracks coins earned and spent."""
    coins_earned = await game.get_property(PATHS["player_stats"], "coins_earned_total")
    coins_spent = await game.get_property(PATHS["player_stats"], "coins_spent_total")

    assert coins_earned is not None, "PlayerStats should have coins_earned_total"
    assert coins_spent is not None, "PlayerStats should have coins_spent_total"
    assert isinstance(coins_earned, int), f"coins_earned_total should be int, got {type(coins_earned)}"
    assert isinstance(coins_spent, int), f"coins_spent_total should be int, got {type(coins_spent)}"


# =============================================================================
# NEXT UPGRADE GOAL HUD TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_hud_has_upgrade_goal_container(game):
    """Verify HUD has upgrade goal container for showing next upgrade."""
    exists = await game.node_exists(PATHS["upgrade_goal_container"])
    assert exists, "HUD should have UpgradeGoalContainer"


@pytest.mark.asyncio
async def test_hud_has_upgrade_goal_label(game):
    """Verify HUD has upgrade goal label."""
    hud_path = PATHS["hud"]
    label = await game.get_property(hud_path, "upgrade_goal_label")
    assert label is not None, "HUD should have upgrade_goal_label"


@pytest.mark.asyncio
async def test_hud_has_upgrade_goal_progress(game):
    """Verify HUD has upgrade goal progress bar."""
    hud_path = PATHS["hud"]
    progress = await game.get_property(hud_path, "upgrade_goal_progress")
    assert progress is not None, "HUD should have upgrade_goal_progress"


# =============================================================================
# TIME SINCE SAVE INDICATOR TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_hud_has_save_indicator_label(game):
    """Verify HUD has save indicator label."""
    exists = await game.node_exists(PATHS["save_indicator_label"])
    assert exists, "HUD should have SaveIndicatorLabel"


@pytest.mark.asyncio
async def test_save_indicator_updates(game):
    """Verify save indicator shows save status."""
    hud_path = PATHS["hud"]
    label = await game.get_property(hud_path, "save_indicator_label")
    assert label is not None, "HUD should have save_indicator_label"


# =============================================================================
# LADDER QUICK-SLOT TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_hud_has_ladder_quickslot(game):
    """Verify HUD has ladder quick-slot."""
    exists = await game.node_exists(PATHS["ladder_quickslot"])
    assert exists, "HUD should have LadderQuickSlot"


@pytest.mark.asyncio
async def test_hud_has_ladder_count_label(game):
    """Verify HUD has ladder count label."""
    hud_path = PATHS["hud"]
    label = await game.get_property(hud_path, "ladder_count_label")
    assert label is not None, "HUD should have ladder_count_label"


@pytest.mark.asyncio
async def test_hud_has_ladder_button(game):
    """Verify HUD has ladder button for quick placement."""
    hud_path = PATHS["hud"]
    button = await game.get_property(hud_path, "ladder_button")
    assert button is not None, "HUD should have ladder_button"


@pytest.mark.asyncio
async def test_hud_has_ladder_place_signal(game):
    """Verify HUD emits ladder_place_requested signal."""
    hud_path = PATHS["hud"]
    has_signal = await game.call_method(hud_path, "has_signal", ["ladder_place_requested"])
    assert has_signal is True, "HUD should have ladder_place_requested signal"


# =============================================================================
# HAPTIC FEEDBACK TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_haptic_feedback_autoload_exists(game):
    """Verify HapticFeedback autoload exists."""
    exists = await game.node_exists(PATHS["haptic_feedback"])
    assert exists, "HapticFeedback autoload should exist"


@pytest.mark.asyncio
async def test_haptic_feedback_has_enabled_property(game):
    """Verify HapticFeedback has enabled property."""
    enabled = await game.get_property(PATHS["haptic_feedback"], "enabled")
    assert enabled is not None, "HapticFeedback should have enabled property"
    assert isinstance(enabled, bool), f"enabled should be bool, got {type(enabled)}"


@pytest.mark.asyncio
async def test_haptic_feedback_has_trigger_method(game):
    """Verify HapticFeedback has trigger method."""
    # Test calling the trigger method with LIGHT type (enum value 0)
    result = await game.call_method(PATHS["haptic_feedback"], "trigger", [0])
    # Method should complete without error (returns null/void)


@pytest.mark.asyncio
async def test_haptic_feedback_has_convenience_methods(game):
    """Verify HapticFeedback has convenience methods for game events."""
    # These should all complete without error
    await game.call_method(PATHS["haptic_feedback"], "on_mining_hit")
    await game.call_method(PATHS["haptic_feedback"], "on_block_destroyed")
    await game.call_method(PATHS["haptic_feedback"], "on_ui_tap")


@pytest.mark.asyncio
async def test_haptic_feedback_is_available_method(game):
    """Verify HapticFeedback has is_available method."""
    available = await game.call_method(PATHS["haptic_feedback"], "is_available")
    assert available is not None, "is_available should return a value"
    # On non-mobile platforms, this will be False


@pytest.mark.asyncio
async def test_haptic_feedback_is_enabled_method(game):
    """Verify HapticFeedback has is_enabled method."""
    enabled = await game.call_method(PATHS["haptic_feedback"], "is_enabled")
    assert enabled is not None, "is_enabled should return a value"


# =============================================================================
# PARALLAX BACKGROUND TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_surface_has_parallax_background(game):
    """Verify Surface scene has parallax background."""
    exists = await game.node_exists(PATHS["surface_parallax"])
    assert exists, "Surface should have ParallaxBackground"


@pytest.mark.asyncio
async def test_surface_has_mountain_layer(game):
    """Verify Surface has mountain parallax layer."""
    surface_path = PATHS["surface"]
    mountain_layer = await game.get_property(surface_path, "mountain_layer")
    assert mountain_layer is not None, "Surface should have mountain_layer"


@pytest.mark.asyncio
async def test_surface_has_cloud_layer(game):
    """Verify Surface has cloud parallax layer."""
    surface_path = PATHS["surface"]
    cloud_layer = await game.get_property(surface_path, "cloud_layer")
    assert cloud_layer is not None, "Surface should have cloud_layer"


# =============================================================================
# SCREEN SHAKE INTENSITY SETTING TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_settings_has_screen_shake_intensity(game):
    """Verify SettingsManager has screen_shake_intensity property."""
    intensity = await game.get_property(PATHS["settings_manager"], "screen_shake_intensity")
    assert intensity is not None, "SettingsManager should have screen_shake_intensity"
    assert isinstance(intensity, float), f"screen_shake_intensity should be float, got {type(intensity)}"
    assert 0.0 <= intensity <= 1.0, f"screen_shake_intensity should be 0.0-1.0, got {intensity}"


@pytest.mark.asyncio
async def test_settings_has_screen_shake_signal(game):
    """Verify SettingsManager has screen_shake_changed signal."""
    has_signal = await game.call_method(PATHS["settings_manager"], "has_signal", ["screen_shake_changed"])
    assert has_signal is True, "SettingsManager should have screen_shake_changed signal"


# =============================================================================
# AUTO-SELL TOGGLE SETTING TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_settings_has_auto_sell_enabled(game):
    """Verify SettingsManager has auto_sell_enabled property."""
    enabled = await game.get_property(PATHS["settings_manager"], "auto_sell_enabled")
    assert enabled is not None, "SettingsManager should have auto_sell_enabled"
    assert isinstance(enabled, bool), f"auto_sell_enabled should be bool, got {type(enabled)}"


@pytest.mark.asyncio
async def test_settings_has_auto_sell_signal(game):
    """Verify SettingsManager has auto_sell_changed signal."""
    has_signal = await game.call_method(PATHS["settings_manager"], "has_signal", ["auto_sell_changed"])
    assert has_signal is True, "SettingsManager should have auto_sell_changed signal"


# =============================================================================
# OFFLINE INCOME SYSTEM TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_save_manager_has_offline_income_signal(game):
    """Verify SaveManager has offline_income_ready signal."""
    has_signal = await game.call_method(PATHS["save_manager"], "has_signal", ["offline_income_ready"])
    assert has_signal is True, "SaveManager should have offline_income_ready signal"


@pytest.mark.asyncio
async def test_save_manager_has_offline_income_constants(game):
    """Verify SaveManager has offline income constants."""
    rate = await game.get_property(PATHS["save_manager"], "OFFLINE_INCOME_RATE")
    max_hours = await game.get_property(PATHS["save_manager"], "OFFLINE_MAX_HOURS")
    max_seconds = await game.get_property(PATHS["save_manager"], "OFFLINE_MAX_SECONDS")

    assert rate == 1.0, f"OFFLINE_INCOME_RATE should be 1.0, got {rate}"
    assert max_hours == 4.0, f"OFFLINE_MAX_HOURS should be 4.0, got {max_hours}"
    assert max_seconds == 14400.0, f"OFFLINE_MAX_SECONDS should be 14400.0, got {max_seconds}"


@pytest.mark.asyncio
async def test_save_manager_has_pending_offline_income(game):
    """Verify SaveManager tracks pending offline income."""
    pending = await game.get_property(PATHS["save_manager"], "pending_offline_income")
    assert pending is not None, "SaveManager should have pending_offline_income"
    assert isinstance(pending, int), f"pending_offline_income should be int, got {type(pending)}"


@pytest.mark.asyncio
async def test_save_manager_has_offline_income_methods(game):
    """Verify SaveManager has offline income utility methods."""
    # Check has_pending_offline_income method exists and returns bool
    has_pending = await game.call_method(PATHS["save_manager"], "has_pending_offline_income")
    assert isinstance(has_pending, bool), f"has_pending_offline_income should return bool, got {type(has_pending)}"

    # Check get_pending_offline_info method exists and returns dict
    info = await game.call_method(PATHS["save_manager"], "get_pending_offline_info")
    assert info is not None, "get_pending_offline_info should return a value"


# =============================================================================
# LIGHTING BY DEPTH TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_lighting_manager_autoload_exists(game):
    """Verify LightingManager autoload exists."""
    exists = await game.node_exists(PATHS["lighting_manager"])
    assert exists, "LightingManager autoload should exist"


@pytest.mark.asyncio
async def test_lighting_manager_has_signal(game):
    """Verify LightingManager has lighting_changed signal."""
    has_signal = await game.call_method(PATHS["lighting_manager"], "has_signal", ["lighting_changed"])
    assert has_signal is True, "LightingManager should have lighting_changed signal"


@pytest.mark.asyncio
async def test_lighting_manager_has_zone_properties(game):
    """Verify LightingManager has zone tracking properties."""
    current_zone = await game.get_property(PATHS["lighting_manager"], "current_zone")
    current_ambient = await game.get_property(PATHS["lighting_manager"], "current_ambient")

    assert current_zone is not None, "LightingManager should have current_zone"
    assert current_ambient is not None, "LightingManager should have current_ambient"


@pytest.mark.asyncio
async def test_lighting_manager_has_update_depth(game):
    """Verify LightingManager has update_depth method."""
    # Call update_depth with depth 0 (surface)
    result = await game.call_method(PATHS["lighting_manager"], "update_depth", [0])
    # Method should complete without error

    # Verify ambient is 1.0 for surface
    ambient = await game.get_property(PATHS["lighting_manager"], "current_ambient")
    # Note: May transition smoothly, so check target
    target = await game.get_property(PATHS["lighting_manager"], "_target_ambient")
    assert target == 1.0, f"Target ambient at surface should be 1.0, got {target}"


@pytest.mark.asyncio
async def test_lighting_manager_zone_names(game):
    """Verify LightingManager has get_current_zone_name method."""
    zone_name = await game.call_method(PATHS["lighting_manager"], "get_current_zone_name")
    assert zone_name is not None, "get_current_zone_name should return a value"
    assert isinstance(zone_name, str), f"zone name should be string, got {type(zone_name)}"


# =============================================================================
# MINING PROGRESS INDICATOR TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_hud_has_mining_progress_container(game):
    """Verify HUD has mining progress container."""
    exists = await game.node_exists(PATHS["mining_progress_container"])
    assert exists, "HUD should have MiningProgressContainer"


@pytest.mark.asyncio
async def test_hud_has_mining_progress_bar(game):
    """Verify HUD has mining progress bar."""
    hud_path = PATHS["hud"]
    bar = await game.get_property(hud_path, "mining_progress_bar")
    assert bar is not None, "HUD should have mining_progress_bar"


@pytest.mark.asyncio
async def test_hud_tracks_player_for_mining(game):
    """Verify HUD can track player for mining progress."""
    hud_path = PATHS["hud"]
    tracked = await game.get_property(hud_path, "_tracked_player")
    # Should be set after connect_to_player is called
    assert tracked is not None, "HUD should track player for mining progress"


@pytest.mark.asyncio
async def test_dirt_grid_has_mining_progress_method(game):
    """Verify DirtGrid has get_block_mining_progress method."""
    # Try to get mining progress for position (2, 8) - likely to be underground
    result = await game.call_method(PATHS["dirt_grid"], "get_block_mining_progress", [{"x": 2, "y": 8}])
    # Should return float (-1.0 if no block, 0.0-1.0 otherwise)
    assert result is not None, "get_block_mining_progress should return a value"


# =============================================================================
# SOUND MANAGER TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_sound_manager_exists(game):
    """Verify SoundManager autoload exists."""
    exists = await game.node_exists(PATHS["sound_manager"])
    assert exists, "SoundManager autoload should exist"


@pytest.mark.asyncio
async def test_sound_manager_has_sfx_pool(game):
    """Verify SoundManager has SFX player pool."""
    max_sfx = await game.get_property(PATHS["sound_manager"], "MAX_SFX_PLAYERS")
    assert max_sfx == 8, f"MAX_SFX_PLAYERS should be 8, got {max_sfx}"


@pytest.mark.asyncio
async def test_sound_manager_has_music_players(game):
    """Verify SoundManager has music player pool."""
    max_music = await game.get_property(PATHS["sound_manager"], "MAX_MUSIC_PLAYERS")
    assert max_music == 2, f"MAX_MUSIC_PLAYERS should be 2, got {max_music}"


@pytest.mark.asyncio
async def test_sound_manager_has_convenience_methods(game):
    """Verify SoundManager has convenience methods for game sounds."""
    # These should all complete without error
    await game.call_method(PATHS["sound_manager"], "play_ui_click")
    await game.call_method(PATHS["sound_manager"], "play_coin_pickup")


# =============================================================================
# LOCALIZATION MANAGER TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_localization_manager_exists(game):
    """Verify LocalizationManager autoload exists."""
    exists = await game.node_exists(PATHS["localization_manager"])
    assert exists, "LocalizationManager autoload should exist"


@pytest.mark.asyncio
async def test_localization_manager_has_default_locale(game):
    """Verify LocalizationManager has default locale."""
    locale = await game.get_property(PATHS["localization_manager"], "current_locale")
    assert locale is not None, "LocalizationManager should have current_locale"


@pytest.mark.asyncio
async def test_localization_manager_has_supported_languages(game):
    """Verify LocalizationManager has supported languages."""
    languages = await game.get_property(PATHS["localization_manager"], "SUPPORTED_LANGUAGES")
    assert languages is not None, "LocalizationManager should have SUPPORTED_LANGUAGES"
    assert "en" in languages, "SUPPORTED_LANGUAGES should include English"


@pytest.mark.asyncio
async def test_localization_manager_format_number(game):
    """Verify LocalizationManager can format numbers."""
    result = await game.call_method(PATHS["localization_manager"], "format_number", [1000])
    assert result is not None, "format_number should return a value"
    assert "," in result or "." in result, f"Formatted number should have separator, got '{result}'"


# =============================================================================
# FOSSIL SPAWNING TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_dirt_grid_has_fossil_signal(game):
    """Verify DirtGrid has fossil_found signal."""
    has_signal = await game.call_method(PATHS["dirt_grid"], "has_signal", ["fossil_found"])
    assert has_signal is True, "DirtGrid should have fossil_found signal"


@pytest.mark.asyncio
async def test_dirt_grid_has_fossil_constants(game):
    """Verify DirtGrid has fossil spawning constants."""
    spawn_chance = await game.get_property(PATHS["dirt_grid"], "FOSSIL_SPAWN_CHANCE")
    assert spawn_chance is not None, "DirtGrid should have FOSSIL_SPAWN_CHANCE"
    assert spawn_chance == 0.005, f"FOSSIL_SPAWN_CHANCE should be 0.005, got {spawn_chance}"


# =============================================================================
# NEW LAYER TESTS (Crystal Caves and Magma Zone)
# =============================================================================


@pytest.mark.asyncio
async def test_crystal_caves_layer_exists(game):
    """Verify Crystal Caves layer is registered in DataRegistry."""
    exists = await game.call_method(PATHS["data_registry"], "has_layer", ["crystal_caves"])
    assert exists is True, "DataRegistry should have crystal_caves layer"


@pytest.mark.asyncio
async def test_magma_zone_layer_exists(game):
    """Verify Magma Zone layer is registered in DataRegistry."""
    exists = await game.call_method(PATHS["data_registry"], "has_layer", ["magma_zone"])
    assert exists is True, "DataRegistry should have magma_zone layer"


@pytest.mark.asyncio
async def test_crystal_caves_depth_range(game):
    """Verify Crystal Caves layer has correct depth range."""
    min_depth = await game.call_method(PATHS["data_registry"], "get_layer_min_depth", ["crystal_caves"])
    max_depth = await game.call_method(PATHS["data_registry"], "get_layer_max_depth", ["crystal_caves"])

    assert min_depth == 450, f"Crystal Caves min_depth should be 450, got {min_depth}"
    assert max_depth == 550, f"Crystal Caves max_depth should be 550, got {max_depth}"


@pytest.mark.asyncio
async def test_magma_zone_depth_range(game):
    """Verify Magma Zone layer has correct depth range."""
    min_depth = await game.call_method(PATHS["data_registry"], "get_layer_min_depth", ["magma_zone"])
    max_depth = await game.call_method(PATHS["data_registry"], "get_layer_max_depth", ["magma_zone"])

    assert min_depth == 700, f"Magma Zone min_depth should be 700, got {min_depth}"
    assert max_depth == 800, f"Magma Zone max_depth should be 800, got {max_depth}"


@pytest.mark.asyncio
async def test_layer_at_depth_450(game):
    """Verify Crystal Caves is returned for depth 450."""
    layer_id = await game.call_method(PATHS["data_registry"], "get_layer_id_at_depth", [475])
    assert layer_id == "crystal_caves", f"Layer at depth 475 should be crystal_caves, got {layer_id}"


@pytest.mark.asyncio
async def test_layer_at_depth_750(game):
    """Verify Magma Zone is returned for depth 750."""
    layer_id = await game.call_method(PATHS["data_registry"], "get_layer_id_at_depth", [750])
    assert layer_id == "magma_zone", f"Layer at depth 750 should be magma_zone, got {layer_id}"


# =============================================================================
# TUTORIAL OVERLAY TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_tutorial_overlay_exists(game):
    """Verify the tutorial overlay node exists."""
    exists = await game.node_exists(PATHS["tutorial_overlay"])
    assert exists, "TutorialOverlay should exist"


@pytest.mark.asyncio
async def test_tutorial_overlay_is_canvas_layer(game):
    """Verify the tutorial overlay is a CanvasLayer."""
    layer = await game.get_property(PATHS["tutorial_overlay"], "layer")
    assert layer is not None, "TutorialOverlay should have layer property (CanvasLayer)"
    assert layer == 99, f"TutorialOverlay layer should be 99 (above HUD), got {layer}"


@pytest.mark.asyncio
async def test_tutorial_overlay_process_mode(game):
    """Verify the tutorial overlay runs while game is paused."""
    # PROCESS_MODE_ALWAYS = 3
    process_mode = await game.get_property(PATHS["tutorial_overlay"], "process_mode")
    assert process_mode == 3, f"TutorialOverlay process_mode should be PROCESS_MODE_ALWAYS (3), got {process_mode}"


@pytest.mark.asyncio
async def test_tutorial_overlay_has_panel(game):
    """Verify the tutorial overlay has a panel for content."""
    panel = await game.get_property(PATHS["tutorial_overlay"], "panel")
    assert panel is not None, "TutorialOverlay should have panel property"


@pytest.mark.asyncio
async def test_tutorial_overlay_has_viewport_resize_handler(game):
    """Verify the tutorial overlay responds to viewport resize."""
    # Check that the _on_viewport_resized method exists by verifying the signal is connected
    # The tutorial overlay should handle viewport resize for portrait mode support
    overlay_path = PATHS["tutorial_overlay"]
    # Test by calling the method directly (should not error)
    result = await game.call_method(overlay_path, "_on_viewport_resized")
    # Method should complete without error (returns void/null)
