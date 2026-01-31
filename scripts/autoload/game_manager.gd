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
signal layer_entered(layer_name: String)
signal coins_changed(new_amount: int)
signal coins_added(amount: int)
signal coins_spent(amount: int)
signal shop_requested
signal shop_closed
signal building_unlocked(building_id: String, building_name: String)
signal max_depth_updated(depth: int)
signal tutorial_state_changed(new_state: int)
signal tutorial_completed

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
var max_depth_reached: int = 0
var unlocked_buildings: Array[String] = []

## Tutorial state tracking
enum TutorialState { MOVEMENT, DIGGING, COLLECTING, SELLING, COMPLETE }
var tutorial_state: TutorialState = TutorialState.MOVEMENT
var tutorial_complete: bool = false

## Reference to the player node (set via register_player)
var player: CharacterBody2D = null

## Track reached depth milestones for one-time triggers
var _reached_milestones: Array[int] = []

## Track current layer for transition notifications
var _current_layer_id: String = ""

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

	# Check for layer transitions
	_check_layer_transition(depth)

	# Check for depth milestones and building unlocks (only when going deeper)
	if depth > old_depth:
		_check_depth_milestones(depth)
		update_max_depth(depth)


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

	# Play coin pickup sound
	if SoundManager:
		SoundManager.play_coin_pickup()


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
			# Play milestone sound
			if SoundManager:
				SoundManager.play_milestone()
			# Auto-save on milestone
			SaveManager.save_game()


## Reset milestones (for new game)
func reset_milestones() -> void:
	_reached_milestones.clear()
	_current_layer_id = ""  # Also reset layer tracking
	reset_buildings()  # Also reset building unlocks


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
# LAYER TRANSITIONS
# ============================================

## Check if player has entered a new layer
func _check_layer_transition(depth: int) -> void:
	var layer = DataRegistry.get_layer_at_depth(depth)
	if layer == null:
		return

	var new_layer_id: String = layer.id
	if new_layer_id != _current_layer_id:
		var old_layer_id := _current_layer_id
		_current_layer_id = new_layer_id
		# Only emit if we had a previous layer (skip initial spawn)
		if old_layer_id != "":
			layer_entered.emit(layer.display_name)
			print("[GameManager] Entered new layer: %s" % layer.display_name)


## Reset current layer (for new game)
func reset_layer() -> void:
	_current_layer_id = ""


## Get current layer name
func get_current_layer_name() -> String:
	var layer = DataRegistry.get_layer_at_depth(current_depth)
	if layer:
		return layer.display_name
	return ""


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


# ============================================
# BUILDING UNLOCK SYSTEM
# ============================================

## Building unlock order - buildings unlock at specific depth milestones
const BUILDING_UNLOCK_ORDER := [
	{"id": "mine_entrance", "name": "Mine Entrance", "unlock_depth": 0},
	{"id": "general_store", "name": "General Store", "unlock_depth": 0},
	{"id": "supply_store", "name": "Supply Store", "unlock_depth": 0},
	{"id": "blacksmith", "name": "Blacksmith", "unlock_depth": 50},
	{"id": "equipment_shop", "name": "Equipment Shop", "unlock_depth": 100},
	{"id": "gem_appraiser", "name": "Gem Appraiser", "unlock_depth": 200},
	{"id": "gadget_shop", "name": "Gadget Shop", "unlock_depth": 300},
	{"id": "refinery", "name": "Refinery", "unlock_depth": 400},
	{"id": "warehouse", "name": "Warehouse", "unlock_depth": 500},
	{"id": "elevator", "name": "Elevator", "unlock_depth": 500},
	{"id": "research_lab", "name": "Research Lab", "unlock_depth": 600},
]


## Update max depth and check for building unlocks
func update_max_depth(depth: int) -> void:
	if depth > max_depth_reached:
		max_depth_reached = depth
		max_depth_updated.emit(max_depth_reached)
		_check_building_unlocks()


## Check if any new buildings should be unlocked based on max depth
func _check_building_unlocks() -> void:
	for building in BUILDING_UNLOCK_ORDER:
		var building_id: String = building["id"]
		if building_id in unlocked_buildings:
			continue
		if max_depth_reached >= building["unlock_depth"]:
			unlocked_buildings.append(building_id)
			building_unlocked.emit(building_id, building["name"])
			print("[GameManager] Building unlocked: %s" % building["name"])


## Check if a specific building is unlocked
func is_building_unlocked(building_id: String) -> bool:
	return building_id in unlocked_buildings


## Get all unlocked building IDs
func get_unlocked_buildings() -> Array[String]:
	return unlocked_buildings.duplicate()


## Set unlocked buildings (for save/load)
func set_unlocked_buildings(buildings: Array) -> void:
	unlocked_buildings.clear()
	for b in buildings:
		if b is String:
			unlocked_buildings.append(b)


## Set max depth reached (for save/load)
func set_max_depth_reached(depth: int) -> void:
	max_depth_reached = depth
	# Check for any buildings that should be unlocked at this depth
	_check_building_unlocks()


## Reset buildings (for new game)
func reset_buildings() -> void:
	unlocked_buildings.clear()
	max_depth_reached = 0
	# Unlock starting buildings
	_check_building_unlocks()


# ============================================
# TUTORIAL SYSTEM
# ============================================

## Advance the tutorial to a new state
func advance_tutorial(new_state: TutorialState) -> void:
	if tutorial_complete:
		return
	if new_state <= tutorial_state and new_state != TutorialState.COMPLETE:
		return  # Don't go backwards

	tutorial_state = new_state
	tutorial_state_changed.emit(new_state)
	print("[GameManager] Tutorial advanced to: %s" % TutorialState.keys()[new_state])

	if new_state == TutorialState.COMPLETE:
		complete_tutorial()


## Mark the tutorial as complete
func complete_tutorial() -> void:
	if tutorial_complete:
		return
	tutorial_complete = true
	tutorial_state = TutorialState.COMPLETE
	tutorial_completed.emit()
	print("[GameManager] Tutorial completed!")
	# Save immediately so it persists
	if SaveManager:
		SaveManager.save_game()


## Check if tutorial is active (not yet complete)
func is_tutorial_active() -> bool:
	return not tutorial_complete


## Reset tutorial (for new game)
func reset_tutorial() -> void:
	tutorial_state = TutorialState.MOVEMENT
	tutorial_complete = false


## Set tutorial state from save data
func set_tutorial_state(state: int, complete: bool) -> void:
	tutorial_state = state as TutorialState
	tutorial_complete = complete


## Get tutorial state for save data
func get_tutorial_state() -> Dictionary:
	return {
		"state": tutorial_state,
		"complete": tutorial_complete
	}
