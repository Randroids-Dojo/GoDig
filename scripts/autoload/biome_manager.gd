extends Node
## BiomeManager - Handles underground biome zones.
##
## Biomes add variety to underground areas with different properties,
## ore spawns, hazards, and visual themes. Biomes can overlay the layer system.

signal biome_entered(biome_id: String, biome_name: String)
signal biome_exited(biome_id: String)

## Biome type definitions
const BIOMES := {
	"normal": {
		"name": "Standard Mines",
		"description": "Regular mining conditions.",
		"ore_multiplier": 1.0,
		"hazard_chance": 0.0,
		"color_tint": Color.WHITE,
	},
	"rich_vein": {
		"name": "Rich Vein",
		"description": "Dense ore deposits. Higher ore spawn rates.",
		"ore_multiplier": 2.0,
		"hazard_chance": 0.0,
		"color_tint": Color(1.0, 1.0, 0.8),  # Slight gold tint
	},
	"crystal_cave": {
		"name": "Crystal Cave",
		"description": "Glittering crystals line the walls. Gems are more common.",
		"ore_multiplier": 0.5,
		"gem_multiplier": 3.0,
		"hazard_chance": 0.0,
		"color_tint": Color(0.9, 0.9, 1.1),  # Slight blue tint
		"light_bonus": 0.1,
	},
	"lava_pocket": {
		"name": "Lava Pocket",
		"description": "Dangerous heat emanates from nearby magma.",
		"ore_multiplier": 1.5,
		"hazard_chance": 0.1,
		"hazard_type": "heat",
		"damage_per_second": 2.0,
		"color_tint": Color(1.1, 0.9, 0.8),  # Orange tint
	},
	"frozen_cavern": {
		"name": "Frozen Cavern",
		"description": "Ice-cold temperatures slow movement but preserve rare minerals.",
		"ore_multiplier": 1.2,
		"hazard_chance": 0.0,
		"movement_multiplier": 0.8,
		"color_tint": Color(0.85, 0.95, 1.1),  # Blue-white tint
	},
	"mushroom_grotto": {
		"name": "Mushroom Grotto",
		"description": "Bioluminescent fungi provide natural light.",
		"ore_multiplier": 0.8,
		"hazard_chance": 0.0,
		"color_tint": Color(0.9, 1.0, 0.85),  # Green tint
		"light_bonus": 0.2,
	},
	"ancient_ruins": {
		"name": "Ancient Ruins",
		"description": "Remnants of a forgotten civilization. Artifacts are more common.",
		"ore_multiplier": 0.7,
		"artifact_multiplier": 5.0,
		"hazard_chance": 0.05,
		"hazard_type": "trap",
		"color_tint": Color(1.0, 0.95, 0.85),  # Sepia tint
	},
	"toxic_marsh": {
		"name": "Toxic Marsh",
		"description": "Poisonous gases seep from the ground. Move quickly!",
		"ore_multiplier": 1.0,
		"hazard_chance": 0.15,
		"hazard_type": "poison",
		"damage_per_second": 1.0,
		"color_tint": Color(0.85, 1.0, 0.75),  # Sickly green
	},
	"void_rift": {
		"name": "Void Rift",
		"description": "Reality warps in this unstable area. Rare materials appear.",
		"ore_multiplier": 0.5,
		"void_crystal_multiplier": 5.0,
		"hazard_chance": 0.2,
		"hazard_type": "instability",
		"color_tint": Color(0.8, 0.7, 1.0),  # Purple tint
	},
}

## Biome spawn chances by depth range
const BIOME_SPAWN_TABLE := [
	{"min_depth": 0, "max_depth": 100, "biomes": {"normal": 1.0}},
	{"min_depth": 100, "max_depth": 300, "biomes": {"normal": 0.7, "rich_vein": 0.2, "mushroom_grotto": 0.1}},
	{"min_depth": 300, "max_depth": 500, "biomes": {"normal": 0.5, "rich_vein": 0.2, "crystal_cave": 0.2, "ancient_ruins": 0.1}},
	{"min_depth": 500, "max_depth": 800, "biomes": {"normal": 0.4, "lava_pocket": 0.2, "frozen_cavern": 0.2, "toxic_marsh": 0.1, "ancient_ruins": 0.1}},
	{"min_depth": 800, "max_depth": 1200, "biomes": {"normal": 0.3, "lava_pocket": 0.3, "crystal_cave": 0.2, "void_rift": 0.1, "toxic_marsh": 0.1}},
	{"min_depth": 1200, "max_depth": 99999, "biomes": {"normal": 0.2, "lava_pocket": 0.2, "void_rift": 0.4, "crystal_cave": 0.2}},
]

## Current biome the player is in
var current_biome: String = "normal"

## Cached biome data for current position
var current_biome_data: Dictionary = {}

## Biome zones in the world (chunk_coord -> biome_id)
var _biome_map: Dictionary = {}

## RNG for biome generation
var _biome_rng := RandomNumberGenerator.new()


func _ready() -> void:
	current_biome_data = BIOMES["normal"].duplicate()
	print("[BiomeManager] Ready with %d biomes" % BIOMES.size())


## Generate biome for a chunk based on its position
func get_biome_for_chunk(chunk_coord: Vector2i, world_seed: int) -> String:
	if _biome_map.has(chunk_coord):
		return _biome_map[chunk_coord]

	# Use chunk position and world seed for deterministic generation
	_biome_rng.seed = world_seed + chunk_coord.x * 10000 + chunk_coord.y

	# Determine depth (chunk Y * chunk size)
	var depth := chunk_coord.y * 16  # Assuming 16-block chunks

	# Find appropriate spawn table entry
	var spawn_entry: Dictionary = {}
	for entry in BIOME_SPAWN_TABLE:
		if depth >= entry["min_depth"] and depth < entry["max_depth"]:
			spawn_entry = entry
			break

	if spawn_entry.is_empty():
		spawn_entry = BIOME_SPAWN_TABLE[-1]  # Use deepest entry

	# Roll for biome
	var roll := _biome_rng.randf()
	var cumulative := 0.0
	var selected_biome := "normal"

	for biome_id in spawn_entry["biomes"]:
		cumulative += spawn_entry["biomes"][biome_id]
		if roll <= cumulative:
			selected_biome = biome_id
			break

	_biome_map[chunk_coord] = selected_biome
	return selected_biome


## Update current biome based on player position
func update_player_biome(grid_pos: Vector2i, world_seed: int) -> void:
	var chunk_coord := Vector2i(grid_pos.x / 16, grid_pos.y / 16)
	var new_biome := get_biome_for_chunk(chunk_coord, world_seed)

	if new_biome != current_biome:
		var old_biome := current_biome
		current_biome = new_biome
		current_biome_data = BIOMES[new_biome].duplicate()

		if old_biome != "":
			biome_exited.emit(old_biome)

		biome_entered.emit(new_biome, current_biome_data["name"])
		print("[BiomeManager] Entered biome: %s" % current_biome_data["name"])


## Get current biome ID
func get_current_biome() -> String:
	return current_biome


## Get current biome data
func get_current_biome_data() -> Dictionary:
	return current_biome_data


## Get biome data by ID
func get_biome_data(biome_id: String) -> Dictionary:
	if BIOMES.has(biome_id):
		return BIOMES[biome_id].duplicate()
	return BIOMES["normal"].duplicate()


## Get ore spawn multiplier for current biome
func get_ore_multiplier() -> float:
	return current_biome_data.get("ore_multiplier", 1.0)


## Get gem spawn multiplier for current biome
func get_gem_multiplier() -> float:
	return current_biome_data.get("gem_multiplier", 1.0)


## Get artifact spawn multiplier for current biome
func get_artifact_multiplier() -> float:
	return current_biome_data.get("artifact_multiplier", 1.0)


## Get void crystal multiplier for current biome
func get_void_crystal_multiplier() -> float:
	return current_biome_data.get("void_crystal_multiplier", 1.0)


## Get movement speed multiplier for current biome
func get_movement_multiplier() -> float:
	return current_biome_data.get("movement_multiplier", 1.0)


## Get light bonus for current biome
func get_light_bonus() -> float:
	return current_biome_data.get("light_bonus", 0.0)


## Get color tint for current biome
func get_color_tint() -> Color:
	return current_biome_data.get("color_tint", Color.WHITE)


## Check if current biome has a hazard
func has_hazard() -> bool:
	return current_biome_data.get("hazard_chance", 0.0) > 0.0


## Get hazard type for current biome
func get_hazard_type() -> String:
	return current_biome_data.get("hazard_type", "")


## Get damage per second for hazardous biomes
func get_hazard_damage() -> float:
	return current_biome_data.get("damage_per_second", 0.0)


## Check if hazard triggers (random roll)
func check_hazard_trigger() -> bool:
	if not has_hazard():
		return false
	return randf() < current_biome_data.get("hazard_chance", 0.0)


## Clear biome map (for new game or chunk reset)
func clear_biome_map() -> void:
	_biome_map.clear()


## Reset for new game
func reset() -> void:
	current_biome = "normal"
	current_biome_data = BIOMES["normal"].duplicate()
	clear_biome_map()


## Get all available biome IDs
func get_all_biome_ids() -> Array:
	return BIOMES.keys()


## Get biome name by ID
func get_biome_name(biome_id: String) -> String:
	if BIOMES.has(biome_id):
		return BIOMES[biome_id]["name"]
	return "Unknown"
