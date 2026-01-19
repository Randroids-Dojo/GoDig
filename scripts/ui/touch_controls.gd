extends Control
## Touch controls UI for mobile devices.
## Provides on-screen buttons for directional movement and jump.
## Automatically shows/hides based on platform detection.

signal direction_pressed(direction: Vector2i)
signal direction_released()
signal jump_pressed()

var current_direction: Vector2i = Vector2i.ZERO

## If true, ignore platform detection and always show controls
@export var force_visible: bool = false


func _ready() -> void:
	# Connect button signals
	$LeftButton.button_down.connect(_on_left_pressed)
	$LeftButton.button_up.connect(_on_button_released)
	$RightButton.button_down.connect(_on_right_pressed)
	$RightButton.button_up.connect(_on_button_released)
	$DownButton.button_down.connect(_on_down_pressed)
	$DownButton.button_up.connect(_on_button_released)
	$JumpButton.button_down.connect(_on_jump_pressed)

	# Connect to platform detector for auto-show/hide
	if PlatformDetector:
		PlatformDetector.platform_changed.connect(_on_platform_changed)
		_update_visibility()


func _update_visibility() -> void:
	if force_visible:
		visible = true
	elif PlatformDetector:
		visible = PlatformDetector.should_show_touch_controls()
	else:
		# Fallback: show on mobile platforms
		visible = OS.get_name() in ["Android", "iOS"]


func _on_platform_changed(_is_mobile: bool) -> void:
	_update_visibility()


func _on_left_pressed() -> void:
	current_direction = Vector2i(-1, 0)
	direction_pressed.emit(current_direction)


func _on_right_pressed() -> void:
	current_direction = Vector2i(1, 0)
	direction_pressed.emit(current_direction)


func _on_down_pressed() -> void:
	current_direction = Vector2i(0, 1)
	direction_pressed.emit(current_direction)


func _on_button_released() -> void:
	current_direction = Vector2i.ZERO
	direction_released.emit()


func get_direction() -> Vector2i:
	return current_direction


func _on_jump_pressed() -> void:
	jump_pressed.emit()
