extends Node
## ExplorationManager - Tracks player exploration for fog of war system.
##
## Creates tension by hiding unexplored areas while rewarding exploration.
## Explored areas remain visible (desaturated) while current vision radius
## shows full color. Works with LightingManager for depth-based lighting.

signal area_revealed(grid_pos: Vector2i)
signal exploration_updated

## Vision radius in blocks (5 tiles = visible area around player)
const VISION_RADIUS := 5

## Explored positions are stored per-chunk for memory efficiency
## Format: Dictionary[Vector2i chunk_coord, Dictionary[String "x,y", bool]]
var _explored_chunks: Dictionary = {}

## Currently visible positions (within vision radius)
var _visible_positions: Dictionary = {}  # Dictionary[Vector2i, bool]

## Player position tracking
var _last_player_grid_pos: Vector2i = Vector2i.ZERO

## Surface row (always visible as home base)
var _surface_row: int = 0


func _ready() -> void:
	# Get surface row from GameManager
	_surface_row = GameManager.SURFACE_ROW
	print("[ExplorationManager] Ready with vision radius: %d" % VISION_RADIUS)


## Update exploration based on player's current position
func update_player_position(player_world_pos: Vector2) -> void:
	var grid_pos := GameManager.world_to_grid(player_world_pos)

	# Skip if player hasn't moved to a new grid position
	if grid_pos == _last_player_grid_pos:
		return

	_last_player_grid_pos = grid_pos

	# Update visible positions (positions within vision radius)
	_update_visible_positions(grid_pos)

	# Reveal positions around the player
	_reveal_area(grid_pos)


## Update the set of currently visible positions
func _update_visible_positions(center: Vector2i) -> void:
	_visible_positions.clear()

	for dx in range(-VISION_RADIUS, VISION_RADIUS + 1):
		for dy in range(-VISION_RADIUS, VISION_RADIUS + 1):
			# Use circular vision (Manhattan distance approximation)
			if absf(dx) + absf(dy) <= VISION_RADIUS * 1.5:
				var pos := Vector2i(center.x + dx, center.y + dy)
				_visible_positions[pos] = true


## Reveal an area around a position
func _reveal_area(center: Vector2i) -> void:
	var newly_revealed := false

	for dx in range(-VISION_RADIUS, VISION_RADIUS + 1):
		for dy in range(-VISION_RADIUS, VISION_RADIUS + 1):
			if absf(dx) + absf(dy) <= VISION_RADIUS * 1.5:
				var pos := Vector2i(center.x + dx, center.y + dy)
				if _mark_explored(pos):
					newly_revealed = true
					area_revealed.emit(pos)

	if newly_revealed:
		exploration_updated.emit()


## Mark a position as explored. Returns true if newly explored.
func _mark_explored(pos: Vector2i) -> bool:
	# Surface is always explored
	if pos.y < _surface_row:
		return false

	var chunk_coord := _get_chunk_coord(pos)
	var key := "%d,%d" % [pos.x, pos.y]

	if not _explored_chunks.has(chunk_coord):
		_explored_chunks[chunk_coord] = {}

	if _explored_chunks[chunk_coord].has(key):
		return false  # Already explored

	_explored_chunks[chunk_coord][key] = true
	return true


## Check if a position has been explored
func is_explored(pos: Vector2i) -> bool:
	# Surface is always visible
	if pos.y < _surface_row:
		return true

	var chunk_coord := _get_chunk_coord(pos)
	var key := "%d,%d" % [pos.x, pos.y]

	if not _explored_chunks.has(chunk_coord):
		return false

	return _explored_chunks[chunk_coord].has(key)


## Check if a position is currently visible (within vision radius)
func is_visible(pos: Vector2i) -> bool:
	# Surface is always visible
	if pos.y < _surface_row:
		return true

	return _visible_positions.has(pos)


## Get the visual state for a position
## Returns: 0 = unexplored (dark), 1 = explored but not visible (desaturated), 2 = visible (full color)
func get_visibility_state(pos: Vector2i) -> int:
	if is_visible(pos):
		return 2  # Full visibility
	elif is_explored(pos):
		return 1  # Explored but not in current vision
	else:
		return 0  # Unexplored (dark)


## Get the modulate color for a block based on exploration state
func get_block_modulate(pos: Vector2i) -> Color:
	var state := get_visibility_state(pos)
	match state:
		0:  # Unexplored - very dark
			return Color(0.15, 0.15, 0.2, 1.0)
		1:  # Explored - desaturated
			return Color(0.6, 0.6, 0.65, 1.0)
		_:  # Visible - full color (let LightingManager handle depth)
			return Color.WHITE


## Get chunk coordinate for a grid position (16x16 chunks)
func _get_chunk_coord(pos: Vector2i) -> Vector2i:
	return Vector2i(
		int(floor(float(pos.x) / 16.0)),
		int(floor(float(pos.y) / 16.0))
	)


## Mark a mined block position as permanently explored
## Called when blocks are destroyed to ensure mined paths remain visible
func mark_block_mined(pos: Vector2i) -> void:
	_mark_explored(pos)


## Mark ladder positions as always visible (critical for return planning)
func mark_ladder_placed(pos: Vector2i) -> void:
	_mark_explored(pos)
	# Also mark adjacent positions for visibility
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			_mark_explored(Vector2i(pos.x + dx, pos.y + dy))


## Get exploration data for saving
func get_save_data() -> Dictionary:
	var data := {}
	for chunk_coord in _explored_chunks:
		var chunk_key := "%d,%d" % [chunk_coord.x, chunk_coord.y]
		data[chunk_key] = _explored_chunks[chunk_coord].duplicate()
	return data


## Load exploration data from save
func load_save_data(data: Dictionary) -> void:
	_explored_chunks.clear()
	for chunk_key in data:
		var parts := (chunk_key as String).split(",")
		if parts.size() == 2:
			var chunk_coord := Vector2i(int(parts[0]), int(parts[1]))
			_explored_chunks[chunk_coord] = data[chunk_key].duplicate()
	print("[ExplorationManager] Loaded %d explored chunks" % _explored_chunks.size())


## Reset exploration for new game
func reset() -> void:
	_explored_chunks.clear()
	_visible_positions.clear()
	_last_player_grid_pos = Vector2i.ZERO
	print("[ExplorationManager] Reset exploration data")


## Get total explored tile count (for stats/achievements)
func get_explored_count() -> int:
	var count := 0
	for chunk_coord in _explored_chunks:
		count += _explored_chunks[chunk_coord].size()
	return count
