extends Node
## SaveManager autoload singleton for persistent save/load operations.
##
## Handles all save file operations including:
## - Player state (position, inventory, coins, progression)
## - World state (chunk modifications stored as binary files)
## - Multiple save slots (3 slots) with auto-save support
## - Mobile pause handling for emergency saves

const SaveDataClass = preload("res://resources/save/save_data.gd")

signal save_started
signal save_completed(success: bool)
signal load_started
signal load_completed(success: bool)
signal save_slot_changed(slot: int)
signal auto_save_triggered

const SAVE_DIR := "user://saves/"
const CHUNKS_DIR := "user://chunks/"
const MAX_SLOTS := 3
const AUTO_SAVE_INTERVAL := 60.0  # Seconds between auto-saves

var current_slot: int = -1
var current_save: SaveDataClass = null
var auto_save_enabled: bool = true

var _is_saving: bool = false
var _auto_save_timer: float = 0.0
var _session_start_time: int = 0
var _last_save_time_ms: int = 0

const MIN_SAVE_INTERVAL_MS := 5000  # 5 seconds minimum between saves (debounce)


func _ready() -> void:
	# Ensure directories exist
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	DirAccess.make_dir_recursive_absolute(CHUNKS_DIR)
	_session_start_time = int(Time.get_unix_time_from_system())
	print("[SaveManager] Ready")


func _process(delta: float) -> void:
	# Update playtime if a save is loaded
	if current_save != null:
		current_save.update_playtime(delta)

	# Auto-save timer
	if auto_save_enabled and current_save != null:
		_auto_save_timer += delta
		if _auto_save_timer >= AUTO_SAVE_INTERVAL:
			_auto_save_timer = 0.0
			auto_save_triggered.emit()
			save_game()


func _notification(what: int) -> void:
	# Emergency save on mobile when app is paused/backgrounded
	if what == NOTIFICATION_APPLICATION_PAUSED:
		print("[SaveManager] App paused - emergency save")
		save_game(true)  # Force save, bypass debounce
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		# Also save on focus loss (desktop)
		if current_save != null:
			save_game(true)  # Force save, bypass debounce
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Window closing - force save
		if current_save != null:
			save_game(true)


## Get file path for a save slot
func get_save_path(slot: int) -> String:
	return SAVE_DIR + "slot_%d.tres" % slot


## Check if a save exists in a slot
func has_save(slot: int) -> bool:
	return ResourceLoader.exists(get_save_path(slot))


## Get save info for slot selection UI (returns null if no save)
func get_save_info(slot: int) -> SaveDataClass:
	if not has_save(slot):
		return null
	# Load just for info, don't set as current
	return ResourceLoader.load(get_save_path(slot)) as SaveDataClass


## Get summaries for all slots (for save selection UI)
func get_all_slot_summaries() -> Array:
	var summaries := []
	for i in range(MAX_SLOTS):
		var info := get_save_info(i)
		if info:
			summaries.append({
				"slot": i,
				"exists": true,
				"summary": info.get_summary(),
				"last_save_time": info.last_save_time,
			})
		else:
			summaries.append({
				"slot": i,
				"exists": false,
				"summary": "Empty Slot",
				"last_save_time": 0,
			})
	return summaries


## Save the current game state (with optional debounce bypass for critical saves)
func save_game(force: bool = false) -> bool:
	if _is_saving:
		push_warning("[SaveManager] Save already in progress")
		return false

	if current_save == null:
		push_warning("[SaveManager] No save loaded, cannot save")
		return false

	if current_slot < 0 or current_slot >= MAX_SLOTS:
		push_error("[SaveManager] Invalid slot: %d" % current_slot)
		return false

	# Debounce: skip if too soon after last save (unless forced)
	var current_time_ms := Time.get_ticks_msec()
	if not force and (current_time_ms - _last_save_time_ms) < MIN_SAVE_INTERVAL_MS:
		return false  # Skip, too soon

	_is_saving = true
	_last_save_time_ms = current_time_ms
	save_started.emit()

	# Update save metadata
	current_save.last_save_time = int(Time.get_unix_time_from_system())

	# Collect current state from game systems
	_collect_game_state()

	# Write to file
	var path := get_save_path(current_slot)
	var error := ResourceSaver.save(current_save, path)

	if error != OK:
		push_error("[SaveManager] Failed to save: %s" % error_string(error))
		_is_saving = false
		save_completed.emit(false)
		return false

	print("[SaveManager] Saved to slot %d" % current_slot)
	_is_saving = false
	save_completed.emit(true)
	return true


## Load a save from a slot
func load_game(slot: int) -> bool:
	if slot < 0 or slot >= MAX_SLOTS:
		push_error("[SaveManager] Invalid slot: %d" % slot)
		return false

	var path := get_save_path(slot)
	if not ResourceLoader.exists(path):
		push_warning("[SaveManager] No save in slot %d" % slot)
		return false

	load_started.emit()

	var loaded = ResourceLoader.load(path)
	if loaded == null or not loaded is SaveDataClass:
		push_error("[SaveManager] Failed to load save from slot %d" % slot)
		load_completed.emit(false)
		return false

	current_slot = slot
	current_save = loaded

	# Handle version migrations
	_migrate_if_needed()

	# Apply loaded state to game systems
	_apply_game_state()

	save_slot_changed.emit(current_slot)
	load_completed.emit(true)
	print("[SaveManager] Loaded slot %d" % slot)
	return true


## Start a new game in a slot
func new_game(slot: int, slot_name: String = "") -> bool:
	if slot < 0 or slot >= MAX_SLOTS:
		push_error("[SaveManager] Invalid slot: %d" % slot)
		return false

	# Delete any existing save and chunks
	delete_save(slot)

	current_slot = slot
	current_save = SaveDataClass.create_new(slot_name)

	# Initial save
	var success := save_game()

	if success:
		save_slot_changed.emit(current_slot)
		print("[SaveManager] New game in slot %d" % slot)

	return success


## Delete a save slot
func delete_save(slot: int) -> void:
	if slot < 0 or slot >= MAX_SLOTS:
		return

	# Delete save file
	var path := get_save_path(slot)
	if FileAccess.file_exists(path):
		var err := DirAccess.remove_absolute(path)
		if err != OK:
			push_warning("[SaveManager] Failed to delete save file: %s" % error_string(err))

	# Delete chunk data
	_clear_chunk_data(slot)

	# Clear current if this was the loaded slot
	if current_slot == slot:
		current_slot = -1
		current_save = null

	print("[SaveManager] Deleted slot %d" % slot)


## Collect game state from various managers before saving
func _collect_game_state() -> void:
	if current_save == null:
		return

	# Collect from GameManager
	if GameManager:
		current_save.coins = GameManager.coins
		current_save.current_depth = GameManager.current_depth
		# Save depth milestones
		current_save.depth_milestones_reached.clear()
		for milestone in GameManager.get_reached_milestones():
			current_save.depth_milestones_reached.append(milestone)

	# Collect from InventoryManager
	if InventoryManager:
		current_save.inventory = InventoryManager.get_inventory_dict()
		current_save.max_slots = InventoryManager.max_slots


## Apply loaded game state to various managers
func _apply_game_state() -> void:
	if current_save == null:
		return

	# Apply to GameManager
	if GameManager:
		GameManager.set_coins(current_save.coins)
		GameManager.current_depth = current_save.current_depth
		# Restore depth milestones
		GameManager.set_reached_milestones(current_save.depth_milestones_reached)

	# Apply to InventoryManager
	if InventoryManager:
		InventoryManager.load_from_dict(current_save.inventory)
		InventoryManager.max_slots = current_save.max_slots


## Run migration if save version is old
func _migrate_if_needed() -> void:
	if current_save == null:
		return

	if current_save.save_version < SaveDataClass.CURRENT_VERSION:
		print("[SaveManager] Migrating save from v%d to v%d" % [
			current_save.save_version,
			SaveDataClass.CURRENT_VERSION
		])

		# Apply migrations here as versions increase
		# Example:
		# if current_save.save_version < 2:
		#     _migrate_v1_to_v2()

		current_save.save_version = SaveDataClass.CURRENT_VERSION
		save_game()


## Clear all chunk data for a slot
func _clear_chunk_data(slot: int) -> void:
	var chunk_path := CHUNKS_DIR + "slot_%d/" % slot
	if not DirAccess.dir_exists_absolute(chunk_path):
		return

	var dir := DirAccess.open(chunk_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			dir.remove(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

	# Remove the directory itself
	DirAccess.remove_absolute(chunk_path)


# ============================================
# CHUNK PERSISTENCE INTERFACE
# ============================================

## Get file path for a chunk
func get_chunk_path(slot: int, chunk_coord: Vector2i) -> String:
	return CHUNKS_DIR + "slot_%d/chunk_%d_%d.dat" % [slot, chunk_coord.x, chunk_coord.y]


## Save chunk modifications to binary file
func save_chunk(chunk_coord: Vector2i, modified_tiles: Dictionary) -> bool:
	if current_slot < 0:
		return false

	if modified_tiles.is_empty():
		# Nothing to save, remove file if it exists
		var path := get_chunk_path(current_slot, chunk_coord)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
		return true

	var path := get_chunk_path(current_slot, chunk_coord)

	# Ensure directory exists
	var dir_path := path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(dir_path)

	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("[SaveManager] Failed to open chunk file for writing: %s" % path)
		return false

	# Store with compression
	file.store_var(modified_tiles, true)
	file.close()
	return true


## Load chunk modifications from binary file
func load_chunk(chunk_coord: Vector2i) -> Dictionary:
	if current_slot < 0:
		return {}

	var path := get_chunk_path(current_slot, chunk_coord)
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("[SaveManager] Failed to open chunk file: %s" % path)
		return {}

	var data = file.get_var(true)
	file.close()

	if data is Dictionary:
		return data
	return {}


## Check if a chunk has saved modifications
func has_modified_chunk(chunk_coord: Vector2i) -> bool:
	if current_slot < 0:
		return false
	return FileAccess.file_exists(get_chunk_path(current_slot, chunk_coord))


# ============================================
# CONVENIENCE METHODS
# ============================================

## Check if a game is currently loaded
func is_game_loaded() -> bool:
	return current_save != null and current_slot >= 0


## Get the current world seed (for terrain generation)
func get_world_seed() -> int:
	if current_save == null:
		return 0
	return current_save.world_seed


## Get player starting position
func get_player_position() -> Vector2i:
	if current_save == null:
		return Vector2i(2, 6)
	return current_save.player_grid_position


## Save player position (called when player moves)
func set_player_position(pos: Vector2i) -> void:
	if current_save != null:
		current_save.player_grid_position = pos
