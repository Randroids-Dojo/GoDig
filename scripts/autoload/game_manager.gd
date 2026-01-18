extends Node
## GoDig Game Manager
##
## Central game state manager with grid constants and utilities.

signal game_started
signal game_over
signal depth_updated(depth: int)

# Grid constants (128x128 blocks, same size as player)
const BLOCK_SIZE := 128
const GRID_OFFSET_X := 0  # No offset for infinite horizontal terrain
const SURFACE_ROW := 7  # Dirt starts at row 7 (bottom quarter of 1280/128 = 10 rows)
const VIEWPORT_WIDTH := 720
const VIEWPORT_HEIGHT := 1280

# Legacy constant kept for backwards compatibility (infinite terrain has no width limit)
const GRID_WIDTH := 999999

var is_running: bool = false
var current_depth: int = 0


func _ready() -> void:
	print("[GameManager] Ready")


func start_game() -> void:
	is_running = true
	current_depth = 0
	game_started.emit()
	print("[GameManager] Game started")


func end_game() -> void:
	is_running = false
	game_over.emit()
	print("[GameManager] Game over")


func update_depth(depth: int) -> void:
	current_depth = depth
	depth_updated.emit(depth)


# Utility functions for grid coordinate conversion
static func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * BLOCK_SIZE + GRID_OFFSET_X,
		grid_pos.y * BLOCK_SIZE
	)


static func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		int((world_pos.x - GRID_OFFSET_X) / BLOCK_SIZE),
		int(world_pos.y / BLOCK_SIZE)
	)
