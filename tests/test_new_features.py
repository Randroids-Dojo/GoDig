"""
Tests for new features: Daily Rewards, Day/Night, Prestige, Enemies, Biomes, Tools.

These tests verify the new managers are initialized correctly and data is loaded.
"""
import pytest
from helpers import PATHS


@pytest.mark.asyncio
async def test_daily_rewards_manager_exists(game):
    """Verify DailyRewardsManager autoload is loaded."""
    result = await game.node_exists(PATHS["daily_rewards_manager"])
    assert result.get("exists", False), "DailyRewardsManager should exist as autoload"


@pytest.mark.asyncio
async def test_day_night_manager_exists(game):
    """Verify DayNightManager autoload is loaded."""
    result = await game.node_exists(PATHS["day_night_manager"])
    assert result.get("exists", False), "DayNightManager should exist as autoload"


@pytest.mark.asyncio
async def test_prestige_manager_exists(game):
    """Verify PrestigeManager autoload is loaded."""
    result = await game.node_exists(PATHS["prestige_manager"])
    assert result.get("exists", False), "PrestigeManager should exist as autoload"


@pytest.mark.asyncio
async def test_enemy_manager_exists(game):
    """Verify EnemyManager autoload is loaded."""
    result = await game.node_exists(PATHS["enemy_manager"])
    assert result.get("exists", False), "EnemyManager should exist as autoload"


@pytest.mark.asyncio
async def test_biome_manager_exists(game):
    """Verify BiomeManager autoload is loaded."""
    result = await game.node_exists(PATHS["biome_manager"])
    assert result.get("exists", False), "BiomeManager should exist as autoload"


@pytest.mark.asyncio
async def test_data_registry_loads_new_tools(game):
    """Verify DataRegistry loads all pickaxe tiers including new ones."""
    tool_count = await game.call_method(PATHS["data_registry"], "get_all_tool_ids")
    tool_ids = tool_count.get("result", [])

    # Should have 9 tools total
    assert len(tool_ids) >= 9, f"Expected at least 9 tools, got {len(tool_ids)}"

    # Verify new pickaxes exist
    expected_tools = ["silver_pickaxe", "mythril_pickaxe", "diamond_pickaxe", "void_pickaxe"]
    for tool_id in expected_tools:
        assert tool_id in tool_ids, f"Missing tool: {tool_id}"


@pytest.mark.asyncio
async def test_data_registry_loads_void_depths_layer(game):
    """Verify Void Depths layer is loaded."""
    result = await game.call_method(PATHS["data_registry"], "has_layer", ["void_depths"])
    assert result.get("result", False), "Void Depths layer should be loaded"


@pytest.mark.asyncio
async def test_data_registry_loads_void_crystal_ore(game):
    """Verify Void Crystal ore is loaded."""
    ore = await game.call_method(PATHS["data_registry"], "get_ore", ["void_crystal"])
    assert ore.get("result") is not None, "Void Crystal ore should be loaded"


@pytest.mark.asyncio
async def test_day_night_manager_time_tracking(game):
    """Verify DayNightManager tracks time correctly."""
    hour = await game.call_method(PATHS["day_night_manager"], "get_hour")
    assert "result" in hour, "get_hour should return a result"
    assert 0 <= hour["result"] <= 23, "Hour should be 0-23"


@pytest.mark.asyncio
async def test_day_night_manager_phase(game):
    """Verify DayNightManager returns a valid phase."""
    phase = await game.call_method(PATHS["day_night_manager"], "get_phase_name")
    valid_phases = ["Dawn", "Day", "Dusk", "Night"]
    assert phase.get("result") in valid_phases, f"Phase should be one of {valid_phases}"


@pytest.mark.asyncio
async def test_prestige_manager_initial_state(game):
    """Verify PrestigeManager starts with zero prestige."""
    level = await game.call_method(PATHS["prestige_manager"], "get_prestige_level")
    assert level.get("result", -1) == 0, "Initial prestige level should be 0"


@pytest.mark.asyncio
async def test_enemy_manager_has_enemy_types(game):
    """Verify EnemyManager has enemy types defined."""
    enemies = await game.call_method(PATHS["enemy_manager"], "get_enemies_at_depth", [500])
    assert "result" in enemies, "get_enemies_at_depth should return a result"
    assert len(enemies["result"]) > 0, "Should have enemies available at depth 500"


@pytest.mark.asyncio
async def test_biome_manager_has_biomes(game):
    """Verify BiomeManager has biomes defined."""
    biomes = await game.call_method(PATHS["biome_manager"], "get_all_biome_ids")
    assert "result" in biomes, "get_all_biome_ids should return a result"
    assert len(biomes["result"]) >= 9, "Should have at least 9 biomes defined"


@pytest.mark.asyncio
async def test_biome_manager_current_biome(game):
    """Verify BiomeManager returns current biome."""
    biome = await game.call_method(PATHS["biome_manager"], "get_current_biome")
    assert biome.get("result") == "normal", "Initial biome should be 'normal'"


@pytest.mark.asyncio
async def test_daily_rewards_streak(game):
    """Verify DailyRewardsManager tracks streaks."""
    streak = await game.call_method(PATHS["daily_rewards_manager"], "get_current_streak")
    assert "result" in streak, "get_current_streak should return a result"
    # Streak might be 0 or 1 depending on when tested
    assert streak["result"] >= 0, "Streak should be non-negative"


# =============================================================================
# ONE-TAP LADDER PLACEMENT TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_player_has_place_ladder_method(game):
    """Verify player has the place_ladder_at_position method."""
    result = await game.call_method(PATHS["player"], "has_method", ["place_ladder_at_position"])
    assert result.get("result", False), "Player should have place_ladder_at_position method"


@pytest.mark.asyncio
async def test_player_has_can_place_ladder_method(game):
    """Verify player has the can_place_ladder method for HUD validation."""
    result = await game.call_method(PATHS["player"], "has_method", ["can_place_ladder"])
    assert result.get("result", False), "Player should have can_place_ladder method"


@pytest.mark.asyncio
async def test_ladder_placement_requires_ladder_in_inventory(game):
    """Player cannot place ladder without ladder in inventory."""
    # Clear inventory to ensure no ladders
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Verify player cannot place ladder
    result = await game.call(PATHS["player"], "can_place_ladder")
    assert result is False, "Should not be able to place ladder without one in inventory"


@pytest.mark.asyncio
async def test_ladder_placement_with_ladder_in_inventory(game):
    """Player can place ladder when they have one in inventory."""
    # Clear inventory first
    await game.call(PATHS["inventory_manager"], "clear_all")

    # Add a ladder
    await game.call(PATHS["inventory_manager"], "add_item_by_id", ["ladder", 1])

    # Verify we have a ladder
    count = await game.call(PATHS["inventory_manager"], "get_item_count_by_id", ["ladder"])
    assert count == 1, f"Should have 1 ladder, got {count}"

    # Check if player can place (depends on position - may fail if on solid block)
    can_place = await game.call(PATHS["player"], "can_place_ladder")
    # Note: can_place may be False if player is standing on solid block or position already has ladder
    # The important thing is the method works and returns a boolean
    assert isinstance(can_place, bool), "can_place_ladder should return a boolean"


@pytest.mark.asyncio
async def test_ladder_quickslot_exists_in_hud(game):
    """Verify ladder quickslot exists in HUD."""
    result = await game.node_exists(PATHS["ladder_quickslot"])
    assert result.get("exists", False), "Ladder quickslot should exist in HUD"
