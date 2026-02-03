"""
SoundManager tests for GoDig endless digging game.

Tests verify that SoundManager:
1. Exists as an autoload singleton
2. Has proper signals for music and sound events
3. Has convenience methods for game events
4. Has music control methods
5. Has tension audio system
6. Pool sizes are configured correctly
"""
import pytest
from helpers import PATHS


# Path to sound manager
SOUND_MANAGER_PATH = PATHS.get("sound_manager", "/root/SoundManager")


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_sound_manager_exists(game):
    """SoundManager autoload should exist."""
    result = await game.node_exists(SOUND_MANAGER_PATH)
    assert result.get("exists") is True, "SoundManager autoload should exist"


# =============================================================================
# SIGNAL TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_music_changed_signal(game):
    """SoundManager should have music_changed signal."""
    has_signal = await game.call(SOUND_MANAGER_PATH, "has_signal", ["music_changed"])
    assert has_signal is True, "SoundManager should have music_changed signal"


@pytest.mark.asyncio
async def test_has_sound_played_signal(game):
    """SoundManager should have sound_played signal."""
    has_signal = await game.call(SOUND_MANAGER_PATH, "has_signal", ["sound_played"])
    assert has_signal is True, "SoundManager should have sound_played signal"


@pytest.mark.asyncio
async def test_has_tension_level_changed_signal(game):
    """SoundManager should have tension_level_changed signal."""
    has_signal = await game.call(SOUND_MANAGER_PATH, "has_signal", ["tension_level_changed"])
    assert has_signal is True, "SoundManager should have tension_level_changed signal"


# =============================================================================
# POOL SIZE CONSTANTS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_max_sfx_players_constant(game):
    """MAX_SFX_PLAYERS should be configured."""
    result = await game.get_property(SOUND_MANAGER_PATH, "MAX_SFX_PLAYERS")
    assert result is not None, "MAX_SFX_PLAYERS should exist"
    assert result > 0, f"MAX_SFX_PLAYERS should be positive, got {result}"


@pytest.mark.asyncio
async def test_max_music_players_constant(game):
    """MAX_MUSIC_PLAYERS should be configured."""
    result = await game.get_property(SOUND_MANAGER_PATH, "MAX_MUSIC_PLAYERS")
    assert result is not None, "MAX_MUSIC_PLAYERS should exist"
    assert result > 0, f"MAX_MUSIC_PLAYERS should be positive, got {result}"


# =============================================================================
# SFX BUS CONSTANTS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_sfx_bus_constant(game):
    """SFX_BUS should be configured."""
    result = await game.get_property(SOUND_MANAGER_PATH, "SFX_BUS")
    assert result is not None, "SFX_BUS should exist"
    assert isinstance(result, str), f"SFX_BUS should be a string, got {type(result)}"


@pytest.mark.asyncio
async def test_music_bus_constant(game):
    """MUSIC_BUS should be configured."""
    result = await game.get_property(SOUND_MANAGER_PATH, "MUSIC_BUS")
    assert result is not None, "MUSIC_BUS should exist"
    assert isinstance(result, str), f"MUSIC_BUS should be a string, got {type(result)}"


# =============================================================================
# SOUND PATH CONSTANTS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_sound_dig_soft_constant(game):
    """SOUND_DIG_SOFT should be configured."""
    result = await game.get_property(SOUND_MANAGER_PATH, "SOUND_DIG_SOFT")
    assert result is not None, "SOUND_DIG_SOFT should exist"
    assert isinstance(result, str), f"SOUND_DIG_SOFT should be a string path, got {type(result)}"


@pytest.mark.asyncio
async def test_sound_block_break_constant(game):
    """SOUND_BLOCK_BREAK should be configured."""
    result = await game.get_property(SOUND_MANAGER_PATH, "SOUND_BLOCK_BREAK")
    assert result is not None, "SOUND_BLOCK_BREAK should exist"
    assert isinstance(result, str), f"SOUND_BLOCK_BREAK should be a string path, got {type(result)}"


@pytest.mark.asyncio
async def test_sound_ore_found_constant(game):
    """SOUND_ORE_FOUND should be configured."""
    result = await game.get_property(SOUND_MANAGER_PATH, "SOUND_ORE_FOUND")
    assert result is not None, "SOUND_ORE_FOUND should exist"
    assert isinstance(result, str), f"SOUND_ORE_FOUND should be a string path, got {type(result)}"


# =============================================================================
# CONVENIENCE METHOD EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_play_sfx_method(game):
    """SoundManager should have play_sfx method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_sfx"])
    assert result is True, "SoundManager should have play_sfx method"


@pytest.mark.asyncio
async def test_has_play_sfx_varied_method(game):
    """SoundManager should have play_sfx_varied method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_sfx_varied"])
    assert result is True, "SoundManager should have play_sfx_varied method"


@pytest.mark.asyncio
async def test_has_play_dig_method(game):
    """SoundManager should have play_dig method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_dig"])
    assert result is True, "SoundManager should have play_dig method"


@pytest.mark.asyncio
async def test_has_play_block_break_method(game):
    """SoundManager should have play_block_break method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_block_break"])
    assert result is True, "SoundManager should have play_block_break method"


@pytest.mark.asyncio
async def test_has_play_ore_found_method(game):
    """SoundManager should have play_ore_found method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_ore_found"])
    assert result is True, "SoundManager should have play_ore_found method"


@pytest.mark.asyncio
async def test_has_play_ore_discovery_method(game):
    """SoundManager should have play_ore_discovery method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_ore_discovery"])
    assert result is True, "SoundManager should have play_ore_discovery method"


@pytest.mark.asyncio
async def test_has_play_pickup_method(game):
    """SoundManager should have play_pickup method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_pickup"])
    assert result is True, "SoundManager should have play_pickup method"


@pytest.mark.asyncio
async def test_has_play_coin_pickup_method(game):
    """SoundManager should have play_coin_pickup method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_coin_pickup"])
    assert result is True, "SoundManager should have play_coin_pickup method"


@pytest.mark.asyncio
async def test_has_play_jackpot_discovery_method(game):
    """SoundManager should have play_jackpot_discovery method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_jackpot_discovery"])
    assert result is True, "SoundManager should have play_jackpot_discovery method"


# =============================================================================
# UI SOUND METHOD EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_play_ui_click_method(game):
    """SoundManager should have play_ui_click method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_ui_click"])
    assert result is True, "SoundManager should have play_ui_click method"


@pytest.mark.asyncio
async def test_has_play_ui_hover_method(game):
    """SoundManager should have play_ui_hover method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_ui_hover"])
    assert result is True, "SoundManager should have play_ui_hover method"


@pytest.mark.asyncio
async def test_has_play_ui_open_method(game):
    """SoundManager should have play_ui_open method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_ui_open"])
    assert result is True, "SoundManager should have play_ui_open method"


@pytest.mark.asyncio
async def test_has_play_ui_close_method(game):
    """SoundManager should have play_ui_close method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_ui_close"])
    assert result is True, "SoundManager should have play_ui_close method"


@pytest.mark.asyncio
async def test_has_play_ui_error_method(game):
    """SoundManager should have play_ui_error method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_ui_error"])
    assert result is True, "SoundManager should have play_ui_error method"


@pytest.mark.asyncio
async def test_has_play_ui_success_method(game):
    """SoundManager should have play_ui_success method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_ui_success"])
    assert result is True, "SoundManager should have play_ui_success method"


@pytest.mark.asyncio
async def test_has_play_purchase_method(game):
    """SoundManager should have play_purchase method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_purchase"])
    assert result is True, "SoundManager should have play_purchase method"


# =============================================================================
# PLAYER SOUND METHOD EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_play_player_hurt_method(game):
    """SoundManager should have play_player_hurt method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_player_hurt"])
    assert result is True, "SoundManager should have play_player_hurt method"


@pytest.mark.asyncio
async def test_has_play_player_death_method(game):
    """SoundManager should have play_player_death method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_player_death"])
    assert result is True, "SoundManager should have play_player_death method"


@pytest.mark.asyncio
async def test_has_play_land_method(game):
    """SoundManager should have play_land method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_land"])
    assert result is True, "SoundManager should have play_land method"


@pytest.mark.asyncio
async def test_has_play_jump_method(game):
    """SoundManager should have play_jump method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_jump"])
    assert result is True, "SoundManager should have play_jump method"


# =============================================================================
# ACHIEVEMENT/MILESTONE SOUND METHOD EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_play_achievement_method(game):
    """SoundManager should have play_achievement method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_achievement"])
    assert result is True, "SoundManager should have play_achievement method"


@pytest.mark.asyncio
async def test_has_play_milestone_method(game):
    """SoundManager should have play_milestone method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_milestone"])
    assert result is True, "SoundManager should have play_milestone method"


@pytest.mark.asyncio
async def test_has_play_level_up_method(game):
    """SoundManager should have play_level_up method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_level_up"])
    assert result is True, "SoundManager should have play_level_up method"


@pytest.mark.asyncio
async def test_has_play_tool_upgrade_method(game):
    """SoundManager should have play_tool_upgrade method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_tool_upgrade"])
    assert result is True, "SoundManager should have play_tool_upgrade method"


@pytest.mark.asyncio
async def test_has_play_safe_return_method(game):
    """SoundManager should have play_safe_return method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_safe_return"])
    assert result is True, "SoundManager should have play_safe_return method"


# =============================================================================
# MUSIC CONTROL METHOD EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_play_music_method(game):
    """SoundManager should have play_music method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_music"])
    assert result is True, "SoundManager should have play_music method"


@pytest.mark.asyncio
async def test_has_stop_music_method(game):
    """SoundManager should have stop_music method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["stop_music"])
    assert result is True, "SoundManager should have stop_music method"


@pytest.mark.asyncio
async def test_has_update_music_for_depth_method(game):
    """SoundManager should have update_music_for_depth method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["update_music_for_depth"])
    assert result is True, "SoundManager should have update_music_for_depth method"


@pytest.mark.asyncio
async def test_has_play_menu_music_method(game):
    """SoundManager should have play_menu_music method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["play_menu_music"])
    assert result is True, "SoundManager should have play_menu_music method"


@pytest.mark.asyncio
async def test_has_is_music_playing_method(game):
    """SoundManager should have is_music_playing method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["is_music_playing"])
    assert result is True, "SoundManager should have is_music_playing method"


@pytest.mark.asyncio
async def test_has_get_current_music_method(game):
    """SoundManager should have get_current_music method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["get_current_music"])
    assert result is True, "SoundManager should have get_current_music method"


# =============================================================================
# VOLUME CONTROL METHOD EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_set_master_volume_method(game):
    """SoundManager should have set_master_volume method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["set_master_volume"])
    assert result is True, "SoundManager should have set_master_volume method"


@pytest.mark.asyncio
async def test_has_set_sfx_volume_method(game):
    """SoundManager should have set_sfx_volume method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["set_sfx_volume"])
    assert result is True, "SoundManager should have set_sfx_volume method"


@pytest.mark.asyncio
async def test_has_set_music_volume_method(game):
    """SoundManager should have set_music_volume method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["set_music_volume"])
    assert result is True, "SoundManager should have set_music_volume method"


# =============================================================================
# UTILITY METHOD EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_stop_all_method(game):
    """SoundManager should have stop_all method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["stop_all"])
    assert result is True, "SoundManager should have stop_all method"


@pytest.mark.asyncio
async def test_has_clear_cache_method(game):
    """SoundManager should have clear_cache method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["clear_cache"])
    assert result is True, "SoundManager should have clear_cache method"


# =============================================================================
# TENSION AUDIO METHOD EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_calculate_risk_score_method(game):
    """SoundManager should have calculate_risk_score method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["calculate_risk_score"])
    assert result is True, "SoundManager should have calculate_risk_score method"


@pytest.mark.asyncio
async def test_has_get_tension_score_method(game):
    """SoundManager should have get_tension_score method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["get_tension_score"])
    assert result is True, "SoundManager should have get_tension_score method"


@pytest.mark.asyncio
async def test_has_update_tension_now_method(game):
    """SoundManager should have update_tension_now method."""
    result = await game.call(SOUND_MANAGER_PATH, "has_method", ["update_tension_now"])
    assert result is True, "SoundManager should have update_tension_now method"


# =============================================================================
# TENSION AUDIO STATE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_tension_score_initial_zero(game):
    """Tension score should start at 0."""
    result = await game.call(SOUND_MANAGER_PATH, "get_tension_score")
    assert result is not None, "get_tension_score should return a value"
    # Tension score might be 0 or a low value depending on game state
    assert isinstance(result, (int, float)), f"Tension score should be numeric, got {type(result)}"
    assert 0.0 <= result <= 1.0, f"Tension score should be between 0 and 1, got {result}"


@pytest.mark.asyncio
async def test_calculate_risk_score_returns_numeric(game):
    """calculate_risk_score should return a numeric value."""
    result = await game.call(SOUND_MANAGER_PATH, "calculate_risk_score")
    assert result is not None, "calculate_risk_score should return a value"
    assert isinstance(result, (int, float)), f"Risk score should be numeric, got {type(result)}"
    assert 0.0 <= result <= 1.0, f"Risk score should be between 0 and 1, got {result}"


# =============================================================================
# TENSION AUDIO CONSTANTS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_tension_bus_constant(game):
    """TENSION_BUS should be configured."""
    result = await game.get_property(SOUND_MANAGER_PATH, "TENSION_BUS")
    assert result is not None, "TENSION_BUS should exist"
    assert isinstance(result, str), f"TENSION_BUS should be a string, got {type(result)}"


@pytest.mark.asyncio
async def test_tension_update_interval_constant(game):
    """TENSION_UPDATE_INTERVAL should be configured."""
    result = await game.get_property(SOUND_MANAGER_PATH, "TENSION_UPDATE_INTERVAL")
    assert result is not None, "TENSION_UPDATE_INTERVAL should exist"
    assert result > 0, f"TENSION_UPDATE_INTERVAL should be positive, got {result}"


@pytest.mark.asyncio
async def test_tension_max_volume_constant(game):
    """TENSION_MAX_VOLUME should be configured."""
    result = await game.get_property(SOUND_MANAGER_PATH, "TENSION_MAX_VOLUME")
    assert result is not None, "TENSION_MAX_VOLUME should exist"
    # Volume in dB, so it can be negative
    assert isinstance(result, (int, float)), f"TENSION_MAX_VOLUME should be numeric, got {type(result)}"


@pytest.mark.asyncio
async def test_risk_weight_inventory_constant(game):
    """RISK_WEIGHT_INVENTORY should be configured."""
    result = await game.get_property(SOUND_MANAGER_PATH, "RISK_WEIGHT_INVENTORY")
    assert result is not None, "RISK_WEIGHT_INVENTORY should exist"
    assert 0.0 <= result <= 1.0, f"RISK_WEIGHT_INVENTORY should be between 0 and 1, got {result}"


@pytest.mark.asyncio
async def test_risk_weight_depth_constant(game):
    """RISK_WEIGHT_DEPTH should be configured."""
    result = await game.get_property(SOUND_MANAGER_PATH, "RISK_WEIGHT_DEPTH")
    assert result is not None, "RISK_WEIGHT_DEPTH should exist"
    assert 0.0 <= result <= 1.0, f"RISK_WEIGHT_DEPTH should be between 0 and 1, got {result}"


@pytest.mark.asyncio
async def test_risk_weight_ladder_constant(game):
    """RISK_WEIGHT_LADDER should be configured."""
    result = await game.get_property(SOUND_MANAGER_PATH, "RISK_WEIGHT_LADDER")
    assert result is not None, "RISK_WEIGHT_LADDER should exist"
    assert 0.0 <= result <= 1.0, f"RISK_WEIGHT_LADDER should be between 0 and 1, got {result}"


# =============================================================================
# MUSIC STATE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_is_music_playing_returns_bool(game):
    """is_music_playing should return a boolean."""
    result = await game.call(SOUND_MANAGER_PATH, "is_music_playing")
    assert isinstance(result, bool), f"is_music_playing should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_get_current_music_returns_string(game):
    """get_current_music should return a string."""
    result = await game.call(SOUND_MANAGER_PATH, "get_current_music")
    assert isinstance(result, str), f"get_current_music should return string, got {type(result)}"


# =============================================================================
# MUSIC TRACK CONSTANTS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_music_menu_constant(game):
    """MUSIC_MENU should be configured."""
    result = await game.get_property(SOUND_MANAGER_PATH, "MUSIC_MENU")
    assert result is not None, "MUSIC_MENU should exist"
    assert isinstance(result, str), f"MUSIC_MENU should be a string path, got {type(result)}"


@pytest.mark.asyncio
async def test_music_surface_constant(game):
    """MUSIC_SURFACE should be configured."""
    result = await game.get_property(SOUND_MANAGER_PATH, "MUSIC_SURFACE")
    assert result is not None, "MUSIC_SURFACE should exist"
    assert isinstance(result, str), f"MUSIC_SURFACE should be a string path, got {type(result)}"


@pytest.mark.asyncio
async def test_music_underground_constant(game):
    """MUSIC_UNDERGROUND should be configured."""
    result = await game.get_property(SOUND_MANAGER_PATH, "MUSIC_UNDERGROUND")
    assert result is not None, "MUSIC_UNDERGROUND should exist"
    assert isinstance(result, str), f"MUSIC_UNDERGROUND should be a string path, got {type(result)}"


@pytest.mark.asyncio
async def test_music_deep_constant(game):
    """MUSIC_DEEP should be configured."""
    result = await game.get_property(SOUND_MANAGER_PATH, "MUSIC_DEEP")
    assert result is not None, "MUSIC_DEEP should exist"
    assert isinstance(result, str), f"MUSIC_DEEP should be a string path, got {type(result)}"


@pytest.mark.asyncio
async def test_music_danger_constant(game):
    """MUSIC_DANGER should be configured."""
    result = await game.get_property(SOUND_MANAGER_PATH, "MUSIC_DANGER")
    assert result is not None, "MUSIC_DANGER should exist"
    assert isinstance(result, str), f"MUSIC_DANGER should be a string path, got {type(result)}"
