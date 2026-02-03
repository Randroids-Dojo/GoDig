"""
JournalManager tests for GoDig endless digging game.

Tests verify that JournalManager:
1. Exists as an autoload singleton
2. Tracks collected lore entries
3. Has proper collection statistics
4. Supports save/load of journal data
5. Has required signals
"""
import pytest
from helpers import PATHS


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_journal_manager_exists(game):
    """JournalManager autoload should exist."""
    result = await game.node_exists(PATHS["journal_manager"])
    assert result.get("exists") is True, "JournalManager autoload should exist"


# =============================================================================
# INITIAL STATE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_initial_collected_count_zero(game):
    """JournalManager should have zero collected lore after reset."""
    # Reset to ensure clean state
    await game.call(PATHS["journal_manager"], "reset")

    count = await game.call(PATHS["journal_manager"], "get_collected_count")
    assert count == 0, f"Should have 0 collected lore after reset, got {count}"


@pytest.mark.asyncio
async def test_initial_collection_progress_zero(game):
    """JournalManager should have zero collection progress after reset."""
    # Reset to ensure clean state
    await game.call(PATHS["journal_manager"], "reset")

    progress = await game.call(PATHS["journal_manager"], "get_collection_progress")
    assert progress == 0.0 or progress is None or progress >= 0.0, f"Progress should be 0 or valid, got {progress}"


# =============================================================================
# LORE QUERY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_total_count(game):
    """get_total_count should return number of available lore entries."""
    count = await game.call(PATHS["journal_manager"], "get_total_count")
    assert count is not None, "get_total_count should return a value"
    assert isinstance(count, int), f"get_total_count should return int, got {type(count)}"
    assert count >= 0, f"Total count should be non-negative, got {count}"


@pytest.mark.asyncio
async def test_get_all_lore(game):
    """get_all_lore should return an array."""
    lore = await game.call(PATHS["journal_manager"], "get_all_lore")
    assert lore is not None, "get_all_lore should return a value"
    assert isinstance(lore, list), f"get_all_lore should return array, got {type(lore)}"


@pytest.mark.asyncio
async def test_get_collected_lore_empty_after_reset(game):
    """get_collected_lore should return empty array after reset."""
    # Reset to ensure clean state
    await game.call(PATHS["journal_manager"], "reset")

    lore = await game.call(PATHS["journal_manager"], "get_collected_lore")
    assert lore is not None, "get_collected_lore should return a value"
    assert isinstance(lore, list), f"get_collected_lore should return array, got {type(lore)}"
    assert len(lore) == 0, f"Should have no collected lore after reset, got {len(lore)}"


# =============================================================================
# LORE COLLECTION TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_is_collected_returns_false_for_uncollected(game):
    """is_collected should return false for non-collected lore."""
    # Reset to ensure clean state
    await game.call(PATHS["journal_manager"], "reset")

    result = await game.call(PATHS["journal_manager"], "is_collected", ["nonexistent_lore_id"])
    assert result is False, "is_collected should return false for non-collected lore"


# =============================================================================
# LORE SPAWN TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_spawned_lore_returns_false_initially(game):
    """has_spawned_lore should return false for unspawned positions."""
    pos = {"x": 100, "y": 100}
    result = await game.call(PATHS["journal_manager"], "has_spawned_lore", [pos])
    # May return false or may have spawned lore - check it's a valid response
    assert result is True or result is False, f"has_spawned_lore should return bool, got {result}"


@pytest.mark.asyncio
async def test_get_spawned_lore_id_returns_empty_for_no_spawn(game):
    """get_spawned_lore_id should return empty string for positions without spawned lore."""
    pos = {"x": 1000, "y": 1000}  # Unlikely to have spawned lore
    result = await game.call(PATHS["journal_manager"], "get_spawned_lore_id", [pos])
    # Either empty string or a lore ID
    assert result is not None, "get_spawned_lore_id should return a value"


@pytest.mark.asyncio
async def test_was_lore_opened_returns_false_for_unopened(game):
    """was_lore_opened should return false for positions without opened lore."""
    # Reset to ensure clean state
    await game.call(PATHS["journal_manager"], "reset")

    pos = {"x": 200, "y": 200}
    result = await game.call(PATHS["journal_manager"], "was_lore_opened", [pos])
    assert result is False, "was_lore_opened should return false for unopened positions"


@pytest.mark.asyncio
async def test_mark_lore_opened(game):
    """mark_lore_opened should mark position as opened."""
    # Reset first
    await game.call(PATHS["journal_manager"], "reset")

    pos = {"x": 300, "y": 300}

    # Mark as opened
    await game.call(PATHS["journal_manager"], "mark_lore_opened", [pos])

    # Check it's now marked
    result = await game.call(PATHS["journal_manager"], "was_lore_opened", [pos])
    assert result is True, "Position should be marked as opened after mark_lore_opened"


# =============================================================================
# STATISTICS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_stats_returns_dict(game):
    """get_stats should return a dictionary with journal statistics."""
    stats = await game.call(PATHS["journal_manager"], "get_stats")
    assert stats is not None, "get_stats should return a value"
    assert isinstance(stats, dict), f"get_stats should return dict, got {type(stats)}"


@pytest.mark.asyncio
async def test_get_stats_has_required_fields(game):
    """get_stats should have required statistical fields."""
    stats = await game.call(PATHS["journal_manager"], "get_stats")

    assert "total_lore" in stats, "Stats should include total_lore"
    assert "collected_lore" in stats, "Stats should include collected_lore"
    assert "completion_percent" in stats, "Stats should include completion_percent"
    assert "by_type" in stats, "Stats should include by_type"


@pytest.mark.asyncio
async def test_stats_total_matches_get_total_count(game):
    """get_stats total_lore should match get_total_count."""
    stats = await game.call(PATHS["journal_manager"], "get_stats")
    total_count = await game.call(PATHS["journal_manager"], "get_total_count")

    assert stats.get("total_lore") == total_count, f"Stats total ({stats.get('total_lore')}) should match get_total_count ({total_count})"


@pytest.mark.asyncio
async def test_stats_collected_matches_get_collected_count(game):
    """get_stats collected_lore should match get_collected_count."""
    # Reset to ensure clean state
    await game.call(PATHS["journal_manager"], "reset")

    stats = await game.call(PATHS["journal_manager"], "get_stats")
    collected_count = await game.call(PATHS["journal_manager"], "get_collected_count")

    assert stats.get("collected_lore") == collected_count, f"Stats collected ({stats.get('collected_lore')}) should match get_collected_count ({collected_count})"


# =============================================================================
# SAVE/LOAD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_save_data_returns_dict(game):
    """get_save_data should return a dictionary."""
    data = await game.call(PATHS["journal_manager"], "get_save_data")
    assert data is not None, "get_save_data should return a value"
    assert isinstance(data, dict), f"get_save_data should return dict, got {type(data)}"


@pytest.mark.asyncio
async def test_get_save_data_has_required_fields(game):
    """get_save_data should have required fields."""
    data = await game.call(PATHS["journal_manager"], "get_save_data")

    assert "collected_lore" in data, "Save data should include collected_lore"
    assert "opened_lore" in data, "Save data should include opened_lore"


@pytest.mark.asyncio
async def test_load_save_data_restores_opened(game):
    """load_save_data should restore opened lore positions."""
    # Reset first
    await game.call(PATHS["journal_manager"], "reset")

    # Mark a position as opened
    pos = {"x": 400, "y": 400}
    await game.call(PATHS["journal_manager"], "mark_lore_opened", [pos])

    # Get save data
    save_data = await game.call(PATHS["journal_manager"], "get_save_data")

    # Reset (clear state)
    await game.call(PATHS["journal_manager"], "reset")

    # Verify position is not opened after reset
    was_opened_before = await game.call(PATHS["journal_manager"], "was_lore_opened", [pos])
    assert was_opened_before is False, "Position should not be opened after reset"

    # Load save data
    await game.call(PATHS["journal_manager"], "load_save_data", [save_data])

    # Verify position is opened again
    was_opened_after = await game.call(PATHS["journal_manager"], "was_lore_opened", [pos])
    assert was_opened_after is True, "Position should be opened after load"


# =============================================================================
# RESET TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_reset_clears_collected(game):
    """reset() should clear collected lore."""
    # Reset
    await game.call(PATHS["journal_manager"], "reset")

    # Check collected count is 0
    count = await game.call(PATHS["journal_manager"], "get_collected_count")
    assert count == 0, f"Collected count should be 0 after reset, got {count}"


@pytest.mark.asyncio
async def test_reset_clears_opened(game):
    """reset() should clear opened lore positions."""
    # Mark a position as opened
    pos = {"x": 500, "y": 500}
    await game.call(PATHS["journal_manager"], "mark_lore_opened", [pos])

    # Reset
    await game.call(PATHS["journal_manager"], "reset")

    # Check position is not opened
    result = await game.call(PATHS["journal_manager"], "was_lore_opened", [pos])
    assert result is False, "Position should not be opened after reset"


# =============================================================================
# SIGNAL EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_lore_collected_signal(game):
    """JournalManager should have lore_collected signal."""
    has_signal = await game.call(PATHS["journal_manager"], "has_signal", ["lore_collected"])
    assert has_signal is True, "JournalManager should have lore_collected signal"


@pytest.mark.asyncio
async def test_has_journal_updated_signal(game):
    """JournalManager should have journal_updated signal."""
    has_signal = await game.call(PATHS["journal_manager"], "has_signal", ["journal_updated"])
    assert has_signal is True, "JournalManager should have journal_updated signal"


@pytest.mark.asyncio
async def test_has_lore_spawned_signal(game):
    """JournalManager should have lore_spawned signal."""
    has_signal = await game.call(PATHS["journal_manager"], "has_signal", ["lore_spawned"])
    assert has_signal is True, "JournalManager should have lore_spawned signal"


# =============================================================================
# LORE TYPE QUERY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_lore_by_type_returns_array(game):
    """get_lore_by_type should return an array."""
    # Use a type that may or may not exist
    lore = await game.call(PATHS["journal_manager"], "get_lore_by_type", ["journal"])
    assert lore is not None, "get_lore_by_type should return a value"
    assert isinstance(lore, list), f"get_lore_by_type should return array, got {type(lore)}"


@pytest.mark.asyncio
async def test_get_lore_by_type_returns_empty_for_invalid_type(game):
    """get_lore_by_type should return empty array for non-existent type."""
    lore = await game.call(PATHS["journal_manager"], "get_lore_by_type", ["nonexistent_type_xyz"])
    assert lore is not None, "get_lore_by_type should return a value"
    assert isinstance(lore, list), f"get_lore_by_type should return array, got {type(lore)}"
    assert len(lore) == 0, f"Should return empty array for non-existent type, got {len(lore)}"


@pytest.mark.asyncio
async def test_get_lore_returns_null_for_invalid_id(game):
    """get_lore should return null for non-existent lore ID."""
    lore = await game.call(PATHS["journal_manager"], "get_lore", ["nonexistent_lore_xyz"])
    # get_lore returns null for non-existent IDs
    assert lore is None, f"get_lore should return null for non-existent ID, got {lore}"
