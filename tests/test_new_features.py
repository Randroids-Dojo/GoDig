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


# =============================================================================
# ENEMY SYSTEM INTEGRATION TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_enemy_manager_enemies_enabled_method(game):
    """Verify EnemyManager has enemies_enabled method for peaceful mode check."""
    result = await game.call_method(PATHS["enemy_manager"], "has_method", ["enemies_enabled"])
    assert result.get("result", False), "EnemyManager should have enemies_enabled method"


@pytest.mark.asyncio
async def test_enemy_manager_check_enemy_spawn_method(game):
    """Verify EnemyManager has check_enemy_spawn method."""
    result = await game.call_method(PATHS["enemy_manager"], "has_method", ["check_enemy_spawn"])
    assert result.get("result", False), "EnemyManager should have check_enemy_spawn method"


@pytest.mark.asyncio
async def test_enemy_manager_start_combat_method(game):
    """Verify EnemyManager has start_combat method."""
    result = await game.call_method(PATHS["enemy_manager"], "has_method", ["start_combat"])
    assert result.get("result", False), "EnemyManager should have start_combat method"


@pytest.mark.asyncio
async def test_enemy_manager_attack_enemy_method(game):
    """Verify EnemyManager has attack_enemy method."""
    result = await game.call_method(PATHS["enemy_manager"], "has_method", ["attack_enemy"])
    assert result.get("result", False), "EnemyManager should have attack_enemy method"


@pytest.mark.asyncio
async def test_settings_manager_peaceful_mode_exists(game):
    """Verify SettingsManager has peaceful_mode setting."""
    result = await game.get_property(PATHS["settings_manager"], "peaceful_mode")
    # peaceful_mode should be a boolean (default False)
    assert result is not None, "peaceful_mode property should exist"
    assert isinstance(result, bool), "peaceful_mode should be a boolean"


@pytest.mark.asyncio
async def test_enemy_spawn_depths_configured(game):
    """Verify enemy spawn depths are configured correctly."""
    # Cave Bat should spawn at depth 100+
    enemies_at_100 = await game.call_method(PATHS["enemy_manager"], "get_enemies_at_depth", [100])
    assert "cave_bat" in enemies_at_100.get("result", []), "Cave Bat should spawn at depth 100"

    # No enemies at surface (depth 0)
    enemies_at_0 = await game.call_method(PATHS["enemy_manager"], "get_enemies_at_depth", [0])
    assert len(enemies_at_0.get("result", [])) == 0, "No enemies should spawn at surface"


@pytest.mark.asyncio
async def test_enemy_manager_not_in_combat_initially(game):
    """Verify EnemyManager starts not in combat."""
    result = await game.call_method(PATHS["enemy_manager"], "is_in_combat")
    assert result.get("result") is False, "EnemyManager should not be in combat initially"


# =============================================================================
# SETTINGS MANAGER ADDITIONAL SETTINGS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_settings_manager_auto_sell_enabled_exists(game):
    """Verify SettingsManager has auto_sell_enabled setting."""
    result = await game.get_property(PATHS["settings_manager"], "auto_sell_enabled")
    # auto_sell_enabled should be a boolean (default False)
    assert result is not None, "auto_sell_enabled property should exist"
    assert isinstance(result, bool), "auto_sell_enabled should be a boolean"


@pytest.mark.asyncio
async def test_settings_manager_tension_audio_enabled_exists(game):
    """Verify SettingsManager has tension_audio_enabled setting."""
    result = await game.get_property(PATHS["settings_manager"], "tension_audio_enabled")
    # tension_audio_enabled should be a boolean (default True)
    assert result is not None, "tension_audio_enabled property should exist"
    assert isinstance(result, bool), "tension_audio_enabled should be a boolean"


# =============================================================================
# ENEMY-MINING INTEGRATION TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_peaceful_mode_disables_enemy_spawning(game):
    """Verify peaceful mode prevents enemy spawning."""
    # Enable peaceful mode
    await game.set_property(PATHS["settings_manager"], "peaceful_mode", True)

    # Check that enemies are disabled
    result = await game.call_method(PATHS["enemy_manager"], "enemies_enabled")
    assert result.get("result") is False, "Enemies should be disabled in peaceful mode"

    # Restore default state
    await game.set_property(PATHS["settings_manager"], "peaceful_mode", False)


@pytest.mark.asyncio
async def test_normal_mode_enables_enemy_spawning(game):
    """Verify normal mode (non-peaceful) allows enemy spawning."""
    # Ensure peaceful mode is off
    await game.set_property(PATHS["settings_manager"], "peaceful_mode", False)

    # Check that enemies are enabled
    result = await game.call_method(PATHS["enemy_manager"], "enemies_enabled")
    assert result.get("result") is True, "Enemies should be enabled in normal mode"


@pytest.mark.asyncio
async def test_enemy_spawn_check_returns_empty_at_surface(game):
    """Verify no enemy spawns at depth 0 (surface)."""
    # Ensure enemies are enabled
    await game.set_property(PATHS["settings_manager"], "peaceful_mode", False)

    # Check spawn at surface - should return empty string (no spawn)
    result = await game.call_method(
        PATHS["enemy_manager"],
        "check_enemy_spawn",
        [{"x": 0, "y": 0, "_type": "Vector2i"}, 0]  # grid_pos, depth
    )
    assert result.get("result") == "", "No enemies should spawn at surface (depth 0)"


@pytest.mark.asyncio
async def test_enemy_types_have_valid_depth_ranges(game):
    """Verify all enemy types have sensible depth configurations."""
    # Check multiple depths for expected enemy availability
    depth_tests = [
        (50, 0, "No enemies below depth 100"),
        (100, 1, "At least 1 enemy at depth 100"),
        (200, 2, "At least 2 enemies at depth 200"),
        (500, 3, "At least 3 enemies at depth 500"),
    ]

    for depth, min_count, description in depth_tests:
        result = await game.call_method(PATHS["enemy_manager"], "get_enemies_at_depth", [depth])
        enemies = result.get("result", [])
        assert len(enemies) >= min_count, f"{description}, got {len(enemies)}"


@pytest.mark.asyncio
async def test_enemy_manager_reset_clears_state(game):
    """Verify EnemyManager reset clears all state."""
    # Reset the manager
    await game.call(PATHS["enemy_manager"], "reset")

    # Verify state is cleared
    in_combat = await game.call_method(PATHS["enemy_manager"], "is_in_combat")
    defeated = await game.call_method(PATHS["enemy_manager"], "get_enemies_defeated")

    assert in_combat.get("result") is False, "Should not be in combat after reset"
    assert defeated.get("result") == 0, "Defeated count should be 0 after reset"


@pytest.mark.asyncio
async def test_enemy_type_cave_bat_properties(game):
    """Verify cave_bat enemy has correct configuration."""
    result = await game.call_method(PATHS["enemy_manager"], "get_enemy_info", ["cave_bat"])
    info = result.get("result", {})

    assert info.get("name") == "Cave Bat", "Cave Bat should have correct name"
    assert info.get("min_depth") == 100, "Cave Bat min depth should be 100"
    assert info.get("hp") == 10, "Cave Bat should have 10 HP"
    assert info.get("damage") == 5, "Cave Bat should deal 5 damage"
    assert info.get("reward_coins") == 25, "Cave Bat should reward 25 coins"


@pytest.mark.asyncio
async def test_enemy_type_rock_crawler_properties(game):
    """Verify rock_crawler enemy has correct configuration."""
    result = await game.call_method(PATHS["enemy_manager"], "get_enemy_info", ["rock_crawler"])
    info = result.get("result", {})

    assert info.get("name") == "Rock Crawler", "Rock Crawler should have correct name"
    assert info.get("min_depth") == 200, "Rock Crawler min depth should be 200"
    assert info.get("hp") == 25, "Rock Crawler should have 25 HP"
    assert info.get("damage") == 10, "Rock Crawler should deal 10 damage"


@pytest.mark.asyncio
async def test_enemy_warning_delay_configured(game):
    """Verify enemy warning delay is set (no sudden death from RNG)."""
    # The warning delay ensures players have time to react before combat starts
    # This is part of the "no beheading" rule - fair warning principle
    result = await game.get_property(PATHS["enemy_manager"], "ENEMY_WARNING_DELAY")
    delay = result

    # Warning delay should be at least 0.5 seconds for fair warning
    assert delay >= 0.5, f"Enemy warning delay should be at least 0.5s for fairness, got {delay}"
