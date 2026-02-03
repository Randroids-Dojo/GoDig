extends Node2D
## Manages the infinite dirt grid with object pooling.
## Generates chunks around the player in all directions.
## Handles ore spawning and mining drops.

const DirtBlockScript = preload("res://scripts/world/dirt_block.gd")
const OreSparkleScene = preload("res://scenes/effects/ore_sparkle.tscn")
const RarityBorderScene = preload("res://scenes/effects/rarity_border.tscn")
const NearOreHintScene = preload("res://scenes/effects/near_ore_hint.tscn")
const OreSparkleManagerScript = preload("res://scripts/effects/ore_sparkle_manager.gd")
const ThreadedChunkGeneratorScript = preload("res://scripts/world/threaded_chunk_generator.gd")
const TreasureChestScene = preload("res://scenes/world/treasure_chest.tscn")
const LorePickupScene = preload("res://scenes/world/lore_pickup.tscn")

const BLOCK_SIZE := 128
const CHUNK_SIZE := 16  # 16x16 blocks per chunk
const POOL_SIZE := 400  # Pool size for chunks
const LOAD_RADIUS := 2  # Load chunks within 2 chunks of player (5x5 grid)

## Emitted when a block drops ore/items. item_id is empty string for dirt-only blocks.
signal block_dropped(grid_pos: Vector2i, item_id: String)

## Emitted when a fossil is found while mining
signal fossil_found(grid_pos: Vector2i, fossil_id: String)

## Emitted when a traversal item (ladder, rope) drops while mining
signal traversal_item_found(grid_pos: Vector2i, item_id: String)

## Emitted when a block is destroyed. Includes world position, color, and hardness for effects.
signal block_destroyed(world_pos: Vector2, color: Color, hardness: float)

## Emitted when an ore block is destroyed. For Tier 2 discovery celebration particles.
signal ore_discovered(world_pos: Vector2, ore_color: Color, hardness: float)

## Emitted when a block is hit but not destroyed. For per-hit particle effects.
signal block_hit(world_pos: Vector2, color: Color, hardness: float)

var _pool: Array = []  # Array of DirtBlock nodes
var _active: Dictionary = {}  # Dictionary[Vector2i, DirtBlock node]
var _loaded_chunks: Dictionary = {}  # Dictionary[Vector2i, bool] tracks loaded chunks
var _ore_map: Dictionary = {}  # Dictionary[Vector2i, String ore_id] - what ore is in each block
var _dug_tiles: Dictionary = {}  # Dictionary[Vector2i, bool] - tiles that have been mined/dug
var _placed_objects: Dictionary = {}  # Dictionary[Vector2i, int tile_type] - ladders, torches, etc.
var _dirty_chunks: Dictionary = {}  # Dictionary[Vector2i, bool] - chunks with unsaved changes
var _sparkles: Dictionary = {}  # Dictionary[Vector2i, CPUParticles2D] - sparkle effects for ore blocks (legacy)
var _rarity_borders: Dictionary = {}  # Dictionary[Vector2i, Node2D] - rarity border effects for ore blocks
var _near_ore_hints: Dictionary = {}  # Dictionary[Vector2i, CPUParticles2D] - subtle hints for near-ore blocks
var _near_ore_blocks: Dictionary = {}  # Dictionary[Vector2i, bool] - tracks blocks adjacent to ore
var _player: Node2D = null
var _active_chests: Dictionary = {}  # Dictionary[Vector2i, Node] - treasure chests in caves
var _active_lore: Dictionary = {}  # Dictionary[Vector2i, Node] - lore pickups in caves
var _treasure_room_tiles: Dictionary = {}  # Dictionary[Vector2i, bool] - tiles cleared for treasure rooms
var _active_room_glows: Dictionary = {}  # Dictionary[Vector2i, PointLight2D] - room glow effects

## MultiMesh-based sparkle manager for performance optimization
var _sparkle_manager: Node2D = null

## Use MultiMesh batching for ore sparkles (reduces draw calls significantly)
## Set to false to fall back to individual CPUParticles2D nodes
var use_multimesh_sparkles: bool = true
var _surface_row: int = 0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

## Threaded chunk generation for mobile performance optimization
## When enabled, chunk terrain data is computed on background threads
var use_threaded_generation: bool = true
var _threaded_generator: Node = null
var _pending_threaded_chunks: Dictionary = {}  # Chunks awaiting threaded generation


func _ready() -> void:
	_preallocate_pool()
	_setup_sparkle_manager()
	_setup_threaded_generator()
	# Connect to SaveManager to save dirty chunks before game save
	if SaveManager:
		SaveManager.save_started.connect(_on_save_started)
	# Connect to ExplorationManager for fog updates
	if ExplorationManager:
		ExplorationManager.exploration_updated.connect(_on_exploration_updated)


func _setup_sparkle_manager() -> void:
	## Setup the MultiMesh-based sparkle manager for optimized rendering
	if use_multimesh_sparkles:
		_sparkle_manager = OreSparkleManagerScript.new()
		_sparkle_manager.name = "OreSparkleManager"
		add_child(_sparkle_manager)


func _setup_threaded_generator() -> void:
	## Setup threaded chunk generator for mobile performance optimization
	## Automatically disabled on web exports (no thread support)
	if not use_threaded_generation:
		return

	# Check platform - disable threading on web
	if OS.has_feature("web"):
		use_threaded_generation = false
		print("[DirtGrid] Threaded generation disabled on web platform")
		return

	_threaded_generator = ThreadedChunkGeneratorScript.new()
	_threaded_generator.name = "ThreadedChunkGenerator"
	add_child(_threaded_generator)
	_threaded_generator.chunk_generated.connect(_on_threaded_chunk_generated)
	print("[DirtGrid] Threaded chunk generation enabled")


func initialize(player: Node2D, surface_row: int) -> void:
	_player = player
	_surface_row = surface_row

	# Initialize threaded generator with current state
	if _threaded_generator:
		var world_seed := SaveManager.get_world_seed() if SaveManager else 0
		_threaded_generator.initialize(_surface_row, world_seed, _dug_tiles)

	# Generate initial chunks around player spawn position
	var player_chunk := _world_to_chunk(_player.position)
	_generate_chunks_around(player_chunk)


func _process(_delta: float) -> void:
	if _player == null:
		return

	var player_chunk := _world_to_chunk(_player.position)
	_generate_chunks_around(player_chunk)
	_cleanup_distant_chunks(player_chunk)

	# Update exploration fog based on player position
	if ExplorationManager:
		ExplorationManager.update_player_position(_player.position)


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
			if not _loaded_chunks.has(chunk_pos) and not _pending_threaded_chunks.has(chunk_pos):
				if use_threaded_generation and _threaded_generator:
					# Use threaded generation for mobile performance
					if _threaded_generator.generate_chunk_async(chunk_pos):
						_pending_threaded_chunks[chunk_pos] = true
				else:
					# Fallback to synchronous generation
					_generate_chunk(chunk_pos)
					_loaded_chunks[chunk_pos] = true


func _generate_chunk(chunk_pos: Vector2i) -> void:
	## Generate a 16x16 chunk of blocks at the given chunk coordinates
	# Load any previously dug tiles for this chunk
	_load_chunk_dug_tiles(chunk_pos)

	var world_seed := SaveManager.get_world_seed() if SaveManager else 0

	# Generate back layer content for this chunk (two-layer cave system)
	if CaveLayerManager:
		CaveLayerManager.generate_back_layer_for_chunk(chunk_pos, world_seed)

	# Generate depth-based surprise discoveries for this chunk
	if DepthDiscoveryManager:
		DepthDiscoveryManager.generate_discoveries_for_chunk(chunk_pos, world_seed)

	# Check for handcrafted cave placement (Spelunky-style pre-designed rooms)
	var handcrafted_tiles: Dictionary = {}
	if HandcraftedCaveManager:
		var depth: int = chunk_pos.y * CHUNK_SIZE - _surface_row
		var placement := HandcraftedCaveManager.check_handcrafted_placement(chunk_pos, depth, world_seed)
		if placement["should_place"] and placement["template"] != null:
			handcrafted_tiles = HandcraftedCaveManager.generate_cave_from_template(
				placement["template"], chunk_pos, placement["offset"], world_seed
			)

	# Check for danger zone placement (optional high-risk high-reward areas)
	var danger_zone_tiles: Dictionary = {}
	if DangerZoneManager and handcrafted_tiles.is_empty():  # Don't overlap with handcrafted
		var depth: int = chunk_pos.y * CHUNK_SIZE - _surface_row
		var danger_result := DangerZoneManager.check_danger_zone_placement(chunk_pos, depth, world_seed)
		if danger_result["has_zone"]:
			danger_zone_tiles = danger_result["tiles"]

	var start_x := chunk_pos.x * CHUNK_SIZE
	var start_y := chunk_pos.y * CHUNK_SIZE

	# Track cave positions for chest spawning
	var cave_positions: Array[Vector2i] = []

	# Generate treasure rooms for this chunk (before block generation)
	_generate_treasure_rooms_for_chunk(chunk_pos, world_seed)

	# First pass: Generate blocks and determine ore spawns
	for local_x in range(CHUNK_SIZE):
		for local_y in range(CHUNK_SIZE):
			var grid_pos := Vector2i(start_x + local_x, start_y + local_y)

			# Skip tiles that were previously dug
			if _dug_tiles.has(grid_pos):
				continue

			# Only generate blocks at or below the surface
			if grid_pos.y >= _surface_row:
				# Check if this is a treasure room tile (cleared)
				if _treasure_room_tiles.has(grid_pos):
					cave_positions.append(grid_pos)  # Treat as cave
					continue  # Leave as empty/air

				# Check handcrafted cave tiles (Spelunky-style pre-designed rooms)
				if handcrafted_tiles.has(grid_pos):
					var tile_char: String = handcrafted_tiles[grid_pos]
					# Handle different handcrafted tile types
					if _is_handcrafted_empty(tile_char):
						cave_positions.append(grid_pos)  # Track for chest/lore spawning
						# Handle special spawn points from handcrafted template
						_handle_handcrafted_spawn(grid_pos, tile_char, world_seed)
						continue  # Leave as empty/air
					elif tile_char == "W":
						# Weak/crumbling block - create block but mark it
						if not _active.has(grid_pos):
							_acquire(grid_pos)
							# TODO: Mark as weak block for eureka mechanics
					elif tile_char == "S":
						# Secret wall - looks solid but is breakable
						if not _active.has(grid_pos):
							_acquire(grid_pos)
							# TODO: Mark as secret wall
					elif tile_char == "#":
						# Solid block
						if not _active.has(grid_pos):
							_acquire(grid_pos)
							_determine_ore_spawn(grid_pos)
					continue  # Handcrafted tile handled

				# Check danger zone tiles (optional high-risk high-reward areas)
				if danger_zone_tiles.has(grid_pos):
					var tile_char: String = danger_zone_tiles[grid_pos]
					if _is_handcrafted_empty(tile_char):
						cave_positions.append(grid_pos)  # Track for spawning
						# Handle ore spawn points in danger zones
						if tile_char == "O":
							# Spawn ore with boosted density
							_handle_danger_zone_ore_spawn(grid_pos, world_seed)
						elif tile_char == "T":
							# Unique treasure spawn point
							_handle_danger_zone_treasure_spawn(grid_pos, world_seed)
						continue  # Leave as empty/air
					elif tile_char in ["W", "#"]:
						# Solid/weak block
						if not _active.has(grid_pos):
							_acquire(grid_pos)
							_determine_ore_spawn(grid_pos)
					continue  # Danger zone tile handled

				# Check if this should be a cave tile (empty)
				if _is_cave_tile(grid_pos):
					cave_positions.append(grid_pos)  # Track for chest spawning
					continue  # Leave as empty/air

				if not _active.has(grid_pos):
					_acquire(grid_pos)
					_determine_ore_spawn(grid_pos)

	# Spawn treasure chests in cave positions
	_spawn_chests_in_caves(cave_positions, world_seed)

	# Spawn lore items in cave positions
	_spawn_lore_in_caves(cave_positions, world_seed)

	# Second pass: Apply near-ore hints to blocks that were marked
	# (ore placement marks adjacent blocks, but those blocks may have been
	# generated in a different order or in adjacent chunks)
	for local_x in range(CHUNK_SIZE):
		for local_y in range(CHUNK_SIZE):
			var grid_pos := Vector2i(start_x + local_x, start_y + local_y)
			if _active.has(grid_pos) and _near_ore_blocks.has(grid_pos):
				_check_and_add_near_ore_hint(grid_pos)


func _on_threaded_chunk_generated(chunk_pos: Vector2i, result) -> void:
	## Callback from ThreadedChunkGenerator when a chunk finishes generating.
	## Applies the pre-computed terrain data to the scene tree.

	# Remove from pending
	_pending_threaded_chunks.erase(chunk_pos)

	# Skip if generation failed
	if not result.success:
		push_warning("[DirtGrid] Threaded chunk generation failed: %s" % result.error_message)
		return

	# Load dug tiles (may have changed since generation started)
	_load_chunk_dug_tiles(chunk_pos)

	var world_seed := SaveManager.get_world_seed() if SaveManager else 0

	# Generate back layer content (must be on main thread due to manager access)
	if CaveLayerManager:
		CaveLayerManager.generate_back_layer_for_chunk(chunk_pos, world_seed)

	# Generate depth-based surprise discoveries for this chunk
	if DepthDiscoveryManager:
		DepthDiscoveryManager.generate_discoveries_for_chunk(chunk_pos, world_seed)

	# Check for handcrafted cave placement (Spelunky-style pre-designed rooms)
	var handcrafted_tiles: Dictionary = {}
	if HandcraftedCaveManager:
		var depth: int = chunk_pos.y * CHUNK_SIZE - _surface_row
		var placement := HandcraftedCaveManager.check_handcrafted_placement(chunk_pos, depth, world_seed)
		if placement["should_place"] and placement["template"] != null:
			handcrafted_tiles = HandcraftedCaveManager.generate_cave_from_template(
				placement["template"], chunk_pos, placement["offset"], world_seed
			)

	# Apply generated tiles
	var cave_positions: Array[Vector2i] = []

	for grid_pos in result.tiles:
		# Double-check dug state (may have changed)
		if _dug_tiles.has(grid_pos):
			continue

		# Check handcrafted cave tiles first (override noise caves)
		if handcrafted_tiles.has(grid_pos):
			var tile_char: String = handcrafted_tiles[grid_pos]
			if _is_handcrafted_empty(tile_char):
				cave_positions.append(grid_pos)
				_handle_handcrafted_spawn(grid_pos, tile_char, world_seed)
				continue
			elif tile_char in ["W", "S", "#"]:
				# Solid/special block - let normal generation handle it
				pass
			else:
				continue

		# Skip cave tiles
		if result.cave_tiles.has(grid_pos):
			cave_positions.append(grid_pos)
			continue

		# Skip already active blocks
		if _active.has(grid_pos):
			continue

		# Acquire and configure block using pre-computed data
		var tile_data = result.tiles[grid_pos]
		var block = _acquire(grid_pos)

		# Apply ore if present
		if tile_data.ore_id != "":
			_ore_map[grid_pos] = tile_data.ore_id
			var ore = DataRegistry.get_ore(tile_data.ore_id)
			if ore:
				_apply_ore_visual(grid_pos, ore)
				_apply_ore_hardness(grid_pos, ore)
				_add_ore_sparkle(grid_pos, ore)
				_add_rarity_border(grid_pos, ore)

	# Add remaining cave positions from threaded result
	for pos in result.cave_tiles:
		if not pos in cave_positions:
			cave_positions.append(pos)

	# Mark near-ore blocks
	for grid_pos in result.near_ore_blocks:
		_near_ore_blocks[grid_pos] = true
		if _active.has(grid_pos) and not result.ore_map.has(grid_pos):
			_check_and_add_near_ore_hint(grid_pos)

	# Spawn treasure chests in cave positions (combined handcrafted + noise)
	_spawn_chests_in_caves(cave_positions, world_seed)

	# Spawn lore items in cave positions (from threaded result)
	_spawn_lore_in_caves(cave_positions, world_seed)

	# Mark chunk as loaded
	_loaded_chunks[chunk_pos] = true


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

	# Also cancel pending threaded chunks that are now too far
	if _threaded_generator:
		var pending_to_cancel: Array[Vector2i] = []
		for chunk_pos: Vector2i in _pending_threaded_chunks.keys():
			var distance: int = maxi(absi(chunk_pos.x - center_chunk.x), absi(chunk_pos.y - center_chunk.y))
			if distance > LOAD_RADIUS + 1:
				pending_to_cancel.append(chunk_pos)
		for chunk_pos in pending_to_cancel:
			_threaded_generator.cancel_chunk_generation(chunk_pos)
			_pending_threaded_chunks.erase(chunk_pos)


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
		# Clean up ore map entry, sparkle, border, and near-ore hints when unloading
		if _ore_map.has(pos):
			_ore_map.erase(pos)
		if _near_ore_blocks.has(pos):
			_near_ore_blocks.erase(pos)
		_remove_ore_sparkle(pos)
		_remove_rarity_border(pos)
		_remove_near_ore_hint(pos)
		_release(pos)

	# Clean up treasure chests and lore in this chunk
	for local_x in range(CHUNK_SIZE):
		for local_y in range(CHUNK_SIZE):
			var grid_pos := Vector2i(start_x + local_x, start_y + local_y)
			_remove_chest(grid_pos)
			_remove_lore(grid_pos)

	# Clean up treasure room data for this chunk
	_cleanup_treasure_room_data(chunk_pos)

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

	# Mark ladder position as explored (critical for return planning)
	if ExplorationManager:
		ExplorationManager.mark_ladder_placed(pos)

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


## Get the highest placed ladder position (smallest Y value, closest to surface)
## Returns null if no ladders are placed
func get_highest_ladder_position() -> Variant:
	var highest_pos: Vector2i = Vector2i(0, 999999)
	var found := false

	for pos in _placed_objects:
		if _placed_objects[pos] == TileTypes.Type.LADDER:
			if pos.y < highest_pos.y:
				highest_pos = pos
				found = true

	if found:
		return highest_pos
	return null


## Get all ladder positions sorted by depth (highest first)
func get_all_ladder_positions() -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	for pos in _placed_objects:
		if _placed_objects[pos] == TileTypes.Type.LADDER:
			positions.append(pos)

	# Sort by Y coordinate (ascending = highest first)
	positions.sort_custom(func(a: Vector2i, b: Vector2i): return a.y < b.y)
	return positions


## Get the number of placed ladders
func get_ladder_count() -> int:
	var count := 0
	for pos in _placed_objects:
		if _placed_objects[pos] == TileTypes.Type.LADDER:
			count += 1
	return count


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

	# Emit hit signal for per-hit particle effects (not on destruction, that has its own signal)
	if not destroyed:
		var world_pos := Vector2(
			pos.x * BLOCK_SIZE + GameManager.GRID_OFFSET_X + BLOCK_SIZE / 2,
			pos.y * BLOCK_SIZE + BLOCK_SIZE / 2
		)
		block_hit.emit(world_pos, block.base_color, block.max_health)

	if destroyed:
		# Signal what dropped (ore or empty string for plain dirt)
		var ore_id := _ore_map.get(pos, "") as String
		block_dropped.emit(pos, ore_id)

		# Check for fossil drop
		var fossil_id := _check_fossil_drop(pos)
		if fossil_id != "":
			fossil_found.emit(pos, fossil_id)

		# Check for traversal item drop (ladder/rope - rare drop from any block)
		var traversal_id := _check_traversal_drop(pos)
		if traversal_id != "":
			traversal_item_found.emit(pos, traversal_id)

		# Signal for particle effects (before releasing block)
		var world_pos := Vector2(
			pos.x * BLOCK_SIZE + GameManager.GRID_OFFSET_X + BLOCK_SIZE / 2,
			pos.y * BLOCK_SIZE + BLOCK_SIZE / 2
		)

		# Two-tier juice system: emit different signals for ore vs regular blocks
		if ore_id != "":
			# Tier 2: Ore discovery celebration - use ore color for particles
			var ore = DataRegistry.get_ore(ore_id)
			var ore_color: Color = ore.color if ore != null else block.base_color
			ore_discovered.emit(world_pos, ore_color, block.max_health)
		else:
			# Tier 1: Regular block destruction
			block_destroyed.emit(world_pos, block.base_color, block.max_health)

		# Play sound effect with tool tier for satisfying feel differentiation
		# Ore discovery gets special ore-specific sound in SoundManager
		if SoundManager:
			var tool_tier := 1
			if PlayerData:
				tool_tier = PlayerData.get_tool_tier()
			if ore_id != "":
				# Use ore-specific discovery sound (pitch/volume varies by ore type)
				var ore = DataRegistry.get_ore(ore_id) if DataRegistry else null
				SoundManager.play_ore_discovery(ore)  # Tier 2 discovery sound
			# Get streak pitch for combo audio feedback
			var streak_pitch := 1.0
			if MiningBonusManager:
				streak_pitch = MiningBonusManager.get_streak_pitch_multiplier()
			SoundManager.play_block_break(block.max_health, tool_tier, streak_pitch)

		# Clean up ore map entry, sparkle, border, and near-ore hints
		if _ore_map.has(pos):
			_ore_map.erase(pos)
		if _near_ore_blocks.has(pos):
			_near_ore_blocks.erase(pos)
		_remove_ore_sparkle(pos)
		_remove_rarity_border(pos)
		_remove_near_ore_hint(pos)

		# Mark tile as dug for persistence
		_dug_tiles[pos] = true
		var chunk_pos := _grid_to_chunk(pos)
		_dirty_chunks[chunk_pos] = true

		# Mark mined position as permanently explored
		if ExplorationManager:
			ExplorationManager.mark_block_mined(pos)

		# Check for enemy spawn (depth-gated, respects peaceful mode)
		var depth := pos.y - _surface_row
		if EnemyManager and depth > 0:
			var spawned_enemy := EnemyManager.check_enemy_spawn(pos, depth)
			if spawned_enemy != "":
				print("[DirtGrid] Enemy spawned: %s at depth %d" % [spawned_enemy, depth])

		# Check for eureka mechanic trigger (depth-specific 'aha' moments)
		if EurekaMechanicManager and depth > 0:
			EurekaMechanicManager.on_block_destroyed(pos, depth)

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
# HANDCRAFTED CAVE HELPERS (Spelunky-style)
# ============================================

func _is_handcrafted_empty(tile_char: String) -> bool:
	## Check if a handcrafted tile character represents empty space
	## These tiles are passable and count as cave positions
	return tile_char in [".", ">", "<", "^", "v", "O", "T", "L", "E", "P"]


func _handle_handcrafted_spawn(grid_pos: Vector2i, tile_char: String, world_seed: int) -> void:
	## Handle special spawn points from handcrafted cave templates
	## Called for empty tiles that may have special spawns
	var depth: int = grid_pos.y - _surface_row

	match tile_char:
		"O":
			# Ore spawn point - spawn depth-appropriate ore
			_spawn_handcrafted_ore(grid_pos, depth, world_seed)
		"T":
			# Treasure spawn point - guaranteed treasure chest
			_spawn_guaranteed_chest(grid_pos, world_seed)
		"L":
			# Ladder spawn point - place a ladder
			_spawn_handcrafted_ladder(grid_pos)
		"E":
			# Enemy spawn point - notify enemy manager
			if EnemyManager:
				EnemyManager.register_spawn_point(grid_pos, depth)
		"P":
			# Platform - create a thin platform block
			# For now, treat as regular cave (platform visuals handled separately)
			pass


func _spawn_handcrafted_ore(grid_pos: Vector2i, depth: int, world_seed: int) -> void:
	## Spawn an ore block at a handcrafted ore spawn point
	## Uses depth-appropriate ore selection
	if not DataRegistry:
		return

	# Seed RNG for deterministic ore type
	var pos_hash := grid_pos.x * 198491317 + grid_pos.y * 6542989 + world_seed
	_rng.seed = pos_hash

	# Get valid ores for this depth
	var ore_id := DataRegistry.get_random_ore_for_depth(depth, _rng)
	if ore_id == "":
		return

	# Create the block and set ore
	if not _active.has(grid_pos):
		_acquire(grid_pos)

	_ore_map[grid_pos] = ore_id
	var block = _active.get(grid_pos)
	if block != null:
		var ore = DataRegistry.get_ore(ore_id)
		if ore != null:
			block.set_ore(ore_id, ore.color)
			_register_ore_effects(grid_pos, ore_id, ore)


func _spawn_guaranteed_chest(grid_pos: Vector2i, world_seed: int) -> void:
	## Spawn a guaranteed treasure chest at a handcrafted treasure point
	if not TreasureChestManager:
		return

	# Skip if already has a chest
	if _active_chests.has(grid_pos):
		return

	var depth: int = grid_pos.y - _surface_row
	var chest_data := TreasureChestManager.generate_chest_loot(depth)

	# Create chest instance
	var chest := TreasureChestScene.instantiate()
	chest.position = Vector2(grid_pos.x * BLOCK_SIZE + BLOCK_SIZE / 2, grid_pos.y * BLOCK_SIZE + BLOCK_SIZE / 2)
	chest.grid_pos = grid_pos
	chest.loot_data = chest_data
	chest.chest_opened.connect(_on_chest_opened.bind(grid_pos))

	add_child(chest)
	_active_chests[grid_pos] = chest


func _spawn_handcrafted_ladder(grid_pos: Vector2i) -> void:
	## Spawn a ladder at a handcrafted ladder spawn point
	## Places a ladder pickup or pre-placed ladder
	# Mark position as having a ladder object
	_placed_objects[grid_pos] = 1  # 1 = ladder

	# The actual ladder rendering is handled by the placed objects system
	# This ensures the ladder persists across chunk loading


# ============================================
# DANGER ZONE SPAWNING
# ============================================

func _handle_danger_zone_ore_spawn(grid_pos: Vector2i, world_seed: int) -> void:
	## Handle ore spawning in danger zones with boosted density.
	## Danger zones have higher ore concentration and may have unique drops.
	if not DataRegistry:
		return

	var depth: int = grid_pos.y - _surface_row
	if depth < 0:
		return

	# Seed RNG for deterministic ore type
	var pos_hash := grid_pos.x * 198491317 + grid_pos.y * 6542989 + world_seed + 42069
	_rng.seed = pos_hash

	# Get ore multiplier from danger zone manager
	var ore_multiplier := 1.0
	if DangerZoneManager:
		ore_multiplier = DangerZoneManager.get_ore_multiplier_at(grid_pos)

	# Boosted chance to spawn ore (danger zone benefit)
	if _rng.randf() > (0.7 * ore_multiplier):  # Base ~30% chance, boosted in zones
		return

	# Get valid ores for this depth
	var ore_id := DataRegistry.get_random_ore_for_depth(depth, _rng)
	if ore_id == "":
		return

	# Create the block and set ore
	if not _active.has(grid_pos):
		_acquire(grid_pos)

	_ore_map[grid_pos] = ore_id
	var block = _active.get(grid_pos)
	if block != null:
		var ore = DataRegistry.get_ore(ore_id)
		if ore != null:
			block.set_ore(ore_id, ore.color)
			_register_ore_effects(grid_pos, ore_id, ore)


func _handle_danger_zone_treasure_spawn(grid_pos: Vector2i, world_seed: int) -> void:
	## Handle unique treasure spawning in danger zones.
	## These can contain zone-specific unique drops.
	if not TreasureChestManager:
		return

	# Skip if already has a chest
	if _active_chests.has(grid_pos):
		return

	var depth: int = grid_pos.y - _surface_row

	# Get zone info for unique drops
	var zone_config := {}
	if DangerZoneManager:
		zone_config = DangerZoneManager.get_zone_config_at(grid_pos)

	# Generate chest with zone-specific loot
	var chest_data := TreasureChestManager.generate_chest_loot(depth)

	# Add unique drops from danger zone
	var unique_drops: Array = zone_config.get("unique_drops", [])
	if not unique_drops.is_empty():
		# Seed RNG
		var pos_hash := grid_pos.x * 73856093 + grid_pos.y * 19349663 + world_seed
		_rng.seed = pos_hash

		# 40% chance for unique drop in danger zone treasure
		if _rng.randf() < 0.4:
			var unique_item: String = unique_drops[_rng.randi() % unique_drops.size()]
			chest_data["unique_item"] = unique_item

	# Create chest instance
	var chest := TreasureChestScene.instantiate()
	chest.position = Vector2(grid_pos.x * BLOCK_SIZE + BLOCK_SIZE / 2, grid_pos.y * BLOCK_SIZE + BLOCK_SIZE / 2)
	chest.grid_pos = grid_pos
	chest.loot_data = chest_data
	chest.chest_opened.connect(_on_chest_opened.bind(grid_pos))

	add_child(chest)
	_active_chests[grid_pos] = chest


# ============================================
# TREASURE CHEST SPAWNING IN CAVES
# ============================================

func _spawn_chests_in_caves(cave_positions: Array[Vector2i], world_seed: int) -> void:
	## Spawn treasure chests in qualifying cave positions.
	## Uses TreasureChestManager for loot generation and tracking.
	if not TreasureChestManager:
		return

	for pos in cave_positions:
		var depth := pos.y - _surface_row
		if depth < 0:
			continue

		# Check if manager says a chest should spawn here
		if TreasureChestManager.should_spawn_chest(pos, depth, world_seed):
			_spawn_chest_at(pos, depth, world_seed)


func _spawn_chest_at(pos: Vector2i, depth: int, world_seed: int) -> void:
	## Spawn a treasure chest visual at the given cave position.
	if _active_chests.has(pos):
		return  # Already spawned

	if not TreasureChestManager:
		return

	# Tell manager to generate chest data
	TreasureChestManager.spawn_chest(pos, depth, world_seed)

	# Create visual chest instance
	var chest = TreasureChestScene.instantiate()
	var chest_data := TreasureChestManager.get_chest_data(pos)

	# Configure chest with tier info
	var tier: int = chest_data.get("tier", 0)
	var tier_name: String = chest_data.get("tier_name", "Chest")
	chest.configure(pos, tier, tier_name)

	add_child(chest)
	_active_chests[pos] = chest


func _remove_chest(pos: Vector2i) -> void:
	## Remove a chest visual from the world.
	if not _active_chests.has(pos):
		return

	var chest = _active_chests[pos]
	if is_instance_valid(chest):
		chest.queue_free()
	_active_chests.erase(pos)


# ============================================
# LORE PICKUP SPAWNING IN CAVES
# ============================================

func _spawn_lore_in_caves(cave_positions: Array[Vector2i], world_seed: int) -> void:
	## Spawn lore pickups in qualifying cave positions.
	## Uses JournalManager for tracking and spawn rolls.
	if not JournalManager:
		return

	for pos in cave_positions:
		var depth := pos.y - _surface_row
		if depth < 20:  # Minimum depth for lore
			continue

		# Check if JournalManager rolls a lore spawn
		var lore_id := JournalManager.roll_lore_spawn(pos, depth, world_seed)
		if lore_id != "":
			_spawn_lore_at(pos, lore_id)


func _spawn_lore_at(pos: Vector2i, lore_id: String) -> void:
	## Spawn a lore pickup visual at the given cave position.
	if _active_lore.has(pos):
		return  # Already spawned

	if not JournalManager:
		return

	# Skip if already picked up
	if JournalManager.was_lore_opened(pos):
		return

	# Create visual lore pickup instance
	var lore_pickup = LorePickupScene.instantiate()
	lore_pickup.configure(pos, lore_id)

	add_child(lore_pickup)
	_active_lore[pos] = lore_pickup


func _remove_lore(pos: Vector2i) -> void:
	## Remove a lore pickup visual from the world.
	if not _active_lore.has(pos):
		return

	var lore_pickup = _active_lore[pos]
	if is_instance_valid(lore_pickup):
		lore_pickup.queue_free()
	_active_lore.erase(pos)

	# Also remove from JournalManager tracking (will reload from save when chunk loads)
	if JournalManager:
		JournalManager.remove_spawned_lore(pos)


# ============================================
# HIDDEN TREASURE ROOM GENERATION
# ============================================

func _generate_treasure_rooms_for_chunk(chunk_pos: Vector2i, world_seed: int) -> void:
	## Check for and generate treasure rooms in this chunk.
	## Rooms are carved spaces with special loot.
	if not TreasureRoomManager:
		return

	var start_x := chunk_pos.x * CHUNK_SIZE
	var start_y := chunk_pos.y * CHUNK_SIZE

	# Check each position in chunk for potential room spawn
	for local_x in range(CHUNK_SIZE):
		for local_y in range(CHUNK_SIZE):
			var grid_pos := Vector2i(start_x + local_x, start_y + local_y)

			# Only check below surface
			if grid_pos.y < _surface_row:
				continue

			var depth := grid_pos.y - _surface_row

			# Check if this position should have a treasure room
			# Only check cave tiles as potential room centers
			if not _is_cave_tile(grid_pos):
				continue

			var room_type := TreasureRoomManager.check_room_spawn(
				grid_pos, depth, world_seed, chunk_pos
			)

			if room_type >= 0:
				# Generate the room and get positions to clear
				var cleared_positions := TreasureRoomManager.generate_room(
					grid_pos, room_type, depth, world_seed
				)

				# Mark all positions as treasure room tiles
				for pos in cleared_positions:
					_treasure_room_tiles[pos] = true

				# Add glow effect at room center
				_add_room_glow(grid_pos, room_type)


func _add_room_glow(center_pos: Vector2i, room_type: int) -> void:
	## Add a glow effect at the center of a treasure room.
	if _active_room_glows.has(center_pos):
		return  # Already has glow

	if not TreasureRoomManager:
		return

	var config: Dictionary = TreasureRoomManager.ROOM_CONFIG.get(room_type, {})
	if config.is_empty():
		return

	# Create point light for room glow
	var glow := PointLight2D.new()
	glow.color = config.get("glow_color", Color.WHITE)
	glow.energy = config.get("glow_energy", 0.5)
	glow.texture_scale = 1.0

	# Position at room center in world coordinates
	glow.position = Vector2(
		center_pos.x * BLOCK_SIZE + GameManager.GRID_OFFSET_X + BLOCK_SIZE / 2,
		center_pos.y * BLOCK_SIZE + BLOCK_SIZE / 2
	)

	add_child(glow)
	_active_room_glows[center_pos] = glow


func _remove_room_glow(center_pos: Vector2i) -> void:
	## Remove a room glow effect.
	if not _active_room_glows.has(center_pos):
		return

	var glow = _active_room_glows[center_pos]
	if is_instance_valid(glow):
		glow.queue_free()
	_active_room_glows.erase(center_pos)


func _cleanup_treasure_room_data(chunk_pos: Vector2i) -> void:
	## Clean up treasure room data when chunk unloads.
	var start_x := chunk_pos.x * CHUNK_SIZE
	var start_y := chunk_pos.y * CHUNK_SIZE

	# Remove treasure room tiles for this chunk
	for local_x in range(CHUNK_SIZE):
		for local_y in range(CHUNK_SIZE):
			var grid_pos := Vector2i(start_x + local_x, start_y + local_y)
			_treasure_room_tiles.erase(grid_pos)

	# Remove room glows and notify manager
	if TreasureRoomManager:
		TreasureRoomManager.unload_chunk_rooms(chunk_pos)

	# Clean up glows in this chunk
	var glows_to_remove: Array[Vector2i] = []
	for center_pos in _active_room_glows:
		var glow_chunk := Vector2i(
			int(floor(float(center_pos.x) / CHUNK_SIZE)),
			int(floor(float(center_pos.y) / CHUNK_SIZE))
		)
		if glow_chunk == chunk_pos:
			glows_to_remove.append(center_pos)

	for center_pos in glows_to_remove:
		_remove_room_glow(center_pos)


# ============================================
# ORE SPAWNING LOGIC
# ============================================

## Player spawn position (grid x coordinate)
const PLAYER_SPAWN_X := 4  # Based on SpawnPoint at 512px / 128 block size = 4

## Guaranteed first ore position (3 blocks below surface, directly under spawn)
const FIRST_ORE_DEPTH := 2  # SURFACE_ROW + 2 = 3 blocks below spawn

func _determine_ore_spawn(pos: Vector2i) -> void:
	## Determine if this position should contain ore based on depth and rarity
	## Uses vein expansion (random walk) to create ore clusters
	var depth := pos.y - GameManager.SURFACE_ROW
	if depth < 0:
		return  # No ores above surface

	# Skip if already has ore (from vein expansion)
	if _ore_map.has(pos):
		return

	# GUARANTEED FIRST ORE: Ensure new players find ore quickly
	# Place coal at (PLAYER_SPAWN_X, SURFACE_ROW + FIRST_ORE_DEPTH) for new games
	if _should_spawn_guaranteed_ore(pos, depth):
		_spawn_guaranteed_first_ore(pos)
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

	# Mark adjacent blocks as "near ore" for subtle hints
	_mark_adjacent_near_ore(pos)


func _should_spawn_guaranteed_ore(pos: Vector2i, depth: int) -> bool:
	## Check if this position should have the guaranteed first ore for new players
	## Returns true only for new games at the specific first-ore position
	if SaveManager == null:
		return false

	# Only spawn guaranteed ore if it hasn't been spawned yet
	if SaveManager.has_first_ore_spawned():
		return false

	# Check if this is the guaranteed ore position (directly below spawn, 2 blocks deep)
	if pos.x != PLAYER_SPAWN_X:
		return false
	if depth != FIRST_ORE_DEPTH:
		return false

	return true


func _spawn_guaranteed_first_ore(pos: Vector2i) -> void:
	## Spawn the guaranteed first ore (coal) for new players
	## This ensures players find ore within their first few blocks of mining
	var coal_ore = DataRegistry.get_ore("coal")
	if coal_ore == null:
		push_warning("[DirtGrid] Could not find coal ore for guaranteed first ore")
		return

	# Place the coal ore
	_place_ore_at(pos, coal_ore)

	# Mark as spawned so it doesn't happen again
	if SaveManager:
		SaveManager.set_first_ore_spawned()

	print("[DirtGrid] Guaranteed first ore (coal) spawned at %s" % str(pos))


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

	# Use MultiMesh manager if available (better performance)
	if use_multimesh_sparkles and _sparkle_manager != null:
		# Calculate world position for the sparkle
		var world_pos := Vector2(
			pos.x * BLOCK_SIZE + GameManager.GRID_OFFSET_X + BLOCK_SIZE / 2,
			pos.y * BLOCK_SIZE + BLOCK_SIZE / 2
		)
		_sparkle_manager.register_sparkle(pos, world_pos, ore.color, rarity_value, symbol)
	else:
		# Fallback to individual sparkle nodes (legacy approach)
		if _sparkles.has(pos):
			return  # Already has a sparkle

		var block = _active[pos]
		var sparkle = OreSparkleScene.instantiate()
		sparkle.configure(ore.color, rarity_value, symbol)
		block.add_child(sparkle)
		_sparkles[pos] = sparkle


func _remove_ore_sparkle(pos: Vector2i) -> void:
	## Remove sparkle effect from a position
	# Use MultiMesh manager if available
	if use_multimesh_sparkles and _sparkle_manager != null:
		_sparkle_manager.unregister_sparkle(pos)
	else:
		# Fallback to individual sparkle nodes (legacy approach)
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
# NEAR-ORE HINT SYSTEM
# ============================================

## Directions for adjacent block checks (cardinal + diagonal)
const ADJACENT_DIRECTIONS := [
	Vector2i(1, 0),   # Right
	Vector2i(-1, 0),  # Left
	Vector2i(0, 1),   # Down
	Vector2i(0, -1),  # Up
	Vector2i(1, 1),   # Down-Right
	Vector2i(-1, 1),  # Down-Left
	Vector2i(1, -1),  # Up-Right
	Vector2i(-1, -1), # Up-Left
]

## Depth at which hints start becoming subtle (players have learned the pattern)
const HINT_LEARNING_DEPTH := 100


func _mark_adjacent_near_ore(ore_pos: Vector2i) -> void:
	## Mark blocks adjacent to an ore position as "near ore" for subtle hints.
	## Only marks blocks that don't already contain ore.
	for dir: Vector2i in ADJACENT_DIRECTIONS:
		var adj_pos: Vector2i = ore_pos + dir

		# Skip if this position already has ore
		if _ore_map.has(adj_pos):
			continue

		# Skip if already marked as near-ore
		if _near_ore_blocks.has(adj_pos):
			continue

		# Skip if the block was already dug
		if _dug_tiles.has(adj_pos):
			continue

		# Mark as near-ore
		_near_ore_blocks[adj_pos] = true

		# Add hint visual if block is active (loaded)
		if _active.has(adj_pos):
			_add_near_ore_hint(adj_pos)


func _add_near_ore_hint(pos: Vector2i) -> void:
	## Add a subtle near-ore hint effect to a block
	if not _active.has(pos):
		return
	if _near_ore_hints.has(pos):
		return  # Already has a hint

	# Don't add hints to blocks that have ore themselves
	if _ore_map.has(pos):
		return

	var block = _active[pos]
	var hint = NearOreHintScene.instantiate()

	# Calculate depth factor - hints become subtler as player learns
	var depth := pos.y - GameManager.SURFACE_ROW
	var depth_factor := 1.0
	if depth > HINT_LEARNING_DEPTH:
		# Gradually reduce hint obviousness with depth (skill development)
		depth_factor = maxf(0.3, 1.0 - (float(depth - HINT_LEARNING_DEPTH) / 400.0))

	hint.configure(depth_factor)
	block.add_child(hint)
	_near_ore_hints[pos] = hint


func _remove_near_ore_hint(pos: Vector2i) -> void:
	## Remove near-ore hint effect from a position
	if not _near_ore_hints.has(pos):
		return

	var hint = _near_ore_hints[pos]
	if is_instance_valid(hint):
		hint.queue_free()
	_near_ore_hints.erase(pos)


func _check_and_add_near_ore_hint(pos: Vector2i) -> void:
	## Check if a position should have a near-ore hint and add it.
	## Called when blocks are activated to handle hints for pre-existing ore.
	if not _near_ore_blocks.has(pos):
		return
	if _ore_map.has(pos):
		return  # Don't add hints to ore blocks
	_add_near_ore_hint(pos)


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
# TRAVERSAL ITEM DROP SYSTEM (Ladder/Rope)
# ============================================

## Traversal item drop rates by depth
## Only drops in top 100m to preserve shop economy below
const TRAVERSAL_DROP_CONFIGS := [
	# Shallow (0-50m): 3% ladder, no rope
	{"min_depth": 0, "max_depth": 50, "item_id": "ladder", "chance": 0.03},
	# Mid (50-100m): 2% ladder, 1% rope
	{"min_depth": 50, "max_depth": 100, "item_id": "ladder", "chance": 0.02},
	{"min_depth": 50, "max_depth": 100, "item_id": "rope", "chance": 0.01},
]


func _check_traversal_drop(pos: Vector2i) -> String:
	## Check if a traversal item (ladder/rope) should drop at this position.
	## Returns item_id or empty string.
	## These rare drops create excitement and provide backup for underprepared players.
	var depth := pos.y - _surface_row
	if depth < 0:
		return ""  # No drops above surface

	if depth >= 100:
		return ""  # No drops below 100m - must buy from shops

	# Use position-based seed for deterministic drops (different from fossil seed)
	var seed_value := pos.x * 314159265 + pos.y * 271828182
	_rng.seed = seed_value

	# Check each drop config that matches our depth
	for config in TRAVERSAL_DROP_CONFIGS:
		if depth >= config["min_depth"] and depth < config["max_depth"]:
			# Roll for this item
			if _rng.randf() < config["chance"]:
				return config["item_id"]

	return ""


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


func debug_sparkle_stats() -> Dictionary:
	## Get sparkle system statistics for performance monitoring
	var stats := {
		"using_multimesh": use_multimesh_sparkles,
		"registered_ores": 0,
		"active_sparkles": 0,
		"legacy_sparkles": _sparkles.size(),
	}

	if use_multimesh_sparkles and _sparkle_manager != null:
		stats["registered_ores"] = _sparkle_manager.get_registered_count()
		stats["active_sparkles"] = _sparkle_manager.get_active_sparkle_count()

	return stats


func debug_threaded_stats() -> Dictionary:
	## Get threaded chunk generation statistics for performance monitoring
	var stats := {
		"using_threaded": use_threaded_generation,
		"pending_chunks": _pending_threaded_chunks.size(),
		"generator_pending": 0,
	}

	if _threaded_generator:
		stats["generator_pending"] = _threaded_generator.get_pending_count()

	return stats


# ============================================
# EXPLORATION/FOG SYSTEM
# ============================================

func _on_exploration_updated() -> void:
	## Called when exploration state changes - update visible block modulation.
	## Only updates blocks within a reasonable radius of player for performance.
	if _player == null:
		return

	var player_grid := GameManager.world_to_grid(_player.position)
	var update_radius := ExplorationManager.VISION_RADIUS + 2

	for dx in range(-update_radius, update_radius + 1):
		for dy in range(-update_radius, update_radius + 1):
			var pos := Vector2i(player_grid.x + dx, player_grid.y + dy)
			if _active.has(pos):
				var block = _active[pos]
				if block.has_method("update_visibility"):
					block.update_visibility()
