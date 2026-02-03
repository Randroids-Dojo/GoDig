extends Node
## ThreadedChunkGenerator - Generates chunk terrain data on background threads.
##
## This class offloads the computationally expensive terrain generation to
## WorkerThreadPool, reducing main thread stutter on mobile devices.
##
## How it works:
## 1. DirtGrid requests chunk generation via generate_chunk_async()
## 2. Heavy calculations (ore spawning, cave generation) run on worker thread
## 3. Worker returns ChunkGenerationResult with tile data
## 4. Main thread applies the result to the scene tree via callback
##
## Thread Safety Notes:
## - Only read-only access to DataRegistry (layers, ores are preloaded)
## - RNG is per-chunk seeded, so deterministic across threads
## - No scene tree access from worker threads


## Signal emitted when a chunk finishes generating
## chunk_pos: Vector2i - the chunk coordinates
## result: ChunkGenerationResult - the generated tile data
signal chunk_generated(chunk_pos: Vector2i, result: ChunkGenerationResult)


## Chunk generation result data (thread-safe, plain data)
class ChunkGenerationResult:
	## Chunk coordinates
	var chunk_pos: Vector2i = Vector2i.ZERO

	## Dictionary[Vector2i, TileGenerationData] - tiles to create
	var tiles: Dictionary = {}

	## Dictionary[Vector2i, String] - ore IDs at each position
	var ore_map: Dictionary = {}

	## Dictionary[Vector2i, bool] - positions marked as near-ore
	var near_ore_blocks: Dictionary = {}

	## Dictionary[Vector2i, bool] - cave/empty positions
	var cave_tiles: Dictionary = {}

	## Whether generation was successful
	var success: bool = true

	## Error message if generation failed
	var error_message: String = ""


## Per-tile generation data (no scene tree references)
class TileGenerationData:
	var grid_pos: Vector2i = Vector2i.ZERO
	var hardness: float = 10.0
	var color: Color = Color.BROWN
	var ore_id: String = ""
	var ore_hardness: float = 0.0
	var ore_color: Color = Color.WHITE
	var is_near_ore: bool = false


## Generation constants (same as DirtGrid)
const CHUNK_SIZE := 16
const CAVE_MIN_DEPTH := 20
const CAVE_FREQUENCY := 0.05
const CAVE_THRESHOLD := 0.85
const CAVE_DEPTH_FACTOR := 0.001


## Queue of pending chunk generation tasks
## Key: Vector2i (chunk_pos), Value: task_id from WorkerThreadPool
var _pending_tasks: Dictionary = {}

## Completed results waiting to be processed on main thread
## Using mutex for thread-safe access
var _completed_results: Array = []
var _results_mutex: Mutex = Mutex.new()

## Surface row (cached from GameManager)
var _surface_row: int = 0

## World seed for deterministic generation
var _world_seed: int = 0

## Reference to dug tiles from save (read-only)
var _dug_tiles_ref: Dictionary = {}


func _ready() -> void:
	# Cache values that are safe to read from any thread
	if GameManager:
		_surface_row = GameManager.SURFACE_ROW
	if SaveManager:
		_world_seed = SaveManager.get_world_seed()


func _process(_delta: float) -> void:
	# Process completed results on main thread
	_process_completed_results()


## Initialize with references from DirtGrid
func initialize(surface_row: int, world_seed: int, dug_tiles: Dictionary) -> void:
	_surface_row = surface_row
	_world_seed = world_seed
	_dug_tiles_ref = dug_tiles


## Request async generation of a chunk
## Returns true if generation was queued, false if already pending
func generate_chunk_async(chunk_pos: Vector2i) -> bool:
	# Skip if already being generated
	if _pending_tasks.has(chunk_pos):
		return false

	# Create generation context (thread-safe data only)
	var context := {
		"chunk_pos": chunk_pos,
		"surface_row": _surface_row,
		"world_seed": _world_seed,
		"dug_tiles": _dug_tiles_ref.duplicate(),  # Copy for thread safety
	}

	# Queue work on thread pool
	var task_id := WorkerThreadPool.add_task(
		_generate_chunk_thread.bind(context)
	)

	_pending_tasks[chunk_pos] = task_id
	return true


## Cancel pending generation for a chunk
func cancel_chunk_generation(chunk_pos: Vector2i) -> void:
	if _pending_tasks.has(chunk_pos):
		# Note: WorkerThreadPool doesn't support true cancellation
		# The task will complete but result will be ignored
		_pending_tasks.erase(chunk_pos)


## Check if a chunk is currently being generated
func is_generating(chunk_pos: Vector2i) -> bool:
	return _pending_tasks.has(chunk_pos)


## Get count of pending generations (for debugging)
func get_pending_count() -> int:
	return _pending_tasks.size()


## Thread-safe chunk generation (runs on WorkerThreadPool)
## This method MUST NOT access the scene tree
func _generate_chunk_thread(context: Dictionary) -> void:
	var chunk_pos: Vector2i = context["chunk_pos"]
	var surface_row: int = context["surface_row"]
	var world_seed: int = context["world_seed"]
	var dug_tiles: Dictionary = context["dug_tiles"]

	var result := ChunkGenerationResult.new()
	result.chunk_pos = chunk_pos

	# Per-chunk RNG for deterministic generation
	var rng := RandomNumberGenerator.new()
	rng.seed = world_seed + chunk_pos.x * 73856093 + chunk_pos.y * 19349663

	var start_x := chunk_pos.x * CHUNK_SIZE
	var start_y := chunk_pos.y * CHUNK_SIZE

	# First pass: Generate terrain and determine ore spawns
	for local_x in range(CHUNK_SIZE):
		for local_y in range(CHUNK_SIZE):
			var grid_pos := Vector2i(start_x + local_x, start_y + local_y)

			# Skip tiles that were previously dug
			if dug_tiles.has(grid_pos):
				continue

			# Only generate at or below surface
			if grid_pos.y < surface_row:
				continue

			# Check if this should be a cave tile
			if _is_cave_tile_thread(grid_pos, surface_row):
				result.cave_tiles[grid_pos] = true
				continue

			# Generate tile data
			var tile_data := TileGenerationData.new()
			tile_data.grid_pos = grid_pos

			# Get hardness and color from depth
			var depth := grid_pos.y - surface_row
			tile_data.hardness = _get_block_hardness_thread(grid_pos, depth)
			tile_data.color = _get_block_color_thread(grid_pos, depth, rng)

			result.tiles[grid_pos] = tile_data

	# Second pass: Determine ore spawns (needs all tiles first for vein expansion)
	for grid_pos in result.tiles:
		var tile_data: TileGenerationData = result.tiles[grid_pos]
		var depth := grid_pos.y - surface_row

		# Skip if already has ore from vein expansion
		if result.ore_map.has(grid_pos):
			tile_data.ore_id = result.ore_map[grid_pos]
			continue

		# Check for ore spawn
		_determine_ore_spawn_thread(grid_pos, depth, result, rng)

	# Third pass: Mark near-ore blocks
	for ore_pos in result.ore_map:
		_mark_adjacent_near_ore_thread(ore_pos, result)

	# Apply ore data to tiles
	for grid_pos in result.ore_map:
		if result.tiles.has(grid_pos):
			var tile_data: TileGenerationData = result.tiles[grid_pos]
			tile_data.ore_id = result.ore_map[grid_pos]

			# Get ore properties for visual application
			var ore = DataRegistry.get_ore(tile_data.ore_id)
			if ore:
				tile_data.ore_color = ore.color
				tile_data.ore_hardness = ore.hardness

	# Mark near-ore tiles
	for grid_pos in result.near_ore_blocks:
		if result.tiles.has(grid_pos) and not result.ore_map.has(grid_pos):
			var tile_data: TileGenerationData = result.tiles[grid_pos]
			tile_data.is_near_ore = true

	# Store result thread-safely
	_results_mutex.lock()
	_completed_results.append(result)
	_results_mutex.unlock()


## Process completed results on main thread
func _process_completed_results() -> void:
	_results_mutex.lock()
	var results := _completed_results.duplicate()
	_completed_results.clear()
	_results_mutex.unlock()

	for result in results:
		var chunk_pos: Vector2i = result.chunk_pos

		# Remove from pending (may have been cancelled)
		if _pending_tasks.has(chunk_pos):
			_pending_tasks.erase(chunk_pos)
			# Emit signal for DirtGrid to apply result
			chunk_generated.emit(chunk_pos, result)


## Thread-safe cave tile check
func _is_cave_tile_thread(pos: Vector2i, surface_row: int) -> bool:
	var depth := pos.y - surface_row
	if depth < CAVE_MIN_DEPTH:
		return false

	var noise_val := _generate_cave_noise_thread(pos)
	var depth_bonus := minf(depth * CAVE_DEPTH_FACTOR, 0.1)
	var adjusted_threshold := CAVE_THRESHOLD - depth_bonus

	return noise_val > adjusted_threshold


## Thread-safe cave noise generation
func _generate_cave_noise_thread(pos: Vector2i) -> float:
	var hash1 := (pos.x * 198491317 + pos.y * 6542989) % 1000000
	var noise1 := float(hash1) / 1000000.0

	var hash2 := (pos.x * 73856093 + pos.y * 19349663) % 1000000
	var noise2 := float(hash2) / 1000000.0

	return noise1 * 0.7 + noise2 * 0.3


## Thread-safe block hardness calculation
## Uses DataRegistry which is initialized before threading starts
func _get_block_hardness_thread(grid_pos: Vector2i, depth: int) -> float:
	if depth < 0:
		depth = 0

	var layer = DataRegistry.get_layer_at_depth(depth)
	if layer == null:
		return 10.0

	return layer.get_hardness_at(grid_pos)


## Thread-safe block color calculation
func _get_block_color_thread(grid_pos: Vector2i, depth: int, rng: RandomNumberGenerator) -> Color:
	if depth < 0:
		depth = 0

	var layer = DataRegistry.get_layer_at_depth(depth)
	if layer == null:
		return Color.BROWN

	# Check transition zone
	if layer.is_transition_zone(depth):
		var next_layer = DataRegistry.get_layer_at_depth(depth + 15)
		if next_layer != null and next_layer != layer:
			# Use deterministic per-position seed for consistency
			var seed_value := grid_pos.x * 1000 + grid_pos.y
			var temp_rng := RandomNumberGenerator.new()
			temp_rng.seed = seed_value
			if temp_rng.randf() < 0.4:
				return next_layer.get_color_at(grid_pos)

	return layer.get_color_at(grid_pos)


## Thread-safe ore spawning
func _determine_ore_spawn_thread(pos: Vector2i, depth: int, result: ChunkGenerationResult, rng: RandomNumberGenerator) -> void:
	if depth < 0:
		return

	# Skip if already has ore
	if result.ore_map.has(pos):
		return

	var available_ores = DataRegistry.get_ores_at_depth(depth)
	if available_ores.is_empty():
		return

	# Use position-based seed for deterministic spawning
	var seed_value := pos.x * 10000 + pos.y
	var ore_rng := RandomNumberGenerator.new()
	ore_rng.seed = seed_value

	# Sort by spawn_threshold descending (rarest first)
	available_ores.sort_custom(func(a, b): return a.spawn_threshold > b.spawn_threshold)

	for ore in available_ores:
		var noise_val := _generate_ore_noise_thread(pos, ore.noise_frequency)
		if noise_val > ore.spawn_threshold:
			_expand_ore_vein_thread(pos, ore, result, rng)
			return


## Thread-safe ore noise generation
func _generate_ore_noise_thread(pos: Vector2i, frequency: float) -> float:
	var hash_val := (pos.x * 374761393 + pos.y * 668265263) % 1000000
	var freq_adj := int(frequency * 1000)
	hash_val = (hash_val * freq_adj) % 1000000
	return float(hash_val) / 1000000.0


## Thread-safe ore vein expansion
func _expand_ore_vein_thread(seed_pos: Vector2i, ore, result: ChunkGenerationResult, rng: RandomNumberGenerator) -> void:
	var vein_seed := seed_pos.x * 73856093 + seed_pos.y * 19349663
	var vein_rng := RandomNumberGenerator.new()
	vein_rng.seed = vein_seed
	var vein_size: int = ore.get_random_vein_size(vein_rng)

	# Place ore at seed position
	result.ore_map[seed_pos] = ore.id

	if vein_size <= 1:
		return

	var placed_positions: Array[Vector2i] = [seed_pos]
	var placed_count := 1
	var attempts := 0
	var max_attempts := vein_size * 6

	var cardinal_dirs := [
		Vector2i(1, 0), Vector2i(-1, 0),
		Vector2i(0, 1), Vector2i(0, -1),
	]
	var diagonal_dirs := [
		Vector2i(1, 1), Vector2i(-1, 1),
		Vector2i(1, -1), Vector2i(-1, -1),
	]

	var last_dir := Vector2i.ZERO

	while placed_count < vein_size and attempts < max_attempts:
		attempts += 1

		var expand_from: Vector2i
		if vein_rng.randf() < 0.7 and placed_positions.size() > 1:
			var recent_idx := placed_positions.size() - 1 - (vein_rng.randi() % mini(3, placed_positions.size()))
			expand_from = placed_positions[recent_idx]
		else:
			expand_from = placed_positions[vein_rng.randi() % placed_positions.size()]

		var dir: Vector2i
		if last_dir != Vector2i.ZERO and vein_rng.randf() < 0.4:
			dir = last_dir
		elif vein_rng.randf() < 0.15:
			dir = diagonal_dirs[vein_rng.randi() % 4]
		else:
			dir = cardinal_dirs[vein_rng.randi() % 4]

		var next_pos := expand_from + dir
		var next_depth := next_pos.y - _surface_row

		if next_depth < 0:
			continue
		if not ore.can_spawn_at_depth(next_depth):
			continue
		if result.ore_map.has(next_pos):
			continue

		result.ore_map[next_pos] = ore.id
		placed_positions.append(next_pos)
		placed_count += 1
		last_dir = dir


## Thread-safe near-ore marking
func _mark_adjacent_near_ore_thread(ore_pos: Vector2i, result: ChunkGenerationResult) -> void:
	var adjacent_dirs := [
		Vector2i(1, 0), Vector2i(-1, 0),
		Vector2i(0, 1), Vector2i(0, -1),
		Vector2i(1, 1), Vector2i(-1, 1),
		Vector2i(1, -1), Vector2i(-1, -1),
	]

	for dir in adjacent_dirs:
		var adj_pos: Vector2i = ore_pos + dir

		if result.ore_map.has(adj_pos):
			continue
		if result.near_ore_blocks.has(adj_pos):
			continue

		result.near_ore_blocks[adj_pos] = true
