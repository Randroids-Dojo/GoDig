extends CPUParticles2D
## Block break particle effect.
##
## Spawns a burst of colored particles when a block is destroyed.
## Different particle behaviors based on material type (hardness).
## Managed by test_level particle pool for performance.

## Material type thresholds (based on block hardness)
const MATERIAL_SOFT := 20.0    # Dirt, grass - soft particles
const MATERIAL_MEDIUM := 50.0  # Stone - medium particles
const MATERIAL_HARD := 80.0    # Granite - hard particles
# Above HARD = Obsidian/etc - heavy particles

## Base particle settings (modified per material)
const BASE_LIFETIME := 0.4
const BASE_AMOUNT := 8

var _in_pool: bool = true


func _ready() -> void:
	emitting = false
	one_shot = true
	explosiveness = 1.0
	amount = BASE_AMOUNT
	lifetime = BASE_LIFETIME

	# Configure default particle behavior (soft material)
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
## hardness parameter controls particle behavior (soft dirt vs hard stone)
func burst(world_pos: Vector2, block_color: Color, hardness: float = 10.0) -> void:
	global_position = world_pos
	color = block_color
	visible = true
	_in_pool = false

	# Configure particles based on material hardness
	_configure_for_material(hardness)

	emitting = true

	# Return to pool after particles finish
	await get_tree().create_timer(lifetime + 0.1).timeout
	_return_to_pool()


func _configure_for_material(hardness: float) -> void:
	## Configure particle behavior based on material hardness.
	## Harder materials = heavier particles, more dramatic effects.

	if hardness < MATERIAL_SOFT:
		# Soft material (dirt, grass): Light dust puff
		amount = 6
		lifetime = 0.35
		spread = 60.0
		initial_velocity_min = 80.0
		initial_velocity_max = 150.0
		gravity = Vector2(0, 400)
		scale_amount_min = 2.5
		scale_amount_max = 5.0

	elif hardness < MATERIAL_MEDIUM:
		# Medium material (stone): Standard debris
		amount = 8
		lifetime = 0.4
		spread = 45.0
		initial_velocity_min = 100.0
		initial_velocity_max = 200.0
		gravity = Vector2(0, 500)
		scale_amount_min = 3.0
		scale_amount_max = 6.0

	elif hardness < MATERIAL_HARD:
		# Hard material (granite): Rock chips flying outward
		amount = 10
		lifetime = 0.5
		spread = 35.0
		initial_velocity_min = 150.0
		initial_velocity_max = 280.0
		gravity = Vector2(0, 600)
		scale_amount_min = 4.0
		scale_amount_max = 8.0

	else:
		# Very hard material (obsidian): Heavy, dramatic shatter
		amount = 12
		lifetime = 0.6
		spread = 30.0
		initial_velocity_min = 180.0
		initial_velocity_max = 350.0
		gravity = Vector2(0, 700)
		scale_amount_min = 5.0
		scale_amount_max = 10.0


func _return_to_pool() -> void:
	visible = false
	emitting = false
	_in_pool = true


## Check if this particle instance is available in the pool
func is_available() -> bool:
	return _in_pool


## Emit a small particle puff for per-hit feedback (lighter than burst)
## Called on each swing, not just on block destruction
func puff(world_pos: Vector2, block_color: Color, hardness: float = 10.0) -> void:
	global_position = world_pos
	color = block_color
	visible = true
	_in_pool = false

	# Lighter particles for per-hit (3-6 small debris)
	_configure_for_puff(hardness)

	emitting = true

	# Return to pool after particles finish
	await get_tree().create_timer(lifetime + 0.1).timeout
	_return_to_pool()


func _configure_for_puff(hardness: float) -> void:
	## Configure lighter particle puff for per-hit effects.
	## Always uses fewer particles than burst.

	# Fewer particles, shorter lifetime, less dramatic
	if hardness < MATERIAL_SOFT:
		# Soft material: tiny dust puff
		amount = 3
		lifetime = 0.25
		spread = 50.0
		initial_velocity_min = 40.0
		initial_velocity_max = 80.0
		gravity = Vector2(0, 300)
		scale_amount_min = 1.5
		scale_amount_max = 3.0

	elif hardness < MATERIAL_MEDIUM:
		# Medium material: small debris
		amount = 4
		lifetime = 0.3
		spread = 40.0
		initial_velocity_min = 60.0
		initial_velocity_max = 120.0
		gravity = Vector2(0, 400)
		scale_amount_min = 2.0
		scale_amount_max = 4.0

	elif hardness < MATERIAL_HARD:
		# Hard material: chip debris
		amount = 5
		lifetime = 0.35
		spread = 35.0
		initial_velocity_min = 80.0
		initial_velocity_max = 150.0
		gravity = Vector2(0, 450)
		scale_amount_min = 2.5
		scale_amount_max = 5.0

	else:
		# Very hard material: rock chips
		amount = 6
		lifetime = 0.4
		spread = 30.0
		initial_velocity_min = 100.0
		initial_velocity_max = 180.0
		gravity = Vector2(0, 500)
		scale_amount_min = 3.0
		scale_amount_max = 6.0
