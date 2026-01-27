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

## Default positions for controls (for hand mode switching)
var _default_joystick_anchor: Vector2 = Vector2.ZERO
var _default_buttons_anchor: Vector2 = Vector2.ZERO
var _initial_setup_done: bool = false


func _ready() -> void:
	# Ensure action buttons exist before connecting signals
	_setup_action_buttons()

	# Store default positions after layout is ready
	call_deferred("_store_default_positions")

	# Connect joystick direction changes
	joystick.direction_changed.connect(_on_joystick_direction_changed)

	# Connect to platform detector for auto-show/hide
	if PlatformDetector:
		PlatformDetector.platform_changed.connect(_on_platform_changed)
		_update_visibility()

	# Connect to settings for hand mode changes
	if SettingsManager:
		SettingsManager.hand_mode_changed.connect(_on_hand_mode_changed)
		call_deferred("_apply_hand_mode")


func _store_default_positions() -> void:
	## Store the default anchor positions for hand mode switching
	if joystick:
		_default_joystick_anchor = joystick.position
	if action_buttons:
		_default_buttons_anchor = action_buttons.position
	_initial_setup_done = true


func _on_hand_mode_changed(_mode: int) -> void:
	_apply_hand_mode()


func _apply_hand_mode() -> void:
	## Reposition controls based on hand mode setting
	if not _initial_setup_done:
		return
	if SettingsManager == null:
		return

	var screen_width := get_viewport().get_visible_rect().size.x

	match SettingsManager.hand_mode:
		SettingsManager.HandMode.STANDARD:
			# Default: joystick left, buttons right
			if joystick:
				joystick.position = _default_joystick_anchor
			if action_buttons:
				action_buttons.position = _default_buttons_anchor

		SettingsManager.HandMode.LEFT_HAND:
			# Flip: joystick right, buttons left
			if joystick:
				joystick.position.x = screen_width - _default_joystick_anchor.x - joystick.size.x
			if action_buttons:
				action_buttons.position.x = _default_joystick_anchor.x

		SettingsManager.HandMode.RIGHT_HAND:
			# Same as standard (optimized for right-handed play)
			if joystick:
				joystick.position = _default_joystick_anchor
			if action_buttons:
				action_buttons.position = _default_buttons_anchor


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
