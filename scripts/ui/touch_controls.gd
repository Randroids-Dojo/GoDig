extends Control
## Touch controls UI for mobile devices.
## Provides virtual joystick for movement and touch screen action buttons.
## Supports multitouch for simultaneous movement and actions.
## Automatically shows/hides based on platform detection.
##
## Note: Digging happens automatically when moving into blocks (via joystick)
## or by tapping directly on adjacent blocks (tap-to-dig).

signal direction_pressed(direction: Vector2i)
signal direction_released()
signal jump_pressed()
signal inventory_pressed()

## Reference to the virtual joystick
@onready var joystick: Control = $VirtualJoystick

## Reference to action buttons container
@onready var action_buttons: Control = $ActionButtons

## Reference to the jump button
@onready var jump_button: TouchScreenButton = $ActionButtons/JumpButton

## Reference to the inventory button
@onready var inventory_button: TouchScreenButton = $ActionButtons/InventoryButton

## If true, ignore platform detection and always show controls
@export var force_visible: bool = false


func _ready() -> void:
	# Ensure action buttons exist before connecting signals
	_setup_action_buttons()

	# Connect joystick direction changes
	joystick.direction_changed.connect(_on_joystick_direction_changed)

	# Connect to platform detector for auto-show/hide
	if PlatformDetector:
		PlatformDetector.platform_changed.connect(_on_platform_changed)
		_update_visibility()


func _setup_action_buttons() -> void:
	## Setup action buttons with proper signals and input mapping

	# Connect jump button
	if jump_button:
		jump_button.pressed.connect(_on_jump_pressed)

	# Connect inventory button
	if inventory_button:
		inventory_button.pressed.connect(_on_inventory_pressed)


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


func _on_inventory_pressed() -> void:
	inventory_pressed.emit()


func get_direction() -> Vector2i:
	return joystick.get_direction()
