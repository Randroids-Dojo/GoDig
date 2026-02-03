"""
MiningBonusManager tests for GoDig endless digging game.

Tests verify that MiningBonusManager:
1. Exists as an autoload singleton
2. Handles combo system correctly
3. Handles streak zones
4. Handles lucky strike system
5. Has depth milestone rewards configured
6. Handles vein bonus system
7. Has all required signals
"""
import pytest
from helpers import PATHS


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_mining_bonus_manager_exists(game):
    """MiningBonusManager autoload should exist."""
    result = await game.node_exists(PATHS["mining_bonus_manager"])
    assert result.get("exists") is True, "MiningBonusManager autoload should exist"


# =============================================================================
# COMBO SYSTEM TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_initial_combo_count_zero(game):
    """combo_count should be 0 initially."""
    # Reset to ensure clean state
    await game.call(PATHS["mining_bonus_manager"], "reset")

    count = await game.get_property(PATHS["mining_bonus_manager"], "combo_count")
    assert count == 0, f"combo_count should be 0 initially, got {count}"


@pytest.mark.asyncio
async def test_initial_combo_not_active(game):
    """combo_active should be false initially."""
    # Reset to ensure clean state
    await game.call(PATHS["mining_bonus_manager"], "reset")

    active = await game.get_property(PATHS["mining_bonus_manager"], "combo_active")
    assert active is False, f"combo_active should be False initially, got {active}"


@pytest.mark.asyncio
async def test_on_block_mined_increments_combo(game):
    """on_block_mined should increment combo_count."""
    # Reset to ensure clean state
    await game.call(PATHS["mining_bonus_manager"], "reset")

    # Mine a block
    await game.call(PATHS["mining_bonus_manager"], "on_block_mined")

    count = await game.get_property(PATHS["mining_bonus_manager"], "combo_count")
    assert count == 1, f"combo_count should be 1 after one block, got {count}"


@pytest.mark.asyncio
async def test_on_block_mined_activates_combo(game):
    """on_block_mined should set combo_active to true."""
    # Reset to ensure clean state
    await game.call(PATHS["mining_bonus_manager"], "reset")

    # Mine a block
    await game.call(PATHS["mining_bonus_manager"], "on_block_mined")

    active = await game.get_property(PATHS["mining_bonus_manager"], "combo_active")
    assert active is True, f"combo_active should be True after mining, got {active}"


@pytest.mark.asyncio
async def test_on_block_mined_multiple_increments(game):
    """Mining multiple blocks should increment combo_count correctly."""
    # Reset to ensure clean state
    await game.call(PATHS["mining_bonus_manager"], "reset")

    # Mine 5 blocks
    for _ in range(5):
        await game.call(PATHS["mining_bonus_manager"], "on_block_mined")

    count = await game.get_property(PATHS["mining_bonus_manager"], "combo_count")
    assert count == 5, f"combo_count should be 5 after five blocks, got {count}"


@pytest.mark.asyncio
async def test_reset_combo_clears_count(game):
    """reset_combo should set combo_count to 0."""
    # Build up a combo
    await game.call(PATHS["mining_bonus_manager"], "on_block_mined")
    await game.call(PATHS["mining_bonus_manager"], "on_block_mined")

    # Reset combo
    await game.call(PATHS["mining_bonus_manager"], "reset_combo")

    count = await game.get_property(PATHS["mining_bonus_manager"], "combo_count")
    assert count == 0, f"combo_count should be 0 after reset, got {count}"


@pytest.mark.asyncio
async def test_reset_combo_deactivates(game):
    """reset_combo should set combo_active to false."""
    # Build up a combo
    await game.call(PATHS["mining_bonus_manager"], "on_block_mined")

    # Reset combo
    await game.call(PATHS["mining_bonus_manager"], "reset_combo")

    active = await game.get_property(PATHS["mining_bonus_manager"], "combo_active")
    assert active is False, f"combo_active should be False after reset, got {active}"


# =============================================================================
# COMBO MULTIPLIER TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_combo_multiplier_base_is_one(game):
    """get_combo_multiplier should return 1.0 with no combo."""
    # Reset to ensure clean state
    await game.call(PATHS["mining_bonus_manager"], "reset")

    multiplier = await game.call(PATHS["mining_bonus_manager"], "get_combo_multiplier")
    assert multiplier == 1.0, f"Base multiplier should be 1.0, got {multiplier}"


@pytest.mark.asyncio
async def test_combo_multiplier_increases_with_combo(game):
    """get_combo_multiplier should increase with higher combo."""
    # Reset to ensure clean state
    await game.call(PATHS["mining_bonus_manager"], "reset")

    # Mine 5 blocks (BLOCKS_PER_LEVEL = 5)
    for _ in range(5):
        await game.call(PATHS["mining_bonus_manager"], "on_block_mined")

    multiplier = await game.call(PATHS["mining_bonus_manager"], "get_combo_multiplier")
    assert multiplier > 1.0, f"Multiplier should be > 1.0 at 5 blocks, got {multiplier}"


@pytest.mark.asyncio
async def test_combo_multiplier_capped(game):
    """get_combo_multiplier should not exceed MAX_COMBO_MULTIPLIER."""
    # Reset to ensure clean state
    await game.call(PATHS["mining_bonus_manager"], "reset")

    # Mine many blocks
    for _ in range(100):
        await game.call(PATHS["mining_bonus_manager"], "on_block_mined")

    multiplier = await game.call(PATHS["mining_bonus_manager"], "get_combo_multiplier")
    max_mult = await game.get_property(PATHS["mining_bonus_manager"], "MAX_COMBO_MULTIPLIER")
    assert multiplier <= max_mult, f"Multiplier {multiplier} should not exceed max {max_mult}"


# =============================================================================
# STREAK ZONE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_not_in_streak_zone_initially(game):
    """is_in_streak_zone should return false initially."""
    # Reset to ensure clean state
    await game.call(PATHS["mining_bonus_manager"], "reset")

    in_zone = await game.call(PATHS["mining_bonus_manager"], "is_in_streak_zone")
    assert in_zone is False, f"Should not be in streak zone initially, got {in_zone}"


@pytest.mark.asyncio
async def test_enters_streak_zone_at_threshold(game):
    """is_in_streak_zone should return true at STREAK_ZONE_THRESHOLD."""
    # Reset to ensure clean state
    await game.call(PATHS["mining_bonus_manager"], "reset")

    threshold = await game.get_property(PATHS["mining_bonus_manager"], "STREAK_ZONE_THRESHOLD")

    # Mine up to threshold
    for _ in range(threshold):
        await game.call(PATHS["mining_bonus_manager"], "on_block_mined")

    in_zone = await game.call(PATHS["mining_bonus_manager"], "is_in_streak_zone")
    assert in_zone is True, f"Should be in streak zone at threshold {threshold}, got {in_zone}"


@pytest.mark.asyncio
async def test_get_streak_pitch_multiplier(game):
    """get_streak_pitch_multiplier should return valid pitch scale."""
    # Reset to ensure clean state
    await game.call(PATHS["mining_bonus_manager"], "reset")

    # Initial should be 1.0
    pitch = await game.call(PATHS["mining_bonus_manager"], "get_streak_pitch_multiplier")
    assert pitch == 1.0, f"Initial pitch should be 1.0, got {pitch}"

    # Mine some blocks
    for _ in range(5):
        await game.call(PATHS["mining_bonus_manager"], "on_block_mined")

    pitch = await game.call(PATHS["mining_bonus_manager"], "get_streak_pitch_multiplier")
    assert 1.0 <= pitch <= 1.2, f"Pitch should be 1.0-1.2, got {pitch}"


@pytest.mark.asyncio
async def test_get_streak_particle_multiplier(game):
    """get_streak_particle_multiplier should return valid particle multiplier."""
    # Reset to ensure clean state
    await game.call(PATHS["mining_bonus_manager"], "reset")

    # Initial should be 1.0
    particles = await game.call(PATHS["mining_bonus_manager"], "get_streak_particle_multiplier")
    assert particles == 1.0, f"Initial particle multiplier should be 1.0, got {particles}"


# =============================================================================
# LUCKY STRIKE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_lucky_strike_base_chance_configured(game):
    """LUCKY_STRIKE_BASE_CHANCE should be configured."""
    chance = await game.get_property(PATHS["mining_bonus_manager"], "LUCKY_STRIKE_BASE_CHANCE")
    assert chance is not None, "LUCKY_STRIKE_BASE_CHANCE should exist"
    assert 0 < chance < 1, f"Lucky strike chance should be between 0 and 1, got {chance}"


@pytest.mark.asyncio
async def test_lucky_strike_multiplier_configured(game):
    """LUCKY_STRIKE_MULTIPLIER should be configured."""
    mult = await game.get_property(PATHS["mining_bonus_manager"], "LUCKY_STRIKE_MULTIPLIER")
    assert mult is not None, "LUCKY_STRIKE_MULTIPLIER should exist"
    assert mult >= 1.0, f"Lucky strike multiplier should be >= 1.0, got {mult}"


@pytest.mark.asyncio
async def test_check_lucky_strike_returns_number(game):
    """check_lucky_strike should return a number >= 1.0."""
    # Reset to ensure clean state
    await game.call(PATHS["mining_bonus_manager"], "reset")

    result = await game.call(PATHS["mining_bonus_manager"], "check_lucky_strike", ["coal"])
    assert isinstance(result, (int, float)), f"check_lucky_strike should return number, got {type(result)}"
    assert result >= 1.0, f"check_lucky_strike should return >= 1.0, got {result}"


@pytest.mark.asyncio
async def test_get_lucky_strike_ore_bonus(game):
    """get_lucky_strike_ore_bonus should return number of extra ores."""
    bonus = await game.call(PATHS["mining_bonus_manager"], "get_lucky_strike_ore_bonus")
    assert bonus is not None, "get_lucky_strike_ore_bonus should return a value"
    assert isinstance(bonus, int), f"Ore bonus should be int, got {type(bonus)}"
    assert bonus >= 0, f"Ore bonus should be non-negative, got {bonus}"


@pytest.mark.asyncio
async def test_pity_threshold_configured(game):
    """PITY_THRESHOLD should be configured for guaranteed lucky strike."""
    threshold = await game.get_property(PATHS["mining_bonus_manager"], "PITY_THRESHOLD")
    assert threshold is not None, "PITY_THRESHOLD should exist"
    assert threshold > 0, f"Pity threshold should be positive, got {threshold}"


# =============================================================================
# DEPTH MILESTONE REWARDS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_depth_milestone_rewards_configured(game):
    """DEPTH_MILESTONE_REWARDS should be configured."""
    rewards = await game.get_property(PATHS["mining_bonus_manager"], "DEPTH_MILESTONE_REWARDS")
    assert rewards is not None, "DEPTH_MILESTONE_REWARDS should exist"
    assert isinstance(rewards, dict), f"DEPTH_MILESTONE_REWARDS should be dict, got {type(rewards)}"
    assert len(rewards) > 0, "Should have at least some milestone rewards"


@pytest.mark.asyncio
async def test_depth_milestone_rewards_have_positive_values(game):
    """All depth milestone rewards should be positive."""
    rewards = await game.get_property(PATHS["mining_bonus_manager"], "DEPTH_MILESTONE_REWARDS")
    for depth, coins in rewards.items():
        assert coins > 0, f"Reward for depth {depth} should be positive, got {coins}"


@pytest.mark.asyncio
async def test_check_unclaimed_milestones_method_exists(game):
    """check_unclaimed_milestones method should exist."""
    result = await game.call(PATHS["mining_bonus_manager"], "has_method", ["check_unclaimed_milestones"])
    assert result is True, "MiningBonusManager should have check_unclaimed_milestones method"


# =============================================================================
# VEIN BONUS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_initial_vein_streak_zero(game):
    """vein_streak should be 0 initially."""
    # Reset to ensure clean state
    await game.call(PATHS["mining_bonus_manager"], "reset")

    streak = await game.get_property(PATHS["mining_bonus_manager"], "vein_streak")
    assert streak == 0, f"vein_streak should be 0 initially, got {streak}"


@pytest.mark.asyncio
async def test_initial_vein_ore_type_empty(game):
    """vein_ore_type should be empty initially."""
    # Reset to ensure clean state
    await game.call(PATHS["mining_bonus_manager"], "reset")

    ore_type = await game.get_property(PATHS["mining_bonus_manager"], "vein_ore_type")
    assert ore_type == "", f"vein_ore_type should be empty initially, got '{ore_type}'"


@pytest.mark.asyncio
async def test_on_ore_collected_tracks_streak(game):
    """on_ore_collected should track vein_streak."""
    # Reset to ensure clean state
    await game.call(PATHS["mining_bonus_manager"], "reset")

    # Collect same ore multiple times
    await game.call(PATHS["mining_bonus_manager"], "on_ore_collected", ["coal"])
    await game.call(PATHS["mining_bonus_manager"], "on_ore_collected", ["coal"])

    streak = await game.get_property(PATHS["mining_bonus_manager"], "vein_streak")
    assert streak == 2, f"vein_streak should be 2 after 2 same ores, got {streak}"


@pytest.mark.asyncio
async def test_on_ore_collected_resets_on_different_ore(game):
    """on_ore_collected should reset streak on different ore type."""
    # Reset to ensure clean state
    await game.call(PATHS["mining_bonus_manager"], "reset")

    # Collect coal then copper
    await game.call(PATHS["mining_bonus_manager"], "on_ore_collected", ["coal"])
    await game.call(PATHS["mining_bonus_manager"], "on_ore_collected", ["coal"])
    await game.call(PATHS["mining_bonus_manager"], "on_ore_collected", ["copper"])

    streak = await game.get_property(PATHS["mining_bonus_manager"], "vein_streak")
    assert streak == 1, f"vein_streak should reset to 1 on different ore, got {streak}"


@pytest.mark.asyncio
async def test_vein_bonus_multiplier_configured(game):
    """VEIN_BONUS_MULTIPLIER should be configured."""
    mult = await game.get_property(PATHS["mining_bonus_manager"], "VEIN_BONUS_MULTIPLIER")
    assert mult is not None, "VEIN_BONUS_MULTIPLIER should exist"
    assert mult >= 1.0, f"Vein bonus multiplier should be >= 1.0, got {mult}"


@pytest.mark.asyncio
async def test_vein_bonus_threshold_configured(game):
    """VEIN_BONUS_THRESHOLD should be configured."""
    threshold = await game.get_property(PATHS["mining_bonus_manager"], "VEIN_BONUS_THRESHOLD")
    assert threshold is not None, "VEIN_BONUS_THRESHOLD should exist"
    assert threshold > 0, f"Vein bonus threshold should be positive, got {threshold}"


@pytest.mark.asyncio
async def test_reset_vein_streak(game):
    """reset_vein_streak should clear vein tracking."""
    # Build up a streak
    await game.call(PATHS["mining_bonus_manager"], "on_ore_collected", ["coal"])
    await game.call(PATHS["mining_bonus_manager"], "on_ore_collected", ["coal"])

    # Reset vein streak
    await game.call(PATHS["mining_bonus_manager"], "reset_vein_streak")

    streak = await game.get_property(PATHS["mining_bonus_manager"], "vein_streak")
    ore_type = await game.get_property(PATHS["mining_bonus_manager"], "vein_ore_type")
    assert streak == 0, f"vein_streak should be 0 after reset, got {streak}"
    assert ore_type == "", f"vein_ore_type should be empty after reset, got '{ore_type}'"


# =============================================================================
# SAVE/LOAD DATA TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_save_data(game):
    """get_save_data should return dictionary with required keys."""
    data = await game.call(PATHS["mining_bonus_manager"], "get_save_data")
    assert data is not None, "get_save_data should return a value"
    assert isinstance(data, dict), f"get_save_data should return dict, got {type(data)}"
    assert "claimed_milestones" in data, "Save data should include claimed_milestones"
    assert "consecutive_misses" in data, "Save data should include consecutive_misses"


@pytest.mark.asyncio
async def test_load_save_data(game):
    """load_save_data should restore state."""
    # Create test data
    test_data = {
        "claimed_milestones": {25: True, 50: True},
        "consecutive_misses": 10,
    }

    # Load save data
    await game.call(PATHS["mining_bonus_manager"], "load_save_data", [test_data])

    # Verify by getting save data back
    data = await game.call(PATHS["mining_bonus_manager"], "get_save_data")
    assert data.get("consecutive_misses") == 10, f"consecutive_misses should be 10, got {data.get('consecutive_misses')}"


# =============================================================================
# RESET TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_reset_clears_all_state(game):
    """reset() should clear all tracking state."""
    # Build up some state
    await game.call(PATHS["mining_bonus_manager"], "on_block_mined")
    await game.call(PATHS["mining_bonus_manager"], "on_ore_collected", ["coal"])

    # Reset
    await game.call(PATHS["mining_bonus_manager"], "reset")

    # Verify all state is cleared
    combo_count = await game.get_property(PATHS["mining_bonus_manager"], "combo_count")
    combo_active = await game.get_property(PATHS["mining_bonus_manager"], "combo_active")
    vein_streak = await game.get_property(PATHS["mining_bonus_manager"], "vein_streak")

    assert combo_count == 0, f"combo_count should be 0 after reset, got {combo_count}"
    assert combo_active is False, f"combo_active should be False after reset, got {combo_active}"
    assert vein_streak == 0, f"vein_streak should be 0 after reset, got {vein_streak}"


# =============================================================================
# SIGNAL EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_combo_updated_signal(game):
    """MiningBonusManager should have combo_updated signal."""
    has_signal = await game.call(PATHS["mining_bonus_manager"], "has_signal", ["combo_updated"])
    assert has_signal is True, "MiningBonusManager should have combo_updated signal"


@pytest.mark.asyncio
async def test_has_combo_ended_signal(game):
    """MiningBonusManager should have combo_ended signal."""
    has_signal = await game.call(PATHS["mining_bonus_manager"], "has_signal", ["combo_ended"])
    assert has_signal is True, "MiningBonusManager should have combo_ended signal"


@pytest.mark.asyncio
async def test_has_lucky_strike_signal(game):
    """MiningBonusManager should have lucky_strike signal."""
    has_signal = await game.call(PATHS["mining_bonus_manager"], "has_signal", ["lucky_strike"])
    assert has_signal is True, "MiningBonusManager should have lucky_strike signal"


@pytest.mark.asyncio
async def test_has_milestone_reward_signal(game):
    """MiningBonusManager should have milestone_reward signal."""
    has_signal = await game.call(PATHS["mining_bonus_manager"], "has_signal", ["milestone_reward"])
    assert has_signal is True, "MiningBonusManager should have milestone_reward signal"


@pytest.mark.asyncio
async def test_has_streak_zone_entered_signal(game):
    """MiningBonusManager should have streak_zone_entered signal."""
    has_signal = await game.call(PATHS["mining_bonus_manager"], "has_signal", ["streak_zone_entered"])
    assert has_signal is True, "MiningBonusManager should have streak_zone_entered signal"


@pytest.mark.asyncio
async def test_has_streak_zone_exited_signal(game):
    """MiningBonusManager should have streak_zone_exited signal."""
    has_signal = await game.call(PATHS["mining_bonus_manager"], "has_signal", ["streak_zone_exited"])
    assert has_signal is True, "MiningBonusManager should have streak_zone_exited signal"


# =============================================================================
# CONSTANTS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_combo_timeout_configured(game):
    """COMBO_TIMEOUT should be configured."""
    timeout = await game.get_property(PATHS["mining_bonus_manager"], "COMBO_TIMEOUT")
    assert timeout is not None, "COMBO_TIMEOUT should exist"
    assert timeout > 0, f"COMBO_TIMEOUT should be positive, got {timeout}"


@pytest.mark.asyncio
async def test_max_combo_multiplier_configured(game):
    """MAX_COMBO_MULTIPLIER should be configured."""
    max_mult = await game.get_property(PATHS["mining_bonus_manager"], "MAX_COMBO_MULTIPLIER")
    assert max_mult is not None, "MAX_COMBO_MULTIPLIER should exist"
    assert max_mult >= 1.0, f"MAX_COMBO_MULTIPLIER should be >= 1.0, got {max_mult}"


@pytest.mark.asyncio
async def test_blocks_per_level_configured(game):
    """BLOCKS_PER_LEVEL should be configured."""
    blocks = await game.get_property(PATHS["mining_bonus_manager"], "BLOCKS_PER_LEVEL")
    assert blocks is not None, "BLOCKS_PER_LEVEL should exist"
    assert blocks > 0, f"BLOCKS_PER_LEVEL should be positive, got {blocks}"
