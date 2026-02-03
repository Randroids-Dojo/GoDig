extends Node
## GoDig Mobile Performance Monitor
##
## Tracks performance metrics for mobile optimization:
## - FPS monitoring and frame time analysis
## - Memory usage tracking
## - Chunk loading performance
## - Particle system performance
## - Battery-aware quality adjustments (mobile)
##
## Provides configurable quality presets and adaptive performance scaling.

# ============================================
# SIGNALS
# ============================================

signal fps_updated(fps: int, delta_ms: float)
signal memory_updated(static_mb: float, dynamic_mb: float)
signal performance_warning(message: String, severity: int)
signal quality_preset_changed(preset: int)
signal adaptive_mode_changed(enabled: bool)

# ============================================
# ENUMS
# ============================================

## Quality presets for different device capabilities
enum QualityPreset { LOW, MEDIUM, HIGH, ULTRA }

## Warning severity levels
enum WarningSeverity { INFO, WARNING, CRITICAL }

# ============================================
# CONSTANTS
# ============================================

## FPS thresholds for warnings
const FPS_TARGET := 60
const FPS_WARNING := 45
const FPS_CRITICAL := 30

## Memory warning thresholds (MB)
const MEMORY_WARNING_MB := 256.0
const MEMORY_CRITICAL_MB := 384.0

## Frame time spike threshold (ms) - frames taking longer than this are logged
const FRAME_SPIKE_MS := 33.3  # 30 FPS equivalent

## Chunk loading distance presets (in chunks)
const CHUNK_RADIUS_BY_PRESET := {
	QualityPreset.LOW: 1,
	QualityPreset.MEDIUM: 2,
	QualityPreset.HIGH: 2,
	QualityPreset.ULTRA: 3,
}

## Max sparkle count by preset
const MAX_SPARKLES_BY_PRESET := {
	QualityPreset.LOW: 100,
	QualityPreset.MEDIUM: 200,
	QualityPreset.HIGH: 300,
	QualityPreset.ULTRA: 500,
}

## Particle multiplier by preset
const PARTICLE_MULT_BY_PRESET := {
	QualityPreset.LOW: 0.5,
	QualityPreset.MEDIUM: 0.75,
	QualityPreset.HIGH: 1.0,
	QualityPreset.ULTRA: 1.5,
}

## Sample window for averaging
const FPS_SAMPLE_WINDOW := 60
const MEMORY_SAMPLE_INTERVAL := 1.0  # Check memory every second

# ============================================
# STATE
# ============================================

## Current quality preset
var quality_preset: QualityPreset = QualityPreset.MEDIUM:
	set(value):
		if value != quality_preset:
			quality_preset = value
			_apply_quality_preset()
			quality_preset_changed.emit(value)

## Adaptive performance mode - automatically adjusts quality based on FPS
var adaptive_mode: bool = false:
	set(value):
		if value != adaptive_mode:
			adaptive_mode = value
			adaptive_mode_changed.emit(value)

## Whether to show debug overlay
var show_overlay: bool = false

## Current metrics
var current_fps: int = 60
var current_frame_time_ms: float = 16.67
var average_fps: float = 60.0
var min_fps: int = 60
var max_fps: int = 60
var frame_spikes: int = 0  # Count of frame spikes this session

## Memory metrics
var static_memory_mb: float = 0.0
var dynamic_memory_mb: float = 0.0
var peak_memory_mb: float = 0.0

## Chunk loading metrics
var chunks_loaded: int = 0
var chunks_pending: int = 0
var chunk_load_time_avg_ms: float = 0.0

## Particle metrics
var active_sparkles: int = 0
var particle_draw_calls: int = 0

## Internal tracking
var _fps_samples: Array[int] = []
var _frame_times: Array[float] = []
var _memory_timer: float = 0.0
var _adaptive_check_timer: float = 0.0
var _session_start_time: int = 0

# ============================================
# LIFECYCLE
# ============================================

func _ready() -> void:
	_session_start_time = Time.get_ticks_msec()
	_detect_initial_preset()
	print("[PerformanceMonitor] Ready - Preset: %s" % QualityPreset.keys()[quality_preset])


func _process(delta: float) -> void:
	_update_fps_metrics(delta)
	_update_memory_metrics(delta)

	if adaptive_mode:
		_check_adaptive_adjustment(delta)


# ============================================
# FPS TRACKING
# ============================================

func _update_fps_metrics(delta: float) -> void:
	## Update FPS and frame time metrics
	var frame_time_ms := delta * 1000.0
	current_frame_time_ms = frame_time_ms
	current_fps = int(1.0 / delta) if delta > 0 else 0

	# Track frame spikes
	if frame_time_ms > FRAME_SPIKE_MS:
		frame_spikes += 1
		if frame_spikes % 100 == 0:
			performance_warning.emit(
				"Frame spike detected: %.1fms (count: %d)" % [frame_time_ms, frame_spikes],
				WarningSeverity.INFO
			)

	# Update samples for averaging
	_fps_samples.append(current_fps)
	_frame_times.append(frame_time_ms)

	if _fps_samples.size() > FPS_SAMPLE_WINDOW:
		_fps_samples.remove_at(0)
		_frame_times.remove_at(0)

	# Calculate averages
	if _fps_samples.size() > 0:
		var sum := 0
		for fps in _fps_samples:
			sum += fps
		average_fps = float(sum) / _fps_samples.size()

		min_fps = 999
		max_fps = 0
		for fps in _fps_samples:
			if fps < min_fps:
				min_fps = fps
			if fps > max_fps:
				max_fps = fps

	# Emit update signal
	fps_updated.emit(current_fps, current_frame_time_ms)

	# Check for warnings
	if average_fps < FPS_CRITICAL:
		performance_warning.emit(
			"Critical FPS: %.1f" % average_fps,
			WarningSeverity.CRITICAL
		)
	elif average_fps < FPS_WARNING:
		performance_warning.emit(
			"Low FPS: %.1f" % average_fps,
			WarningSeverity.WARNING
		)


# ============================================
# MEMORY TRACKING
# ============================================

func _update_memory_metrics(delta: float) -> void:
	## Update memory usage metrics periodically
	_memory_timer += delta
	if _memory_timer < MEMORY_SAMPLE_INTERVAL:
		return
	_memory_timer = 0.0

	# Get memory stats from Performance singleton
	static_memory_mb = Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0
	dynamic_memory_mb = Performance.get_monitor(Performance.MEMORY_MESSAGE_BUFFER_MAX) / 1048576.0

	var total_mb := static_memory_mb + dynamic_memory_mb
	if total_mb > peak_memory_mb:
		peak_memory_mb = total_mb

	memory_updated.emit(static_memory_mb, dynamic_memory_mb)

	# Check for memory warnings
	if total_mb > MEMORY_CRITICAL_MB:
		performance_warning.emit(
			"Critical memory usage: %.1f MB" % total_mb,
			WarningSeverity.CRITICAL
		)
	elif total_mb > MEMORY_WARNING_MB:
		performance_warning.emit(
			"High memory usage: %.1f MB" % total_mb,
			WarningSeverity.WARNING
		)


# ============================================
# ADAPTIVE PERFORMANCE
# ============================================

func _check_adaptive_adjustment(delta: float) -> void:
	## Check if quality preset should be adjusted based on performance
	_adaptive_check_timer += delta
	if _adaptive_check_timer < 5.0:  # Check every 5 seconds
		return
	_adaptive_check_timer = 0.0

	# Need enough samples
	if _fps_samples.size() < FPS_SAMPLE_WINDOW / 2:
		return

	# Downgrade if consistently low FPS
	if average_fps < FPS_WARNING and quality_preset > QualityPreset.LOW:
		var new_preset := quality_preset - 1 as QualityPreset
		print("[PerformanceMonitor] Adaptive: Downgrading to %s (avg FPS: %.1f)" % [
			QualityPreset.keys()[new_preset], average_fps
		])
		quality_preset = new_preset
		_fps_samples.clear()  # Reset samples after change
		return

	# Upgrade if consistently high FPS and not at max
	if average_fps > FPS_TARGET + 5 and min_fps > FPS_TARGET and quality_preset < QualityPreset.ULTRA:
		var new_preset := quality_preset + 1 as QualityPreset
		print("[PerformanceMonitor] Adaptive: Upgrading to %s (avg FPS: %.1f)" % [
			QualityPreset.keys()[new_preset], average_fps
		])
		quality_preset = new_preset
		_fps_samples.clear()


# ============================================
# QUALITY PRESET APPLICATION
# ============================================

func _detect_initial_preset() -> void:
	## Detect appropriate initial quality preset based on device
	if OS.has_feature("mobile"):
		# Mobile defaults to MEDIUM, can be adjusted
		quality_preset = QualityPreset.MEDIUM
		adaptive_mode = true  # Enable adaptive on mobile by default
	elif OS.has_feature("web"):
		# Web defaults to LOW for broader compatibility
		quality_preset = QualityPreset.LOW
	else:
		# Desktop defaults to HIGH
		quality_preset = QualityPreset.HIGH


func _apply_quality_preset() -> void:
	## Apply the current quality preset to game systems

	# Note: DirtGrid reads LOAD_RADIUS directly, so we provide a method
	# to query the optimal radius. Systems should call get_chunk_radius()
	# when generating chunks.

	# Particle multiplier is handled through SettingsManager
	# But we can adjust the base values here

	print("[PerformanceMonitor] Applied preset: %s" % QualityPreset.keys()[quality_preset])
	print("  - Chunk radius: %d" % get_chunk_radius())
	print("  - Max sparkles: %d" % get_max_sparkles())
	print("  - Particle mult: %.2f" % get_particle_multiplier())


# ============================================
# PUBLIC API
# ============================================

## Get recommended chunk loading radius for current preset
func get_chunk_radius() -> int:
	return CHUNK_RADIUS_BY_PRESET.get(quality_preset, 2)


## Get recommended max sparkles for current preset
func get_max_sparkles() -> int:
	return MAX_SPARKLES_BY_PRESET.get(quality_preset, 200)


## Get particle multiplier for current preset
func get_particle_multiplier() -> float:
	return PARTICLE_MULT_BY_PRESET.get(quality_preset, 1.0)


## Get current performance stats as a dictionary
func get_stats() -> Dictionary:
	return {
		"fps": current_fps,
		"fps_avg": average_fps,
		"fps_min": min_fps,
		"fps_max": max_fps,
		"frame_time_ms": current_frame_time_ms,
		"frame_spikes": frame_spikes,
		"memory_static_mb": static_memory_mb,
		"memory_dynamic_mb": dynamic_memory_mb,
		"memory_peak_mb": peak_memory_mb,
		"chunks_loaded": chunks_loaded,
		"chunks_pending": chunks_pending,
		"active_sparkles": active_sparkles,
		"quality_preset": QualityPreset.keys()[quality_preset],
		"adaptive_mode": adaptive_mode,
		"session_duration_s": (Time.get_ticks_msec() - _session_start_time) / 1000.0,
	}


## Get formatted stats string for debug display
func get_stats_string() -> String:
	var stats := get_stats()
	return """FPS: %d (avg: %.1f, min: %d, max: %d)
Frame: %.2fms | Spikes: %d
Memory: %.1f MB (peak: %.1f MB)
Chunks: %d loaded, %d pending
Sparkles: %d active
Preset: %s | Adaptive: %s
Session: %.0fs""" % [
		stats["fps"],
		stats["fps_avg"],
		stats["fps_min"],
		stats["fps_max"],
		stats["frame_time_ms"],
		stats["frame_spikes"],
		stats["memory_static_mb"],
		stats["memory_peak_mb"],
		stats["chunks_loaded"],
		stats["chunks_pending"],
		stats["active_sparkles"],
		stats["quality_preset"],
		"ON" if stats["adaptive_mode"] else "OFF",
		stats["session_duration_s"],
	]


## Update chunk metrics (called by DirtGrid)
func update_chunk_metrics(loaded: int, pending: int) -> void:
	chunks_loaded = loaded
	chunks_pending = pending


## Update sparkle metrics (called by OreSparkleManager)
func update_sparkle_metrics(active: int) -> void:
	active_sparkles = active


## Force a specific quality preset (for testing)
func set_quality_preset(preset: QualityPreset) -> void:
	quality_preset = preset


## Get preset by name (for settings UI)
func get_preset_by_name(preset_name: String) -> QualityPreset:
	match preset_name.to_upper():
		"LOW": return QualityPreset.LOW
		"MEDIUM": return QualityPreset.MEDIUM
		"HIGH": return QualityPreset.HIGH
		"ULTRA": return QualityPreset.ULTRA
		_: return QualityPreset.MEDIUM


## Check if running on a low-end device (heuristic)
func is_low_end_device() -> bool:
	if OS.has_feature("web"):
		return true  # Assume web is constrained
	if average_fps < FPS_WARNING and _fps_samples.size() >= FPS_SAMPLE_WINDOW / 2:
		return true
	return false


## Get battery level (mobile only, returns -1.0 on desktop)
func get_battery_level() -> float:
	if OS.has_feature("mobile"):
		# Note: Godot 4 doesn't have direct battery API
		# This would need platform-specific implementation
		# For now, return -1 to indicate unavailable
		return -1.0
	return -1.0


## Check if device is on battery power (mobile only)
func is_on_battery() -> bool:
	if OS.has_feature("mobile"):
		# Would need platform-specific implementation
		return true  # Assume mobile is always on battery
	return false
