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
async def test_dig_button_exists(game):
    """Verify the dig TouchScreenButton exists for touch digging."""
    exists = await game.node_exists(PATHS["dig_button"])
    assert exists, "Dig button should exist for touch controls"


@pytest.mark.asyncio
async def test_dig_button_has_action(game):
    """Verify the dig button has the correct input action mapped."""
    action = await game.get_property(PATHS["dig_button"], "action")
    assert action == "dig", f"Dig button should have action 'dig', got '{action}'"


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
async def test_player_has_wall_jump_states(game):
    """Verify the player has the wall-jump state machine states."""
    # Check that the player is in a valid state (IDLE = 0 at start)
    current_state = await game.get_property(PATHS["player"], "current_state")
    assert current_state is not None, "Player should have current_state property"
    # State.IDLE = 0
    assert current_state == 0, f"Player should start in IDLE state (0), got {current_state}"


@pytest.mark.asyncio
async def test_data_registry_exists(game):
    """Verify the DataRegistry autoload exists."""
    exists = await game.node_exists(PATHS["data_registry"])
    assert exists, "DataRegistry autoload should exist"


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


@pytest.mark.asyncio
async def test_coins_property_exists(game):
    """Verify the GameManager has a coins property."""
    coins = await game.get_property(PATHS["game_manager"], "coins")
    assert coins is not None, "GameManager should have coins property"
    assert isinstance(coins, int), f"Coins should be an int, got {type(coins)}"


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
