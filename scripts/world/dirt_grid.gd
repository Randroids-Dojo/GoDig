extends Node2D
## Manages the infinite dirt grid with object pooling.
## Generates chunks around the player in all directions.
## Handles ore spawning and mining drops.

const DirtBlockScript = preload("res://scripts/world/dirt_block.gd")
const OreSparkleScene = preload("res://scenes/effects/ore_sparkle.tscn")
const RarityBorderScene = preload("res://scenes/effects/rarity_border.tscn")

const BLOCK_SIZE := 128
const CHUNK_SIZE := 16  # 16x16 blocks per chunk
const POOL_SIZE := 400  # Pool size for chunks
const LOAD_RADIUS := 2  # Load chunks within 2 chunks of player (5x5 grid)

## Emitted when a block drops ore/items. item_id is empty string for dirt-only blocks.
signal block_dropped(grid_pos: Vector2i, item_id: String)

## Emitted when a fossil is found while mining
signal fossil_found(grid_pos: Vector2i, fossil_id: String)

## Emitted when a block is destroyed. Includes world position, color, and hardness for effects.
signal block_destroyed(world_pos: Vector2, color: Color, hardness: float)

var _pool: Array = []  # Array of DirtBlock nodes
var _active: Dictionary = {}  # Dictionary[Vector2i, DirtBlock node]
var _loaded_chunks: Dictionary = {}  # Dictionary[Vector2i, bool] tracks loaded chunks
var _ore_map: Dictionary = {}  # Dictionary[Vector2i, String ore_id] - what ore is in each block
var _dug_tiles: Dictionary = {}  # Dictionary[Vector2i, bool] - tiles that have been mined/dug
var _placed_objects: Dictionary = {}  # Dictionary[Vector2i, int tile_type] - ladders, torches, etc.
var _dirty_chunks: Dictionary = {}  # Dictionary[Vector2i, bool] - chunks with unsaved changes
var _sparkles: Dictionary = {}  # Dictionary[Vector2i, CPUParticles2D] - sparkle effects for ore blocks
var _rarity_borders: Dictionary = {}  # Dictionary[Vector2i, Node2D] - rarity border effects for ore blocks
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
				# Check if this should be a cave tile (empty)
				if _is_cave_tile(grid_pos):
					continue  # Leave as empty/air

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
		# Clean up ore map entry, sparkle, and border when unloading
		if _ore_map.has(pos):
			_ore_map.erase(pos)
		_remove_ore_sparkle(pos)
		_remove_rarity_border(pos)
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


func get_tile_type(pos: Vector2i) -> int:
	## Returns the tile type at the position
	## Returns TileTypes.Type.AIR for empty, LADDER for ladders, etc.
	if _placed_objects.has(pos):
		return _placed_objects[pos]
	if _active.has(pos):
		return TileTypes.Type.DIRT  # Simplified - actual type would depend on depth
	return TileTypes.Type.AIR


func place_ladder(pos: Vector2i) -> bool:
	## Place a ladder at the specified position
	## Returns true if placed successfully, false if position is occupied
	if _active.has(pos):
		return false  # Can't place on solid block
	if _placed_objects.has(pos):
		return false  # Already has a placed object

	_placed_objects[pos] = TileTypes.Type.LADDER

	# Mark chunk as dirty for persistence
	var chunk_pos := _grid_to_chunk(pos)
	_dirty_chunks[chunk_pos] = true

	return true


func remove_ladder(pos: Vector2i) -> bool:
	## Remove a ladder from the specified position
	## Returns true if removed, false if no ladder there
	if not _placed_objects.has(pos):
		return false
	if _placed_objects[pos] != TileTypes.Type.LADDER:
		return false

	_placed_objects.erase(pos)

	# Mark chunk as dirty for persistence
	var chunk_pos := _grid_to_chunk(pos)
	_dirty_chunks[chunk_pos] = true

	return true


func has_ladder(pos: Vector2i) -> bool:
	## Check if there's a ladder at the position
	return _placed_objects.get(pos, TileTypes.Type.AIR) == TileTypes.Type.LADDER


## Get all placed objects as a saveable dictionary
## Format: {"x,y": tile_type, ...}
func get_placed_objects_dict() -> Dictionary:
	var result := {}
	for pos in _placed_objects:
		var key := "%d,%d" % [pos.x, pos.y]
		result[key] = _placed_objects[pos]
	return result


## Load placed objects from a saved dictionary
## Format: {"x,y": tile_type, ...}
func load_placed_objects_dict(data: Dictionary) -> void:
	_placed_objects.clear()
	for key in data:
		var parts = key.split(",")
		if parts.size() == 2:
			var pos := Vector2i(int(parts[0]), int(parts[1]))
			_placed_objects[pos] = data[key]
	print("[DirtGrid] Loaded %d placed objects" % _placed_objects.size())


func get_block_hardness(pos: Vector2i) -> float:
	## Get the max hardness of a block at the position
	## Returns 0.0 if no block exists
	if not _active.has(pos):
		return 0.0
	var block = _active[pos]
	return block.max_health


func get_block_health(pos: Vector2i) -> float:
	## Get the current health of a block at the position
	## Returns 0.0 if no block exists
	if not _active.has(pos):
		return 0.0
	var block = _active[pos]
	return block.current_health


func get_block_mining_progress(pos: Vector2i) -> float:
	## Get the mining progress of a block (0.0 = undamaged, 1.0 = about to break)
	## Returns -1.0 if no block exists
	if not _active.has(pos):
		return -1.0
	var block = _active[pos]
	if block.max_health <= 0:
		return 1.0
	return 1.0 - (block.current_health / block.max_health)


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

		# Check for fossil drop
		var fossil_id := _check_fossil_drop(pos)
		if fossil_id != "":
			fossil_found.emit(pos, fossil_id)

		# Signal for particle effects and screen shake (before releasing block)
		var world_pos := Vector2(
			pos.x * BLOCK_SIZE + GameManager.GRID_OFFSET_X + BLOCK_SIZE / 2,
			pos.y * BLOCK_SIZE + BLOCK_SIZE / 2
		)
		block_destroyed.emit(world_pos, block.base_color, block.max_health)

		# Play sound effect
		if SoundManager:
			SoundManager.play_block_break(block.max_health)

		# Clean up ore map entry, sparkle, and border
		if _ore_map.has(pos):
			_ore_map.erase(pos)
		_remove_ore_sparkle(pos)
		_remove_rarity_border(pos)

		# Mark tile as dug for persistence
		_dug_tiles[pos] = true
		var chunk_pos := _grid_to_chunk(pos)
		_dirty_chunks[chunk_pos] = true

		_release(pos)

	return destroyed


# ============================================
# CAVE GENERATION
# ============================================

## Cave generation constants
const CAVE_MIN_DEPTH := 20  # Caves start appearing 20 blocks below surface
const CAVE_FREQUENCY := 0.05  # Lower = larger caves
const CAVE_THRESHOLD := 0.85  # Higher = fewer caves (0.0-1.0)
const CAVE_DEPTH_FACTOR := 0.001  # Caves get slightly more common with depth

func _is_cave_tile(pos: Vector2i) -> bool:
	## Determine if a position should be a cave (empty) using noise
	var depth := pos.y - _surface_row
	if depth < CAVE_MIN_DEPTH:
		return false  # No caves in shallow layers

	# Use position-based noise for deterministic cave shapes
	var noise_val := _generate_cave_noise(pos)

	# Adjust threshold based on depth - deeper = slightly more caves
	var depth_bonus := minf(depth * CAVE_DEPTH_FACTOR, 0.1)
	var adjusted_threshold := CAVE_THRESHOLD - depth_bonus

	return noise_val > adjusted_threshold


func _generate_cave_noise(pos: Vector2i) -> float:
	## Generate cave noise value for a position
	## Uses layered noise for more natural cave shapes
	var freq := CAVE_FREQUENCY

	# Primary noise layer
	var hash1 := (pos.x * 198491317 + pos.y * 6542989) % 1000000
	var noise1 := float(hash1) / 1000000.0

	# Secondary layer for variation (different frequency)
	var hash2 := (pos.x * 73856093 + pos.y * 19349663) % 1000000
	var noise2 := float(hash2) / 1000000.0

	# Combine layers (weighted average)
	return noise1 * 0.7 + noise2 * 0.3


# ============================================
# ORE SPAWNING LOGIC
# ============================================

func _determine_ore_spawn(pos: Vector2i) -> void:
	## Determine if this position should contain ore based on depth and rarity
	## Uses vein expansion (random walk) to create ore clusters
	var depth := pos.y - GameManager.SURFACE_ROW
	if depth < 0:
		return  # No ores above surface

	# Skip if already has ore (from vein expansion)
	if _ore_map.has(pos):
		return

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
			# This is a vein seed - expand using random walk
			_expand_ore_vein(pos, ore)
			return  # Only one ore type per seed position


func _expand_ore_vein(seed_pos: Vector2i, ore) -> void:
	## Expand ore from seed position using improved cluster algorithm
	## Creates natural-looking ore veins with branches and organic shapes

	# Get vein size from ore data
	var vein_seed := seed_pos.x * 73856093 + seed_pos.y * 19349663
	_rng.seed = vein_seed
	var vein_size: int = ore.get_random_vein_size(_rng)

	# Place ore at seed position first
	_place_ore_at(seed_pos, ore)

	if vein_size <= 1:
		return  # Single block vein

	# Use cluster-based expansion for larger, more natural veins
	var placed_positions: Array[Vector2i] = [seed_pos]
	var placed_count := 1
	var attempts := 0
	var max_attempts := vein_size * 6  # More attempts for better coverage

	# Cardinal and diagonal directions for more organic shapes
	var cardinal_dirs := [
		Vector2i(1, 0),   # Right
		Vector2i(-1, 0),  # Left
		Vector2i(0, 1),   # Down
		Vector2i(0, -1),  # Up
	]

	# Diagonal directions for occasional branch variation
	var diagonal_dirs := [
		Vector2i(1, 1),   # Down-Right
		Vector2i(-1, 1),  # Down-Left
		Vector2i(1, -1),  # Up-Right
		Vector2i(-1, -1), # Up-Left
	]

	# Track last direction for "flow" tendency (veins tend to continue)
	var last_dir := Vector2i.ZERO

	while placed_count < vein_size and attempts < max_attempts:
		attempts += 1

		# Pick a random existing ore position to expand from
		var expand_from: Vector2i
		if _rng.randf() < 0.7 and placed_positions.size() > 1:
			# Usually expand from most recent positions (creates tendrils)
			var recent_idx := placed_positions.size() - 1 - (_rng.randi() % mini(3, placed_positions.size()))
			expand_from = placed_positions[recent_idx]
		else:
			# Occasionally expand from any position (creates branches)
			expand_from = placed_positions[_rng.randi() % placed_positions.size()]

		# Pick direction with bias toward continuing previous direction
		var dir: Vector2i
		if last_dir != Vector2i.ZERO and _rng.randf() < 0.4:
			# Continue in same direction (creates longer veins)
			dir = last_dir
		elif _rng.randf() < 0.15:
			# Occasionally use diagonal (creates more organic shapes)
			dir = diagonal_dirs[_rng.randi() % 4]
		else:
			# Usually use cardinal direction
			dir = cardinal_dirs[_rng.randi() % 4]

		var next_pos := expand_from + dir

		# Check if valid position for ore
		var next_depth := next_pos.y - GameManager.SURFACE_ROW
		if next_depth < 0:
			continue  # Don't place above surface

		if not ore.can_spawn_at_depth(next_depth):
			continue  # Outside ore's depth range

		if _ore_map.has(next_pos):
			# Position already has ore, try different direction
			continue

		if _dug_tiles.has(next_pos):
			continue  # Don't place ore in dug tiles

		# Place ore at this position
		_place_ore_at(next_pos, ore)
		placed_positions.append(next_pos)
		placed_count += 1
		last_dir = dir


func _place_ore_at(pos: Vector2i, ore) -> void:
	## Place ore at a specific position and apply visuals
	_ore_map[pos] = ore.id

	# Apply visual if block is active (loaded)
	if _active.has(pos):
		_apply_ore_visual(pos, ore)
		_apply_ore_hardness(pos, ore)
		_add_ore_sparkle(pos, ore)
		_add_rarity_border(pos, ore)


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


func _add_ore_sparkle(pos: Vector2i, ore) -> void:
	## Add sparkle effect to an ore block
	if not _active.has(pos):
		return
	if _sparkles.has(pos):
		return  # Already has a sparkle

	var block = _active[pos]
	var sparkle = OreSparkleScene.instantiate()

	# Get rarity from ore (convert string to int if needed)
	var rarity_value := 0
	if "rarity" in ore:
		match ore.rarity:
			"common": rarity_value = 0
			"uncommon": rarity_value = 1
			"rare": rarity_value = 2
			"epic": rarity_value = 3
			"legendary": rarity_value = 4
			_: rarity_value = 0
	elif "tier" in ore:
		rarity_value = clampi(ore.tier - 1, 0, 4)

	# Get colorblind symbol if available
	var symbol := ""
	if "colorblind_symbol" in ore:
		symbol = ore.colorblind_symbol

	sparkle.configure(ore.color, rarity_value, symbol)
	block.add_child(sparkle)
	_sparkles[pos] = sparkle


func _remove_ore_sparkle(pos: Vector2i) -> void:
	## Remove sparkle effect from a position
	if not _sparkles.has(pos):
		return

	var sparkle = _sparkles[pos]
	if is_instance_valid(sparkle):
		sparkle.queue_free()
	_sparkles.erase(pos)


func _add_rarity_border(pos: Vector2i, ore) -> void:
	## Add rarity border effect to an ore block
	if not _active.has(pos):
		return
	if _rarity_borders.has(pos):
		return  # Already has a border

	var block = _active[pos]
	var border = RarityBorderScene.instantiate()

	# Get rarity from ore (convert string to int if needed)
	var rarity_value := 0
	if "rarity" in ore:
		match ore.rarity:
			"common": rarity_value = 0
			"uncommon": rarity_value = 1
			"rare": rarity_value = 2
			"epic": rarity_value = 3
			"legendary": rarity_value = 4
			_: rarity_value = 0
	elif "tier" in ore:
		rarity_value = clampi(ore.tier - 1, 0, 4)

	border.configure(rarity_value)
	block.add_child(border)
	_rarity_borders[pos] = border


func _remove_rarity_border(pos: Vector2i) -> void:
	## Remove rarity border effect from a position
	if not _rarity_borders.has(pos):
		return

	var border = _rarity_borders[pos]
	if is_instance_valid(border):
		border.queue_free()
	_rarity_borders.erase(pos)


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
# FOSSIL SPAWNING SYSTEM
# ============================================

## Fossil spawn chances by depth tier
const FOSSIL_SPAWN_CHANCE := 0.005  # 0.5% base chance per block
const FOSSIL_DEPTH_TIERS := [
	{"min_depth": 50, "max_depth": 150, "fossil_id": "fossil_common", "weight": 1.0},
	{"min_depth": 150, "max_depth": 300, "fossil_id": "fossil_rare", "weight": 0.3},
	{"min_depth": 300, "max_depth": 500, "fossil_id": "fossil_amber", "weight": 0.15},
	{"min_depth": 500, "max_depth": 99999, "fossil_id": "fossil_legendary", "weight": 0.05},
]


func _check_fossil_drop(pos: Vector2i) -> String:
	## Check if a fossil should drop at this position
	## Returns fossil_id or empty string
	var depth := pos.y - _surface_row
	if depth < 50:
		return ""  # No fossils in shallow areas

	# Use position-based seed for deterministic spawning
	var seed_value := pos.x * 73856093 + pos.y * 19349663
	_rng.seed = seed_value

	# Roll for fossil spawn
	if _rng.randf() > FOSSIL_SPAWN_CHANCE:
		return ""

	# Determine which fossil tiers are available at this depth
	var available_fossils: Array = []
	var total_weight := 0.0

	for tier in FOSSIL_DEPTH_TIERS:
		if depth >= tier["min_depth"] and depth < tier["max_depth"]:
			available_fossils.append(tier)
			total_weight += tier["weight"]

	if available_fossils.is_empty():
		return ""

	# Weighted random selection
	var roll := _rng.randf() * total_weight
	var cumulative := 0.0

	for tier in available_fossils:
		cumulative += tier["weight"]
		if roll <= cumulative:
			return tier["fossil_id"]

	# Fallback to first available
	return available_fossils[0]["fossil_id"]


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
