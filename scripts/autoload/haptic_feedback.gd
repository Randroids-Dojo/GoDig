extends Node
## HapticFeedback autoload singleton for mobile vibration feedback.
##
## Provides tactile feedback on supported mobile devices for:
## - Mining impacts (light taps for hits, strong for block break)
## - Damage taken (sharp feedback)
## - Achievements (celebration pattern)
## - UI interactions (subtle feedback)
##
## Respects user settings and gracefully degrades on unsupported platforms.

signal haptic_triggered(intensity: float, duration: float)

## Haptic intensity presets
enum HapticType {
	LIGHT,       # UI interactions, subtle
	MEDIUM,      # Standard mining hits
	HEAVY,       # Block breaks, impacts
	SUCCESS,     # Achievements, purchases
	WARNING,     # Low health, danger
	ERROR,       # Failed actions
}

## Intensity values for each type (0.0 to 1.0)
const INTENSITY := {
	HapticType.LIGHT: 0.2,
	HapticType.MEDIUM: 0.5,
	HapticType.HEAVY: 0.8,
	HapticType.SUCCESS: 0.6,
	HapticType.WARNING: 0.7,
	HapticType.ERROR: 0.4,
}

## Duration in milliseconds for each type
const DURATION_MS := {
	HapticType.LIGHT: 10,
	HapticType.MEDIUM: 20,
	HapticType.HEAVY: 40,
	HapticType.SUCCESS: 30,
	HapticType.WARNING: 50,
	HapticType.ERROR: 15,
}

## Whether haptic feedback is enabled (respects user settings)
var enabled: bool = true

## Whether the platform supports haptic feedback
var _platform_supported: bool = false

## Cooldown to prevent haptic spam
var _cooldown_timer: float = 0.0
const MIN_INTERVAL: float = 0.03  # 30ms minimum between haptics


func _ready() -> void:
	# Check platform support
	_platform_supported = _check_platform_support()

	# Load user preference and connect to settings changes
	if SettingsManager:
		enabled = SettingsManager.haptics_enabled
		SettingsManager.haptics_changed.connect(_on_haptics_setting_changed)

	print("[HapticFeedback] Ready (supported: %s, enabled: %s)" % [_platform_supported, enabled])


func _on_haptics_setting_changed(new_enabled: bool) -> void:
	enabled = new_enabled
	print("[HapticFeedback] Setting changed: %s" % enabled)


func _process(delta: float) -> void:
	if _cooldown_timer > 0:
		_cooldown_timer -= delta


func _check_platform_support() -> bool:
	## Check if the current platform supports haptic feedback
	var os_name := OS.get_name()

	# Mobile platforms support vibration
	if os_name in ["Android", "iOS"]:
		return true

	# Web may support through Gamepad API (limited)
	if os_name == "Web":
		return false  # Web vibration is unreliable

	# Desktop platforms don't support haptic
	return false


## Trigger haptic feedback of the specified type
func trigger(type: HapticType) -> void:
	if not enabled or not _platform_supported:
		return

	if _cooldown_timer > 0:
		return  # Still in cooldown

	var intensity: float = INTENSITY.get(type, 0.5)
	var duration_ms: int = DURATION_MS.get(type, 20)

	_do_vibrate(intensity, duration_ms)
	_cooldown_timer = MIN_INTERVAL

	haptic_triggered.emit(intensity, float(duration_ms) / 1000.0)


## Trigger haptic with custom intensity and duration
func trigger_custom(intensity: float, duration_ms: int) -> void:
	if not enabled or not _platform_supported:
		return

	if _cooldown_timer > 0:
		return

	intensity = clampf(intensity, 0.0, 1.0)
	duration_ms = clampi(duration_ms, 1, 500)

	_do_vibrate(intensity, duration_ms)
	_cooldown_timer = MIN_INTERVAL

	haptic_triggered.emit(intensity, float(duration_ms) / 1000.0)


## Trigger a pattern of haptics (for achievements, etc.)
func trigger_pattern(pattern: Array) -> void:
	## Pattern is array of [duration_ms, pause_ms] pairs
	if not enabled or not _platform_supported:
		return

	# Simple implementation: just trigger the first pulse
	# A more advanced version would use a coroutine/timer
	if pattern.size() > 0:
		var first_pulse = pattern[0]
		if first_pulse is Array and first_pulse.size() >= 1:
			_do_vibrate(0.6, first_pulse[0])


func _do_vibrate(intensity: float, duration_ms: int) -> void:
	## Actually perform the vibration on supported platforms
	var os_name := OS.get_name()

	if os_name == "Android":
		# Android supports vibration through Input singleton
		# Note: Godot 4's Input.vibrate_handheld takes duration in seconds
		var duration_sec := float(duration_ms) / 1000.0
		Input.vibrate_handheld(int(duration_ms), intensity)
	elif os_name == "iOS":
		# iOS uses Input.vibrate_handheld as well
		Input.vibrate_handheld(int(duration_ms), intensity)


# ============================================
# CONVENIENCE METHODS FOR GAME EVENTS
# ============================================

## Called when player mines a block (light feedback per hit)
func on_mining_hit() -> void:
	trigger(HapticType.LIGHT)


## Called when a block is destroyed (satisfying feedback)
func on_block_destroyed() -> void:
	trigger(HapticType.HEAVY)


## Called when player takes damage
func on_damage_taken(amount: int) -> void:
	if amount >= 30:
		trigger(HapticType.HEAVY)
	elif amount >= 10:
		trigger(HapticType.MEDIUM)
	else:
		trigger(HapticType.LIGHT)


## Called when player collects an ore
func on_ore_collected() -> void:
	trigger(HapticType.LIGHT)


## Called when an achievement is unlocked
func on_achievement_unlocked() -> void:
	trigger(HapticType.SUCCESS)


## Called when player makes a purchase
func on_purchase() -> void:
	trigger(HapticType.SUCCESS)


## Called when player enters low health state
func on_low_health_warning() -> void:
	trigger(HapticType.WARNING)


## Called on UI button press
func on_ui_tap() -> void:
	trigger(HapticType.LIGHT)


## Called when an action fails (can't afford, blocked, etc.)
func on_action_failed() -> void:
	trigger(HapticType.ERROR)


## Called when player wall jumps
func on_wall_jump() -> void:
	trigger(HapticType.MEDIUM)


## Called when player lands after a fall
func on_land(fall_blocks: int) -> void:
	if fall_blocks >= 5:
		trigger(HapticType.HEAVY)
	elif fall_blocks >= 3:
		trigger(HapticType.MEDIUM)


## Called when player enters a new underground layer
func on_layer_entered() -> void:
	trigger(HapticType.MEDIUM)


## Called when player picks up a valuable item (gems, rare ores)
func on_rare_pickup() -> void:
	trigger(HapticType.SUCCESS)


## Called when player's inventory becomes full
func on_inventory_full() -> void:
	trigger(HapticType.WARNING)


## Called when player reaches a depth milestone
func on_milestone_reached() -> void:
	trigger(HapticType.SUCCESS)


## Called when player enters a shop or building
func on_building_enter() -> void:
	trigger(HapticType.LIGHT)


## Called when player sells items
func on_sell() -> void:
	trigger(HapticType.SUCCESS)


# ============================================
# SETTINGS INTEGRATION
# ============================================

## Enable or disable haptic feedback
func set_enabled(value: bool) -> void:
	enabled = value
	print("[HapticFeedback] Enabled: %s" % enabled)


## Check if haptic feedback is available on this device
func is_available() -> bool:
	return _platform_supported


## Check if haptic feedback is currently enabled
func is_enabled() -> bool:
	return enabled and _platform_supported
