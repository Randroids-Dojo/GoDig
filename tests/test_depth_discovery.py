"""
DepthDiscoveryManager tests for GoDig endless digging game.

Tests verify that DepthDiscoveryManager:
1. Exists as an autoload singleton
2. Triggers depth-based discoveries correctly
3. Manages eureka reward unlocking
4. Tracks first-discovery bonuses
5. Persists state via save/load
6. Has all required signals and constants

Reference: Session 26 research on Mr. Mine - each depth layer introduces
discoverable surprises (caves, abandoned equipment, rare ore veins).
"""
import pytest
from helpers import PATHS


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_depth_discovery_manager_exists(game):
    """DepthDiscoveryManager autoload should exist."""
    result = await game.node_exists(PATHS["depth_discovery_manager"])
    assert result.get("exists") is True, "DepthDiscoveryManager autoload should exist"


# =============================================================================
# INITIAL STATE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_initial_no_active_discoveries(game):
    """DepthDiscoveryManager should have no active discoveries initially."""
    # Reset to ensure clean state
    await game.call(PATHS["depth_discovery_manager"], "reset")

    stats = await game.call(PATHS["depth_discovery_manager"], "get_stats")
    assert stats is not None, "get_stats should return a value"
    assert stats.get("active_discoveries", -1) == 0, "Should have no active discoveries initially"


@pytest.mark.asyncio
async def test_initial_zero_discovered_count(game):
    """DepthDiscoveryManager should have zero discovered count initially."""
    # Reset to ensure clean state
    await game.call(PATHS["depth_discovery_manager"], "reset")

    stats = await game.call(PATHS["depth_discovery_manager"], "get_stats")
    assert stats.get("discovered_count", -1) == 0, "Should have zero discovered count initially"


@pytest.mark.asyncio
async def test_initial_zero_collected_total(game):
    """DepthDiscoveryManager should have zero collected total initially."""
    # Reset to ensure clean state
    await game.call(PATHS["depth_discovery_manager"], "reset")

    stats = await game.call(PATHS["depth_discovery_manager"], "get_stats")
    assert stats.get("collected_total", -1) == 0, "Should have zero collected total initially"


@pytest.mark.asyncio
async def test_initial_zero_hint_cooldown(game):
    """DepthDiscoveryManager should have zero hint cooldown initially."""
    # Reset to ensure clean state
    await game.call(PATHS["depth_discovery_manager"], "reset")

    stats = await game.call(PATHS["depth_discovery_manager"], "get_stats")
    assert stats.get("hint_cooldown", -1) == 0.0, "Should have zero hint cooldown initially"


# =============================================================================
# DISCOVERY TABLE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_discovery_tables_constant_exists(game):
    """DISCOVERY_TABLES constant should exist."""
    result = await game.get_property(PATHS["depth_discovery_manager"], "DISCOVERY_TABLES")
    assert result is not None, "DISCOVERY_TABLES should exist"
    assert isinstance(result, dict), f"DISCOVERY_TABLES should be dict, got {type(result)}"


@pytest.mark.asyncio
async def test_discovery_tables_has_shallow(game):
    """DISCOVERY_TABLES should have shallow tier (0-50m)."""
    result = await game.get_property(PATHS["depth_discovery_manager"], "DISCOVERY_TABLES")
    assert "shallow" in result, "DISCOVERY_TABLES should have 'shallow' tier"
    shallow = result["shallow"]
    assert shallow.get("min_depth") == 0, "Shallow min_depth should be 0"
    assert shallow.get("max_depth") == 50, "Shallow max_depth should be 50"


@pytest.mark.asyncio
async def test_discovery_tables_has_mid_shallow(game):
    """DISCOVERY_TABLES should have mid_shallow tier (50-150m)."""
    result = await game.get_property(PATHS["depth_discovery_manager"], "DISCOVERY_TABLES")
    assert "mid_shallow" in result, "DISCOVERY_TABLES should have 'mid_shallow' tier"
    mid = result["mid_shallow"]
    assert mid.get("min_depth") == 50, "Mid_shallow min_depth should be 50"
    assert mid.get("max_depth") == 150, "Mid_shallow max_depth should be 150"


@pytest.mark.asyncio
async def test_discovery_tables_has_medium(game):
    """DISCOVERY_TABLES should have medium tier (150-300m)."""
    result = await game.get_property(PATHS["depth_discovery_manager"], "DISCOVERY_TABLES")
    assert "medium" in result, "DISCOVERY_TABLES should have 'medium' tier"


@pytest.mark.asyncio
async def test_discovery_tables_has_deep(game):
    """DISCOVERY_TABLES should have deep tier (300-500m)."""
    result = await game.get_property(PATHS["depth_discovery_manager"], "DISCOVERY_TABLES")
    assert "deep" in result, "DISCOVERY_TABLES should have 'deep' tier"


@pytest.mark.asyncio
async def test_discovery_tables_has_abyssal(game):
    """DISCOVERY_TABLES should have abyssal tier (500m+)."""
    result = await game.get_property(PATHS["depth_discovery_manager"], "DISCOVERY_TABLES")
    assert "abyssal" in result, "DISCOVERY_TABLES should have 'abyssal' tier"


@pytest.mark.asyncio
async def test_discovery_chance_increases_with_depth(game):
    """Discovery chance should increase with depth (more rewards for risk)."""
    result = await game.get_property(PATHS["depth_discovery_manager"], "DISCOVERY_TABLES")

    shallow_chance = result.get("shallow", {}).get("chance_per_chunk", 0)
    deep_chance = result.get("deep", {}).get("chance_per_chunk", 0)
    abyssal_chance = result.get("abyssal", {}).get("chance_per_chunk", 0)

    assert deep_chance > shallow_chance, \
        f"Deep chance ({deep_chance}) should be > shallow ({shallow_chance})"
    assert abyssal_chance > deep_chance, \
        f"Abyssal chance ({abyssal_chance}) should be > deep ({deep_chance})"


# =============================================================================
# DISCOVERY TYPE ENUM TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_discovery_type_enum_exists(game):
    """DiscoveryType enum should be accessible."""
    # Check that the class has the enum defined
    result = await game.get_property(PATHS["depth_discovery_manager"], "DiscoveryType")
    # In GDScript, enums are dictionaries
    assert result is not None, "DiscoveryType should exist"


# =============================================================================
# POSITION QUERY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_discovery_at_returns_false_when_empty(game):
    """has_discovery_at should return false when no discoveries exist."""
    # Reset to ensure clean state
    await game.call(PATHS["depth_discovery_manager"], "reset")

    # Check random position
    result = await game.call(PATHS["depth_discovery_manager"], "has_discovery_at", [{"x": 50, "y": 100, "_type": "Vector2i"}])
    assert result is False, "Should return false when no discoveries at position"


@pytest.mark.asyncio
async def test_get_discovery_at_returns_empty_when_none(game):
    """get_discovery_at should return empty dict when no discovery exists."""
    # Reset to ensure clean state
    await game.call(PATHS["depth_discovery_manager"], "reset")

    # Check random position
    result = await game.call(PATHS["depth_discovery_manager"], "get_discovery_at", [{"x": 50, "y": 100, "_type": "Vector2i"}])
    assert result is not None, "get_discovery_at should return a value"
    assert isinstance(result, dict), f"get_discovery_at should return dict, got {type(result)}"
    assert len(result) == 0, "Should return empty dict when no discovery"


# =============================================================================
# RESET TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_reset_clears_active_discoveries(game):
    """reset() should clear active discoveries."""
    await game.call(PATHS["depth_discovery_manager"], "reset")

    stats = await game.call(PATHS["depth_discovery_manager"], "get_stats")
    assert stats.get("active_discoveries") == 0, "Active discoveries should be 0 after reset"


@pytest.mark.asyncio
async def test_reset_clears_collected_discoveries(game):
    """reset() should clear collected discoveries."""
    await game.call(PATHS["depth_discovery_manager"], "reset")

    stats = await game.call(PATHS["depth_discovery_manager"], "get_stats")
    assert stats.get("collected_total") == 0, "Collected total should be 0 after reset"


@pytest.mark.asyncio
async def test_reset_clears_hint_cooldown(game):
    """reset() should clear hint cooldown."""
    await game.call(PATHS["depth_discovery_manager"], "reset")

    stats = await game.call(PATHS["depth_discovery_manager"], "get_stats")
    assert stats.get("hint_cooldown") == 0.0, "Hint cooldown should be 0 after reset"


# =============================================================================
# SAVE/LOAD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_save_data_returns_dict(game):
    """get_save_data should return dictionary."""
    data = await game.call(PATHS["depth_discovery_manager"], "get_save_data")
    assert data is not None, "get_save_data should return a value"
    assert isinstance(data, dict), f"get_save_data should return dict, got {type(data)}"


@pytest.mark.asyncio
async def test_get_save_data_has_collected_discoveries(game):
    """get_save_data should include collected_discoveries."""
    data = await game.call(PATHS["depth_discovery_manager"], "get_save_data")
    assert "collected_discoveries" in data, "Save data should include collected_discoveries"


@pytest.mark.asyncio
async def test_load_save_data_restores_collected(game):
    """load_save_data should restore collected discoveries."""
    # Reset first
    await game.call(PATHS["depth_discovery_manager"], "reset")

    # Load with some collected discoveries
    test_data = {
        "collected_discoveries": {
            "10,20": True,
            "50,100": True,
            "0,75": True,
        }
    }
    await game.call(PATHS["depth_discovery_manager"], "load_save_data", [test_data])

    # Verify by getting save data back
    data = await game.call(PATHS["depth_discovery_manager"], "get_save_data")
    collected = data.get("collected_discoveries", {})
    assert len(collected) == 3, f"Should have 3 collected discoveries, got {len(collected)}"


@pytest.mark.asyncio
async def test_load_save_data_updates_stats(game):
    """load_save_data should update stats with loaded count."""
    # Reset first
    await game.call(PATHS["depth_discovery_manager"], "reset")

    # Load with some collected discoveries
    test_data = {
        "collected_discoveries": {
            "5,10": True,
            "15,30": True,
        }
    }
    await game.call(PATHS["depth_discovery_manager"], "load_save_data", [test_data])

    # Check stats
    stats = await game.call(PATHS["depth_discovery_manager"], "get_stats")
    assert stats.get("collected_total") == 2, f"Collected total should be 2, got {stats.get('collected_total')}"


# =============================================================================
# SIGNAL EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_discovery_found_signal(game):
    """DepthDiscoveryManager should have discovery_found signal."""
    has_signal = await game.call(PATHS["depth_discovery_manager"], "has_signal", ["discovery_found"])
    assert has_signal is True, "DepthDiscoveryManager should have discovery_found signal"


@pytest.mark.asyncio
async def test_has_discovery_loot_collected_signal(game):
    """DepthDiscoveryManager should have discovery_loot_collected signal."""
    has_signal = await game.call(PATHS["depth_discovery_manager"], "has_signal", ["discovery_loot_collected"])
    assert has_signal is True, "DepthDiscoveryManager should have discovery_loot_collected signal"


@pytest.mark.asyncio
async def test_has_discovery_hint_revealed_signal(game):
    """DepthDiscoveryManager should have discovery_hint_revealed signal."""
    has_signal = await game.call(PATHS["depth_discovery_manager"], "has_signal", ["discovery_hint_revealed"])
    assert has_signal is True, "DepthDiscoveryManager should have discovery_hint_revealed signal"


@pytest.mark.asyncio
async def test_has_rare_vein_discovered_signal(game):
    """DepthDiscoveryManager should have rare_vein_discovered signal."""
    has_signal = await game.call(PATHS["depth_discovery_manager"], "has_signal", ["rare_vein_discovered"])
    assert has_signal is True, "DepthDiscoveryManager should have rare_vein_discovered signal"


@pytest.mark.asyncio
async def test_has_mysterious_cave_entered_signal(game):
    """DepthDiscoveryManager should have mysterious_cave_entered signal."""
    has_signal = await game.call(PATHS["depth_discovery_manager"], "has_signal", ["mysterious_cave_entered"])
    assert has_signal is True, "DepthDiscoveryManager should have mysterious_cave_entered signal"


@pytest.mark.asyncio
async def test_has_abandoned_equipment_found_signal(game):
    """DepthDiscoveryManager should have abandoned_equipment_found signal."""
    has_signal = await game.call(PATHS["depth_discovery_manager"], "has_signal", ["abandoned_equipment_found"])
    assert has_signal is True, "DepthDiscoveryManager should have abandoned_equipment_found signal"


# =============================================================================
# CONSTANTS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_chunk_size_constant(game):
    """CHUNK_SIZE constant should be configured."""
    result = await game.get_property(PATHS["depth_discovery_manager"], "CHUNK_SIZE")
    assert result is not None, "CHUNK_SIZE should exist"
    assert result == 16, f"CHUNK_SIZE should be 16, got {result}"


@pytest.mark.asyncio
async def test_min_discovery_distance_constant(game):
    """MIN_DISCOVERY_DISTANCE constant should be configured."""
    result = await game.get_property(PATHS["depth_discovery_manager"], "MIN_DISCOVERY_DISTANCE")
    assert result is not None, "MIN_DISCOVERY_DISTANCE should exist"
    assert result == 32, f"MIN_DISCOVERY_DISTANCE should be 32, got {result}"


@pytest.mark.asyncio
async def test_hint_cooldown_time_constant(game):
    """HINT_COOLDOWN_TIME constant should be configured."""
    result = await game.get_property(PATHS["depth_discovery_manager"], "HINT_COOLDOWN_TIME")
    assert result is not None, "HINT_COOLDOWN_TIME should exist"
    assert result == 30.0, f"HINT_COOLDOWN_TIME should be 30.0, got {result}"


# =============================================================================
# GET STATS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_stats_returns_dict(game):
    """get_stats should return dictionary."""
    stats = await game.call(PATHS["depth_discovery_manager"], "get_stats")
    assert stats is not None, "get_stats should return a value"
    assert isinstance(stats, dict), f"get_stats should return dict, got {type(stats)}"


@pytest.mark.asyncio
async def test_get_stats_has_required_fields(game):
    """get_stats should include all required fields."""
    stats = await game.call(PATHS["depth_discovery_manager"], "get_stats")

    required_fields = [
        "active_discoveries",
        "discovered_count",
        "collected_total",
        "hint_cooldown",
    ]

    for field in required_fields:
        assert field in stats, f"Stats should include '{field}'"


# =============================================================================
# METHOD EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_generate_discoveries_for_chunk_exists(game):
    """generate_discoveries_for_chunk method should exist."""
    # Just call it with safe params to verify it exists and doesn't crash
    # Using a chunk far from player to avoid side effects
    await game.call(PATHS["depth_discovery_manager"], "generate_discoveries_for_chunk", [
        {"x": 100, "y": 100, "_type": "Vector2i"},
        12345
    ])
    # If we get here without error, method exists


@pytest.mark.asyncio
async def test_check_for_discoveries_exists(game):
    """check_for_discoveries method should exist."""
    # Reset first to ensure clean state
    await game.call(PATHS["depth_discovery_manager"], "reset")

    # Call with a position - method is void so just verify no error
    await game.call(PATHS["depth_discovery_manager"], "check_for_discoveries", [
        {"x": 0, "y": 10, "_type": "Vector2i"}
    ])
    # If we get here without error, method exists


# =============================================================================
# DEPTH TABLE SELECTION TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_discovery_table_shallow(game):
    """_get_discovery_table should return shallow for depth 0-49."""
    result = await game.call(PATHS["depth_discovery_manager"], "_get_discovery_table", [25])
    assert result is not None, "_get_discovery_table should return a value"
    assert isinstance(result, dict), f"Should return dict, got {type(result)}"
    assert result.get("min_depth") == 0, "Should return shallow table for depth 25"
    assert result.get("max_depth") == 50, "Should return shallow table for depth 25"


@pytest.mark.asyncio
async def test_get_discovery_table_mid_shallow(game):
    """_get_discovery_table should return mid_shallow for depth 50-149."""
    result = await game.call(PATHS["depth_discovery_manager"], "_get_discovery_table", [100])
    assert result is not None, "_get_discovery_table should return a value"
    assert result.get("min_depth") == 50, "Should return mid_shallow table for depth 100"
    assert result.get("max_depth") == 150, "Should return mid_shallow table for depth 100"


@pytest.mark.asyncio
async def test_get_discovery_table_medium(game):
    """_get_discovery_table should return medium for depth 150-299."""
    result = await game.call(PATHS["depth_discovery_manager"], "_get_discovery_table", [200])
    assert result is not None, "_get_discovery_table should return a value"
    assert result.get("min_depth") == 150, "Should return medium table for depth 200"
    assert result.get("max_depth") == 300, "Should return medium table for depth 200"


@pytest.mark.asyncio
async def test_get_discovery_table_deep(game):
    """_get_discovery_table should return deep for depth 300-499."""
    result = await game.call(PATHS["depth_discovery_manager"], "_get_discovery_table", [400])
    assert result is not None, "_get_discovery_table should return a value"
    assert result.get("min_depth") == 300, "Should return deep table for depth 400"
    assert result.get("max_depth") == 500, "Should return deep table for depth 400"


@pytest.mark.asyncio
async def test_get_discovery_table_abyssal(game):
    """_get_discovery_table should return abyssal for depth 500+."""
    result = await game.call(PATHS["depth_discovery_manager"], "_get_discovery_table", [600])
    assert result is not None, "_get_discovery_table should return a value"
    assert result.get("min_depth") == 500, "Should return abyssal table for depth 600"
