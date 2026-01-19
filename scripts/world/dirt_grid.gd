extends Node2D
## Manages the infinite dirt grid with object pooling.
## Generates blocks in a rectangular area around the player.
## Supports infinite horizontal and vertical expansion.
## Handles ore spawning and mining drops.

const DirtBlockScript = preload("res://scripts/world/dirt_block.gd")

const BLOCK_SIZE := 128
const POOL_SIZE := 200  # Increased for horizontal expansion
const ROWS_AHEAD := 10
const ROWS_BEHIND := 5
const COLS_LEFT := 8   # Load 8 columns to the left of player
const COLS_RIGHT := 8  # Load 8 columns to the right of player
const CLEANUP_DISTANCE := 15  # Unload blocks beyond this distance

## Emitted when a block drops ore/items. item_id is empty string for dirt-only blocks.
signal block_dropped(grid_pos: Vector2i, item_id: String)

var _pool: Array = []  # Array of DirtBlock nodes
var _active: Dictionary = {}  # Dictionary[Vector2i, DirtBlock node]
var _ore_map: Dictionary = {}  # Dictionary[Vector2i, String ore_id] - what ore is in each block
var _player: Node2D = null
var _player_grid_pos: Vector2i = Vector2i.ZERO
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_preallocate_pool()


func initialize(player: Node2D, surface_row: int) -> void:
	_player = player
	# Convert player position to grid coordinates
	_player_grid_pos = Vector2i(
		int(_player.position.x / BLOCK_SIZE),
		int(_player.position.y / BLOCK_SIZE)
	)
	# Generate initial area around player
	_generate_blocks_around_player()


func _process(_delta: float) -> void:
	if _player == null:
		return

	# Update player grid position
	var new_grid_pos := Vector2i(
		int(_player.position.x / BLOCK_SIZE),
		int(_player.position.y / BLOCK_SIZE)
	)

	# Only update if player moved to a new grid cell
	if new_grid_pos != _player_grid_pos:
		_player_grid_pos = new_grid_pos
		_generate_blocks_around_player()
		_cleanup_distant_blocks()


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


func _generate_blocks_around_player() -> void:
	## Generate blocks in a rectangular area around the player
	var min_col := _player_grid_pos.x - COLS_LEFT
	var max_col := _player_grid_pos.x + COLS_RIGHT
	var min_row := _player_grid_pos.y - ROWS_BEHIND
	var max_row := _player_grid_pos.y + ROWS_AHEAD

	# Generate all blocks in the rectangle
	for row in range(min_row, max_row + 1):
		# Skip rows above surface
		if row < GameManager.SURFACE_ROW:
			continue

		for col in range(min_col, max_col + 1):
			var pos := Vector2i(col, row)
			if not _active.has(pos):
				_acquire(pos)
				_determine_ore_spawn(pos)


func _cleanup_distant_blocks() -> void:
	## Remove blocks that are too far from the player
	var to_remove: Array[Vector2i] = []

	for pos: Vector2i in _active.keys():
		var distance := (pos - _player_grid_pos).length()
		if distance > CLEANUP_DISTANCE:
			to_remove.append(pos)

	for pos in to_remove:
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
