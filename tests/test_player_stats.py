"""
PlayerStats tests for GoDig endless digging game.

Tests verify that PlayerStats:
1. Exists as an autoload singleton
2. Tracks mining statistics
3. Tracks movement statistics
4. Tracks economy statistics
5. Tracks death statistics
6. Tracks depth statistics
7. Has proper save/load functionality
"""
import pytest
from helpers import PATHS


# Path to player stats
PLAYER_STATS_PATH = PATHS.get("player_stats", "/root/PlayerStats")


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_player_stats_exists(game):
    """PlayerStats autoload should exist."""
    result = await game.node_exists(PLAYER_STATS_PATH)
    assert result.get("exists") is True, "PlayerStats autoload should exist"


# =============================================================================
# MINING STATISTICS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_blocks_mined_total(game):
    """PlayerStats should have blocks_mined_total property."""
    result = await game.get_property(PLAYER_STATS_PATH, "blocks_mined_total")
    assert result is not None, "blocks_mined_total should exist"
    assert isinstance(result, int), f"blocks_mined_total should be int, got {type(result)}"
    assert result >= 0, f"blocks_mined_total should be non-negative, got {result}"


@pytest.mark.asyncio
async def test_has_blocks_mined_by_type(game):
    """PlayerStats should have blocks_mined_by_type dictionary."""
    result = await game.get_property(PLAYER_STATS_PATH, "blocks_mined_by_type")
    assert result is not None, "blocks_mined_by_type should exist"
    assert isinstance(result, dict), f"blocks_mined_by_type should be dict, got {type(result)}"


@pytest.mark.asyncio
async def test_has_ores_collected_total(game):
    """PlayerStats should have ores_collected_total property."""
    result = await game.get_property(PLAYER_STATS_PATH, "ores_collected_total")
    assert result is not None, "ores_collected_total should exist"
    assert isinstance(result, int), f"ores_collected_total should be int, got {type(result)}"
    assert result >= 0, f"ores_collected_total should be non-negative, got {result}"


@pytest.mark.asyncio
async def test_has_ores_collected_by_type(game):
    """PlayerStats should have ores_collected_by_type dictionary."""
    result = await game.get_property(PLAYER_STATS_PATH, "ores_collected_by_type")
    assert result is not None, "ores_collected_by_type should exist"
    assert isinstance(result, dict), f"ores_collected_by_type should be dict, got {type(result)}"


# =============================================================================
# MOVEMENT STATISTICS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_tiles_moved(game):
    """PlayerStats should have tiles_moved property."""
    result = await game.get_property(PLAYER_STATS_PATH, "tiles_moved")
    assert result is not None, "tiles_moved should exist"
    assert isinstance(result, int), f"tiles_moved should be int, got {type(result)}"
    assert result >= 0, f"tiles_moved should be non-negative, got {result}"


@pytest.mark.asyncio
async def test_has_jumps_performed(game):
    """PlayerStats should have jumps_performed property."""
    result = await game.get_property(PLAYER_STATS_PATH, "jumps_performed")
    assert result is not None, "jumps_performed should exist"
    assert isinstance(result, int), f"jumps_performed should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_has_wall_jumps_performed(game):
    """PlayerStats should have wall_jumps_performed property."""
    result = await game.get_property(PLAYER_STATS_PATH, "wall_jumps_performed")
    assert result is not None, "wall_jumps_performed should exist"
    assert isinstance(result, int), f"wall_jumps_performed should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_has_ladders_climbed(game):
    """PlayerStats should have ladders_climbed property."""
    result = await game.get_property(PLAYER_STATS_PATH, "ladders_climbed")
    assert result is not None, "ladders_climbed should exist"
    assert isinstance(result, int), f"ladders_climbed should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_has_falls_taken(game):
    """PlayerStats should have falls_taken property."""
    result = await game.get_property(PLAYER_STATS_PATH, "falls_taken")
    assert result is not None, "falls_taken should exist"
    assert isinstance(result, int), f"falls_taken should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_has_fall_damage_taken(game):
    """PlayerStats should have fall_damage_taken property."""
    result = await game.get_property(PLAYER_STATS_PATH, "fall_damage_taken")
    assert result is not None, "fall_damage_taken should exist"
    assert isinstance(result, int), f"fall_damage_taken should be int, got {type(result)}"


# =============================================================================
# ECONOMY STATISTICS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_coins_earned_total(game):
    """PlayerStats should have coins_earned_total property."""
    result = await game.get_property(PLAYER_STATS_PATH, "coins_earned_total")
    assert result is not None, "coins_earned_total should exist"
    assert isinstance(result, int), f"coins_earned_total should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_has_coins_spent_total(game):
    """PlayerStats should have coins_spent_total property."""
    result = await game.get_property(PLAYER_STATS_PATH, "coins_spent_total")
    assert result is not None, "coins_spent_total should exist"
    assert isinstance(result, int), f"coins_spent_total should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_has_items_purchased(game):
    """PlayerStats should have items_purchased property."""
    result = await game.get_property(PLAYER_STATS_PATH, "items_purchased")
    assert result is not None, "items_purchased should exist"
    assert isinstance(result, int), f"items_purchased should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_has_items_sold_total(game):
    """PlayerStats should have items_sold_total property."""
    result = await game.get_property(PLAYER_STATS_PATH, "items_sold_total")
    assert result is not None, "items_sold_total should exist"
    assert isinstance(result, int), f"items_sold_total should be int, got {type(result)}"


# =============================================================================
# DEATH STATISTICS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_deaths_total(game):
    """PlayerStats should have deaths_total property."""
    result = await game.get_property(PLAYER_STATS_PATH, "deaths_total")
    assert result is not None, "deaths_total should exist"
    assert isinstance(result, int), f"deaths_total should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_has_deaths_by_cause(game):
    """PlayerStats should have deaths_by_cause dictionary."""
    result = await game.get_property(PLAYER_STATS_PATH, "deaths_by_cause")
    assert result is not None, "deaths_by_cause should exist"
    assert isinstance(result, dict), f"deaths_by_cause should be dict, got {type(result)}"


@pytest.mark.asyncio
async def test_has_deepest_death_depth(game):
    """PlayerStats should have deepest_death_depth property."""
    result = await game.get_property(PLAYER_STATS_PATH, "deepest_death_depth")
    assert result is not None, "deepest_death_depth should exist"
    assert isinstance(result, int), f"deepest_death_depth should be int, got {type(result)}"


# =============================================================================
# TIME STATISTICS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_total_playtime_seconds(game):
    """PlayerStats should have total_playtime_seconds property."""
    result = await game.get_property(PLAYER_STATS_PATH, "total_playtime_seconds")
    assert result is not None, "total_playtime_seconds should exist"
    assert isinstance(result, (int, float)), f"total_playtime_seconds should be number, got {type(result)}"


@pytest.mark.asyncio
async def test_has_sessions_played(game):
    """PlayerStats should have sessions_played property."""
    result = await game.get_property(PLAYER_STATS_PATH, "sessions_played")
    assert result is not None, "sessions_played should exist"
    assert isinstance(result, int), f"sessions_played should be int, got {type(result)}"
    assert result >= 1, f"sessions_played should be at least 1, got {result}"


# =============================================================================
# DEPTH STATISTICS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_max_depth_reached(game):
    """PlayerStats should have max_depth_reached property."""
    result = await game.get_property(PLAYER_STATS_PATH, "max_depth_reached")
    assert result is not None, "max_depth_reached should exist"
    assert isinstance(result, int), f"max_depth_reached should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_has_times_reached_depth(game):
    """PlayerStats should have times_reached_depth dictionary."""
    result = await game.get_property(PLAYER_STATS_PATH, "times_reached_depth")
    assert result is not None, "times_reached_depth should exist"
    assert isinstance(result, dict), f"times_reached_depth should be dict, got {type(result)}"


# =============================================================================
# SESSION STATISTICS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_session_blocks_mined(game):
    """PlayerStats should have session_blocks_mined property."""
    result = await game.get_property(PLAYER_STATS_PATH, "session_blocks_mined")
    assert result is not None, "session_blocks_mined should exist"
    assert isinstance(result, int), f"session_blocks_mined should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_has_session_ores_collected(game):
    """PlayerStats should have session_ores_collected property."""
    result = await game.get_property(PLAYER_STATS_PATH, "session_ores_collected")
    assert result is not None, "session_ores_collected should exist"
    assert isinstance(result, int), f"session_ores_collected should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_has_session_max_depth(game):
    """PlayerStats should have session_max_depth property."""
    result = await game.get_property(PLAYER_STATS_PATH, "session_max_depth")
    assert result is not None, "session_max_depth should exist"
    assert isinstance(result, int), f"session_max_depth should be int, got {type(result)}"


# =============================================================================
# MILESTONE CONSTANT TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_mining_milestones(game):
    """PlayerStats should have MINING_MILESTONES constant."""
    result = await game.get_property(PLAYER_STATS_PATH, "MINING_MILESTONES")
    assert result is not None, "MINING_MILESTONES should exist"
    assert isinstance(result, list), f"MINING_MILESTONES should be array, got {type(result)}"
    assert len(result) > 0, "MINING_MILESTONES should not be empty"


@pytest.mark.asyncio
async def test_has_movement_milestones(game):
    """PlayerStats should have MOVEMENT_MILESTONES constant."""
    result = await game.get_property(PLAYER_STATS_PATH, "MOVEMENT_MILESTONES")
    assert result is not None, "MOVEMENT_MILESTONES should exist"
    assert isinstance(result, list), f"MOVEMENT_MILESTONES should be array, got {type(result)}"


@pytest.mark.asyncio
async def test_has_coin_milestones(game):
    """PlayerStats should have COIN_MILESTONES constant."""
    result = await game.get_property(PLAYER_STATS_PATH, "COIN_MILESTONES")
    assert result is not None, "COIN_MILESTONES should exist"
    assert isinstance(result, list), f"COIN_MILESTONES should be array, got {type(result)}"


# =============================================================================
# TRACKING METHOD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_track_block_mined_increments(game):
    """track_block_mined should increment blocks_mined_total."""
    # Get current value
    before = await game.get_property(PLAYER_STATS_PATH, "blocks_mined_total")

    # Track a block mined
    await game.call(PLAYER_STATS_PATH, "track_block_mined", ["dirt"])

    # Verify increment
    after = await game.get_property(PLAYER_STATS_PATH, "blocks_mined_total")
    assert after == before + 1, f"blocks_mined_total should increment by 1, was {before}, now {after}"


@pytest.mark.asyncio
async def test_track_ore_collected_increments(game):
    """track_ore_collected should increment ores_collected_total."""
    # Get current value
    before = await game.get_property(PLAYER_STATS_PATH, "ores_collected_total")

    # Track an ore collected
    await game.call(PLAYER_STATS_PATH, "track_ore_collected", ["coal"])

    # Verify increment
    after = await game.get_property(PLAYER_STATS_PATH, "ores_collected_total")
    assert after == before + 1, f"ores_collected_total should increment by 1, was {before}, now {after}"


@pytest.mark.asyncio
async def test_track_tile_moved_increments(game):
    """track_tile_moved should increment tiles_moved."""
    # Get current value
    before = await game.get_property(PLAYER_STATS_PATH, "tiles_moved")

    # Track a tile move
    await game.call(PLAYER_STATS_PATH, "track_tile_moved")

    # Verify increment
    after = await game.get_property(PLAYER_STATS_PATH, "tiles_moved")
    assert after == before + 1, f"tiles_moved should increment by 1, was {before}, now {after}"


@pytest.mark.asyncio
async def test_track_coins_earned_increments(game):
    """track_coins_earned should add to coins_earned_total."""
    # Get current value
    before = await game.get_property(PLAYER_STATS_PATH, "coins_earned_total")

    # Track coins earned
    await game.call(PLAYER_STATS_PATH, "track_coins_earned", [100])

    # Verify increment
    after = await game.get_property(PLAYER_STATS_PATH, "coins_earned_total")
    assert after == before + 100, f"coins_earned_total should increase by 100, was {before}, now {after}"


@pytest.mark.asyncio
async def test_track_death_increments(game):
    """track_death should increment deaths_total."""
    # Get current value
    before = await game.get_property(PLAYER_STATS_PATH, "deaths_total")

    # Track a death
    await game.call(PLAYER_STATS_PATH, "track_death", ["fall", 50])

    # Verify increment
    after = await game.get_property(PLAYER_STATS_PATH, "deaths_total")
    assert after == before + 1, f"deaths_total should increment by 1, was {before}, now {after}"


@pytest.mark.asyncio
async def test_track_depth_updates_max(game):
    """track_depth should update max_depth_reached if new depth is higher."""
    # Reset to ensure clean state
    await game.call(PLAYER_STATS_PATH, "reset")

    # Track a depth
    await game.call(PLAYER_STATS_PATH, "track_depth", [50])

    # Verify max depth
    max_depth = await game.get_property(PLAYER_STATS_PATH, "max_depth_reached")
    assert max_depth >= 50, f"max_depth_reached should be at least 50, got {max_depth}"


# =============================================================================
# CONVENIENCE GETTER TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_playtime_string(game):
    """get_playtime_string should return a formatted time string."""
    result = await game.call(PLAYER_STATS_PATH, "get_playtime_string")
    assert result is not None, "get_playtime_string should return a value"
    assert isinstance(result, str), f"get_playtime_string should return string, got {type(result)}"
    # Should contain at least one colon (M:SS or H:MM:SS format)
    assert ":" in result, f"Playtime string should be formatted with colons, got '{result}'"


@pytest.mark.asyncio
async def test_get_most_mined_block_type(game):
    """get_most_mined_block_type should return a block type string."""
    result = await game.call(PLAYER_STATS_PATH, "get_most_mined_block_type")
    assert result is not None, "get_most_mined_block_type should return a value"
    assert isinstance(result, str), f"get_most_mined_block_type should return string, got {type(result)}"


@pytest.mark.asyncio
async def test_get_most_collected_ore(game):
    """get_most_collected_ore should return an ore ID string."""
    result = await game.call(PLAYER_STATS_PATH, "get_most_collected_ore")
    assert result is not None, "get_most_collected_ore should return a value"
    assert isinstance(result, str), f"get_most_collected_ore should return string, got {type(result)}"


@pytest.mark.asyncio
async def test_get_most_common_death_cause(game):
    """get_most_common_death_cause should return a cause string."""
    result = await game.call(PLAYER_STATS_PATH, "get_most_common_death_cause")
    assert result is not None, "get_most_common_death_cause should return a value"
    assert isinstance(result, str), f"get_most_common_death_cause should return string, got {type(result)}"


@pytest.mark.asyncio
async def test_get_session_duration(game):
    """get_session_duration should return a positive number."""
    result = await game.call(PLAYER_STATS_PATH, "get_session_duration")
    assert result is not None, "get_session_duration should return a value"
    assert isinstance(result, (int, float)), f"get_session_duration should return number, got {type(result)}"
    assert result >= 0, f"Session duration should be non-negative, got {result}"


# =============================================================================
# SIGNAL TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_stat_updated_signal(game):
    """PlayerStats should have stat_updated signal."""
    has_signal = await game.call(PLAYER_STATS_PATH, "has_signal", ["stat_updated"])
    assert has_signal is True, "PlayerStats should have stat_updated signal"


@pytest.mark.asyncio
async def test_has_milestone_reached_signal(game):
    """PlayerStats should have milestone_reached signal."""
    has_signal = await game.call(PLAYER_STATS_PATH, "has_signal", ["milestone_reached"])
    assert has_signal is True, "PlayerStats should have milestone_reached signal"


# =============================================================================
# SAVE/LOAD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_save_data_returns_dict(game):
    """get_save_data should return a dictionary."""
    result = await game.call(PLAYER_STATS_PATH, "get_save_data")
    assert result is not None, "get_save_data should return a value"
    assert isinstance(result, dict), f"get_save_data should return dict, got {type(result)}"


@pytest.mark.asyncio
async def test_get_save_data_has_required_fields(game):
    """get_save_data should include all required fields."""
    result = await game.call(PLAYER_STATS_PATH, "get_save_data")
    required_fields = [
        "blocks_mined_total",
        "tiles_moved",
        "coins_earned_total",
        "deaths_total",
        "max_depth_reached",
        "total_playtime_seconds",
        "sessions_played",
    ]
    for field in required_fields:
        assert field in result, f"Save data should include {field}"


@pytest.mark.asyncio
async def test_load_save_data_restores_values(game):
    """load_save_data should restore statistics."""
    test_data = {
        "blocks_mined_total": 100,
        "tiles_moved": 500,
        "coins_earned_total": 1000,
        "deaths_total": 5,
        "max_depth_reached": 75,
        "total_playtime_seconds": 3600.0,
        "sessions_played": 10,
    }
    await game.call(PLAYER_STATS_PATH, "load_save_data", [test_data])

    # Verify blocks_mined_total was restored
    blocks = await game.get_property(PLAYER_STATS_PATH, "blocks_mined_total")
    assert blocks == 100, f"blocks_mined_total should be 100, got {blocks}"

    # Verify max_depth_reached was restored
    depth = await game.get_property(PLAYER_STATS_PATH, "max_depth_reached")
    assert depth == 75, f"max_depth_reached should be 75, got {depth}"


# =============================================================================
# RESET TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_reset_clears_stats(game):
    """reset should clear all statistics to zero/empty."""
    # First track some stats
    await game.call(PLAYER_STATS_PATH, "track_block_mined", ["dirt"])
    await game.call(PLAYER_STATS_PATH, "track_coins_earned", [100])

    # Reset
    await game.call(PLAYER_STATS_PATH, "reset")

    # Verify cleared
    blocks = await game.get_property(PLAYER_STATS_PATH, "blocks_mined_total")
    assert blocks == 0, f"blocks_mined_total should be 0 after reset, got {blocks}"

    coins = await game.get_property(PLAYER_STATS_PATH, "coins_earned_total")
    assert coins == 0, f"coins_earned_total should be 0 after reset, got {coins}"


@pytest.mark.asyncio
async def test_reset_starts_new_session(game):
    """reset should start a new session."""
    # Get current sessions
    before = await game.get_property(PLAYER_STATS_PATH, "sessions_played")

    # Reset starts a new session (sessions_played becomes 1)
    await game.call(PLAYER_STATS_PATH, "reset")

    after = await game.get_property(PLAYER_STATS_PATH, "sessions_played")
    # After reset, sessions_played is 1 (new session started)
    assert after == 1, f"sessions_played should be 1 after reset, got {after}"
