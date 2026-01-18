extends Node2D
## Manages the infinite dirt grid with object pooling.
## Generates chunks around the player in all directions.
## Handles ore spawning and mining drops.

const DirtBlockScript = preload("res://scripts/world/dirt_block.gd")

const BLOCK_SIZE := 128
const CHUNK_SIZE := 16  # 16x16 blocks per chunk
const POOL_SIZE := 500  # Increased for horizontal generation
const LOAD_RADIUS := 3  # Load chunks within 3 chunks of player

## Emitted when a block drops ore/items. item_id is empty string for dirt-only blocks.
signal block_dropped(grid_pos: Vector2i, item_id: String)

var _pool: Array = []  # Array of DirtBlock nodes
var _active: Dictionary = {}  # Dictionary[Vector2i, DirtBlock node]
var _loaded_chunks: Dictionary = {}  # Dictionary[Vector2i, bool] tracks loaded chunks
var _ore_map: Dictionary = {}  # Dictionary[Vector2i, String ore_id] - what ore is in each block
var _player: Node2D = null
var _surface_row: int = 0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_preallocate_pool()


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
	var start_x := chunk_pos.x * CHUNK_SIZE
	var start_y := chunk_pos.y * CHUNK_SIZE

	for local_x in range(CHUNK_SIZE):
		for local_y in range(CHUNK_SIZE):
			var grid_pos := Vector2i(start_x + local_x, start_y + local_y)

			# Only generate blocks at or below the surface
			if grid_pos.y >= _surface_row:
				if not _active.has(grid_pos):
					_acquire(grid_pos)
					_determine_ore_spawn(grid_pos)


func _cleanup_distant_chunks(center_chunk: Vector2i) -> void:
	## Remove chunks that are too far from the player
	var chunks_to_remove: Array[Vector2i] = []

	for chunk_pos: Vector2i in _loaded_chunks.keys():
		var distance := max(abs(chunk_pos.x - center_chunk.x), abs(chunk_pos.y - center_chunk.y))
		if distance > LOAD_RADIUS + 1:  # Keep one extra chunk as buffer
			chunks_to_remove.append(chunk_pos)

	for chunk_pos in chunks_to_remove:
		_unload_chunk(chunk_pos)
		_loaded_chunks.erase(chunk_pos)


func _unload_chunk(chunk_pos: Vector2i) -> void:
	## Remove all blocks in the given chunk
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


func has_block(pos: Vector2i) -> bool:
	return _active.has(pos)


func get_block(pos: Vector2i):
	return _active.get(pos)


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

		# Clean up ore map entry
		if _ore_map.has(pos):
			_ore_map.erase(pos)

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
