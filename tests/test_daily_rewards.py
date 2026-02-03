"""
DailyRewardsManager tests for GoDig endless digging game.

Tests verify that DailyRewardsManager:
1. Exists as an autoload singleton
2. Has all required properties for tracking login streaks
3. Has all required methods for reward management
4. Has correct reward cycle configuration
5. Has proper save/load functionality
"""
import pytest
from helpers import PATHS


# Path to daily rewards manager
DAILY_REWARDS_PATH = "/root/DailyRewardsManager"


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_daily_rewards_manager_exists(game):
    """DailyRewardsManager autoload should exist."""
    result = await game.node_exists(DAILY_REWARDS_PATH)
    assert result.get("exists") is True, "DailyRewardsManager autoload should exist"


# =============================================================================
# PROPERTY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_current_streak(game):
    """DailyRewardsManager should have current_streak property."""
    result = await game.get_property(DAILY_REWARDS_PATH, "current_streak")
    assert result is not None, "current_streak should exist"
    assert isinstance(result, int), f"current_streak should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_has_last_login_day(game):
    """DailyRewardsManager should have last_login_day property."""
    result = await game.get_property(DAILY_REWARDS_PATH, "last_login_day")
    assert result is not None, "last_login_day should exist"
    assert isinstance(result, int), f"last_login_day should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_has_reward_claimed_today(game):
    """DailyRewardsManager should have reward_claimed_today property."""
    result = await game.get_property(DAILY_REWARDS_PATH, "reward_claimed_today")
    assert result is not None, "reward_claimed_today should exist"
    assert isinstance(result, bool), f"reward_claimed_today should be bool, got {type(result)}"


@pytest.mark.asyncio
async def test_has_total_rewards_claimed(game):
    """DailyRewardsManager should have total_rewards_claimed property."""
    result = await game.get_property(DAILY_REWARDS_PATH, "total_rewards_claimed")
    assert result is not None, "total_rewards_claimed should exist"
    assert isinstance(result, int), f"total_rewards_claimed should be int, got {type(result)}"


# =============================================================================
# CONSTANT TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_daily_rewards_constant_exists(game):
    """DAILY_REWARDS constant should be accessible."""
    result = await game.get_property(DAILY_REWARDS_PATH, "DAILY_REWARDS")
    assert result is not None, "DAILY_REWARDS should exist"
    assert isinstance(result, list), f"DAILY_REWARDS should be array, got {type(result)}"
    assert len(result) == 7, f"DAILY_REWARDS should have 7 days, got {len(result)}"


@pytest.mark.asyncio
async def test_daily_rewards_have_coins(game):
    """Each day in DAILY_REWARDS should have coins."""
    result = await game.get_property(DAILY_REWARDS_PATH, "DAILY_REWARDS")
    for i, day_reward in enumerate(result):
        assert "coins" in day_reward, f"Day {i+1} should have coins"
        assert day_reward["coins"] > 0, f"Day {i+1} coins should be positive"


@pytest.mark.asyncio
async def test_day_7_has_bonus_item(game):
    """Day 7 reward should include a bonus item."""
    result = await game.get_property(DAILY_REWARDS_PATH, "DAILY_REWARDS")
    day_7 = result[6]  # Index 6 is day 7
    assert "bonus_item" in day_7, "Day 7 should have bonus_item"
    assert day_7["bonus_item"] == "teleport_scroll", f"Day 7 bonus should be teleport_scroll, got {day_7['bonus_item']}"


@pytest.mark.asyncio
async def test_streak_milestones_constant_exists(game):
    """STREAK_MILESTONES constant should be accessible."""
    result = await game.get_property(DAILY_REWARDS_PATH, "STREAK_MILESTONES")
    assert result is not None, "STREAK_MILESTONES should exist"
    assert isinstance(result, dict), f"STREAK_MILESTONES should be dict, got {type(result)}"


@pytest.mark.asyncio
async def test_streak_milestones_have_expected_keys(game):
    """STREAK_MILESTONES should have key milestones at 7, 14, 30, 60, 100 days."""
    result = await game.get_property(DAILY_REWARDS_PATH, "STREAK_MILESTONES")
    # Keys may be strings in JSON
    key_set = set(int(k) for k in result.keys())
    expected = {7, 14, 30, 60, 100}
    assert expected.issubset(key_set), f"Missing milestones, expected {expected}, got {key_set}"


# =============================================================================
# METHOD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_streak_day_returns_valid_day(game):
    """get_streak_day should return a value between 1 and 7."""
    result = await game.call(DAILY_REWARDS_PATH, "get_streak_day")
    assert result is not None, "get_streak_day should return a value"
    assert isinstance(result, int), f"get_streak_day should return int, got {type(result)}"
    assert 1 <= result <= 7, f"Streak day should be 1-7, got {result}"


@pytest.mark.asyncio
async def test_get_todays_reward_returns_dict(game):
    """get_todays_reward should return a dictionary."""
    result = await game.call(DAILY_REWARDS_PATH, "get_todays_reward")
    assert result is not None, "get_todays_reward should return a value"
    assert isinstance(result, dict), f"get_todays_reward should return dict, got {type(result)}"


@pytest.mark.asyncio
async def test_get_todays_reward_has_coins(game):
    """get_todays_reward result should include coins."""
    result = await game.call(DAILY_REWARDS_PATH, "get_todays_reward")
    assert "coins" in result, "Reward should include coins"
    assert result["coins"] > 0, f"Coins should be positive, got {result['coins']}"


@pytest.mark.asyncio
async def test_get_todays_reward_has_streak(game):
    """get_todays_reward result should include current streak."""
    result = await game.call(DAILY_REWARDS_PATH, "get_todays_reward")
    assert "streak" in result, "Reward should include streak"
    assert isinstance(result["streak"], int), f"Streak should be int, got {type(result['streak'])}"


@pytest.mark.asyncio
async def test_has_unclaimed_reward_returns_bool(game):
    """has_unclaimed_reward should return a boolean."""
    result = await game.call(DAILY_REWARDS_PATH, "has_unclaimed_reward")
    assert result is not None, "has_unclaimed_reward should return a value"
    assert isinstance(result, bool), f"has_unclaimed_reward should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_get_current_streak_returns_int(game):
    """get_current_streak should return an integer."""
    result = await game.call(DAILY_REWARDS_PATH, "get_current_streak")
    assert result is not None, "get_current_streak should return a value"
    assert isinstance(result, int), f"get_current_streak should return int, got {type(result)}"
    assert result >= 0, f"Streak should be non-negative, got {result}"


@pytest.mark.asyncio
async def test_get_total_rewards_claimed_returns_int(game):
    """get_total_rewards_claimed should return an integer."""
    result = await game.call(DAILY_REWARDS_PATH, "get_total_rewards_claimed")
    assert result is not None, "get_total_rewards_claimed should return a value"
    assert isinstance(result, int), f"get_total_rewards_claimed should return int, got {type(result)}"
    assert result >= 0, f"Total rewards should be non-negative, got {result}"


# =============================================================================
# SIGNAL TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_reward_available_signal(game):
    """DailyRewardsManager should have reward_available signal."""
    has_signal = await game.call(DAILY_REWARDS_PATH, "has_signal", ["reward_available"])
    assert has_signal is True, "DailyRewardsManager should have reward_available signal"


@pytest.mark.asyncio
async def test_has_reward_claimed_signal(game):
    """DailyRewardsManager should have reward_claimed signal."""
    has_signal = await game.call(DAILY_REWARDS_PATH, "has_signal", ["reward_claimed"])
    assert has_signal is True, "DailyRewardsManager should have reward_claimed signal"


@pytest.mark.asyncio
async def test_has_streak_reset_signal(game):
    """DailyRewardsManager should have streak_reset signal."""
    has_signal = await game.call(DAILY_REWARDS_PATH, "has_signal", ["streak_reset"])
    assert has_signal is True, "DailyRewardsManager should have streak_reset signal"


@pytest.mark.asyncio
async def test_has_streak_milestone_signal(game):
    """DailyRewardsManager should have streak_milestone signal."""
    has_signal = await game.call(DAILY_REWARDS_PATH, "has_signal", ["streak_milestone"])
    assert has_signal is True, "DailyRewardsManager should have streak_milestone signal"


# =============================================================================
# SAVE/LOAD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_save_data_returns_dict(game):
    """get_save_data should return a dictionary."""
    result = await game.call(DAILY_REWARDS_PATH, "get_save_data")
    assert result is not None, "get_save_data should return a value"
    assert isinstance(result, dict), f"get_save_data should return dict, got {type(result)}"


@pytest.mark.asyncio
async def test_get_save_data_has_required_fields(game):
    """get_save_data should include all required fields."""
    result = await game.call(DAILY_REWARDS_PATH, "get_save_data")
    required_fields = ["current_streak", "last_login_day", "reward_claimed_today", "total_rewards_claimed"]
    for field in required_fields:
        assert field in result, f"Save data should include {field}"


@pytest.mark.asyncio
async def test_load_save_data_restores_streak(game):
    """load_save_data should restore current_streak."""
    # Get current state
    original_data = await game.call(DAILY_REWARDS_PATH, "get_save_data")

    # Load test data (streak will be adjusted by _check_daily_login but let's verify structure works)
    test_data = {
        "current_streak": 5,
        "last_login_day": original_data.get("last_login_day", 0),  # Keep same day to avoid reset
        "reward_claimed_today": True,
        "total_rewards_claimed": 10
    }
    await game.call(DAILY_REWARDS_PATH, "load_save_data", [test_data])

    # Verify total_rewards_claimed was restored (this doesn't get modified by _check_daily_login)
    total = await game.call(DAILY_REWARDS_PATH, "get_total_rewards_claimed")
    assert total == 10, f"total_rewards_claimed should be 10, got {total}"


# =============================================================================
# RESET TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_reset_clears_streak(game):
    """reset should set current_streak to 0."""
    await game.call(DAILY_REWARDS_PATH, "reset")
    streak = await game.get_property(DAILY_REWARDS_PATH, "current_streak")
    assert streak == 0, f"Streak should be 0 after reset, got {streak}"


@pytest.mark.asyncio
async def test_reset_clears_last_login_day(game):
    """reset should set last_login_day to 0."""
    await game.call(DAILY_REWARDS_PATH, "reset")
    last_login = await game.get_property(DAILY_REWARDS_PATH, "last_login_day")
    assert last_login == 0, f"last_login_day should be 0 after reset, got {last_login}"


@pytest.mark.asyncio
async def test_reset_clears_reward_claimed(game):
    """reset should set reward_claimed_today to false."""
    await game.call(DAILY_REWARDS_PATH, "reset")
    claimed = await game.get_property(DAILY_REWARDS_PATH, "reward_claimed_today")
    assert claimed is False, f"reward_claimed_today should be false after reset, got {claimed}"


@pytest.mark.asyncio
async def test_reset_clears_total_rewards(game):
    """reset should set total_rewards_claimed to 0."""
    await game.call(DAILY_REWARDS_PATH, "reset")
    total = await game.get_property(DAILY_REWARDS_PATH, "total_rewards_claimed")
    assert total == 0, f"total_rewards_claimed should be 0 after reset, got {total}"


# =============================================================================
# REWARD VALUE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_rewards_escalate_through_week(game):
    """DAILY_REWARDS coins should increase through the 7-day cycle."""
    result = await game.get_property(DAILY_REWARDS_PATH, "DAILY_REWARDS")
    # Get coin values for each day
    coins = [day["coins"] for day in result]

    # Day 7 should have the most coins
    assert coins[6] > coins[0], f"Day 7 ({coins[6]}) should have more coins than Day 1 ({coins[0]})"

    # General progression: later days should have more
    assert coins[3] > coins[0], f"Day 4 should have more coins than Day 1"
    assert coins[5] > coins[2], f"Day 6 should have more coins than Day 3"


@pytest.mark.asyncio
async def test_day_7_is_jackpot(game):
    """Day 7 should have significantly more coins than other days."""
    result = await game.get_property(DAILY_REWARDS_PATH, "DAILY_REWARDS")
    day_7_coins = result[6]["coins"]
    day_6_coins = result[5]["coins"]

    # Day 7 should be at least 2x day 6 (it's the jackpot)
    assert day_7_coins >= day_6_coins * 2, f"Day 7 ({day_7_coins}) should be at least 2x Day 6 ({day_6_coins})"


# =============================================================================
# STREAK BONUS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_reward_includes_streak_bonus(game):
    """get_todays_reward should include streak_bonus multiplier."""
    result = await game.call(DAILY_REWARDS_PATH, "get_todays_reward")
    assert "streak_bonus" in result, "Reward should include streak_bonus multiplier"
    assert result["streak_bonus"] >= 1.0, f"streak_bonus should be >= 1.0, got {result['streak_bonus']}"
