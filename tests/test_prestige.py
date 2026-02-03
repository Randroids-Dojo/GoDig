"""
PrestigeManager tests for GoDig endless digging game.

Tests verify that PrestigeManager:
1. Exists as an autoload singleton
2. Has correct constants for prestige thresholds and bonuses
3. Tracks prestige level and points correctly
4. Calculates prestige points from depth properly
5. Manages bonus allocation and limits
6. Supports save/load functionality
7. Resets appropriately for new game vs full reset
"""
import pytest
from helpers import PATHS


# Path to prestige manager
PRESTIGE_MANAGER_PATH = PATHS.get("prestige_manager", "/root/PrestigeManager")


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_prestige_manager_exists(game):
    """PrestigeManager autoload should exist."""
    result = await game.node_exists(PRESTIGE_MANAGER_PATH)
    assert result.get("exists") is True, "PrestigeManager autoload should exist"


# =============================================================================
# CONSTANTS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_min_prestige_depth_constant(game):
    """PrestigeManager should have MIN_PRESTIGE_DEPTH constant."""
    result = await game.get_property(PRESTIGE_MANAGER_PATH, "MIN_PRESTIGE_DEPTH")
    assert result is not None, "MIN_PRESTIGE_DEPTH should exist"
    assert isinstance(result, int), f"MIN_PRESTIGE_DEPTH should be int, got {type(result)}"
    assert result >= 100, f"MIN_PRESTIGE_DEPTH should be at least 100, got {result}"


@pytest.mark.asyncio
async def test_min_prestige_depth_value(game):
    """MIN_PRESTIGE_DEPTH should be 500."""
    result = await game.get_property(PRESTIGE_MANAGER_PATH, "MIN_PRESTIGE_DEPTH")
    assert result == 500, f"MIN_PRESTIGE_DEPTH should be 500, got {result}"


@pytest.mark.asyncio
async def test_has_points_per_100_depth(game):
    """PrestigeManager should have POINTS_PER_100_DEPTH constant."""
    result = await game.get_property(PRESTIGE_MANAGER_PATH, "POINTS_PER_100_DEPTH")
    assert result is not None, "POINTS_PER_100_DEPTH should exist"
    assert isinstance(result, int), f"POINTS_PER_100_DEPTH should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_has_milestone_bonus_points(game):
    """PrestigeManager should have MILESTONE_BONUS_POINTS constant."""
    result = await game.get_property(PRESTIGE_MANAGER_PATH, "MILESTONE_BONUS_POINTS")
    assert result is not None, "MILESTONE_BONUS_POINTS should exist"
    assert isinstance(result, dict), f"MILESTONE_BONUS_POINTS should be dict, got {type(result)}"


@pytest.mark.asyncio
async def test_has_bonus_types(game):
    """PrestigeManager should have BONUS_TYPES constant."""
    result = await game.get_property(PRESTIGE_MANAGER_PATH, "BONUS_TYPES")
    assert result is not None, "BONUS_TYPES should exist"
    assert isinstance(result, dict), f"BONUS_TYPES should be dict, got {type(result)}"


@pytest.mark.asyncio
async def test_bonus_types_count(game):
    """Should have 5 bonus types defined."""
    result = await game.get_property(PRESTIGE_MANAGER_PATH, "BONUS_TYPES")
    assert len(result) == 5, f"Should have 5 bonus types, got {len(result)}"


@pytest.mark.asyncio
async def test_has_mining_speed_bonus(game):
    """BONUS_TYPES should have mining_speed."""
    result = await game.get_property(PRESTIGE_MANAGER_PATH, "BONUS_TYPES")
    assert "mining_speed" in result, "Should have 'mining_speed' bonus type"


@pytest.mark.asyncio
async def test_has_coin_bonus(game):
    """BONUS_TYPES should have coin_bonus."""
    result = await game.get_property(PRESTIGE_MANAGER_PATH, "BONUS_TYPES")
    assert "coin_bonus" in result, "Should have 'coin_bonus' bonus type"


@pytest.mark.asyncio
async def test_has_fall_resistance_bonus(game):
    """BONUS_TYPES should have fall_resistance."""
    result = await game.get_property(PRESTIGE_MANAGER_PATH, "BONUS_TYPES")
    assert "fall_resistance" in result, "Should have 'fall_resistance' bonus type"


@pytest.mark.asyncio
async def test_has_starting_coins_bonus(game):
    """BONUS_TYPES should have starting_coins."""
    result = await game.get_property(PRESTIGE_MANAGER_PATH, "BONUS_TYPES")
    assert "starting_coins" in result, "Should have 'starting_coins' bonus type"


@pytest.mark.asyncio
async def test_has_inventory_bonus(game):
    """BONUS_TYPES should have inventory_bonus."""
    result = await game.get_property(PRESTIGE_MANAGER_PATH, "BONUS_TYPES")
    assert "inventory_bonus" in result, "Should have 'inventory_bonus' bonus type"


# =============================================================================
# BONUS TYPE STRUCTURE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_bonus_type_has_name(game):
    """Each bonus type should have a name field."""
    result = await game.get_property(PRESTIGE_MANAGER_PATH, "BONUS_TYPES")
    for bonus_id, bonus_data in result.items():
        assert "name" in bonus_data, f"Bonus {bonus_id} should have 'name' field"
        assert isinstance(bonus_data["name"], str), f"Bonus {bonus_id} name should be string"


@pytest.mark.asyncio
async def test_bonus_type_has_per_point(game):
    """Each bonus type should have a per_point field."""
    result = await game.get_property(PRESTIGE_MANAGER_PATH, "BONUS_TYPES")
    for bonus_id, bonus_data in result.items():
        assert "per_point" in bonus_data, f"Bonus {bonus_id} should have 'per_point' field"
        assert isinstance(bonus_data["per_point"], (int, float)), f"Bonus {bonus_id} per_point should be number"


@pytest.mark.asyncio
async def test_bonus_type_has_max_points(game):
    """Each bonus type should have a max_points field."""
    result = await game.get_property(PRESTIGE_MANAGER_PATH, "BONUS_TYPES")
    for bonus_id, bonus_data in result.items():
        assert "max_points" in bonus_data, f"Bonus {bonus_id} should have 'max_points' field"
        assert isinstance(bonus_data["max_points"], int), f"Bonus {bonus_id} max_points should be int"
        assert bonus_data["max_points"] > 0, f"Bonus {bonus_id} max_points should be positive"


# =============================================================================
# STATE PROPERTY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_prestige_level_property(game):
    """prestige_level property should be accessible."""
    result = await game.get_property(PRESTIGE_MANAGER_PATH, "prestige_level")
    assert result is not None, "prestige_level should exist"
    assert isinstance(result, int), f"prestige_level should be int, got {type(result)}"
    assert result >= 0, f"prestige_level should be non-negative, got {result}"


@pytest.mark.asyncio
async def test_total_prestige_points_property(game):
    """total_prestige_points property should be accessible."""
    result = await game.get_property(PRESTIGE_MANAGER_PATH, "total_prestige_points")
    assert result is not None, "total_prestige_points should exist"
    assert isinstance(result, int), f"total_prestige_points should be int, got {type(result)}"
    assert result >= 0, f"total_prestige_points should be non-negative, got {result}"


@pytest.mark.asyncio
async def test_available_points_property(game):
    """available_points property should be accessible."""
    result = await game.get_property(PRESTIGE_MANAGER_PATH, "available_points")
    assert result is not None, "available_points should exist"
    assert isinstance(result, int), f"available_points should be int, got {type(result)}"
    assert result >= 0, f"available_points should be non-negative, got {result}"


@pytest.mark.asyncio
async def test_allocated_points_property(game):
    """allocated_points property should be accessible."""
    result = await game.get_property(PRESTIGE_MANAGER_PATH, "allocated_points")
    assert result is not None, "allocated_points should exist"
    assert isinstance(result, dict), f"allocated_points should be dict, got {type(result)}"


@pytest.mark.asyncio
async def test_current_run_max_depth_property(game):
    """current_run_max_depth property should be accessible."""
    result = await game.get_property(PRESTIGE_MANAGER_PATH, "current_run_max_depth")
    assert result is not None, "current_run_max_depth should exist"
    assert isinstance(result, int), f"current_run_max_depth should be int, got {type(result)}"
    assert result >= 0, f"current_run_max_depth should be non-negative, got {result}"


# =============================================================================
# METHOD TESTS - PRESTIGE CHECK
# =============================================================================

@pytest.mark.asyncio
async def test_can_prestige_returns_bool(game):
    """can_prestige should return a boolean."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "can_prestige")
    assert isinstance(result, bool), f"can_prestige should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_can_prestige_initially_false(game):
    """can_prestige should be false initially (depth 0)."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "can_prestige")
    assert result is False, "can_prestige should be False when depth < MIN_PRESTIGE_DEPTH"


@pytest.mark.asyncio
async def test_calculate_prestige_points_returns_int(game):
    """calculate_prestige_points should return an integer."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "calculate_prestige_points")
    assert result is not None, "calculate_prestige_points should return a value"
    assert isinstance(result, int), f"calculate_prestige_points should return int, got {type(result)}"


@pytest.mark.asyncio
async def test_calculate_prestige_points_zero_when_shallow(game):
    """calculate_prestige_points should return 0 when below MIN_PRESTIGE_DEPTH."""
    # Reset to ensure clean state
    await game.call(PRESTIGE_MANAGER_PATH, "reset")
    result = await game.call(PRESTIGE_MANAGER_PATH, "calculate_prestige_points")
    assert result == 0, f"Should return 0 when depth < MIN_PRESTIGE_DEPTH, got {result}"


# =============================================================================
# METHOD TESTS - BONUS ACCESS
# =============================================================================

@pytest.mark.asyncio
async def test_get_bonus_value_valid(game):
    """get_bonus_value should return a number for valid bonus type."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_bonus_value", ["mining_speed"])
    assert result is not None, "get_bonus_value should return a value"
    assert isinstance(result, (int, float)), f"get_bonus_value should return number, got {type(result)}"


@pytest.mark.asyncio
async def test_get_bonus_value_invalid(game):
    """get_bonus_value should return 0 for invalid bonus type."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_bonus_value", ["nonexistent_bonus"])
    assert result == 0.0, f"Invalid bonus type should return 0.0, got {result}"


@pytest.mark.asyncio
async def test_get_active_bonuses_returns_dict(game):
    """get_active_bonuses should return a dictionary."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_active_bonuses")
    assert result is not None, "get_active_bonuses should return a value"
    assert isinstance(result, dict), f"get_active_bonuses should return dict, got {type(result)}"


@pytest.mark.asyncio
async def test_get_mining_speed_multiplier(game):
    """get_mining_speed_multiplier should return >= 1.0."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_mining_speed_multiplier")
    assert result is not None, "get_mining_speed_multiplier should return a value"
    assert isinstance(result, (int, float)), f"get_mining_speed_multiplier should return number, got {type(result)}"
    assert result >= 1.0, f"mining_speed_multiplier should be >= 1.0, got {result}"


@pytest.mark.asyncio
async def test_get_coin_multiplier(game):
    """get_coin_multiplier should return >= 1.0."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_coin_multiplier")
    assert result is not None, "get_coin_multiplier should return a value"
    assert isinstance(result, (int, float)), f"get_coin_multiplier should return number, got {type(result)}"
    assert result >= 1.0, f"coin_multiplier should be >= 1.0, got {result}"


@pytest.mark.asyncio
async def test_get_fall_resistance(game):
    """get_fall_resistance should return a value between 0 and 1."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_fall_resistance")
    assert result is not None, "get_fall_resistance should return a value"
    assert isinstance(result, (int, float)), f"get_fall_resistance should return number, got {type(result)}"
    assert 0 <= result <= 1, f"fall_resistance should be between 0 and 1, got {result}"


@pytest.mark.asyncio
async def test_get_starting_coins(game):
    """get_starting_coins should return non-negative integer."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_starting_coins")
    assert result is not None, "get_starting_coins should return a value"
    assert isinstance(result, int), f"get_starting_coins should return int, got {type(result)}"
    assert result >= 0, f"starting_coins should be non-negative, got {result}"


@pytest.mark.asyncio
async def test_get_bonus_inventory_slots(game):
    """get_bonus_inventory_slots should return non-negative integer."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_bonus_inventory_slots")
    assert result is not None, "get_bonus_inventory_slots should return a value"
    assert isinstance(result, int), f"get_bonus_inventory_slots should return int, got {type(result)}"
    assert result >= 0, f"bonus_inventory_slots should be non-negative, got {result}"


# =============================================================================
# METHOD TESTS - GETTER METHODS
# =============================================================================

@pytest.mark.asyncio
async def test_get_prestige_level(game):
    """get_prestige_level should return the prestige level."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_prestige_level")
    assert result is not None, "get_prestige_level should return a value"
    assert isinstance(result, int), f"get_prestige_level should return int, got {type(result)}"


@pytest.mark.asyncio
async def test_get_available_points(game):
    """get_available_points should return available points."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_available_points")
    assert result is not None, "get_available_points should return a value"
    assert isinstance(result, int), f"get_available_points should return int, got {type(result)}"


@pytest.mark.asyncio
async def test_get_total_points(game):
    """get_total_points should return total prestige points."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_total_points")
    assert result is not None, "get_total_points should return a value"
    assert isinstance(result, int), f"get_total_points should return int, got {type(result)}"


@pytest.mark.asyncio
async def test_get_allocated_points_valid(game):
    """get_allocated_points should return allocated points for valid bonus."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_allocated_points", ["mining_speed"])
    assert result is not None, "get_allocated_points should return a value"
    assert isinstance(result, int), f"get_allocated_points should return int, got {type(result)}"


@pytest.mark.asyncio
async def test_get_allocated_points_invalid(game):
    """get_allocated_points should return 0 for invalid bonus."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_allocated_points", ["nonexistent"])
    assert result == 0, f"Invalid bonus should return 0, got {result}"


@pytest.mark.asyncio
async def test_get_max_points_valid(game):
    """get_max_points should return max points for valid bonus."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_max_points", ["mining_speed"])
    assert result is not None, "get_max_points should return a value"
    assert isinstance(result, int), f"get_max_points should return int, got {type(result)}"
    assert result > 0, f"max_points should be positive, got {result}"


@pytest.mark.asyncio
async def test_get_max_points_invalid(game):
    """get_max_points should return 0 for invalid bonus."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_max_points", ["nonexistent"])
    assert result == 0, f"Invalid bonus should return 0, got {result}"


# =============================================================================
# RESET TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_reset_run_completes(game):
    """reset_run should complete without error."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "reset_run")
    # Verify run depth was reset
    depth = await game.get_property(PRESTIGE_MANAGER_PATH, "current_run_max_depth")
    assert depth == 0, f"After reset_run, current_run_max_depth should be 0, got {depth}"


@pytest.mark.asyncio
async def test_reset_completes(game):
    """reset should complete without error."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "reset")
    # Verify full reset
    level = await game.get_property(PRESTIGE_MANAGER_PATH, "prestige_level")
    assert level == 0, f"After reset, prestige_level should be 0, got {level}"
    points = await game.get_property(PRESTIGE_MANAGER_PATH, "total_prestige_points")
    assert points == 0, f"After reset, total_prestige_points should be 0, got {points}"


# =============================================================================
# SAVE/LOAD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_save_data_returns_dict(game):
    """get_save_data should return a dictionary."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_save_data")
    assert result is not None, "get_save_data should return a value"
    assert isinstance(result, dict), f"get_save_data should return dict, got {type(result)}"


@pytest.mark.asyncio
async def test_get_save_data_has_prestige_level(game):
    """get_save_data should include prestige_level."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_save_data")
    assert "prestige_level" in result, "save data should have prestige_level"


@pytest.mark.asyncio
async def test_get_save_data_has_total_prestige_points(game):
    """get_save_data should include total_prestige_points."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_save_data")
    assert "total_prestige_points" in result, "save data should have total_prestige_points"


@pytest.mark.asyncio
async def test_get_save_data_has_available_points(game):
    """get_save_data should include available_points."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_save_data")
    assert "available_points" in result, "save data should have available_points"


@pytest.mark.asyncio
async def test_get_save_data_has_allocated_points(game):
    """get_save_data should include allocated_points."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_save_data")
    assert "allocated_points" in result, "save data should have allocated_points"


@pytest.mark.asyncio
async def test_get_save_data_has_current_run_max_depth(game):
    """get_save_data should include current_run_max_depth."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_save_data")
    assert "current_run_max_depth" in result, "save data should have current_run_max_depth"


@pytest.mark.asyncio
async def test_load_save_data_completes(game):
    """load_save_data should complete without error."""
    save_data = {
        "prestige_level": 2,
        "total_prestige_points": 15,
        "available_points": 5,
        "allocated_points": {"mining_speed": 3, "coin_bonus": 2},
        "current_run_max_depth": 750,
    }
    result = await game.call(PRESTIGE_MANAGER_PATH, "load_save_data", [save_data])
    # Verify data was loaded
    level = await game.get_property(PRESTIGE_MANAGER_PATH, "prestige_level")
    assert level == 2, f"After load, prestige_level should be 2, got {level}"


# =============================================================================
# SIGNAL TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_prestige_available_signal(game):
    """PrestigeManager should have prestige_available signal."""
    has_signal = await game.call(PRESTIGE_MANAGER_PATH, "has_signal", ["prestige_available"])
    assert has_signal is True, "PrestigeManager should have prestige_available signal"


@pytest.mark.asyncio
async def test_has_prestige_completed_signal(game):
    """PrestigeManager should have prestige_completed signal."""
    has_signal = await game.call(PRESTIGE_MANAGER_PATH, "has_signal", ["prestige_completed"])
    assert has_signal is True, "PrestigeManager should have prestige_completed signal"


@pytest.mark.asyncio
async def test_has_prestige_points_changed_signal(game):
    """PrestigeManager should have prestige_points_changed signal."""
    has_signal = await game.call(PRESTIGE_MANAGER_PATH, "has_signal", ["prestige_points_changed"])
    assert has_signal is True, "PrestigeManager should have prestige_points_changed signal"


# =============================================================================
# MILESTONE BONUS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_milestone_bonuses_increase_with_depth(game):
    """Deeper milestones should give more bonus points."""
    result = await game.get_property(PRESTIGE_MANAGER_PATH, "MILESTONE_BONUS_POINTS")
    prev_bonus = 0
    for milestone in sorted(result.keys()):
        bonus = result[milestone]
        assert bonus >= prev_bonus, f"Milestone {milestone} bonus ({bonus}) should be >= previous ({prev_bonus})"
        prev_bonus = bonus


@pytest.mark.asyncio
async def test_milestone_500_exists(game):
    """MILESTONE_BONUS_POINTS should have 500m milestone."""
    result = await game.get_property(PRESTIGE_MANAGER_PATH, "MILESTONE_BONUS_POINTS")
    assert 500 in result, "Should have 500m milestone"


@pytest.mark.asyncio
async def test_milestone_1000_exists(game):
    """MILESTONE_BONUS_POINTS should have 1000m milestone."""
    result = await game.get_property(PRESTIGE_MANAGER_PATH, "MILESTONE_BONUS_POINTS")
    assert 1000 in result, "Should have 1000m milestone"


@pytest.mark.asyncio
async def test_milestone_2000_exists(game):
    """MILESTONE_BONUS_POINTS should have 2000m milestone."""
    result = await game.get_property(PRESTIGE_MANAGER_PATH, "MILESTONE_BONUS_POINTS")
    assert 2000 in result, "Should have 2000m milestone"


# =============================================================================
# BONUS MAX VALUE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_mining_speed_max(game):
    """mining_speed should have a max of 20 points."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_max_points", ["mining_speed"])
    assert result == 20, f"mining_speed max should be 20, got {result}"


@pytest.mark.asyncio
async def test_coin_bonus_max(game):
    """coin_bonus should have a max of 25 points."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_max_points", ["coin_bonus"])
    assert result == 25, f"coin_bonus max should be 25, got {result}"


@pytest.mark.asyncio
async def test_fall_resistance_max(game):
    """fall_resistance should have a max of 10 points."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_max_points", ["fall_resistance"])
    assert result == 10, f"fall_resistance max should be 10, got {result}"


@pytest.mark.asyncio
async def test_starting_coins_max(game):
    """starting_coins should have a max of 20 points."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_max_points", ["starting_coins"])
    assert result == 20, f"starting_coins max should be 20, got {result}"


@pytest.mark.asyncio
async def test_inventory_bonus_max(game):
    """inventory_bonus should have a max of 5 points."""
    result = await game.call(PRESTIGE_MANAGER_PATH, "get_max_points", ["inventory_bonus"])
    assert result == 5, f"inventory_bonus max should be 5, got {result}"
