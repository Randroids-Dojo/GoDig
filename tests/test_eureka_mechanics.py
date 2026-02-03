"""
EurekaMechanicManager tests for GoDig endless digging game.

Tests verify that EurekaMechanicManager:
1. Exists as an autoload singleton
2. Manages layer-specific eureka mechanics
3. Tracks first-discovery of mechanics
4. Handles crumbling blocks, pressure cracks, crystal resonance
5. Persists discovered mechanics via save/load
6. Has all required signals

Reference: Based on The Witness, Bonfire Peaks, and puzzle game research -
each depth layer introduces subtle mechanic twists that create 'aha' moments.
"""
import pytest
from helpers import PATHS


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_eureka_mechanic_manager_exists(game):
    """EurekaMechanicManager autoload should exist."""
    result = await game.node_exists(PATHS["eureka_mechanic_manager"])
    assert result.get("exists") is True, "EurekaMechanicManager autoload should exist"


# =============================================================================
# INITIAL STATE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_initial_no_discovered_mechanics(game):
    """EurekaMechanicManager should have no discovered mechanics initially."""
    # Reset to ensure clean state
    await game.call(PATHS["eureka_mechanic_manager"], "reset")

    stats = await game.call(PATHS["eureka_mechanic_manager"], "get_stats")
    assert stats is not None, "get_stats should return a value"
    assert stats.get("discovered_count", -1) == 0, "Should have no discovered mechanics initially"


@pytest.mark.asyncio
async def test_initial_no_active_crumbling(game):
    """EurekaMechanicManager should have no active crumbling blocks initially."""
    # Reset to ensure clean state
    await game.call(PATHS["eureka_mechanic_manager"], "reset")

    stats = await game.call(PATHS["eureka_mechanic_manager"], "get_stats")
    assert stats.get("active_crumbling", -1) == 0, "Should have no active crumbling blocks initially"


@pytest.mark.asyncio
async def test_initial_no_active_loose(game):
    """EurekaMechanicManager should have no active loose blocks initially."""
    # Reset to ensure clean state
    await game.call(PATHS["eureka_mechanic_manager"], "reset")

    stats = await game.call(PATHS["eureka_mechanic_manager"], "get_stats")
    assert stats.get("active_loose", -1) == 0, "Should have no active loose blocks initially"


@pytest.mark.asyncio
async def test_initial_void_sight_inactive(game):
    """EurekaMechanicManager should have void sight inactive initially."""
    # Reset to ensure clean state
    await game.call(PATHS["eureka_mechanic_manager"], "reset")

    stats = await game.call(PATHS["eureka_mechanic_manager"], "get_stats")
    assert stats.get("void_sight_active", True) is False, "Void sight should be inactive initially"


# =============================================================================
# MECHANIC DISCOVERY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_discovered_mechanic_returns_false_initially(game):
    """has_discovered_mechanic should return false for any layer initially."""
    # Reset to ensure clean state
    await game.call(PATHS["eureka_mechanic_manager"], "reset")

    # Check for any layer
    result = await game.call(PATHS["eureka_mechanic_manager"], "has_discovered_mechanic", ["topsoil"])
    assert result is False, "Should not have discovered topsoil mechanic initially"


@pytest.mark.asyncio
async def test_get_discovered_mechanics_empty_initially(game):
    """get_discovered_mechanics should return empty array initially."""
    # Reset to ensure clean state
    await game.call(PATHS["eureka_mechanic_manager"], "reset")

    result = await game.call(PATHS["eureka_mechanic_manager"], "get_discovered_mechanics")
    assert result is not None, "get_discovered_mechanics should return a value"
    assert len(result) == 0, f"Should have no discovered mechanics, got {len(result)}"


# =============================================================================
# RESET TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_reset_clears_discovered_mechanics(game):
    """reset() should clear discovered mechanics."""
    await game.call(PATHS["eureka_mechanic_manager"], "reset")

    stats = await game.call(PATHS["eureka_mechanic_manager"], "get_stats")
    assert stats.get("discovered_count") == 0, "Discovered count should be 0 after reset"


@pytest.mark.asyncio
async def test_reset_clears_crumbling_blocks(game):
    """reset() should clear active crumbling blocks."""
    await game.call(PATHS["eureka_mechanic_manager"], "reset")

    stats = await game.call(PATHS["eureka_mechanic_manager"], "get_stats")
    assert stats.get("active_crumbling") == 0, "Active crumbling should be 0 after reset"


@pytest.mark.asyncio
async def test_reset_clears_loose_blocks(game):
    """reset() should clear active loose blocks."""
    await game.call(PATHS["eureka_mechanic_manager"], "reset")

    stats = await game.call(PATHS["eureka_mechanic_manager"], "get_stats")
    assert stats.get("active_loose") == 0, "Active loose should be 0 after reset"


@pytest.mark.asyncio
async def test_reset_clears_void_sight(game):
    """reset() should clear void sight timer."""
    await game.call(PATHS["eureka_mechanic_manager"], "reset")

    stats = await game.call(PATHS["eureka_mechanic_manager"], "get_stats")
    assert stats.get("void_sight_active") is False, "Void sight should be inactive after reset"


# =============================================================================
# SAVE/LOAD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_save_data_returns_dict(game):
    """get_save_data should return dictionary."""
    data = await game.call(PATHS["eureka_mechanic_manager"], "get_save_data")
    assert data is not None, "get_save_data should return a value"
    assert isinstance(data, dict), f"get_save_data should return dict, got {type(data)}"


@pytest.mark.asyncio
async def test_get_save_data_has_discovered_mechanics(game):
    """get_save_data should include discovered_mechanics."""
    data = await game.call(PATHS["eureka_mechanic_manager"], "get_save_data")
    assert "discovered_mechanics" in data, "Save data should include discovered_mechanics"


@pytest.mark.asyncio
async def test_load_save_data_restores_discovered(game):
    """load_save_data should restore discovered mechanics."""
    # Reset first
    await game.call(PATHS["eureka_mechanic_manager"], "reset")

    # Load with some discovered mechanics
    test_data = {
        "discovered_mechanics": {
            "topsoil": True,
            "clay": True,
            "stone": True,
        }
    }
    await game.call(PATHS["eureka_mechanic_manager"], "load_save_data", [test_data])

    # Verify by getting save data back
    data = await game.call(PATHS["eureka_mechanic_manager"], "get_save_data")
    discovered = data.get("discovered_mechanics", {})
    assert len(discovered) == 3, f"Should have 3 discovered mechanics, got {len(discovered)}"


@pytest.mark.asyncio
async def test_load_save_data_updates_stats(game):
    """load_save_data should update stats with loaded count."""
    # Reset first
    await game.call(PATHS["eureka_mechanic_manager"], "reset")

    # Load with discovered mechanics
    test_data = {
        "discovered_mechanics": {
            "subsoil": True,
            "granite": True,
        }
    }
    await game.call(PATHS["eureka_mechanic_manager"], "load_save_data", [test_data])

    # Check stats
    stats = await game.call(PATHS["eureka_mechanic_manager"], "get_stats")
    assert stats.get("discovered_count") == 2, f"Discovered count should be 2, got {stats.get('discovered_count')}"


@pytest.mark.asyncio
async def test_load_save_data_makes_has_discovered_return_true(game):
    """After load, has_discovered_mechanic should return true for loaded mechanics."""
    # Reset first
    await game.call(PATHS["eureka_mechanic_manager"], "reset")

    # Load with a discovered mechanic
    test_data = {
        "discovered_mechanics": {
            "crystal_caves": True,
        }
    }
    await game.call(PATHS["eureka_mechanic_manager"], "load_save_data", [test_data])

    # Check
    result = await game.call(PATHS["eureka_mechanic_manager"], "has_discovered_mechanic", ["crystal_caves"])
    assert result is True, "Should have discovered crystal_caves after load"


# =============================================================================
# SIGNAL EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_eureka_discovered_signal(game):
    """EurekaMechanicManager should have eureka_discovered signal."""
    has_signal = await game.call(PATHS["eureka_mechanic_manager"], "has_signal", ["eureka_discovered"])
    assert has_signal is True, "EurekaMechanicManager should have eureka_discovered signal"


@pytest.mark.asyncio
async def test_has_crumbling_block_started_signal(game):
    """EurekaMechanicManager should have crumbling_block_started signal."""
    has_signal = await game.call(PATHS["eureka_mechanic_manager"], "has_signal", ["crumbling_block_started"])
    assert has_signal is True, "EurekaMechanicManager should have crumbling_block_started signal"


@pytest.mark.asyncio
async def test_has_crumbling_block_fell_signal(game):
    """EurekaMechanicManager should have crumbling_block_fell signal."""
    has_signal = await game.call(PATHS["eureka_mechanic_manager"], "has_signal", ["crumbling_block_fell"])
    assert has_signal is True, "EurekaMechanicManager should have crumbling_block_fell signal"


@pytest.mark.asyncio
async def test_has_pressure_crack_triggered_signal(game):
    """EurekaMechanicManager should have pressure_crack_triggered signal."""
    has_signal = await game.call(PATHS["eureka_mechanic_manager"], "has_signal", ["pressure_crack_triggered"])
    assert has_signal is True, "EurekaMechanicManager should have pressure_crack_triggered signal"


@pytest.mark.asyncio
async def test_has_crystal_resonance_triggered_signal(game):
    """EurekaMechanicManager should have crystal_resonance_triggered signal."""
    has_signal = await game.call(PATHS["eureka_mechanic_manager"], "has_signal", ["crystal_resonance_triggered"])
    assert has_signal is True, "EurekaMechanicManager should have crystal_resonance_triggered signal"


@pytest.mark.asyncio
async def test_has_loose_block_fell_signal(game):
    """EurekaMechanicManager should have loose_block_fell signal."""
    has_signal = await game.call(PATHS["eureka_mechanic_manager"], "has_signal", ["loose_block_fell"])
    assert has_signal is True, "EurekaMechanicManager should have loose_block_fell signal"


@pytest.mark.asyncio
async def test_has_void_sight_activated_signal(game):
    """EurekaMechanicManager should have void_sight_activated signal."""
    has_signal = await game.call(PATHS["eureka_mechanic_manager"], "has_signal", ["void_sight_activated"])
    assert has_signal is True, "EurekaMechanicManager should have void_sight_activated signal"


@pytest.mark.asyncio
async def test_has_reality_tear_jackpot_signal(game):
    """EurekaMechanicManager should have reality_tear_jackpot signal."""
    has_signal = await game.call(PATHS["eureka_mechanic_manager"], "has_signal", ["reality_tear_jackpot"])
    assert has_signal is True, "EurekaMechanicManager should have reality_tear_jackpot signal"


# =============================================================================
# CONSTANTS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_void_sight_duration_constant(game):
    """VOID_SIGHT_DURATION constant should be configured."""
    result = await game.get_property(PATHS["eureka_mechanic_manager"], "VOID_SIGHT_DURATION")
    assert result is not None, "VOID_SIGHT_DURATION should exist"
    assert result == 2.0, f"VOID_SIGHT_DURATION should be 2.0, got {result}"


# =============================================================================
# GET STATS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_stats_returns_dict(game):
    """get_stats should return dictionary."""
    stats = await game.call(PATHS["eureka_mechanic_manager"], "get_stats")
    assert stats is not None, "get_stats should return a value"
    assert isinstance(stats, dict), f"get_stats should return dict, got {type(stats)}"


@pytest.mark.asyncio
async def test_get_stats_has_required_fields(game):
    """get_stats should include all required fields."""
    stats = await game.call(PATHS["eureka_mechanic_manager"], "get_stats")

    required_fields = [
        "discovered_count",
        "active_crumbling",
        "active_loose",
        "void_sight_active",
    ]

    for field in required_fields:
        assert field in stats, f"Stats should include '{field}'"


# =============================================================================
# METHOD EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_check_eureka_trigger_exists(game):
    """check_eureka_trigger method should exist."""
    # Reset first to ensure clean state
    await game.call(PATHS["eureka_mechanic_manager"], "reset")

    # Call with null layer (should handle gracefully)
    # Method takes grid_pos (Vector2i) and layer (Resource), but with null layer it should just return
    await game.call(PATHS["eureka_mechanic_manager"], "check_eureka_trigger", [
        {"x": 5, "y": 10, "_type": "Vector2i"},
        None  # Null layer should be handled gracefully
    ])
    # If we get here without error, method exists and handles null gracefully


@pytest.mark.asyncio
async def test_on_block_destroyed_exists(game):
    """on_block_destroyed method should exist."""
    # Reset first
    await game.call(PATHS["eureka_mechanic_manager"], "reset")

    # Call with grid position and depth
    await game.call(PATHS["eureka_mechanic_manager"], "on_block_destroyed", [
        {"x": 5, "y": 10, "_type": "Vector2i"},
        100  # depth
    ])
    # If we get here without error, method exists


# =============================================================================
# MECHANIC DESCRIPTIONS
# =============================================================================

@pytest.mark.asyncio
async def test_discovered_mechanics_is_persisted_array(game):
    """Discovered mechanics should be persistable as array of layer IDs."""
    # Reset and load test data
    await game.call(PATHS["eureka_mechanic_manager"], "reset")

    test_data = {
        "discovered_mechanics": {
            "topsoil": True,
            "clay": True,
        }
    }
    await game.call(PATHS["eureka_mechanic_manager"], "load_save_data", [test_data])

    # Get the array of discovered mechanics
    result = await game.call(PATHS["eureka_mechanic_manager"], "get_discovered_mechanics")
    assert isinstance(result, list), f"get_discovered_mechanics should return array, got {type(result)}"
    assert len(result) == 2, f"Should have 2 discovered mechanics, got {len(result)}"
    assert "topsoil" in result, "Should include 'topsoil'"
    assert "clay" in result, "Should include 'clay'"
