extends Node
## GoDig Game Manager
##
## Central game state manager with grid constants and utilities.

signal game_started
signal game_over
signal depth_updated(depth: int)

# Grid constants
const BLOCK_SIZE := 64
const GRID_WIDTH := 11  # (720 - 16) / 64 = 11 blocks
const GRID_OFFSET_X := 8  # Center the grid: (720 - 11*64) / 2 = 8
const SURFACE_ROW := 14  # Dirt starts at row 14 (bottom quarter of 1280/64 = 20 rows)
const VIEWPORT_WIDTH := 720
const VIEWPORT_HEIGHT := 1280

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
