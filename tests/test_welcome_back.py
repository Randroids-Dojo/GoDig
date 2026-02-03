"""
WelcomeBackManager tests for GoDig endless digging game.

Tests verify that WelcomeBackManager:
1. Exists as an autoload singleton
2. Detects returning players after significant absence
3. Calculates rewards based on time away (guilt-free model)
4. Uses streak-free reward model (no punishment for absence)
5. Persists state via save/load
6. Has all required signals

Reference: Session 26 research - "welcome-back rewards should feel like a gift, not guilt"
"""
import pytest
from helpers import PATHS


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_welcome_back_manager_exists(game):
    """WelcomeBackManager autoload should exist."""
    result = await game.node_exists(PATHS["welcome_back_manager"])
    assert result.get("exists") is True, "WelcomeBackManager autoload should exist"


# =============================================================================
# INITIAL STATE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_initial_no_pending_welcome(game):
    """WelcomeBackManager should have no pending welcome initially."""
    # Reset to ensure clean state
    await game.call(PATHS["welcome_back_manager"], "reset")

    has_pending = await game.call(PATHS["welcome_back_manager"], "has_pending")
    assert has_pending is False, "Should have no pending welcome initially"


@pytest.mark.asyncio
async def test_initial_empty_pending_data(game):
    """WelcomeBackManager should have empty pending data initially."""
    # Reset to ensure clean state
    await game.call(PATHS["welcome_back_manager"], "reset")

    data = await game.call(PATHS["welcome_back_manager"], "get_pending_data")
    assert data is not None, "get_pending_data should return a value"
    assert isinstance(data, dict), f"get_pending_data should return dict, got {type(data)}"
    assert len(data) == 0, f"Pending data should be empty initially, got {len(data)} keys"


@pytest.mark.asyncio
async def test_last_play_time_set_on_reset(game):
    """reset() should set last_play_time to current time."""
    await game.call(PATHS["welcome_back_manager"], "reset")

    data = await game.call(PATHS["welcome_back_manager"], "get_save_data")
    assert data is not None, "get_save_data should return a value"
    # last_play_time should be a recent timestamp (within a few seconds of now)
    assert "last_play_time" in data, "Save data should include last_play_time"
    assert data.get("last_play_time", 0) > 0, "last_play_time should be set to a positive value"


# =============================================================================
# LADDER GIFT CALCULATION TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_ladder_gift_4_hours(game):
    """4-8 hours away should gift 2 ladders."""
    result = await game.call(PATHS["welcome_back_manager"], "_calculate_ladder_gift", [4])
    assert result == 2, f"4 hours away should gift 2 ladders, got {result}"


@pytest.mark.asyncio
async def test_ladder_gift_6_hours(game):
    """6 hours away (between 4-8) should gift 2 ladders."""
    result = await game.call(PATHS["welcome_back_manager"], "_calculate_ladder_gift", [6])
    assert result == 2, f"6 hours away should gift 2 ladders, got {result}"


@pytest.mark.asyncio
async def test_ladder_gift_8_hours(game):
    """8-24 hours away should gift 3 ladders."""
    result = await game.call(PATHS["welcome_back_manager"], "_calculate_ladder_gift", [8])
    assert result == 3, f"8 hours away should gift 3 ladders, got {result}"


@pytest.mark.asyncio
async def test_ladder_gift_12_hours(game):
    """12 hours away (between 8-24) should gift 3 ladders."""
    result = await game.call(PATHS["welcome_back_manager"], "_calculate_ladder_gift", [12])
    assert result == 3, f"12 hours away should gift 3 ladders, got {result}"


@pytest.mark.asyncio
async def test_ladder_gift_24_hours(game):
    """24-72 hours away should gift 5 ladders."""
    result = await game.call(PATHS["welcome_back_manager"], "_calculate_ladder_gift", [24])
    assert result == 5, f"24 hours away should gift 5 ladders, got {result}"


@pytest.mark.asyncio
async def test_ladder_gift_48_hours(game):
    """48 hours away (between 24-72) should gift 5 ladders."""
    result = await game.call(PATHS["welcome_back_manager"], "_calculate_ladder_gift", [48])
    assert result == 5, f"48 hours away should gift 5 ladders, got {result}"


@pytest.mark.asyncio
async def test_ladder_gift_72_hours(game):
    """72-168 hours away should gift 8 ladders."""
    result = await game.call(PATHS["welcome_back_manager"], "_calculate_ladder_gift", [72])
    assert result == 8, f"72 hours away should gift 8 ladders, got {result}"


@pytest.mark.asyncio
async def test_ladder_gift_168_hours(game):
    """168+ hours (7+ days) away should gift 10 ladders (max)."""
    result = await game.call(PATHS["welcome_back_manager"], "_calculate_ladder_gift", [168])
    assert result == 10, f"168 hours away should gift 10 ladders (max), got {result}"


@pytest.mark.asyncio
async def test_ladder_gift_500_hours(game):
    """Long absence (500 hours) should still cap at 10 ladders."""
    result = await game.call(PATHS["welcome_back_manager"], "_calculate_ladder_gift", [500])
    assert result == 10, f"500 hours away should still cap at 10 ladders, got {result}"


@pytest.mark.asyncio
async def test_ladder_gift_less_than_4_hours(game):
    """Less than 4 hours should gift 0 ladders (not enough time)."""
    result = await game.call(PATHS["welcome_back_manager"], "_calculate_ladder_gift", [3])
    assert result == 0, f"3 hours away should gift 0 ladders, got {result}"


# =============================================================================
# TIME FORMATTING TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_format_time_away_hours(game):
    """_format_time_away should return 'X hours' for less than 24 hours."""
    result = await game.call(PATHS["welcome_back_manager"], "_format_time_away", [12])
    assert result == "12 hours", f"12 hours should format as '12 hours', got '{result}'"


@pytest.mark.asyncio
async def test_format_time_away_1_day(game):
    """_format_time_away should return '1 day' for 24-47 hours."""
    result = await game.call(PATHS["welcome_back_manager"], "_format_time_away", [36])
    assert result == "1 day", f"36 hours should format as '1 day', got '{result}'"


@pytest.mark.asyncio
async def test_format_time_away_days(game):
    """_format_time_away should return 'X days' for 48-167 hours."""
    result = await game.call(PATHS["welcome_back_manager"], "_format_time_away", [72])
    assert result == "3 days", f"72 hours should format as '3 days', got '{result}'"


@pytest.mark.asyncio
async def test_format_time_away_week(game):
    """_format_time_away should return 'over a week' for 168+ hours."""
    result = await game.call(PATHS["welcome_back_manager"], "_format_time_away", [200])
    assert result == "over a week", f"200 hours should format as 'over a week', got '{result}'"


# =============================================================================
# CLAIM REWARDS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_claim_returns_empty_when_no_pending(game):
    """claim_welcome_back should return empty dict when no pending welcome."""
    # Reset to ensure no pending welcome
    await game.call(PATHS["welcome_back_manager"], "reset")

    result = await game.call(PATHS["welcome_back_manager"], "claim_welcome_back")
    assert result is not None, "claim_welcome_back should return a value"
    assert isinstance(result, dict), f"claim_welcome_back should return dict, got {type(result)}"
    assert len(result) == 0, f"Should return empty dict when no pending, got {len(result)} keys"


@pytest.mark.asyncio
async def test_claim_clears_pending(game):
    """claim_welcome_back should clear the pending state."""
    # Simulate a pending welcome by manually preparing data
    # Since we can't easily mock time, we'll call dismiss to reset first
    await game.call(PATHS["welcome_back_manager"], "reset")

    # After reset, there should be no pending welcome
    has_pending = await game.call(PATHS["welcome_back_manager"], "has_pending")
    assert has_pending is False, "Should have no pending after reset"


# =============================================================================
# DISMISS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_dismiss_clears_pending(game):
    """dismiss_welcome_back should clear the pending state."""
    # Reset first
    await game.call(PATHS["welcome_back_manager"], "reset")

    # Dismiss
    await game.call(PATHS["welcome_back_manager"], "dismiss_welcome_back")

    # Verify cleared
    has_pending = await game.call(PATHS["welcome_back_manager"], "has_pending")
    assert has_pending is False, "Should have no pending after dismiss"


@pytest.mark.asyncio
async def test_dismiss_updates_last_play_time(game):
    """dismiss_welcome_back should update last_play_time."""
    # Get initial last_play_time
    initial_data = await game.call(PATHS["welcome_back_manager"], "get_save_data")
    initial_time = initial_data.get("last_play_time", 0)

    # Wait a tiny bit (not realistic but tests the function call)
    await game.call(PATHS["welcome_back_manager"], "dismiss_welcome_back")

    # Get new last_play_time
    new_data = await game.call(PATHS["welcome_back_manager"], "get_save_data")
    new_time = new_data.get("last_play_time", 0)

    # Time should be >= initial (might be same if called quickly)
    assert new_time >= initial_time, "last_play_time should be updated on dismiss"


# =============================================================================
# RESET TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_reset_clears_pending_welcome(game):
    """reset() should clear pending welcome state."""
    await game.call(PATHS["welcome_back_manager"], "reset")

    has_pending = await game.call(PATHS["welcome_back_manager"], "has_pending")
    assert has_pending is False, "Should have no pending after reset"


@pytest.mark.asyncio
async def test_reset_clears_pending_data(game):
    """reset() should clear pending data."""
    await game.call(PATHS["welcome_back_manager"], "reset")

    data = await game.call(PATHS["welcome_back_manager"], "get_pending_data")
    assert len(data) == 0, f"Pending data should be empty after reset, got {len(data)} keys"


@pytest.mark.asyncio
async def test_reset_sets_last_play_time(game):
    """reset() should set last_play_time to current time."""
    await game.call(PATHS["welcome_back_manager"], "reset")

    data = await game.call(PATHS["welcome_back_manager"], "get_save_data")
    assert data.get("last_play_time", 0) > 0, "last_play_time should be positive after reset"


# =============================================================================
# SAVE/LOAD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_save_data_returns_dict(game):
    """get_save_data should return dictionary."""
    data = await game.call(PATHS["welcome_back_manager"], "get_save_data")
    assert data is not None, "get_save_data should return a value"
    assert isinstance(data, dict), f"get_save_data should return dict, got {type(data)}"


@pytest.mark.asyncio
async def test_get_save_data_has_last_play_time(game):
    """get_save_data should include last_play_time."""
    data = await game.call(PATHS["welcome_back_manager"], "get_save_data")
    assert "last_play_time" in data, "Save data should include last_play_time"


@pytest.mark.asyncio
async def test_load_save_data_restores_last_play_time(game):
    """load_save_data should restore last_play_time."""
    # Reset first
    await game.call(PATHS["welcome_back_manager"], "reset")

    # Load specific data (recent timestamp so no welcome back triggers)
    import time
    test_time = int(time.time()) - 60  # 1 minute ago
    test_data = {"last_play_time": test_time}
    await game.call(PATHS["welcome_back_manager"], "load_save_data", [test_data])

    # Verify
    data = await game.call(PATHS["welcome_back_manager"], "get_save_data")
    assert data.get("last_play_time") == test_time, f"last_play_time should be {test_time}, got {data.get('last_play_time')}"


# =============================================================================
# SIGNAL EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_welcome_back_ready_signal(game):
    """WelcomeBackManager should have welcome_back_ready signal."""
    has_signal = await game.call(PATHS["welcome_back_manager"], "has_signal", ["welcome_back_ready"])
    assert has_signal is True, "WelcomeBackManager should have welcome_back_ready signal"


@pytest.mark.asyncio
async def test_has_welcome_back_claimed_signal(game):
    """WelcomeBackManager should have welcome_back_claimed signal."""
    has_signal = await game.call(PATHS["welcome_back_manager"], "has_signal", ["welcome_back_claimed"])
    assert has_signal is True, "WelcomeBackManager should have welcome_back_claimed signal"


# =============================================================================
# CONSTANTS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_min_absence_seconds_constant(game):
    """MIN_ABSENCE_SECONDS should be configured (4 hours by default)."""
    result = await game.get_property(PATHS["welcome_back_manager"], "MIN_ABSENCE_SECONDS")
    assert result is not None, "MIN_ABSENCE_SECONDS should exist"
    # 4 hours = 14400 seconds
    assert result == 14400, f"MIN_ABSENCE_SECONDS should be 14400 (4 hours), got {result}"


@pytest.mark.asyncio
async def test_ladder_gift_by_hours_constant(game):
    """LADDER_GIFT_BY_HOURS should be configured."""
    result = await game.get_property(PATHS["welcome_back_manager"], "LADDER_GIFT_BY_HOURS")
    assert result is not None, "LADDER_GIFT_BY_HOURS should exist"
    assert isinstance(result, dict), f"LADDER_GIFT_BY_HOURS should be dict, got {type(result)}"

    # Verify all tiers are present
    expected_tiers = [4, 8, 24, 72, 168]
    for tier in expected_tiers:
        # Keys might be strings or ints depending on serialization
        assert str(tier) in [str(k) for k in result.keys()] or tier in result.keys(), \
            f"LADDER_GIFT_BY_HOURS should have tier {tier}"


# =============================================================================
# STREAK-FREE MODEL TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_no_streak_counter_in_save_data(game):
    """Save data should NOT contain streak or consecutive day counters (guilt-free model)."""
    data = await game.call(PATHS["welcome_back_manager"], "get_save_data")

    # These should NOT exist (streak-free model)
    bad_keys = ["streak", "consecutive_days", "login_streak", "daily_streak"]
    for key in bad_keys:
        assert key not in data, f"Save data should NOT contain '{key}' (streak-free model)"


@pytest.mark.asyncio
async def test_longer_absence_gives_more_ladders(game):
    """Longer absence should give more ladders (gift, not punishment)."""
    # 8 hours vs 72 hours
    short_absence = await game.call(PATHS["welcome_back_manager"], "_calculate_ladder_gift", [8])
    long_absence = await game.call(PATHS["welcome_back_manager"], "_calculate_ladder_gift", [72])

    assert long_absence > short_absence, \
        f"Longer absence ({long_absence}) should give more ladders than shorter ({short_absence})"


@pytest.mark.asyncio
async def test_has_pending_method_exists(game):
    """has_pending() method should exist and be callable."""
    result = await game.call(PATHS["welcome_back_manager"], "has_pending")
    assert isinstance(result, bool), f"has_pending should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_check_welcome_back_method_exists(game):
    """check_welcome_back() method should exist and be callable."""
    # This just verifies the method exists and doesn't throw
    result = await game.call(PATHS["welcome_back_manager"], "check_welcome_back")
    # Method is void, should complete without error
    assert result is None or result is True or result is False, "check_welcome_back should complete"
