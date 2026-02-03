"""
SettingsManager tests for GoDig endless digging game.

Tests verify that SettingsManager:
1. Exists as an autoload singleton
2. Has all required settings properties
3. Emits signals when settings change
4. Properly validates and clamps values
"""
import pytest
from helpers import PATHS


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_settings_manager_exists(game):
    """SettingsManager autoload should exist."""
    result = await game.node_exists(PATHS["settings_manager"])
    assert result.get("exists") is True, "SettingsManager autoload should exist"


# =============================================================================
# TEXT SIZE SETTINGS
# =============================================================================

@pytest.mark.asyncio
async def test_settings_has_text_size_level(game):
    """SettingsManager should have text_size_level property."""
    level = await game.get_property(PATHS["settings_manager"], "text_size_level")
    assert level is not None, "text_size_level should exist"
    assert isinstance(level, int), f"text_size_level should be int, got {type(level)}"


@pytest.mark.asyncio
async def test_settings_text_size_level_default(game):
    """text_size_level should default to 1 (100% scale)."""
    level = await game.get_property(PATHS["settings_manager"], "text_size_level")
    # Default is 1 which maps to TEXT_SCALES[1] = 1.0
    assert level == 1, f"text_size_level should default to 1, got {level}"


@pytest.mark.asyncio
async def test_settings_get_text_scale(game):
    """get_text_scale() should return the current scale multiplier."""
    scale = await game.call(PATHS["settings_manager"], "get_text_scale")
    assert scale is not None, "get_text_scale should return a value"
    assert isinstance(scale, (int, float)), f"get_text_scale should return number, got {type(scale)}"
    assert 0.5 <= scale <= 2.5, f"Text scale should be reasonable, got {scale}"


@pytest.mark.asyncio
async def test_settings_get_text_scale_options(game):
    """get_text_scale_options() should return available scale options."""
    options = await game.call(PATHS["settings_manager"], "get_text_scale_options")
    assert options is not None, "get_text_scale_options should return a value"
    assert isinstance(options, list), f"get_text_scale_options should return array, got {type(options)}"
    assert len(options) >= 3, f"Should have at least 3 text scale options, got {len(options)}"


# =============================================================================
# COLORBLIND MODE SETTINGS
# =============================================================================

@pytest.mark.asyncio
async def test_settings_has_colorblind_mode(game):
    """SettingsManager should have colorblind_mode property."""
    mode = await game.get_property(PATHS["settings_manager"], "colorblind_mode")
    assert mode is not None, "colorblind_mode should exist"
    assert isinstance(mode, int), f"colorblind_mode should be int (enum), got {type(mode)}"


@pytest.mark.asyncio
async def test_settings_colorblind_mode_default(game):
    """colorblind_mode should default to 0 (OFF)."""
    mode = await game.get_property(PATHS["settings_manager"], "colorblind_mode")
    # Default is ColorblindMode.OFF = 0
    assert mode == 0, f"colorblind_mode should default to 0 (OFF), got {mode}"


# =============================================================================
# HAND MODE SETTINGS
# =============================================================================

@pytest.mark.asyncio
async def test_settings_has_hand_mode(game):
    """SettingsManager should have hand_mode property."""
    mode = await game.get_property(PATHS["settings_manager"], "hand_mode")
    assert mode is not None, "hand_mode should exist"
    assert isinstance(mode, int), f"hand_mode should be int (enum), got {type(mode)}"


@pytest.mark.asyncio
async def test_settings_hand_mode_default(game):
    """hand_mode should default to 0 (STANDARD)."""
    mode = await game.get_property(PATHS["settings_manager"], "hand_mode")
    # Default is HandMode.STANDARD = 0
    assert mode == 0, f"hand_mode should default to 0 (STANDARD), got {mode}"


# =============================================================================
# HAPTIC FEEDBACK SETTINGS
# =============================================================================

@pytest.mark.asyncio
async def test_settings_has_haptics_enabled(game):
    """SettingsManager should have haptics_enabled property."""
    enabled = await game.get_property(PATHS["settings_manager"], "haptics_enabled")
    assert enabled is not None, "haptics_enabled should exist"
    assert isinstance(enabled, bool), f"haptics_enabled should be bool, got {type(enabled)}"


@pytest.mark.asyncio
async def test_settings_haptics_enabled_default(game):
    """haptics_enabled should default to true."""
    enabled = await game.get_property(PATHS["settings_manager"], "haptics_enabled")
    assert enabled is True, f"haptics_enabled should default to True, got {enabled}"


# =============================================================================
# REDUCED MOTION SETTINGS
# =============================================================================

@pytest.mark.asyncio
async def test_settings_has_reduced_motion(game):
    """SettingsManager should have reduced_motion property."""
    enabled = await game.get_property(PATHS["settings_manager"], "reduced_motion")
    assert enabled is not None, "reduced_motion should exist"
    assert isinstance(enabled, bool), f"reduced_motion should be bool, got {type(enabled)}"


@pytest.mark.asyncio
async def test_settings_reduced_motion_default(game):
    """reduced_motion should default to false."""
    enabled = await game.get_property(PATHS["settings_manager"], "reduced_motion")
    assert enabled is False, f"reduced_motion should default to False, got {enabled}"


# =============================================================================
# SCREEN SHAKE SETTINGS
# =============================================================================

@pytest.mark.asyncio
async def test_settings_has_screen_shake_intensity(game):
    """SettingsManager should have screen_shake_intensity property."""
    intensity = await game.get_property(PATHS["settings_manager"], "screen_shake_intensity")
    assert intensity is not None, "screen_shake_intensity should exist"
    assert isinstance(intensity, (int, float)), f"screen_shake_intensity should be number, got {type(intensity)}"


@pytest.mark.asyncio
async def test_settings_screen_shake_intensity_default(game):
    """screen_shake_intensity should default to 1.0."""
    intensity = await game.get_property(PATHS["settings_manager"], "screen_shake_intensity")
    assert intensity == 1.0, f"screen_shake_intensity should default to 1.0, got {intensity}"


@pytest.mark.asyncio
async def test_settings_screen_shake_intensity_range(game):
    """screen_shake_intensity should be clamped between 0.0 and 1.0."""
    intensity = await game.get_property(PATHS["settings_manager"], "screen_shake_intensity")
    assert 0.0 <= intensity <= 1.0, f"screen_shake_intensity should be 0.0-1.0, got {intensity}"


# =============================================================================
# JUICE LEVEL SETTINGS
# =============================================================================

@pytest.mark.asyncio
async def test_settings_has_juice_level(game):
    """SettingsManager should have juice_level property."""
    level = await game.get_property(PATHS["settings_manager"], "juice_level")
    assert level is not None, "juice_level should exist"
    assert isinstance(level, int), f"juice_level should be int (enum), got {type(level)}"


@pytest.mark.asyncio
async def test_settings_juice_level_default(game):
    """juice_level should default to 2 (MEDIUM)."""
    level = await game.get_property(PATHS["settings_manager"], "juice_level")
    # Default is JuiceLevel.MEDIUM = 2
    assert level == 2, f"juice_level should default to 2 (MEDIUM), got {level}"


@pytest.mark.asyncio
async def test_settings_get_particle_multiplier(game):
    """get_particle_multiplier() should return multiplier based on juice level."""
    multiplier = await game.call(PATHS["settings_manager"], "get_particle_multiplier")
    assert multiplier is not None, "get_particle_multiplier should return a value"
    assert isinstance(multiplier, (int, float)), f"get_particle_multiplier should return number, got {type(multiplier)}"
    # MEDIUM juice should return 1.0
    assert multiplier == 1.0, f"MEDIUM juice should have 1.0 multiplier, got {multiplier}"


@pytest.mark.asyncio
async def test_settings_get_shake_multiplier(game):
    """get_shake_multiplier() should return multiplier based on juice level."""
    multiplier = await game.call(PATHS["settings_manager"], "get_shake_multiplier")
    assert multiplier is not None, "get_shake_multiplier should return a value"
    assert isinstance(multiplier, (int, float)), f"get_shake_multiplier should return number, got {type(multiplier)}"
    # MEDIUM juice should return 1.0
    assert multiplier == 1.0, f"MEDIUM juice should have 1.0 multiplier, got {multiplier}"


# =============================================================================
# AUTO-SELL SETTINGS
# =============================================================================

@pytest.mark.asyncio
async def test_settings_has_auto_sell_enabled(game):
    """SettingsManager should have auto_sell_enabled property."""
    enabled = await game.get_property(PATHS["settings_manager"], "auto_sell_enabled")
    assert enabled is not None, "auto_sell_enabled should exist"
    assert isinstance(enabled, bool), f"auto_sell_enabled should be bool, got {type(enabled)}"


@pytest.mark.asyncio
async def test_settings_auto_sell_enabled_default(game):
    """auto_sell_enabled should default to false."""
    enabled = await game.get_property(PATHS["settings_manager"], "auto_sell_enabled")
    assert enabled is False, f"auto_sell_enabled should default to False, got {enabled}"


# =============================================================================
# AUDIO SETTINGS
# =============================================================================

@pytest.mark.asyncio
async def test_settings_has_master_volume(game):
    """SettingsManager should have master_volume property."""
    volume = await game.get_property(PATHS["settings_manager"], "master_volume")
    assert volume is not None, "master_volume should exist"
    assert isinstance(volume, (int, float)), f"master_volume should be number, got {type(volume)}"


@pytest.mark.asyncio
async def test_settings_master_volume_default(game):
    """master_volume should default to 1.0."""
    volume = await game.get_property(PATHS["settings_manager"], "master_volume")
    assert volume == 1.0, f"master_volume should default to 1.0, got {volume}"


@pytest.mark.asyncio
async def test_settings_has_sfx_volume(game):
    """SettingsManager should have sfx_volume property."""
    volume = await game.get_property(PATHS["settings_manager"], "sfx_volume")
    assert volume is not None, "sfx_volume should exist"
    assert isinstance(volume, (int, float)), f"sfx_volume should be number, got {type(volume)}"


@pytest.mark.asyncio
async def test_settings_sfx_volume_default(game):
    """sfx_volume should default to 1.0."""
    volume = await game.get_property(PATHS["settings_manager"], "sfx_volume")
    assert volume == 1.0, f"sfx_volume should default to 1.0, got {volume}"


@pytest.mark.asyncio
async def test_settings_has_music_volume(game):
    """SettingsManager should have music_volume property."""
    volume = await game.get_property(PATHS["settings_manager"], "music_volume")
    assert volume is not None, "music_volume should exist"
    assert isinstance(volume, (int, float)), f"music_volume should be number, got {type(volume)}"


@pytest.mark.asyncio
async def test_settings_music_volume_default(game):
    """music_volume should default to 1.0."""
    volume = await game.get_property(PATHS["settings_manager"], "music_volume")
    assert volume == 1.0, f"music_volume should default to 1.0, got {volume}"


@pytest.mark.asyncio
async def test_settings_has_tension_audio_enabled(game):
    """SettingsManager should have tension_audio_enabled property."""
    enabled = await game.get_property(PATHS["settings_manager"], "tension_audio_enabled")
    assert enabled is not None, "tension_audio_enabled should exist"
    assert isinstance(enabled, bool), f"tension_audio_enabled should be bool, got {type(enabled)}"


@pytest.mark.asyncio
async def test_settings_tension_audio_enabled_default(game):
    """tension_audio_enabled should default to true."""
    enabled = await game.get_property(PATHS["settings_manager"], "tension_audio_enabled")
    assert enabled is True, f"tension_audio_enabled should default to True, got {enabled}"


# =============================================================================
# PEACEFUL MODE SETTINGS
# =============================================================================

@pytest.mark.asyncio
async def test_settings_has_peaceful_mode(game):
    """SettingsManager should have peaceful_mode property."""
    enabled = await game.get_property(PATHS["settings_manager"], "peaceful_mode")
    assert enabled is not None, "peaceful_mode should exist"
    assert isinstance(enabled, bool), f"peaceful_mode should be bool, got {type(enabled)}"


@pytest.mark.asyncio
async def test_settings_peaceful_mode_default(game):
    """peaceful_mode should default to false."""
    enabled = await game.get_property(PATHS["settings_manager"], "peaceful_mode")
    assert enabled is False, f"peaceful_mode should default to False, got {enabled}"


# =============================================================================
# CONTROL SETTINGS
# =============================================================================

@pytest.mark.asyncio
async def test_settings_has_swipe_controls_enabled(game):
    """SettingsManager should have swipe_controls_enabled property."""
    enabled = await game.get_property(PATHS["settings_manager"], "swipe_controls_enabled")
    assert enabled is not None, "swipe_controls_enabled should exist"
    assert isinstance(enabled, bool), f"swipe_controls_enabled should be bool, got {type(enabled)}"


@pytest.mark.asyncio
async def test_settings_swipe_controls_enabled_default(game):
    """swipe_controls_enabled should default to false."""
    enabled = await game.get_property(PATHS["settings_manager"], "swipe_controls_enabled")
    assert enabled is False, f"swipe_controls_enabled should default to False, got {enabled}"


@pytest.mark.asyncio
async def test_settings_has_joystick_deadzone(game):
    """SettingsManager should have joystick_deadzone property."""
    deadzone = await game.get_property(PATHS["settings_manager"], "joystick_deadzone")
    assert deadzone is not None, "joystick_deadzone should exist"
    assert isinstance(deadzone, (int, float)), f"joystick_deadzone should be number, got {type(deadzone)}"


@pytest.mark.asyncio
async def test_settings_joystick_deadzone_default(game):
    """joystick_deadzone should default to 0.2."""
    deadzone = await game.get_property(PATHS["settings_manager"], "joystick_deadzone")
    assert deadzone == 0.2, f"joystick_deadzone should default to 0.2, got {deadzone}"


@pytest.mark.asyncio
async def test_settings_has_button_size_scale(game):
    """SettingsManager should have button_size_scale property."""
    scale = await game.get_property(PATHS["settings_manager"], "button_size_scale")
    assert scale is not None, "button_size_scale should exist"
    assert isinstance(scale, (int, float)), f"button_size_scale should be number, got {type(scale)}"


@pytest.mark.asyncio
async def test_settings_button_size_scale_default(game):
    """button_size_scale should default to 1.0."""
    scale = await game.get_property(PATHS["settings_manager"], "button_size_scale")
    assert scale == 1.0, f"button_size_scale should default to 1.0, got {scale}"


@pytest.mark.asyncio
async def test_settings_has_tap_to_dig_enabled(game):
    """SettingsManager should have tap_to_dig_enabled property."""
    enabled = await game.get_property(PATHS["settings_manager"], "tap_to_dig_enabled")
    assert enabled is not None, "tap_to_dig_enabled should exist"
    assert isinstance(enabled, bool), f"tap_to_dig_enabled should be bool, got {type(enabled)}"


@pytest.mark.asyncio
async def test_settings_tap_to_dig_enabled_default(game):
    """tap_to_dig_enabled should default to true."""
    enabled = await game.get_property(PATHS["settings_manager"], "tap_to_dig_enabled")
    assert enabled is True, f"tap_to_dig_enabled should default to True, got {enabled}"


# =============================================================================
# RESET TO DEFAULTS
# =============================================================================

@pytest.mark.asyncio
async def test_settings_reset_to_defaults(game):
    """reset_to_defaults() should restore all settings to default values."""
    # Call reset_to_defaults
    await game.call(PATHS["settings_manager"], "reset_to_defaults")

    # Verify key settings are back to defaults
    text_level = await game.get_property(PATHS["settings_manager"], "text_size_level")
    assert text_level == 1, f"text_size_level should be reset to 1, got {text_level}"

    haptics = await game.get_property(PATHS["settings_manager"], "haptics_enabled")
    assert haptics is True, f"haptics_enabled should be reset to True, got {haptics}"

    juice = await game.get_property(PATHS["settings_manager"], "juice_level")
    assert juice == 2, f"juice_level should be reset to 2 (MEDIUM), got {juice}"

    peaceful = await game.get_property(PATHS["settings_manager"], "peaceful_mode")
    assert peaceful is False, f"peaceful_mode should be reset to False, got {peaceful}"


# =============================================================================
# SIGNAL EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_settings_has_text_size_changed_signal(game):
    """SettingsManager should have text_size_changed signal."""
    has_signal = await game.call(PATHS["settings_manager"], "has_signal", ["text_size_changed"])
    assert has_signal is True, "SettingsManager should have text_size_changed signal"


@pytest.mark.asyncio
async def test_settings_has_colorblind_mode_changed_signal(game):
    """SettingsManager should have colorblind_mode_changed signal."""
    has_signal = await game.call(PATHS["settings_manager"], "has_signal", ["colorblind_mode_changed"])
    assert has_signal is True, "SettingsManager should have colorblind_mode_changed signal"


@pytest.mark.asyncio
async def test_settings_has_hand_mode_changed_signal(game):
    """SettingsManager should have hand_mode_changed signal."""
    has_signal = await game.call(PATHS["settings_manager"], "has_signal", ["hand_mode_changed"])
    assert has_signal is True, "SettingsManager should have hand_mode_changed signal"


@pytest.mark.asyncio
async def test_settings_has_haptics_changed_signal(game):
    """SettingsManager should have haptics_changed signal."""
    has_signal = await game.call(PATHS["settings_manager"], "has_signal", ["haptics_changed"])
    assert has_signal is True, "SettingsManager should have haptics_changed signal"


@pytest.mark.asyncio
async def test_settings_has_reduced_motion_changed_signal(game):
    """SettingsManager should have reduced_motion_changed signal."""
    has_signal = await game.call(PATHS["settings_manager"], "has_signal", ["reduced_motion_changed"])
    assert has_signal is True, "SettingsManager should have reduced_motion_changed signal"


@pytest.mark.asyncio
async def test_settings_has_audio_changed_signal(game):
    """SettingsManager should have audio_changed signal."""
    has_signal = await game.call(PATHS["settings_manager"], "has_signal", ["audio_changed"])
    assert has_signal is True, "SettingsManager should have audio_changed signal"


@pytest.mark.asyncio
async def test_settings_has_screen_shake_changed_signal(game):
    """SettingsManager should have screen_shake_changed signal."""
    has_signal = await game.call(PATHS["settings_manager"], "has_signal", ["screen_shake_changed"])
    assert has_signal is True, "SettingsManager should have screen_shake_changed signal"


@pytest.mark.asyncio
async def test_settings_has_auto_sell_changed_signal(game):
    """SettingsManager should have auto_sell_changed signal."""
    has_signal = await game.call(PATHS["settings_manager"], "has_signal", ["auto_sell_changed"])
    assert has_signal is True, "SettingsManager should have auto_sell_changed signal"


@pytest.mark.asyncio
async def test_settings_has_tension_audio_changed_signal(game):
    """SettingsManager should have tension_audio_changed signal."""
    has_signal = await game.call(PATHS["settings_manager"], "has_signal", ["tension_audio_changed"])
    assert has_signal is True, "SettingsManager should have tension_audio_changed signal"


@pytest.mark.asyncio
async def test_settings_has_juice_level_changed_signal(game):
    """SettingsManager should have juice_level_changed signal."""
    has_signal = await game.call(PATHS["settings_manager"], "has_signal", ["juice_level_changed"])
    assert has_signal is True, "SettingsManager should have juice_level_changed signal"


@pytest.mark.asyncio
async def test_settings_has_peaceful_mode_changed_signal(game):
    """SettingsManager should have peaceful_mode_changed signal."""
    has_signal = await game.call(PATHS["settings_manager"], "has_signal", ["peaceful_mode_changed"])
    assert has_signal is True, "SettingsManager should have peaceful_mode_changed signal"


@pytest.mark.asyncio
async def test_settings_has_swipe_controls_changed_signal(game):
    """SettingsManager should have swipe_controls_changed signal."""
    has_signal = await game.call(PATHS["settings_manager"], "has_signal", ["swipe_controls_changed"])
    assert has_signal is True, "SettingsManager should have swipe_controls_changed signal"


@pytest.mark.asyncio
async def test_settings_has_joystick_deadzone_changed_signal(game):
    """SettingsManager should have joystick_deadzone_changed signal."""
    has_signal = await game.call(PATHS["settings_manager"], "has_signal", ["joystick_deadzone_changed"])
    assert has_signal is True, "SettingsManager should have joystick_deadzone_changed signal"


@pytest.mark.asyncio
async def test_settings_has_button_size_changed_signal(game):
    """SettingsManager should have button_size_changed signal."""
    has_signal = await game.call(PATHS["settings_manager"], "has_signal", ["button_size_changed"])
    assert has_signal is True, "SettingsManager should have button_size_changed signal"


@pytest.mark.asyncio
async def test_settings_has_tap_to_dig_changed_signal(game):
    """SettingsManager should have tap_to_dig_changed signal."""
    has_signal = await game.call(PATHS["settings_manager"], "has_signal", ["tap_to_dig_changed"])
    assert has_signal is True, "SettingsManager should have tap_to_dig_changed signal"


@pytest.mark.asyncio
async def test_settings_has_settings_loaded_signal(game):
    """SettingsManager should have settings_loaded signal."""
    has_signal = await game.call(PATHS["settings_manager"], "has_signal", ["settings_loaded"])
    assert has_signal is True, "SettingsManager should have settings_loaded signal"


@pytest.mark.asyncio
async def test_settings_has_settings_reset_signal(game):
    """SettingsManager should have settings_reset signal."""
    has_signal = await game.call(PATHS["settings_manager"], "has_signal", ["settings_reset"])
    assert has_signal is True, "SettingsManager should have settings_reset signal"
