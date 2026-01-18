extends CharacterBody2D
## Player controller with grid-based movement and mining.
## Uses a state machine: IDLE, MOVING, MINING.
## Player is 128x128 (same size as one dirt block).

signal block_destroyed(grid_pos: Vector2i)
signal depth_changed(depth: int)

enum State { IDLE, MOVING, MINING }

const BLOCK_SIZE := 128
const MOVE_DURATION := 0.15  # Seconds to move one block

var dirt_grid: Node2D  # Set by test_level.gd
var touch_direction: Vector2i = Vector2i.ZERO  # Direction from touch controls

var current_state: State = State.IDLE
var grid_position: Vector2i  # Player's grid cell (1x1 now)
var target_grid_position: Vector2i
var mining_direction: Vector2i
var mining_target: Vector2i
var _move_tween: Tween

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	grid_position = _world_to_grid(position)
	sprite.animation_finished.connect(_on_animation_finished)


func _process(_delta: float) -> void:
	match current_state:
		State.IDLE:
			_handle_idle_input()
		State.MOVING:
			pass  # Tween handles movement
		State.MINING:
			_handle_mining_input()


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
	current_state = State.IDLE
	_update_depth()


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
