"""
MonetizationManager tests for GoDig endless digging game.

Tests verify that MonetizationManager:
1. Exists as an autoload singleton
2. Has proper ad eligibility gating (unlocked after criteria met)
3. Tracks IAP and ad analytics
4. Respects first-loop-complete monetization gate
5. Has reset functionality
6. Has all required signals

Reference: Session 29 research on D1 retention focus - no monetization until player is invested.
"""
import pytest
from helpers import PATHS


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_monetization_manager_exists(game):
    """MonetizationManager autoload should exist."""
    result = await game.node_exists(PATHS["monetization_manager"])
    assert result.get("exists") is True, "MonetizationManager autoload should exist"


# =============================================================================
# INITIAL STATE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_initial_monetization_locked(game):
    """MonetizationManager should start with monetization locked."""
    # Reset to ensure clean state
    await game.call(PATHS["monetization_manager"], "reset")

    is_unlocked = await game.call(PATHS["monetization_manager"], "is_monetization_unlocked")
    assert is_unlocked is False, "Monetization should be locked initially (D1 retention focus)"


@pytest.mark.asyncio
async def test_initial_zero_successful_runs(game):
    """MonetizationManager should start with zero successful runs tracked."""
    # Reset to ensure clean state
    await game.call(PATHS["monetization_manager"], "reset")

    # Get save data to check internal state
    data = await game.call(PATHS["monetization_manager"], "get_save_data")
    assert data is not None, "get_save_data should return a value"
    assert data.get("successful_runs", -1) == 0, f"Should have 0 successful runs initially, got {data.get('successful_runs')}"


@pytest.mark.asyncio
async def test_initial_zero_playtime(game):
    """MonetizationManager should start with zero playtime tracked."""
    # Reset to ensure clean state
    await game.call(PATHS["monetization_manager"], "reset")

    data = await game.call(PATHS["monetization_manager"], "get_save_data")
    assert data is not None, "get_save_data should return a value"
    assert data.get("total_playtime_seconds", -1) == 0.0, f"Should have 0 playtime initially, got {data.get('total_playtime_seconds')}"


@pytest.mark.asyncio
async def test_initial_zero_ad_stats(game):
    """MonetizationManager should start with zero ad statistics."""
    # Reset to ensure clean state
    await game.call(PATHS["monetization_manager"], "reset")

    data = await game.call(PATHS["monetization_manager"], "get_save_data")
    assert data.get("ads_offered", -1) == 0, "Should have 0 ads offered initially"
    assert data.get("ads_watched", -1) == 0, "Should have 0 ads watched initially"
    assert data.get("ads_declined", -1) == 0, "Should have 0 ads declined initially"


# =============================================================================
# AD ELIGIBILITY GATING TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_monetization_locked_with_one_run(game):
    """Monetization should stay locked with only 1 successful run (need 3+)."""
    # Reset to ensure clean state
    await game.call(PATHS["monetization_manager"], "reset")

    # Track 1 successful run
    await game.call(PATHS["monetization_manager"], "track_successful_run")

    is_unlocked = await game.call(PATHS["monetization_manager"], "is_monetization_unlocked")
    assert is_unlocked is False, "Monetization should be locked with only 1 run (need 3+)"


@pytest.mark.asyncio
async def test_monetization_locked_with_two_runs(game):
    """Monetization should stay locked with only 2 successful runs (need 3+)."""
    # Reset to ensure clean state
    await game.call(PATHS["monetization_manager"], "reset")

    # Track 2 successful runs
    await game.call(PATHS["monetization_manager"], "track_successful_run")
    await game.call(PATHS["monetization_manager"], "track_successful_run")

    is_unlocked = await game.call(PATHS["monetization_manager"], "is_monetization_unlocked")
    assert is_unlocked is False, "Monetization should be locked with only 2 runs (need 3+)"


@pytest.mark.asyncio
async def test_monetization_unlocked_with_three_runs(game):
    """Monetization should unlock after 3 successful runs (Path 2 criterion)."""
    # Reset to ensure clean state
    await game.call(PATHS["monetization_manager"], "reset")

    # Track 3 successful runs
    await game.call(PATHS["monetization_manager"], "track_successful_run")
    await game.call(PATHS["monetization_manager"], "track_successful_run")
    await game.call(PATHS["monetization_manager"], "track_successful_run")

    is_unlocked = await game.call(PATHS["monetization_manager"], "is_monetization_unlocked")
    assert is_unlocked is True, "Monetization should unlock after 3 successful runs"


@pytest.mark.asyncio
async def test_successful_run_count_increments(game):
    """track_successful_run should increment the run counter."""
    # Reset to ensure clean state
    await game.call(PATHS["monetization_manager"], "reset")

    # Track runs
    await game.call(PATHS["monetization_manager"], "track_successful_run")
    await game.call(PATHS["monetization_manager"], "track_successful_run")

    data = await game.call(PATHS["monetization_manager"], "get_save_data")
    assert data.get("successful_runs") == 2, f"Should have 2 successful runs, got {data.get('successful_runs')}"


# =============================================================================
# STUCK OFFER TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_check_stuck_offer_returns_false_when_locked(game):
    """check_stuck_offer should return false when monetization is locked."""
    # Reset to ensure clean state
    await game.call(PATHS["monetization_manager"], "reset")

    # Try to check stuck offer when locked (deep, low ladders, low health)
    result = await game.call(PATHS["monetization_manager"], "check_stuck_offer", [100, 0, 0.1])
    assert result is False, "check_stuck_offer should return false when monetization is locked"


@pytest.mark.asyncio
async def test_check_stuck_offer_available_when_unlocked(game):
    """check_stuck_offer should return true when unlocked and player is stuck."""
    # Reset and unlock monetization
    await game.call(PATHS["monetization_manager"], "reset")
    await game.call(PATHS["monetization_manager"], "track_successful_run")
    await game.call(PATHS["monetization_manager"], "track_successful_run")
    await game.call(PATHS["monetization_manager"], "track_successful_run")

    # Check stuck offer when deeply stuck (depth 100, 0 ladders, 10% health)
    result = await game.call(PATHS["monetization_manager"], "check_stuck_offer", [100, 0, 0.1])
    assert result is True, "check_stuck_offer should return true when unlocked and player is stuck"


@pytest.mark.asyncio
async def test_check_stuck_offer_false_when_not_stuck(game):
    """check_stuck_offer should return false when player is not stuck."""
    # Reset and unlock monetization
    await game.call(PATHS["monetization_manager"], "reset")
    await game.call(PATHS["monetization_manager"], "track_successful_run")
    await game.call(PATHS["monetization_manager"], "track_successful_run")
    await game.call(PATHS["monetization_manager"], "track_successful_run")

    # Not stuck: shallow depth
    result = await game.call(PATHS["monetization_manager"], "check_stuck_offer", [10, 5, 1.0])
    assert result is False, "check_stuck_offer should return false when player is shallow"


# =============================================================================
# AD TRACKING TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_ad_completed_increments_watched(game):
    """on_rewarded_ad_completed should increment ads watched counter."""
    # Reset and unlock monetization
    await game.call(PATHS["monetization_manager"], "reset")
    await game.call(PATHS["monetization_manager"], "track_successful_run")
    await game.call(PATHS["monetization_manager"], "track_successful_run")
    await game.call(PATHS["monetization_manager"], "track_successful_run")

    # Show an offer first to set pending offer type
    await game.call(PATHS["monetization_manager"], "show_stuck_recovery_offer")

    # Complete the ad
    await game.call(PATHS["monetization_manager"], "on_rewarded_ad_completed")

    data = await game.call(PATHS["monetization_manager"], "get_save_data")
    assert data.get("ads_watched") == 1, f"Should have 1 ad watched, got {data.get('ads_watched')}"


@pytest.mark.asyncio
async def test_ad_declined_increments_declined(game):
    """on_rewarded_ad_declined should increment ads declined counter."""
    # Reset and unlock monetization
    await game.call(PATHS["monetization_manager"], "reset")
    await game.call(PATHS["monetization_manager"], "track_successful_run")
    await game.call(PATHS["monetization_manager"], "track_successful_run")
    await game.call(PATHS["monetization_manager"], "track_successful_run")

    # Show an offer first to set pending offer type
    await game.call(PATHS["monetization_manager"], "show_stuck_recovery_offer")

    # Decline the ad
    await game.call(PATHS["monetization_manager"], "on_rewarded_ad_declined")

    data = await game.call(PATHS["monetization_manager"], "get_save_data")
    assert data.get("ads_declined") == 1, f"Should have 1 ad declined, got {data.get('ads_declined')}"


@pytest.mark.asyncio
async def test_show_stuck_recovery_offer_increments_offered(game):
    """show_stuck_recovery_offer should increment ads offered counter."""
    # Reset and unlock monetization
    await game.call(PATHS["monetization_manager"], "reset")
    await game.call(PATHS["monetization_manager"], "track_successful_run")
    await game.call(PATHS["monetization_manager"], "track_successful_run")
    await game.call(PATHS["monetization_manager"], "track_successful_run")

    # Show an offer
    await game.call(PATHS["monetization_manager"], "show_stuck_recovery_offer")

    data = await game.call(PATHS["monetization_manager"], "get_save_data")
    assert data.get("ads_offered") == 1, f"Should have 1 ad offered, got {data.get('ads_offered')}"


# =============================================================================
# CONVERSION RATE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_conversion_rate_zero_when_no_offers(game):
    """get_ad_conversion_rate should return 0 when no ads offered."""
    # Reset to ensure clean state
    await game.call(PATHS["monetization_manager"], "reset")

    rate = await game.call(PATHS["monetization_manager"], "get_ad_conversion_rate")
    assert rate == 0.0, f"Conversion rate should be 0 when no ads offered, got {rate}"


@pytest.mark.asyncio
async def test_conversion_rate_calculation(game):
    """get_ad_conversion_rate should correctly calculate watched/offered ratio."""
    # Reset and unlock monetization
    await game.call(PATHS["monetization_manager"], "reset")
    await game.call(PATHS["monetization_manager"], "track_successful_run")
    await game.call(PATHS["monetization_manager"], "track_successful_run")
    await game.call(PATHS["monetization_manager"], "track_successful_run")

    # Offer and complete 2 ads
    await game.call(PATHS["monetization_manager"], "show_stuck_recovery_offer")
    await game.call(PATHS["monetization_manager"], "on_rewarded_ad_completed")
    await game.call(PATHS["monetization_manager"], "show_stuck_recovery_offer")
    await game.call(PATHS["monetization_manager"], "on_rewarded_ad_completed")

    # Offer and decline 2 ads
    await game.call(PATHS["monetization_manager"], "show_stuck_recovery_offer")
    await game.call(PATHS["monetization_manager"], "on_rewarded_ad_declined")
    await game.call(PATHS["monetization_manager"], "show_stuck_recovery_offer")
    await game.call(PATHS["monetization_manager"], "on_rewarded_ad_declined")

    # Conversion rate should be 2/4 = 0.5
    rate = await game.call(PATHS["monetization_manager"], "get_ad_conversion_rate")
    assert rate == 0.5, f"Conversion rate should be 0.5 (2 watched / 4 offered), got {rate}"


# =============================================================================
# ANALYTICS DATA TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_analytics_data_returns_dict(game):
    """get_analytics_data should return dictionary with all required fields."""
    data = await game.call(PATHS["monetization_manager"], "get_analytics_data")
    assert data is not None, "get_analytics_data should return a value"
    assert isinstance(data, dict), f"get_analytics_data should return dict, got {type(data)}"


@pytest.mark.asyncio
async def test_get_analytics_data_has_required_fields(game):
    """get_analytics_data should include all required analytics fields."""
    data = await game.call(PATHS["monetization_manager"], "get_analytics_data")

    required_fields = [
        "monetization_unlocked",
        "successful_runs",
        "total_playtime_minutes",
        "ads_offered",
        "ads_watched",
        "ads_declined",
        "conversion_rate",
    ]

    for field in required_fields:
        assert field in data, f"Analytics data should include '{field}'"


# =============================================================================
# SAVE/LOAD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_save_data_returns_dict(game):
    """get_save_data should return dictionary with persistence data."""
    data = await game.call(PATHS["monetization_manager"], "get_save_data")
    assert data is not None, "get_save_data should return a value"
    assert isinstance(data, dict), f"get_save_data should return dict, got {type(data)}"


@pytest.mark.asyncio
async def test_get_save_data_has_required_fields(game):
    """get_save_data should include all required persistence fields."""
    data = await game.call(PATHS["monetization_manager"], "get_save_data")

    required_fields = [
        "monetization_unlocked",
        "successful_runs",
        "total_playtime_seconds",
        "ads_offered",
        "ads_watched",
        "ads_declined",
    ]

    for field in required_fields:
        assert field in data, f"Save data should include '{field}'"


@pytest.mark.asyncio
async def test_load_save_data_restores_state(game):
    """load_save_data should restore monetization state."""
    # Reset first
    await game.call(PATHS["monetization_manager"], "reset")

    # Load save data with specific values
    test_data = {
        "monetization_unlocked": True,
        "successful_runs": 5,
        "total_playtime_seconds": 900.0,
        "ads_offered": 10,
        "ads_watched": 7,
        "ads_declined": 3,
    }
    await game.call(PATHS["monetization_manager"], "load_save_data", [test_data])

    # Verify state was restored
    is_unlocked = await game.call(PATHS["monetization_manager"], "is_monetization_unlocked")
    assert is_unlocked is True, "Monetization should be unlocked after load"

    data = await game.call(PATHS["monetization_manager"], "get_save_data")
    assert data.get("successful_runs") == 5, f"successful_runs should be 5, got {data.get('successful_runs')}"
    assert data.get("total_playtime_seconds") == 900.0, f"total_playtime_seconds should be 900, got {data.get('total_playtime_seconds')}"
    assert data.get("ads_offered") == 10, f"ads_offered should be 10, got {data.get('ads_offered')}"
    assert data.get("ads_watched") == 7, f"ads_watched should be 7, got {data.get('ads_watched')}"
    assert data.get("ads_declined") == 3, f"ads_declined should be 3, got {data.get('ads_declined')}"


# =============================================================================
# RESET TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_reset_clears_monetization_state(game):
    """reset() should clear all monetization state."""
    # First set up some state
    await game.call(PATHS["monetization_manager"], "track_successful_run")
    await game.call(PATHS["monetization_manager"], "track_successful_run")
    await game.call(PATHS["monetization_manager"], "track_successful_run")

    # Now reset
    await game.call(PATHS["monetization_manager"], "reset")

    # Verify everything is reset
    is_unlocked = await game.call(PATHS["monetization_manager"], "is_monetization_unlocked")
    assert is_unlocked is False, "Monetization should be locked after reset"

    data = await game.call(PATHS["monetization_manager"], "get_save_data")
    assert data.get("successful_runs") == 0, "successful_runs should be 0 after reset"
    assert data.get("total_playtime_seconds") == 0.0, "total_playtime_seconds should be 0 after reset"
    assert data.get("ads_offered") == 0, "ads_offered should be 0 after reset"
    assert data.get("ads_watched") == 0, "ads_watched should be 0 after reset"
    assert data.get("ads_declined") == 0, "ads_declined should be 0 after reset"


@pytest.mark.asyncio
async def test_reset_clears_pending_offer(game):
    """reset() should clear any pending ad offer."""
    # Unlock and show an offer
    await game.call(PATHS["monetization_manager"], "track_successful_run")
    await game.call(PATHS["monetization_manager"], "track_successful_run")
    await game.call(PATHS["monetization_manager"], "track_successful_run")
    await game.call(PATHS["monetization_manager"], "show_stuck_recovery_offer")

    # Reset
    await game.call(PATHS["monetization_manager"], "reset")

    # Unlock again and verify we can show a new offer (wouldn't work if old one still pending)
    await game.call(PATHS["monetization_manager"], "track_successful_run")
    await game.call(PATHS["monetization_manager"], "track_successful_run")
    await game.call(PATHS["monetization_manager"], "track_successful_run")

    # This should work now since pending offer was cleared
    result = await game.call(PATHS["monetization_manager"], "check_stuck_offer", [100, 0, 0.1])
    assert result is True, "Should be able to check stuck offer after reset cleared pending offer"


# =============================================================================
# SIGNAL EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_monetization_unlocked_signal(game):
    """MonetizationManager should have monetization_unlocked signal."""
    has_signal = await game.call(PATHS["monetization_manager"], "has_signal", ["monetization_unlocked"])
    assert has_signal is True, "MonetizationManager should have monetization_unlocked signal"


@pytest.mark.asyncio
async def test_has_rewarded_ad_available_signal(game):
    """MonetizationManager should have rewarded_ad_available signal."""
    has_signal = await game.call(PATHS["monetization_manager"], "has_signal", ["rewarded_ad_available"])
    assert has_signal is True, "MonetizationManager should have rewarded_ad_available signal"


@pytest.mark.asyncio
async def test_has_rewarded_ad_completed_signal(game):
    """MonetizationManager should have rewarded_ad_completed signal."""
    has_signal = await game.call(PATHS["monetization_manager"], "has_signal", ["rewarded_ad_completed"])
    assert has_signal is True, "MonetizationManager should have rewarded_ad_completed signal"


@pytest.mark.asyncio
async def test_has_rewarded_ad_declined_signal(game):
    """MonetizationManager should have rewarded_ad_declined signal."""
    has_signal = await game.call(PATHS["monetization_manager"], "has_signal", ["rewarded_ad_declined"])
    assert has_signal is True, "MonetizationManager should have rewarded_ad_declined signal"


# =============================================================================
# CONSTANTS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_gate_min_successful_runs_constant(game):
    """GATE_MIN_SUCCESSFUL_RUNS should be configured (3 by default)."""
    result = await game.get_property(PATHS["monetization_manager"], "GATE_MIN_SUCCESSFUL_RUNS")
    assert result is not None, "GATE_MIN_SUCCESSFUL_RUNS should exist"
    assert result == 3, f"GATE_MIN_SUCCESSFUL_RUNS should be 3, got {result}"


@pytest.mark.asyncio
async def test_gate_min_playtime_seconds_constant(game):
    """GATE_MIN_PLAYTIME_SECONDS should be configured (15 minutes by default)."""
    result = await game.get_property(PATHS["monetization_manager"], "GATE_MIN_PLAYTIME_SECONDS")
    assert result is not None, "GATE_MIN_PLAYTIME_SECONDS should exist"
    assert result == 15.0 * 60.0, f"GATE_MIN_PLAYTIME_SECONDS should be 900 (15 min), got {result}"


@pytest.mark.asyncio
async def test_reward_stuck_ladders_constant(game):
    """REWARD_STUCK_LADDERS should be configured."""
    result = await game.get_property(PATHS["monetization_manager"], "REWARD_STUCK_LADDERS")
    assert result is not None, "REWARD_STUCK_LADDERS should exist"
    assert result > 0, f"REWARD_STUCK_LADDERS should be positive, got {result}"


@pytest.mark.asyncio
async def test_reward_coin_boost_pct_constant(game):
    """REWARD_COIN_BOOST_PCT should be configured."""
    result = await game.get_property(PATHS["monetization_manager"], "REWARD_COIN_BOOST_PCT")
    assert result is not None, "REWARD_COIN_BOOST_PCT should exist"
    assert 0 < result <= 1, f"REWARD_COIN_BOOST_PCT should be between 0 and 1, got {result}"


@pytest.mark.asyncio
async def test_reward_revive_hp_pct_constant(game):
    """REWARD_REVIVE_HP_PCT should be configured."""
    result = await game.get_property(PATHS["monetization_manager"], "REWARD_REVIVE_HP_PCT")
    assert result is not None, "REWARD_REVIVE_HP_PCT should exist"
    assert 0 < result <= 1, f"REWARD_REVIVE_HP_PCT should be between 0 and 1, got {result}"
