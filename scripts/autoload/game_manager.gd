extends Node
## GoDig Game Manager
##
## Central game state manager with grid constants and utilities.

signal game_started
signal game_over
signal depth_updated(depth: int)
signal coins_changed(new_amount: int)
signal coins_added(amount: int)
signal coins_spent(amount: int)

# Grid constants (128x128 blocks, same size as player)
const BLOCK_SIZE := 128
const GRID_WIDTH := 5  # 720 / 128 = 5.625, use 5 blocks centered
const GRID_OFFSET_X := 40  # Center the grid: (720 - 5*128) / 2 = 40
const SURFACE_ROW := 7  # Dirt starts at row 7 (bottom quarter of 1280/128 = 10 rows)
const VIEWPORT_WIDTH := 720
const VIEWPORT_HEIGHT := 1280

var is_running: bool = false
var current_depth: int = 0
var coins: int = 0


func _ready() -> void:
	print("[GameManager] Ready")


func start_game() -> void:
	is_running = true
	current_depth = 0
	coins = 0
	game_started.emit()
	coins_changed.emit(coins)
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


# ============================================
# CURRENCY SYSTEM
# ============================================

## Add coins to the player's wallet
func add_coins(amount: int) -> void:
	if amount <= 0:
		return
	coins += amount
	coins_added.emit(amount)
	coins_changed.emit(coins)


## Spend coins if player has enough. Returns true if successful.
func spend_coins(amount: int) -> bool:
	if amount <= 0:
		return false
	if coins < amount:
		return false
	coins -= amount
	coins_spent.emit(amount)
	coins_changed.emit(coins)
	return true


## Check if player can afford a purchase
func can_afford(amount: int) -> bool:
	return coins >= amount


## Get current coin balance
func get_coins() -> int:
	return coins


## Set coins directly (for save/load)
func set_coins(amount: int) -> void:
	coins = maxi(0, amount)
	coins_changed.emit(coins)
