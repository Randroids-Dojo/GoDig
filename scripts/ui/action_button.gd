extends TouchScreenButton
## Touch screen action button with multitouch support.
## Emits pressed and released signals for proper mobile input handling.
## Supports visual feedback and custom action mapping.

signal button_pressed()
signal button_released()

## The input action this button triggers (optional, for Input.action_*)
@export var action_name: String = ""

## Visual feedback color when pressed
@export var pressed_color: Color = Color(0.6, 0.6, 0.6, 1.0)

## Normal color when not pressed
@export var normal_color: Color = Color(1.0, 1.0, 1.0, 1.0)

## Whether this button is currently pressed
var is_pressed: bool = false:
	get:
		return is_pressed
	set(value):
		is_pressed = value
		_update_visual()


func _ready() -> void:
	# Connect TouchScreenButton signals
	self.pressed.connect(_on_pressed)
	self.released.connect(_on_released)

	# Enable multitouch
	passby_press = false  # Don't trigger when dragging across

	_update_visual()


func _on_pressed() -> void:
	is_pressed = true
	button_pressed.emit()

	# Trigger input action if configured
	if action_name != "":
		Input.action_press(action_name)


func _on_released() -> void:
	is_pressed = false
	button_released.emit()

	# Release input action if configured
	if action_name != "":
		Input.action_release(action_name)


func _update_visual() -> void:
	# Update modulate for visual feedback
	if is_pressed:
		modulate = pressed_color
	else:
		modulate = normal_color
