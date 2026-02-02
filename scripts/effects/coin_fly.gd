extends Node2D
## Single coin sprite that arcs from source to target position.
##
## Used by SellAnimation to create coin cascade effect when selling items.
## Coins arc outward then converge to the wallet/coin counter with spin.

## Signal emitted when coin reaches target
signal coin_arrived(value: int)

## Target position (global coordinates)
var target_pos: Vector2 = Vector2.ZERO

## Value this coin represents (for sound/feedback scaling)
var coin_value: int = 1

## Animation state
var _elapsed: float = 0.0
var _duration: float = 0.5
var _start_pos: Vector2 = Vector2.ZERO
var _control_point: Vector2 = Vector2.ZERO  # Bezier control for arc
var _spin_speed: float = 720.0  # Degrees per second
var _scale_curve: float = 1.2  # Start slightly larger

## The visual sprite
var _sprite: ColorRect = null


func _ready() -> void:
	# Create a simple coin visual (gold square - will be replaced with sprite if available)
	_sprite = ColorRect.new()
	_sprite.name = "CoinSprite"
	_sprite.size = Vector2(12, 12)
	_sprite.color = Color(1.0, 0.85, 0.2)  # Gold
	_sprite.pivot_offset = _sprite.size / 2.0
	add_child(_sprite)


## Start flying toward target
## from: Starting position (global)
## to: Target position (global)
## delay: Stagger delay before starting
## duration: Flight time
func fly_to(from: Vector2, to: Vector2, delay: float = 0.0, duration: float = 0.5) -> void:
	_start_pos = from
	target_pos = to
	_duration = duration
	_elapsed = -delay  # Negative elapsed handles delay
	global_position = from

	# Create arc control point - spread outward before converging
	var midpoint := (from + to) / 2.0
	var perpendicular := (to - from).rotated(PI / 2.0).normalized()
	var spread_amount := randf_range(30.0, 80.0) * (1 if randf() > 0.5 else -1)
	_control_point = midpoint + perpendicular * spread_amount

	# Random spin direction
	_spin_speed = randf_range(540.0, 900.0) * (1 if randf() > 0.5 else -1)

	# Slightly randomize scale
	_scale_curve = randf_range(1.0, 1.3)

	visible = true
	set_process(true)


func _process(delta: float) -> void:
	_elapsed += delta

	if _elapsed < 0:
		# Still in delay period
		return

	var t := clampf(_elapsed / _duration, 0.0, 1.0)

	# Quadratic bezier interpolation for arc
	var q0 := _start_pos.lerp(_control_point, t)
	var q1 := _control_point.lerp(target_pos, t)
	global_position = q0.lerp(q1, t)

	# Spin the coin
	if _sprite:
		_sprite.rotation_degrees += _spin_speed * delta

		# Scale pulse - start larger, shrink to normal
		var scale_t := 1.0 - (1.0 - t) * (_scale_curve - 1.0)
		_sprite.scale = Vector2(scale_t, scale_t)

	# Check if arrived
	if t >= 1.0:
		coin_arrived.emit(coin_value)
		queue_free()
