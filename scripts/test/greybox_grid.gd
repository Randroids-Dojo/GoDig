extends Node2D
## Minimal greybox grid for core mining test.
## Simple block management without chunks, ores, or complexity.

const BLOCK_SIZE := 128
const GRID_WIDTH := 20
const GRID_HEIGHT := 30
const SURFACE_ROW := 5  # Blocks start at row 5

const GreyboxBlockScript = preload("res://scripts/test/greybox_block.gd")

signal block_destroyed(block_pos: Vector2i)
signal block_hit(block_pos: Vector2i)

var _blocks: Dictionary = {}  # Vector2i -> ColorRect
var _pool: Array = []
const POOL_SIZE := 200


func _ready() -> void:
	_preallocate_pool()
	_generate_terrain()
	print("[GreyboxGrid] Terrain generated")


func _preallocate_pool() -> void:
	for i in POOL_SIZE:
		var block := ColorRect.new()
		block.set_script(GreyboxBlockScript)
		block.visible = false
		add_child(block)
		_pool.push_back(block)


func _acquire(grid_pos: Vector2i) -> ColorRect:
	var block: ColorRect
	if _pool.is_empty():
		block = ColorRect.new()
		block.set_script(GreyboxBlockScript)
		add_child(block)
	else:
		block = _pool.pop_back()

	block.activate(grid_pos)
	_blocks[grid_pos] = block
	return block


func _release(grid_pos: Vector2i) -> void:
	if _blocks.has(grid_pos):
		var block = _blocks[grid_pos]
		block.deactivate()
		_pool.push_back(block)
		_blocks.erase(grid_pos)


func _generate_terrain() -> void:
	## Generate simple grid of blocks
	for x in range(GRID_WIDTH):
		for y in range(SURFACE_ROW, GRID_HEIGHT):
			var grid_pos := Vector2i(x, y)
			_acquire(grid_pos)


func has_block(pos: Vector2i) -> bool:
	return _blocks.has(pos)


func get_block(pos: Vector2i):
	return _blocks.get(pos)


func hit_block(pos: Vector2i, damage: float) -> bool:
	## Hit a block with damage, return true if destroyed
	if not _blocks.has(pos):
		return true  # Already empty

	var block = _blocks[pos]
	var destroyed := block.take_hit(damage)

	if destroyed:
		block_destroyed.emit(pos)
		_release(pos)
	else:
		block_hit.emit(pos)

	return destroyed
