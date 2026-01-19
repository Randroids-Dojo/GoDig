extends Node2D

## Manages horizontal surface chunk loading
## Handles infinite horizontal scrolling by loading/unloading chunks as player moves

signal chunk_loaded(chunk_x: int)
signal chunk_unloaded(chunk_x: int)

const CHUNK_WIDTH := 32  # Tiles per surface chunk
const TILE_SIZE := 128
const LOAD_RADIUS := 2   # Load 2 chunks each direction
const UNLOAD_RADIUS := 4 # Unload at 4 chunks away
const BUILDING_INTERVAL := 2  # Building slot every 2 chunks

var loaded_chunks: Dictionary = {}  # int chunk_x -> SurfaceChunk
var _player_chunk_x: int = 0
var _player: Node2D = null

@onready var ground_tilemap: TileMap = $GroundTileMap
@onready var buildings_container: Node2D = $Buildings


func _ready() -> void:
	# Wait for player to be initialized via initialize() call
	pass


func initialize(player: Node2D) -> void:
	_player = player
	# Now load initial chunks around player
	if _player != null:
		var world_x := _player.position.x
		var chunk_x := int(world_x / (CHUNK_WIDTH * TILE_SIZE))
		_player_chunk_x = chunk_x
		_update_chunks_around(chunk_x)


func _process(_delta: float) -> void:
	if _player == null:
		return

	var world_x := _player.position.x
	var new_chunk := int(world_x / (CHUNK_WIDTH * TILE_SIZE))
	if new_chunk != _player_chunk_x:
		_player_chunk_x = new_chunk
		_update_chunks_around(new_chunk)


func _update_chunks_around(center_chunk: int) -> void:
	# Load needed chunks
	for offset in range(-LOAD_RADIUS, LOAD_RADIUS + 1):
		var chunk_x := center_chunk + offset
		if chunk_x not in loaded_chunks:
			_load_surface_chunk(chunk_x)

	# Unload distant chunks
	var to_unload: Array[int] = []
	for chunk_x in loaded_chunks.keys():
		if abs(chunk_x - center_chunk) > UNLOAD_RADIUS:
			to_unload.append(chunk_x)

	for chunk_x in to_unload:
		_unload_surface_chunk(chunk_x)


func _load_surface_chunk(chunk_x: int) -> void:
	var chunk := SurfaceChunk.new()
	chunk.chunk_x = chunk_x
	_generate_surface_terrain(chunk)
	_apply_chunk_to_tilemap(chunk)
	loaded_chunks[chunk_x] = chunk
	chunk_loaded.emit(chunk_x)


func _generate_surface_terrain(chunk: SurfaceChunk) -> void:
	var base_x := chunk.chunk_x * CHUNK_WIDTH

	for x in range(CHUNK_WIDTH):
		var world_x := base_x + x

		# Ground row (y = 0 in surface coordinates)
		chunk.tiles[Vector2i(x, 0)] = TileTypes.Type.GRASS

		# Sub-surface row (y = 1)
		chunk.tiles[Vector2i(x, 1)] = TileTypes.Type.DIRT

	# Check if this chunk has a building slot
	chunk.building_slot = get_building_slot_for_chunk(chunk.chunk_x)


func _apply_chunk_to_tilemap(chunk: SurfaceChunk) -> void:
	if ground_tilemap == null:
		return

	var base_x := chunk.chunk_x * CHUNK_WIDTH

	for local_pos in chunk.tiles.keys():
		var world_pos := Vector2i(base_x + local_pos.x, local_pos.y)
		var tile_type: int = chunk.tiles[local_pos]
		var atlas_coords := _get_atlas_coords(tile_type)
		ground_tilemap.set_cell(0, world_pos, 0, atlas_coords)


func _unload_surface_chunk(chunk_x: int) -> void:
	if chunk_x not in loaded_chunks:
		return

	var chunk: SurfaceChunk = loaded_chunks[chunk_x]

	if ground_tilemap != null:
		var base_x := chunk_x * CHUNK_WIDTH

		# Clear tiles from TileMap
		for local_pos in chunk.tiles.keys():
			var world_pos := Vector2i(base_x + local_pos.x, local_pos.y)
			ground_tilemap.erase_cell(0, world_pos)

	loaded_chunks.erase(chunk_x)
	chunk_unloaded.emit(chunk_x)


func _get_atlas_coords(tile_type: int) -> Vector2i:
	match tile_type:
		TileTypes.Type.GRASS: return Vector2i(0, 0)
		TileTypes.Type.DIRT: return Vector2i(1, 0)
		_: return Vector2i(0, 0)


func get_building_slot_for_chunk(chunk_x: int) -> int:
	# Mine entrance at chunk 0
	if chunk_x == 0:
		return 0  # Mine slot

	# Buildings at every BUILDING_INTERVAL chunks
	if chunk_x % BUILDING_INTERVAL == 0:
		return chunk_x // BUILDING_INTERVAL

	return -1  # No building slot in this chunk


## Convert surface position to underground grid position
func surface_to_underground(surface_pos: Vector2i) -> Vector2i:
	return Vector2i(surface_pos.x, GameManager.SURFACE_ROW + surface_pos.y)


## Check if player should transition underground
func should_enter_underground(surface_pos: Vector2i) -> bool:
	return surface_pos.y > 0 and surface_pos.x == 0  # At mine entrance
