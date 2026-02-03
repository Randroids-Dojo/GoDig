"""
SaveManager tests for GoDig endless digging game.

Tests verify that SaveManager:
1. Exists as an autoload singleton
2. Has correct constants for save paths and limits
3. Manages save slots correctly
4. Tracks save/load state properly
5. Handles offline income system
6. Manages FTUE (First Time User Experience) tracking
7. Handles backup/recovery operations
8. Has proper signals for save events
"""
import pytest
from helpers import PATHS


# Path to save manager
SAVE_MANAGER_PATH = PATHS.get("save_manager", "/root/SaveManager")


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_save_manager_exists(game):
    """SaveManager autoload should exist."""
    result = await game.node_exists(SAVE_MANAGER_PATH)
    assert result.get("exists") is True, "SaveManager autoload should exist"


# =============================================================================
# CONSTANTS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_save_dir_constant(game):
    """SaveManager should have SAVE_DIR constant."""
    result = await game.get_property(SAVE_MANAGER_PATH, "SAVE_DIR")
    assert result is not None, "SAVE_DIR should exist"
    assert isinstance(result, str), f"SAVE_DIR should be string, got {type(result)}"
    assert "user://" in result, f"SAVE_DIR should be in user:// directory, got {result}"


@pytest.mark.asyncio
async def test_has_chunks_dir_constant(game):
    """SaveManager should have CHUNKS_DIR constant."""
    result = await game.get_property(SAVE_MANAGER_PATH, "CHUNKS_DIR")
    assert result is not None, "CHUNKS_DIR should exist"
    assert isinstance(result, str), f"CHUNKS_DIR should be string, got {type(result)}"


@pytest.mark.asyncio
async def test_has_max_slots_constant(game):
    """SaveManager should have MAX_SLOTS constant."""
    result = await game.get_property(SAVE_MANAGER_PATH, "MAX_SLOTS")
    assert result is not None, "MAX_SLOTS should exist"
    assert isinstance(result, int), f"MAX_SLOTS should be int, got {type(result)}"
    assert result >= 1, f"MAX_SLOTS should be at least 1, got {result}"


@pytest.mark.asyncio
async def test_max_slots_value(game):
    """MAX_SLOTS should be 3."""
    result = await game.get_property(SAVE_MANAGER_PATH, "MAX_SLOTS")
    assert result == 3, f"MAX_SLOTS should be 3, got {result}"


@pytest.mark.asyncio
async def test_has_auto_save_interval_constant(game):
    """SaveManager should have AUTO_SAVE_INTERVAL constant."""
    result = await game.get_property(SAVE_MANAGER_PATH, "AUTO_SAVE_INTERVAL")
    assert result is not None, "AUTO_SAVE_INTERVAL should exist"
    assert isinstance(result, (int, float)), f"AUTO_SAVE_INTERVAL should be number, got {type(result)}"


@pytest.mark.asyncio
async def test_auto_save_interval_value(game):
    """AUTO_SAVE_INTERVAL should be 30 seconds."""
    result = await game.get_property(SAVE_MANAGER_PATH, "AUTO_SAVE_INTERVAL")
    assert result == 30.0, f"AUTO_SAVE_INTERVAL should be 30.0, got {result}"


@pytest.mark.asyncio
async def test_has_offline_income_rate(game):
    """SaveManager should have OFFLINE_INCOME_RATE constant."""
    result = await game.get_property(SAVE_MANAGER_PATH, "OFFLINE_INCOME_RATE")
    assert result is not None, "OFFLINE_INCOME_RATE should exist"
    assert isinstance(result, (int, float)), f"OFFLINE_INCOME_RATE should be number, got {type(result)}"


@pytest.mark.asyncio
async def test_has_offline_max_hours(game):
    """SaveManager should have OFFLINE_MAX_HOURS constant."""
    result = await game.get_property(SAVE_MANAGER_PATH, "OFFLINE_MAX_HOURS")
    assert result is not None, "OFFLINE_MAX_HOURS should exist"
    assert isinstance(result, (int, float)), f"OFFLINE_MAX_HOURS should be number, got {type(result)}"


@pytest.mark.asyncio
async def test_has_min_save_interval_ms(game):
    """SaveManager should have MIN_SAVE_INTERVAL_MS constant."""
    result = await game.get_property(SAVE_MANAGER_PATH, "MIN_SAVE_INTERVAL_MS")
    assert result is not None, "MIN_SAVE_INTERVAL_MS should exist"
    assert isinstance(result, int), f"MIN_SAVE_INTERVAL_MS should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_has_max_save_retries(game):
    """SaveManager should have MAX_SAVE_RETRIES constant."""
    result = await game.get_property(SAVE_MANAGER_PATH, "MAX_SAVE_RETRIES")
    assert result is not None, "MAX_SAVE_RETRIES should exist"
    assert isinstance(result, int), f"MAX_SAVE_RETRIES should be int, got {type(result)}"


# =============================================================================
# STATE PROPERTY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_current_slot_property(game):
    """current_slot property should be accessible."""
    result = await game.get_property(SAVE_MANAGER_PATH, "current_slot")
    assert result is not None, "current_slot should exist"
    assert isinstance(result, int), f"current_slot should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_auto_save_enabled_property(game):
    """auto_save_enabled property should be accessible."""
    result = await game.get_property(SAVE_MANAGER_PATH, "auto_save_enabled")
    assert result is not None, "auto_save_enabled should exist"
    assert isinstance(result, bool), f"auto_save_enabled should be bool, got {type(result)}"


@pytest.mark.asyncio
async def test_pending_offline_income_property(game):
    """pending_offline_income property should be accessible."""
    result = await game.get_property(SAVE_MANAGER_PATH, "pending_offline_income")
    assert result is not None, "pending_offline_income should exist"
    assert isinstance(result, int), f"pending_offline_income should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_pending_offline_minutes_property(game):
    """pending_offline_minutes property should be accessible."""
    result = await game.get_property(SAVE_MANAGER_PATH, "pending_offline_minutes")
    assert result is not None, "pending_offline_minutes should exist"
    assert isinstance(result, int), f"pending_offline_minutes should be int, got {type(result)}"


# =============================================================================
# ERROR TRACKING PROPERTY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_last_save_error_property(game):
    """last_save_error property should be accessible."""
    result = await game.get_property(SAVE_MANAGER_PATH, "last_save_error")
    assert result is not None or result == "", "last_save_error should exist"
    assert isinstance(result, str), f"last_save_error should be string, got {type(result)}"


@pytest.mark.asyncio
async def test_last_load_error_property(game):
    """last_load_error property should be accessible."""
    result = await game.get_property(SAVE_MANAGER_PATH, "last_load_error")
    assert result is not None or result == "", "last_load_error should exist"
    assert isinstance(result, str), f"last_load_error should be string, got {type(result)}"


@pytest.mark.asyncio
async def test_consecutive_save_failures_property(game):
    """consecutive_save_failures property should be accessible."""
    result = await game.get_property(SAVE_MANAGER_PATH, "consecutive_save_failures")
    assert result is not None, "consecutive_save_failures should exist"
    assert isinstance(result, int), f"consecutive_save_failures should be int, got {type(result)}"
    assert result >= 0, f"consecutive_save_failures should be non-negative, got {result}"


# =============================================================================
# SLOT MANAGEMENT METHOD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_save_path_returns_string(game):
    """get_save_path should return a string path."""
    result = await game.call(SAVE_MANAGER_PATH, "get_save_path", [0])
    assert result is not None, "get_save_path should return a value"
    assert isinstance(result, str), f"get_save_path should return string, got {type(result)}"


@pytest.mark.asyncio
async def test_get_save_path_includes_slot(game):
    """get_save_path should include slot number in path."""
    result = await game.call(SAVE_MANAGER_PATH, "get_save_path", [1])
    assert "1" in result, f"get_save_path(1) should include '1' in path, got {result}"


@pytest.mark.asyncio
async def test_has_save_returns_bool(game):
    """has_save should return a boolean."""
    result = await game.call(SAVE_MANAGER_PATH, "has_save", [0])
    assert isinstance(result, bool), f"has_save should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_get_all_slot_summaries_returns_array(game):
    """get_all_slot_summaries should return an array."""
    result = await game.call(SAVE_MANAGER_PATH, "get_all_slot_summaries")
    assert result is not None, "get_all_slot_summaries should return a value"
    assert isinstance(result, list), f"get_all_slot_summaries should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_get_all_slot_summaries_has_correct_count(game):
    """get_all_slot_summaries should return MAX_SLOTS entries."""
    result = await game.call(SAVE_MANAGER_PATH, "get_all_slot_summaries")
    max_slots = await game.get_property(SAVE_MANAGER_PATH, "MAX_SLOTS")
    assert len(result) == max_slots, f"Should have {max_slots} slot summaries, got {len(result)}"


@pytest.mark.asyncio
async def test_slot_summary_has_required_fields(game):
    """Each slot summary should have required fields."""
    result = await game.call(SAVE_MANAGER_PATH, "get_all_slot_summaries")
    for summary in result:
        assert "slot" in summary, f"Slot summary should have 'slot' field: {summary}"
        assert "exists" in summary, f"Slot summary should have 'exists' field: {summary}"
        assert "summary" in summary, f"Slot summary should have 'summary' field: {summary}"


# =============================================================================
# GAME LOAD STATE METHOD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_is_game_loaded_returns_bool(game):
    """is_game_loaded should return a boolean."""
    result = await game.call(SAVE_MANAGER_PATH, "is_game_loaded")
    assert isinstance(result, bool), f"is_game_loaded should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_get_world_seed_returns_int(game):
    """get_world_seed should return an integer."""
    result = await game.call(SAVE_MANAGER_PATH, "get_world_seed")
    assert isinstance(result, int), f"get_world_seed should return int, got {type(result)}"


@pytest.mark.asyncio
async def test_get_player_position_returns_value(game):
    """get_player_position should return a Vector2i or dict."""
    result = await game.call(SAVE_MANAGER_PATH, "get_player_position")
    assert result is not None, "get_player_position should return a value"


# =============================================================================
# TIME SINCE SAVE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_seconds_since_last_save_returns_int(game):
    """get_seconds_since_last_save should return an integer."""
    result = await game.call(SAVE_MANAGER_PATH, "get_seconds_since_last_save")
    assert isinstance(result, int), f"get_seconds_since_last_save should return int, got {type(result)}"


@pytest.mark.asyncio
async def test_get_time_since_save_text_returns_string(game):
    """get_time_since_save_text should return a string."""
    result = await game.call(SAVE_MANAGER_PATH, "get_time_since_save_text")
    assert result is not None, "get_time_since_save_text should return a value"
    assert isinstance(result, str), f"get_time_since_save_text should return string, got {type(result)}"


# =============================================================================
# OFFLINE INCOME METHOD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_pending_offline_income_returns_bool(game):
    """has_pending_offline_income should return a boolean."""
    result = await game.call(SAVE_MANAGER_PATH, "has_pending_offline_income")
    assert isinstance(result, bool), f"has_pending_offline_income should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_get_pending_offline_info_returns_dict(game):
    """get_pending_offline_info should return a dictionary."""
    result = await game.call(SAVE_MANAGER_PATH, "get_pending_offline_info")
    assert result is not None, "get_pending_offline_info should return a value"
    assert isinstance(result, dict), f"get_pending_offline_info should return dict, got {type(result)}"


@pytest.mark.asyncio
async def test_get_pending_offline_info_has_fields(game):
    """get_pending_offline_info should have amount and minutes fields."""
    result = await game.call(SAVE_MANAGER_PATH, "get_pending_offline_info")
    assert "amount" in result, "get_pending_offline_info should have 'amount' field"
    assert "minutes" in result, "get_pending_offline_info should have 'minutes' field"


@pytest.mark.asyncio
async def test_claim_offline_income_returns_int(game):
    """claim_offline_income should return an integer."""
    result = await game.call(SAVE_MANAGER_PATH, "claim_offline_income")
    assert isinstance(result, int), f"claim_offline_income should return int, got {type(result)}"


# =============================================================================
# FTUE TRACKING METHOD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_first_ore_spawned_returns_bool(game):
    """has_first_ore_spawned should return a boolean."""
    result = await game.call(SAVE_MANAGER_PATH, "has_first_ore_spawned")
    assert isinstance(result, bool), f"has_first_ore_spawned should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_has_first_ore_been_collected_returns_bool(game):
    """has_first_ore_been_collected should return a boolean."""
    result = await game.call(SAVE_MANAGER_PATH, "has_first_ore_been_collected")
    assert isinstance(result, bool), f"has_first_ore_been_collected should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_is_ftue_completed_returns_bool(game):
    """is_ftue_completed should return a boolean."""
    result = await game.call(SAVE_MANAGER_PATH, "is_ftue_completed")
    assert isinstance(result, bool), f"is_ftue_completed should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_has_ftue_first_dig_returns_bool(game):
    """has_ftue_first_dig should return a boolean."""
    result = await game.call(SAVE_MANAGER_PATH, "has_ftue_first_dig")
    assert isinstance(result, bool), f"has_ftue_first_dig should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_has_ftue_first_sell_returns_bool(game):
    """has_ftue_first_sell should return a boolean."""
    result = await game.call(SAVE_MANAGER_PATH, "has_ftue_first_sell")
    assert isinstance(result, bool), f"has_ftue_first_sell should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_is_brand_new_player_returns_bool(game):
    """is_brand_new_player should return a boolean."""
    result = await game.call(SAVE_MANAGER_PATH, "is_brand_new_player")
    assert isinstance(result, bool), f"is_brand_new_player should return bool, got {type(result)}"


# =============================================================================
# FIRST UPGRADE TRACKING METHOD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_first_upgrade_purchased_returns_bool(game):
    """has_first_upgrade_purchased should return a boolean."""
    result = await game.call(SAVE_MANAGER_PATH, "has_first_upgrade_purchased")
    assert isinstance(result, bool), f"has_first_upgrade_purchased should return bool, got {type(result)}"


# =============================================================================
# BACKUP/RECOVERY METHOD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_backup_path_returns_string(game):
    """get_backup_path should return a string."""
    result = await game.call(SAVE_MANAGER_PATH, "get_backup_path", [0])
    assert result is not None, "get_backup_path should return a value"
    assert isinstance(result, str), f"get_backup_path should return string, got {type(result)}"


@pytest.mark.asyncio
async def test_get_backup_path_includes_backup_suffix(game):
    """get_backup_path should include backup suffix."""
    result = await game.call(SAVE_MANAGER_PATH, "get_backup_path", [0])
    backup_suffix = await game.get_property(SAVE_MANAGER_PATH, "BACKUP_SUFFIX")
    assert backup_suffix in result, f"get_backup_path should include '{backup_suffix}', got {result}"


@pytest.mark.asyncio
async def test_has_backup_returns_bool(game):
    """has_backup should return a boolean."""
    result = await game.call(SAVE_MANAGER_PATH, "has_backup", [0])
    assert isinstance(result, bool), f"has_backup should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_get_last_error_returns_string(game):
    """get_last_error should return a string."""
    result = await game.call(SAVE_MANAGER_PATH, "get_last_error")
    assert result is not None or result == "", "get_last_error should return a value"
    assert isinstance(result, str), f"get_last_error should return string, got {type(result)}"


@pytest.mark.asyncio
async def test_is_save_system_healthy_returns_bool(game):
    """is_save_system_healthy should return a boolean."""
    result = await game.call(SAVE_MANAGER_PATH, "is_save_system_healthy")
    assert isinstance(result, bool), f"is_save_system_healthy should return bool, got {type(result)}"


# =============================================================================
# CHUNK PERSISTENCE METHOD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_chunk_path_returns_string(game):
    """get_chunk_path should return a string."""
    # Vector2i serializes as dict with x/y, pass as list
    result = await game.call(SAVE_MANAGER_PATH, "get_chunk_path", [0, {"x": 0, "y": 0}])
    assert result is not None, "get_chunk_path should return a value"
    assert isinstance(result, str), f"get_chunk_path should return string, got {type(result)}"


@pytest.mark.asyncio
async def test_has_modified_chunk_returns_bool(game):
    """has_modified_chunk should return a boolean."""
    result = await game.call(SAVE_MANAGER_PATH, "has_modified_chunk", [{"x": 0, "y": 0}])
    assert isinstance(result, bool), f"has_modified_chunk should return bool, got {type(result)}"


# =============================================================================
# SIGNAL TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_save_started_signal(game):
    """SaveManager should have save_started signal."""
    has_signal = await game.call(SAVE_MANAGER_PATH, "has_signal", ["save_started"])
    assert has_signal is True, "SaveManager should have save_started signal"


@pytest.mark.asyncio
async def test_has_save_completed_signal(game):
    """SaveManager should have save_completed signal."""
    has_signal = await game.call(SAVE_MANAGER_PATH, "has_signal", ["save_completed"])
    assert has_signal is True, "SaveManager should have save_completed signal"


@pytest.mark.asyncio
async def test_has_save_error_signal(game):
    """SaveManager should have save_error signal."""
    has_signal = await game.call(SAVE_MANAGER_PATH, "has_signal", ["save_error"])
    assert has_signal is True, "SaveManager should have save_error signal"


@pytest.mark.asyncio
async def test_has_load_started_signal(game):
    """SaveManager should have load_started signal."""
    has_signal = await game.call(SAVE_MANAGER_PATH, "has_signal", ["load_started"])
    assert has_signal is True, "SaveManager should have load_started signal"


@pytest.mark.asyncio
async def test_has_load_completed_signal(game):
    """SaveManager should have load_completed signal."""
    has_signal = await game.call(SAVE_MANAGER_PATH, "has_signal", ["load_completed"])
    assert has_signal is True, "SaveManager should have load_completed signal"


@pytest.mark.asyncio
async def test_has_load_error_signal(game):
    """SaveManager should have load_error signal."""
    has_signal = await game.call(SAVE_MANAGER_PATH, "has_signal", ["load_error"])
    assert has_signal is True, "SaveManager should have load_error signal"


@pytest.mark.asyncio
async def test_has_save_slot_changed_signal(game):
    """SaveManager should have save_slot_changed signal."""
    has_signal = await game.call(SAVE_MANAGER_PATH, "has_signal", ["save_slot_changed"])
    assert has_signal is True, "SaveManager should have save_slot_changed signal"


@pytest.mark.asyncio
async def test_has_auto_save_triggered_signal(game):
    """SaveManager should have auto_save_triggered signal."""
    has_signal = await game.call(SAVE_MANAGER_PATH, "has_signal", ["auto_save_triggered"])
    assert has_signal is True, "SaveManager should have auto_save_triggered signal"


@pytest.mark.asyncio
async def test_has_offline_income_ready_signal(game):
    """SaveManager should have offline_income_ready signal."""
    has_signal = await game.call(SAVE_MANAGER_PATH, "has_signal", ["offline_income_ready"])
    assert has_signal is True, "SaveManager should have offline_income_ready signal"


@pytest.mark.asyncio
async def test_has_backup_created_signal(game):
    """SaveManager should have backup_created signal."""
    has_signal = await game.call(SAVE_MANAGER_PATH, "has_signal", ["backup_created"])
    assert has_signal is True, "SaveManager should have backup_created signal"


@pytest.mark.asyncio
async def test_has_backup_restored_signal(game):
    """SaveManager should have backup_restored signal."""
    has_signal = await game.call(SAVE_MANAGER_PATH, "has_signal", ["backup_restored"])
    assert has_signal is True, "SaveManager should have backup_restored signal"


# =============================================================================
# CLEAR ERRORS TEST
# =============================================================================

@pytest.mark.asyncio
async def test_clear_errors_clears_state(game):
    """clear_errors should reset error tracking state."""
    await game.call(SAVE_MANAGER_PATH, "clear_errors")
    last_save = await game.get_property(SAVE_MANAGER_PATH, "last_save_error")
    last_load = await game.get_property(SAVE_MANAGER_PATH, "last_load_error")
    failures = await game.get_property(SAVE_MANAGER_PATH, "consecutive_save_failures")
    assert last_save == "", f"last_save_error should be empty after clear, got '{last_save}'"
    assert last_load == "", f"last_load_error should be empty after clear, got '{last_load}'"
    assert failures == 0, f"consecutive_save_failures should be 0 after clear, got {failures}"
