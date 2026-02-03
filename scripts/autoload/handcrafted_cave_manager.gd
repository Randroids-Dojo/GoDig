extends Node
## HandcraftedCaveManager - Generates handcrafted cave formations.
##
## Based on Spelunky's procedural generation approach:
## - Pre-designed room templates with defined entry/exit points
## - Templates are procedurally placed to create interesting formations
## - Guarantees playability while maintaining variety
##
## This manager works alongside the existing cave noise system,
## occasionally replacing random caves with handcrafted designs.

const ChunkTemplateScript = preload("res://resources/chunks/chunk_template.gd")
const ChunkLibraryScript = preload("res://scripts/world/chunk_library.gd")

signal handcrafted_cave_placed(chunk_pos: Vector2i, template_id: String)
signal treasure_room_placed(grid_pos: Vector2i, template_id: String)
signal special_tile_generated(grid_pos: Vector2i, tile_type: String)

## Chance for a chunk to contain a handcrafted cave instead of noise-based
const HANDCRAFTED_CHANCE_BASE := 0.08  # 8% base chance

## Chance increases with depth
const HANDCRAFTED_DEPTH_BONUS := 0.0001  # +0.01% per meter

## Maximum handcrafted chance
const HANDCRAFTED_MAX_CHANCE := 0.25  # 25% max

## Minimum blocks between handcrafted caves
const MIN_HANDCRAFTED_DISTANCE := 64

## Chunk size (must match DirtGrid)
const CHUNK_SIZE := 16

## Library of handcrafted templates
var _library: ChunkLibraryScript = null

## Active handcrafted caves (chunk_pos -> template data)
var _active_caves: Dictionary = {}

## Placed handcrafted positions for distance checking
var _placed_positions: Array[Vector2i] = []

## RNG for placement decisions
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	# Create library instance
	_library = ChunkLibraryScript.new()
	_library.name = "ChunkLibrary"
	add_child(_library)

	print("[HandcraftedCaveManager] Ready with %d templates" % _library.get_stats()["total_templates"])


## Check if a chunk should have a handcrafted cave
## Returns: {"should_place": bool, "template": ChunkTemplate or null, "offset": Vector2i}
func check_handcrafted_placement(chunk_pos: Vector2i, depth: int, world_seed: int) -> Dictionary:
	var result := {
		"should_place": false,
		"template": null,
		"offset": Vector2i.ZERO,
	}

	# Skip above minimum depth
	if depth < 20:
		return result

	# Check distance from existing handcrafted caves
	var chunk_center := Vector2i(chunk_pos.x * CHUNK_SIZE + CHUNK_SIZE / 2, chunk_pos.y * CHUNK_SIZE + CHUNK_SIZE / 2)
	for placed_pos in _placed_positions:
		var distance := Vector2(chunk_center - placed_pos).length()
		if distance < MIN_HANDCRAFTED_DISTANCE:
			return result

	# Deterministic RNG for this chunk
	_rng.seed = world_seed + chunk_pos.x * 541 + chunk_pos.y * 877

	# Calculate placement chance
	var chance := HANDCRAFTED_CHANCE_BASE + (depth * HANDCRAFTED_DEPTH_BONUS)
	chance = minf(chance, HANDCRAFTED_MAX_CHANCE)

	if _rng.randf() > chance:
		return result

	# Select a template type based on depth and randomness
	var template_type := _select_template_type(depth)
	var template: ChunkTemplateScript = _library.select_random_template(template_type, depth, _rng)

	if template == null:
		return result

	# Calculate offset within chunk (ensure template fits)
	var max_offset_x := CHUNK_SIZE - template.width
	var max_offset_y := CHUNK_SIZE - template.height
	var offset := Vector2i(
		_rng.randi() % maxi(1, max_offset_x),
		_rng.randi() % maxi(1, max_offset_y)
	)

	result["should_place"] = true
	result["template"] = template
	result["offset"] = offset

	return result


## Select template type based on depth and weighted randomness
func _select_template_type(depth: int) -> String:
	var weights := {
		"chamber": 3.0,
		"tunnel": 2.5,
		"shaft": 1.5,
		"rest": 1.0,
		"ore_pocket": 1.5,
	}

	# Add treasure rooms deeper
	if depth >= 50:
		weights["treasure"] = 0.3

	# Add hazards in mid-depths
	if depth >= 80:
		weights["hazard"] = 0.8

	# Calculate total weight
	var total_weight := 0.0
	for weight in weights.values():
		total_weight += weight

	# Weighted selection
	var roll := _rng.randf() * total_weight
	var cumulative := 0.0

	for template_type in weights:
		cumulative += weights[template_type]
		if roll <= cumulative:
			return template_type

	return "chamber"  # Fallback


## Generate cave tiles from a template at a position
## Returns: Dictionary[Vector2i, String] mapping positions to tile types
func generate_cave_from_template(
	template: ChunkTemplateScript,
	chunk_pos: Vector2i,
	offset: Vector2i,
	world_seed: int
) -> Dictionary:
	var tiles: Dictionary = {}
	var start_x := chunk_pos.x * CHUNK_SIZE + offset.x
	var start_y := chunk_pos.y * CHUNK_SIZE + offset.y

	# Track this placement
	var center := Vector2i(start_x + template.width / 2, start_y + template.height / 2)
	_placed_positions.append(center)

	# Store active cave data
	_active_caves[chunk_pos] = {
		"template_id": template.id,
		"offset": offset,
		"center": center,
	}

	# Parse template pattern
	for local_y in range(template.height):
		for local_x in range(template.width):
			var grid_pos := Vector2i(start_x + local_x, start_y + local_y)
			var tile_char := template.get_tile_at(local_x, local_y)

			tiles[grid_pos] = tile_char

			# Emit signals for special tiles
			match tile_char:
				"T":
					special_tile_generated.emit(grid_pos, "treasure")
				"O":
					special_tile_generated.emit(grid_pos, "ore")
				"L":
					special_tile_generated.emit(grid_pos, "ladder")
				"E":
					special_tile_generated.emit(grid_pos, "enemy")
				"S":
					special_tile_generated.emit(grid_pos, "secret")
				"W":
					special_tile_generated.emit(grid_pos, "weak")
				"P":
					special_tile_generated.emit(grid_pos, "platform")

	handcrafted_cave_placed.emit(chunk_pos, template.id)
	print("[HandcraftedCaveManager] Placed '%s' at chunk %s" % [template.display_name, str(chunk_pos)])

	return tiles


## Check if a position is part of a handcrafted cave
func is_handcrafted_tile(grid_pos: Vector2i) -> bool:
	var chunk_pos := Vector2i(
		int(floor(float(grid_pos.x) / CHUNK_SIZE)),
		int(floor(float(grid_pos.y) / CHUNK_SIZE))
	)

	if not _active_caves.has(chunk_pos):
		return false

	var cave_data: Dictionary = _active_caves[chunk_pos]
	var offset: Vector2i = cave_data["offset"]
	var template: ChunkTemplateScript = _library.get_template(cave_data["template_id"])

	if template == null:
		return false

	var start_x := chunk_pos.x * CHUNK_SIZE + offset.x
	var start_y := chunk_pos.y * CHUNK_SIZE + offset.y
	var local_x := grid_pos.x - start_x
	var local_y := grid_pos.y - start_y

	return local_x >= 0 and local_x < template.width and local_y >= 0 and local_y < template.height


## Get the tile type at a position in a handcrafted cave
func get_handcrafted_tile(grid_pos: Vector2i) -> String:
	var chunk_pos := Vector2i(
		int(floor(float(grid_pos.x) / CHUNK_SIZE)),
		int(floor(float(grid_pos.y) / CHUNK_SIZE))
	)

	if not _active_caves.has(chunk_pos):
		return ""

	var cave_data: Dictionary = _active_caves[chunk_pos]
	var offset: Vector2i = cave_data["offset"]
	var template: ChunkTemplateScript = _library.get_template(cave_data["template_id"])

	if template == null:
		return ""

	var start_x := chunk_pos.x * CHUNK_SIZE + offset.x
	var start_y := chunk_pos.y * CHUNK_SIZE + offset.y
	var local_x := grid_pos.x - start_x
	var local_y := grid_pos.y - start_y

	if local_x >= 0 and local_x < template.width and local_y >= 0 and local_y < template.height:
		return template.get_tile_at(local_x, local_y)

	return ""


## Check if a position should be empty (cave/air) based on handcrafted design
func should_be_empty(grid_pos: Vector2i) -> bool:
	var tile := get_handcrafted_tile(grid_pos)
	if tile == "":
		return false  # Not in a handcrafted cave

	# Empty tiles
	return tile in [".", ">", "<", "^", "v", "O", "T", "L", "E", "P"]


## Check if a position should have a weak/crumbling block
func should_be_weak(grid_pos: Vector2i) -> bool:
	return get_handcrafted_tile(grid_pos) == "W"


## Check if a position should have a secret wall
func should_be_secret(grid_pos: Vector2i) -> bool:
	return get_handcrafted_tile(grid_pos) == "S"


## Check if a position should spawn ore
func should_spawn_ore(grid_pos: Vector2i) -> bool:
	return get_handcrafted_tile(grid_pos) == "O"


## Check if a position should spawn treasure
func should_spawn_treasure(grid_pos: Vector2i) -> bool:
	return get_handcrafted_tile(grid_pos) == "T"


## Check if a position should have a ladder spawn
func should_spawn_ladder(grid_pos: Vector2i) -> bool:
	return get_handcrafted_tile(grid_pos) == "L"


## Check if a position should spawn an enemy
func should_spawn_enemy(grid_pos: Vector2i) -> bool:
	return get_handcrafted_tile(grid_pos) == "E"


## Check if a position is a platform
func is_platform(grid_pos: Vector2i) -> bool:
	return get_handcrafted_tile(grid_pos) == "P"


## Unload handcrafted data for a chunk
func unload_chunk(chunk_pos: Vector2i) -> void:
	if _active_caves.has(chunk_pos):
		var center: Vector2i = _active_caves[chunk_pos].get("center", Vector2i.ZERO)
		_placed_positions.erase(center)
		_active_caves.erase(chunk_pos)


## Reset for new game
func reset() -> void:
	_active_caves.clear()
	_placed_positions.clear()
	print("[HandcraftedCaveManager] Reset for new game")


## Get statistics
func get_stats() -> Dictionary:
	return {
		"active_caves": _active_caves.size(),
		"placed_positions": _placed_positions.size(),
		"library_templates": _library.get_stats()["total_templates"],
	}


# ============================================
# PERSISTENCE (optional - handcrafted caves regenerate deterministically)
# ============================================

## Get save data
func get_save_data() -> Dictionary:
	# Caves regenerate deterministically from seed, so we only need to track
	# special interactions (e.g., looted treasures, triggered secrets)
	return {}


## Load save data
func load_save_data(_data: Dictionary) -> void:
	# Caves regenerate deterministically
	pass
