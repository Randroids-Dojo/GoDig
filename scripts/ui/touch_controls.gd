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

## Swipe gesture tracking
var _swipe_start_pos: Vector2 = Vector2.ZERO
var _swipe_start_time: float = 0.0
var _is_swiping: bool = false
const SWIPE_MIN_DISTANCE: float = 50.0  # Minimum swipe distance in pixels
const SWIPE_MAX_TIME: float = 0.5  # Maximum time for a valid swipe
const SWIPE_COOLDOWN: float = 0.15  # Cooldown between swipes
var _swipe_cooldown_timer: float = 0.0


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


# ============================================
# SWIPE GESTURE CONTROLS
# ============================================

## Track active button touch for manual fallback detection
var _active_button_touch: int = -1  # Touch index currently on a button

func _process(delta: float) -> void:
	# Update swipe cooldown
	if _swipe_cooldown_timer > 0:
		_swipe_cooldown_timer -= delta


func _input(event: InputEvent) -> void:
	# Handle touch events for buttons (fallback for TouchScreenButton issues on mobile web)
	if event is InputEventScreenTouch:
		_handle_button_touch(event)

		# Process swipe only if enabled and not on controls
		if SettingsManager and SettingsManager.swipe_controls_enabled:
			if not _is_over_control(event.position):
				if event.pressed:
					_start_swipe(event.position)
				else:
					_end_swipe(event.position)

	elif event is InputEventScreenDrag:
		# Process swipe only if enabled and not on controls
		if SettingsManager and SettingsManager.swipe_controls_enabled:
			if not _is_over_control(event.position):
				_update_swipe(event.position)


func _handle_button_touch(event: InputEventScreenTouch) -> void:
	## Manual touch detection for action buttons (fallback for mobile web)
	## This ensures buttons work even when TouchScreenButton has viewport issues

	# Convert screen position to canvas coordinates
	var canvas_xform := get_viewport().canvas_transform
	var world_pos := canvas_xform.affine_inverse() * event.position

	if event.pressed:
		# Check if touch is on jump button
		if jump_button and jump_button.visible:
			var jump_rect := _get_button_rect(jump_button)
			if jump_rect.has_point(world_pos):
				_active_button_touch = event.index
				_on_jump_pressed()
				return

		# Check if touch is on inventory button
		if inventory_button and inventory_button.visible:
			var inv_rect := _get_button_rect(inventory_button)
			if inv_rect.has_point(world_pos):
				_active_button_touch = event.index
				_on_inventory_pressed()
				return
	else:
		# Touch released - clear active button if it was this touch
		if event.index == _active_button_touch:
			_active_button_touch = -1


func _get_button_rect(button: TouchScreenButton) -> Rect2:
	## Get the global rect for a TouchScreenButton based on its shape
	var button_global_pos := button.global_position
	var shape := button.shape as RectangleShape2D
	if shape:
		var size := shape.size
		if button.shape_centered:
			return Rect2(button_global_pos - size / 2.0, size)
		else:
			return Rect2(button_global_pos, size)
	# Fallback: use a reasonable default size
	return Rect2(button_global_pos, Vector2(100, 100))


func _start_swipe(pos: Vector2) -> void:
	## Begin tracking a potential swipe gesture
	_swipe_start_pos = pos
	_swipe_start_time = Time.get_ticks_msec() / 1000.0
	_is_swiping = true


func _update_swipe(pos: Vector2) -> void:
	## Update swipe tracking - can emit early if swipe distance is reached
	if not _is_swiping or _swipe_cooldown_timer > 0:
		return

	var delta := pos - _swipe_start_pos
	var distance := delta.length()

	# Check if we've swiped far enough
	if distance >= SWIPE_MIN_DISTANCE:
		var direction := _get_swipe_direction(delta)
		if direction != Vector2i.ZERO:
			_emit_swipe(direction)
			_is_swiping = false  # Prevent multiple swipes from same gesture


func _end_swipe(pos: Vector2) -> void:
	## Complete a swipe gesture and check if it was valid
	if not _is_swiping:
		return

	var delta := pos - _swipe_start_pos
	var distance := delta.length()
	var elapsed := (Time.get_ticks_msec() / 1000.0) - _swipe_start_time

	# Reset swiping state
	_is_swiping = false

	# Check if cooldown is active
	if _swipe_cooldown_timer > 0:
		return

	# Check if swipe was fast and far enough
	if distance >= SWIPE_MIN_DISTANCE and elapsed <= SWIPE_MAX_TIME:
		var direction := _get_swipe_direction(delta)
		if direction != Vector2i.ZERO:
			_emit_swipe(direction)


func _get_swipe_direction(delta: Vector2) -> Vector2i:
	## Convert swipe delta to a cardinal direction
	# Determine if horizontal or vertical swipe
	if abs(delta.x) > abs(delta.y):
		# Horizontal swipe
		if delta.x > 0:
			return Vector2i(1, 0)  # Right
		else:
			return Vector2i(-1, 0)  # Left
	else:
		# Vertical swipe
		if delta.y > 0:
			return Vector2i(0, 1)  # Down
		else:
			return Vector2i(0, -1)  # Up
	return Vector2i.ZERO


func _emit_swipe(direction: Vector2i) -> void:
	## Emit a swipe in the specified direction
	_swipe_cooldown_timer = SWIPE_COOLDOWN
	direction_pressed.emit(direction)

	# Auto-release after a short delay (simulate tap-move)
	await get_tree().create_timer(0.1).timeout
	direction_released.emit()
	print("[TouchControls] Swipe detected: %s" % str(direction))


func _is_over_control(pos: Vector2) -> bool:
	## Check if position is over a control element (joystick or buttons)
	## pos is in screen coordinates, so we need to convert to canvas coordinates
	if pos == Vector2.ZERO:
		return false

	# Convert screen position to canvas/world coordinates
	var canvas_xform := get_viewport().canvas_transform
	var world_pos := canvas_xform.affine_inverse() * pos

	if joystick and joystick.visible:
		var joystick_rect := Rect2(joystick.global_position, joystick.size)
		if joystick_rect.has_point(world_pos):
			return true

	if action_buttons and action_buttons.visible:
		var buttons_rect := Rect2(action_buttons.global_position, action_buttons.size)
		if buttons_rect.has_point(world_pos):
			return true

	return false
