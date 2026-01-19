extends Node
## Platform detection utility for GoDig.
##
## Provides automatic detection of mobile vs desktop platforms and
## touch input capabilities. Use this to show/hide touch controls
## and adapt UI layouts.

signal platform_changed(is_mobile: bool)
signal touch_input_detected
signal keyboard_input_detected

## True if running on a mobile platform (Android, iOS, or web on mobile device)
var is_mobile_platform: bool = false

## True if touch input is currently being used
var is_using_touch: bool = false

## True if user has manually overridden the control scheme
var manual_override: bool = false
var manual_is_mobile: bool = false

# Track last input type for hybrid devices
var _last_input_was_touch: bool = false


func _ready() -> void:
	# Detect platform on startup
	is_mobile_platform = _detect_mobile_platform()
	is_using_touch = is_mobile_platform

	print("[PlatformDetector] Platform: %s" % ("Mobile" if is_mobile_platform else "Desktop"))
	print("[PlatformDetector] Touch controls: %s" % ("Enabled" if should_show_touch_controls() else "Disabled"))


func _input(event: InputEvent) -> void:
	if manual_override:
		return

	# Detect touch input
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if not _last_input_was_touch:
			_last_input_was_touch = true
			is_using_touch = true
			touch_input_detected.emit()
			platform_changed.emit(true)

	# Detect keyboard/mouse input
	elif event is InputEventKey or event is InputEventMouseButton:
		if _last_input_was_touch:
			_last_input_was_touch = false
			is_using_touch = false
			keyboard_input_detected.emit()
			platform_changed.emit(false)


## Returns true if touch controls should be shown.
## Takes into account platform detection, manual override, and current input type.
func should_show_touch_controls() -> bool:
	if manual_override:
		return manual_is_mobile
	return is_mobile_platform or is_using_touch


## Force touch controls on or off, overriding automatic detection.
## Call with null to restore automatic detection.
func set_manual_override(enable_touch: Variant) -> void:
	if enable_touch == null:
		manual_override = false
		is_using_touch = is_mobile_platform
		platform_changed.emit(is_mobile_platform)
	else:
		manual_override = true
		manual_is_mobile = enable_touch as bool
		platform_changed.emit(manual_is_mobile)


## Check if we're on a touchscreen device (mobile or touch-capable desktop)
func has_touchscreen() -> bool:
	return DisplayServer.is_touchscreen_available()


## Get the effective "mobile mode" state
func is_mobile_mode() -> bool:
	if manual_override:
		return manual_is_mobile
	return is_mobile_platform or is_using_touch


## Private: Detect if we're on a mobile platform
func _detect_mobile_platform() -> bool:
	var os_name := OS.get_name()

	# Direct mobile platforms
	if os_name in ["Android", "iOS"]:
		return true

	# Web platform - check for mobile browser
	if os_name == "Web":
		return _detect_mobile_browser()

	# Desktop platforms with touchscreen - default to desktop controls
	# but allow touch input to switch modes
	if os_name in ["Windows", "macOS", "Linux"]:
		# Could check for touchscreen here, but default to desktop
		# Touch input will auto-switch if used
		return false

	# Unknown platform - assume desktop
	return false


## Private: Detect mobile browser on Web platform
func _detect_mobile_browser() -> bool:
	# Check if touchscreen is available (most reliable for web)
	if DisplayServer.is_touchscreen_available():
		return true

	# Fallback: Check viewport size (mobile devices typically have smaller viewports)
	# This is a heuristic - portrait orientation with small width suggests mobile
	var viewport_size := DisplayServer.window_get_size()
	if viewport_size.x < 800 and viewport_size.y > viewport_size.x:
		return true

	return false
