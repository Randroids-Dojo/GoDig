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
## Uses tool identity settings for color tinting and scale when available
func burst(world_pos: Vector2, block_color: Color, hardness: float = 10.0) -> void:
	global_position = world_pos

	# Apply tool particle color tint if available
	var final_color := block_color
	var scale_mult := 1.0
	var tool_sparks := false

	if PlayerData and PlayerData.current_tool:
		var tool = PlayerData.current_tool
		if "particle_color" in tool and tool.particle_color != Color.WHITE:
			# Blend block color with tool's particle color for consistent identity
			final_color = block_color.lerp(tool.particle_color, 0.3)
		if "particle_scale" in tool:
			scale_mult = tool.particle_scale
		if "creates_sparks" in tool:
			tool_sparks = tool.creates_sparks

	color = final_color
	visible = true
	_in_pool = false

	# Configure particles based on material hardness
	_configure_for_material(hardness)

	# Apply tool scale modifier
	scale_amount_min *= scale_mult
	scale_amount_max *= scale_mult

	# Metallic tools create brighter, faster sparks
	if tool_sparks and hardness >= MATERIAL_MEDIUM:
		initial_velocity_min *= 1.2
		initial_velocity_max *= 1.3
		lifetime *= 0.85  # Shorter but more intense

	emitting = true

	# Return to pool after particles finish
	await get_tree().create_timer(lifetime + 0.1).timeout
	_return_to_pool()


func _configure_for_material(hardness: float) -> void:
	## Configure particle behavior based on material hardness.
	## Two-tier juice system: Tier 1 block destruction is satisfying but not overwhelming.
	## Tier 2 (ore discovery) uses ore_burst() instead for celebration effect.

	if hardness < MATERIAL_SOFT:
		# Soft material (dirt, grass): Light dust puff (5-6 particles)
		amount = 5
		lifetime = 0.3
		spread = 55.0
		initial_velocity_min = 70.0
		initial_velocity_max = 130.0
		gravity = Vector2(0, 380)
		scale_amount_min = 2.0
		scale_amount_max = 4.5

	elif hardness < MATERIAL_MEDIUM:
		# Medium material (stone): Standard debris (6-7 particles)
		amount = 7
		lifetime = 0.35
		spread = 45.0
		initial_velocity_min = 90.0
		initial_velocity_max = 180.0
		gravity = Vector2(0, 450)
		scale_amount_min = 2.5
		scale_amount_max = 5.5

	elif hardness < MATERIAL_HARD:
		# Hard material (granite): Rock chips flying outward (8 particles)
		amount = 8
		lifetime = 0.45
		spread = 35.0
		initial_velocity_min = 130.0
		initial_velocity_max = 250.0
		gravity = Vector2(0, 550)
		scale_amount_min = 3.5
		scale_amount_max = 7.0

	else:
		# Very hard material (obsidian): Heavy shatter (10 particles)
		amount = 10
		lifetime = 0.55
		spread = 30.0
		initial_velocity_min = 160.0
		initial_velocity_max = 320.0
		gravity = Vector2(0, 650)
		scale_amount_min = 4.5
		scale_amount_max = 9.0


func _return_to_pool() -> void:
	visible = false
	emitting = false
	_in_pool = true


## Check if this particle instance is available in the pool
func is_available() -> bool:
	return _in_pool


## Emit a Tier 2 ore discovery particle burst (10-15 particles with glow effect)
## This is the celebration moment when ore is found - more dramatic than regular burst
func ore_burst(world_pos: Vector2, ore_color: Color, hardness: float = 10.0) -> void:
	global_position = world_pos
	# Use ore color with slight brightening for celebration feel
	color = ore_color.lightened(0.2)
	visible = true
	_in_pool = false

	# Tier 2 discovery celebration: 10-15 particles
	_configure_for_ore_discovery(hardness)

	emitting = true

	# Return to pool after particles finish
	await get_tree().create_timer(lifetime + 0.1).timeout
	_return_to_pool()


func _configure_for_ore_discovery(hardness: float) -> void:
	## Configure Tier 2 ore discovery celebration particles.
	## More particles (10-15), larger, more dramatic than regular burst.
	## Creates an excitement spike distinct from regular mining.

	# Base ore discovery settings (12 particles average)
	amount = 12
	lifetime = 0.5
	spread = 50.0
	initial_velocity_min = 120.0
	initial_velocity_max = 240.0
	gravity = Vector2(0, 450)
	scale_amount_min = 4.0
	scale_amount_max = 8.0

	# Adjust slightly by hardness for variety
	if hardness >= MATERIAL_HARD:
		# Hard ore blocks: slightly more dramatic
		amount = 15
		lifetime = 0.6
		initial_velocity_min = 140.0
		initial_velocity_max = 280.0
		scale_amount_min = 4.5
		scale_amount_max = 9.0
	elif hardness >= MATERIAL_MEDIUM:
		# Medium hardness ore: standard discovery
		amount = 12
		lifetime = 0.5
	else:
		# Soft ore (like coal): slightly lighter
		amount = 10
		lifetime = 0.45


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
	## Two-tier juice system: Tier 1 mining feedback is SUBTLE (2-4 particles)
	## Reserved for every-hit feedback without visual fatigue.

	# Fewer particles, shorter lifetime, minimal visual noise
	if hardness < MATERIAL_SOFT:
		# Soft material: tiny dust puff (2-3 particles)
		amount = 2
		lifetime = 0.2
		spread = 45.0
		initial_velocity_min = 30.0
		initial_velocity_max = 60.0
		gravity = Vector2(0, 250)
		scale_amount_min = 1.0
		scale_amount_max = 2.5

	elif hardness < MATERIAL_MEDIUM:
		# Medium material: small debris (3 particles)
		amount = 3
		lifetime = 0.25
		spread = 40.0
		initial_velocity_min = 50.0
		initial_velocity_max = 100.0
		gravity = Vector2(0, 350)
		scale_amount_min = 1.5
		scale_amount_max = 3.0

	elif hardness < MATERIAL_HARD:
		# Hard material: chip debris (4 particles)
		amount = 4
		lifetime = 0.3
		spread = 35.0
		initial_velocity_min = 70.0
		initial_velocity_max = 130.0
		gravity = Vector2(0, 400)
		scale_amount_min = 2.0
		scale_amount_max = 4.0

	else:
		# Very hard material: rock chips (4 particles)
		amount = 4
		lifetime = 0.35
		spread = 30.0
		initial_velocity_min = 90.0
		initial_velocity_max = 160.0
		gravity = Vector2(0, 450)
		scale_amount_min = 2.5
		scale_amount_max = 5.0
