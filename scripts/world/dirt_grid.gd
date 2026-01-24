extends Node2D
## Manages the infinite dirt grid with object pooling.
## Generates chunks around the player in all directions.
## Handles ore spawning and mining drops.

const DirtBlockScript = preload("res://scripts/world/dirt_block.gd")

const BLOCK_SIZE := 128
const CHUNK_SIZE := 16  # 16x16 blocks per chunk
const POOL_SIZE := 400  # Pool size for chunks
const LOAD_RADIUS := 2  # Load chunks within 2 chunks of player (5x5 grid)

## Emitted when a block drops ore/items. item_id is empty string for dirt-only blocks.
signal block_dropped(grid_pos: Vector2i, item_id: String)

## Emitted when a block is destroyed. Includes world position and color for particle effects.
signal block_destroyed(world_pos: Vector2, color: Color)

var _pool: Array = []  # Array of DirtBlock nodes
var _active: Dictionary = {}  # Dictionary[Vector2i, DirtBlock node]
var _loaded_chunks: Dictionary = {}  # Dictionary[Vector2i, bool] tracks loaded chunks
var _ore_map: Dictionary = {}  # Dictionary[Vector2i, String ore_id] - what ore is in each block
var _dug_tiles: Dictionary = {}  # Dictionary[Vector2i, bool] - tiles that have been mined/dug
var _dirty_chunks: Dictionary = {}  # Dictionary[Vector2i, bool] - chunks with unsaved changes
var _player: Node2D = null
var _surface_row: int = 0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_preallocate_pool()
	# Connect to SaveManager to save dirty chunks before game save
	if SaveManager:
		SaveManager.save_started.connect(_on_save_started)


func initialize(player: Node2D, surface_row: int) -> void:
	_player = player
	_surface_row = surface_row
	# Generate initial chunks around player spawn position
	var player_chunk := _world_to_chunk(_player.position)
	_generate_chunks_around(player_chunk)


func _process(_delta: float) -> void:
	if _player == null:
		return

	var player_chunk := _world_to_chunk(_player.position)
	_generate_chunks_around(player_chunk)
	_cleanup_distant_chunks(player_chunk)


func _preallocate_pool() -> void:
	for i in range(POOL_SIZE):
		var block := ColorRect.new()
		block.set_script(DirtBlockScript)
		block.visible = false
		add_child(block)
		_pool.push_back(block)


func _acquire(grid_pos: Vector2i) -> ColorRect:
	var block: ColorRect
	if _pool.is_empty():
		# Pool exhausted, create new block
		block = ColorRect.new()
		block.set_script(DirtBlockScript)
		add_child(block)
	else:
		block = _pool.pop_back()

	block.activate(grid_pos)
	_active[grid_pos] = block
	return block


func _release(grid_pos: Vector2i) -> void:
	if _active.has(grid_pos):
		var block = _active[grid_pos]
		block.deactivate()
		_pool.push_back(block)
		_active.erase(grid_pos)


func _world_to_chunk(world_pos: Vector2) -> Vector2i:
	## Convert world position to chunk coordinates
	var grid_pos := GameManager.world_to_grid(world_pos)
	return _grid_to_chunk(grid_pos)


func _grid_to_chunk(grid_pos: Vector2i) -> Vector2i:
	## Convert grid position to chunk coordinates
	return Vector2i(
		int(floor(float(grid_pos.x) / CHUNK_SIZE)),
		int(floor(float(grid_pos.y) / CHUNK_SIZE))
	)


func _generate_chunks_around(center_chunk: Vector2i) -> void:
	## Generate all chunks within LOAD_RADIUS of center_chunk
	for x in range(center_chunk.x - LOAD_RADIUS, center_chunk.x + LOAD_RADIUS + 1):
		for y in range(center_chunk.y - LOAD_RADIUS, center_chunk.y + LOAD_RADIUS + 1):
			var chunk_pos := Vector2i(x, y)
			if not _loaded_chunks.has(chunk_pos):
				_generate_chunk(chunk_pos)
				_loaded_chunks[chunk_pos] = true


func _generate_chunk(chunk_pos: Vector2i) -> void:
	## Generate a 16x16 chunk of blocks at the given chunk coordinates
	# Load any previously dug tiles for this chunk
	_load_chunk_dug_tiles(chunk_pos)

	var start_x := chunk_pos.x * CHUNK_SIZE
	var start_y := chunk_pos.y * CHUNK_SIZE

	for local_x in range(CHUNK_SIZE):
		for local_y in range(CHUNK_SIZE):
			var grid_pos := Vector2i(start_x + local_x, start_y + local_y)

			# Skip tiles that were previously dug
			if _dug_tiles.has(grid_pos):
				continue

			# Only generate blocks at or below the surface
			if grid_pos.y >= _surface_row:
				if not _active.has(grid_pos):
					_acquire(grid_pos)
					_determine_ore_spawn(grid_pos)


func _cleanup_distant_chunks(center_chunk: Vector2i) -> void:
	## Remove chunks that are too far from the player
	var chunks_to_remove: Array[Vector2i] = []

	for chunk_pos: Vector2i in _loaded_chunks.keys():
		var distance: int = maxi(absi(chunk_pos.x - center_chunk.x), absi(chunk_pos.y - center_chunk.y))
		if distance > LOAD_RADIUS + 1:  # Keep one extra chunk as buffer
			chunks_to_remove.append(chunk_pos)

	for chunk_pos in chunks_to_remove:
		_unload_chunk(chunk_pos)
		_loaded_chunks.erase(chunk_pos)


func _unload_chunk(chunk_pos: Vector2i) -> void:
	## Remove all blocks in the given chunk
	# Save dug tiles for this chunk before unloading if dirty
	if _dirty_chunks.has(chunk_pos):
		_save_chunk_dug_tiles(chunk_pos)
		_dirty_chunks.erase(chunk_pos)

	var start_x := chunk_pos.x * CHUNK_SIZE
	var start_y := chunk_pos.y * CHUNK_SIZE

	var to_remove: Array[Vector2i] = []
	for local_x in range(CHUNK_SIZE):
		for local_y in range(CHUNK_SIZE):
			var grid_pos := Vector2i(start_x + local_x, start_y + local_y)
			if _active.has(grid_pos):
				to_remove.append(grid_pos)

	for pos in to_remove:
		# Clean up ore map entry when unloading
		if _ore_map.has(pos):
			_ore_map.erase(pos)
		_release(pos)

	# Clear dug tiles memory for this chunk (will reload from save when needed)
	_clear_chunk_dug_tiles_memory(chunk_pos)


func has_block(pos: Vector2i) -> bool:
	return _active.has(pos)


func get_block(pos: Vector2i):
	return _active.get(pos)


func can_mine_block(pos: Vector2i, tool_tier: int = -1) -> bool:
	## Returns true if the player's tool can mine this block.
	## Returns false if the ore requires a higher tool tier.
	## If tool_tier is -1, uses PlayerData's equipped tool tier.
	if not _active.has(pos):
		return true  # Empty space is always "minable"

	# Get tool tier from PlayerData if not specified
	var tier := tool_tier
	if tier < 0:
		if PlayerData != null:
			tier = PlayerData.get_tool_tier()
		else:
			tier = 0  # Default fallback

	# Check if this block has ore with a tier requirement
	if not _ore_map.has(pos):
		return true  # Regular dirt is always minable

	var ore_id: String = _ore_map[pos]
	var ore = DataRegistry.get_ore(ore_id)
	if ore == null:
		return true

	return tier >= ore.required_tool_tier


func get_ore_at(pos: Vector2i) -> String:
	## Returns the ore ID at the position, or empty string if none
	return _ore_map.get(pos, "")


func hit_block(pos: Vector2i, tool_damage: float = -1.0) -> bool:
	## Hit a block with specified tool damage, returns true if destroyed
	## If tool_damage is -1, uses PlayerData's equipped tool damage
	if not _active.has(pos):
		return true  # Already gone

	var block = _active[pos]

	# Get tool damage from PlayerData if not specified
	var damage := tool_damage
	if damage < 0:
		if PlayerData != null:
			damage = PlayerData.get_tool_damage()
		else:
			damage = 10.0  # Default fallback

	var destroyed: bool = block.take_hit(damage)

	if destroyed:
		# Signal what dropped (ore or empty string for plain dirt)
		var ore_id := _ore_map.get(pos, "") as String
		block_dropped.emit(pos, ore_id)

		# Signal for particle effects (before releasing block)
		var world_pos := Vector2(
			pos.x * BLOCK_SIZE + GameManager.GRID_OFFSET_X + BLOCK_SIZE / 2,
			pos.y * BLOCK_SIZE + BLOCK_SIZE / 2
		)
		block_destroyed.emit(world_pos, block.base_color)

		# Clean up ore map entry
		if _ore_map.has(pos):
			_ore_map.erase(pos)

		# Mark tile as dug for persistence
		_dug_tiles[pos] = true
		var chunk_pos := _grid_to_chunk(pos)
		_dirty_chunks[chunk_pos] = true

		_release(pos)

	return destroyed


# ============================================
# ORE SPAWNING LOGIC
# ============================================

func _determine_ore_spawn(pos: Vector2i) -> void:
	## Determine if this position should contain ore based on depth and rarity
	var depth := pos.y - GameManager.SURFACE_ROW
	if depth < 0:
		return  # No ores above surface

	# Get all ores that can spawn at this depth
	var available_ores := DataRegistry.get_ores_at_depth(depth)
	if available_ores.is_empty():
		return

	# Use position-based seed for deterministic spawning
	var seed_value := pos.x * 10000 + pos.y
	_rng.seed = seed_value

	# Check each ore (rarest first - they have highest thresholds)
	# Sort by spawn_threshold descending so rarest are checked first
	available_ores.sort_custom(func(a, b): return a.spawn_threshold > b.spawn_threshold)

	for ore in available_ores:
		# Generate noise-like value using position
		var noise_val := _generate_ore_noise(pos, ore.noise_frequency)
		if noise_val > ore.spawn_threshold:
			_ore_map[pos] = ore.id
			# Visually tint the block to show ore
			_apply_ore_visual(pos, ore)
			# Apply ore hardness bonus to make ore blocks harder to mine
			_apply_ore_hardness(pos, ore)
			return  # Only one ore per block


func _generate_ore_noise(pos: Vector2i, frequency: float) -> float:
	## Generate a pseudo-noise value for ore spawning
	## Using hash-based approach for deterministic results
	var hash_val := (pos.x * 374761393 + pos.y * 668265263) % 1000000
	var freq_adj := int(frequency * 1000)
	hash_val = (hash_val * freq_adj) % 1000000
	return float(hash_val) / 1000000.0


func _apply_ore_visual(pos: Vector2i, ore) -> void:
	## Apply ore color tint to block visual
	if not _active.has(pos):
		return

	var block = _active[pos]
	# Blend block's layer color with ore color
	var ore_color: Color = ore.color
	var base_color: Color = block.color
	block.color = base_color.lerp(ore_color, 0.5)


func _apply_ore_hardness(pos: Vector2i, ore) -> void:
	## Apply ore hardness bonus to block
	if not _active.has(pos):
		return

	var block = _active[pos]
	if ore.hardness > 0:
		block.apply_ore_hardness(ore.hardness)


# ============================================
# TILE PERSISTENCE (Save/Load)
# ============================================

func _load_chunk_dug_tiles(chunk_pos: Vector2i) -> void:
	## Load previously dug tiles for a chunk from SaveManager
	if SaveManager == null or not SaveManager.is_game_loaded():
		return

	var chunk_data := SaveManager.load_chunk(chunk_pos)
	if chunk_data.is_empty():
		return

	# chunk_data is Dictionary[String, bool] where key is "x,y" format
	# (Vector2i keys don't serialize well to JSON/binary)
	for key in chunk_data.keys():
		if chunk_data[key] == true:
			# Parse "x,y" string back to Vector2i
			var parts := (key as String).split(",")
			if parts.size() == 2:
				var pos := Vector2i(int(parts[0]), int(parts[1]))
				_dug_tiles[pos] = true


func _save_chunk_dug_tiles(chunk_pos: Vector2i) -> void:
	## Save dug tiles for a chunk to SaveManager
	if SaveManager == null or not SaveManager.is_game_loaded():
		return

	var start_x := chunk_pos.x * CHUNK_SIZE
	var start_y := chunk_pos.y * CHUNK_SIZE

	# Collect dug tiles in this chunk, using string keys for serialization
	var chunk_data := {}
	for local_x in range(CHUNK_SIZE):
		for local_y in range(CHUNK_SIZE):
			var grid_pos := Vector2i(start_x + local_x, start_y + local_y)
			if _dug_tiles.has(grid_pos):
				var key := "%d,%d" % [grid_pos.x, grid_pos.y]
				chunk_data[key] = true

	SaveManager.save_chunk(chunk_pos, chunk_data)


func _clear_chunk_dug_tiles_memory(chunk_pos: Vector2i) -> void:
	## Clear in-memory dug tiles for a chunk (will reload from save when needed)
	var start_x := chunk_pos.x * CHUNK_SIZE
	var start_y := chunk_pos.y * CHUNK_SIZE

	for local_x in range(CHUNK_SIZE):
		for local_y in range(CHUNK_SIZE):
			var grid_pos := Vector2i(start_x + local_x, start_y + local_y)
			if _dug_tiles.has(grid_pos):
				_dug_tiles.erase(grid_pos)


func save_all_dirty_chunks() -> void:
	## Save all chunks that have unsaved changes (call before game exit)
	for chunk_pos in _dirty_chunks.keys():
		_save_chunk_dug_tiles(chunk_pos)
	_dirty_chunks.clear()
	print("[DirtGrid] Saved all dirty chunks")


func _on_save_started() -> void:
	## Called when SaveManager is about to save - flush dirty chunks first
	save_all_dirty_chunks()


func clear_all_dug_tiles() -> void:
	## Clear all dug tiles (for new game)
	_dug_tiles.clear()
	_dirty_chunks.clear()
	print("[DirtGrid] Cleared all dug tiles")


func get_dug_tile_count() -> int:
	## Get count of dug tiles in memory (for debugging)
	return _dug_tiles.size()


# ============================================
# TESTING HELPERS (for PlayGodot automation)
# ============================================

func has_block_at(x: int, y: int) -> bool:
	## Check if block exists at position (x, y) - separate args for JSON-RPC calls
	return _active.has(Vector2i(x, y))


func get_block_at(x: int, y: int):
	## Get block at position (x, y) - separate args for JSON-RPC calls
	return _active.get(Vector2i(x, y))


func debug_active_count() -> int:
	## Get count of active blocks for debugging
	return _active.size()


func debug_surface_row() -> int:
	## Get surface row for debugging
	return _surface_row


func debug_chunk_count() -> int:
	## Get count of loaded chunks for debugging
	return _loaded_chunks.size()
