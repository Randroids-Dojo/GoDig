extends Node
## DayNightManager - Tracks day/night cycle for surface area.
##
## Provides time-of-day effects including lighting changes at the surface,
## potential shop price variations, and atmosphere. Underground areas are
## not affected by the day/night cycle.

signal time_changed(hour: int, phase: String)
signal phase_changed(new_phase: String, old_phase: String)
signal new_day_started(day_count: int)

## Time phases
enum TimePhase { DAWN, DAY, DUSK, NIGHT }

## Current time (0.0 - 24.0 representing hours)
var current_time: float = 8.0  # Start at 8 AM

## Current day count
var day_count: int = 1

## Time multiplier (1.0 = real time, 60.0 = 1 game hour per real minute)
var time_scale: float = 60.0  # 1 game hour = 1 real minute

## Whether time is paused
var time_paused: bool = false

## Current phase
var current_phase: TimePhase = TimePhase.DAY

## Phase definitions (start hour)
const PHASE_TIMES := {
	TimePhase.DAWN: 5.0,   # 5 AM
	TimePhase.DAY: 7.0,    # 7 AM
	TimePhase.DUSK: 18.0,  # 6 PM
	TimePhase.NIGHT: 20.0, # 8 PM
}

## Surface lighting tints for each phase
const PHASE_LIGHTING := {
	TimePhase.DAWN: {"ambient": 0.7, "tint": Color(1.0, 0.85, 0.7)},    # Warm orange sunrise
	TimePhase.DAY: {"ambient": 1.0, "tint": Color.WHITE},               # Full daylight
	TimePhase.DUSK: {"ambient": 0.7, "tint": Color(1.0, 0.75, 0.6)},    # Orange sunset
	TimePhase.NIGHT: {"ambient": 0.4, "tint": Color(0.7, 0.75, 0.95)},  # Blue moonlight
}

## Shop price multipliers by phase (night = premium for emergency supplies)
const SHOP_PRICE_MULTIPLIERS := {
	TimePhase.DAWN: 1.0,
	TimePhase.DAY: 1.0,
	TimePhase.DUSK: 1.0,
	TimePhase.NIGHT: 1.15,  # 15% markup at night
}


func _ready() -> void:
	# Determine initial phase
	_update_phase()
	print("[DayNightManager] Ready - Time: %.1f, Phase: %s" % [current_time, get_phase_name()])


func _process(delta: float) -> void:
	if time_paused:
		return

	# Only advance time when game is actively playing
	if GameManager and GameManager.state != GameManager.GameState.PLAYING:
		return

	# Advance time
	var previous_hour := int(current_time)
	current_time += (delta / 3600.0) * time_scale  # Convert seconds to hours

	# Handle day rollover
	if current_time >= 24.0:
		current_time -= 24.0
		day_count += 1
		new_day_started.emit(day_count)
		print("[DayNightManager] New day: %d" % day_count)

	# Emit hourly updates
	var current_hour := int(current_time)
	if current_hour != previous_hour:
		time_changed.emit(current_hour, get_phase_name())

	# Update phase
	_update_phase()


## Update the current phase based on time
func _update_phase() -> void:
	var old_phase := current_phase

	if current_time >= PHASE_TIMES[TimePhase.NIGHT] or current_time < PHASE_TIMES[TimePhase.DAWN]:
		current_phase = TimePhase.NIGHT
	elif current_time >= PHASE_TIMES[TimePhase.DUSK]:
		current_phase = TimePhase.DUSK
	elif current_time >= PHASE_TIMES[TimePhase.DAY]:
		current_phase = TimePhase.DAY
	else:
		current_phase = TimePhase.DAWN

	if current_phase != old_phase:
		phase_changed.emit(get_phase_name(), _get_phase_name_from_enum(old_phase))
		print("[DayNightManager] Phase changed: %s -> %s" % [
			_get_phase_name_from_enum(old_phase),
			get_phase_name()
		])


## Get the current phase name
func get_phase_name() -> String:
	return _get_phase_name_from_enum(current_phase)


func _get_phase_name_from_enum(phase: TimePhase) -> String:
	match phase:
		TimePhase.DAWN: return "Dawn"
		TimePhase.DAY: return "Day"
		TimePhase.DUSK: return "Dusk"
		TimePhase.NIGHT: return "Night"
	return "Unknown"


## Get current hour (0-23)
func get_hour() -> int:
	return int(current_time)


## Get formatted time string (e.g., "8:30 AM")
func get_time_string() -> String:
	var hour := int(current_time)
	var minute := int((current_time - hour) * 60)
	var period := "AM" if hour < 12 else "PM"
	var display_hour := hour % 12
	if display_hour == 0:
		display_hour = 12
	return "%d:%02d %s" % [display_hour, minute, period]


## Get surface lighting data for current time
func get_surface_lighting() -> Dictionary:
	# Interpolate between phases for smooth transitions
	var lighting: Dictionary = PHASE_LIGHTING[current_phase].duplicate()

	# Calculate transition progress
	var next_phase := _get_next_phase()
	var phase_start: float = PHASE_TIMES[current_phase]
	var phase_end: float = PHASE_TIMES[next_phase]

	# Handle night wrapping
	if phase_end < phase_start:
		phase_end += 24.0
	var adjusted_time := current_time
	if current_time < phase_start:
		adjusted_time += 24.0

	var phase_duration: float = phase_end - phase_start
	var progress: float = (adjusted_time - phase_start) / phase_duration
	progress = clampf(progress, 0.0, 1.0)

	# Smooth transition in the last 20% of each phase
	if progress > 0.8:
		var transition_progress: float = (progress - 0.8) / 0.2
		var next_lighting: Dictionary = PHASE_LIGHTING[next_phase]
		lighting["ambient"] = lerpf(lighting["ambient"], next_lighting["ambient"], transition_progress)
		lighting["tint"] = lighting["tint"].lerp(next_lighting["tint"], transition_progress)

	return lighting


func _get_next_phase() -> TimePhase:
	match current_phase:
		TimePhase.DAWN: return TimePhase.DAY
		TimePhase.DAY: return TimePhase.DUSK
		TimePhase.DUSK: return TimePhase.NIGHT
		TimePhase.NIGHT: return TimePhase.DAWN
	return TimePhase.DAY


## Get current shop price multiplier
func get_shop_price_multiplier() -> float:
	return SHOP_PRICE_MULTIPLIERS[current_phase]


## Check if it's currently nighttime
func is_night() -> bool:
	return current_phase == TimePhase.NIGHT


## Check if it's daytime (day or dawn/dusk)
func is_daytime() -> bool:
	return current_phase == TimePhase.DAY


## Pause time advancement
func pause_time() -> void:
	time_paused = true


## Resume time advancement
func resume_time() -> void:
	time_paused = false


## Set time directly (0.0 - 24.0)
func set_time(hour: float) -> void:
	current_time = fmod(hour, 24.0)
	if current_time < 0:
		current_time += 24.0
	_update_phase()


## Skip to next phase
func skip_to_next_phase() -> void:
	var next_phase := _get_next_phase()
	current_time = PHASE_TIMES[next_phase]
	_update_phase()


## Get day count
func get_day_count() -> int:
	return day_count


# ============================================
# SAVE/LOAD
# ============================================

## Get save data
func get_save_data() -> Dictionary:
	return {
		"current_time": current_time,
		"day_count": day_count,
	}


## Load from save data
func load_save_data(data: Dictionary) -> void:
	current_time = data.get("current_time", 8.0)
	day_count = data.get("day_count", 1)
	_update_phase()
	print("[DayNightManager] Loaded - Time: %.1f, Day: %d, Phase: %s" % [
		current_time, day_count, get_phase_name()
	])


## Reset for new game
func reset() -> void:
	current_time = 8.0
	day_count = 1
	time_paused = false
	_update_phase()
