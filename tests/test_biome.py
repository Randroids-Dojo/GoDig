"""
BiomeManager tests for GoDig endless digging game.

Tests verify that BiomeManager:
1. Exists as an autoload singleton
2. Has all biome definitions
3. Provides correct biome data lookups
4. Tracks biome state and discoveries
5. Handles surprise cave biome discovery
"""
import pytest
from helpers import PATHS


# Path to biome manager
BIOME_MANAGER_PATH = PATHS.get("biome_manager", "/root/BiomeManager")


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_biome_manager_exists(game):
    """BiomeManager autoload should exist."""
    result = await game.node_exists(BIOME_MANAGER_PATH)
    assert result.get("exists") is True, "BiomeManager autoload should exist"


# =============================================================================
# BIOME STATE PROPERTY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_current_biome(game):
    """BiomeManager should have current_biome property."""
    result = await game.get_property(BIOME_MANAGER_PATH, "current_biome")
    assert result is not None, "current_biome should exist"
    assert isinstance(result, str), f"current_biome should be string, got {type(result)}"


@pytest.mark.asyncio
async def test_has_current_biome_data(game):
    """BiomeManager should have current_biome_data property."""
    result = await game.get_property(BIOME_MANAGER_PATH, "current_biome_data")
    assert result is not None, "current_biome_data should exist"
    assert isinstance(result, dict), f"current_biome_data should be dict, got {type(result)}"


@pytest.mark.asyncio
async def test_current_biome_data_has_name(game):
    """current_biome_data should have a name field."""
    result = await game.get_property(BIOME_MANAGER_PATH, "current_biome_data")
    assert "name" in result, "current_biome_data should have 'name' field"
    assert isinstance(result["name"], str), "biome name should be string"


@pytest.mark.asyncio
async def test_current_biome_data_has_ore_multiplier(game):
    """current_biome_data should have ore_multiplier field."""
    result = await game.get_property(BIOME_MANAGER_PATH, "current_biome_data")
    assert "ore_multiplier" in result, "current_biome_data should have 'ore_multiplier' field"
    assert isinstance(result["ore_multiplier"], (int, float)), "ore_multiplier should be number"


# =============================================================================
# BIOME DATA ACCESS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_all_biome_ids(game):
    """get_all_biome_ids should return an array of biome IDs."""
    result = await game.call(BIOME_MANAGER_PATH, "get_all_biome_ids")
    assert result is not None, "get_all_biome_ids should return a value"
    assert isinstance(result, list), f"get_all_biome_ids should return list, got {type(result)}"
    assert len(result) > 0, "Should have at least one biome"


@pytest.mark.asyncio
async def test_has_normal_biome(game):
    """get_all_biome_ids should include 'normal' biome."""
    result = await game.call(BIOME_MANAGER_PATH, "get_all_biome_ids")
    assert "normal" in result, "Should have 'normal' biome"


@pytest.mark.asyncio
async def test_has_crystal_cave_biome(game):
    """get_all_biome_ids should include 'crystal_cave' biome."""
    result = await game.call(BIOME_MANAGER_PATH, "get_all_biome_ids")
    assert "crystal_cave" in result, "Should have 'crystal_cave' biome"


@pytest.mark.asyncio
async def test_has_lava_pocket_biome(game):
    """get_all_biome_ids should include 'lava_pocket' biome."""
    result = await game.call(BIOME_MANAGER_PATH, "get_all_biome_ids")
    assert "lava_pocket" in result, "Should have 'lava_pocket' biome"


@pytest.mark.asyncio
async def test_get_biome_data_valid(game):
    """get_biome_data should return data for a valid biome."""
    result = await game.call(BIOME_MANAGER_PATH, "get_biome_data", ["normal"])
    assert result is not None, "get_biome_data should return a value"
    assert isinstance(result, dict), f"get_biome_data should return dict, got {type(result)}"
    assert "name" in result, "biome data should have 'name'"
    assert "ore_multiplier" in result, "biome data should have 'ore_multiplier'"


@pytest.mark.asyncio
async def test_get_biome_data_invalid_returns_normal(game):
    """get_biome_data with invalid ID should return normal biome data."""
    result = await game.call(BIOME_MANAGER_PATH, "get_biome_data", ["nonexistent_biome"])
    assert result is not None, "get_biome_data should return a value for invalid ID"
    assert isinstance(result, dict), "get_biome_data should return dict"
    # Should return normal biome as fallback
    assert result.get("name") == "Standard Mines", "Should return normal biome as fallback"


@pytest.mark.asyncio
async def test_get_biome_name(game):
    """get_biome_name should return the display name for a biome."""
    result = await game.call(BIOME_MANAGER_PATH, "get_biome_name", ["crystal_cave"])
    assert result is not None, "get_biome_name should return a value"
    assert isinstance(result, str), f"get_biome_name should return string, got {type(result)}"
    assert result == "Crystal Cavern", f"crystal_cave name should be 'Crystal Cavern', got {result}"


@pytest.mark.asyncio
async def test_get_biome_name_invalid(game):
    """get_biome_name with invalid ID should return 'Unknown'."""
    result = await game.call(BIOME_MANAGER_PATH, "get_biome_name", ["fake_biome"])
    assert result == "Unknown", f"Invalid biome name should be 'Unknown', got {result}"


# =============================================================================
# BIOME MULTIPLIER TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_ore_multiplier(game):
    """get_ore_multiplier should return a positive number."""
    result = await game.call(BIOME_MANAGER_PATH, "get_ore_multiplier")
    assert result is not None, "get_ore_multiplier should return a value"
    assert isinstance(result, (int, float)), f"get_ore_multiplier should return number, got {type(result)}"
    assert result > 0, f"ore_multiplier should be positive, got {result}"


@pytest.mark.asyncio
async def test_get_gem_multiplier(game):
    """get_gem_multiplier should return a positive number."""
    result = await game.call(BIOME_MANAGER_PATH, "get_gem_multiplier")
    assert result is not None, "get_gem_multiplier should return a value"
    assert isinstance(result, (int, float)), f"get_gem_multiplier should return number, got {type(result)}"
    assert result > 0, f"gem_multiplier should be positive, got {result}"


@pytest.mark.asyncio
async def test_get_artifact_multiplier(game):
    """get_artifact_multiplier should return a positive number."""
    result = await game.call(BIOME_MANAGER_PATH, "get_artifact_multiplier")
    assert result is not None, "get_artifact_multiplier should return a value"
    assert isinstance(result, (int, float)), f"get_artifact_multiplier should return number, got {type(result)}"
    assert result > 0, f"artifact_multiplier should be positive, got {result}"


@pytest.mark.asyncio
async def test_get_movement_multiplier(game):
    """get_movement_multiplier should return a positive number."""
    result = await game.call(BIOME_MANAGER_PATH, "get_movement_multiplier")
    assert result is not None, "get_movement_multiplier should return a value"
    assert isinstance(result, (int, float)), f"get_movement_multiplier should return number, got {type(result)}"
    assert result > 0, f"movement_multiplier should be positive, got {result}"


@pytest.mark.asyncio
async def test_get_light_bonus(game):
    """get_light_bonus should return a number (can be 0)."""
    result = await game.call(BIOME_MANAGER_PATH, "get_light_bonus")
    assert result is not None, "get_light_bonus should return a value"
    assert isinstance(result, (int, float)), f"get_light_bonus should return number, got {type(result)}"


@pytest.mark.asyncio
async def test_get_ladder_drop_bonus(game):
    """get_ladder_drop_bonus should return a positive number."""
    result = await game.call(BIOME_MANAGER_PATH, "get_ladder_drop_bonus")
    assert result is not None, "get_ladder_drop_bonus should return a value"
    assert isinstance(result, (int, float)), f"get_ladder_drop_bonus should return number, got {type(result)}"
    assert result > 0, f"ladder_drop_bonus should be positive, got {result}"


@pytest.mark.asyncio
async def test_get_equipment_drop_bonus(game):
    """get_equipment_drop_bonus should return a positive number."""
    result = await game.call(BIOME_MANAGER_PATH, "get_equipment_drop_bonus")
    assert result is not None, "get_equipment_drop_bonus should return a value"
    assert isinstance(result, (int, float)), f"get_equipment_drop_bonus should return number, got {type(result)}"
    assert result > 0, f"equipment_drop_bonus should be positive, got {result}"


# =============================================================================
# HAZARD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_hazard_returns_bool(game):
    """has_hazard should return a boolean."""
    result = await game.call(BIOME_MANAGER_PATH, "has_hazard")
    assert isinstance(result, bool), f"has_hazard should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_get_hazard_type(game):
    """get_hazard_type should return a string (may be empty)."""
    result = await game.call(BIOME_MANAGER_PATH, "get_hazard_type")
    assert result is not None or result == "", "get_hazard_type should return a value"
    assert isinstance(result, str), f"get_hazard_type should return string, got {type(result)}"


@pytest.mark.asyncio
async def test_get_hazard_damage(game):
    """get_hazard_damage should return a non-negative number."""
    result = await game.call(BIOME_MANAGER_PATH, "get_hazard_damage")
    assert result is not None, "get_hazard_damage should return a value"
    assert isinstance(result, (int, float)), f"get_hazard_damage should return number, got {type(result)}"
    assert result >= 0, f"hazard_damage should be non-negative, got {result}"


@pytest.mark.asyncio
async def test_check_hazard_trigger_returns_bool(game):
    """check_hazard_trigger should return a boolean."""
    result = await game.call(BIOME_MANAGER_PATH, "check_hazard_trigger")
    assert isinstance(result, bool), f"check_hazard_trigger should return bool, got {type(result)}"


# =============================================================================
# SURPRISE CAVE DISCOVERY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_total_surprise_count(game):
    """get_total_surprise_count should return the number of surprise biomes."""
    result = await game.call(BIOME_MANAGER_PATH, "get_total_surprise_count")
    assert result is not None, "get_total_surprise_count should return a value"
    assert isinstance(result, int), f"get_total_surprise_count should return int, got {type(result)}"
    assert result == 4, f"Should have 4 surprise biomes, got {result}"


@pytest.mark.asyncio
async def test_get_discovered_surprise_count(game):
    """get_discovered_surprise_count should return count of discovered surprise biomes."""
    result = await game.call(BIOME_MANAGER_PATH, "get_discovered_surprise_count")
    assert result is not None, "get_discovered_surprise_count should return a value"
    assert isinstance(result, int), f"get_discovered_surprise_count should return int, got {type(result)}"
    assert result >= 0, f"discovered count should be non-negative, got {result}"


@pytest.mark.asyncio
async def test_get_discovered_surprise_biomes_returns_array(game):
    """get_discovered_surprise_biomes should return an array."""
    result = await game.call(BIOME_MANAGER_PATH, "get_discovered_surprise_biomes")
    assert result is not None, "get_discovered_surprise_biomes should return a value"
    assert isinstance(result, list), f"get_discovered_surprise_biomes should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_has_discovered_biome_returns_bool(game):
    """has_discovered_biome should return a boolean."""
    result = await game.call(BIOME_MANAGER_PATH, "has_discovered_biome", ["crystal_cave"])
    assert isinstance(result, bool), f"has_discovered_biome should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_has_discovered_all_surprises_returns_bool(game):
    """has_discovered_all_surprises should return a boolean."""
    result = await game.call(BIOME_MANAGER_PATH, "has_discovered_all_surprises")
    assert isinstance(result, bool), f"has_discovered_all_surprises should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_is_in_surprise_cave_returns_bool(game):
    """is_in_surprise_cave should return a boolean."""
    result = await game.call(BIOME_MANAGER_PATH, "is_in_surprise_cave")
    assert isinstance(result, bool), f"is_in_surprise_cave should return bool, got {type(result)}"


# =============================================================================
# DISCOVERY TEXT/ICON TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_discovery_text_returns_string(game):
    """get_discovery_text should return a string (may be empty)."""
    result = await game.call(BIOME_MANAGER_PATH, "get_discovery_text")
    assert result is not None or result == "", "get_discovery_text should return a value"
    assert isinstance(result, str), f"get_discovery_text should return string, got {type(result)}"


@pytest.mark.asyncio
async def test_get_discovery_icon_returns_string(game):
    """get_discovery_icon should return a string (may be empty)."""
    result = await game.call(BIOME_MANAGER_PATH, "get_discovery_icon")
    assert result is not None or result == "", "get_discovery_icon should return a value"
    assert isinstance(result, str), f"get_discovery_icon should return string, got {type(result)}"


# =============================================================================
# BIOME GENERATION TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_current_biome_method(game):
    """get_current_biome should return the current biome ID."""
    result = await game.call(BIOME_MANAGER_PATH, "get_current_biome")
    assert result is not None, "get_current_biome should return a value"
    assert isinstance(result, str), f"get_current_biome should return string, got {type(result)}"


@pytest.mark.asyncio
async def test_get_current_biome_data_method(game):
    """get_current_biome_data should return the current biome data dict."""
    result = await game.call(BIOME_MANAGER_PATH, "get_current_biome_data")
    assert result is not None, "get_current_biome_data should return a value"
    assert isinstance(result, dict), f"get_current_biome_data should return dict, got {type(result)}"


# =============================================================================
# RESET TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_reset_completes(game):
    """reset should complete without error."""
    result = await game.call(BIOME_MANAGER_PATH, "reset")
    # Method should complete without error
    # Verify state was reset
    current_biome = await game.get_property(BIOME_MANAGER_PATH, "current_biome")
    assert current_biome == "normal", f"After reset, current_biome should be 'normal', got {current_biome}"


@pytest.mark.asyncio
async def test_clear_biome_map_completes(game):
    """clear_biome_map should complete without error."""
    result = await game.call(BIOME_MANAGER_PATH, "clear_biome_map")
    # Method should complete without error
    assert result is None or isinstance(result, (bool, dict)), "clear_biome_map should complete"


# =============================================================================
# SAVE/LOAD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_save_data_returns_dict(game):
    """get_save_data should return a dictionary."""
    result = await game.call(BIOME_MANAGER_PATH, "get_save_data")
    assert result is not None, "get_save_data should return a value"
    assert isinstance(result, dict), f"get_save_data should return dict, got {type(result)}"


@pytest.mark.asyncio
async def test_get_save_data_has_discovered_biomes(game):
    """get_save_data should include discovered_surprise_biomes."""
    result = await game.call(BIOME_MANAGER_PATH, "get_save_data")
    assert "discovered_surprise_biomes" in result, "save data should have discovered_surprise_biomes"


@pytest.mark.asyncio
async def test_get_save_data_has_biome_map(game):
    """get_save_data should include biome_map."""
    result = await game.call(BIOME_MANAGER_PATH, "get_save_data")
    assert "biome_map" in result, "save data should have biome_map"


@pytest.mark.asyncio
async def test_load_save_data_completes(game):
    """load_save_data should complete without error."""
    save_data = {"discovered_surprise_biomes": {}, "biome_map": {}}
    result = await game.call(BIOME_MANAGER_PATH, "load_save_data", [save_data])
    # Method should complete without error
    assert result is None or isinstance(result, (bool, dict)), "load_save_data should complete"


# =============================================================================
# SIGNAL TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_biome_entered_signal(game):
    """BiomeManager should have biome_entered signal."""
    has_signal = await game.call(BIOME_MANAGER_PATH, "has_signal", ["biome_entered"])
    assert has_signal is True, "BiomeManager should have biome_entered signal"


@pytest.mark.asyncio
async def test_has_biome_exited_signal(game):
    """BiomeManager should have biome_exited signal."""
    has_signal = await game.call(BIOME_MANAGER_PATH, "has_signal", ["biome_exited"])
    assert has_signal is True, "BiomeManager should have biome_exited signal"


@pytest.mark.asyncio
async def test_has_surprise_cave_discovered_signal(game):
    """BiomeManager should have surprise_cave_discovered signal."""
    has_signal = await game.call(BIOME_MANAGER_PATH, "has_signal", ["surprise_cave_discovered"])
    assert has_signal is True, "BiomeManager should have surprise_cave_discovered signal"


# =============================================================================
# BIOME CHARACTERISTICS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_rich_vein_has_high_ore_multiplier(game):
    """Rich vein biome should have ore_multiplier > 1."""
    result = await game.call(BIOME_MANAGER_PATH, "get_biome_data", ["rich_vein"])
    assert result.get("ore_multiplier", 1.0) > 1.0, "rich_vein should have ore_multiplier > 1"


@pytest.mark.asyncio
async def test_crystal_cave_has_gem_multiplier(game):
    """Crystal cave biome should have gem_multiplier > 1."""
    result = await game.call(BIOME_MANAGER_PATH, "get_biome_data", ["crystal_cave"])
    assert result.get("gem_multiplier", 1.0) > 1.0, "crystal_cave should have gem_multiplier > 1"


@pytest.mark.asyncio
async def test_lava_pocket_has_hazard(game):
    """Lava pocket biome should have hazard_chance > 0."""
    result = await game.call(BIOME_MANAGER_PATH, "get_biome_data", ["lava_pocket"])
    assert result.get("hazard_chance", 0.0) > 0.0, "lava_pocket should have hazard_chance > 0"


@pytest.mark.asyncio
async def test_lava_pocket_hazard_type_is_heat(game):
    """Lava pocket biome should have hazard_type 'heat'."""
    result = await game.call(BIOME_MANAGER_PATH, "get_biome_data", ["lava_pocket"])
    assert result.get("hazard_type") == "heat", "lava_pocket hazard_type should be 'heat'"


@pytest.mark.asyncio
async def test_mushroom_grotto_is_surprise(game):
    """Mushroom grotto biome should be marked as surprise."""
    result = await game.call(BIOME_MANAGER_PATH, "get_biome_data", ["mushroom_grotto"])
    assert result.get("is_surprise") is True, "mushroom_grotto should be a surprise biome"


@pytest.mark.asyncio
async def test_normal_biome_is_not_surprise(game):
    """Normal biome should not be marked as surprise."""
    result = await game.call(BIOME_MANAGER_PATH, "get_biome_data", ["normal"])
    assert result.get("is_surprise") is False, "normal biome should not be a surprise biome"
