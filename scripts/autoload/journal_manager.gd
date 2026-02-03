extends Node
## JournalManager - Tracks collected lore entries and spawns lore in the world.
##
## Lore entries are discoverable items found while mining. Once collected,
## they're added to the journal permanently and can be read from the museum.

const LoreData = preload("res://resources/lore/lore_data.gd")

signal lore_collected(lore_id: String)
signal journal_updated
signal lore_spawned(grid_pos: Vector2i, lore_id: String)

## Dictionary of collected lore IDs -> first collection timestamp
var collected_lore: Dictionary = {}

## All available lore in the game (loaded from resources)
var _all_lore: Array = []

## Lore sorted by entry number for ordered display
var _lore_by_entry: Array = []

## Lore grouped by type
var _lore_by_type: Dictionary = {}  # type string -> Array[LoreData]

## Spawned lore positions (grid_pos -> lore_id) - prevents double spawning
var _spawned_lore: Dictionary = {}

## Opened lore positions (grid_pos -> bool) - persisted across sessions
var _opened_lore: Dictionary = {}

## RNG for spawn rolls
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	print("[JournalManager] Ready")


## Called after DataRegistry is ready to load lore resources
func initialize_lore() -> void:
	_load_lore()
	print("[JournalManager] Initialized - %d lore entries available" % _all_lore.size())


func _load_lore() -> void:
	## Load all lore resources from DataRegistry
	_all_lore.clear()
	_lore_by_type.clear()

	if DataRegistry == null:
		push_warning("[JournalManager] DataRegistry not available")
		return

	# Get all lore items from registry
	var all_items = DataRegistry.get_all_items()
	for item in all_items:
		if item.category == "lore":
			_all_lore.append(item)

	# Sort by entry number
	_lore_by_entry = _all_lore.duplicate()
	_lore_by_entry.sort_custom(func(a, b): return a.entry_number < b.entry_number)

	# Group by type
	for lore in _all_lore:
		var lore_type: String = lore.lore_type
		if not _lore_by_type.has(lore_type):
			_lore_by_type[lore_type] = []
		_lore_by_type[lore_type].append(lore)


## Check if a lore entry has been collected
func is_collected(lore_id: String) -> bool:
	return collected_lore.has(lore_id)


## Mark a lore entry as collected
func collect_lore(lore_id: String) -> void:
	if is_collected(lore_id):
		return  # Already collected

	collected_lore[lore_id] = Time.get_unix_time_from_system()
	lore_collected.emit(lore_id)
	journal_updated.emit()

	# Add to inventory for display
	if InventoryManager:
		InventoryManager.add_item_by_id(lore_id, 1)

	# Trigger achievement/analytics
	if AchievementManager:
		AchievementManager.check_lore_collection(get_collected_count())
	if AnalyticsManager:
		AnalyticsManager.track_lore_found(lore_id)

	print("[JournalManager] Lore collected: %s" % lore_id)


## Get the number of collected lore entries
func get_collected_count() -> int:
	return collected_lore.size()


## Get the total number of lore entries in the game
func get_total_count() -> int:
	return _all_lore.size()


## Get collection progress as a percentage (0.0 to 1.0)
func get_collection_progress() -> float:
	if _all_lore.size() == 0:
		return 0.0
	return float(collected_lore.size()) / float(_all_lore.size())


## Get all lore entries (for journal display)
func get_all_lore() -> Array:
	return _lore_by_entry.duplicate()


## Get collected lore entries only (sorted by entry number)
func get_collected_lore() -> Array:
	var result: Array = []
	for lore in _lore_by_entry:
		if is_collected(lore.id):
			result.append(lore)
	return result


## Get lore by type
func get_lore_by_type(lore_type: String) -> Array:
	if _lore_by_type.has(lore_type):
		return _lore_by_type[lore_type].duplicate()
	return []


## Get lore data by ID
func get_lore(lore_id: String) -> LoreData:
	for lore in _all_lore:
		if lore.id == lore_id:
			return lore
	return null


## Check if a lore entry can spawn at a given depth
func can_lore_spawn_at_depth(lore: LoreData, depth: int) -> bool:
	if lore == null:
		return false
	return lore.can_spawn_at_depth(depth)


## Roll for lore spawn during chunk generation
## Returns the lore ID if one should spawn, empty string otherwise
func roll_lore_spawn(grid_pos: Vector2i, depth: int, world_seed: int) -> String:
	# Don't spawn too shallow
	if depth < 20:
		return ""

	# Don't spawn if already opened at this position
	if _opened_lore.has(grid_pos):
		return ""

	# Don't spawn if already spawned at this position
	if _spawned_lore.has(grid_pos):
		return ""

	# Use position-based seed for deterministic spawning
	_rng.seed = world_seed + grid_pos.x * 127391 + grid_pos.y * 918273

	# Get eligible lore for this depth
	var eligible: Array = []
	for lore in _all_lore:
		if lore.can_spawn_at_depth(depth):
			eligible.append(lore)

	if eligible.is_empty():
		return ""

	# Roll for each eligible lore (check spawn chance)
	for lore in eligible:
		var roll := _rng.randf()
		if roll < lore.spawn_chance:
			_spawned_lore[grid_pos] = lore.id
			lore_spawned.emit(grid_pos, lore.id)
			return lore.id

	return ""


## Mark a lore pickup as opened/collected
func mark_lore_opened(grid_pos: Vector2i) -> void:
	_opened_lore[grid_pos] = true


## Check if lore was already opened at position
func was_lore_opened(grid_pos: Vector2i) -> bool:
	return _opened_lore.has(grid_pos)


## Check if lore is spawned at position
func has_spawned_lore(grid_pos: Vector2i) -> bool:
	return _spawned_lore.has(grid_pos)


## Get spawned lore ID at position
func get_spawned_lore_id(grid_pos: Vector2i) -> String:
	return _spawned_lore.get(grid_pos, "")


## Remove spawned lore (chunk unload)
func remove_spawned_lore(grid_pos: Vector2i) -> void:
	_spawned_lore.erase(grid_pos)


## Reset for new game
func reset() -> void:
	collected_lore.clear()
	_spawned_lore.clear()
	_opened_lore.clear()
	journal_updated.emit()
	print("[JournalManager] Reset for new game")


# ============================================
# SAVE/LOAD
# ============================================

## Get save data
func get_save_data() -> Dictionary:
	# Convert opened lore positions to serializable format
	var opened_list: Array = []
	for pos in _opened_lore:
		opened_list.append([pos.x, pos.y])

	return {
		"collected_lore": collected_lore.duplicate(),
		"opened_lore": opened_list,
	}


## Load from save data
func load_save_data(data: Dictionary) -> void:
	collected_lore.clear()
	_opened_lore.clear()

	# Load collected lore
	var collected = data.get("collected_lore", {})
	if collected is Dictionary:
		collected_lore = collected.duplicate()

	# Load opened positions
	var opened_list = data.get("opened_lore", [])
	for item in opened_list:
		if item is Array and item.size() == 2:
			_opened_lore[Vector2i(item[0], item[1])] = true

	journal_updated.emit()
	print("[JournalManager] Loaded - %d collected, %d opened" % [collected_lore.size(), _opened_lore.size()])


# ============================================
# STATISTICS
# ============================================

## Get journal statistics for achievements/tracking
func get_stats() -> Dictionary:
	var stats_by_type := {}
	for lore_type in _lore_by_type:
		var lore_array: Array = _lore_by_type[lore_type]
		var total: int = lore_array.size()
		var collected_count: int = 0
		for lore in lore_array:
			if is_collected(lore.id):
				collected_count += 1
		stats_by_type[lore_type] = {
			"total": total,
			"collected": collected_count,
		}

	return {
		"total_lore": _all_lore.size(),
		"collected_lore": collected_lore.size(),
		"completion_percent": get_collection_progress() * 100.0,
		"by_type": stats_by_type,
	}
