"""
PerformanceMonitor tests for GoDig endless digging game.

Tests verify that PerformanceMonitor:
1. Exists as an autoload singleton
2. Tracks FPS and frame time metrics
3. Provides quality preset management
4. Supports adaptive performance mode
5. Returns valid statistics
"""
import pytest
from helpers import PATHS


# Path to performance monitor
PERFORMANCE_PATH = PATHS.get("performance_monitor", "/root/PerformanceMonitor")


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_performance_monitor_exists(game):
    """PerformanceMonitor autoload should exist."""
    result = await game.node_exists(PERFORMANCE_PATH)
    assert result.get("exists") is True, "PerformanceMonitor autoload should exist"


# =============================================================================
# FPS METRICS PROPERTY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_current_fps(game):
    """PerformanceMonitor should have current_fps property."""
    result = await game.get_property(PERFORMANCE_PATH, "current_fps")
    assert result is not None, "current_fps should exist"
    assert isinstance(result, int), f"current_fps should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_has_current_frame_time_ms(game):
    """PerformanceMonitor should have current_frame_time_ms property."""
    result = await game.get_property(PERFORMANCE_PATH, "current_frame_time_ms")
    assert result is not None, "current_frame_time_ms should exist"
    assert isinstance(result, (int, float)), f"current_frame_time_ms should be number, got {type(result)}"


@pytest.mark.asyncio
async def test_has_average_fps(game):
    """PerformanceMonitor should have average_fps property."""
    result = await game.get_property(PERFORMANCE_PATH, "average_fps")
    assert result is not None, "average_fps should exist"
    assert isinstance(result, (int, float)), f"average_fps should be number, got {type(result)}"


@pytest.mark.asyncio
async def test_has_min_fps(game):
    """PerformanceMonitor should have min_fps property."""
    result = await game.get_property(PERFORMANCE_PATH, "min_fps")
    assert result is not None, "min_fps should exist"
    assert isinstance(result, int), f"min_fps should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_has_max_fps(game):
    """PerformanceMonitor should have max_fps property."""
    result = await game.get_property(PERFORMANCE_PATH, "max_fps")
    assert result is not None, "max_fps should exist"
    assert isinstance(result, int), f"max_fps should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_has_frame_spikes(game):
    """PerformanceMonitor should have frame_spikes property."""
    result = await game.get_property(PERFORMANCE_PATH, "frame_spikes")
    assert result is not None, "frame_spikes should exist"
    assert isinstance(result, int), f"frame_spikes should be int, got {type(result)}"
    assert result >= 0, f"frame_spikes should be non-negative, got {result}"


# =============================================================================
# MEMORY METRICS PROPERTY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_static_memory_mb(game):
    """PerformanceMonitor should have static_memory_mb property."""
    result = await game.get_property(PERFORMANCE_PATH, "static_memory_mb")
    assert result is not None, "static_memory_mb should exist"
    assert isinstance(result, (int, float)), f"static_memory_mb should be number, got {type(result)}"


@pytest.mark.asyncio
async def test_has_dynamic_memory_mb(game):
    """PerformanceMonitor should have dynamic_memory_mb property."""
    result = await game.get_property(PERFORMANCE_PATH, "dynamic_memory_mb")
    assert result is not None, "dynamic_memory_mb should exist"
    assert isinstance(result, (int, float)), f"dynamic_memory_mb should be number, got {type(result)}"


@pytest.mark.asyncio
async def test_has_peak_memory_mb(game):
    """PerformanceMonitor should have peak_memory_mb property."""
    result = await game.get_property(PERFORMANCE_PATH, "peak_memory_mb")
    assert result is not None, "peak_memory_mb should exist"
    assert isinstance(result, (int, float)), f"peak_memory_mb should be number, got {type(result)}"


# =============================================================================
# CHUNK/PARTICLE METRICS PROPERTY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_chunks_loaded(game):
    """PerformanceMonitor should have chunks_loaded property."""
    result = await game.get_property(PERFORMANCE_PATH, "chunks_loaded")
    assert result is not None, "chunks_loaded should exist"
    assert isinstance(result, int), f"chunks_loaded should be int, got {type(result)}"
    assert result >= 0, f"chunks_loaded should be non-negative, got {result}"


@pytest.mark.asyncio
async def test_has_chunks_pending(game):
    """PerformanceMonitor should have chunks_pending property."""
    result = await game.get_property(PERFORMANCE_PATH, "chunks_pending")
    assert result is not None, "chunks_pending should exist"
    assert isinstance(result, int), f"chunks_pending should be int, got {type(result)}"
    assert result >= 0, f"chunks_pending should be non-negative, got {result}"


@pytest.mark.asyncio
async def test_has_active_sparkles(game):
    """PerformanceMonitor should have active_sparkles property."""
    result = await game.get_property(PERFORMANCE_PATH, "active_sparkles")
    assert result is not None, "active_sparkles should exist"
    assert isinstance(result, int), f"active_sparkles should be int, got {type(result)}"
    assert result >= 0, f"active_sparkles should be non-negative, got {result}"


# =============================================================================
# QUALITY PRESET PROPERTY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_quality_preset(game):
    """PerformanceMonitor should have quality_preset property."""
    result = await game.get_property(PERFORMANCE_PATH, "quality_preset")
    assert result is not None, "quality_preset should exist"
    assert isinstance(result, int), f"quality_preset should be int (enum), got {type(result)}"
    assert 0 <= result <= 3, f"quality_preset should be 0-3 (LOW to ULTRA), got {result}"


@pytest.mark.asyncio
async def test_has_adaptive_mode(game):
    """PerformanceMonitor should have adaptive_mode property."""
    result = await game.get_property(PERFORMANCE_PATH, "adaptive_mode")
    assert result is not None, "adaptive_mode should exist"
    assert isinstance(result, bool), f"adaptive_mode should be bool, got {type(result)}"


@pytest.mark.asyncio
async def test_has_show_overlay(game):
    """PerformanceMonitor should have show_overlay property."""
    result = await game.get_property(PERFORMANCE_PATH, "show_overlay")
    assert result is not None, "show_overlay should exist"
    assert isinstance(result, bool), f"show_overlay should be bool, got {type(result)}"


# =============================================================================
# QUALITY PRESET METHOD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_chunk_radius(game):
    """get_chunk_radius should return a positive integer."""
    result = await game.call(PERFORMANCE_PATH, "get_chunk_radius")
    assert result is not None, "get_chunk_radius should return a value"
    assert isinstance(result, int), f"get_chunk_radius should return int, got {type(result)}"
    assert result > 0, f"chunk_radius should be positive, got {result}"


@pytest.mark.asyncio
async def test_get_max_sparkles(game):
    """get_max_sparkles should return a positive integer."""
    result = await game.call(PERFORMANCE_PATH, "get_max_sparkles")
    assert result is not None, "get_max_sparkles should return a value"
    assert isinstance(result, int), f"get_max_sparkles should return int, got {type(result)}"
    assert result > 0, f"max_sparkles should be positive, got {result}"


@pytest.mark.asyncio
async def test_get_particle_multiplier(game):
    """get_particle_multiplier should return a positive float."""
    result = await game.call(PERFORMANCE_PATH, "get_particle_multiplier")
    assert result is not None, "get_particle_multiplier should return a value"
    assert isinstance(result, (int, float)), f"get_particle_multiplier should return number, got {type(result)}"
    assert result > 0, f"particle_multiplier should be positive, got {result}"


@pytest.mark.asyncio
async def test_get_preset_by_name_low(game):
    """get_preset_by_name should return 0 for 'LOW'."""
    result = await game.call(PERFORMANCE_PATH, "get_preset_by_name", ["LOW"])
    assert result == 0, f"LOW preset should be 0, got {result}"


@pytest.mark.asyncio
async def test_get_preset_by_name_medium(game):
    """get_preset_by_name should return 1 for 'MEDIUM'."""
    result = await game.call(PERFORMANCE_PATH, "get_preset_by_name", ["MEDIUM"])
    assert result == 1, f"MEDIUM preset should be 1, got {result}"


@pytest.mark.asyncio
async def test_get_preset_by_name_high(game):
    """get_preset_by_name should return 2 for 'HIGH'."""
    result = await game.call(PERFORMANCE_PATH, "get_preset_by_name", ["HIGH"])
    assert result == 2, f"HIGH preset should be 2, got {result}"


@pytest.mark.asyncio
async def test_get_preset_by_name_ultra(game):
    """get_preset_by_name should return 3 for 'ULTRA'."""
    result = await game.call(PERFORMANCE_PATH, "get_preset_by_name", ["ULTRA"])
    assert result == 3, f"ULTRA preset should be 3, got {result}"


@pytest.mark.asyncio
async def test_get_preset_by_name_invalid(game):
    """get_preset_by_name should return 1 (MEDIUM) for invalid name."""
    result = await game.call(PERFORMANCE_PATH, "get_preset_by_name", ["INVALID"])
    assert result == 1, f"Invalid preset should default to MEDIUM (1), got {result}"


# =============================================================================
# STATS METHOD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_stats_returns_dict(game):
    """get_stats should return a dictionary."""
    result = await game.call(PERFORMANCE_PATH, "get_stats")
    assert result is not None, "get_stats should return a value"
    assert isinstance(result, dict), f"get_stats should return dict, got {type(result)}"


@pytest.mark.asyncio
async def test_get_stats_has_fps(game):
    """get_stats should include fps."""
    result = await game.call(PERFORMANCE_PATH, "get_stats")
    assert "fps" in result, "stats should have fps"


@pytest.mark.asyncio
async def test_get_stats_has_fps_avg(game):
    """get_stats should include fps_avg."""
    result = await game.call(PERFORMANCE_PATH, "get_stats")
    assert "fps_avg" in result, "stats should have fps_avg"


@pytest.mark.asyncio
async def test_get_stats_has_memory_static_mb(game):
    """get_stats should include memory_static_mb."""
    result = await game.call(PERFORMANCE_PATH, "get_stats")
    assert "memory_static_mb" in result, "stats should have memory_static_mb"


@pytest.mark.asyncio
async def test_get_stats_has_quality_preset(game):
    """get_stats should include quality_preset."""
    result = await game.call(PERFORMANCE_PATH, "get_stats")
    assert "quality_preset" in result, "stats should have quality_preset"


@pytest.mark.asyncio
async def test_get_stats_has_adaptive_mode(game):
    """get_stats should include adaptive_mode."""
    result = await game.call(PERFORMANCE_PATH, "get_stats")
    assert "adaptive_mode" in result, "stats should have adaptive_mode"


@pytest.mark.asyncio
async def test_get_stats_has_session_duration(game):
    """get_stats should include session_duration_s."""
    result = await game.call(PERFORMANCE_PATH, "get_stats")
    assert "session_duration_s" in result, "stats should have session_duration_s"
    assert result["session_duration_s"] >= 0, "session_duration should be non-negative"


@pytest.mark.asyncio
async def test_get_stats_string_returns_string(game):
    """get_stats_string should return a formatted string."""
    result = await game.call(PERFORMANCE_PATH, "get_stats_string")
    assert result is not None, "get_stats_string should return a value"
    assert isinstance(result, str), f"get_stats_string should return string, got {type(result)}"
    assert len(result) > 0, "stats string should not be empty"


# =============================================================================
# DEVICE DETECTION TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_is_low_end_device_returns_bool(game):
    """is_low_end_device should return a boolean."""
    result = await game.call(PERFORMANCE_PATH, "is_low_end_device")
    assert isinstance(result, bool), f"is_low_end_device should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_get_battery_level_returns_float(game):
    """get_battery_level should return a float (-1 if unavailable)."""
    result = await game.call(PERFORMANCE_PATH, "get_battery_level")
    assert result is not None, "get_battery_level should return a value"
    assert isinstance(result, (int, float)), f"get_battery_level should return number, got {type(result)}"


@pytest.mark.asyncio
async def test_is_on_battery_returns_bool(game):
    """is_on_battery should return a boolean."""
    result = await game.call(PERFORMANCE_PATH, "is_on_battery")
    assert isinstance(result, bool), f"is_on_battery should return bool, got {type(result)}"


# =============================================================================
# UPDATE METHOD TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_update_chunk_metrics_completes(game):
    """update_chunk_metrics should complete without error."""
    result = await game.call(PERFORMANCE_PATH, "update_chunk_metrics", [5, 2])
    # Method should complete without error
    assert result is None or isinstance(result, (bool, dict)), "update_chunk_metrics should complete"


@pytest.mark.asyncio
async def test_update_sparkle_metrics_completes(game):
    """update_sparkle_metrics should complete without error."""
    result = await game.call(PERFORMANCE_PATH, "update_sparkle_metrics", [100])
    # Method should complete without error
    assert result is None or isinstance(result, (bool, dict)), "update_sparkle_metrics should complete"


# =============================================================================
# SIGNAL TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_fps_updated_signal(game):
    """PerformanceMonitor should have fps_updated signal."""
    has_signal = await game.call(PERFORMANCE_PATH, "has_signal", ["fps_updated"])
    assert has_signal is True, "PerformanceMonitor should have fps_updated signal"


@pytest.mark.asyncio
async def test_has_memory_updated_signal(game):
    """PerformanceMonitor should have memory_updated signal."""
    has_signal = await game.call(PERFORMANCE_PATH, "has_signal", ["memory_updated"])
    assert has_signal is True, "PerformanceMonitor should have memory_updated signal"


@pytest.mark.asyncio
async def test_has_performance_warning_signal(game):
    """PerformanceMonitor should have performance_warning signal."""
    has_signal = await game.call(PERFORMANCE_PATH, "has_signal", ["performance_warning"])
    assert has_signal is True, "PerformanceMonitor should have performance_warning signal"


@pytest.mark.asyncio
async def test_has_quality_preset_changed_signal(game):
    """PerformanceMonitor should have quality_preset_changed signal."""
    has_signal = await game.call(PERFORMANCE_PATH, "has_signal", ["quality_preset_changed"])
    assert has_signal is True, "PerformanceMonitor should have quality_preset_changed signal"


@pytest.mark.asyncio
async def test_has_adaptive_mode_changed_signal(game):
    """PerformanceMonitor should have adaptive_mode_changed signal."""
    has_signal = await game.call(PERFORMANCE_PATH, "has_signal", ["adaptive_mode_changed"])
    assert has_signal is True, "PerformanceMonitor should have adaptive_mode_changed signal"


# =============================================================================
# QUALITY PRESET CONSISTENCY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_low_preset_has_smallest_chunk_radius(game):
    """LOW preset should have the smallest chunk radius."""
    # Save current preset
    original = await game.get_property(PERFORMANCE_PATH, "quality_preset")

    # Set to LOW and get chunk radius
    await game.call(PERFORMANCE_PATH, "set_quality_preset", [0])  # LOW
    low_radius = await game.call(PERFORMANCE_PATH, "get_chunk_radius")

    # Set to ULTRA and get chunk radius
    await game.call(PERFORMANCE_PATH, "set_quality_preset", [3])  # ULTRA
    ultra_radius = await game.call(PERFORMANCE_PATH, "get_chunk_radius")

    # Restore original
    await game.call(PERFORMANCE_PATH, "set_quality_preset", [original])

    assert low_radius <= ultra_radius, f"LOW radius ({low_radius}) should be <= ULTRA ({ultra_radius})"


@pytest.mark.asyncio
async def test_low_preset_has_smallest_sparkles(game):
    """LOW preset should have the fewest sparkles."""
    original = await game.get_property(PERFORMANCE_PATH, "quality_preset")

    await game.call(PERFORMANCE_PATH, "set_quality_preset", [0])
    low_sparkles = await game.call(PERFORMANCE_PATH, "get_max_sparkles")

    await game.call(PERFORMANCE_PATH, "set_quality_preset", [3])
    ultra_sparkles = await game.call(PERFORMANCE_PATH, "get_max_sparkles")

    await game.call(PERFORMANCE_PATH, "set_quality_preset", [original])

    assert low_sparkles <= ultra_sparkles, f"LOW sparkles ({low_sparkles}) should be <= ULTRA ({ultra_sparkles})"
