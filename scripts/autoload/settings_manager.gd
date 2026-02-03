extends Node
## GoDig Settings Manager
##
## Central settings manager for game options, accessibility preferences,
## and audio settings. Persists settings to disk and emits signals when
## settings change so UI can react.

# ============================================
# SIGNALS
# ============================================

signal text_size_changed(scale: float)
signal colorblind_mode_changed(mode: int)
signal hand_mode_changed(mode: int)
signal haptics_changed(enabled: bool)
signal reduced_motion_changed(enabled: bool)
signal audio_changed()
signal settings_loaded()
signal settings_reset()
signal screen_shake_changed(intensity: float)
signal auto_sell_changed(enabled: bool)
signal tension_audio_changed(enabled: bool)
signal juice_level_changed(level: int)

# ============================================
# ENUMS
# ============================================

enum ColorblindMode { OFF, SYMBOLS, HIGH_CONTRAST }
enum HandMode { STANDARD, LEFT_HAND, RIGHT_HAND }
## Juice level affects particle amounts, screen shake intensity, and visual feedback
## Research (N=3018) shows Medium/High is optimal - both None and Extreme decrease play time
enum JuiceLevel { OFF, LOW, MEDIUM, HIGH }

# ============================================
# CONSTANTS
# ============================================

const SETTINGS_PATH := "user://settings.cfg"
const TEXT_SCALES := [0.85, 1.0, 1.25, 1.5, 2.0]

## Debounce delay for saving (seconds)
const SAVE_DEBOUNCE := 0.5

# ============================================
# SETTINGS VALUES
# ============================================

## Accessibility: Text size level (index into TEXT_SCALES)
var text_size_level: int = 1:
	set(value):
		text_size_level = clampi(value, 0, TEXT_SCALES.size() - 1)
		text_size_changed.emit(get_text_scale())
		_queue_save()

## Accessibility: Colorblind mode
var colorblind_mode: ColorblindMode = ColorblindMode.OFF:
	set(value):
		colorblind_mode = value
		colorblind_mode_changed.emit(value)
		_queue_save()

## Accessibility: Hand preference for controls
var hand_mode: HandMode = HandMode.STANDARD:
	set(value):
		hand_mode = value
		hand_mode_changed.emit(value)
		_queue_save()

## Accessibility: Haptic feedback enabled
var haptics_enabled: bool = true:
	set(value):
		haptics_enabled = value
		haptics_changed.emit(value)
		_queue_save()

## Accessibility: Reduced motion mode
var reduced_motion: bool = false:
	set(value):
		reduced_motion = value
		reduced_motion_changed.emit(value)
		_queue_save()

## Accessibility: Screen shake intensity (0.0 - 1.0, 0 = off)
var screen_shake_intensity: float = 1.0:
	set(value):
		screen_shake_intensity = clampf(value, 0.0, 1.0)
		screen_shake_changed.emit(screen_shake_intensity)
		_queue_save()

## Visual Effects: Juice level (particle amounts, effects intensity)
## Research (N=3018) shows Medium/High is optimal - default to MEDIUM
var juice_level: JuiceLevel = JuiceLevel.MEDIUM:
	set(value):
		juice_level = value
		juice_level_changed.emit(value)
		_queue_save()

## Gameplay: Auto-sell ores on pickup when inventory full
var auto_sell_enabled: bool = false:
	set(value):
		auto_sell_enabled = value
		auto_sell_changed.emit(value)
		_queue_save()

## Audio: Master volume (0.0 - 1.0)
var master_volume: float = 1.0:
	set(value):
		master_volume = clampf(value, 0.0, 1.0)
		_apply_audio_volumes()
		audio_changed.emit()
		_queue_save()

## Audio: Sound effects volume (0.0 - 1.0)
var sfx_volume: float = 1.0:
	set(value):
		sfx_volume = clampf(value, 0.0, 1.0)
		_apply_audio_volumes()
		audio_changed.emit()
		_queue_save()

## Audio: Music volume (0.0 - 1.0)
var music_volume: float = 1.0:
	set(value):
		music_volume = clampf(value, 0.0, 1.0)
		_apply_audio_volumes()
		audio_changed.emit()
		_queue_save()

## Audio: Tension audio enabled (ambient audio that shifts based on risk factors)
var tension_audio_enabled: bool = true:
	set(value):
		tension_audio_enabled = value
		tension_audio_changed.emit(value)
		_queue_save()

# ============================================
# CONTROL SETTINGS
# ============================================

signal swipe_controls_changed(enabled: bool)
signal joystick_deadzone_changed(deadzone: float)
signal button_size_changed(scale: float)
signal tap_to_dig_changed(enabled: bool)

## Controls: Swipe gesture controls enabled
var swipe_controls_enabled: bool = false:
	set(value):
		swipe_controls_enabled = value
		swipe_controls_changed.emit(value)
		_queue_save()

## Controls: Virtual joystick deadzone (0.0 - 0.5)
var joystick_deadzone: float = 0.2:
	set(value):
		joystick_deadzone = clampf(value, 0.0, 0.5)
		joystick_deadzone_changed.emit(joystick_deadzone)
		_queue_save()

## Controls: Button size scale (0.75 - 1.5)
var button_size_scale: float = 1.0:
	set(value):
		button_size_scale = clampf(value, 0.75, 1.5)
		button_size_changed.emit(button_size_scale)
		_queue_save()

## Controls: Tap-to-dig enabled
var tap_to_dig_enabled: bool = true:
	set(value):
		tap_to_dig_enabled = value
		tap_to_dig_changed.emit(value)
		_queue_save()

# ============================================
# INTERNAL STATE
# ============================================

var _save_timer: Timer = null
var _save_pending: bool = false
var _loading: bool = false  # Prevent saves during load


func _ready() -> void:
	_setup_save_timer()
	_load_settings()
	print("[SettingsManager] Ready")


# ============================================
# PUBLIC API
# ============================================

## Get the current text scale multiplier
func get_text_scale() -> float:
	return TEXT_SCALES[text_size_level]


## Get available text scale options
func get_text_scale_options() -> Array:
	return TEXT_SCALES.duplicate()


## Get particle multiplier based on juice level
## Returns 0.0 for OFF, 0.5 for LOW, 1.0 for MEDIUM (default), 1.5 for HIGH
func get_particle_multiplier() -> float:
	match juice_level:
		JuiceLevel.OFF:
			return 0.0
		JuiceLevel.LOW:
			return 0.5
		JuiceLevel.MEDIUM:
			return 1.0
		JuiceLevel.HIGH:
			return 1.5
		_:
			return 1.0


## Get shake multiplier based on juice level (screen shake is scaled by this)
## Returns 0.0 for OFF, 0.5 for LOW, 1.0 for MEDIUM, 1.3 for HIGH
func get_shake_multiplier() -> float:
	match juice_level:
		JuiceLevel.OFF:
			return 0.0
		JuiceLevel.LOW:
			return 0.5
		JuiceLevel.MEDIUM:
			return 1.0
		JuiceLevel.HIGH:
			return 1.3
		_:
			return 1.0


## Reset all settings to defaults
func reset_to_defaults() -> void:
	_loading = true  # Prevent intermediate saves
	text_size_level = 1
	colorblind_mode = ColorblindMode.OFF
	hand_mode = HandMode.STANDARD
	haptics_enabled = true
	reduced_motion = false
	screen_shake_intensity = 1.0
	juice_level = JuiceLevel.MEDIUM  # Research shows Medium is optimal
	auto_sell_enabled = false
	master_volume = 1.0
	sfx_volume = 1.0
	music_volume = 1.0
	tension_audio_enabled = true
	swipe_controls_enabled = false
	joystick_deadzone = 0.2
	button_size_scale = 1.0
	tap_to_dig_enabled = true
	_loading = false
	_save_settings()
	settings_reset.emit()
	print("[SettingsManager] Settings reset to defaults")


## Force an immediate save (bypasses debounce)
func save_now() -> void:
	_save_settings()


# ============================================
# SAVE / LOAD
# ============================================

func _setup_save_timer() -> void:
	_save_timer = Timer.new()
	_save_timer.wait_time = SAVE_DEBOUNCE
	_save_timer.one_shot = true
	_save_timer.timeout.connect(_on_save_timer_timeout)
	add_child(_save_timer)


## Queue a save (with debounce to avoid excessive file writes)
func _queue_save() -> void:
	if _loading:
		return
	_save_pending = true
	if _save_timer:
		_save_timer.start()


func _on_save_timer_timeout() -> void:
	if _save_pending:
		_save_settings()


func _save_settings() -> void:
	_save_pending = false

	var config := ConfigFile.new()

	# Accessibility settings
	config.set_value("accessibility", "text_size_level", text_size_level)
	config.set_value("accessibility", "colorblind_mode", colorblind_mode)
	config.set_value("accessibility", "hand_mode", hand_mode)
	config.set_value("accessibility", "haptics_enabled", haptics_enabled)
	config.set_value("accessibility", "reduced_motion", reduced_motion)
	config.set_value("accessibility", "screen_shake_intensity", screen_shake_intensity)
	config.set_value("accessibility", "juice_level", juice_level)

	# Gameplay settings
	config.set_value("gameplay", "auto_sell_enabled", auto_sell_enabled)

	# Audio settings
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "tension_audio_enabled", tension_audio_enabled)

	# Control settings
	config.set_value("controls", "swipe_controls_enabled", swipe_controls_enabled)
	config.set_value("controls", "joystick_deadzone", joystick_deadzone)
	config.set_value("controls", "button_size_scale", button_size_scale)
	config.set_value("controls", "tap_to_dig_enabled", tap_to_dig_enabled)

	var error := config.save(SETTINGS_PATH)
	if error != OK:
		push_error("[SettingsManager] Failed to save settings: %s" % error_string(error))
	else:
		print("[SettingsManager] Settings saved")


func _load_settings() -> void:
	_loading = true

	var config := ConfigFile.new()
	var error := config.load(SETTINGS_PATH)

	if error != OK:
		if error == ERR_FILE_NOT_FOUND:
			print("[SettingsManager] No settings file found, using defaults")
		else:
			push_warning("[SettingsManager] Failed to load settings: %s, using defaults" % error_string(error))
		_loading = false
		settings_loaded.emit()
		return

	# Load accessibility settings with validation
	text_size_level = _validate_int(
		config.get_value("accessibility", "text_size_level", 1),
		0, TEXT_SCALES.size() - 1, 1
	)

	colorblind_mode = _validate_enum(
		config.get_value("accessibility", "colorblind_mode", ColorblindMode.OFF),
		ColorblindMode.values(),
		ColorblindMode.OFF
	) as ColorblindMode

	hand_mode = _validate_enum(
		config.get_value("accessibility", "hand_mode", HandMode.STANDARD),
		HandMode.values(),
		HandMode.STANDARD
	) as HandMode

	haptics_enabled = _validate_bool(
		config.get_value("accessibility", "haptics_enabled", true),
		true
	)

	reduced_motion = _validate_bool(
		config.get_value("accessibility", "reduced_motion", false),
		false
	)

	screen_shake_intensity = _validate_float(
		config.get_value("accessibility", "screen_shake_intensity", 1.0),
		0.0, 1.0, 1.0
	)

	juice_level = _validate_enum(
		config.get_value("accessibility", "juice_level", JuiceLevel.MEDIUM),
		JuiceLevel.values(),
		JuiceLevel.MEDIUM
	) as JuiceLevel

	# Load gameplay settings
	auto_sell_enabled = _validate_bool(
		config.get_value("gameplay", "auto_sell_enabled", false),
		false
	)

	# Load audio settings with validation
	master_volume = _validate_float(
		config.get_value("audio", "master_volume", 1.0),
		0.0, 1.0, 1.0
	)

	sfx_volume = _validate_float(
		config.get_value("audio", "sfx_volume", 1.0),
		0.0, 1.0, 1.0
	)

	music_volume = _validate_float(
		config.get_value("audio", "music_volume", 1.0),
		0.0, 1.0, 1.0
	)

	tension_audio_enabled = _validate_bool(
		config.get_value("audio", "tension_audio_enabled", true),
		true
	)

	# Load control settings
	swipe_controls_enabled = _validate_bool(
		config.get_value("controls", "swipe_controls_enabled", false),
		false
	)

	joystick_deadzone = _validate_float(
		config.get_value("controls", "joystick_deadzone", 0.2),
		0.0, 0.5, 0.2
	)

	button_size_scale = _validate_float(
		config.get_value("controls", "button_size_scale", 1.0),
		0.75, 1.5, 1.0
	)

	tap_to_dig_enabled = _validate_bool(
		config.get_value("controls", "tap_to_dig_enabled", true),
		true
	)

	_loading = false
	_apply_audio_volumes()
	settings_loaded.emit()
	print("[SettingsManager] Settings loaded")


# ============================================
# VALIDATION HELPERS
# ============================================

func _validate_int(value: Variant, min_val: int, max_val: int, default: int) -> int:
	if value is int:
		return clampi(value, min_val, max_val)
	return default


func _validate_float(value: Variant, min_val: float, max_val: float, default: float) -> float:
	if value is float or value is int:
		return clampf(float(value), min_val, max_val)
	return default


func _validate_bool(value: Variant, default: bool) -> bool:
	if value is bool:
		return value
	return default


func _validate_enum(value: Variant, valid_values: Array, default: int) -> int:
	if value is int and value in valid_values:
		return value
	return default


# ============================================
# AUDIO BUS INTEGRATION
# ============================================

func _apply_audio_volumes() -> void:
	# Apply volumes to audio buses if they exist
	var master_idx := AudioServer.get_bus_index("Master")
	if master_idx >= 0:
		AudioServer.set_bus_volume_db(master_idx, linear_to_db(master_volume))

	var sfx_idx := AudioServer.get_bus_index("SFX")
	if sfx_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(sfx_volume))

	var music_idx := AudioServer.get_bus_index("Music")
	if music_idx >= 0:
		AudioServer.set_bus_volume_db(music_idx, linear_to_db(music_volume))
