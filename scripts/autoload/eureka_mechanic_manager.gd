extends Node
## EurekaMechanicManager - Handles depth-specific eureka mechanics.
##
## Based on The Witness, Bonfire Peaks, and puzzle game research:
## Each depth layer introduces a subtle mechanic twist that creates 'aha' moments.
## Players feel smart when they discover something new that changes how they play.
##
## Eureka Mechanics by Layer:
## - Topsoil: Basic dig (always active, introduces core mechanic)
## - Clay: Ore shimmer hints (subtle visual cues near ore)
## - Subsoil: Crumbling blocks (blocks fall after delay when support removed)
## - Stone: Cave sense (subtle audio hints when near hidden caves)
## - Granite: Pressure cracks (chain-breaking blocks along crack lines)
## - Crystal Caves: Crystal resonance (hitting crystal weakens adjacent crystals)
## - Deep Stone: Loose blocks (gravity-affected blocks that fall)
## - Magma Zone: Heat weaken (repeated heat exposure weakens blocks)
## - Obsidian Core: Void sight (briefly see rare ores through walls)
## - Void Depths: Reality tears (chance for jackpot ore clusters)

signal eureka_discovered(layer_id: String, mechanic: String, mechanic_name: String)
signal crumbling_block_started(grid_pos: Vector2i, delay: float)
signal crumbling_block_fell(grid_pos: Vector2i)
signal pressure_crack_triggered(grid_pos: Vector2i, affected_positions: Array)
signal crystal_resonance_triggered(grid_pos: Vector2i, weakened_positions: Array)
signal loose_block_fell(grid_pos: Vector2i, landed_pos: Vector2i)
signal void_sight_activated(center_pos: Vector2i, revealed_ores: Array)
signal reality_tear_jackpot(grid_pos: Vector2i, ore_id: String, multiplier: float)

## Discovered eureka mechanics (layer_id -> bool)
## Once discovered, we don't show the tutorial hint again
var _discovered_mechanics: Dictionary = {}

## Active crumbling blocks (grid_pos -> {timer, delay})
var _crumbling_blocks: Dictionary = {}

## Active loose blocks (grid_pos -> {falling, velocity})
var _loose_blocks: Dictionary = {}

## Void sight timer
var _void_sight_timer: float = 0.0
const VOID_SIGHT_DURATION := 2.0

## RNG for mechanic triggers
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	print("[EurekaMechanicManager] Ready - layer-specific eureka mechanics system")


func _process(delta: float) -> void:
	_process_crumbling_blocks(delta)
	_process_void_sight(delta)


# ============================================
# MECHANIC TRIGGER ENTRY POINT
# ============================================

## Check and trigger eureka mechanic for a block being mined
## Called by DirtGrid when a block is about to be broken
func check_eureka_trigger(grid_pos: Vector2i, layer: Resource) -> void:
	if layer == null or not layer.has_method("has_eureka_mechanic"):
		return

	if not layer.has_eureka_mechanic():
		return

	# Check if this is first discovery of this layer's mechanic
	if not _discovered_mechanics.has(layer.id):
		_discovered_mechanics[layer.id] = true
		eureka_discovered.emit(layer.id, layer.eureka_mechanic, layer.eureka_name)
		print("[EurekaMechanicManager] First discovery of %s mechanic in %s" % [
			layer.eureka_mechanic, layer.display_name
		])

	# Trigger the specific mechanic
	if layer.should_trigger_eureka(_rng):
		_trigger_mechanic(grid_pos, layer)


## Trigger a specific eureka mechanic
func _trigger_mechanic(grid_pos: Vector2i, layer: Resource) -> void:
	match layer.eureka_mechanic:
		"crumbling_blocks":
			_start_crumbling_block(grid_pos, layer.eureka_param_1)
		"pressure_cracks":
			_trigger_pressure_cracks(grid_pos, int(layer.eureka_param_1))
		"crystal_resonance":
			_trigger_crystal_resonance(grid_pos, layer.eureka_param_1)
		"loose_blocks":
			_start_loose_block_fall(grid_pos, layer.eureka_param_1)
		"heat_weaken":
			_apply_heat_weakening(grid_pos, layer.eureka_param_1)
		"void_sight":
			_activate_void_sight(grid_pos, int(layer.eureka_param_1))
		"reality_tears":
			_check_reality_tear(grid_pos, layer.eureka_param_1, layer.eureka_param_2)


# ============================================
# CRUMBLING BLOCKS MECHANIC
# Blocks fall after a delay when support is removed
# ============================================

func _start_crumbling_block(grid_pos: Vector2i, delay: float) -> void:
	# Check blocks above for crumbling candidates
	var above_pos := Vector2i(grid_pos.x, grid_pos.y - 1)

	# Don't start if already crumbling
	if _crumbling_blocks.has(above_pos):
		return

	# Check if the block above exists and should crumble
	if not _block_exists(above_pos):
		return

	# Start crumbling timer
	_crumbling_blocks[above_pos] = {
		"timer": delay,
		"delay": delay,
	}

	crumbling_block_started.emit(above_pos, delay)

	# Play warning sound
	if SoundManager:
		SoundManager.play_ui_sound("warning")


func _process_crumbling_blocks(delta: float) -> void:
	var to_remove: Array[Vector2i] = []

	for pos in _crumbling_blocks:
		var data: Dictionary = _crumbling_blocks[pos]
		data["timer"] -= delta

		if data["timer"] <= 0:
			_crumble_block(pos)
			to_remove.append(pos)

	for pos in to_remove:
		_crumbling_blocks.erase(pos)


func _crumble_block(grid_pos: Vector2i) -> void:
	# Break the block
	if _break_block(grid_pos):
		crumbling_block_fell.emit(grid_pos)

		# Play crumble sound
		if SoundManager:
			SoundManager.play_block_break(20.0, 1, 1.0)

		# Haptic feedback
		if HapticFeedback:
			HapticFeedback.impact_medium()

		# Check if blocks above should also crumble (chain reaction)
		var above_pos := Vector2i(grid_pos.x, grid_pos.y - 1)
		if _block_exists(above_pos) and not _crumbling_blocks.has(above_pos):
			# Shorter delay for chain reaction
			_crumbling_blocks[above_pos] = {
				"timer": 0.3,
				"delay": 0.3,
			}


# ============================================
# PRESSURE CRACKS MECHANIC
# Breaking a block causes nearby blocks along crack lines to weaken/break
# ============================================

func _trigger_pressure_cracks(grid_pos: Vector2i, radius: int) -> void:
	var affected: Array = []

	# Define crack directions (horizontal and vertical lines)
	var directions: Array[Vector2i] = [
		Vector2i(1, 0), Vector2i(-1, 0),  # Horizontal
		Vector2i(0, 1), Vector2i(0, -1),  # Vertical
	]

	for dir: Vector2i in directions:
		for i in range(1, radius + 1):
			var check_pos: Vector2i = grid_pos + dir * i

			# Random chance to continue crack (decreases with distance)
			var continue_chance := 1.0 - (float(i) / float(radius + 1))
			if _rng.randf() > continue_chance:
				break

			if _block_exists(check_pos):
				affected.append(check_pos)
				# Damage the block (weaken but don't always break)
				_damage_block(check_pos, 0.5)

	if not affected.is_empty():
		pressure_crack_triggered.emit(grid_pos, affected)

		# Play crack sound
		if SoundManager:
			SoundManager.play_block_break(30.0, 1, 0.8)


# ============================================
# CRYSTAL RESONANCE MECHANIC
# Hitting a crystal block weakens adjacent crystal blocks
# ============================================

func _trigger_crystal_resonance(grid_pos: Vector2i, weakness_multiplier: float) -> void:
	var weakened: Array = []

	# Check all 8 adjacent blocks
	var directions: Array[Vector2i] = [
		Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
		Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1),
	]

	for dir: Vector2i in directions:
		var adj_pos: Vector2i = grid_pos + dir

		# Check if adjacent block is ore (crystals)
		if _is_ore_block(adj_pos):
			weakened.append(adj_pos)
			# Apply weakness (reduce health)
			_damage_block(adj_pos, weakness_multiplier)

	if not weakened.is_empty():
		crystal_resonance_triggered.emit(grid_pos, weakened)

		# Play resonance sound - subtle UI success for mechanical feedback
		if SoundManager:
			SoundManager.play_sfx(SoundManager.SOUND_UI_SUCCESS, -8.0, 1.3)  # High-pitched subtle chime


# ============================================
# LOOSE BLOCKS MECHANIC
# Some blocks fall due to gravity when unsupported
# ============================================

func _start_loose_block_fall(grid_pos: Vector2i, fall_speed: float) -> void:
	# Check blocks above for loose candidates
	var check_pos := Vector2i(grid_pos.x, grid_pos.y - 1)

	if not _block_exists(check_pos):
		return

	# Already falling
	if _loose_blocks.has(check_pos):
		return

	_loose_blocks[check_pos] = {
		"falling": true,
		"velocity": fall_speed,
		"start_y": check_pos.y,
	}

	# Process immediately in next frame
	# The actual falling is handled by DirtGrid


# ============================================
# HEAT WEAKENING MECHANIC
# Blocks in magma zone get weaker from heat exposure
# ============================================

func _apply_heat_weakening(grid_pos: Vector2i, damage_bonus: float) -> void:
	# Apply extra damage to nearby blocks due to heat
	var directions: Array[Vector2i] = [
		Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	]

	for dir: Vector2i in directions:
		var adj_pos: Vector2i = grid_pos + dir
		if _block_exists(adj_pos):
			# Random chance to weaken
			if _rng.randf() < 0.3:
				_damage_block(adj_pos, damage_bonus)


# ============================================
# VOID SIGHT MECHANIC
# Briefly reveal rare ores through walls
# ============================================

func _activate_void_sight(grid_pos: Vector2i, reveal_radius: int) -> void:
	if _void_sight_timer > 0:
		return  # Already active

	_void_sight_timer = VOID_SIGHT_DURATION

	var revealed_ores: Array = []

	# Scan for ores in radius
	for dx in range(-reveal_radius, reveal_radius + 1):
		for dy in range(-reveal_radius, reveal_radius + 1):
			var check_pos: Vector2i = Vector2i(grid_pos.x + dx, grid_pos.y + dy)

			# Check if this is a rare ore position
			var ore_id := _get_ore_at(check_pos)
			if ore_id != "" and _is_rare_ore(ore_id):
				revealed_ores.append({"pos": check_pos, "ore_id": ore_id})

	if not revealed_ores.is_empty():
		void_sight_activated.emit(grid_pos, revealed_ores)

		# Play mysterious reveal sound - void sight is a discovery
		if SoundManager:
			SoundManager.play_achievement()

		# Haptic
		if HapticFeedback:
			HapticFeedback.impact_light()


func _process_void_sight(delta: float) -> void:
	if _void_sight_timer > 0:
		_void_sight_timer -= delta
		# Void sight effect handled by UI/visual layer


# ============================================
# REALITY TEARS MECHANIC
# Chance for jackpot ore clusters in void depths
# ============================================

func _check_reality_tear(grid_pos: Vector2i, trigger_chance: float, multiplier: float) -> void:
	# Roll for reality tear
	if _rng.randf() > trigger_chance:
		return

	# Get the ore at this position
	var ore_id := _get_ore_at(grid_pos)
	if ore_id == "":
		ore_id = "void_crystal"  # Default to void crystal in void depths

	reality_tear_jackpot.emit(grid_pos, ore_id, multiplier)

	# Spawn bonus ore around the position
	_spawn_jackpot_ore(grid_pos, ore_id, int(multiplier))

	# Major celebration - reality tear jackpot is a major reward
	if SoundManager:
		SoundManager.play_level_up()  # Jackpot deserves level-up sound
	if HapticFeedback:
		HapticFeedback.on_milestone_reached()

	print("[EurekaMechanicManager] Reality tear jackpot! %dx %s" % [int(multiplier), ore_id])


func _spawn_jackpot_ore(grid_pos: Vector2i, ore_id: String, count: int) -> void:
	# This will be handled by the calling system (DirtGrid)
	# Signal already emitted for external handling
	pass


# ============================================
# HELPER METHODS - Interface with other systems
# ============================================

func _block_exists(grid_pos: Vector2i) -> bool:
	# Check with DirtGrid (via GameManager or direct reference)
	var dirt_grid = _get_dirt_grid()
	if dirt_grid != null:
		return dirt_grid.has_block(grid_pos)
	return false


func _break_block(grid_pos: Vector2i) -> bool:
	var dirt_grid = _get_dirt_grid()
	if dirt_grid != null:
		return dirt_grid.hit_block(grid_pos, 9999.0)  # Instant break
	return false


func _damage_block(grid_pos: Vector2i, damage_ratio: float) -> void:
	var dirt_grid = _get_dirt_grid()
	if dirt_grid != null:
		var current_health: float = dirt_grid.get_block_health(grid_pos)
		var damage: float = current_health * damage_ratio
		dirt_grid.hit_block(grid_pos, damage)


func _is_ore_block(grid_pos: Vector2i) -> bool:
	var dirt_grid = _get_dirt_grid()
	if dirt_grid != null:
		return dirt_grid.get_ore_at(grid_pos) != ""
	return false


func _get_ore_at(grid_pos: Vector2i) -> String:
	var dirt_grid = _get_dirt_grid()
	if dirt_grid != null:
		return dirt_grid.get_ore_at(grid_pos)
	return ""


func _is_rare_ore(ore_id: String) -> bool:
	if not DataRegistry:
		return false
	var ore = DataRegistry.get_ore(ore_id)
	if ore == null:
		return false
	# Check rarity - rare, epic, legendary are considered rare
	var rarity: String = ore.rarity if "rarity" in ore else "common"
	return rarity in ["rare", "epic", "legendary"]


func _get_dirt_grid() -> Node:
	# Find DirtGrid in the scene tree
	var main = get_tree().current_scene
	if main != null:
		return main.find_child("DirtGrid", true, false)
	return null


# ============================================
# CHECK MECHANICS ON BLOCK BREAK
# Called when any block is broken to check for eureka triggers
# ============================================

## Called by DirtGrid when a block is destroyed
func on_block_destroyed(grid_pos: Vector2i, depth: int) -> void:
	# Get the layer at this depth
	if not DataRegistry:
		return

	var layer = DataRegistry.get_layer_at_depth(depth)
	if layer == null:
		return

	# Check for eureka mechanic trigger
	check_eureka_trigger(grid_pos, layer)


# ============================================
# PERSISTENCE
# ============================================

## Get save data
func get_save_data() -> Dictionary:
	return {
		"discovered_mechanics": _discovered_mechanics.duplicate(),
	}


## Load save data
func load_save_data(data: Dictionary) -> void:
	_discovered_mechanics.clear()

	var discovered = data.get("discovered_mechanics", {})
	for key in discovered:
		_discovered_mechanics[key] = discovered[key]

	print("[EurekaMechanicManager] Loaded %d discovered mechanics" % _discovered_mechanics.size())


## Reset for new game
func reset() -> void:
	_discovered_mechanics.clear()
	_crumbling_blocks.clear()
	_loose_blocks.clear()
	_void_sight_timer = 0.0
	print("[EurekaMechanicManager] Reset for new game")


# ============================================
# STATISTICS
# ============================================

## Get statistics for debugging
func get_stats() -> Dictionary:
	return {
		"discovered_count": _discovered_mechanics.size(),
		"active_crumbling": _crumbling_blocks.size(),
		"active_loose": _loose_blocks.size(),
		"void_sight_active": _void_sight_timer > 0,
	}


## Check if a mechanic has been discovered
func has_discovered_mechanic(layer_id: String) -> bool:
	return _discovered_mechanics.has(layer_id)


## Get all discovered mechanics
func get_discovered_mechanics() -> Array:
	return _discovered_mechanics.keys()
