extends Node
## GoDig Game Manager
##
## Central game state manager with grid constants, game state machine,
## scene management, and cross-system communication.

# Preload TileSetSetup to avoid class_name resolution issues during autoload init
const TileSetSetupScript = preload("res://scripts/setup/tileset_setup.gd")

# ============================================
# GAME STATE MACHINE
# ============================================

enum GameState { MENU, PLAYING, PAUSED, SHOP, GAME_OVER }

var state: GameState = GameState.MENU

signal state_changed(new_state: GameState)
signal game_started
signal game_over
signal depth_updated(depth: int)
signal depth_milestone_reached(depth: int)
signal coins_changed(new_amount: int)
signal coins_added(amount: int)
signal coins_spent(amount: int)
signal shop_requested
signal shop_closed

# Grid constants (128x128 blocks, same size as player)
const BLOCK_SIZE := 128
const GRID_OFFSET_X := 0  # No offset for infinite horizontal terrain
const SURFACE_ROW := 7  # Dirt starts at row 7 (bottom quarter of 1280/128 = 10 rows)
const VIEWPORT_WIDTH := 720
const VIEWPORT_HEIGHT := 1280

# Legacy constant kept for backwards compatibility (infinite terrain has no width limit)
const GRID_WIDTH := 999999

# Scene paths for navigation
const SCENE_MAIN_MENU := "res://scenes/ui/main_menu.tscn"
const SCENE_GAME := "res://scenes/main.tscn"
const SCENE_GAME_OVER := "res://scenes/ui/game_over.tscn"

var is_running: bool = false
var current_depth: int = 0
var coins: int = 0

## Reference to the player node (set via register_player)
var player: CharacterBody2D = null

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
	set_state(GameState.GAME_OVER)
	game_over.emit()
	print("[GameManager] Game over")


# ============================================
# GAME STATE MANAGEMENT
# ============================================

## Set the game state with proper pause handling
func set_state(new_state: GameState) -> void:
	var old_state := state
	if old_state == new_state:
		return

	state = new_state
	state_changed.emit(new_state)

	match new_state:
		GameState.PLAYING:
			get_tree().paused = false
			is_running = true
		GameState.PAUSED, GameState.SHOP:
			get_tree().paused = true
		GameState.GAME_OVER:
			get_tree().paused = true
			is_running = false
		GameState.MENU:
			get_tree().paused = false
			is_running = false


## Check if the game is in PLAYING state
func is_playing() -> bool:
	return state == GameState.PLAYING


## Pause the game (only if currently playing)
func pause_game() -> void:
	if state == GameState.PLAYING:
		set_state(GameState.PAUSED)


## Resume the game (only if currently paused)
func resume_game() -> void:
	if state == GameState.PAUSED:
		set_state(GameState.PLAYING)


## Toggle between paused and playing states
func toggle_pause() -> void:
	if state == GameState.PLAYING:
		pause_game()
	elif state == GameState.PAUSED:
		resume_game()


# ============================================
# SCENE MANAGEMENT
# ============================================

## Navigate to main menu
func go_to_main_menu() -> void:
	set_state(GameState.MENU)
	get_tree().change_scene_to_file(SCENE_MAIN_MENU)


## Start a new game in the current save slot
func start_new_game(slot: int = -1) -> void:
	var target_slot := slot if slot >= 0 else SaveManager.current_slot
	if target_slot < 0:
		target_slot = 0  # Default to slot 0
	SaveManager.new_game(target_slot)
	_load_game_scene()


## Continue an existing game from save
func continue_game(slot: int = -1) -> void:
	var target_slot := slot if slot >= 0 else SaveManager.current_slot
	if target_slot < 0 or not SaveManager.has_save(target_slot):
		push_warning("[GameManager] No save to continue in slot %d" % target_slot)
		return
	SaveManager.load_game(target_slot)
	_load_game_scene()


## Load the game scene and transition to PLAYING state
func _load_game_scene() -> void:
	get_tree().change_scene_to_file(SCENE_GAME)
	# Wait for scene to be ready before changing state
	await get_tree().process_frame
	set_state(GameState.PLAYING)
	game_started.emit()


# ============================================
# PLAYER REFERENCE
# ============================================

## Register the player node (called by player on _ready)
func register_player(p: CharacterBody2D) -> void:
	player = p
	print("[GameManager] Player registered")


## Unregister the player (called when player is freed)
func unregister_player() -> void:
	player = null


## Get the player's world position (returns Vector2.ZERO if no player)
func get_player_position() -> Vector2:
	if player:
		return player.position
	return Vector2.ZERO


## Get the player's grid position
func get_player_grid_position() -> Vector2i:
	return world_to_grid(get_player_position())


# ============================================
# SHOP/UI INTEGRATION
# ============================================

## Open the shop UI
func open_shop() -> void:
	set_state(GameState.SHOP)
	shop_requested.emit()


## Close the shop UI and resume playing
func close_shop() -> void:
	set_state(GameState.PLAYING)
	shop_closed.emit()


# ============================================
# DEPTH TRACKING
# ============================================

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


# ============================================
# MOBILE LIFECYCLE
# ============================================

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED:
			# Mobile: app went to background - save and pause
			if state == GameState.PLAYING:
				SaveManager.save_game(true)  # Force save
				pause_game()
		NOTIFICATION_APPLICATION_RESUMED:
			# Mobile: app returned to foreground - stay paused, player can resume
			pass
