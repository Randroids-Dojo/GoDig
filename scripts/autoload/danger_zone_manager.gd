extends Node
## DangerZoneManager - Manages optional high-risk high-reward danger zones.
##
## Inspired by Dead Cells' Cursed Biomes: Players can always choose a safe path,
## but can opt into danger zones for better rewards.
##
## Danger Zone Types:
## - Collapsed Mine: Cracked walls, falling blocks. +50% ore density.
## - Lava Pocket: Red glow, heat damage over time. Fire gems (unique).
## - Flooded Section: Reduced visibility. Water crystals (unique).
## - Gas Pocket: Poison tick damage. Fossil artifacts (unique).

const ChunkTemplateScript = preload("res://resources/chunks/chunk_template.gd")

signal danger_zone_entered(zone_type: String, grid_pos: Vector2i)
signal danger_zone_exited(zone_type: String)
signal danger_zone_warning(zone_type: String, grid_pos: Vector2i)
signal unique_drop_obtained(item_id: String, zone_type: String)

## Danger zone types with their properties
enum ZoneType {
	NONE,
	COLLAPSED_MINE,
	LAVA_POCKET,
	FLOODED_SECTION,
	GAS_POCKET,
}

## Zone spawn configuration
const ZONE_MIN_DEPTH := 30  # Minimum layer depth for danger zones
const ZONE_SPAWN_CHANCE_BASE := 0.10  # 10% base chance per chunk at min depth
const ZONE_SPAWN_CHANCE_MAX := 0.18  # 18% max chance at deep levels
const ZONE_DEPTH_BONUS := 0.0002  # +0.02% per meter of depth

## Ore density multipliers for danger zones
const ORE_DENSITY_MULTIPLIER := 1.5  # 50% more ore in danger zones

## Zone hazard configuration
const HAZARD_CONFIG := {
	ZoneType.COLLAPSED_MINE: {
		"name": "Collapsed Mine",
		"description": "Unstable area with falling debris",
		"damage_type": "impact",
		"damage_per_tick": 0.0,  # Damage from falling blocks instead
		"falling_block_chance": 0.15,  # Per movement
		"ore_multiplier": 1.5,
		"visual_color": Color(0.6, 0.5, 0.4),  # Dusty brown
		"unique_drops": ["ancient_ore"],
	},
	ZoneType.LAVA_POCKET: {
		"name": "Lava Pocket",
		"description": "Extreme heat zone - move quickly!",
		"damage_type": "heat",
		"damage_per_tick": 3.0,  # Per second
		"tick_interval": 1.0,
		"ore_multiplier": 1.8,
		"visual_color": Color(1.0, 0.3, 0.1),  # Lava orange
		"unique_drops": ["fire_gem", "molten_core"],
	},
	ZoneType.FLOODED_SECTION: {
		"name": "Flooded Section",
		"description": "Water-filled tunnels with poor visibility",
		"damage_type": "drowning",
		"damage_per_tick": 1.0,  # Slow damage
		"tick_interval": 2.0,
		"ore_multiplier": 1.4,
		"visual_color": Color(0.2, 0.4, 0.8),  # Deep blue
		"unique_drops": ["water_crystal", "aquamarine"],
	},
	ZoneType.GAS_POCKET: {
		"name": "Gas Pocket",
		"description": "Toxic fumes - don't linger!",
		"damage_type": "poison",
		"damage_per_tick": 2.0,
		"tick_interval": 1.5,
		"ore_multiplier": 1.6,
		"visual_color": Color(0.3, 0.7, 0.2),  # Toxic green
		"unique_drops": ["fossil_amber", "petrified_bone"],
	},
}

## Active danger zones: Dictionary[Vector2i chunk_pos, ZoneData]
var _active_zones: Dictionary = {}

## Zone boundaries for fast lookup: Dictionary[Vector2i grid_pos, Vector2i chunk_pos]
var _zone_tiles: Dictionary = {}

## Player's current zone (if any)
var _current_zone_chunk: Vector2i = Vector2i(-9999, -9999)
var _current_zone_type: ZoneType = ZoneType.NONE

## Hazard damage accumulator
var _hazard_damage_timer: float = 0.0

## Warning state (tracks if player is near a zone entrance)
var _warning_active: bool = false

## RNG for deterministic zone generation
var _rng := RandomNumberGenerator.new()


## Zone data structure
class ZoneData:
	var zone_type: ZoneType = ZoneType.NONE
	var chunk_pos: Vector2i = Vector2i.ZERO
	var tiles: Array[Vector2i] = []  # Grid positions in this zone
	var entry_points: Array[Vector2i] = []  # Warning positions before entry
	var ore_positions: Array[Vector2i] = []  # Enhanced ore spawn positions
	var center: Vector2i = Vector2i.ZERO


func _ready() -> void:
	print("[DangerZoneManager] Ready")


func _process(delta: float) -> void:
	# Process hazard damage if player is in a zone
	if _current_zone_type != ZoneType.NONE:
		_process_hazard_damage(delta)


## Check if a chunk should have a danger zone and generate it
## Called by DirtGrid during chunk generation
func check_danger_zone_placement(chunk_pos: Vector2i, depth: int, world_seed: int) -> Dictionary:
	var result := {
		"has_zone": false,
		"zone_type": ZoneType.NONE,
		"tiles": {},  # Dictionary[Vector2i, String tile_char]
	}

	# Skip if below minimum depth
	if depth < ZONE_MIN_DEPTH:
		return result

	# Skip if zone already exists here
	if _active_zones.has(chunk_pos):
		return result

	# Deterministic RNG for this chunk
	_rng.seed = world_seed + chunk_pos.x * 7919 + chunk_pos.y * 7927 + 42069

	# Calculate spawn chance based on depth
	var chance := ZONE_SPAWN_CHANCE_BASE + (depth * ZONE_DEPTH_BONUS)
	chance = minf(chance, ZONE_SPAWN_CHANCE_MAX)

	if _rng.randf() > chance:
		return result

	# Select zone type based on depth and biome
	var zone_type := _select_zone_type(depth)
	if zone_type == ZoneType.NONE:
		return result

	# Generate zone layout
	var zone_data := _generate_zone_layout(chunk_pos, zone_type, depth)
	if zone_data == null:
		return result

	# Store zone
	_active_zones[chunk_pos] = zone_data
	for tile_pos in zone_data.tiles:
		_zone_tiles[tile_pos] = chunk_pos

	# Convert zone tiles to chunk template format
	result["has_zone"] = true
	result["zone_type"] = zone_type
	result["tiles"] = _zone_to_tile_chars(zone_data)

	print("[DangerZoneManager] Generated %s at chunk %s (depth %d)" % [
		HAZARD_CONFIG[zone_type]["name"],
		str(chunk_pos),
		depth
	])

	return result


## Select appropriate zone type based on depth
func _select_zone_type(depth: int) -> ZoneType:
	var weights := {}

	# Collapsed mines available from start
	weights[ZoneType.COLLAPSED_MINE] = 3.0

	# Gas pockets from moderate depth
	if depth >= 50:
		weights[ZoneType.GAS_POCKET] = 2.0

	# Flooded sections from mid depth
	if depth >= 80:
		weights[ZoneType.FLOODED_SECTION] = 2.5

	# Lava pockets only in deep areas
	if depth >= 120:
		weights[ZoneType.LAVA_POCKET] = 1.5

	if weights.is_empty():
		return ZoneType.NONE

	# Weighted random selection
	var total_weight := 0.0
	for w in weights.values():
		total_weight += w

	var roll := _rng.randf() * total_weight
	var cumulative := 0.0

	for zone_type in weights:
		cumulative += weights[zone_type]
		if roll <= cumulative:
			return zone_type

	return ZoneType.COLLAPSED_MINE


## Generate the tile layout for a danger zone
func _generate_zone_layout(chunk_pos: Vector2i, zone_type: ZoneType, _depth: int) -> ZoneData:
	var zone := ZoneData.new()
	zone.zone_type = zone_type
	zone.chunk_pos = chunk_pos

	# Zone size varies by type
	var zone_width: int
	var zone_height: int

	match zone_type:
		ZoneType.COLLAPSED_MINE:
			zone_width = _rng.randi_range(6, 10)
			zone_height = _rng.randi_range(4, 7)
		ZoneType.LAVA_POCKET:
			zone_width = _rng.randi_range(5, 8)
			zone_height = _rng.randi_range(4, 6)
		ZoneType.FLOODED_SECTION:
			zone_width = _rng.randi_range(7, 10)
			zone_height = _rng.randi_range(5, 8)
		ZoneType.GAS_POCKET:
			zone_width = _rng.randi_range(6, 9)
			zone_height = _rng.randi_range(4, 6)
		_:
			return null

	# Calculate position within chunk (ensure it fits)
	const CHUNK_SIZE := 16
	var max_offset_x := CHUNK_SIZE - zone_width - 2
	var max_offset_y := CHUNK_SIZE - zone_height - 2

	if max_offset_x < 1 or max_offset_y < 1:
		return null

	var offset_x := _rng.randi_range(1, maxi(1, max_offset_x))
	var offset_y := _rng.randi_range(1, maxi(1, max_offset_y))

	var start_x := chunk_pos.x * CHUNK_SIZE + offset_x
	var start_y := chunk_pos.y * CHUNK_SIZE + offset_y

	zone.center = Vector2i(start_x + zone_width / 2, start_y + zone_height / 2)

	# Generate tiles for the zone interior
	for local_y in range(zone_height):
		for local_x in range(zone_width):
			var grid_pos := Vector2i(start_x + local_x, start_y + local_y)

			# Border tiles are walls (safe path around)
			var is_border := local_x == 0 or local_x == zone_width - 1 or \
							 local_y == 0 or local_y == zone_height - 1

			if is_border:
				# Entry points on sides (not corners)
				var is_entry := false
				if local_x == 0 and local_y == zone_height / 2:
					is_entry = true
					zone.entry_points.append(Vector2i(start_x - 1, start_y + local_y))
				elif local_x == zone_width - 1 and local_y == zone_height / 2:
					is_entry = true
					zone.entry_points.append(Vector2i(start_x + zone_width, start_y + local_y))

				if is_entry:
					zone.tiles.append(grid_pos)
			else:
				# Interior is the danger zone
				zone.tiles.append(grid_pos)

				# Mark some positions for ore spawns (higher density)
				if _rng.randf() < 0.25:  # 25% of tiles have ore
					zone.ore_positions.append(grid_pos)

	return zone


## Convert zone data to tile characters for chunk generation
func _zone_to_tile_chars(zone_data: ZoneData) -> Dictionary:
	var tiles: Dictionary = {}

	for grid_pos in zone_data.tiles:
		# Interior tiles are empty (cave air with hazard)
		if grid_pos in zone_data.ore_positions:
			tiles[grid_pos] = "O"  # Ore spawn point
		else:
			tiles[grid_pos] = "."  # Empty/air

	# Add entry point markers
	for entry_pos in zone_data.entry_points:
		tiles[entry_pos] = "<"  # Passable entry

	return tiles


## Check if a grid position is inside a danger zone
func is_in_danger_zone(grid_pos: Vector2i) -> bool:
	return _zone_tiles.has(grid_pos)


## Get the zone type at a position
func get_zone_type_at(grid_pos: Vector2i) -> ZoneType:
	if not _zone_tiles.has(grid_pos):
		return ZoneType.NONE

	var chunk_pos: Vector2i = _zone_tiles[grid_pos]
	if not _active_zones.has(chunk_pos):
		return ZoneType.NONE

	return _active_zones[chunk_pos].zone_type


## Get the zone config at a position
func get_zone_config_at(grid_pos: Vector2i) -> Dictionary:
	var zone_type := get_zone_type_at(grid_pos)
	if zone_type == ZoneType.NONE:
		return {}
	return HAZARD_CONFIG.get(zone_type, {})


## Get ore density multiplier for a position
func get_ore_multiplier_at(grid_pos: Vector2i) -> float:
	var config := get_zone_config_at(grid_pos)
	if config.is_empty():
		return 1.0
	return config.get("ore_multiplier", 1.0)


## Get visual tint color for a position (for ambient effects)
func get_zone_color_at(grid_pos: Vector2i) -> Color:
	var config := get_zone_config_at(grid_pos)
	if config.is_empty():
		return Color.WHITE
	return config.get("visual_color", Color.WHITE)


## Check if position is near a zone entry (for warning)
func is_near_zone_entry(grid_pos: Vector2i) -> bool:
	for chunk_pos in _active_zones:
		var zone: ZoneData = _active_zones[chunk_pos]
		for entry_pos in zone.entry_points:
			var distance := Vector2(grid_pos - entry_pos).length()
			if distance <= 2.0:
				return true
	return false


## Get nearest zone entry info for warnings
func get_nearest_zone_info(grid_pos: Vector2i) -> Dictionary:
	var nearest_distance := INF
	var nearest_zone: ZoneData = null

	for chunk_pos in _active_zones:
		var zone: ZoneData = _active_zones[chunk_pos]
		for entry_pos in zone.entry_points:
			var distance := Vector2(grid_pos - entry_pos).length()
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_zone = zone

	if nearest_zone == null or nearest_distance > 3.0:
		return {}

	var config: Dictionary = HAZARD_CONFIG.get(nearest_zone.zone_type, {})
	return {
		"zone_type": nearest_zone.zone_type,
		"name": config.get("name", "Unknown"),
		"description": config.get("description", ""),
		"distance": nearest_distance,
	}


## Called when player moves - update zone tracking
func update_player_position(grid_pos: Vector2i) -> void:
	var was_in_zone := _current_zone_type != ZoneType.NONE
	var new_zone_type := get_zone_type_at(grid_pos)

	# Check for zone entry/exit
	if new_zone_type != _current_zone_type:
		if was_in_zone:
			var old_config: Dictionary = HAZARD_CONFIG.get(_current_zone_type, {})
			danger_zone_exited.emit(old_config.get("name", "Unknown"))
			print("[DangerZoneManager] Exited %s" % old_config.get("name", "Unknown"))

		_current_zone_type = new_zone_type
		_current_zone_chunk = _zone_tiles.get(grid_pos, Vector2i(-9999, -9999))
		_hazard_damage_timer = 0.0

		if new_zone_type != ZoneType.NONE:
			var new_config: Dictionary = HAZARD_CONFIG.get(new_zone_type, {})
			danger_zone_entered.emit(new_config.get("name", "Unknown"), grid_pos)
			print("[DangerZoneManager] Entered %s" % new_config.get("name", "Unknown"))

	# Check for warning (approaching a zone)
	var near_info := get_nearest_zone_info(grid_pos)
	var should_warn := not near_info.is_empty() and _current_zone_type == ZoneType.NONE

	if should_warn and not _warning_active:
		_warning_active = true
		danger_zone_warning.emit(near_info.get("name", ""), grid_pos)
	elif not should_warn and _warning_active:
		_warning_active = false


## Process hazard damage to player
func _process_hazard_damage(delta: float) -> void:
	if _current_zone_type == ZoneType.NONE:
		return

	var config: Dictionary = HAZARD_CONFIG.get(_current_zone_type, {})
	var damage_per_tick: float = config.get("damage_per_tick", 0.0)
	var tick_interval: float = config.get("tick_interval", 1.0)

	if damage_per_tick <= 0:
		return

	_hazard_damage_timer += delta

	if _hazard_damage_timer >= tick_interval:
		_hazard_damage_timer -= tick_interval

		# Apply damage to player
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("take_damage"):
			var damage_source: String = config.get("damage_type", "hazard")
			player.take_damage(int(damage_per_tick), damage_source)


## Roll for unique drop when mining in a zone
## Returns item_id if drop occurs, empty string otherwise
func roll_unique_drop(grid_pos: Vector2i) -> String:
	var config := get_zone_config_at(grid_pos)
	if config.is_empty():
		return ""

	var unique_drops: Array = config.get("unique_drops", [])
	if unique_drops.is_empty():
		return ""

	# 5% chance for unique drop per block mined in zone
	if _rng.randf() < 0.05:
		var item_id: String = unique_drops[_rng.randi() % unique_drops.size()]
		unique_drop_obtained.emit(item_id, config.get("name", "Unknown"))
		print("[DangerZoneManager] Unique drop: %s" % item_id)
		return item_id

	return ""


## Get current zone info for HUD display
func get_current_zone_info() -> Dictionary:
	if _current_zone_type == ZoneType.NONE:
		return {}
	return HAZARD_CONFIG.get(_current_zone_type, {})


## Check if player is currently in any danger zone
func is_player_in_danger_zone() -> bool:
	return _current_zone_type != ZoneType.NONE


## Unload zone data for a chunk
func unload_chunk(chunk_pos: Vector2i) -> void:
	if _active_zones.has(chunk_pos):
		var zone: ZoneData = _active_zones[chunk_pos]
		for tile_pos in zone.tiles:
			_zone_tiles.erase(tile_pos)
		_active_zones.erase(chunk_pos)


## Reset for new game
func reset() -> void:
	_active_zones.clear()
	_zone_tiles.clear()
	_current_zone_type = ZoneType.NONE
	_current_zone_chunk = Vector2i(-9999, -9999)
	_hazard_damage_timer = 0.0
	_warning_active = false
	print("[DangerZoneManager] Reset for new game")


## Get statistics for debugging
func get_stats() -> Dictionary:
	return {
		"active_zones": _active_zones.size(),
		"zone_tiles": _zone_tiles.size(),
		"current_zone": ZoneType.keys()[_current_zone_type] if _current_zone_type != ZoneType.NONE else "None",
	}
