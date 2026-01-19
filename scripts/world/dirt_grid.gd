extends Node2D
## Manages the infinite dirt grid with object pooling.
## Generates rows ahead of the player and cleans up rows behind.
## Handles ore spawning and mining drops.

const DirtBlockScript = preload("res://scripts/world/dirt_block.gd")

const BLOCK_SIZE := 128
const POOL_SIZE := 100  # Fewer blocks needed with larger size
const ROWS_AHEAD := 10
const ROWS_BEHIND := 5

## Emitted when a block drops ore/items. item_id is empty string for dirt-only blocks.
signal block_dropped(grid_pos: Vector2i, item_id: String)

var _pool: Array = []  # Array of DirtBlock nodes
var _active: Dictionary = {}  # Dictionary[Vector2i, DirtBlock node]
var _ore_map: Dictionary = {}  # Dictionary[Vector2i, String ore_id] - what ore is in each block
var _lowest_generated_row: int = 0
var _player: Node2D = null
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_preallocate_pool()


func initialize(player: Node2D, surface_row: int) -> void:
	_player = player
	_lowest_generated_row = surface_row
	# Generate initial rows (surface + some below)
	for row in range(surface_row, surface_row + ROWS_AHEAD):
		_generate_row(row)


func _process(_delta: float) -> void:
	if _player == null:
		return

	var player_row := int(_player.position.y / BLOCK_SIZE)
	_generate_rows_below(player_row + ROWS_AHEAD)
	_cleanup_rows_above(player_row - ROWS_BEHIND)


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


func _generate_rows_below(target_row: int) -> void:
	while _lowest_generated_row <= target_row:
		_generate_row(_lowest_generated_row)
		_lowest_generated_row += 1


func _generate_row(row: int) -> void:
	for col in range(GameManager.GRID_WIDTH):
		var pos := Vector2i(col, row)
		if not _active.has(pos):
			_acquire(pos)
			_determine_ore_spawn(pos)


func _cleanup_rows_above(min_row: int) -> void:
	var to_remove: Array[Vector2i] = []
	for pos: Vector2i in _active.keys():
		if pos.y < min_row:
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
		damage = PlayerData.get_tool_damage()

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
