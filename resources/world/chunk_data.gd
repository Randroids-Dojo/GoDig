class_name ChunkData extends Resource
## Resource class for storing chunk state in the infinite world.
##
## Each chunk is CHUNK_SIZE x CHUNK_SIZE tiles. ChunkData stores only
## modifications from the generated terrain (delta compression) to minimize
## storage while supporting infinite depth.
##
## Coordinate spaces:
## - World coords: absolute tile position in the infinite world
## - Chunk coords: which chunk (world / CHUNK_SIZE)
## - Local coords: position within chunk (world % CHUNK_SIZE), range [0, CHUNK_SIZE)

## Size of a chunk in tiles (16x16 is the target from spec)
const CHUNK_SIZE := 16

## Chunk coordinate in chunk-space (not world tiles)
## Example: chunk at (0, 2) contains world tiles y=32 to y=47
@export var chunk_coord: Vector2i = Vector2i.ZERO

## Modified tiles - key: packed local position, value: TileTypes.Type
## Only stores tiles that differ from generated terrain.
## Uses packed int keys: local_x + local_y * CHUNK_SIZE
@export var modified_tiles: Dictionary = {}

## Placed objects like ladders - separate from terrain mods
## Key: packed local position, value: object type from TileTypes
@export var placed_objects: Dictionary = {}

## Whether this chunk has ever been visited/generated
@export var is_generated: bool = false

## Timestamp of last modification (Unix time) for cleanup priority
@export var last_modified: int = 0


## Convert world tile position to chunk coordinate
static func world_to_chunk(world_pos: Vector2i) -> Vector2i:
	# Integer division rounds toward negative infinity for negative coords
	var cx := world_pos.x / CHUNK_SIZE if world_pos.x >= 0 else (world_pos.x - CHUNK_SIZE + 1) / CHUNK_SIZE
	var cy := world_pos.y / CHUNK_SIZE if world_pos.y >= 0 else (world_pos.y - CHUNK_SIZE + 1) / CHUNK_SIZE
	return Vector2i(cx, cy)


## Convert world tile position to local position within chunk
static func world_to_local(world_pos: Vector2i) -> Vector2i:
	var lx := world_pos.x % CHUNK_SIZE
	var ly := world_pos.y % CHUNK_SIZE
	# Handle negative coords (modulo can be negative in GDScript)
	if lx < 0:
		lx += CHUNK_SIZE
	if ly < 0:
		ly += CHUNK_SIZE
	return Vector2i(lx, ly)


## Convert chunk coordinate + local position to world position
static func chunk_local_to_world(chunk_coord_param: Vector2i, local_pos: Vector2i) -> Vector2i:
	return Vector2i(
		chunk_coord_param.x * CHUNK_SIZE + local_pos.x,
		chunk_coord_param.y * CHUNK_SIZE + local_pos.y
	)


## Pack local coordinates into a single int for dictionary key
static func pack_local(local_pos: Vector2i) -> int:
	return local_pos.x + local_pos.y * CHUNK_SIZE


## Unpack dictionary key back to local coordinates
static func unpack_local(packed: int) -> Vector2i:
	return Vector2i(packed % CHUNK_SIZE, packed / CHUNK_SIZE)


## Set a modified tile at local position
func set_modified_tile(local_pos: Vector2i, tile_type: int) -> void:
	var key := pack_local(local_pos)
	if tile_type == TileTypes.Type.AIR:
		# Store AIR to record that tile was dug
		modified_tiles[key] = tile_type
	else:
		modified_tiles[key] = tile_type
	last_modified = int(Time.get_unix_time_from_system())


## Get modified tile at local position, returns null if not modified
func get_modified_tile(local_pos: Vector2i):
	var key := pack_local(local_pos)
	if modified_tiles.has(key):
		return modified_tiles[key]
	return null


## Check if a tile has been modified from generated state
func has_modified_tile(local_pos: Vector2i) -> bool:
	return modified_tiles.has(pack_local(local_pos))


## Clear a modification (revert to generated terrain)
func clear_modified_tile(local_pos: Vector2i) -> void:
	modified_tiles.erase(pack_local(local_pos))
	last_modified = int(Time.get_unix_time_from_system())


## Place an object at local position
func place_object(local_pos: Vector2i, object_type: int) -> void:
	var key := pack_local(local_pos)
	placed_objects[key] = object_type
	last_modified = int(Time.get_unix_time_from_system())


## Remove a placed object
func remove_object(local_pos: Vector2i) -> void:
	placed_objects.erase(pack_local(local_pos))
	last_modified = int(Time.get_unix_time_from_system())


## Get placed object at local position, returns null if none
func get_placed_object(local_pos: Vector2i):
	var key := pack_local(local_pos)
	if placed_objects.has(key):
		return placed_objects[key]
	return null


## Check if there's a placed object at local position
func has_placed_object(local_pos: Vector2i) -> bool:
	return placed_objects.has(pack_local(local_pos))


## Check if chunk has any modifications (for cleanup decisions)
func has_modifications() -> bool:
	return not modified_tiles.is_empty() or not placed_objects.is_empty()


## Get total count of modifications
func get_modification_count() -> int:
	return modified_tiles.size() + placed_objects.size()


## Get world position of chunk origin (top-left tile)
func get_world_origin() -> Vector2i:
	return Vector2i(chunk_coord.x * CHUNK_SIZE, chunk_coord.y * CHUNK_SIZE)


## Get world rect covered by this chunk
func get_world_rect() -> Rect2i:
	var origin := get_world_origin()
	return Rect2i(origin.x, origin.y, CHUNK_SIZE, CHUNK_SIZE)


## Serialize to dictionary for save system
func to_dict() -> Dictionary:
	return {
		"chunk_coord": [chunk_coord.x, chunk_coord.y],
		"modified_tiles": modified_tiles.duplicate(),
		"placed_objects": placed_objects.duplicate(),
		"is_generated": is_generated,
		"last_modified": last_modified,
	}


## Deserialize from dictionary
static func from_dict(data: Dictionary) -> ChunkData:
	var chunk := ChunkData.new()
	var coord_arr = data.get("chunk_coord", [0, 0])
	chunk.chunk_coord = Vector2i(coord_arr[0], coord_arr[1])
	chunk.modified_tiles = data.get("modified_tiles", {})
	chunk.placed_objects = data.get("placed_objects", {})
	chunk.is_generated = data.get("is_generated", false)
	chunk.last_modified = data.get("last_modified", 0)
	return chunk
