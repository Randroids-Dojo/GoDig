---
title: "implement: Chunk data structure"
status: closed
priority: 1
issue-type: task
created-at: "2026-01-16T00:37:51.423895-06:00"
close-reason: Implemented in resources/world/chunk_data.gd and scripts/world/tile_types.gd
---

## Description

Create the ChunkData resource class and related data structures used by the chunk-based world generation system. Each chunk is 16x16 tiles and tracks both generated terrain and player modifications (dug tiles, placed ladders).

## Context

The infinite depth world is divided into chunks. ChunkData stores the state of each chunk for persistence - which tiles have been modified from their generated state. This allows the world to regenerate identically while respecting player changes.

## Affected Files

- `resources/world/chunk_data.gd` - NEW: ChunkData resource class (NOT YET IMPLEMENTED)
- `scripts/world/tile_types.gd` - **IMPLEMENTED**: Enum/constants for tile types

## Implementation Notes

### Tile Types Constants

```gdscript
# scripts/world/tile_types.gd
class_name TileTypes

enum Type {
    AIR = -1,       # Dug out / empty
    DIRT = 0,
    CLAY = 1,
    STONE = 2,
    GRANITE = 3,
    BASALT = 4,
    OBSIDIAN = 5,
    # Ores
    COAL = 10,
    COPPER = 11,
    IRON = 12,
    SILVER = 13,
    GOLD = 14,
    DIAMOND = 15,
    # Placed objects
    LADDER = 100,
}

# Tile hardness (hits to break)
const HARDNESS := {
    Type.DIRT: 1,
    Type.CLAY: 2,
    Type.STONE: 3,
    Type.GRANITE: 5,
    Type.BASALT: 8,
    Type.OBSIDIAN: 12,
    Type.COAL: 2,
    Type.COPPER: 3,
    Type.IRON: 4,
    Type.SILVER: 5,
    Type.GOLD: 6,
    Type.DIAMOND: 10,
}
```

### ChunkData Resource Class

```gdscript
# resources/world/chunk_data.gd
class_name ChunkData extends Resource

## Chunk coordinate in chunk-space (not world tiles)
@export var chunk_coord: Vector2i = Vector2i.ZERO

## Modified tiles only - key: local Vector2i (0-15, 0-15), value: TileTypes.Type
## Empty means tile uses generated value. This is delta compression.
@export var modified_tiles: Dictionary = {}

## Placed objects like ladders - key: local Vector2i, value: object type
@export var placed_objects: Dictionary = {}

## Whether this chunk has ever been visited/generated
@export var is_generated: bool = false

## Timestamp of last modification (for cleanup)
@export var last_modified: int = 0


func set_tile(local_pos: Vector2i, tile_type: int) -> void:
    modified_tiles[local_pos] = tile_type
    last_modified = Time.get_unix_time_from_system()


func get_tile(local_pos: Vector2i) -> int:
    if modified_tiles.has(local_pos):
        return modified_tiles[local_pos]
    return -2  # -2 means "use generated value"


func clear_tile(local_pos: Vector2i) -> void:
    set_tile(local_pos, TileTypes.Type.AIR)


func place_object(local_pos: Vector2i, object_type: int) -> void:
    placed_objects[local_pos] = object_type
    last_modified = Time.get_unix_time_from_system()


func remove_object(local_pos: Vector2i) -> void:
    placed_objects.erase(local_pos)
    last_modified = Time.get_unix_time_from_system()


func has_modifications() -> bool:
    return not modified_tiles.is_empty() or not placed_objects.is_empty()


## Convert to dictionary for binary save
func to_save_dict() -> Dictionary:
    return {
        "coord": [chunk_coord.x, chunk_coord.y],
        "tiles": _compress_tiles(),
        "objects": _compress_objects(),
        "time": last_modified
    }


## Load from dictionary
static func from_save_dict(data: Dictionary) -> ChunkData:
    var chunk := ChunkData.new()
    chunk.chunk_coord = Vector2i(data["coord"][0], data["coord"][1])
    chunk._decompress_tiles(data.get("tiles", []))
    chunk._decompress_objects(data.get("objects", []))
    chunk.last_modified = data.get("time", 0)
    chunk.is_generated = true
    return chunk


## Compress tiles to array for smaller save size
func _compress_tiles() -> Array:
    var result := []
    for pos in modified_tiles:
        # Pack as [x, y, type]
        result.append([pos.x, pos.y, modified_tiles[pos]])
    return result


func _decompress_tiles(data: Array) -> void:
    modified_tiles.clear()
    for entry in data:
        var pos := Vector2i(entry[0], entry[1])
        modified_tiles[pos] = entry[2]


func _compress_objects() -> Array:
    var result := []
    for pos in placed_objects:
        result.append([pos.x, pos.y, placed_objects[pos]])
    return result


func _decompress_objects(data: Array) -> void:
    placed_objects.clear()
    for entry in data:
        var pos := Vector2i(entry[0], entry[1])
        placed_objects[pos] = entry[2]
```

### Coordinate Conversion Helpers

These should go in ChunkManager but define the interface here:

```gdscript
const CHUNK_SIZE := 16

static func world_to_chunk(world_pos: Vector2i) -> Vector2i:
    return Vector2i(
        floori(float(world_pos.x) / CHUNK_SIZE),
        floori(float(world_pos.y) / CHUNK_SIZE)
    )

static func world_to_local(world_pos: Vector2i) -> Vector2i:
    var x := world_pos.x % CHUNK_SIZE
    var y := world_pos.y % CHUNK_SIZE
    if x < 0: x += CHUNK_SIZE
    if y < 0: y += CHUNK_SIZE
    return Vector2i(x, y)

static func chunk_to_world(chunk_coord: Vector2i) -> Vector2i:
    return Vector2i(chunk_coord.x * CHUNK_SIZE, chunk_coord.y * CHUNK_SIZE)
```

## Edge Cases

- Negative chunk coordinates: Handle correctly with floori (chunks go up too)
- Empty chunk: Has no modifications, should not be saved
- Chunk at world boundaries: No special handling needed (infinite world)
- Very deep chunks (y > 10000): No int overflow at reasonable depths

## Verify

- [ ] Build succeeds with no errors
- [ ] TileTypes enum contains all required tile types
- [ ] ChunkData can be created with chunk_coord
- [ ] set_tile/get_tile correctly store and retrieve modifications
- [ ] clear_tile sets tile to AIR type
- [ ] has_modifications returns false for fresh chunk
- [ ] has_modifications returns true after modification
- [ ] to_save_dict and from_save_dict round-trip correctly
- [ ] Coordinate conversions are correct for positive and negative coords
