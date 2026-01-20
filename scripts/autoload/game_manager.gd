extends Node
## GoDig Game Manager
##
## Central game state manager with grid constants and utilities.

# Preload TileSetSetup to avoid class_name resolution issues during autoload init
const TileSetSetupScript = preload("res://scripts/setup/tileset_setup.gd")

signal game_started
signal game_over
signal depth_updated(depth: int)
signal depth_milestone_reached(depth: int)
signal coins_changed(new_amount: int)
signal coins_added(amount: int)
signal coins_spent(amount: int)

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
var coins: int = 0

## Track reached depth milestones for one-time triggers
var _reached_milestones: Array[int] = []

## Depth milestones that trigger auto-save (first time only)
const DEPTH_MILESTONES := [10, 25, 50, 100, 150, 200, 300, 500, 750, 1000]

## Cached terrain tileset (loaded on ready)
var terrain_tileset: TileSet = null


func _ready() -> void:
	_init_tileset()
	print("[GameManager] Ready")


## Initialize the terrain TileSet (load or create)
func _init_tileset() -> void:
	terrain_tileset = TileSetSetupScript.get_or_create_tileset()
	if terrain_tileset:
		print("[GameManager] TileSet initialized with ", terrain_tileset.get_source_count(), " sources")


func start_game() -> void:
	is_running = true
	current_depth = 0
	coins = 0
	reset_milestones()
	game_started.emit()
	coins_changed.emit(coins)
	print("[GameManager] Game started")


func end_game() -> void:
	is_running = false
	game_over.emit()
	print("[GameManager] Game over")


func update_depth(depth: int) -> void:
	var old_depth := current_depth
	current_depth = depth
	depth_updated.emit(depth)

	# Check for depth milestones (only trigger once per milestone)
	if depth > old_depth:
		_check_depth_milestones(depth)


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


# ============================================
# TILESET ACCESS
# ============================================

## Get the terrain TileSet (creates if not yet initialized)
func get_terrain_tileset() -> TileSet:
	if terrain_tileset == null:
		_init_tileset()
	return terrain_tileset


# ============================================
# DEPTH MILESTONES
# ============================================

## Check if player has reached a new depth milestone
func _check_depth_milestones(depth: int) -> void:
	for milestone in DEPTH_MILESTONES:
		if depth >= milestone and milestone not in _reached_milestones:
			_reached_milestones.append(milestone)
			depth_milestone_reached.emit(milestone)
			print("[GameManager] Depth milestone reached: %dm" % milestone)
			# Auto-save on milestone
			SaveManager.save_game()


## Reset milestones (for new game)
func reset_milestones() -> void:
	_reached_milestones.clear()


## Set reached milestones (for save/load)
func set_reached_milestones(milestones: Array) -> void:
	_reached_milestones.clear()
	for m in milestones:
		if m is int:
			_reached_milestones.append(m)


## Get reached milestones (for save/load)
func get_reached_milestones() -> Array[int]:
	return _reached_milestones
