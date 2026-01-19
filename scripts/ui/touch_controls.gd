extends Control
## Touch controls UI for mobile devices.
## Provides virtual joystick for movement and jump button.
## Automatically shows/hides based on platform detection.
## Tap-to-dig is handled by the Player script directly.

signal direction_pressed(direction: Vector2i)
signal direction_released()
signal jump_pressed()

## Reference to the virtual joystick
@onready var joystick: Control = $VirtualJoystick

## Reference to the jump button
@onready var jump_button: Button = $JumpButton

## If true, ignore platform detection and always show controls
@export var force_visible: bool = false


func _ready() -> void:
	# Connect joystick direction changes
	joystick.direction_changed.connect(_on_joystick_direction_changed)

	# Connect jump button
	jump_button.button_down.connect(_on_jump_pressed)

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


func _on_joystick_direction_changed(direction: Vector2i) -> void:
	if direction == Vector2i.ZERO:
		direction_released.emit()
	else:
		direction_pressed.emit(direction)


func _on_jump_pressed() -> void:
	jump_pressed.emit()


func get_direction() -> Vector2i:
	return joystick.get_direction()
