extends CharacterBody2D
## Player controller with grid-based movement, mining, and wall-jump.
## Uses a state machine: IDLE, MOVING, MINING, FALLING, WALL_SLIDING, WALL_JUMPING.
## Player is 128x128 (same size as one dirt block).

signal block_destroyed(grid_pos: Vector2i)
signal depth_changed(depth: int)
signal jump_pressed  # Emitted when player wants to jump (for wall-jump)

enum State { IDLE, MOVING, MINING, FALLING, WALL_SLIDING, WALL_JUMPING }

const BLOCK_SIZE := 128
const MOVE_DURATION := 0.15  # Seconds to move one block

# Wall-jump physics constants
const GRAVITY: float = 980.0
const WALL_SLIDE_SPEED: float = 50.0
const WALL_JUMP_FORCE_X: float = 200.0
const WALL_JUMP_FORCE_Y: float = 450.0
const WALL_JUMP_COOLDOWN: float = 0.2  # Prevent instant re-grab

var dirt_grid: Node2D  # Set by test_level.gd
var touch_direction: Vector2i = Vector2i.ZERO  # Direction from touch controls
var wants_jump: bool = false  # Set by touch controls or keyboard

var current_state: State = State.IDLE
var grid_position: Vector2i  # Player's grid cell (1x1 now)
var target_grid_position: Vector2i
var mining_direction: Vector2i
var mining_target: Vector2i
var _move_tween: Tween

# Wall-jump state
var _wall_direction: int = 0  # -1 = wall on left, 1 = wall on right, 0 = no wall
var _wall_jump_timer: float = 0.0  # Cooldown after wall-jump

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	grid_position = _world_to_grid(position)
	sprite.animation_finished.connect(_on_animation_finished)


func _process(delta: float) -> void:
	# Update wall-jump cooldown timer
	if _wall_jump_timer > 0:
		_wall_jump_timer -= delta

	match current_state:
		State.IDLE:
			_handle_idle_input()
		State.MOVING:
			pass  # Tween handles movement
		State.MINING:
			_handle_mining_input()
		State.FALLING:
			_handle_falling(delta)
		State.WALL_SLIDING:
			_handle_wall_sliding(delta)
		State.WALL_JUMPING:
			_handle_wall_jumping(delta)


func _handle_idle_input() -> void:
	var dir := _get_input_direction()
	if dir != Vector2i.ZERO:
		_try_move_or_mine(dir)


func _handle_mining_input() -> void:
	# Stop mining if player releases the direction key
	var dir := _get_input_direction()
	if dir != mining_direction:
		sprite.stop()
		current_state = State.IDLE


func _get_input_direction() -> Vector2i:
	# Check touch controls first
	if touch_direction != Vector2i.ZERO:
		return touch_direction

	# Fall back to keyboard input
	if Input.is_action_pressed("move_down"):
		return Vector2i(0, 1)
	elif Input.is_action_pressed("move_left"):
		return Vector2i(-1, 0)
	elif Input.is_action_pressed("move_right"):
		return Vector2i(1, 0)
	return Vector2i.ZERO


func _check_jump_input() -> bool:
	# Check touch jump or keyboard
	if wants_jump:
		wants_jump = false  # Consume the input
		return true
	if Input.is_action_just_pressed("jump"):
		return true
	return false


func _try_move_or_mine(direction: Vector2i) -> void:
	var target := grid_position + direction

	# No horizontal bounds - infinite terrain in all directions!
	# Vertical movement is unrestricted too (can go up or down freely)

	# Check if target cell has a block
	if dirt_grid and dirt_grid.has_block(target):
		_start_mining(direction, target)
	else:
		_start_move(target)


func _start_move(target: Vector2i) -> void:
	current_state = State.MOVING
	target_grid_position = target

	if _move_tween:
		_move_tween.kill()

	_move_tween = create_tween()
	_move_tween.tween_property(self, "position", _grid_to_world(target), MOVE_DURATION)
	_move_tween.tween_callback(_on_move_complete)


func _on_move_complete() -> void:
	grid_position = target_grid_position
	_update_depth()

	# Check if there's ground below - if not, start falling
	if _should_fall():
		_start_falling()
	else:
		current_state = State.IDLE


func _start_mining(direction: Vector2i, target_block: Vector2i) -> void:
	current_state = State.MINING
	mining_direction = direction
	mining_target = target_block

	# Flip sprite based on direction
	if direction.x != 0:
		sprite.flip_h = (direction.x < 0)

	sprite.play("swing")


func _on_animation_finished() -> void:
	if current_state != State.MINING:
		return

	if dirt_grid == null:
		current_state = State.IDLE
		return

	var destroyed: bool = dirt_grid.hit_block(mining_target)

	if destroyed:
		block_destroyed.emit(mining_target)
		# Block destroyed, move into the space
		_start_move(mining_target)
	else:
		# Block still has health, continue mining if key still pressed
		var dir := _get_input_direction()
		if dir == mining_direction:
			sprite.play("swing")
		else:
			current_state = State.IDLE


func _update_depth() -> void:
	var depth := grid_position.y - GameManager.SURFACE_ROW
	if depth < 0:
		depth = 0
	depth_changed.emit(depth)


func _grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * BLOCK_SIZE + GameManager.GRID_OFFSET_X,
		grid_pos.y * BLOCK_SIZE
	)


func _world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		int((world_pos.x - GameManager.GRID_OFFSET_X) / BLOCK_SIZE),
		int(world_pos.y / BLOCK_SIZE)
	)


## Called by TouchControls when a direction button is pressed
func set_touch_direction(direction: Vector2i) -> void:
	touch_direction = direction


## Called by TouchControls when all direction buttons are released
func clear_touch_direction() -> void:
	touch_direction = Vector2i.ZERO


## Called by TouchControls when jump button is pressed
func trigger_jump() -> void:
	wants_jump = true


# ============================================
# FALLING AND WALL-JUMP LOGIC
# ============================================

func _should_fall() -> bool:
	## Returns true if the player should start falling (no block below)
	if dirt_grid == null:
		return false
	var below := grid_position + Vector2i(0, 1)
	return not dirt_grid.has_block(below)


func _start_falling() -> void:
	current_state = State.FALLING
	velocity = Vector2.ZERO


func _handle_falling(delta: float) -> void:
	# Apply gravity
	velocity.y += GRAVITY * delta

	# Check for walls on either side for potential wall-slide
	_update_wall_direction()

	# Check if we can grab a wall (pressing toward it and cooldown expired)
	if _wall_direction != 0 and _wall_jump_timer <= 0:
		var input_dir := _get_input_direction()
		# Must be pressing toward the wall to grab it
		if (input_dir.x < 0 and _wall_direction == -1) or (input_dir.x > 0 and _wall_direction == 1):
			_start_wall_slide()
			return

	# Move based on physics velocity
	position.y += velocity.y * delta

	# Check if we landed on a block
	_check_landing()


func _update_wall_direction() -> void:
	## Detect adjacent walls using the grid
	_wall_direction = 0
	if dirt_grid == null:
		return

	# Get current grid position from world position
	var current_grid := _world_to_grid(position)

	# Check left wall
	var left_pos := current_grid + Vector2i(-1, 0)
	if left_pos.x >= 0 and dirt_grid.has_block(left_pos):
		_wall_direction = -1
		return

	# Check right wall
	var right_pos := current_grid + Vector2i(1, 0)
	if right_pos.x < GameManager.GRID_WIDTH and dirt_grid.has_block(right_pos):
		_wall_direction = 1


func _start_wall_slide() -> void:
	current_state = State.WALL_SLIDING
	velocity.y = 0  # Reset vertical velocity when grabbing wall


func _handle_wall_sliding(delta: float) -> void:
	# Slide down slowly
	velocity.y = WALL_SLIDE_SPEED
	position.y += velocity.y * delta

	# Update wall detection
	_update_wall_direction()

	# Check if wall is still there
	if _wall_direction == 0:
		current_state = State.FALLING
		return

	# Check for jump input
	if _check_jump_input():
		_do_wall_jump()
		return

	# Check if still pressing toward wall
	var input_dir := _get_input_direction()
	var pressing_toward_wall := (input_dir.x < 0 and _wall_direction == -1) or \
								(input_dir.x > 0 and _wall_direction == 1)
	if not pressing_toward_wall:
		current_state = State.FALLING
		return

	# Check if we landed on a block
	_check_landing()


func _do_wall_jump() -> void:
	current_state = State.WALL_JUMPING
	_wall_jump_timer = WALL_JUMP_COOLDOWN

	# Jump away from wall
	velocity.x = WALL_JUMP_FORCE_X * (-_wall_direction)  # Jump away from wall
	velocity.y = -WALL_JUMP_FORCE_Y

	# Flip sprite to face jump direction
	sprite.flip_h = (_wall_direction > 0)


func _handle_wall_jumping(delta: float) -> void:
	# Apply gravity
	velocity.y += GRAVITY * delta

	# Move based on physics velocity
	position.x += velocity.x * delta
	position.y += velocity.y * delta

	# Clamp to world bounds
	var min_x := float(GameManager.GRID_OFFSET_X)
	var max_x := float(GameManager.GRID_OFFSET_X + (GameManager.GRID_WIDTH - 1) * BLOCK_SIZE)
	position.x = clamp(position.x, min_x, max_x)

	# Transition to falling after horizontal velocity dies down or we start falling
	if velocity.y > 0:
		current_state = State.FALLING
		_check_wall_grab()
		return

	# Check if we landed on a block
	_check_landing()


func _check_wall_grab() -> void:
	## Check if we can grab a wall during/after wall-jump
	if _wall_jump_timer > 0:
		return  # Still in cooldown

	_update_wall_direction()
	if _wall_direction != 0:
		var input_dir := _get_input_direction()
		if (input_dir.x < 0 and _wall_direction == -1) or (input_dir.x > 0 and _wall_direction == 1):
			_start_wall_slide()


func _check_landing() -> void:
	## Check if player has landed on a block
	if dirt_grid == null:
		return

	# Get current grid position from world position
	var current_grid := _world_to_grid(position)
	var below := current_grid + Vector2i(0, 1)

	# Check if there's a block below us and we're close to being on top of it
	if dirt_grid.has_block(below):
		# Calculate the top of the block below
		var block_top := below.y * BLOCK_SIZE
		# If we're at or past the top of the block, snap and land
		if position.y >= block_top - BLOCK_SIZE:
			_land_on_grid(current_grid)


func _land_on_grid(landing_grid: Vector2i) -> void:
	## Snap player to grid position and return to IDLE state
	# Snap to proper grid position
	grid_position = landing_grid
	position = _grid_to_world(grid_position)
	velocity = Vector2.ZERO
	current_state = State.IDLE
	_update_depth()
