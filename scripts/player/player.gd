extends CharacterBody2D
## Player controller with grid-based movement and mining.
## Uses a state machine: IDLE, MOVING, MINING.

signal block_destroyed(grid_pos: Vector2i)
signal depth_changed(depth: int)

enum State { IDLE, MOVING, MINING }

const BLOCK_SIZE := 64
const MOVE_DURATION := 0.15  # Seconds to move one block

@export var dirt_grid: Node2D  # DirtGrid node

var current_state: State = State.IDLE
var grid_position: Vector2i  # Top-left of player's 2x2 footprint
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
			pass  # Animation callback handles completion


func _handle_idle_input() -> void:
	var dir := Vector2i.ZERO

	if Input.is_action_pressed("move_down"):
		dir = Vector2i(0, 1)
	elif Input.is_action_pressed("move_left"):
		dir = Vector2i(-1, 0)
	elif Input.is_action_pressed("move_right"):
		dir = Vector2i(1, 0)

	if dir != Vector2i.ZERO:
		_try_move_or_mine(dir)


func _try_move_or_mine(direction: Vector2i) -> void:
	var target := grid_position + direction

	# Check bounds (don't go off left/right edges)
	if target.x < 0 or target.x + 1 >= GameManager.GRID_WIDTH:
		return

	# Check if path is clear (need to check cells for 2x2 player)
	var blocked_cells := _get_blocked_cells(target, direction)

	if blocked_cells.is_empty():
		_start_move(target)
	else:
		_start_mining(direction, blocked_cells[0])


func _get_blocked_cells(target_pos: Vector2i, dir: Vector2i) -> Array[Vector2i]:
	## Player is 2x2, check which cells block movement in given direction
	var blocked: Array[Vector2i] = []
	var cells_to_check: Array[Vector2i] = []

	if dir == Vector2i(0, 1):  # Moving down
		# Check bottom edge of player's new position
		cells_to_check = [
			Vector2i(target_pos.x, target_pos.y + 1),
			Vector2i(target_pos.x + 1, target_pos.y + 1)
		]
	elif dir == Vector2i(-1, 0):  # Moving left
		# Check left edge of player's new position
		cells_to_check = [
			Vector2i(target_pos.x, target_pos.y),
			Vector2i(target_pos.x, target_pos.y + 1)
		]
	elif dir == Vector2i(1, 0):  # Moving right
		# Check right edge of player's new position
		cells_to_check = [
			Vector2i(target_pos.x + 1, target_pos.y),
			Vector2i(target_pos.x + 1, target_pos.y + 1)
		]

	for cell in cells_to_check:
		if dirt_grid and dirt_grid.has_block(cell):
			blocked.append(cell)

	return blocked


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
		# Check if path is now clear
		var blocked := _get_blocked_cells(grid_position + mining_direction, mining_direction)
		if blocked.is_empty():
			_start_move(grid_position + mining_direction)
		else:
			# Continue mining next block in path
			mining_target = blocked[0]
			sprite.play("swing")
	else:
		# Block still has health, continue mining same block
		sprite.play("swing")


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
