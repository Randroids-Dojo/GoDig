extends Node2D
## ChunkManager - TileMap-based infinite terrain system.
##
## Replaces DirtGrid for v1.0 with TileMap rendering instead of ColorRect blocks.
## Loads/unloads 16x16 tile chunks around the player with background threading.
## Maintains a 5x5 chunk area (25 chunks max) centered on the player.
##
## Key advantages over DirtGrid:
## - TileMap batches draw calls for better performance
## - Simpler collision setup (uses TileSet physics layers)
## - Better support for horizontal expansion (infinite terrain)
## - Chunk persistence using ChunkData resource class

const TileSetSetupScript = preload("res://scripts/setup/tileset_setup.gd")

signal chunk_loaded(chunk_coord: Vector2i)
signal chunk_unloaded(chunk_coord: Vector2i)
signal block_dropped(grid_pos: Vector2i, item_id: String)
signal block_destroyed(world_pos: Vector2, color: Color, hardness: float)
signal ore_discovered(world_pos: Vector2, ore_color: Color, hardness: float)
signal block_hit(world_pos: Vector2, color: Color, hardness: float)

const CHUNK_SIZE := 16
const LOAD_RADIUS := 2   # 5x5 = radius 2 in each direction
const UNLOAD_RADIUS := 3 # Unload slightly further to prevent thrash
const BLOCK_SIZE := 128

## Tilemap layers
const TERRAIN_LAYER := 0
const OBJECTS_LAYER := 1

@onready var tilemap: TileMap

var loaded_chunks: Dictionary = {}  # Vector2i -> ChunkData
var _player_chunk: Vector2i = Vector2i.ZERO
var _generation_queue: Array[Vector2i] = []
var _generation_thread: Thread = null
var _pending_tiles: Array = []  # Tiles to apply on main thread
var _mutex: Mutex = Mutex.new()

var _player: Node2D = null
var _surface_row: int = 0
var _world_seed: int = 0
var _dug_tiles: Dictionary = {}  # Vector2i -> bool - tiles that have been mined
var _ore_map: Dictionary = {}  # Vector2i -> String ore_id
var _dirty_chunks: Dictionary = {}  # Chunks with unsaved changes
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_setup_tilemap()
	# Connect to SaveManager to save dirty chunks before game save
	if SaveManager:
		SaveManager.save_started.connect(_on_save_started)


func _setup_tilemap() -> void:
	## Create and configure the TileMap node with terrain TileSet
	tilemap = TileMap.new()
	tilemap.name = "TileMap"

	# Use the terrain TileSet from GameManager (or create if needed)
	if GameManager and GameManager.terrain_tileset:
		tilemap.tile_set = GameManager.terrain_tileset
	else:
		tilemap.tile_set = TileSetSetupScript.get_or_create_tileset()

	# Position TileMap to align with grid
	tilemap.position = Vector2.ZERO
	tilemap.z_index = 0

	add_child(tilemap)
	print("[ChunkManager] TileMap initialized")


func initialize(player: Node2D, surface_row: int) -> void:
	_player = player
	_surface_row = surface_row
	_world_seed = SaveManager.get_world_seed() if SaveManager else 0

	# Generate initial chunks around player spawn position
	var player_chunk := world_to_chunk(GameManager.world_to_grid(_player.position))
	_generate_chunks_around(player_chunk)


func _process(_delta: float) -> void:
	_apply_pending_tiles()

	if _player == null:
		return

	var player_chunk := world_to_chunk(GameManager.world_to_grid(_player.position))
	if player_chunk != _player_chunk:
		_player_chunk = player_chunk
		_generate_chunks_around(player_chunk)
		_cleanup_distant_chunks(player_chunk)


## Call this when player moves to new grid position
func update_player_position(world_pos: Vector2i) -> void:
	var new_chunk := world_to_chunk(world_pos)
	if new_chunk != _player_chunk:
		_player_chunk = new_chunk
		_generate_chunks_around(_player_chunk)
		_cleanup_distant_chunks(_player_chunk)


func _generate_chunks_around(center_chunk: Vector2i) -> void:
	## Generate all chunks within LOAD_RADIUS of center_chunk
	## Prioritize chunks below player (digging direction)
	var needed_chunks: Array[Vector2i] = []

	for x in range(-LOAD_RADIUS, LOAD_RADIUS + 1):
		for y in range(-LOAD_RADIUS, LOAD_RADIUS + 1):
			var chunk := center_chunk + Vector2i(x, y)
			if chunk not in loaded_chunks and chunk not in _generation_queue:
				needed_chunks.append(chunk)

	# Sort by priority - chunks below player first
	needed_chunks.sort_custom(_chunk_priority_sort.bind(center_chunk))

	# Queue for generation
	for chunk in needed_chunks:
		_generation_queue.append(chunk)

	# Start generation if not already running
	if not _generation_queue.is_empty() and _generation_thread == null:
		_start_generation_thread()


func _chunk_priority_sort(a: Vector2i, b: Vector2i, center: Vector2i) -> bool:
	# Prioritize chunks below player (y increases downward)
	var a_below := a.y > center.y
	var b_below := b.y > center.y
	if a_below != b_below:
		return a_below  # Below comes first

	# Then by distance
	var dist_a := (a - center).length()
	var dist_b := (b - center).length()
	return dist_a < dist_b


func _start_generation_thread() -> void:
	if _generation_queue.is_empty():
		return

	# On web, use synchronous generation (no threading support)
	if OS.has_feature("web"):
		_generate_chunks_synchronous()
		return

	_generation_thread = Thread.new()
	_generation_thread.start(_generate_chunks_threaded)


func _generate_chunks_synchronous() -> void:
	## Synchronous fallback for web platform
	while not _generation_queue.is_empty():
		var chunk_coord: Vector2i = _generation_queue.pop_front()
		_generate_chunk(chunk_coord)


func _generate_chunks_threaded() -> void:
	while true:
		_mutex.lock()
		if _generation_queue.is_empty():
			_mutex.unlock()
			break
		var chunk_coord: Vector2i = _generation_queue.pop_front()
		_mutex.unlock()

		_generate_chunk(chunk_coord)


func _generate_chunk(chunk_coord: Vector2i) -> void:
	## Generate terrain data for a chunk (can run on thread)
	var chunk_data := ChunkData.new()
	chunk_data.chunk_coord = chunk_coord
	chunk_data.is_generated = true

	# Load previously saved modifications for this chunk
	var saved_mods: Dictionary = {}
	if SaveManager and SaveManager.is_game_loaded():
		saved_mods = SaveManager.load_chunk(chunk_coord)

	var tiles_to_place: Array = []
	var base_world := chunk_to_world(chunk_coord)

	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var local := Vector2i(x, y)
			var world := base_world + local

			# Skip tiles above surface
			if world.y < _surface_row:
				continue

			# Check saved modifications (dug tiles)
			var local_key := "%d,%d" % [world.x, world.y]
			if saved_mods.has(local_key) and saved_mods[local_key] == true:
				_dug_tiles[world] = true
				continue  # Tile was dug, leave as air

			# Check if already in _dug_tiles
			if _dug_tiles.has(world):
				continue

			# Check if this should be a cave tile (empty)
			if _is_cave_tile(world):
				continue

			# Generate tile type based on depth
			var depth := world.y - _surface_row
			var tile_type := _get_tile_type_at(world, depth)

			tiles_to_place.append({
				"pos": world,
				"type": tile_type,
				"depth": depth
			})

	# Store chunk data and queue tiles for main thread
	_mutex.lock()
	loaded_chunks[chunk_coord] = chunk_data
	_pending_tiles.append_array(tiles_to_place)
	_mutex.unlock()


func _get_tile_type_at(world_pos: Vector2i, depth: int) -> int:
	## Determine tile type based on depth (layer-based)
	if depth < 0:
		return TileTypes.Type.AIR

	# Get layer from DataRegistry if available
	if DataRegistry:
		var layer = DataRegistry.get_layer_at_depth(depth)
		if layer:
			# Use layer's base tile type
			match layer.id:
				"surface": return TileTypes.Type.DIRT
				"clay": return TileTypes.Type.CLAY
				"stone": return TileTypes.Type.STONE
				"granite": return TileTypes.Type.GRANITE
				"basalt": return TileTypes.Type.BASALT
				"obsidian": return TileTypes.Type.OBSIDIAN

	# Fallback: depth-based tile type
	if depth < 50:
		return TileTypes.Type.DIRT
	elif depth < 150:
		return TileTypes.Type.CLAY
	elif depth < 300:
		return TileTypes.Type.STONE
	elif depth < 500:
		return TileTypes.Type.GRANITE
	elif depth < 800:
		return TileTypes.Type.BASALT
	else:
		return TileTypes.Type.OBSIDIAN


func _is_cave_tile(pos: Vector2i) -> bool:
	## Determine if a position should be a cave (empty) using noise
	var depth := pos.y - _surface_row
	if depth < 20:
		return false  # No caves in shallow layers

	# Use position-based noise for deterministic cave shapes
	var hash1 := (pos.x * 198491317 + pos.y * 6542989) % 1000000
	var noise1 := float(hash1) / 1000000.0
	var hash2 := (pos.x * 73856093 + pos.y * 19349663) % 1000000
	var noise2 := float(hash2) / 1000000.0
	var noise_val := noise1 * 0.7 + noise2 * 0.3

	# Adjust threshold based on depth - deeper = slightly more caves
	var depth_bonus := minf(depth * 0.001, 0.1)
	var threshold := 0.85 - depth_bonus

	return noise_val > threshold


func _apply_pending_tiles() -> void:
	if _pending_tiles.is_empty():
		return

	_mutex.lock()
	var tiles := _pending_tiles.duplicate()
	_pending_tiles.clear()
	_mutex.unlock()

	# Apply tiles in batches to prevent frame stuttering
	var BATCH_SIZE := 200
	var applied := 0

	for tile_data in tiles:
		if applied >= BATCH_SIZE:
			# Re-queue remaining
			_mutex.lock()
			_pending_tiles.append_array(tiles.slice(applied))
			_mutex.unlock()
			break

		_place_tile(tile_data.pos, tile_data.type)

		# Check for ore spawn
		_determine_ore_spawn(tile_data.pos, tile_data.depth)

		applied += 1

	# Clean up thread if done
	if _generation_queue.is_empty() and _pending_tiles.is_empty():
		if _generation_thread != null:
			_generation_thread.wait_to_finish()
			_generation_thread = null


func _place_tile(world_pos: Vector2i, tile_type: int) -> void:
	if tile_type == TileTypes.Type.AIR:
		tilemap.erase_cell(TERRAIN_LAYER, world_pos)
	else:
		# Get atlas coords from TileSetSetup
		var atlas_coords := TileSetSetupScript.get_atlas_coords(tile_type)
		tilemap.set_cell(TERRAIN_LAYER, world_pos, 0, atlas_coords)


func _cleanup_distant_chunks(center_chunk: Vector2i) -> void:
	## Remove chunks that are too far from the player
	var chunks_to_remove: Array[Vector2i] = []

	for chunk_coord: Vector2i in loaded_chunks.keys():
		var distance := maxi(absi(chunk_coord.x - center_chunk.x), absi(chunk_coord.y - center_chunk.y))
		if distance > UNLOAD_RADIUS:
			chunks_to_remove.append(chunk_coord)

	for chunk_coord in chunks_to_remove:
		_unload_chunk(chunk_coord)


func _unload_chunk(chunk_coord: Vector2i) -> void:
	if chunk_coord not in loaded_chunks:
		return

	var chunk_data: ChunkData = loaded_chunks[chunk_coord]

	# Save if modified
	if _dirty_chunks.has(chunk_coord):
		_save_chunk_dug_tiles(chunk_coord)
		_dirty_chunks.erase(chunk_coord)

	# Clear tiles from TileMap
	var base := chunk_to_world(chunk_coord)
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var world_pos := base + Vector2i(x, y)
			tilemap.erase_cell(TERRAIN_LAYER, world_pos)
			tilemap.erase_cell(OBJECTS_LAYER, world_pos)
			# Clear ore map entry
			_ore_map.erase(world_pos)

	loaded_chunks.erase(chunk_coord)
	chunk_unloaded.emit(chunk_coord)


## Called when player digs a tile
func dig_tile(world_pos: Vector2i) -> bool:
	## Hit a tile to dig it. Returns true if destroyed.
	var chunk_coord := world_to_chunk(world_pos)
	if chunk_coord not in loaded_chunks:
		return false

	# Check if tile exists
	var tile_data := tilemap.get_cell_tile_data(TERRAIN_LAYER, world_pos)
	if tile_data == null:
		return true  # Already empty

	# Get hardness from tile data
	var hardness: float = tile_data.get_custom_data("hardness")
	if hardness <= 0:
		hardness = 1.0

	# For now, instant destruction (can add durability system later)
	# Get tile info before destroying
	var tile_type: int = tile_data.get_custom_data("tile_type")
	var color := TileTypes.get_color(tile_type)

	# Signal what dropped (ore or empty string for plain dirt)
	var ore_id := _ore_map.get(world_pos, "") as String
	block_dropped.emit(world_pos, ore_id)

	# Signal for particle effects
	var pixel_pos := Vector2(
		world_pos.x * BLOCK_SIZE + BLOCK_SIZE / 2,
		world_pos.y * BLOCK_SIZE + BLOCK_SIZE / 2
	)

	if ore_id != "":
		var ore = DataRegistry.get_ore(ore_id) if DataRegistry else null
		var ore_color: Color = ore.color if ore != null else color
		ore_discovered.emit(pixel_pos, ore_color, hardness)
	else:
		block_destroyed.emit(pixel_pos, color, hardness)

	# Clear the tile
	tilemap.erase_cell(TERRAIN_LAYER, world_pos)
	_ore_map.erase(world_pos)

	# Mark as dug for persistence
	_dug_tiles[world_pos] = true
	_dirty_chunks[chunk_coord] = true

	# Update chunk data
	var local := world_to_local(world_pos)
	var chunk_data: ChunkData = loaded_chunks[chunk_coord]
	chunk_data.set_modified_tile(local, TileTypes.Type.AIR)

	return true


func has_block(pos: Vector2i) -> bool:
	var tile_data := tilemap.get_cell_tile_data(TERRAIN_LAYER, pos)
	return tile_data != null


func get_tile_type(pos: Vector2i) -> int:
	var tile_data := tilemap.get_cell_tile_data(TERRAIN_LAYER, pos)
	if tile_data == null:
		return TileTypes.Type.AIR
	return tile_data.get_custom_data("tile_type")


func get_ore_at(pos: Vector2i) -> String:
	return _ore_map.get(pos, "")


## Place a ladder at the specified position
func place_ladder(pos: Vector2i) -> bool:
	if has_block(pos):
		return false  # Can't place on solid block

	# Check for existing placed object
	var object_data := tilemap.get_cell_tile_data(OBJECTS_LAYER, pos)
	if object_data != null:
		return false  # Already has a placed object

	var atlas_coords := TileSetSetupScript.get_atlas_coords(TileTypes.Type.LADDER)
	tilemap.set_cell(OBJECTS_LAYER, pos, 0, atlas_coords)

	# Mark chunk as dirty for persistence
	var chunk_coord := world_to_chunk(pos)
	_dirty_chunks[chunk_coord] = true

	# Update chunk data
	if loaded_chunks.has(chunk_coord):
		var local := world_to_local(pos)
		var chunk_data: ChunkData = loaded_chunks[chunk_coord]
		chunk_data.place_object(local, TileTypes.Type.LADDER)

	return true


func has_ladder(pos: Vector2i) -> bool:
	var object_data := tilemap.get_cell_tile_data(OBJECTS_LAYER, pos)
	if object_data == null:
		return false
	return object_data.get_custom_data("tile_type") == TileTypes.Type.LADDER


## Coordinate helpers
static func world_to_chunk(world_pos: Vector2i) -> Vector2i:
	return Vector2i(
		floori(float(world_pos.x) / CHUNK_SIZE),
		floori(float(world_pos.y) / CHUNK_SIZE)
	)


static func world_to_local(world_pos: Vector2i) -> Vector2i:
	var x := world_pos.x % CHUNK_SIZE
	var y := world_pos.y % CHUNK_SIZE
	if x < 0: x += CHUNK_SIZE
	if y < 0: y += CHUNK_SIZE
	return Vector2i(x, y)


static func chunk_to_world(chunk_coord: Vector2i) -> Vector2i:
	return chunk_coord * CHUNK_SIZE


## ORE SPAWNING LOGIC
func _determine_ore_spawn(pos: Vector2i, depth: int) -> void:
	if depth < 0:
		return

	if _ore_map.has(pos):
		return  # Already has ore

	# Get all ores that can spawn at this depth
	var available_ores = DataRegistry.get_ores_at_depth(depth) if DataRegistry else []
	if available_ores.is_empty():
		return

	# Use position-based seed for deterministic spawning
	var seed_value := pos.x * 10000 + pos.y
	_rng.seed = seed_value

	# Sort by spawn_threshold descending (rarest first)
	available_ores.sort_custom(func(a, b): return a.spawn_threshold > b.spawn_threshold)

	for ore in available_ores:
		var noise_val := _generate_ore_noise(pos, ore.noise_frequency)
		if noise_val > ore.spawn_threshold:
			_place_ore_at(pos, ore)
			return


func _generate_ore_noise(pos: Vector2i, frequency: float) -> float:
	var hash_val := (pos.x * 374761393 + pos.y * 668265263) % 1000000
	var freq_adj := int(frequency * 1000)
	hash_val = (hash_val * freq_adj) % 1000000
	return float(hash_val) / 1000000.0


func _place_ore_at(pos: Vector2i, ore) -> void:
	_ore_map[pos] = ore.id
	# Visual update would be handled by a shader or overlay system
	# For TileMap, we could use alternative source/atlas coords for ore tiles


## PERSISTENCE
func _save_chunk_dug_tiles(chunk_coord: Vector2i) -> void:
	if SaveManager == null or not SaveManager.is_game_loaded():
		return

	var start := chunk_to_world(chunk_coord)

	# Collect dug tiles in this chunk
	var chunk_data := {}
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var grid_pos := start + Vector2i(x, y)
			if _dug_tiles.has(grid_pos):
				var key := "%d,%d" % [grid_pos.x, grid_pos.y]
				chunk_data[key] = true

	SaveManager.save_chunk(chunk_coord, chunk_data)


func save_all_dirty_chunks() -> void:
	for chunk_coord in _dirty_chunks.keys():
		_save_chunk_dug_tiles(chunk_coord)
	_dirty_chunks.clear()
	print("[ChunkManager] Saved all dirty chunks")


func _on_save_started() -> void:
	save_all_dirty_chunks()


func clear_all_dug_tiles() -> void:
	_dug_tiles.clear()
	_dirty_chunks.clear()
	print("[ChunkManager] Cleared all dug tiles")


## DEBUG HELPERS
func debug_active_count() -> int:
	var count := 0
	for chunk_coord in loaded_chunks:
		count += CHUNK_SIZE * CHUNK_SIZE
	return count


func debug_chunk_count() -> int:
	return loaded_chunks.size()
