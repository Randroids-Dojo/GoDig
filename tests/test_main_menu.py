"""
Main Menu integration tests.

Tests the main menu scene including:
- UI elements display correctly
- New Game button starts a new game
- Continue button visibility based on save status
- Settings button opens settings
"""
import pytest
from helpers import MAIN_MENU_PATHS


# =============================================================================
# MAIN MENU SCENE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_main_menu_loads(main_menu):
    """Main menu scene loads as the initial scene."""
    exists = await main_menu.node_exists(MAIN_MENU_PATHS["main_menu"])
    assert exists, "MainMenu root node should exist"


@pytest.mark.asyncio
async def test_main_menu_has_title(main_menu):
    """Main menu displays the game title."""
    exists = await main_menu.node_exists(MAIN_MENU_PATHS["main_menu_title"])
    assert exists, "Title label should exist"


@pytest.mark.asyncio
async def test_main_menu_title_text(main_menu):
    """Main menu title shows 'GoDig'."""
    text = await main_menu.get_property(MAIN_MENU_PATHS["main_menu_title"], "text")
    assert text == "GoDig", f"Title should be 'GoDig', got '{text}'"


@pytest.mark.asyncio
async def test_main_menu_has_subtitle(main_menu):
    """Main menu has a subtitle label."""
    exists = await main_menu.node_exists(MAIN_MENU_PATHS["main_menu_subtitle"])
    assert exists, "Subtitle label should exist"


@pytest.mark.asyncio
async def test_main_menu_has_new_game_button(main_menu):
    """Main menu has a New Game button."""
    exists = await main_menu.node_exists(MAIN_MENU_PATHS["main_menu_new_game"])
    assert exists, "New Game button should exist"


@pytest.mark.asyncio
async def test_main_menu_new_game_button_text(main_menu):
    """New Game button has correct text."""
    text = await main_menu.get_property(MAIN_MENU_PATHS["main_menu_new_game"], "text")
    assert text == "New Game", f"Button text should be 'New Game', got '{text}'"


@pytest.mark.asyncio
async def test_main_menu_has_continue_button(main_menu):
    """Main menu has a Continue button."""
    exists = await main_menu.node_exists(MAIN_MENU_PATHS["main_menu_continue"])
    assert exists, "Continue button should exist"


@pytest.mark.asyncio
async def test_main_menu_continue_button_text(main_menu):
    """Continue button has correct text."""
    text = await main_menu.get_property(MAIN_MENU_PATHS["main_menu_continue"], "text")
    assert text == "Continue", f"Button text should be 'Continue', got '{text}'"


@pytest.mark.asyncio
async def test_main_menu_has_settings_button(main_menu):
    """Main menu has a Settings button."""
    exists = await main_menu.node_exists(MAIN_MENU_PATHS["main_menu_settings"])
    assert exists, "Settings button should exist"


@pytest.mark.asyncio
async def test_main_menu_settings_button_text(main_menu):
    """Settings button has correct text."""
    text = await main_menu.get_property(MAIN_MENU_PATHS["main_menu_settings"], "text")
    assert text == "Settings", f"Button text should be 'Settings', got '{text}'"


@pytest.mark.asyncio
async def test_main_menu_has_version_label(main_menu):
    """Main menu shows version number."""
    exists = await main_menu.node_exists(MAIN_MENU_PATHS["main_menu_version"])
    assert exists, "Version label should exist"


@pytest.mark.asyncio
async def test_main_menu_version_has_v_prefix(main_menu):
    """Version label starts with 'v'."""
    text = await main_menu.get_property(MAIN_MENU_PATHS["main_menu_version"], "text")
    assert text.startswith("v"), f"Version should start with 'v', got '{text}'"


@pytest.mark.asyncio
async def test_main_menu_is_visible(main_menu):
    """MainMenu root node is visible."""
    visible = await main_menu.get_property(MAIN_MENU_PATHS["main_menu"], "visible")
    assert visible, "MainMenu should be visible"


@pytest.mark.asyncio
async def test_main_menu_buttons_are_visible(main_menu):
    """All main menu buttons should be visible (except Continue without saves)."""
    # New Game should always be visible
    new_game_visible = await main_menu.get_property(MAIN_MENU_PATHS["main_menu_new_game"], "visible")
    assert new_game_visible, "New Game button should be visible"

    # Settings should always be visible
    settings_visible = await main_menu.get_property(MAIN_MENU_PATHS["main_menu_settings"], "visible")
    assert settings_visible, "Settings button should be visible"


# =============================================================================
# GAME SCENE TESTS (verify game fixture properly loads scene)
# These tests require imported resources (terrain_atlas.png) which need
# .NET SDK for the Godot mono build's import process.
# =============================================================================

@pytest.mark.asyncio
@pytest.mark.xfail(reason="Requires imported resources - needs .NET SDK for import")
async def test_game_scene_loads_via_change_scene(game):
    """Game scene loads when navigating from main menu."""
    exists = await game.node_exists("/root/Main")
    assert exists, "Game scene should load"


@pytest.mark.asyncio
@pytest.mark.xfail(reason="Requires imported resources - needs .NET SDK for import")
async def test_game_scene_has_player(game):
    """Game scene contains the player."""
    exists = await game.node_exists("/root/Main/Player")
    assert exists, "Player should exist in game scene"


# =============================================================================
# SETTINGS MANAGER INTEGRATION TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_settings_manager_exists(main_menu):
    """SettingsManager autoload should be available."""
    exists = await main_menu.node_exists("/root/SettingsManager")
    assert exists, "SettingsManager should exist as autoload"


@pytest.mark.asyncio
async def test_settings_manager_accessibility_properties(main_menu):
    """SettingsManager should have accessibility settings."""
    # Text size
    text_size = await main_menu.get_property("/root/SettingsManager", "text_size_level")
    assert text_size is not None, "text_size_level should exist"
    assert isinstance(text_size, int), "text_size_level should be an integer"

    # Haptics
    haptics = await main_menu.get_property("/root/SettingsManager", "haptics_enabled")
    assert haptics is not None, "haptics_enabled should exist"
    assert isinstance(haptics, bool), "haptics_enabled should be a boolean"

    # Reduced motion
    reduced_motion = await main_menu.get_property("/root/SettingsManager", "reduced_motion")
    assert reduced_motion is not None, "reduced_motion should exist"
    assert isinstance(reduced_motion, bool), "reduced_motion should be a boolean"


@pytest.mark.asyncio
async def test_settings_manager_control_properties(main_menu):
    """SettingsManager should have control settings."""
    # Tap-to-dig
    tap_to_dig = await main_menu.get_property("/root/SettingsManager", "tap_to_dig_enabled")
    assert tap_to_dig is not None, "tap_to_dig_enabled should exist"
    assert isinstance(tap_to_dig, bool), "tap_to_dig_enabled should be a boolean"

    # Swipe controls
    swipe = await main_menu.get_property("/root/SettingsManager", "swipe_controls_enabled")
    assert swipe is not None, "swipe_controls_enabled should exist"
    assert isinstance(swipe, bool), "swipe_controls_enabled should be a boolean"

    # Joystick deadzone
    deadzone = await main_menu.get_property("/root/SettingsManager", "joystick_deadzone")
    assert deadzone is not None, "joystick_deadzone should exist"
    assert 0.0 <= deadzone <= 0.5, f"joystick_deadzone should be 0.0-0.5, got {deadzone}"


@pytest.mark.asyncio
async def test_settings_manager_gameplay_properties(main_menu):
    """SettingsManager should have gameplay settings."""
    # Peaceful mode
    peaceful = await main_menu.get_property("/root/SettingsManager", "peaceful_mode")
    assert peaceful is not None, "peaceful_mode should exist"
    assert isinstance(peaceful, bool), "peaceful_mode should be a boolean"

    # Auto-sell
    auto_sell = await main_menu.get_property("/root/SettingsManager", "auto_sell_enabled")
    assert auto_sell is not None, "auto_sell_enabled should exist"
    assert isinstance(auto_sell, bool), "auto_sell_enabled should be a boolean"


@pytest.mark.asyncio
async def test_settings_manager_audio_properties(main_menu):
    """SettingsManager should have audio settings."""
    # Master volume
    master = await main_menu.get_property("/root/SettingsManager", "master_volume")
    assert master is not None, "master_volume should exist"
    assert 0.0 <= master <= 1.0, f"master_volume should be 0.0-1.0, got {master}"

    # SFX volume
    sfx = await main_menu.get_property("/root/SettingsManager", "sfx_volume")
    assert sfx is not None, "sfx_volume should exist"
    assert 0.0 <= sfx <= 1.0, f"sfx_volume should be 0.0-1.0, got {sfx}"

    # Music volume
    music = await main_menu.get_property("/root/SettingsManager", "music_volume")
    assert music is not None, "music_volume should exist"
    assert 0.0 <= music <= 1.0, f"music_volume should be 0.0-1.0, got {music}"

    # Tension audio
    tension = await main_menu.get_property("/root/SettingsManager", "tension_audio_enabled")
    assert tension is not None, "tension_audio_enabled should exist"
    assert isinstance(tension, bool), "tension_audio_enabled should be a boolean"


@pytest.mark.asyncio
async def test_settings_manager_juice_level(main_menu):
    """SettingsManager should have juice level setting."""
    juice = await main_menu.get_property("/root/SettingsManager", "juice_level")
    assert juice is not None, "juice_level should exist"
    # JuiceLevel enum: OFF=0, LOW=1, MEDIUM=2, HIGH=3
    assert 0 <= juice <= 3, f"juice_level should be 0-3, got {juice}"


@pytest.mark.asyncio
async def test_settings_manager_screen_shake(main_menu):
    """SettingsManager should have screen shake intensity setting."""
    shake = await main_menu.get_property("/root/SettingsManager", "screen_shake_intensity")
    assert shake is not None, "screen_shake_intensity should exist"
    assert 0.0 <= shake <= 1.0, f"screen_shake_intensity should be 0.0-1.0, got {shake}"


@pytest.mark.asyncio
async def test_settings_manager_colorblind_mode(main_menu):
    """SettingsManager should have colorblind mode setting."""
    mode = await main_menu.get_property("/root/SettingsManager", "colorblind_mode")
    assert mode is not None, "colorblind_mode should exist"
    # ColorblindMode enum: OFF=0, SYMBOLS=1, HIGH_CONTRAST=2
    assert 0 <= mode <= 2, f"colorblind_mode should be 0-2, got {mode}"


@pytest.mark.asyncio
async def test_settings_manager_hand_mode(main_menu):
    """SettingsManager should have hand mode setting."""
    mode = await main_menu.get_property("/root/SettingsManager", "hand_mode")
    assert mode is not None, "hand_mode should exist"
    # HandMode enum: STANDARD=0, LEFT_HAND=1, RIGHT_HAND=2
    assert 0 <= mode <= 2, f"hand_mode should be 0-2, got {mode}"
