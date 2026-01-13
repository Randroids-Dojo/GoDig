extends Node2D
## Manages the infinite dirt grid with object pooling.
## Generates rows ahead of the player and cleans up rows behind.

const DirtBlockScript = preload("res://scripts/world/dirt_block.gd")

const BLOCK_SIZE := 128
const POOL_SIZE := 100  # Fewer blocks needed with larger size
const ROWS_AHEAD := 10
const ROWS_BEHIND := 5

var _pool: Array = []  # Array of DirtBlock nodes
var _active: Dictionary = {}  # Dictionary[Vector2i, DirtBlock node]
var _lowest_generated_row: int = 0
var _player: Node2D = null


func _ready() -> void:
	_preallocate_pool()


func initialize(player: Node2D, surface_row: int) -> void:
	_player = player
	_lowest_generated_row = surface_row
	# Generate initial rows (surface + some below)
	for row in range(surface_row, surface_row + ROWS_AHEAD):
		_generate_row(row)


func _process(_delta: float) -> void:
	if _player == null:
		return

	var player_row := int(_player.position.y / BLOCK_SIZE)
	_generate_rows_below(player_row + ROWS_AHEAD)
	_cleanup_rows_above(player_row - ROWS_BEHIND)


func _preallocate_pool() -> void:
	for i in range(POOL_SIZE):
		var block := ColorRect.new()
		block.set_script(DirtBlockScript)
		block.visible = false
		add_child(block)
		_pool.push_back(block)


func _acquire(grid_pos: Vector2i) -> ColorRect:
	var block: ColorRect
	if _pool.is_empty():
		# Pool exhausted, create new block
		block = ColorRect.new()
		block.set_script(DirtBlockScript)
		add_child(block)
	else:
		block = _pool.pop_back()

	block.activate(grid_pos)
	_active[grid_pos] = block
	return block


func _release(grid_pos: Vector2i) -> void:
	if _active.has(grid_pos):
		var block = _active[grid_pos]
		block.deactivate()
		_pool.push_back(block)
		_active.erase(grid_pos)


func _generate_rows_below(target_row: int) -> void:
	while _lowest_generated_row <= target_row:
		_generate_row(_lowest_generated_row)
		_lowest_generated_row += 1


func _generate_row(row: int) -> void:
	for col in range(GameManager.GRID_WIDTH):
		var pos := Vector2i(col, row)
		if not _active.has(pos):
			_acquire(pos)


func _cleanup_rows_above(min_row: int) -> void:
	var to_remove: Array[Vector2i] = []
	for pos: Vector2i in _active.keys():
		if pos.y < min_row:
			to_remove.append(pos)

	for pos in to_remove:
		_release(pos)


func has_block(pos: Vector2i) -> bool:
	return _active.has(pos)


func get_block(pos: Vector2i):
	return _active.get(pos)


func hit_block(pos: Vector2i) -> bool:
	## Hit a block, returns true if destroyed
	if not _active.has(pos):
		return true  # Already gone

	var block = _active[pos]
	var destroyed: bool = block.take_hit()

	if destroyed:
		_release(pos)

	return destroyed
