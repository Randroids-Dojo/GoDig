"""
EnemyManager tests for GoDig endless digging game.

Tests verify that EnemyManager:
1. Exists as an autoload singleton
2. Has all enemy type definitions
3. Provides correct enemy data lookups
4. Handles enemy spawn conditions based on depth
5. Manages combat state properly
6. Respects peaceful mode setting
7. Supports save/load functionality
"""
import pytest
from helpers import PATHS


# Path to enemy manager
ENEMY_MANAGER_PATH = PATHS.get("enemy_manager", "/root/EnemyManager")


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_enemy_manager_exists(game):
    """EnemyManager autoload should exist."""
    result = await game.node_exists(ENEMY_MANAGER_PATH)
    assert result.get("exists") is True, "EnemyManager autoload should exist"


# =============================================================================
# ENEMY TYPE DEFINITION TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_enemy_types(game):
    """EnemyManager should have ENEMY_TYPES constant."""
    result = await game.get_property(ENEMY_MANAGER_PATH, "ENEMY_TYPES")
    assert result is not None, "ENEMY_TYPES should exist"
    assert isinstance(result, dict), f"ENEMY_TYPES should be dict, got {type(result)}"
    assert len(result) > 0, "Should have at least one enemy type"


@pytest.mark.asyncio
async def test_has_cave_bat_enemy(game):
    """EnemyManager should have cave_bat enemy type."""
    result = await game.get_property(ENEMY_MANAGER_PATH, "ENEMY_TYPES")
    assert "cave_bat" in result, "Should have 'cave_bat' enemy type"


@pytest.mark.asyncio
async def test_has_rock_crawler_enemy(game):
    """EnemyManager should have rock_crawler enemy type."""
    result = await game.get_property(ENEMY_MANAGER_PATH, "ENEMY_TYPES")
    assert "rock_crawler" in result, "Should have 'rock_crawler' enemy type"


@pytest.mark.asyncio
async def test_has_crystal_spider_enemy(game):
    """EnemyManager should have crystal_spider enemy type."""
    result = await game.get_property(ENEMY_MANAGER_PATH, "ENEMY_TYPES")
    assert "crystal_spider" in result, "Should have 'crystal_spider' enemy type"


@pytest.mark.asyncio
async def test_has_lava_slug_enemy(game):
    """EnemyManager should have lava_slug enemy type."""
    result = await game.get_property(ENEMY_MANAGER_PATH, "ENEMY_TYPES")
    assert "lava_slug" in result, "Should have 'lava_slug' enemy type"


@pytest.mark.asyncio
async def test_has_void_wraith_enemy(game):
    """EnemyManager should have void_wraith enemy type."""
    result = await game.get_property(ENEMY_MANAGER_PATH, "ENEMY_TYPES")
    assert "void_wraith" in result, "Should have 'void_wraith' enemy type"


@pytest.mark.asyncio
async def test_enemy_types_count(game):
    """Should have 5 enemy types defined."""
    result = await game.get_property(ENEMY_MANAGER_PATH, "ENEMY_TYPES")
    assert len(result) == 5, f"Should have 5 enemy types, got {len(result)}"


# =============================================================================
# ENEMY DATA STRUCTURE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_enemy_type_has_name(game):
    """Each enemy type should have a name field."""
    result = await game.get_property(ENEMY_MANAGER_PATH, "ENEMY_TYPES")
    for enemy_id, enemy_data in result.items():
        assert "name" in enemy_data, f"Enemy {enemy_id} should have 'name' field"
        assert isinstance(enemy_data["name"], str), f"Enemy {enemy_id} name should be string"


@pytest.mark.asyncio
async def test_enemy_type_has_hp(game):
    """Each enemy type should have an hp field."""
    result = await game.get_property(ENEMY_MANAGER_PATH, "ENEMY_TYPES")
    for enemy_id, enemy_data in result.items():
        assert "hp" in enemy_data, f"Enemy {enemy_id} should have 'hp' field"
        assert isinstance(enemy_data["hp"], int), f"Enemy {enemy_id} hp should be int"
        assert enemy_data["hp"] > 0, f"Enemy {enemy_id} hp should be positive"


@pytest.mark.asyncio
async def test_enemy_type_has_damage(game):
    """Each enemy type should have a damage field."""
    result = await game.get_property(ENEMY_MANAGER_PATH, "ENEMY_TYPES")
    for enemy_id, enemy_data in result.items():
        assert "damage" in enemy_data, f"Enemy {enemy_id} should have 'damage' field"
        assert isinstance(enemy_data["damage"], int), f"Enemy {enemy_id} damage should be int"
        assert enemy_data["damage"] > 0, f"Enemy {enemy_id} damage should be positive"


@pytest.mark.asyncio
async def test_enemy_type_has_min_depth(game):
    """Each enemy type should have a min_depth field."""
    result = await game.get_property(ENEMY_MANAGER_PATH, "ENEMY_TYPES")
    for enemy_id, enemy_data in result.items():
        assert "min_depth" in enemy_data, f"Enemy {enemy_id} should have 'min_depth' field"
        assert isinstance(enemy_data["min_depth"], int), f"Enemy {enemy_id} min_depth should be int"


@pytest.mark.asyncio
async def test_enemy_type_has_max_depth(game):
    """Each enemy type should have a max_depth field."""
    result = await game.get_property(ENEMY_MANAGER_PATH, "ENEMY_TYPES")
    for enemy_id, enemy_data in result.items():
        assert "max_depth" in enemy_data, f"Enemy {enemy_id} should have 'max_depth' field"
        assert isinstance(enemy_data["max_depth"], int), f"Enemy {enemy_id} max_depth should be int"


@pytest.mark.asyncio
async def test_enemy_type_has_spawn_chance(game):
    """Each enemy type should have a spawn_chance field."""
    result = await game.get_property(ENEMY_MANAGER_PATH, "ENEMY_TYPES")
    for enemy_id, enemy_data in result.items():
        assert "spawn_chance" in enemy_data, f"Enemy {enemy_id} should have 'spawn_chance' field"
        assert isinstance(enemy_data["spawn_chance"], (int, float)), f"Enemy {enemy_id} spawn_chance should be number"
        assert 0 <= enemy_data["spawn_chance"] <= 1, f"Enemy {enemy_id} spawn_chance should be between 0 and 1"


@pytest.mark.asyncio
async def test_enemy_type_has_reward_coins(game):
    """Each enemy type should have a reward_coins field."""
    result = await game.get_property(ENEMY_MANAGER_PATH, "ENEMY_TYPES")
    for enemy_id, enemy_data in result.items():
        assert "reward_coins" in enemy_data, f"Enemy {enemy_id} should have 'reward_coins' field"
        assert isinstance(enemy_data["reward_coins"], int), f"Enemy {enemy_id} reward_coins should be int"
        assert enemy_data["reward_coins"] > 0, f"Enemy {enemy_id} reward_coins should be positive"


@pytest.mark.asyncio
async def test_enemy_type_has_description(game):
    """Each enemy type should have a description field."""
    result = await game.get_property(ENEMY_MANAGER_PATH, "ENEMY_TYPES")
    for enemy_id, enemy_data in result.items():
        assert "description" in enemy_data, f"Enemy {enemy_id} should have 'description' field"
        assert isinstance(enemy_data["description"], str), f"Enemy {enemy_id} description should be string"


# =============================================================================
# ENEMY DATA ACCESS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_enemy_info_valid(game):
    """get_enemy_info should return data for valid enemy."""
    result = await game.call(ENEMY_MANAGER_PATH, "get_enemy_info", ["cave_bat"])
    assert result is not None, "get_enemy_info should return a value"
    assert isinstance(result, dict), f"get_enemy_info should return dict, got {type(result)}"
    assert "name" in result, "enemy info should have 'name'"
    assert "hp" in result, "enemy info should have 'hp'"


@pytest.mark.asyncio
async def test_get_enemy_info_invalid(game):
    """get_enemy_info with invalid ID should return empty dict."""
    result = await game.call(ENEMY_MANAGER_PATH, "get_enemy_info", ["nonexistent_enemy"])
    assert result is not None, "get_enemy_info should return a value for invalid ID"
    assert isinstance(result, dict), "get_enemy_info should return dict"
    assert len(result) == 0, "Invalid enemy should return empty dict"


@pytest.mark.asyncio
async def test_get_enemies_at_depth_returns_array(game):
    """get_enemies_at_depth should return an array."""
    result = await game.call(ENEMY_MANAGER_PATH, "get_enemies_at_depth", [200])
    assert result is not None, "get_enemies_at_depth should return a value"
    assert isinstance(result, list), f"get_enemies_at_depth should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_get_enemies_at_depth_shallow(game):
    """At shallow depths (50), no enemies should be available."""
    result = await game.call(ENEMY_MANAGER_PATH, "get_enemies_at_depth", [50])
    assert len(result) == 0, f"At depth 50, no enemies should be available, got {result}"


@pytest.mark.asyncio
async def test_get_enemies_at_depth_100(game):
    """At depth 100, cave_bat should be available."""
    result = await game.call(ENEMY_MANAGER_PATH, "get_enemies_at_depth", [100])
    assert "cave_bat" in result, "At depth 100, cave_bat should be available"


@pytest.mark.asyncio
async def test_get_enemies_at_depth_200(game):
    """At depth 200, cave_bat and rock_crawler should be available."""
    result = await game.call(ENEMY_MANAGER_PATH, "get_enemies_at_depth", [200])
    assert "cave_bat" in result, "At depth 200, cave_bat should be available"
    assert "rock_crawler" in result, "At depth 200, rock_crawler should be available"


@pytest.mark.asyncio
async def test_get_enemies_at_depth_1000(game):
    """At depth 1000, void_wraith should be available."""
    result = await game.call(ENEMY_MANAGER_PATH, "get_enemies_at_depth", [1000])
    assert "void_wraith" in result, "At depth 1000, void_wraith should be available"


# =============================================================================
# COMBAT STATE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_initial_not_in_combat(game):
    """Initially, in_combat should be false."""
    result = await game.get_property(ENEMY_MANAGER_PATH, "in_combat")
    assert result is False, "Initially in_combat should be False"


@pytest.mark.asyncio
async def test_is_in_combat_returns_bool(game):
    """is_in_combat should return a boolean."""
    result = await game.call(ENEMY_MANAGER_PATH, "is_in_combat")
    assert isinstance(result, bool), f"is_in_combat should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_get_current_enemy_hp_initial(game):
    """get_current_enemy_hp should return 0 when not in combat."""
    result = await game.call(ENEMY_MANAGER_PATH, "get_current_enemy_hp")
    assert result == 0, f"current_enemy_hp should be 0 when not in combat, got {result}"


@pytest.mark.asyncio
async def test_get_current_enemy_initial(game):
    """get_current_enemy should return empty dict when not in combat."""
    result = await game.call(ENEMY_MANAGER_PATH, "get_current_enemy")
    assert result is not None, "get_current_enemy should return a value"
    assert isinstance(result, dict), f"get_current_enemy should return dict, got {type(result)}"


@pytest.mark.asyncio
async def test_active_enemies_initially_empty(game):
    """active_enemies should be empty initially."""
    result = await game.get_property(ENEMY_MANAGER_PATH, "active_enemies")
    assert result is not None, "active_enemies should exist"
    assert isinstance(result, dict), f"active_enemies should be dict, got {type(result)}"
    assert len(result) == 0, f"active_enemies should be empty initially, got {len(result)}"


# =============================================================================
# STATISTICS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_enemies_defeated_returns_int(game):
    """get_enemies_defeated should return an integer."""
    result = await game.call(ENEMY_MANAGER_PATH, "get_enemies_defeated")
    assert result is not None, "get_enemies_defeated should return a value"
    assert isinstance(result, int), f"get_enemies_defeated should return int, got {type(result)}"
    assert result >= 0, f"enemies_defeated should be non-negative, got {result}"


@pytest.mark.asyncio
async def test_enemies_defeated_property(game):
    """enemies_defeated property should be accessible."""
    result = await game.get_property(ENEMY_MANAGER_PATH, "enemies_defeated")
    assert result is not None, "enemies_defeated should exist"
    assert isinstance(result, int), f"enemies_defeated should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_total_enemy_reward_property(game):
    """total_enemy_reward property should be accessible."""
    result = await game.get_property(ENEMY_MANAGER_PATH, "total_enemy_reward")
    assert result is not None, "total_enemy_reward should exist"
    assert isinstance(result, int), f"total_enemy_reward should be int, got {type(result)}"


# =============================================================================
# PEACEFUL MODE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_enemies_enabled_returns_bool(game):
    """enemies_enabled should return a boolean."""
    result = await game.call(ENEMY_MANAGER_PATH, "enemies_enabled")
    assert isinstance(result, bool), f"enemies_enabled should return bool, got {type(result)}"


# =============================================================================
# RESET TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_reset_completes(game):
    """reset should complete without error."""
    result = await game.call(ENEMY_MANAGER_PATH, "reset")
    # Verify state was reset
    in_combat = await game.get_property(ENEMY_MANAGER_PATH, "in_combat")
    assert in_combat is False, "After reset, in_combat should be False"
    enemies_defeated = await game.get_property(ENEMY_MANAGER_PATH, "enemies_defeated")
    assert enemies_defeated == 0, "After reset, enemies_defeated should be 0"


@pytest.mark.asyncio
async def test_clear_enemies_completes(game):
    """clear_enemies should complete without error."""
    result = await game.call(ENEMY_MANAGER_PATH, "clear_enemies")
    # Verify enemies were cleared
    active_enemies = await game.get_property(ENEMY_MANAGER_PATH, "active_enemies")
    assert len(active_enemies) == 0, "After clear_enemies, active_enemies should be empty"


# =============================================================================
# SAVE/LOAD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_save_data_returns_dict(game):
    """get_save_data should return a dictionary."""
    result = await game.call(ENEMY_MANAGER_PATH, "get_save_data")
    assert result is not None, "get_save_data should return a value"
    assert isinstance(result, dict), f"get_save_data should return dict, got {type(result)}"


@pytest.mark.asyncio
async def test_get_save_data_has_enemies_defeated(game):
    """get_save_data should include enemies_defeated."""
    result = await game.call(ENEMY_MANAGER_PATH, "get_save_data")
    assert "enemies_defeated" in result, "save data should have enemies_defeated"


@pytest.mark.asyncio
async def test_get_save_data_has_total_enemy_reward(game):
    """get_save_data should include total_enemy_reward."""
    result = await game.call(ENEMY_MANAGER_PATH, "get_save_data")
    assert "total_enemy_reward" in result, "save data should have total_enemy_reward"


@pytest.mark.asyncio
async def test_load_save_data_completes(game):
    """load_save_data should complete without error."""
    save_data = {"enemies_defeated": 5, "total_enemy_reward": 100}
    result = await game.call(ENEMY_MANAGER_PATH, "load_save_data", [save_data])
    # Verify data was loaded
    enemies_defeated = await game.get_property(ENEMY_MANAGER_PATH, "enemies_defeated")
    assert enemies_defeated == 5, f"After load, enemies_defeated should be 5, got {enemies_defeated}"


# =============================================================================
# SIGNAL TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_enemy_spawned_signal(game):
    """EnemyManager should have enemy_spawned signal."""
    has_signal = await game.call(ENEMY_MANAGER_PATH, "has_signal", ["enemy_spawned"])
    assert has_signal is True, "EnemyManager should have enemy_spawned signal"


@pytest.mark.asyncio
async def test_has_enemy_defeated_signal(game):
    """EnemyManager should have enemy_defeated signal."""
    has_signal = await game.call(ENEMY_MANAGER_PATH, "has_signal", ["enemy_defeated"])
    assert has_signal is True, "EnemyManager should have enemy_defeated signal"


@pytest.mark.asyncio
async def test_has_combat_started_signal(game):
    """EnemyManager should have combat_started signal."""
    has_signal = await game.call(ENEMY_MANAGER_PATH, "has_signal", ["combat_started"])
    assert has_signal is True, "EnemyManager should have combat_started signal"


@pytest.mark.asyncio
async def test_has_combat_ended_signal(game):
    """EnemyManager should have combat_ended signal."""
    has_signal = await game.call(ENEMY_MANAGER_PATH, "has_signal", ["combat_ended"])
    assert has_signal is True, "EnemyManager should have combat_ended signal"


# =============================================================================
# ENEMY DIFFICULTY SCALING TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_deeper_enemies_have_more_hp(game):
    """Deeper enemies should have more HP."""
    result = await game.get_property(ENEMY_MANAGER_PATH, "ENEMY_TYPES")
    cave_bat_hp = result["cave_bat"]["hp"]
    void_wraith_hp = result["void_wraith"]["hp"]
    assert void_wraith_hp > cave_bat_hp, "Deeper enemies should have more HP"


@pytest.mark.asyncio
async def test_deeper_enemies_deal_more_damage(game):
    """Deeper enemies should deal more damage."""
    result = await game.get_property(ENEMY_MANAGER_PATH, "ENEMY_TYPES")
    cave_bat_damage = result["cave_bat"]["damage"]
    void_wraith_damage = result["void_wraith"]["damage"]
    assert void_wraith_damage > cave_bat_damage, "Deeper enemies should deal more damage"


@pytest.mark.asyncio
async def test_deeper_enemies_give_more_reward(game):
    """Deeper enemies should give more reward."""
    result = await game.get_property(ENEMY_MANAGER_PATH, "ENEMY_TYPES")
    cave_bat_reward = result["cave_bat"]["reward_coins"]
    void_wraith_reward = result["void_wraith"]["reward_coins"]
    assert void_wraith_reward > cave_bat_reward, "Deeper enemies should give more reward"


@pytest.mark.asyncio
async def test_deeper_enemies_have_lower_spawn_chance(game):
    """Deeper enemies should have lower spawn chance."""
    result = await game.get_property(ENEMY_MANAGER_PATH, "ENEMY_TYPES")
    cave_bat_chance = result["cave_bat"]["spawn_chance"]
    void_wraith_chance = result["void_wraith"]["spawn_chance"]
    assert void_wraith_chance < cave_bat_chance, "Deeper enemies should have lower spawn chance"


# =============================================================================
# WARNING DELAY TESTS (No Sudden Death From RNG)
# =============================================================================

@pytest.mark.asyncio
async def test_has_warning_delay_constant(game):
    """EnemyManager should have ENEMY_WARNING_DELAY constant."""
    result = await game.get_property(ENEMY_MANAGER_PATH, "ENEMY_WARNING_DELAY")
    assert result is not None, "ENEMY_WARNING_DELAY should exist"
    assert isinstance(result, (int, float)), f"ENEMY_WARNING_DELAY should be number, got {type(result)}"
    assert result > 0, "ENEMY_WARNING_DELAY should be positive (player needs time to react)"
