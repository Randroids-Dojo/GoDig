extends Node
## CaveLayerManager - Manages two-layer cave system with hidden back areas.
##
## Inspired by Spelunky 2's two-layer approach:
## - Front Layer: Regular visible caves the player can see and explore
## - Back Layer: Hidden areas accessible only with special items
##
## Back layer contains:
## - Treasure rooms with rare loot
## - Hidden passages connecting distant areas
## - Special places with unique rewards
## - Secret biomes not found in front layer
##
## Players reveal back layer using special items:
## - Spelunking Goggles (temporary reveal in vision radius)
## - Echo Stones (permanent reveal of connected back area)
## - Spectral Lantern (reveals back layer entrance hints)

signal back_layer_revealed(positions: Array)
signal back_layer_hidden
signal treasure_room_found(world_pos: Vector2, room_type: String)
signal hidden_passage_discovered(from_pos: Vector2, to_pos: Vector2)
signal back_layer_item_used(item_id: String)
signal back_layer_entrance_nearby(world_pos: Vector2)

## Cave layer types
enum Layer {
	FRONT = 0,  # Regular visible layer
	BACK = 1,   # Hidden layer requiring special items
}

## Back layer content types
enum BackContentType {
	TREASURE_ROOM,     # Contains valuable loot
	HIDDEN_PASSAGE,    # Connects distant areas
	SPECIAL_PLACE,     # Unique rewards, lore items
	SECRET_BIOME,      # Unique biome not in front layer
	VOID_POCKET,       # Rare materials, dangerous
}

## Treasure room configurations
const TREASURE_ROOMS := {
	"gem_cache": {
		"name": "Gem Cache",
		"description": "A hidden pocket of precious gems.",
		"min_depth": 100,
		"spawn_weight": 1.0,
		"loot_table": ["ruby", "emerald", "sapphire", "diamond"],
		"loot_count_min": 2,
		"loot_count_max": 5,
	},
	"ancient_vault": {
		"name": "Ancient Vault",
		"description": "Sealed chamber from a forgotten age.",
		"min_depth": 300,
		"spawn_weight": 0.5,
		"loot_table": ["artifact_ancient", "gold", "diamond"],
		"loot_count_min": 3,
		"loot_count_max": 7,
	},
	"crystal_grotto": {
		"name": "Crystal Grotto",
		"description": "Natural crystal formations glitter in the darkness.",
		"min_depth": 200,
		"spawn_weight": 0.7,
		"loot_table": ["amethyst", "sapphire", "crystal_shard"],
		"loot_count_min": 4,
		"loot_count_max": 10,
	},
	"miners_stash": {
		"name": "Miner's Stash",
		"description": "Supplies left behind by previous miners.",
		"min_depth": 50,
		"spawn_weight": 1.2,
		"loot_table": ["ladder", "rope", "torch", "food"],
		"loot_count_min": 3,
		"loot_count_max": 6,
	},
	"void_fragment": {
		"name": "Void Fragment",
		"description": "A tear in reality leaking rare materials.",
		"min_depth": 500,
		"spawn_weight": 0.2,
		"loot_table": ["void_crystal", "dark_matter", "reality_shard"],
		"loot_count_min": 1,
		"loot_count_max": 3,
	},
}

## Generation parameters
const BACK_LAYER_MIN_DEPTH := 50  # Back layer starts appearing at 50m
const BACK_LAYER_FREQUENCY := 0.03  # 3% of chunks have back layer content
const BACK_LAYER_DEPTH_FACTOR := 0.001  # Slightly more common with depth
const ENTRANCE_REVEAL_RADIUS := 3  # Tiles around entrance that hint at back layer
const BACK_VISION_RADIUS := 4  # Vision radius when using reveal items

## State tracking
var _back_layer_map: Dictionary = {}  # Vector2i chunk -> BackLayerChunk data
var _revealed_positions: Dictionary = {}  # Vector2i grid -> bool (permanently revealed)
var _temp_revealed_positions: Dictionary = {}  # Temporarily revealed (item-based)
var _treasure_rooms: Dictionary = {}  # Vector2i grid -> room data
var _hidden_passages: Array = []  # Array of {from: Vector2i, to: Vector2i}
var _back_layer_enabled: bool = false  # Current reveal state
var _reveal_timer: float = 0.0  # Time remaining for temporary reveal
var _rng := RandomNumberGenerator.new()

## Reference to player for proximity checks
var _player_grid_pos: Vector2i = Vector2i.ZERO


func _ready() -> void:
	print("[CaveLayerManager] Ready with %d treasure room types" % TREASURE_ROOMS.size())


func _process(delta: float) -> void:
	# Update temporary reveal timer
	if _reveal_timer > 0:
		_reveal_timer -= delta
		if _reveal_timer <= 0:
			_end_temporary_reveal()


## Check if a grid position should have back layer content
func has_back_layer(pos: Vector2i) -> bool:
	return _back_layer_map.has(_get_chunk_coord(pos))


## Check if a grid position's back layer is currently revealed
func is_back_layer_revealed(pos: Vector2i) -> bool:
	if _revealed_positions.has(pos):
		return true
	if _temp_revealed_positions.has(pos):
		return true
	return false


## Check if position is a back layer entrance (connection point between layers)
func is_back_layer_entrance(pos: Vector2i) -> bool:
	var chunk_coord := _get_chunk_coord(pos)
	if not _back_layer_map.has(chunk_coord):
		return false
	var chunk_data: Dictionary = _back_layer_map[chunk_coord]
	return chunk_data.get("entrance_pos", Vector2i(-9999, -9999)) == pos


## Get the back layer content type at a position (if any)
func get_back_content_type(pos: Vector2i) -> int:
	var chunk_coord := _get_chunk_coord(pos)
	if not _back_layer_map.has(chunk_coord):
		return -1
	var chunk_data: Dictionary = _back_layer_map[chunk_coord]
	return chunk_data.get("content_type", -1)


## Get treasure room data at position (if any)
func get_treasure_room(pos: Vector2i):
	return _treasure_rooms.get(pos, null)


## Generate back layer content for a chunk (called during chunk generation)
func generate_back_layer_for_chunk(chunk_coord: Vector2i, world_seed: int) -> void:
	if _back_layer_map.has(chunk_coord):
		return  # Already generated

	# Calculate depth (chunk Y * chunk size * block size gives approximate depth)
	var chunk_depth := chunk_coord.y * 16  # Assuming 16-block chunks
	if chunk_depth < BACK_LAYER_MIN_DEPTH:
		return  # No back layer in shallow areas

	# Deterministic RNG for this chunk
	_rng.seed = world_seed + chunk_coord.x * 73856093 + chunk_coord.y * 19349663

	# Check if this chunk should have back layer content
	var spawn_chance := BACK_LAYER_FREQUENCY + (chunk_depth * BACK_LAYER_DEPTH_FACTOR)
	if _rng.randf() > spawn_chance:
		return  # No back layer this chunk

	# Determine content type based on depth
	var content_type := _select_content_type(chunk_depth)

	# Generate entrance position (random position within chunk)
	var local_x := _rng.randi() % 16
	var local_y := _rng.randi() % 16
	var entrance_pos := Vector2i(
		chunk_coord.x * 16 + local_x,
		chunk_coord.y * 16 + local_y
	)

	# Store back layer data
	var chunk_data := {
		"chunk_coord": chunk_coord,
		"content_type": content_type,
		"entrance_pos": entrance_pos,
		"generated_at": Time.get_unix_time_from_system(),
	}

	# Generate specific content based on type
	match content_type:
		BackContentType.TREASURE_ROOM:
			_generate_treasure_room(chunk_data, chunk_depth)
		BackContentType.HIDDEN_PASSAGE:
			_generate_hidden_passage(chunk_data, chunk_depth)
		BackContentType.SPECIAL_PLACE:
			_generate_special_place(chunk_data, chunk_depth)
		BackContentType.SECRET_BIOME:
			_generate_secret_biome(chunk_data, chunk_depth)
		BackContentType.VOID_POCKET:
			_generate_void_pocket(chunk_data, chunk_depth)

	_back_layer_map[chunk_coord] = chunk_data
	print("[CaveLayerManager] Generated back layer at chunk %s: %s" % [
		str(chunk_coord),
		BackContentType.keys()[content_type]
	])


## Select content type based on depth (deeper = rarer content)
func _select_content_type(depth: int) -> int:
	var weights := []

	# Treasure rooms always available (below min depth)
	weights.append({"type": BackContentType.TREASURE_ROOM, "weight": 1.0})

	# Hidden passages common at all depths
	weights.append({"type": BackContentType.HIDDEN_PASSAGE, "weight": 0.8})

	# Special places less common
	if depth >= 150:
		weights.append({"type": BackContentType.SPECIAL_PLACE, "weight": 0.4})

	# Secret biomes rare
	if depth >= 300:
		weights.append({"type": BackContentType.SECRET_BIOME, "weight": 0.2})

	# Void pockets very rare, deep only
	if depth >= 500:
		weights.append({"type": BackContentType.VOID_POCKET, "weight": 0.1})

	# Weighted selection
	var total_weight := 0.0
	for w in weights:
		total_weight += w["weight"]

	var roll := _rng.randf() * total_weight
	var cumulative := 0.0

	for w in weights:
		cumulative += w["weight"]
		if roll <= cumulative:
			return w["type"]

	return BackContentType.TREASURE_ROOM  # Fallback


## Generate a treasure room
func _generate_treasure_room(chunk_data: Dictionary, depth: int) -> void:
	# Find eligible room types for this depth
	var eligible_rooms: Array = []
	var total_weight := 0.0

	for room_id in TREASURE_ROOMS:
		var room: Dictionary = TREASURE_ROOMS[room_id]
		if depth >= room["min_depth"]:
			eligible_rooms.append({"id": room_id, "data": room})
			total_weight += room["spawn_weight"]

	if eligible_rooms.is_empty():
		eligible_rooms.append({"id": "miners_stash", "data": TREASURE_ROOMS["miners_stash"]})
		total_weight = TREASURE_ROOMS["miners_stash"]["spawn_weight"]

	# Weighted selection
	var roll := _rng.randf() * total_weight
	var cumulative := 0.0
	var selected_room: Dictionary = eligible_rooms[0]

	for room in eligible_rooms:
		var room_dict: Dictionary = room
		cumulative += room_dict["data"]["spawn_weight"]
		if roll <= cumulative:
			selected_room = room_dict
			break

	# Generate loot
	var room_data: Dictionary = selected_room["data"]
	var loot_count := _rng.randi_range(
		int(room_data["loot_count_min"]),
		int(room_data["loot_count_max"])
	)
	var loot_items: Array = []
	var loot_table: Array = room_data["loot_table"]
	for i in range(loot_count):
		var item_idx: int = _rng.randi() % loot_table.size()
		loot_items.append(loot_table[item_idx])

	# Store room data
	var entrance_pos: Vector2i = chunk_data["entrance_pos"]
	_treasure_rooms[entrance_pos] = {
		"room_id": selected_room["id"],
		"room_name": room_data["name"],
		"description": room_data["description"],
		"loot": loot_items,
		"collected": false,
	}

	chunk_data["room_id"] = selected_room["id"]
	chunk_data["room_name"] = room_data["name"]


## Generate a hidden passage connecting two areas
func _generate_hidden_passage(chunk_data: Dictionary, depth: int) -> void:
	var entrance_pos: Vector2i = chunk_data["entrance_pos"]

	# Generate exit position (random offset, typically 5-20 blocks away)
	var exit_offset := Vector2i(
		_rng.randi_range(-20, 20),
		_rng.randi_range(-10, 10)
	)
	# Ensure minimum distance
	if abs(exit_offset.x) < 5:
		exit_offset.x = 5 * signi(exit_offset.x) if exit_offset.x != 0 else 5
	if abs(exit_offset.y) < 3:
		exit_offset.y = 3 * signi(exit_offset.y) if exit_offset.y != 0 else 3

	var exit_pos := entrance_pos + exit_offset

	_hidden_passages.append({
		"from": entrance_pos,
		"to": exit_pos,
		"discovered": false,
	})

	chunk_data["exit_pos"] = exit_pos


## Generate a special place with unique content
func _generate_special_place(chunk_data: Dictionary, depth: int) -> void:
	# Special places contain lore items, journals, unique artifacts
	var special_types := ["ancient_tablet", "miner_journal", "mysterious_artifact", "lost_equipment"]
	chunk_data["special_type"] = special_types[_rng.randi() % special_types.size()]


## Generate a secret biome pocket
func _generate_secret_biome(chunk_data: Dictionary, depth: int) -> void:
	# Secret biomes not found in the front layer
	var secret_biomes := ["luminous_garden", "frozen_heart", "magma_core", "echo_chamber"]
	chunk_data["secret_biome"] = secret_biomes[_rng.randi() % secret_biomes.size()]


## Generate a void pocket with rare materials
func _generate_void_pocket(chunk_data: Dictionary, depth: int) -> void:
	# Void pockets are dangerous but contain rare materials
	chunk_data["void_intensity"] = _rng.randf_range(0.5, 1.0)
	chunk_data["is_dangerous"] = true


## Use a reveal item to show back layer
func use_reveal_item(item_id: String, player_pos: Vector2) -> void:
	var grid_pos := GameManager.world_to_grid(player_pos)

	match item_id:
		"spelunking_goggles":
			# Temporary reveal in vision radius for 30 seconds
			_start_temporary_reveal(grid_pos, BACK_VISION_RADIUS, 30.0)
			back_layer_item_used.emit(item_id)
		"echo_stone":
			# Permanent reveal of connected back area
			_permanently_reveal_connected_area(grid_pos)
			back_layer_item_used.emit(item_id)
		"spectral_lantern":
			# Reveal hints of nearby back layer entrances
			_reveal_entrance_hints(grid_pos)
			back_layer_item_used.emit(item_id)
		_:
			print("[CaveLayerManager] Unknown reveal item: %s" % item_id)


## Start temporary back layer reveal
func _start_temporary_reveal(center: Vector2i, radius: int, duration: float) -> void:
	_temp_revealed_positions.clear()
	_reveal_timer = duration
	_back_layer_enabled = true

	# Reveal positions in radius
	var revealed: Array = []
	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			if abs(dx) + abs(dy) <= radius * 1.5:
				var pos := Vector2i(center.x + dx, center.y + dy)
				_temp_revealed_positions[pos] = true
				revealed.append(pos)

	back_layer_revealed.emit(revealed)
	print("[CaveLayerManager] Temporary reveal: %d positions for %.1fs" % [revealed.size(), duration])


## End temporary reveal
func _end_temporary_reveal() -> void:
	_temp_revealed_positions.clear()
	_back_layer_enabled = false
	back_layer_hidden.emit()
	print("[CaveLayerManager] Temporary reveal ended")


## Permanently reveal connected back area
func _permanently_reveal_connected_area(start_pos: Vector2i) -> void:
	# Find nearest back layer chunk
	var chunk_coord := _get_chunk_coord(start_pos)
	var search_radius := 2

	var target_chunk: Dictionary = {}
	for dx in range(-search_radius, search_radius + 1):
		for dy in range(-search_radius, search_radius + 1):
			var check_coord := Vector2i(chunk_coord.x + dx, chunk_coord.y + dy)
			if _back_layer_map.has(check_coord):
				target_chunk = _back_layer_map[check_coord]
				break
		if not target_chunk.is_empty():
			break

	if target_chunk.is_empty():
		print("[CaveLayerManager] No back layer found nearby for permanent reveal")
		return

	# Reveal the entire back area (flood fill from entrance)
	var entrance_pos: Vector2i = target_chunk["entrance_pos"]
	var revealed: Array = []
	var to_reveal: Array = [entrance_pos]
	var checked: Dictionary = {}

	while not to_reveal.is_empty():
		var pos: Vector2i = to_reveal.pop_front()
		if checked.has(pos):
			continue
		checked[pos] = true

		# Add to permanent reveal
		_revealed_positions[pos] = true
		revealed.append(pos)

		# Expand to adjacent tiles (limited to reasonable area)
		if revealed.size() < 100:  # Limit expansion
			var directions: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
			for dir: Vector2i in directions:
				var next_pos: Vector2i = pos + dir
				if not checked.has(next_pos):
					to_reveal.append(next_pos)

	back_layer_revealed.emit(revealed)
	print("[CaveLayerManager] Permanently revealed %d positions" % revealed.size())


## Reveal hints about nearby back layer entrances
func _reveal_entrance_hints(center: Vector2i) -> void:
	var search_radius := 10
	var hints_found := 0

	for dx in range(-search_radius, search_radius + 1):
		for dy in range(-search_radius, search_radius + 1):
			var pos := Vector2i(center.x + dx, center.y + dy)
			if is_back_layer_entrance(pos):
				# Emit hint signal for UI to display
				var world_pos := GameManager.grid_to_world(pos)
				back_layer_entrance_nearby.emit(world_pos)
				hints_found += 1

	print("[CaveLayerManager] Found %d back layer entrance hints" % hints_found)


## Update player position for proximity-based features
func update_player_position(player_world_pos: Vector2) -> void:
	var grid_pos := GameManager.world_to_grid(player_world_pos)

	if grid_pos == _player_grid_pos:
		return

	_player_grid_pos = grid_pos

	# Check for nearby back layer entrances (subtle hint system)
	_check_entrance_proximity(grid_pos)


## Check if player is near a back layer entrance
func _check_entrance_proximity(player_pos: Vector2i) -> void:
	for dx in range(-ENTRANCE_REVEAL_RADIUS, ENTRANCE_REVEAL_RADIUS + 1):
		for dy in range(-ENTRANCE_REVEAL_RADIUS, ENTRANCE_REVEAL_RADIUS + 1):
			var pos := Vector2i(player_pos.x + dx, player_pos.y + dy)
			if is_back_layer_entrance(pos):
				# Player is near a back layer entrance - could trigger subtle hint
				var world_pos := GameManager.grid_to_world(pos)
				back_layer_entrance_nearby.emit(world_pos)
				return


## Collect treasure room loot at position
func collect_treasure_room(pos: Vector2i) -> Array:
	if not _treasure_rooms.has(pos):
		return []

	var room_data: Dictionary = _treasure_rooms[pos]
	if room_data["collected"]:
		return []

	room_data["collected"] = true
	var loot: Array = room_data["loot"]

	treasure_room_found.emit(GameManager.grid_to_world(pos), room_data["room_id"])
	print("[CaveLayerManager] Treasure room collected: %s with %d items" % [
		room_data["room_name"],
		loot.size()
	])

	return loot


## Discover hidden passage at position
func discover_passage(pos: Vector2i) -> Dictionary:
	for passage in _hidden_passages:
		if passage["from"] == pos and not passage["discovered"]:
			passage["discovered"] = true
			var from_world := GameManager.grid_to_world(passage["from"])
			var to_world := GameManager.grid_to_world(passage["to"])
			hidden_passage_discovered.emit(from_world, to_world)
			print("[CaveLayerManager] Hidden passage discovered: %s -> %s" % [
				str(passage["from"]),
				str(passage["to"])
			])
			return passage
	return {}


## Get chunk coordinate from grid position
func _get_chunk_coord(pos: Vector2i) -> Vector2i:
	return Vector2i(
		int(floor(float(pos.x) / 16.0)),
		int(floor(float(pos.y) / 16.0))
	)


## Get save data for persistence
func get_save_data() -> Dictionary:
	# Convert revealed positions to serializable format
	var revealed_list: Array = []
	for pos in _revealed_positions:
		revealed_list.append([pos.x, pos.y])

	# Convert treasure room collection state
	var collected_rooms: Array = []
	for pos in _treasure_rooms:
		if _treasure_rooms[pos]["collected"]:
			collected_rooms.append([pos.x, pos.y])

	# Convert discovered passages
	var discovered_passages: Array = []
	for passage in _hidden_passages:
		if passage["discovered"]:
			discovered_passages.append([
				passage["from"].x, passage["from"].y,
				passage["to"].x, passage["to"].y
			])

	return {
		"revealed_positions": revealed_list,
		"collected_rooms": collected_rooms,
		"discovered_passages": discovered_passages,
	}


## Load save data
func load_save_data(data: Dictionary) -> void:
	_revealed_positions.clear()

	# Load revealed positions
	var revealed_list = data.get("revealed_positions", [])
	for item in revealed_list:
		if item is Array and item.size() == 2:
			_revealed_positions[Vector2i(item[0], item[1])] = true

	# Mark collected rooms
	var collected_rooms = data.get("collected_rooms", [])
	for item in collected_rooms:
		if item is Array and item.size() == 2:
			var pos := Vector2i(item[0], item[1])
			if _treasure_rooms.has(pos):
				_treasure_rooms[pos]["collected"] = true

	# Mark discovered passages
	var discovered_passages = data.get("discovered_passages", [])
	for item in discovered_passages:
		if item is Array and item.size() == 4:
			var from_pos := Vector2i(item[0], item[1])
			for passage in _hidden_passages:
				if passage["from"] == from_pos:
					passage["discovered"] = true
					break

	print("[CaveLayerManager] Loaded save data: %d revealed positions" % _revealed_positions.size())


## Reset for new game
func reset() -> void:
	_back_layer_map.clear()
	_revealed_positions.clear()
	_temp_revealed_positions.clear()
	_treasure_rooms.clear()
	_hidden_passages.clear()
	_back_layer_enabled = false
	_reveal_timer = 0.0
	_player_grid_pos = Vector2i.ZERO
	print("[CaveLayerManager] Reset for new game")


## Get statistics for debugging
func get_stats() -> Dictionary:
	return {
		"back_layer_chunks": _back_layer_map.size(),
		"revealed_positions": _revealed_positions.size(),
		"temp_revealed": _temp_revealed_positions.size(),
		"treasure_rooms": _treasure_rooms.size(),
		"hidden_passages": _hidden_passages.size(),
		"reveal_active": _back_layer_enabled,
		"reveal_time_remaining": _reveal_timer,
	}
