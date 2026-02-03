"""
FrustrationTracker tests for GoDig endless digging game.

Tests verify that FrustrationTracker:
1. Exists as an autoload singleton
2. Has all required frustration types
3. Records frustrations correctly
4. Maps frustrations to upgrade recommendations
5. Has all required signals
"""
import pytest
from helpers import PATHS


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_frustration_tracker_exists(game):
    """FrustrationTracker autoload should exist."""
    result = await game.node_exists(PATHS["frustration_tracker"])
    assert result.get("exists") is True, "FrustrationTracker autoload should exist"


# =============================================================================
# INITIAL STATE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_initial_no_recommended_upgrade(game):
    """FrustrationTracker should have no recommendation initially."""
    # Reset to ensure clean state
    await game.call(PATHS["frustration_tracker"], "reset")

    upgrade = await game.call(PATHS["frustration_tracker"], "get_recommended_upgrade")
    assert upgrade == "", f"Should have no recommended upgrade initially, got '{upgrade}'"


@pytest.mark.asyncio
async def test_initial_no_frustration_description(game):
    """FrustrationTracker should have no frustration description initially."""
    # Reset to ensure clean state
    await game.call(PATHS["frustration_tracker"], "reset")

    description = await game.call(PATHS["frustration_tracker"], "get_frustration_description")
    assert description == "", f"Should have no description initially, got '{description}'"


@pytest.mark.asyncio
async def test_initial_empty_recent_frustrations(game):
    """FrustrationTracker should have no recent frustrations initially."""
    # Reset to ensure clean state
    await game.call(PATHS["frustration_tracker"], "reset")

    frustrations = await game.call(PATHS["frustration_tracker"], "get_all_recent_frustrations")
    assert frustrations is not None, "get_all_recent_frustrations should return a value"
    assert len(frustrations) == 0, f"Should have no recent frustrations, got {len(frustrations)}"


# =============================================================================
# FRUSTRATION RECORDING TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_record_death_fall(game):
    """record_death with 'fall' cause should record DEATH_FALL frustration."""
    # Reset to ensure clean state
    await game.call(PATHS["frustration_tracker"], "reset")

    # Record a fall death
    await game.call(PATHS["frustration_tracker"], "record_death", ["fall", 50])

    # Check recommended upgrade (DEATH_FALL -> boots)
    upgrade = await game.call(PATHS["frustration_tracker"], "get_recommended_upgrade")
    assert upgrade == "boots", f"Fall death should recommend boots, got '{upgrade}'"


@pytest.mark.asyncio
async def test_record_death_other(game):
    """record_death with non-fall cause should record DEATH_OTHER frustration."""
    # Reset to ensure clean state
    await game.call(PATHS["frustration_tracker"], "reset")

    # Record a non-fall death
    await game.call(PATHS["frustration_tracker"], "record_death", ["enemy", 75])

    # Check recommended upgrade (DEATH_OTHER -> helmet)
    upgrade = await game.call(PATHS["frustration_tracker"], "get_recommended_upgrade")
    assert upgrade == "helmet", f"Other death should recommend helmet, got '{upgrade}'"


@pytest.mark.asyncio
async def test_record_hard_block(game):
    """record_hard_block should record HARD_BLOCK frustration."""
    # Reset to ensure clean state
    await game.call(PATHS["frustration_tracker"], "reset")

    # Record hard block frustration (block tier 3, tool tier 1)
    await game.call(PATHS["frustration_tracker"], "record_hard_block", [3, 1])

    # Check recommended upgrade (HARD_BLOCK -> pickaxe)
    upgrade = await game.call(PATHS["frustration_tracker"], "get_recommended_upgrade")
    assert upgrade == "pickaxe", f"Hard block should recommend pickaxe, got '{upgrade}'"


@pytest.mark.asyncio
async def test_record_ladder_shortage(game):
    """record_ladder_shortage should record LADDER_SHORTAGE frustration."""
    # Reset to ensure clean state
    await game.call(PATHS["frustration_tracker"], "reset")

    # Record ladder shortage
    await game.call(PATHS["frustration_tracker"], "record_ladder_shortage", [80, 5])

    # Check recommended upgrade (LADDER_SHORTAGE -> supplies)
    upgrade = await game.call(PATHS["frustration_tracker"], "get_recommended_upgrade")
    assert upgrade == "supplies", f"Ladder shortage should recommend supplies, got '{upgrade}'"


# =============================================================================
# FRUSTRATION COUNT TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_frustration_count_increments(game):
    """Recording same frustration multiple times should increment count."""
    # Reset to ensure clean state
    await game.call(PATHS["frustration_tracker"], "reset")

    # Record hard block twice
    await game.call(PATHS["frustration_tracker"], "record_hard_block", [2, 1])
    await game.call(PATHS["frustration_tracker"], "record_hard_block", [3, 1])

    # Get frustration count (HARD_BLOCK = 4 in enum)
    count = await game.call(PATHS["frustration_tracker"], "get_frustration_count", [4])
    assert count == 2, f"Should have count 2 for hard block, got {count}"


# =============================================================================
# FRUSTRATION PRIORITY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_most_recent_frustration_takes_priority(game):
    """Most recently recorded frustration should be the current one."""
    # Reset to ensure clean state
    await game.call(PATHS["frustration_tracker"], "reset")

    # Record fall death first
    await game.call(PATHS["frustration_tracker"], "record_death", ["fall", 30])

    # Then record ladder shortage
    await game.call(PATHS["frustration_tracker"], "record_ladder_shortage", [60, 3])

    # Most recent (ladder shortage) should be recommended
    upgrade = await game.call(PATHS["frustration_tracker"], "get_recommended_upgrade")
    assert upgrade == "supplies", f"Most recent frustration should be current, got '{upgrade}'"


# =============================================================================
# CLEAR FRUSTRATION TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_clear_all_frustrations(game):
    """clear_frustration with no args should clear all frustrations."""
    # Record some frustrations
    await game.call(PATHS["frustration_tracker"], "record_hard_block", [2, 1])
    await game.call(PATHS["frustration_tracker"], "record_ladder_shortage", [50, 2])

    # Clear all
    await game.call(PATHS["frustration_tracker"], "clear_frustration", [0])  # 0 = NONE means clear all

    # Should have no recommendation
    upgrade = await game.call(PATHS["frustration_tracker"], "get_recommended_upgrade")
    assert upgrade == "", f"Should have no recommendation after clear, got '{upgrade}'"


@pytest.mark.asyncio
async def test_reset_clears_state(game):
    """reset() should clear all frustrations and counters."""
    # Record some frustrations
    await game.call(PATHS["frustration_tracker"], "record_hard_block", [2, 1])

    # Reset
    await game.call(PATHS["frustration_tracker"], "reset")

    # Should have no recommendation
    upgrade = await game.call(PATHS["frustration_tracker"], "get_recommended_upgrade")
    assert upgrade == "", f"Should have no recommendation after reset, got '{upgrade}'"

    # Recent frustrations should be empty
    frustrations = await game.call(PATHS["frustration_tracker"], "get_all_recent_frustrations")
    assert len(frustrations) == 0, f"Should have no frustrations after reset, got {len(frustrations)}"


# =============================================================================
# UPGRADE RECOMMENDATION TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_is_upgrade_recommended(game):
    """is_upgrade_recommended should return true for current recommendation."""
    # Reset to ensure clean state
    await game.call(PATHS["frustration_tracker"], "reset")

    # Record hard block (recommends pickaxe)
    await game.call(PATHS["frustration_tracker"], "record_hard_block", [3, 1])

    # Check pickaxe is recommended
    is_recommended = await game.call(PATHS["frustration_tracker"], "is_upgrade_recommended", ["pickaxe"])
    assert is_recommended is True, "pickaxe should be recommended after hard block"

    # Check other upgrades are not recommended
    is_boots_recommended = await game.call(PATHS["frustration_tracker"], "is_upgrade_recommended", ["boots"])
    assert is_boots_recommended is False, "boots should not be recommended for hard block"


# =============================================================================
# FRUSTRATION DESCRIPTION TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_frustration_description_not_empty(game):
    """get_frustration_description should return non-empty string when frustrated."""
    # Reset to ensure clean state
    await game.call(PATHS["frustration_tracker"], "reset")

    # Record a frustration
    await game.call(PATHS["frustration_tracker"], "record_hard_block", [3, 1])

    # Get description
    description = await game.call(PATHS["frustration_tracker"], "get_frustration_description")
    assert description != "", "Should have a description when frustrated"
    assert len(description) > 5, f"Description should be meaningful, got '{description}'"


# =============================================================================
# ALL RECENT FRUSTRATIONS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_all_recent_frustrations_returns_list(game):
    """get_all_recent_frustrations should return array of frustration data."""
    # Reset to ensure clean state
    await game.call(PATHS["frustration_tracker"], "reset")

    # Record multiple frustrations
    await game.call(PATHS["frustration_tracker"], "record_hard_block", [2, 1])
    await game.call(PATHS["frustration_tracker"], "record_death", ["fall", 30])

    # Get all frustrations
    frustrations = await game.call(PATHS["frustration_tracker"], "get_all_recent_frustrations")
    assert frustrations is not None, "Should return a value"
    assert isinstance(frustrations, list), f"Should return array, got {type(frustrations)}"
    assert len(frustrations) == 2, f"Should have 2 frustrations, got {len(frustrations)}"


@pytest.mark.asyncio
async def test_recent_frustrations_have_required_fields(game):
    """Each frustration in get_all_recent_frustrations should have required fields."""
    # Reset to ensure clean state
    await game.call(PATHS["frustration_tracker"], "reset")

    # Record a frustration
    await game.call(PATHS["frustration_tracker"], "record_ladder_shortage", [50, 3])

    # Get all frustrations
    frustrations = await game.call(PATHS["frustration_tracker"], "get_all_recent_frustrations")
    assert len(frustrations) >= 1, "Should have at least 1 frustration"

    frustration = frustrations[0]
    assert "type_name" in frustration, "Frustration should have type_name"
    assert "upgrade" in frustration, "Frustration should have upgrade"
    assert "description" in frustration, "Frustration should have description"
    assert "count" in frustration, "Frustration should have count"


# =============================================================================
# MINING TRACKING TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_track_mining_hit(game):
    """track_mining_hit should be callable without error."""
    # This just verifies the method exists and is callable
    result = await game.call(PATHS["frustration_tracker"], "track_mining_hit")
    # Method is void, should not throw
    assert result is None or result is True or result is False, "track_mining_hit should complete"


@pytest.mark.asyncio
async def test_track_block_mined(game):
    """track_block_mined should be callable without error."""
    # This just verifies the method exists and is callable
    result = await game.call(PATHS["frustration_tracker"], "track_block_mined")
    # Method is void, should not throw
    assert result is None or result is True or result is False, "track_block_mined should complete"


# =============================================================================
# SIGNAL EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_frustration_recorded_signal(game):
    """FrustrationTracker should have frustration_recorded signal."""
    has_signal = await game.call(PATHS["frustration_tracker"], "has_signal", ["frustration_recorded"])
    assert has_signal is True, "FrustrationTracker should have frustration_recorded signal"


@pytest.mark.asyncio
async def test_has_recommended_upgrade_changed_signal(game):
    """FrustrationTracker should have recommended_upgrade_changed signal."""
    has_signal = await game.call(PATHS["frustration_tracker"], "has_signal", ["recommended_upgrade_changed"])
    assert has_signal is True, "FrustrationTracker should have recommended_upgrade_changed signal"


# =============================================================================
# SAVE/LOAD DATA TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_save_data(game):
    """get_save_data should return dictionary with trip_count."""
    data = await game.call(PATHS["frustration_tracker"], "get_save_data")
    assert data is not None, "get_save_data should return a value"
    assert isinstance(data, dict), f"get_save_data should return dict, got {type(data)}"
    assert "trip_count" in data, "Save data should include trip_count"


@pytest.mark.asyncio
async def test_load_save_data(game):
    """load_save_data should restore trip_count."""
    # Reset first
    await game.call(PATHS["frustration_tracker"], "reset")

    # Load some save data
    test_data = {"trip_count": 5}
    await game.call(PATHS["frustration_tracker"], "load_save_data", [test_data])

    # Verify by getting save data back
    data = await game.call(PATHS["frustration_tracker"], "get_save_data")
    assert data.get("trip_count") == 5, f"trip_count should be 5, got {data.get('trip_count')}"


# =============================================================================
# FRUSTRATION TYPE CONSTANTS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_frustration_to_upgrade_mapping_exists(game):
    """FRUSTRATION_TO_UPGRADE constant should be accessible."""
    result = await game.get_property(PATHS["frustration_tracker"], "FRUSTRATION_TO_UPGRADE")
    assert result is not None, "FRUSTRATION_TO_UPGRADE should exist"
    assert isinstance(result, dict), f"FRUSTRATION_TO_UPGRADE should be dict, got {type(result)}"


@pytest.mark.asyncio
async def test_frustration_descriptions_exists(game):
    """FRUSTRATION_DESCRIPTIONS constant should be accessible."""
    result = await game.get_property(PATHS["frustration_tracker"], "FRUSTRATION_DESCRIPTIONS")
    assert result is not None, "FRUSTRATION_DESCRIPTIONS should exist"
    assert isinstance(result, dict), f"FRUSTRATION_DESCRIPTIONS should be dict, got {type(result)}"


@pytest.mark.asyncio
async def test_frustration_decay_timeout_configured(game):
    """FRUSTRATION_DECAY_SECONDS should be configured."""
    result = await game.get_property(PATHS["frustration_tracker"], "FRUSTRATION_DECAY_SECONDS")
    assert result is not None, "FRUSTRATION_DECAY_SECONDS should exist"
    assert isinstance(result, (int, float)), f"FRUSTRATION_DECAY_SECONDS should be number, got {type(result)}"
    assert result > 0, f"Decay timeout should be positive, got {result}"
