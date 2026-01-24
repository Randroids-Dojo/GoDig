extends CPUParticles2D
## Block break particle effect.
##
## Spawns a burst of colored particles when a block is destroyed.
## Managed by test_level particle pool for performance.

const LIFETIME := 0.4
const AMOUNT := 8

var _in_pool: bool = true


func _ready() -> void:
	emitting = false
	one_shot = true
	explosiveness = 1.0
	amount = AMOUNT
	lifetime = LIFETIME

	# Configure particle behavior
	direction = Vector2(0, -1)  # Spray upward
	spread = 45.0
	initial_velocity_min = 100.0
	initial_velocity_max = 200.0
	gravity = Vector2(0, 500)  # Fall back down
	scale_amount_min = 3.0
	scale_amount_max = 6.0

	# Fade out
	color_ramp = _create_fade_gradient()


func _create_fade_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.add_point(0.0, Color.WHITE)
	gradient.add_point(0.7, Color.WHITE)
	gradient.add_point(1.0, Color(1, 1, 1, 0))  # Fade to transparent
	return gradient


## Emit a particle burst at the given position with the block's color
func burst(world_pos: Vector2, block_color: Color) -> void:
	global_position = world_pos
	color = block_color
	visible = true
	_in_pool = false
	emitting = true

	# Return to pool after particles finish
	await get_tree().create_timer(LIFETIME + 0.1).timeout
	_return_to_pool()


func _return_to_pool() -> void:
	visible = false
	emitting = false
	_in_pool = true


## Check if this particle instance is available in the pool
func is_available() -> bool:
	return _in_pool
