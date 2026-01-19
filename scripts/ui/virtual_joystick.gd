extends Control
## Virtual joystick control for mobile movement.
## Provides an on-screen analog joystick that outputs cardinal directions.
## Only outputs: up (disabled for MVP), down, left, right, and neutral.

signal direction_changed(direction: Vector2i)

## The maximum distance the knob can move from center
@export var max_distance: float = 64.0
## Deadzone threshold (normalized 0-1)
@export var deadzone: float = 0.2
## Size of the joystick base
@export var base_size: float = 160.0
## Size of the knob
@export var knob_size: float = 80.0
## Allow vertical input (up for MVP is disabled, down is allowed)
@export var allow_up: bool = false

## Base circle (outer ring)
var base: Control
## Knob (inner movable circle)
var knob: Control

var _touch_index: int = -1
var _center_position: Vector2
var _current_direction: Vector2i = Vector2i.ZERO


func _ready() -> void:
	# Create the base (outer circle)
	base = Control.new()
	base.name = "Base"
	base.custom_minimum_size = Vector2(base_size, base_size)
	base.size = Vector2(base_size, base_size)
	add_child(base)

	var base_bg = ColorRect.new()
	base_bg.name = "BaseBG"
	base_bg.color = Color(0.2, 0.2, 0.2, 0.5)
	base_bg.size = Vector2(base_size, base_size)
	base.add_child(base_bg)

	# Create the knob (inner circle)
	knob = Control.new()
	knob.name = "Knob"
	knob.custom_minimum_size = Vector2(knob_size, knob_size)
	knob.size = Vector2(knob_size, knob_size)
	base.add_child(knob)

	var knob_bg = ColorRect.new()
	knob_bg.name = "KnobBG"
	knob_bg.color = Color(0.4, 0.4, 0.4, 0.8)
	knob_bg.size = Vector2(knob_size, knob_size)
	knob.add_child(knob_bg)

	# Center the knob initially
	_center_position = Vector2(base_size / 2.0, base_size / 2.0)
	_center_knob()

	# Set minimum size for this control
	custom_minimum_size = Vector2(base_size, base_size)
	size = Vector2(base_size, base_size)


func _center_knob() -> void:
	knob.position = _center_position - Vector2(knob_size / 2.0, knob_size / 2.0)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			# Check if touch is within our bounds
			if _is_within_bounds(event.position):
				_touch_index = event.index
				_handle_touch(event.position)
		else:
			if event.index == _touch_index:
				_touch_index = -1
				_reset_joystick()

	elif event is InputEventScreenDrag:
		if event.index == _touch_index:
			_handle_touch(event.position)


func _is_within_bounds(screen_pos: Vector2) -> bool:
	var local_pos = _screen_to_local(screen_pos)
	var rect = Rect2(Vector2.ZERO, Vector2(base_size, base_size))
	# Expand bounds slightly for easier grabbing
	rect = rect.grow(20.0)
	return rect.has_point(local_pos)


func _screen_to_local(screen_pos: Vector2) -> Vector2:
	return screen_pos - global_position


func _handle_touch(screen_pos: Vector2) -> void:
	var local_pos = _screen_to_local(screen_pos)

	# Calculate offset from center
	var offset = local_pos - _center_position
	var distance = offset.length()

	# Clamp to max distance
	if distance > max_distance:
		offset = offset.normalized() * max_distance

	# Update knob position
	knob.position = _center_position + offset - Vector2(knob_size / 2.0, knob_size / 2.0)

	# Calculate direction
	var normalized_offset = offset / max_distance
	var new_direction = _calculate_direction(normalized_offset)

	if new_direction != _current_direction:
		_current_direction = new_direction
		direction_changed.emit(_current_direction)


func _calculate_direction(normalized_offset: Vector2) -> Vector2i:
	# Check if within deadzone
	if normalized_offset.length() < deadzone:
		return Vector2i.ZERO

	# Determine dominant axis
	var abs_x = abs(normalized_offset.x)
	var abs_y = abs(normalized_offset.y)

	if abs_x > abs_y:
		# Horizontal movement
		if normalized_offset.x > 0:
			return Vector2i(1, 0)  # Right
		else:
			return Vector2i(-1, 0)  # Left
	else:
		# Vertical movement
		if normalized_offset.y > 0:
			return Vector2i(0, 1)  # Down
		elif allow_up:
			return Vector2i(0, -1)  # Up (only if allowed)
		else:
			return Vector2i.ZERO  # Up not allowed in MVP


func _reset_joystick() -> void:
	_center_knob()
	if _current_direction != Vector2i.ZERO:
		_current_direction = Vector2i.ZERO
		direction_changed.emit(_current_direction)


func get_direction() -> Vector2i:
	return _current_direction
