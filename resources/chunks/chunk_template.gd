class_name ChunkTemplate extends Resource
## ChunkTemplate - Defines a pre-designed cave room pattern.
##
## Based on Spelunky's room assembly system: pre-designed rooms with
## defined entry/exit points that can be procedurally arranged while
## guaranteeing playability and interesting formations.
##
## Templates use a simple grid notation:
## '.' = empty (cave/air)
## '#' = solid (block)
## 'O' = ore spawn point
## 'T' = treasure spawn point
## 'L' = ladder spawn point
## 'E' = enemy spawn point
## 'S' = secret area (hidden behind breakable wall)
## 'W' = weak block (crumbles easily)
## 'P' = platform ledge
## '>' = right exit point
## '<' = left exit point
## '^' = up exit point
## 'v' = down exit point

## Unique identifier for this template
@export var id: String = ""

## Display name for debugging
@export var display_name: String = ""

## Template description
@export_multiline var description: String = ""

## Template type for categorization
@export_enum("chamber", "tunnel", "shaft", "treasure", "rest", "ore_pocket", "hazard", "danger_zone") var template_type: String = "chamber"

## Width of the template in blocks
@export var width: int = 8

## Height of the template in blocks
@export var height: int = 8

## The grid pattern (array of strings, one per row)
## Each string should have 'width' characters
@export var pattern: PackedStringArray = []

## Minimum depth (in blocks below surface) where this template can appear
@export var min_depth: int = 0

## Maximum depth where this template can appear (0 = no limit)
@export var max_depth: int = 0

## Weight for random selection (higher = more common)
@export_range(0.0, 10.0, 0.1) var spawn_weight: float = 1.0

## Ore type hints for 'O' spawn points (empty = use depth-appropriate ore)
@export var ore_hints: PackedStringArray = []

## Treasure tier for 'T' spawn points (0 = use depth-based)
@export var treasure_tier: int = 0

## Whether this template requires specific approach direction
@export var required_approach: String = ""  # "left", "right", "top", "bottom", ""

## Tags for filtering (e.g., "secret", "boss", "rest")
@export var tags: PackedStringArray = []


## Get the character at a grid position in the pattern
func get_tile_at(x: int, y: int) -> String:
	if y < 0 or y >= pattern.size():
		return "#"  # Solid by default
	var row: String = pattern[y]
	if x < 0 or x >= row.length():
		return "#"  # Solid by default
	return row[x]


## Check if position is empty (cave/air)
func is_empty(x: int, y: int) -> bool:
	var tile := get_tile_at(x, y)
	return tile in [".", ">", "<", "^", "v", "O", "T", "L", "E", "P"]


## Check if position is solid (block)
func is_solid(x: int, y: int) -> bool:
	var tile := get_tile_at(x, y)
	return tile in ["#", "W", "S"]


## Check if position is a spawn point
func is_spawn_point(x: int, y: int) -> bool:
	var tile := get_tile_at(x, y)
	return tile in ["O", "T", "L", "E"]


## Get all positions of a specific tile type
func get_positions_of(tile_char: String) -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	for y in range(pattern.size()):
		var row: String = pattern[y]
		for x in range(row.length()):
			if row[x] == tile_char:
				positions.append(Vector2i(x, y))
	return positions


## Get all exit points with their directions
func get_exits() -> Array[Dictionary]:
	var exits: Array[Dictionary] = []

	for y in range(pattern.size()):
		var row: String = pattern[y]
		for x in range(row.length()):
			var tile := row[x]
			match tile:
				">":
					exits.append({"pos": Vector2i(x, y), "direction": "right"})
				"<":
					exits.append({"pos": Vector2i(x, y), "direction": "left"})
				"^":
					exits.append({"pos": Vector2i(x, y), "direction": "up"})
				"v":
					exits.append({"pos": Vector2i(x, y), "direction": "down"})

	return exits


## Check if template can spawn at the given depth
func can_spawn_at_depth(depth: int) -> bool:
	if depth < min_depth:
		return false
	if max_depth > 0 and depth > max_depth:
		return false
	return true


## Check if template has a specific tag
func has_tag(tag: String) -> bool:
	return tags.has(tag)


## Get the ore ID to use at a position (based on ore_hints or depth)
func get_ore_id_for(index: int, depth: int) -> String:
	if index >= 0 and index < ore_hints.size():
		return ore_hints[index]
	# Return empty to use depth-based ore
	return ""


## Validate the pattern (ensure dimensions match and required elements exist)
func validate() -> Dictionary:
	var result := {"valid": true, "errors": []}

	if pattern.is_empty():
		result["valid"] = false
		result["errors"].append("Pattern is empty")
		return result

	if pattern.size() != height:
		result["valid"] = false
		result["errors"].append("Pattern height (%d) doesn't match height property (%d)" % [pattern.size(), height])

	for y in range(pattern.size()):
		var row: String = pattern[y]
		if row.length() != width:
			result["valid"] = false
			result["errors"].append("Row %d width (%d) doesn't match width property (%d)" % [y, row.length(), width])

	# Check for at least one exit
	var exits := get_exits()
	if exits.is_empty():
		result["errors"].append("Warning: No exit points defined")

	return result


## Create a rotated version of this template (90 degrees clockwise)
func rotated_90() -> ChunkTemplate:
	var rotated := ChunkTemplate.new()
	rotated.id = id + "_rot90"
	rotated.display_name = display_name + " (90)"
	rotated.description = description
	rotated.template_type = template_type
	rotated.width = height
	rotated.height = width
	rotated.min_depth = min_depth
	rotated.max_depth = max_depth
	rotated.spawn_weight = spawn_weight
	rotated.ore_hints = ore_hints
	rotated.treasure_tier = treasure_tier
	rotated.tags = tags

	# Rotate the pattern
	var new_pattern: PackedStringArray = []
	for x in range(width):
		var new_row := ""
		for y in range(height - 1, -1, -1):
			var tile := get_tile_at(x, y)
			# Rotate directional tiles
			match tile:
				">": tile = "v"
				"v": tile = "<"
				"<": tile = "^"
				"^": tile = ">"
			new_row += tile
		new_pattern.append(new_row)

	rotated.pattern = new_pattern

	# Rotate required approach
	match required_approach:
		"left": rotated.required_approach = "top"
		"top": rotated.required_approach = "right"
		"right": rotated.required_approach = "bottom"
		"bottom": rotated.required_approach = "left"
		_: rotated.required_approach = ""

	return rotated


## Create a mirrored version of this template (horizontal flip)
func mirrored_horizontal() -> ChunkTemplate:
	var mirrored := ChunkTemplate.new()
	mirrored.id = id + "_flip_h"
	mirrored.display_name = display_name + " (H-Flip)"
	mirrored.description = description
	mirrored.template_type = template_type
	mirrored.width = width
	mirrored.height = height
	mirrored.min_depth = min_depth
	mirrored.max_depth = max_depth
	mirrored.spawn_weight = spawn_weight
	mirrored.ore_hints = ore_hints
	mirrored.treasure_tier = treasure_tier
	mirrored.tags = tags

	# Mirror the pattern
	var new_pattern: PackedStringArray = []
	for y in range(pattern.size()):
		var row: String = pattern[y]
		var new_row := ""
		for x in range(row.length() - 1, -1, -1):
			var tile := row[x]
			# Flip directional tiles
			match tile:
				">": tile = "<"
				"<": tile = ">"
			new_row += tile
		new_pattern.append(new_row)

	mirrored.pattern = new_pattern

	# Flip required approach
	match required_approach:
		"left": mirrored.required_approach = "right"
		"right": mirrored.required_approach = "left"
		_: mirrored.required_approach = required_approach

	return mirrored
