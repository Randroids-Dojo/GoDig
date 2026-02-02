extends CharacterBody2D
## Minimal player for greybox mining test.
## Tests the core feel of tap-to-mine with no progression systems.

const BLOCK_SIZE := 128
const MOVE_SPEED := 400.0
const GRAVITY := 1200.0
const JUMP_VELOCITY := -450.0

## Mining configuration
const MINE_DAMAGE := 10.0  # Damage per tap
const MINE_REACH := 1  # Can mine adjacent blocks

## State
var grid_position := Vector2i(0, 0)
var _target_block: Vector2i = Vector2i.ZERO
var _is_mining: bool = false

## References
var dirt_grid: Node2D = null

## Feedback
var _particles: CPUParticles2D = null
var _camera: Camera2D = null


func _ready() -> void:
	# Create simple particle effect for mining feedback
	_particles = CPUParticles2D.new()
	_particles.emitting = false
	_particles.amount = 8
	_particles.lifetime = 0.3
	_particles.one_shot = true
	_particles.explosiveness = 1.0
	_particles.direction = Vector2(0, -1)
	_particles.spread = 60.0
	_particles.gravity = Vector2(0, 400)
	_particles.initial_velocity_min = 100.0
	_particles.initial_velocity_max = 200.0
	_particles.scale_amount_min = 0.3
	_particles.scale_amount_max = 0.5
	_particles.color = Color(0.5, 0.5, 0.5)  # Grey for greybox
	add_child(_particles)

	# Get camera
	_camera = get_node_or_null("Camera2D")

	print("[GreyboxPlayer] Ready")


func _physics_process(delta: float) -> void:
	# Apply gravity
	velocity.y += GRAVITY * delta

	# Movement input
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * MOVE_SPEED

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	move_and_slide()

	# Update grid position
	grid_position = Vector2i(
		int(position.x / BLOCK_SIZE),
		int(position.y / BLOCK_SIZE)
	)


func _input(event: InputEvent) -> void:
	# Handle touch/click for mining
	if event is InputEventMouseButton and event.pressed:
		_handle_tap(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		_handle_tap(event.position)


func _handle_tap(screen_pos: Vector2) -> void:
	## Handle tap input for mining
	if dirt_grid == null:
		return

	# Convert screen position to world position
	var world_pos := get_global_mouse_position()
	var tap_grid := Vector2i(
		int(world_pos.x / BLOCK_SIZE),
		int(world_pos.y / BLOCK_SIZE)
	)

	# Check if within mining reach
	var distance := maxi(absi(tap_grid.x - grid_position.x), absi(tap_grid.y - grid_position.y))
	if distance > MINE_REACH:
		return  # Too far

	# Check if there's a block there
	if not dirt_grid.has_block(tap_grid):
		return

	# Mine the block
	_mine_block(tap_grid)


func _mine_block(block_pos: Vector2i) -> void:
	## Mine a block at the given position
	if dirt_grid == null:
		return

	var destroyed := dirt_grid.hit_block(block_pos, MINE_DAMAGE)

	if destroyed:
		# Block was destroyed - provide feedback
		_on_block_destroyed(block_pos)
	else:
		# Block damaged but not destroyed
		_on_block_hit(block_pos)


func _on_block_hit(block_pos: Vector2i) -> void:
	## Called when block is damaged but not destroyed
	# Small screen shake
	if _camera:
		_apply_screen_shake(1.5)

	# Position particles at block
	var world_pos := Vector2(block_pos.x * BLOCK_SIZE + BLOCK_SIZE / 2, block_pos.y * BLOCK_SIZE + BLOCK_SIZE / 2)
	_particles.global_position = world_pos
	_particles.amount = 4
	_particles.restart()
	_particles.emitting = true


func _on_block_destroyed(block_pos: Vector2i) -> void:
	## Called when block is fully destroyed
	# Larger screen shake
	if _camera:
		_apply_screen_shake(3.0)

	# More particles
	var world_pos := Vector2(block_pos.x * BLOCK_SIZE + BLOCK_SIZE / 2, block_pos.y * BLOCK_SIZE + BLOCK_SIZE / 2)
	_particles.global_position = world_pos
	_particles.amount = 12
	_particles.restart()
	_particles.emitting = true

	print("[GreyboxPlayer] Block destroyed at %s" % str(block_pos))


func _apply_screen_shake(intensity: float) -> void:
	## Apply simple screen shake
	if _camera == null:
		return

	var original_offset := _camera.offset
	_camera.offset = original_offset + Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))

	# Reset after a short time
	await get_tree().create_timer(0.05).timeout
	if _camera:
		_camera.offset = original_offset


## Set the dirt grid reference
func set_dirt_grid(grid: Node2D) -> void:
	dirt_grid = grid
