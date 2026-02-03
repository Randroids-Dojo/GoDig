extends Node
## TreasureRoomManager - Manages hidden treasure room generation and discovery.
##
## Hidden treasure rooms are special carved-out areas that spawn rarely in
## caves, creating memorable discovery moments. Rooms contain valuable loot
## scaled to depth.

signal room_discovered(grid_pos: Vector2i, room_type: String)
signal room_generated(grid_pos: Vector2i, room_type: String)
signal room_looted(grid_pos: Vector2i, loot: Array)

## Room type definitions
enum RoomType {
	SUPPLY_CACHE,   # Small 3x3, contains traversal items
	ORE_POCKET,     # Medium 5x5, contains depth-tier ore
	ANCIENT_VAULT,  # Large 7x7, contains artifact + premium loot
}

## Room configuration by type
const ROOM_CONFIG := {
	RoomType.SUPPLY_CACHE: {
		"name": "Supply Cache",
		"size": Vector2i(3, 3),
		"spawn_chance": 0.01,  # 1% per cave tile check
		"min_depth": 50,
		"glow_color": Color(0.8, 0.7, 0.4),  # Warm yellow
		"glow_energy": 0.3,
	},
	RoomType.ORE_POCKET: {
		"name": "Ore Pocket",
		"size": Vector2i(5, 5),
		"spawn_chance": 0.005,  # 0.5% per cave tile check
		"min_depth": 100,
		"glow_color": Color(0.5, 0.8, 1.0),  # Crystal blue
		"glow_energy": 0.5,
	},
	RoomType.ANCIENT_VAULT: {
		"name": "Ancient Vault",
		"size": Vector2i(7, 7),
		"spawn_chance": 0.001,  # 0.1% per cave tile check
		"min_depth": 200,
		"glow_color": Color(1.0, 0.6, 0.2),  # Gold
		"glow_energy": 0.8,
	},
}

## Minimum distance between treasure rooms (in grid units)
const MIN_ROOM_DISTANCE := 50

## Maximum rooms per chunk (prevents clustering)
const MAX_ROOMS_PER_CHUNK := 1

## Active treasure rooms (center_pos -> room_data)
var _rooms: Dictionary = {}

## Discovered rooms (center_pos -> bool) - persisted
var _discovered_rooms: Dictionary = {}

## Looted rooms (center_pos -> bool) - persisted
var _looted_rooms: Dictionary = {}

## Room positions per chunk for distance checking
var _rooms_by_chunk: Dictionary = {}  # chunk_pos -> Array[Vector2i]

## RNG for spawning
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	print("[TreasureRoomManager] Ready with %d room types" % ROOM_CONFIG.size())


## Check if a treasure room should spawn at a position during cave generation
## Returns RoomType enum or -1 if no room should spawn
func check_room_spawn(cave_pos: Vector2i, depth: int, world_seed: int, chunk_pos: Vector2i) -> int:
	# Don't spawn if too shallow
	if depth < 50:
		return -1

	# Check chunk room limit
	if _rooms_by_chunk.has(chunk_pos):
		if _rooms_by_chunk[chunk_pos].size() >= MAX_ROOMS_PER_CHUNK:
			return -1

	# Skip if already a room here
	if _rooms.has(cave_pos):
		return -1

	# Check minimum distance from other rooms
	if not _check_min_distance(cave_pos):
		return -1

	# Use position-based seed for deterministic spawning
	_rng.seed = world_seed + cave_pos.x * 982451653 + cave_pos.y * 314159265

	# Roll for each room type (rarest first)
	for room_type in [RoomType.ANCIENT_VAULT, RoomType.ORE_POCKET, RoomType.SUPPLY_CACHE]:
		var config: Dictionary = ROOM_CONFIG[room_type]

		# Check depth requirement
		if depth < config["min_depth"]:
			continue

		# Roll for spawn
		if _rng.randf() < config["spawn_chance"]:
			return room_type

	return -1


## Check if a position is far enough from existing rooms
func _check_min_distance(pos: Vector2i) -> bool:
	for existing_pos in _rooms:
		var dist := Vector2(pos - existing_pos).length()
		if dist < MIN_ROOM_DISTANCE:
			return false
	return true


## Generate a treasure room at the specified position
## Returns array of positions that should be cleared (made into cave)
func generate_room(center_pos: Vector2i, room_type: int, depth: int, world_seed: int) -> Array[Vector2i]:
	if room_type < 0 or room_type >= RoomType.size():
		return []

	var config: Dictionary = ROOM_CONFIG[room_type]
	var size: Vector2i = config["size"]
	var half_size := Vector2i(size.x / 2, size.y / 2)

	# Generate loot for this room
	var loot := _generate_loot(room_type, depth, world_seed, center_pos)

	# Create room data
	var room_data := {
		"center_pos": center_pos,
		"room_type": room_type,
		"type_name": config["name"],
		"size": size,
		"depth": depth,
		"loot": loot,
		"discovered": false,
		"looted": false,
		"glow_color": config["glow_color"],
		"glow_energy": config["glow_energy"],
	}

	_rooms[center_pos] = room_data

	# Track in chunk
	var chunk_pos := Vector2i(
		int(floor(float(center_pos.x) / 16)),
		int(floor(float(center_pos.y) / 16))
	)
	if not _rooms_by_chunk.has(chunk_pos):
		_rooms_by_chunk[chunk_pos] = []
	_rooms_by_chunk[chunk_pos].append(center_pos)

	room_generated.emit(center_pos, config["name"])

	# Calculate positions to clear
	var cleared_positions: Array[Vector2i] = []
	for x in range(-half_size.x, half_size.x + 1):
		for y in range(-half_size.y, half_size.y + 1):
			# For Ancient Vault, leave outer ring as walls (requires digging)
			if room_type == RoomType.ANCIENT_VAULT:
				if abs(x) == half_size.x or abs(y) == half_size.y:
					continue  # Leave outer ring solid

			cleared_positions.append(center_pos + Vector2i(x, y))

	return cleared_positions


## Generate loot for a treasure room based on type and depth
func _generate_loot(room_type: int, depth: int, world_seed: int, center_pos: Vector2i) -> Array:
	_rng.seed = world_seed + center_pos.x * 271828182 + center_pos.y * 141421356

	var loot: Array = []

	match room_type:
		RoomType.SUPPLY_CACHE:
			# 3-5 ladders or 1-2 ropes
			if _rng.randf() < 0.7:
				var ladder_count := _rng.randi_range(3, 5)
				loot.append({"type": "item", "item_id": "ladder", "amount": ladder_count})
			else:
				var rope_count := _rng.randi_range(1, 2)
				loot.append({"type": "item", "item_id": "rope", "amount": rope_count})

			# Small coin bonus
			var coins := _rng.randi_range(20, 50)
			loot.append({"type": "coins", "amount": coins})

		RoomType.ORE_POCKET:
			# 5-10 ore pieces of current depth tier
			var ore_count := _rng.randi_range(5, 10)
			var ore_id := _get_depth_ore(depth)
			loot.append({"type": "item", "item_id": ore_id, "amount": ore_count})

			# Medium coin bonus
			var coins := _rng.randi_range(50, 150)
			loot.append({"type": "coins", "amount": coins})

		RoomType.ANCIENT_VAULT:
			# Artifact + premium ore + substantial coins
			var artifact_id := _get_random_artifact(depth)
			if artifact_id != "":
				loot.append({"type": "item", "item_id": artifact_id, "amount": 1})

			# Premium ore (3-5 pieces)
			var ore_count := _rng.randi_range(3, 5)
			var ore_id := _get_premium_ore(depth)
			loot.append({"type": "item", "item_id": ore_id, "amount": ore_count})

			# Large coin bonus
			var depth_multiplier := 1.0 + (depth * 0.003)
			var coins := int(_rng.randi_range(200, 500) * depth_multiplier)
			loot.append({"type": "coins", "amount": coins})

	return loot


## Get appropriate ore for depth tier
func _get_depth_ore(depth: int) -> String:
	if depth < 100:
		return ["coal", "copper"][_rng.randi() % 2]
	elif depth < 200:
		return ["iron", "silver"][_rng.randi() % 2]
	elif depth < 350:
		return ["gold", "platinum"][_rng.randi() % 2]
	else:
		return ["titanium", "obsidian"][_rng.randi() % 2]


## Get premium ore for Ancient Vaults (one tier above current depth)
func _get_premium_ore(depth: int) -> String:
	if depth < 100:
		return ["silver", "iron"][_rng.randi() % 2]
	elif depth < 200:
		return ["gold", "platinum"][_rng.randi() % 2]
	elif depth < 350:
		return ["titanium", "obsidian"][_rng.randi() % 2]
	else:
		return "void_crystal"


## Get a random artifact available at depth
func _get_random_artifact(depth: int) -> String:
	var available := []

	if depth >= 50:
		available.append("artifact_ancient_coin")
	if depth >= 150:
		available.append("artifact_crystal_skull")
	if depth >= 250:
		available.append("artifact_fossilized_crown")
	if depth >= 350:
		available.append("artifact_obsidian_tablet")

	if available.is_empty():
		return ""

	return available[_rng.randi() % available.size()]


## Mark a room as discovered (player enters visible range)
func discover_room(center_pos: Vector2i) -> void:
	if not _rooms.has(center_pos):
		return

	if _discovered_rooms.has(center_pos):
		return  # Already discovered

	_discovered_rooms[center_pos] = true
	_rooms[center_pos]["discovered"] = true

	var room_data: Dictionary = _rooms[center_pos]
	room_discovered.emit(center_pos, room_data["type_name"])

	# Trigger celebration feedback
	if HapticFeedback:
		HapticFeedback.on_milestone_reached()
	if SoundManager:
		SoundManager.play_milestone()

	# Track achievement
	if AchievementManager:
		_check_explorer_achievement()

	print("[TreasureRoomManager] Room discovered: %s at %s" % [
		room_data["type_name"],
		str(center_pos)
	])


## Check explorer achievement progress
func _check_explorer_achievement() -> void:
	var discovered_count := _discovered_rooms.size()
	if discovered_count >= 10:
		AchievementManager.unlock("explorer")


## Loot a room (give all contents to player)
func loot_room(center_pos: Vector2i) -> Array:
	if not _rooms.has(center_pos):
		return []

	if _looted_rooms.has(center_pos):
		return []  # Already looted

	_looted_rooms[center_pos] = true
	_rooms[center_pos]["looted"] = true

	var room_data: Dictionary = _rooms[center_pos]
	var loot: Array = room_data["loot"]

	# Give loot to player
	_apply_loot(loot)

	room_looted.emit(center_pos, loot)
	print("[TreasureRoomManager] Room looted: %s - %d items" % [
		room_data["type_name"],
		loot.size()
	])

	return loot


## Apply loot to player (add to inventory/coins)
func _apply_loot(loot: Array) -> void:
	for item in loot:
		match item.get("type", ""):
			"coins":
				var amount: int = item.get("amount", 0)
				if GameManager:
					GameManager.add_coins(amount)
			"item":
				var item_id: String = item.get("item_id", "")
				var amount: int = item.get("amount", 1)
				if InventoryManager and item_id != "":
					InventoryManager.add_item_by_id(item_id, amount)


## Check if a position is part of a treasure room
func is_room_position(pos: Vector2i) -> bool:
	for center_pos in _rooms:
		var room_data: Dictionary = _rooms[center_pos]
		var size: Vector2i = room_data["size"]
		var half_size := Vector2i(size.x / 2, size.y / 2)

		if pos.x >= center_pos.x - half_size.x and pos.x <= center_pos.x + half_size.x:
			if pos.y >= center_pos.y - half_size.y and pos.y <= center_pos.y + half_size.y:
				return true

	return false


## Get room data at a position (returns empty dict if not a room)
func get_room_at(pos: Vector2i) -> Dictionary:
	for center_pos in _rooms:
		var room_data: Dictionary = _rooms[center_pos]
		var size: Vector2i = room_data["size"]
		var half_size := Vector2i(size.x / 2, size.y / 2)

		if pos.x >= center_pos.x - half_size.x and pos.x <= center_pos.x + half_size.x:
			if pos.y >= center_pos.y - half_size.y and pos.y <= center_pos.y + half_size.y:
				return room_data

	return {}


## Check if a room has been discovered at position
func is_room_discovered(center_pos: Vector2i) -> bool:
	return _discovered_rooms.has(center_pos)


## Check if a room has been looted at position
func is_room_looted(center_pos: Vector2i) -> bool:
	return _looted_rooms.has(center_pos)


## Get room center position if pos is inside a room
func get_room_center(pos: Vector2i) -> Vector2i:
	for center_pos in _rooms:
		var room_data: Dictionary = _rooms[center_pos]
		var size: Vector2i = room_data["size"]
		var half_size := Vector2i(size.x / 2, size.y / 2)

		if pos.x >= center_pos.x - half_size.x and pos.x <= center_pos.x + half_size.x:
			if pos.y >= center_pos.y - half_size.y and pos.y <= center_pos.y + half_size.y:
				return center_pos

	return Vector2i(-1, -1)


## Get all active room positions
func get_all_room_positions() -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	for pos in _rooms:
		positions.append(pos)
	return positions


## Remove room data for a chunk (on unload)
func unload_chunk_rooms(chunk_pos: Vector2i) -> void:
	if not _rooms_by_chunk.has(chunk_pos):
		return

	for center_pos in _rooms_by_chunk[chunk_pos]:
		_rooms.erase(center_pos)

	_rooms_by_chunk.erase(chunk_pos)


## Reset for new game
func reset() -> void:
	_rooms.clear()
	_discovered_rooms.clear()
	_looted_rooms.clear()
	_rooms_by_chunk.clear()
	print("[TreasureRoomManager] Reset for new game")


# ============================================
# SAVE/LOAD
# ============================================

## Get save data
func get_save_data() -> Dictionary:
	# Convert positions to serializable format
	var discovered_list: Array = []
	for pos in _discovered_rooms:
		discovered_list.append([pos.x, pos.y])

	var looted_list: Array = []
	for pos in _looted_rooms:
		looted_list.append([pos.x, pos.y])

	return {
		"discovered_rooms": discovered_list,
		"looted_rooms": looted_list,
	}


## Load from save data
func load_save_data(data: Dictionary) -> void:
	_discovered_rooms.clear()
	_looted_rooms.clear()

	var discovered_list = data.get("discovered_rooms", [])
	for item in discovered_list:
		if item is Array and item.size() == 2:
			_discovered_rooms[Vector2i(item[0], item[1])] = true

	var looted_list = data.get("looted_rooms", [])
	for item in looted_list:
		if item is Array and item.size() == 2:
			_looted_rooms[Vector2i(item[0], item[1])] = true

	print("[TreasureRoomManager] Loaded - %d discovered, %d looted" % [
		_discovered_rooms.size(),
		_looted_rooms.size()
	])


# ============================================
# STATISTICS
# ============================================

## Get treasure room statistics
func get_stats() -> Dictionary:
	var rooms_by_type := {}
	for room_type in RoomType:
		rooms_by_type[room_type] = 0

	for center_pos in _rooms:
		var room_data: Dictionary = _rooms[center_pos]
		var room_type: int = room_data["room_type"]
		rooms_by_type[room_type] = rooms_by_type.get(room_type, 0) + 1

	return {
		"total_discovered": _discovered_rooms.size(),
		"total_looted": _looted_rooms.size(),
		"active_rooms": _rooms.size(),
		"rooms_by_type": rooms_by_type,
	}
