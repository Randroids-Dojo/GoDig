extends Node
## DepthDiscoveryManager - Generates depth-based surprise discoveries.
##
## Based on Mr. Mine research (Session 26): Each depth layer should introduce
## discoverable surprises - caves, abandoned equipment, rare ore veins.
## Not just harder blocks. Random events like finding a mysterious cave mix up
## routine gameplay and add excitement.
##
## Discovery Types:
## - Mysterious Caves: Hidden caverns with unique environments
## - Abandoned Equipment: Tools and items left by previous miners
## - Rare Ore Veins: Concentrated deposits of valuable minerals
## - Ancient Relics: Story items and lore fragments
## - Unusual Formations: Strange geological features with bonuses
##
## Discovery Mechanics:
## - Discoveries are tied to depth milestones (every 25-50m)
## - RNG-based spawning with depth-appropriate content
## - One-time discoveries per position (persisted in save)
## - Visual and audio feedback to make discoveries feel special

signal discovery_found(discovery_type: String, discovery_name: String, grid_pos: Vector2i)
signal discovery_loot_collected(items: Array)
signal discovery_hint_revealed(direction: String, distance: int)
signal rare_vein_discovered(ore_id: String, vein_size: int, grid_pos: Vector2i)
signal mysterious_cave_entered(cave_type: String, grid_pos: Vector2i)
signal abandoned_equipment_found(item_id: String, grid_pos: Vector2i)

## Discovery type enum
enum DiscoveryType {
	MYSTERIOUS_CAVE,
	ABANDONED_EQUIPMENT,
	RARE_VEIN,
	ANCIENT_RELIC,
	UNUSUAL_FORMATION,
}

## Discovery configuration by depth range
## Each entry defines what discoveries are possible at that depth
const DISCOVERY_TABLES := {
	# Shallow depths (0-50m) - Beginner-friendly discoveries
	"shallow": {
		"min_depth": 0,
		"max_depth": 50,
		"chance_per_chunk": 0.08,  # 8% per chunk
		"discoveries": [
			{
				"type": DiscoveryType.ABANDONED_EQUIPMENT,
				"weight": 3.0,
				"items": ["old_pickaxe", "rusted_lantern", "torn_map", "miner_journal_1"],
				"name": "Abandoned Camp",
				"description": "An old miner's resting spot."
			},
			{
				"type": DiscoveryType.RARE_VEIN,
				"weight": 2.0,
				"ores": ["coal", "copper"],
				"bonus_size": 3,
				"name": "Rich Deposit",
				"description": "A concentrated vein of ore!"
			},
			{
				"type": DiscoveryType.MYSTERIOUS_CAVE,
				"weight": 1.0,
				"cave_type": "starter_cave",
				"name": "Hidden Hollow",
				"description": "A small cave with traces of previous miners."
			},
		]
	},
	# Mid depths (50-150m) - More variety
	"mid_shallow": {
		"min_depth": 50,
		"max_depth": 150,
		"chance_per_chunk": 0.10,  # 10% per chunk
		"discoveries": [
			{
				"type": DiscoveryType.MYSTERIOUS_CAVE,
				"weight": 2.5,
				"cave_type": "crystal_pocket",
				"name": "Crystal Pocket",
				"description": "A small cavity lined with crystals!"
			},
			{
				"type": DiscoveryType.ABANDONED_EQUIPMENT,
				"weight": 2.0,
				"items": ["iron_pickaxe", "oil_lantern", "supply_crate", "miner_journal_2"],
				"name": "Supply Cache",
				"description": "Emergency supplies left behind."
			},
			{
				"type": DiscoveryType.RARE_VEIN,
				"weight": 2.5,
				"ores": ["iron", "copper", "silver"],
				"bonus_size": 4,
				"name": "Mother Lode",
				"description": "A massive ore vein!"
			},
			{
				"type": DiscoveryType.ANCIENT_RELIC,
				"weight": 1.0,
				"items": ["stone_tablet", "ancient_coin", "fossil_fragment"],
				"name": "Ancient Remains",
				"description": "Signs of ancient civilizations."
			},
		]
	},
	# Medium depths (150-300m) - Increasing rewards
	"medium": {
		"min_depth": 150,
		"max_depth": 300,
		"chance_per_chunk": 0.12,  # 12% per chunk
		"discoveries": [
			{
				"type": DiscoveryType.MYSTERIOUS_CAVE,
				"weight": 2.0,
				"cave_type": "glowing_cavern",
				"name": "Glowing Cavern",
				"description": "Bioluminescent fungi illuminate this cave!"
			},
			{
				"type": DiscoveryType.RARE_VEIN,
				"weight": 3.0,
				"ores": ["gold", "silver", "ruby"],
				"bonus_size": 5,
				"name": "Precious Vein",
				"description": "A vein of precious minerals!"
			},
			{
				"type": DiscoveryType.ABANDONED_EQUIPMENT,
				"weight": 1.5,
				"items": ["steel_pickaxe", "compressed_ladder_pack", "emergency_rope", "miner_journal_3"],
				"name": "Lost Expedition",
				"description": "Remnants of an ill-fated expedition."
			},
			{
				"type": DiscoveryType.ANCIENT_RELIC,
				"weight": 1.5,
				"items": ["carved_totem", "runed_stone", "sealed_scroll"],
				"name": "Runed Chamber",
				"description": "Strange symbols cover the walls."
			},
			{
				"type": DiscoveryType.UNUSUAL_FORMATION,
				"weight": 1.0,
				"bonus_type": "ore_magnet",
				"duration": 60,
				"name": "Magnetic Anomaly",
				"description": "Ore seems drawn to this spot!"
			},
		]
	},
	# Deep (300-500m) - Dangerous but rewarding
	"deep": {
		"min_depth": 300,
		"max_depth": 500,
		"chance_per_chunk": 0.15,  # 15% per chunk
		"discoveries": [
			{
				"type": DiscoveryType.MYSTERIOUS_CAVE,
				"weight": 2.5,
				"cave_type": "lava_shrine",
				"name": "Lava Shrine",
				"description": "An ancient place of worship near magma."
			},
			{
				"type": DiscoveryType.RARE_VEIN,
				"weight": 2.5,
				"ores": ["diamond", "emerald", "gold"],
				"bonus_size": 6,
				"name": "Gem Cluster",
				"description": "Precious gems sparkle in the stone!"
			},
			{
				"type": DiscoveryType.ANCIENT_RELIC,
				"weight": 2.0,
				"items": ["golden_idol", "obsidian_mirror", "crystal_skull", "miner_journal_4"],
				"name": "Forgotten Vault",
				"description": "A sealed chamber from ages past."
			},
			{
				"type": DiscoveryType.UNUSUAL_FORMATION,
				"weight": 1.5,
				"bonus_type": "heat_shield",
				"duration": 120,
				"name": "Cool Pocket",
				"description": "A strangely cool area in the heat."
			},
			{
				"type": DiscoveryType.ABANDONED_EQUIPMENT,
				"weight": 1.5,
				"items": ["heat_suit_fragment", "lava_boots", "asbestos_gloves"],
				"name": "Heat Gear Stash",
				"description": "Protective equipment for deep mining."
			},
		]
	},
	# Abyssal (500m+) - Rare and valuable
	"abyssal": {
		"min_depth": 500,
		"max_depth": 99999,
		"chance_per_chunk": 0.18,  # 18% per chunk
		"discoveries": [
			{
				"type": DiscoveryType.MYSTERIOUS_CAVE,
				"weight": 2.0,
				"cave_type": "void_chamber",
				"name": "Void Chamber",
				"description": "Reality seems thin here..."
			},
			{
				"type": DiscoveryType.RARE_VEIN,
				"weight": 2.0,
				"ores": ["void_crystal", "dark_matter", "starfall_ore"],
				"bonus_size": 8,
				"name": "Cosmic Deposit",
				"description": "Materials from beyond this world!"
			},
			{
				"type": DiscoveryType.ANCIENT_RELIC,
				"weight": 2.5,
				"items": ["void_key", "reality_shard", "temporal_compass", "miner_journal_5"],
				"name": "Elder Cache",
				"description": "Artifacts of immense power."
			},
			{
				"type": DiscoveryType.UNUSUAL_FORMATION,
				"weight": 2.0,
				"bonus_type": "void_sight",
				"duration": 180,
				"name": "Void Lens",
				"description": "See through the darkness..."
			},
			{
				"type": DiscoveryType.MYSTERIOUS_CAVE,
				"weight": 1.5,
				"cave_type": "elder_temple",
				"name": "Elder Temple",
				"description": "A monument to forgotten gods."
			},
		]
	},
}

## Chunk size for discovery generation
const CHUNK_SIZE := 16

## Minimum blocks between discoveries
const MIN_DISCOVERY_DISTANCE := 32

## Active discoveries in the world
## Key: Vector2i (chunk_pos), Value: Discovery data
var _active_discoveries: Dictionary = {}

## Collected discoveries (persisted)
## Key: String (position as "x,y"), Value: bool
var _collected_discoveries: Dictionary = {}

## Hint cooldown to prevent spam
var _hint_cooldown: float = 0.0
const HINT_COOLDOWN_TIME := 30.0

## RNG for discovery generation
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	# Connect to depth updates
	if GameManager:
		GameManager.depth_updated.connect(_on_depth_updated)

	print("[DepthDiscoveryManager] Ready with %d depth tiers" % DISCOVERY_TABLES.size())


func _process(delta: float) -> void:
	if _hint_cooldown > 0:
		_hint_cooldown -= delta


## Generate discoveries for a chunk (called during chunk generation)
func generate_discoveries_for_chunk(chunk_pos: Vector2i, world_seed: int) -> void:
	if _active_discoveries.has(chunk_pos):
		return  # Already generated

	# Calculate depth from chunk position
	var depth := chunk_pos.y * CHUNK_SIZE
	if depth < 0:
		return  # Above surface

	# Get appropriate discovery table
	var table := _get_discovery_table(depth)
	if table.is_empty():
		return

	# Deterministic RNG for this chunk
	_rng.seed = world_seed + chunk_pos.x * 98765 + chunk_pos.y * 54321

	# Check if this chunk should have a discovery
	var chance: float = table.get("chance_per_chunk", 0.1)
	if _rng.randf() > chance:
		return

	# Generate discovery
	var discovery := _generate_discovery(table, chunk_pos, depth)
	if discovery.is_empty():
		return

	_active_discoveries[chunk_pos] = discovery
	print("[DepthDiscoveryManager] Generated discovery at chunk %s: %s" % [
		str(chunk_pos),
		discovery.get("name", "Unknown")
	])


## Get the discovery table for a given depth
func _get_discovery_table(depth: int) -> Dictionary:
	for table_id in DISCOVERY_TABLES:
		var table: Dictionary = DISCOVERY_TABLES[table_id]
		if depth >= table["min_depth"] and depth < table["max_depth"]:
			return table
	return {}


## Generate a specific discovery from the table
func _generate_discovery(table: Dictionary, chunk_pos: Vector2i, depth: int) -> Dictionary:
	var discoveries: Array = table.get("discoveries", [])
	if discoveries.is_empty():
		return {}

	# Calculate total weight
	var total_weight := 0.0
	for d in discoveries:
		total_weight += d.get("weight", 1.0)

	# Weighted random selection
	var roll := _rng.randf() * total_weight
	var cumulative := 0.0
	var selected: Dictionary = discoveries[0]

	for d in discoveries:
		cumulative += d.get("weight", 1.0)
		if roll <= cumulative:
			selected = d
			break

	# Generate position within chunk
	var local_x := _rng.randi() % CHUNK_SIZE
	var local_y := _rng.randi() % CHUNK_SIZE
	var grid_pos := Vector2i(
		chunk_pos.x * CHUNK_SIZE + local_x,
		chunk_pos.y * CHUNK_SIZE + local_y
	)

	# Check if already collected
	var pos_key := "%d,%d" % [grid_pos.x, grid_pos.y]
	if _collected_discoveries.has(pos_key):
		return {}  # Already collected

	return {
		"type": selected.get("type", DiscoveryType.MYSTERIOUS_CAVE),
		"name": selected.get("name", "Discovery"),
		"description": selected.get("description", ""),
		"grid_pos": grid_pos,
		"chunk_pos": chunk_pos,
		"depth": depth,
		"data": selected.duplicate(),
		"discovered": false,
	}


## Check for nearby discoveries (called when player moves)
func check_for_discoveries(player_grid_pos: Vector2i) -> void:
	var player_chunk := Vector2i(
		int(floor(float(player_grid_pos.x) / CHUNK_SIZE)),
		int(floor(float(player_grid_pos.y) / CHUNK_SIZE))
	)

	# Check nearby chunks
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			var check_chunk := Vector2i(player_chunk.x + dx, player_chunk.y + dy)
			if not _active_discoveries.has(check_chunk):
				continue

			var discovery: Dictionary = _active_discoveries[check_chunk]
			if discovery.get("discovered", false):
				continue

			var disc_pos: Vector2i = discovery.get("grid_pos", Vector2i.ZERO)
			var distance: int = abs(player_grid_pos.x - disc_pos.x) + abs(player_grid_pos.y - disc_pos.y)

			# Check if player is at the discovery
			if distance <= 1:
				_trigger_discovery(discovery)
			elif distance <= 5 and _hint_cooldown <= 0:
				# Show hint when nearby
				_show_discovery_hint(player_grid_pos, disc_pos)


## Trigger a discovery when player finds it
func _trigger_discovery(discovery: Dictionary) -> void:
	discovery["discovered"] = true

	var discovery_type: int = discovery.get("type", DiscoveryType.MYSTERIOUS_CAVE)
	var name: String = discovery.get("name", "Discovery")
	var grid_pos: Vector2i = discovery.get("grid_pos", Vector2i.ZERO)
	var data: Dictionary = discovery.get("data", {})

	# Mark as collected
	var pos_key := "%d,%d" % [grid_pos.x, grid_pos.y]
	_collected_discoveries[pos_key] = true

	# Emit main signal
	discovery_found.emit(DiscoveryType.keys()[discovery_type], name, grid_pos)

	# Handle discovery-specific logic
	match discovery_type:
		DiscoveryType.MYSTERIOUS_CAVE:
			var cave_type: String = data.get("cave_type", "unknown")
			mysterious_cave_entered.emit(cave_type, grid_pos)
			_apply_cave_effects(cave_type)

		DiscoveryType.ABANDONED_EQUIPMENT:
			var items: Array = data.get("items", [])
			if not items.is_empty():
				var item_id: String = items[_rng.randi() % items.size()]
				abandoned_equipment_found.emit(item_id, grid_pos)
				_give_item_to_player(item_id)

		DiscoveryType.RARE_VEIN:
			var ores: Array = data.get("ores", [])
			var bonus_size: int = data.get("bonus_size", 3)
			if not ores.is_empty():
				var ore_id: String = ores[_rng.randi() % ores.size()]
				rare_vein_discovered.emit(ore_id, bonus_size, grid_pos)
				_spawn_bonus_ore(ore_id, grid_pos, bonus_size)

		DiscoveryType.ANCIENT_RELIC:
			var items: Array = data.get("items", [])
			if not items.is_empty():
				var item_id: String = items[_rng.randi() % items.size()]
				abandoned_equipment_found.emit(item_id, grid_pos)
				_give_item_to_player(item_id)

		DiscoveryType.UNUSUAL_FORMATION:
			var bonus_type: String = data.get("bonus_type", "")
			var duration: int = data.get("duration", 60)
			_apply_formation_bonus(bonus_type, duration)

	# Play discovery sound - depth discoveries are achievements
	if SoundManager:
		SoundManager.play_achievement()  # Discovery-appropriate sound

	# Haptic feedback
	if HapticFeedback:
		HapticFeedback.impact_heavy()

	print("[DepthDiscoveryManager] Discovery triggered: %s at %s" % [name, str(grid_pos)])


## Show a hint that a discovery is nearby
func _show_discovery_hint(player_pos: Vector2i, discovery_pos: Vector2i) -> void:
	_hint_cooldown = HINT_COOLDOWN_TIME

	var dx: int = discovery_pos.x - player_pos.x
	var dy: int = discovery_pos.y - player_pos.y
	var distance: int = abs(dx) + abs(dy)

	# Determine direction
	var direction := ""
	if abs(dx) > abs(dy):
		direction = "east" if dx > 0 else "west"
	else:
		direction = "south" if dy > 0 else "north"

	discovery_hint_revealed.emit(direction, distance)


## Apply effects for entering a mysterious cave
func _apply_cave_effects(cave_type: String) -> void:
	match cave_type:
		"crystal_pocket":
			# Bonus to gem drops for a while
			if MiningBonusManager:
				MiningBonusManager.apply_temporary_bonus("gem_boost", 2.0, 60.0)
		"glowing_cavern":
			# Temporary light bonus
			if LightingManager:
				LightingManager.apply_temporary_boost(0.3, 120.0)
		"lava_shrine":
			# Heat resistance
			pass  # Would apply heat shield effect
		"void_chamber":
			# Reveal nearby ores
			pass  # Would reveal ore locations
		"elder_temple":
			# Major lore discovery
			if AchievementManager:
				AchievementManager.unlock_achievement("elder_temple_found")


## Give an item to the player
func _give_item_to_player(item_id: String) -> void:
	if not InventoryManager or not DataRegistry:
		return

	# Get the item data from registry
	var item: ItemData = DataRegistry.get_item(item_id)
	if item == null:
		push_warning("[DepthDiscoveryManager] Unknown item: %s" % item_id)
		return

	# Try to add to inventory
	if InventoryManager.can_add_item(item_id, 1):
		InventoryManager.add_item(item, 1)
		print("[DepthDiscoveryManager] Gave item to player: %s" % item_id)
	else:
		# Inventory full - notify player
		print("[DepthDiscoveryManager] Could not give item (inventory full): %s" % item_id)


## Spawn bonus ore near the discovery
func _spawn_bonus_ore(ore_id: String, center_pos: Vector2i, count: int) -> void:
	# This would interface with DirtGrid to mark extra ore positions
	# For now, just log it
	print("[DepthDiscoveryManager] Would spawn %d bonus %s ore near %s" % [count, ore_id, str(center_pos)])


## Apply a formation bonus effect
func _apply_formation_bonus(bonus_type: String, duration: int) -> void:
	match bonus_type:
		"ore_magnet":
			# Increase ore spawn rate nearby
			if MiningBonusManager:
				MiningBonusManager.apply_temporary_bonus("ore_rate", 1.5, float(duration))
		"heat_shield":
			# Reduce heat damage
			pass  # Would apply heat resistance
		"void_sight":
			# Reveal hidden areas
			if CaveLayerManager:
				var player_pos := GameManager.get_player_position()
				CaveLayerManager.use_reveal_item("spelunking_goggles", player_pos)


## Called when player depth changes
func _on_depth_updated(depth: int) -> void:
	# Check for discoveries at the player's position
	var player_grid_pos := GameManager.get_player_grid_position()
	check_for_discoveries(player_grid_pos)


## Check if there's a discovery at a specific position
func has_discovery_at(grid_pos: Vector2i) -> bool:
	var chunk_pos := Vector2i(
		int(floor(float(grid_pos.x) / CHUNK_SIZE)),
		int(floor(float(grid_pos.y) / CHUNK_SIZE))
	)

	if not _active_discoveries.has(chunk_pos):
		return false

	var discovery: Dictionary = _active_discoveries[chunk_pos]
	var disc_pos: Vector2i = discovery.get("grid_pos", Vector2i.ZERO)
	return disc_pos == grid_pos


## Get discovery data at a position
func get_discovery_at(grid_pos: Vector2i) -> Dictionary:
	var chunk_pos := Vector2i(
		int(floor(float(grid_pos.x) / CHUNK_SIZE)),
		int(floor(float(grid_pos.y) / CHUNK_SIZE))
	)

	if not _active_discoveries.has(chunk_pos):
		return {}

	var discovery: Dictionary = _active_discoveries[chunk_pos]
	var disc_pos: Vector2i = discovery.get("grid_pos", Vector2i.ZERO)
	if disc_pos == grid_pos:
		return discovery
	return {}


## Get save data for persistence
func get_save_data() -> Dictionary:
	return {
		"collected_discoveries": _collected_discoveries.duplicate(),
	}


## Load save data
func load_save_data(data: Dictionary) -> void:
	_collected_discoveries.clear()

	var collected = data.get("collected_discoveries", {})
	for key in collected:
		_collected_discoveries[key] = collected[key]

	print("[DepthDiscoveryManager] Loaded %d collected discoveries" % _collected_discoveries.size())


## Reset for new game
func reset() -> void:
	_active_discoveries.clear()
	_collected_discoveries.clear()
	_hint_cooldown = 0.0
	print("[DepthDiscoveryManager] Reset for new game")


## Get statistics for debugging
func get_stats() -> Dictionary:
	var discovered_count := 0
	for chunk_pos in _active_discoveries:
		if _active_discoveries[chunk_pos].get("discovered", false):
			discovered_count += 1

	return {
		"active_discoveries": _active_discoveries.size(),
		"discovered_count": discovered_count,
		"collected_total": _collected_discoveries.size(),
		"hint_cooldown": _hint_cooldown,
	}
