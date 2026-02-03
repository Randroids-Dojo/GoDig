"""
AchievementManager tests for GoDig endless digging game.

Tests verify that AchievementManager:
1. Exists as an autoload singleton
2. Has proper signals (achievement_unlocked)
3. Has all achievement definitions
4. Tracking methods work correctly
5. Save/load data works
6. Reset functionality works
"""
import pytest
from helpers import PATHS


# Path to achievement manager
ACHIEVEMENT_PATH = PATHS.get("achievement_manager", "/root/AchievementManager")


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_achievement_manager_exists(game):
    """AchievementManager autoload should exist."""
    result = await game.node_exists(ACHIEVEMENT_PATH)
    assert result.get("exists") is True, "AchievementManager autoload should exist"


# =============================================================================
# SIGNAL TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_achievement_unlocked_signal(game):
    """AchievementManager should have achievement_unlocked signal."""
    has_signal = await game.call(ACHIEVEMENT_PATH, "has_signal", ["achievement_unlocked"])
    assert has_signal is True, "AchievementManager should have achievement_unlocked signal"


# =============================================================================
# ACHIEVEMENT CONSTANTS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_achievements_constant_exists(game):
    """ACHIEVEMENTS constant should exist and be a dictionary."""
    result = await game.get_property(ACHIEVEMENT_PATH, "ACHIEVEMENTS")
    assert result is not None, "ACHIEVEMENTS constant should exist"
    assert isinstance(result, dict), f"ACHIEVEMENTS should be a dict, got {type(result)}"


@pytest.mark.asyncio
async def test_achievements_not_empty(game):
    """ACHIEVEMENTS should contain achievement definitions."""
    result = await game.get_property(ACHIEVEMENT_PATH, "ACHIEVEMENTS")
    assert len(result) > 0, "ACHIEVEMENTS should not be empty"


@pytest.mark.asyncio
async def test_achievements_has_first_dig(game):
    """ACHIEVEMENTS should include first_dig achievement."""
    result = await game.get_property(ACHIEVEMENT_PATH, "ACHIEVEMENTS")
    assert "first_dig" in result, "ACHIEVEMENTS should have first_dig"


@pytest.mark.asyncio
async def test_achievements_has_depth_milestones(game):
    """ACHIEVEMENTS should include depth milestone achievements."""
    result = await game.get_property(ACHIEVEMENT_PATH, "ACHIEVEMENTS")
    depth_achievements = ["depth_10", "depth_50", "depth_100", "depth_250", "depth_500"]
    for achievement_id in depth_achievements:
        assert achievement_id in result, f"ACHIEVEMENTS should have {achievement_id}"


@pytest.mark.asyncio
async def test_achievements_has_coin_milestones(game):
    """ACHIEVEMENTS should include coin milestone achievements."""
    result = await game.get_property(ACHIEVEMENT_PATH, "ACHIEVEMENTS")
    coin_achievements = ["coins_100", "coins_500", "coins_1000", "coins_5000"]
    for achievement_id in coin_achievements:
        assert achievement_id in result, f"ACHIEVEMENTS should have {achievement_id}"


@pytest.mark.asyncio
async def test_achievement_has_required_fields(game):
    """Each achievement should have id, name, description, icon fields."""
    result = await game.get_property(ACHIEVEMENT_PATH, "ACHIEVEMENTS")
    # Check first_dig as a sample
    first_dig = result.get("first_dig", {})
    required_fields = ["id", "name", "description", "icon"]
    for field in required_fields:
        assert field in first_dig, f"Achievement should have '{field}' field"


# =============================================================================
# STATE PROPERTY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_unlocked_property_exists(game):
    """unlocked property should exist and be an array."""
    result = await game.get_property(ACHIEVEMENT_PATH, "unlocked")
    assert result is not None, "unlocked property should exist"
    assert isinstance(result, list), f"unlocked should be an array, got {type(result)}"


@pytest.mark.asyncio
async def test_lifetime_coins_property_exists(game):
    """lifetime_coins property should exist and be numeric."""
    result = await game.get_property(ACHIEVEMENT_PATH, "lifetime_coins")
    assert result is not None, "lifetime_coins property should exist"
    assert isinstance(result, (int, float)), f"lifetime_coins should be numeric, got {type(result)}"


@pytest.mark.asyncio
async def test_ores_collected_property_exists(game):
    """ores_collected property should exist and be a dictionary."""
    result = await game.get_property(ACHIEVEMENT_PATH, "ores_collected")
    assert result is not None, "ores_collected property should exist"
    assert isinstance(result, dict), f"ores_collected should be a dict, got {type(result)}"


@pytest.mark.asyncio
async def test_blocks_destroyed_property_exists(game):
    """blocks_destroyed property should exist and be numeric."""
    result = await game.get_property(ACHIEVEMENT_PATH, "blocks_destroyed")
    assert result is not None, "blocks_destroyed property should exist"
    assert isinstance(result, (int, float)), f"blocks_destroyed should be numeric, got {type(result)}"


# =============================================================================
# METHOD EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_unlock_method(game):
    """AchievementManager should have unlock method."""
    result = await game.call(ACHIEVEMENT_PATH, "has_method", ["unlock"])
    assert result is True, "AchievementManager should have unlock method"


@pytest.mark.asyncio
async def test_has_is_unlocked_method(game):
    """AchievementManager should have is_unlocked method."""
    result = await game.call(ACHIEVEMENT_PATH, "has_method", ["is_unlocked"])
    assert result is True, "AchievementManager should have is_unlocked method"


@pytest.mark.asyncio
async def test_has_track_block_destroyed_method(game):
    """AchievementManager should have track_block_destroyed method."""
    result = await game.call(ACHIEVEMENT_PATH, "has_method", ["track_block_destroyed"])
    assert result is True, "AchievementManager should have track_block_destroyed method"


@pytest.mark.asyncio
async def test_has_track_ore_collected_method(game):
    """AchievementManager should have track_ore_collected method."""
    result = await game.call(ACHIEVEMENT_PATH, "has_method", ["track_ore_collected"])
    assert result is True, "AchievementManager should have track_ore_collected method"


@pytest.mark.asyncio
async def test_has_track_sale_method(game):
    """AchievementManager should have track_sale method."""
    result = await game.call(ACHIEVEMENT_PATH, "has_method", ["track_sale"])
    assert result is True, "AchievementManager should have track_sale method"


@pytest.mark.asyncio
async def test_has_track_death_method(game):
    """AchievementManager should have track_death method."""
    result = await game.call(ACHIEVEMENT_PATH, "has_method", ["track_death"])
    assert result is True, "AchievementManager should have track_death method"


@pytest.mark.asyncio
async def test_has_track_upgrade_method(game):
    """AchievementManager should have track_upgrade method."""
    result = await game.call(ACHIEVEMENT_PATH, "has_method", ["track_upgrade"])
    assert result is True, "AchievementManager should have track_upgrade method"


@pytest.mark.asyncio
async def test_has_check_lore_collection_method(game):
    """AchievementManager should have check_lore_collection method."""
    result = await game.call(ACHIEVEMENT_PATH, "has_method", ["check_lore_collection"])
    assert result is True, "AchievementManager should have check_lore_collection method"


@pytest.mark.asyncio
async def test_has_get_all_achievements_method(game):
    """AchievementManager should have get_all_achievements method."""
    result = await game.call(ACHIEVEMENT_PATH, "has_method", ["get_all_achievements"])
    assert result is True, "AchievementManager should have get_all_achievements method"


@pytest.mark.asyncio
async def test_has_get_unlocked_count_method(game):
    """AchievementManager should have get_unlocked_count method."""
    result = await game.call(ACHIEVEMENT_PATH, "has_method", ["get_unlocked_count"])
    assert result is True, "AchievementManager should have get_unlocked_count method"


@pytest.mark.asyncio
async def test_has_get_total_count_method(game):
    """AchievementManager should have get_total_count method."""
    result = await game.call(ACHIEVEMENT_PATH, "has_method", ["get_total_count"])
    assert result is True, "AchievementManager should have get_total_count method"


@pytest.mark.asyncio
async def test_has_get_save_data_method(game):
    """AchievementManager should have get_save_data method."""
    result = await game.call(ACHIEVEMENT_PATH, "has_method", ["get_save_data"])
    assert result is True, "AchievementManager should have get_save_data method"


@pytest.mark.asyncio
async def test_has_load_save_data_method(game):
    """AchievementManager should have load_save_data method."""
    result = await game.call(ACHIEVEMENT_PATH, "has_method", ["load_save_data"])
    assert result is True, "AchievementManager should have load_save_data method"


@pytest.mark.asyncio
async def test_has_reset_method(game):
    """AchievementManager should have reset method."""
    result = await game.call(ACHIEVEMENT_PATH, "has_method", ["reset"])
    assert result is True, "AchievementManager should have reset method"


# =============================================================================
# GET METHODS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_total_count_returns_positive(game):
    """get_total_count should return a positive number."""
    result = await game.call(ACHIEVEMENT_PATH, "get_total_count")
    assert result is not None, "get_total_count should return a value"
    assert isinstance(result, int), f"get_total_count should return int, got {type(result)}"
    assert result > 0, f"get_total_count should be positive, got {result}"


@pytest.mark.asyncio
async def test_get_unlocked_count_returns_numeric(game):
    """get_unlocked_count should return a number."""
    result = await game.call(ACHIEVEMENT_PATH, "get_unlocked_count")
    assert result is not None, "get_unlocked_count should return a value"
    assert isinstance(result, int), f"get_unlocked_count should return int, got {type(result)}"
    assert result >= 0, f"get_unlocked_count should be non-negative, got {result}"


@pytest.mark.asyncio
async def test_get_all_achievements_returns_array(game):
    """get_all_achievements should return an array."""
    result = await game.call(ACHIEVEMENT_PATH, "get_all_achievements")
    assert result is not None, "get_all_achievements should return a value"
    assert isinstance(result, list), f"get_all_achievements should return array, got {type(result)}"


@pytest.mark.asyncio
async def test_get_all_achievements_has_unlocked_status(game):
    """get_all_achievements should include unlocked status for each achievement."""
    result = await game.call(ACHIEVEMENT_PATH, "get_all_achievements")
    if len(result) > 0:
        first_achievement = result[0]
        assert "unlocked" in first_achievement, "Achievement should have 'unlocked' status"
        assert isinstance(first_achievement["unlocked"], bool), "unlocked should be a boolean"


# =============================================================================
# IS_UNLOCKED TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_is_unlocked_returns_bool(game):
    """is_unlocked should return a boolean."""
    result = await game.call(ACHIEVEMENT_PATH, "is_unlocked", ["first_dig"])
    assert isinstance(result, bool), f"is_unlocked should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_is_unlocked_false_for_unknown(game):
    """is_unlocked should return false for unknown achievement IDs."""
    result = await game.call(ACHIEVEMENT_PATH, "is_unlocked", ["nonexistent_achievement_xyz"])
    assert result is False, "is_unlocked should return false for unknown achievements"


# =============================================================================
# RESET TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_reset_clears_unlocked(game):
    """reset should clear all unlocked achievements."""
    await game.call(ACHIEVEMENT_PATH, "reset")
    count = await game.call(ACHIEVEMENT_PATH, "get_unlocked_count")
    assert count == 0, f"Unlocked count should be 0 after reset, got {count}"


@pytest.mark.asyncio
async def test_reset_clears_lifetime_coins(game):
    """reset should clear lifetime_coins."""
    await game.call(ACHIEVEMENT_PATH, "reset")
    coins = await game.get_property(ACHIEVEMENT_PATH, "lifetime_coins")
    assert coins == 0, f"lifetime_coins should be 0 after reset, got {coins}"


@pytest.mark.asyncio
async def test_reset_clears_ores_collected(game):
    """reset should clear ores_collected."""
    await game.call(ACHIEVEMENT_PATH, "reset")
    ores = await game.get_property(ACHIEVEMENT_PATH, "ores_collected")
    assert len(ores) == 0, f"ores_collected should be empty after reset, got {ores}"


@pytest.mark.asyncio
async def test_reset_clears_blocks_destroyed(game):
    """reset should clear blocks_destroyed."""
    await game.call(ACHIEVEMENT_PATH, "reset")
    blocks = await game.get_property(ACHIEVEMENT_PATH, "blocks_destroyed")
    assert blocks == 0, f"blocks_destroyed should be 0 after reset, got {blocks}"


# =============================================================================
# SAVE/LOAD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_save_data_returns_dict(game):
    """get_save_data should return a dictionary."""
    result = await game.call(ACHIEVEMENT_PATH, "get_save_data")
    assert result is not None, "get_save_data should return a value"
    assert isinstance(result, dict), f"get_save_data should return dict, got {type(result)}"


@pytest.mark.asyncio
async def test_get_save_data_has_required_fields(game):
    """get_save_data should include all required persistence fields."""
    result = await game.call(ACHIEVEMENT_PATH, "get_save_data")
    required_fields = ["unlocked", "lifetime_coins", "ores_collected", "blocks_destroyed"]
    for field in required_fields:
        assert field in result, f"Save data should include '{field}'"


@pytest.mark.asyncio
async def test_load_save_data_restores_unlocked(game):
    """load_save_data should restore unlocked achievements."""
    # Reset first
    await game.call(ACHIEVEMENT_PATH, "reset")

    # Load save data with some unlocked achievements
    test_data = {
        "unlocked": ["first_dig", "first_ore"],
        "lifetime_coins": 500,
        "ores_collected": {"copper": 10},
        "blocks_destroyed": 100
    }
    await game.call(ACHIEVEMENT_PATH, "load_save_data", [test_data])

    # Verify state was restored
    count = await game.call(ACHIEVEMENT_PATH, "get_unlocked_count")
    assert count == 2, f"Should have 2 unlocked achievements, got {count}"


@pytest.mark.asyncio
async def test_load_save_data_restores_lifetime_coins(game):
    """load_save_data should restore lifetime_coins."""
    # Reset first
    await game.call(ACHIEVEMENT_PATH, "reset")

    # Load save data
    test_data = {
        "unlocked": [],
        "lifetime_coins": 1234,
        "ores_collected": {},
        "blocks_destroyed": 0
    }
    await game.call(ACHIEVEMENT_PATH, "load_save_data", [test_data])

    # Verify state was restored
    coins = await game.get_property(ACHIEVEMENT_PATH, "lifetime_coins")
    assert coins == 1234, f"lifetime_coins should be 1234, got {coins}"


@pytest.mark.asyncio
async def test_load_save_data_restores_blocks_destroyed(game):
    """load_save_data should restore blocks_destroyed."""
    # Reset first
    await game.call(ACHIEVEMENT_PATH, "reset")

    # Load save data
    test_data = {
        "unlocked": [],
        "lifetime_coins": 0,
        "ores_collected": {},
        "blocks_destroyed": 500
    }
    await game.call(ACHIEVEMENT_PATH, "load_save_data", [test_data])

    # Verify state was restored
    blocks = await game.get_property(ACHIEVEMENT_PATH, "blocks_destroyed")
    assert blocks == 500, f"blocks_destroyed should be 500, got {blocks}"


# =============================================================================
# UNLOCK FUNCTIONALITY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_unlock_adds_to_unlocked(game):
    """unlock should add achievement to unlocked list."""
    # Reset first
    await game.call(ACHIEVEMENT_PATH, "reset")

    # Unlock an achievement
    await game.call(ACHIEVEMENT_PATH, "unlock", ["first_dig"])

    # Verify it's unlocked
    is_unlocked = await game.call(ACHIEVEMENT_PATH, "is_unlocked", ["first_dig"])
    assert is_unlocked is True, "first_dig should be unlocked after unlock call"


@pytest.mark.asyncio
async def test_unlock_does_not_duplicate(game):
    """unlock should not add duplicates."""
    # Reset first
    await game.call(ACHIEVEMENT_PATH, "reset")

    # Unlock same achievement twice
    await game.call(ACHIEVEMENT_PATH, "unlock", ["first_dig"])
    await game.call(ACHIEVEMENT_PATH, "unlock", ["first_dig"])

    # Should still only have 1
    count = await game.call(ACHIEVEMENT_PATH, "get_unlocked_count")
    assert count == 1, f"Should have 1 unlocked (no duplicates), got {count}"


@pytest.mark.asyncio
async def test_unlock_increments_count(game):
    """unlock should increment unlocked count."""
    # Reset first
    await game.call(ACHIEVEMENT_PATH, "reset")

    # Get initial count
    initial_count = await game.call(ACHIEVEMENT_PATH, "get_unlocked_count")

    # Unlock an achievement
    await game.call(ACHIEVEMENT_PATH, "unlock", ["first_dig"])

    # Count should increase by 1
    new_count = await game.call(ACHIEVEMENT_PATH, "get_unlocked_count")
    assert new_count == initial_count + 1, f"Count should increase by 1, got {new_count}"


# =============================================================================
# TRACKING FUNCTIONALITY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_track_block_destroyed_increments_counter(game):
    """track_block_destroyed should increment blocks_destroyed."""
    # Reset first
    await game.call(ACHIEVEMENT_PATH, "reset")

    # Get initial count
    initial = await game.get_property(ACHIEVEMENT_PATH, "blocks_destroyed")

    # Track a block destroyed
    await game.call(ACHIEVEMENT_PATH, "track_block_destroyed")

    # Count should increase
    new_count = await game.get_property(ACHIEVEMENT_PATH, "blocks_destroyed")
    assert new_count == initial + 1, f"blocks_destroyed should increment, got {new_count}"


@pytest.mark.asyncio
async def test_track_block_destroyed_unlocks_first_dig(game):
    """track_block_destroyed should unlock first_dig on first call."""
    # Reset first
    await game.call(ACHIEVEMENT_PATH, "reset")

    # Verify not unlocked
    is_unlocked_before = await game.call(ACHIEVEMENT_PATH, "is_unlocked", ["first_dig"])
    assert is_unlocked_before is False, "first_dig should not be unlocked initially"

    # Track first block
    await game.call(ACHIEVEMENT_PATH, "track_block_destroyed")

    # Should now be unlocked
    is_unlocked_after = await game.call(ACHIEVEMENT_PATH, "is_unlocked", ["first_dig"])
    assert is_unlocked_after is True, "first_dig should be unlocked after first block"


@pytest.mark.asyncio
async def test_track_death_unlocks_first_death(game):
    """track_death should unlock first_death achievement."""
    # Reset first
    await game.call(ACHIEVEMENT_PATH, "reset")

    # Track death
    await game.call(ACHIEVEMENT_PATH, "track_death")

    # Should be unlocked
    is_unlocked = await game.call(ACHIEVEMENT_PATH, "is_unlocked", ["first_death"])
    assert is_unlocked is True, "first_death should be unlocked after track_death"


@pytest.mark.asyncio
async def test_track_upgrade_unlocks_first_upgrade(game):
    """track_upgrade should unlock first_upgrade achievement."""
    # Reset first
    await game.call(ACHIEVEMENT_PATH, "reset")

    # Track upgrade
    await game.call(ACHIEVEMENT_PATH, "track_upgrade")

    # Should be unlocked
    is_unlocked = await game.call(ACHIEVEMENT_PATH, "is_unlocked", ["first_upgrade"])
    assert is_unlocked is True, "first_upgrade should be unlocked after track_upgrade"


@pytest.mark.asyncio
async def test_track_sale_unlocks_first_sale(game):
    """track_sale should unlock first_sale achievement."""
    # Reset first
    await game.call(ACHIEVEMENT_PATH, "reset")

    # Track sale with positive amount
    await game.call(ACHIEVEMENT_PATH, "track_sale", [100])

    # Should be unlocked
    is_unlocked = await game.call(ACHIEVEMENT_PATH, "is_unlocked", ["first_sale"])
    assert is_unlocked is True, "first_sale should be unlocked after track_sale"


@pytest.mark.asyncio
async def test_track_sale_zero_does_not_unlock(game):
    """track_sale with zero amount should not unlock achievement."""
    # Reset first
    await game.call(ACHIEVEMENT_PATH, "reset")

    # Track sale with zero amount
    await game.call(ACHIEVEMENT_PATH, "track_sale", [0])

    # Should NOT be unlocked
    is_unlocked = await game.call(ACHIEVEMENT_PATH, "is_unlocked", ["first_sale"])
    assert is_unlocked is False, "first_sale should not unlock for zero amount sale"
