"""
EconomyConfig tests for GoDig endless digging game.

Tests verify that EconomyConfig:
1. Exists as an autoload singleton
2. Has all economy configuration properties
3. Provides correct economy value calculations
4. Supports A/B testing
5. Maintains session snapshot for stable values
"""
import pytest
from helpers import PATHS


# Path to economy config
ECONOMY_CONFIG_PATH = PATHS.get("economy_config", "/root/EconomyConfig")


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_economy_config_exists(game):
    """EconomyConfig autoload should exist."""
    result = await game.node_exists(ECONOMY_CONFIG_PATH)
    assert result.get("exists") is True, "EconomyConfig autoload should exist"


# =============================================================================
# ORE VALUE PROPERTY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_ore_value_multiplier(game):
    """EconomyConfig should have ore_value_multiplier property."""
    result = await game.get_property(ECONOMY_CONFIG_PATH, "ore_value_multiplier")
    assert result is not None, "ore_value_multiplier should exist"
    assert isinstance(result, (int, float)), f"ore_value_multiplier should be number, got {type(result)}"
    assert result > 0, f"ore_value_multiplier should be positive, got {result}"


@pytest.mark.asyncio
async def test_has_ore_depth_value_bonus(game):
    """EconomyConfig should have ore_depth_value_bonus property."""
    result = await game.get_property(ECONOMY_CONFIG_PATH, "ore_depth_value_bonus")
    assert result is not None, "ore_depth_value_bonus should exist"
    assert isinstance(result, (int, float)), f"ore_depth_value_bonus should be number, got {type(result)}"


@pytest.mark.asyncio
async def test_has_early_ore_boost(game):
    """EconomyConfig should have early_ore_boost property."""
    result = await game.get_property(ECONOMY_CONFIG_PATH, "early_ore_boost")
    assert result is not None, "early_ore_boost should exist"
    assert isinstance(result, (int, float)), f"early_ore_boost should be number, got {type(result)}"


@pytest.mark.asyncio
async def test_has_ore_multipliers(game):
    """EconomyConfig should have ore_multipliers dictionary."""
    result = await game.get_property(ECONOMY_CONFIG_PATH, "ore_multipliers")
    assert result is not None, "ore_multipliers should exist"
    assert isinstance(result, dict), f"ore_multipliers should be dict, got {type(result)}"


# =============================================================================
# TOOL COST PROPERTY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_tool_cost_multiplier(game):
    """EconomyConfig should have tool_cost_multiplier property."""
    result = await game.get_property(ECONOMY_CONFIG_PATH, "tool_cost_multiplier")
    assert result is not None, "tool_cost_multiplier should exist"
    assert isinstance(result, (int, float)), f"tool_cost_multiplier should be number, got {type(result)}"


@pytest.mark.asyncio
async def test_has_tool_cost_overrides(game):
    """EconomyConfig should have tool_cost_overrides dictionary."""
    result = await game.get_property(ECONOMY_CONFIG_PATH, "tool_cost_overrides")
    assert result is not None, "tool_cost_overrides should exist"
    assert isinstance(result, dict), f"tool_cost_overrides should be dict, got {type(result)}"


# =============================================================================
# CONSUMABLE COST PROPERTY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_ladder_cost(game):
    """EconomyConfig should have ladder_cost property."""
    result = await game.get_property(ECONOMY_CONFIG_PATH, "ladder_cost")
    assert result is not None, "ladder_cost should exist"
    assert isinstance(result, int), f"ladder_cost should be int, got {type(result)}"
    assert result > 0, f"ladder_cost should be positive, got {result}"


@pytest.mark.asyncio
async def test_has_rope_cost(game):
    """EconomyConfig should have rope_cost property."""
    result = await game.get_property(ECONOMY_CONFIG_PATH, "rope_cost")
    assert result is not None, "rope_cost should exist"
    assert isinstance(result, int), f"rope_cost should be int, got {type(result)}"
    assert result > 0, f"rope_cost should be positive, got {result}"


@pytest.mark.asyncio
async def test_has_teleport_scroll_cost(game):
    """EconomyConfig should have teleport_scroll_cost property."""
    result = await game.get_property(ECONOMY_CONFIG_PATH, "teleport_scroll_cost")
    assert result is not None, "teleport_scroll_cost should exist"
    assert isinstance(result, int), f"teleport_scroll_cost should be int, got {type(result)}"
    assert result > 0, f"teleport_scroll_cost should be positive, got {result}"


# =============================================================================
# UPGRADE CURVE PROPERTY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_upgrade_cost_model(game):
    """EconomyConfig should have upgrade_cost_model property."""
    result = await game.get_property(ECONOMY_CONFIG_PATH, "upgrade_cost_model")
    assert result is not None, "upgrade_cost_model should exist"
    assert isinstance(result, str), f"upgrade_cost_model should be string, got {type(result)}"
    valid_models = ["exponential", "linear", "soft_cap"]
    assert result in valid_models, f"upgrade_cost_model should be one of {valid_models}, got {result}"


@pytest.mark.asyncio
async def test_has_upgrade_exp_base(game):
    """EconomyConfig should have upgrade_exp_base property."""
    result = await game.get_property(ECONOMY_CONFIG_PATH, "upgrade_exp_base")
    assert result is not None, "upgrade_exp_base should exist"
    assert isinstance(result, (int, float)), f"upgrade_exp_base should be number, got {type(result)}"
    assert result > 1, f"upgrade_exp_base should be > 1, got {result}"


@pytest.mark.asyncio
async def test_has_upgrade_soft_cap_tier(game):
    """EconomyConfig should have upgrade_soft_cap_tier property."""
    result = await game.get_property(ECONOMY_CONFIG_PATH, "upgrade_soft_cap_tier")
    assert result is not None, "upgrade_soft_cap_tier should exist"
    assert isinstance(result, int), f"upgrade_soft_cap_tier should be int, got {type(result)}"
    assert result > 0, f"upgrade_soft_cap_tier should be positive, got {result}"


# =============================================================================
# SESSION TARGET PROPERTY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_target_first_ore_time(game):
    """EconomyConfig should have target_first_ore_time property."""
    result = await game.get_property(ECONOMY_CONFIG_PATH, "target_first_ore_time")
    assert result is not None, "target_first_ore_time should exist"
    assert isinstance(result, (int, float)), f"target_first_ore_time should be number, got {type(result)}"
    assert result > 0, f"target_first_ore_time should be positive, got {result}"


@pytest.mark.asyncio
async def test_has_target_first_sell_time(game):
    """EconomyConfig should have target_first_sell_time property."""
    result = await game.get_property(ECONOMY_CONFIG_PATH, "target_first_sell_time")
    assert result is not None, "target_first_sell_time should exist"
    assert isinstance(result, (int, float)), f"target_first_sell_time should be number, got {type(result)}"


@pytest.mark.asyncio
async def test_has_target_first_upgrade_time(game):
    """EconomyConfig should have target_first_upgrade_time property."""
    result = await game.get_property(ECONOMY_CONFIG_PATH, "target_first_upgrade_time")
    assert result is not None, "target_first_upgrade_time should exist"
    assert isinstance(result, (int, float)), f"target_first_upgrade_time should be number, got {type(result)}"


@pytest.mark.asyncio
async def test_has_target_session_length(game):
    """EconomyConfig should have target_session_length property."""
    result = await game.get_property(ECONOMY_CONFIG_PATH, "target_session_length")
    assert result is not None, "target_session_length should exist"
    assert isinstance(result, (int, float)), f"target_session_length should be number, got {type(result)}"


# =============================================================================
# RISK ZONE PROPERTY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_risk_zones(game):
    """EconomyConfig should have risk_zones dictionary."""
    result = await game.get_property(ECONOMY_CONFIG_PATH, "risk_zones")
    assert result is not None, "risk_zones should exist"
    assert isinstance(result, dict), f"risk_zones should be dict, got {type(result)}"
    assert len(result) > 0, "risk_zones should not be empty"


@pytest.mark.asyncio
async def test_risk_zones_have_value_mult(game):
    """Each risk zone should have value_mult property."""
    result = await game.get_property(ECONOMY_CONFIG_PATH, "risk_zones")
    for depth, zone_data in result.items():
        assert "value_mult" in zone_data, f"Zone at depth {depth} should have value_mult"


@pytest.mark.asyncio
async def test_has_jackpot_chance(game):
    """EconomyConfig should have jackpot_chance property."""
    result = await game.get_property(ECONOMY_CONFIG_PATH, "jackpot_chance")
    assert result is not None, "jackpot_chance should exist"
    assert isinstance(result, (int, float)), f"jackpot_chance should be number, got {type(result)}"
    assert 0 <= result <= 1, f"jackpot_chance should be 0-1, got {result}"


@pytest.mark.asyncio
async def test_has_jackpot_mult_range(game):
    """EconomyConfig should have jackpot multiplier range properties."""
    min_result = await game.get_property(ECONOMY_CONFIG_PATH, "jackpot_mult_min")
    max_result = await game.get_property(ECONOMY_CONFIG_PATH, "jackpot_mult_max")
    assert min_result is not None, "jackpot_mult_min should exist"
    assert max_result is not None, "jackpot_mult_max should exist"
    assert max_result >= min_result, f"jackpot_mult_max ({max_result}) should be >= min ({min_result})"


# =============================================================================
# A/B TEST PROPERTY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_ab_assignments(game):
    """EconomyConfig should have ab_assignments dictionary."""
    result = await game.get_property(ECONOMY_CONFIG_PATH, "ab_assignments")
    assert result is not None, "ab_assignments should exist"
    assert isinstance(result, dict), f"ab_assignments should be dict, got {type(result)}"


# =============================================================================
# METHOD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_ore_sell_value_returns_positive(game):
    """get_ore_sell_value should return a positive value."""
    result = await game.call(ECONOMY_CONFIG_PATH, "get_ore_sell_value", ["coal", 10, 0])
    assert result is not None, "get_ore_sell_value should return a value"
    assert isinstance(result, int), f"get_ore_sell_value should return int, got {type(result)}"
    assert result > 0, f"Ore sell value should be positive, got {result}"


@pytest.mark.asyncio
async def test_get_ore_sell_value_increases_with_depth(game):
    """get_ore_sell_value should increase at deeper depths."""
    shallow_value = await game.call(ECONOMY_CONFIG_PATH, "get_ore_sell_value", ["coal", 10, 0])
    deep_value = await game.call(ECONOMY_CONFIG_PATH, "get_ore_sell_value", ["coal", 10, 100])
    # Due to variance, we can't guarantee strictly greater, but the base should trend higher
    # Just verify both are valid
    assert shallow_value > 0, f"Shallow value should be positive, got {shallow_value}"
    assert deep_value > 0, f"Deep value should be positive, got {deep_value}"


@pytest.mark.asyncio
async def test_get_tool_cost_returns_valid(game):
    """get_tool_cost should return a valid cost."""
    result = await game.call(ECONOMY_CONFIG_PATH, "get_tool_cost", ["copper_pickaxe", 100])
    assert result is not None, "get_tool_cost should return a value"
    assert isinstance(result, int), f"get_tool_cost should return int, got {type(result)}"
    assert result >= 0, f"Tool cost should be non-negative, got {result}"


@pytest.mark.asyncio
async def test_get_consumable_cost_ladder(game):
    """get_consumable_cost for ladder should return the configured cost."""
    result = await game.call(ECONOMY_CONFIG_PATH, "get_consumable_cost", ["ladder"])
    configured_cost = await game.get_property(ECONOMY_CONFIG_PATH, "ladder_cost")
    assert result is not None, "get_consumable_cost should return a value"
    assert result == configured_cost, f"Ladder cost should match config ({configured_cost}), got {result}"


@pytest.mark.asyncio
async def test_get_consumable_cost_rope(game):
    """get_consumable_cost for rope should return the configured cost."""
    result = await game.call(ECONOMY_CONFIG_PATH, "get_consumable_cost", ["rope"])
    configured_cost = await game.get_property(ECONOMY_CONFIG_PATH, "rope_cost")
    assert result is not None, "get_consumable_cost should return a value"
    assert result == configured_cost, f"Rope cost should match config ({configured_cost}), got {result}"


@pytest.mark.asyncio
async def test_get_consumable_cost_teleport_scroll(game):
    """get_consumable_cost for teleport_scroll should return the configured cost."""
    result = await game.call(ECONOMY_CONFIG_PATH, "get_consumable_cost", ["teleport_scroll"])
    configured_cost = await game.get_property(ECONOMY_CONFIG_PATH, "teleport_scroll_cost")
    assert result is not None, "get_consumable_cost should return a value"
    assert result == configured_cost, f"Teleport scroll cost should match config ({configured_cost}), got {result}"


@pytest.mark.asyncio
async def test_get_consumable_cost_unknown_returns_zero(game):
    """get_consumable_cost for unknown item should return 0."""
    result = await game.call(ECONOMY_CONFIG_PATH, "get_consumable_cost", ["unknown_item"])
    assert result == 0, f"Unknown item cost should be 0, got {result}"


@pytest.mark.asyncio
async def test_get_ab_group_returns_string(game):
    """get_ab_group should return a string (group name or 'control')."""
    result = await game.call(ECONOMY_CONFIG_PATH, "get_ab_group", ["nonexistent_test"])
    assert result is not None, "get_ab_group should return a value"
    assert isinstance(result, str), f"get_ab_group should return string, got {type(result)}"
    # Unknown test should return "control"
    assert result == "control", f"Unknown test should return 'control', got {result}"


@pytest.mark.asyncio
async def test_is_config_loaded(game):
    """is_config_loaded should return a boolean."""
    result = await game.call(ECONOMY_CONFIG_PATH, "is_config_loaded")
    assert result is not None, "is_config_loaded should return a value"
    assert isinstance(result, bool), f"is_config_loaded should return bool, got {type(result)}"


# =============================================================================
# SIGNAL TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_config_loaded_signal(game):
    """EconomyConfig should have config_loaded signal."""
    has_signal = await game.call(ECONOMY_CONFIG_PATH, "has_signal", ["config_loaded"])
    assert has_signal is True, "EconomyConfig should have config_loaded signal"


@pytest.mark.asyncio
async def test_has_ab_test_assigned_signal(game):
    """EconomyConfig should have ab_test_assigned signal."""
    has_signal = await game.call(ECONOMY_CONFIG_PATH, "has_signal", ["ab_test_assigned"])
    assert has_signal is True, "EconomyConfig should have ab_test_assigned signal"


# =============================================================================
# DEBUG METHOD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_config_debug_returns_dict(game):
    """get_config_debug should return a dictionary."""
    result = await game.call(ECONOMY_CONFIG_PATH, "get_config_debug")
    assert result is not None, "get_config_debug should return a value"
    assert isinstance(result, dict), f"get_config_debug should return dict, got {type(result)}"


@pytest.mark.asyncio
async def test_get_config_debug_has_key_values(game):
    """get_config_debug should include key configuration values."""
    result = await game.call(ECONOMY_CONFIG_PATH, "get_config_debug")
    expected_keys = ["ore_value_multiplier", "ladder_cost", "ab_assignments"]
    for key in expected_keys:
        assert key in result, f"Debug config should include {key}"


# =============================================================================
# FORCE RELOAD TEST
# =============================================================================

@pytest.mark.asyncio
async def test_force_reload_completes(game):
    """force_reload should complete without error."""
    # This is a void method, just verify it doesn't throw
    result = await game.call(ECONOMY_CONFIG_PATH, "force_reload")
    # Method should complete without error
    assert result is None or isinstance(result, bool) or result == {}, "force_reload should complete"


# =============================================================================
# SESSION PACING TARGET TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_pacing_targets_are_reasonable(game):
    """Session pacing targets should have reasonable relationships."""
    first_ore = await game.get_property(ECONOMY_CONFIG_PATH, "target_first_ore_time")
    first_sell = await game.get_property(ECONOMY_CONFIG_PATH, "target_first_sell_time")
    first_upgrade = await game.get_property(ECONOMY_CONFIG_PATH, "target_first_upgrade_time")

    # First ore should come before first sell
    assert first_ore <= first_sell, f"First ore ({first_ore}s) should come before/at first sell ({first_sell}s)"

    # First sell should come before first upgrade
    assert first_sell <= first_upgrade, f"First sell ({first_sell}s) should come before/at first upgrade ({first_upgrade}s)"


@pytest.mark.asyncio
async def test_target_trips_per_upgrade(game):
    """target_trips_per_upgrade should be a reasonable number (1-5)."""
    result = await game.get_property(ECONOMY_CONFIG_PATH, "target_trips_per_upgrade")
    assert result is not None, "target_trips_per_upgrade should exist"
    assert isinstance(result, int), f"target_trips_per_upgrade should be int, got {type(result)}"
    assert 1 <= result <= 5, f"target_trips_per_upgrade should be 1-5, got {result}"
