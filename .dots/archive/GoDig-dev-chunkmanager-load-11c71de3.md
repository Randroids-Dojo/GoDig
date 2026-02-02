---
title: "v1.0: ChunkManager - load/unload around player"
status: open
priority: 3
issue-type: task
created-at: "2026-01-16T00:37:51.427311-06:00"
after:
  - GoDig-dev-chunk-data-0fe0f614
  - GoDig-dev-noise-based-3afe498c
---

> **Scope: v1.0 Enhancement** - MVP uses DirtGrid for simplicity. ChunkManager will replace it in v1.0 for horizontal expansion and better persistence. See research: GoDig-research-assess-dirtgrid-1f19fea7

## Description

Create a ChunkManager that loads/unloads 16x16 tile chunks around the player. Maintains a 5x5 chunk area (25 chunks max) centered on the player. Uses background threading for generation to prevent frame stutters.

## Context

For infinite depth, chunks must be generated on-demand. Loading too many causes memory issues; loading too few causes pop-in. The 5x5 area gives 2-chunk buffer around player in all directions. Prioritize chunks below player (digging direction).

## Affected Files

- `scripts/world/chunk_manager.gd` - NEW: ChunkManager node script
- `scenes/world/chunk_manager.tscn` - NEW: ChunkManager scene with TileMap
- Depends on: TileTypes, ChunkData, terrain generator

## Implementation Notes

### ChunkManager Node Structure

```
ChunkManager (Node2D)
├── TileMap (ground layer)
└── PlacedObjects (Node2D for ladders etc)
```

### Core ChunkManager Script

```gdscript
# scripts/world/chunk_manager.gd
extends Node2D

signal chunk_loaded(chunk_coord: Vector2i)
signal chunk_unloaded(chunk_coord: Vector2i)

const CHUNK_SIZE := 16
const LOAD_RADIUS := 2   # 5x5 = radius 2 in each direction
const UNLOAD_RADIUS := 3 # Unload slightly further to prevent thrash

@onready var tilemap: TileMap = $TileMap

var loaded_chunks: Dictionary = {}  # Vector2i -> ChunkData
var _player_chunk: Vector2i = Vector2i.ZERO
var _generation_queue: Array[Vector2i] = []
var _generation_thread: Thread = null
var _pending_tiles: Array = []  # Tiles to apply on main thread
var _mutex: Mutex = Mutex.new()

func _ready() -> void:
    pass

func _process(_delta: float) -> void:
    _apply_pending_tiles()

## Call this when player moves to new grid position
func update_player_position(world_pos: Vector2i) -> void:
    var new_chunk := world_to_chunk(world_pos)
    if new_chunk != _player_chunk:
        _player_chunk = new_chunk
        _update_loaded_chunks()

func _update_loaded_chunks() -> void:
    # Determine which chunks should be loaded
    var needed_chunks: Array[Vector2i] = []
    for x in range(-LOAD_RADIUS, LOAD_RADIUS + 1):
        for y in range(-LOAD_RADIUS, LOAD_RADIUS + 1):
            var chunk := _player_chunk + Vector2i(x, y)
            needed_chunks.append(chunk)

    # Queue new chunks for generation (prioritize below player)
    needed_chunks.sort_custom(_chunk_priority_sort)
    for chunk in needed_chunks:
        if chunk not in loaded_chunks and chunk not in _generation_queue:
            _generation_queue.append(chunk)

    # Unload distant chunks
    var chunks_to_unload: Array[Vector2i] = []
    for chunk in loaded_chunks.keys():
        var distance := (chunk - _player_chunk).length()
        if distance > UNLOAD_RADIUS:
            chunks_to_unload.append(chunk)

    for chunk in chunks_to_unload:
        _unload_chunk(chunk)

    # Start generation if not already running
    if not _generation_queue.is_empty() and _generation_thread == null:
        _start_generation_thread()

func _chunk_priority_sort(a: Vector2i, b: Vector2i) -> bool:
    # Prioritize chunks below player (y increases downward)
    var a_below := a.y > _player_chunk.y
    var b_below := b.y > _player_chunk.y
    if a_below != b_below:
        return a_below  # Below comes first

    # Then by distance
    var dist_a := (a - _player_chunk).length()
    var dist_b := (b - _player_chunk).length()
    return dist_a < dist_b

func _start_generation_thread() -> void:
    if _generation_queue.is_empty():
        return
    _generation_thread = Thread.new()
    _generation_thread.start(_generate_chunks_threaded)

func _generate_chunks_threaded() -> void:
    while true:
        _mutex.lock()
        if _generation_queue.is_empty():
            _mutex.unlock()
            break
        var chunk_coord := _generation_queue.pop_front()
        _mutex.unlock()

        _generate_chunk(chunk_coord)

func _generate_chunk(chunk_coord: Vector2i) -> void:
    var chunk_data := ChunkData.new()
    chunk_data.chunk_coord = chunk_coord
    chunk_data.is_generated = true

    # Check SaveManager for persisted modifications
    var saved_mods: Dictionary = SaveManager.load_chunk(chunk_coord)

    var tiles_to_place: Array = []
    var base_world := chunk_to_world(chunk_coord)

    for x in range(CHUNK_SIZE):
        for y in range(CHUNK_SIZE):
            var local := Vector2i(x, y)
            var world := base_world + local

            var tile_type: int
            if saved_mods.has(local):
                tile_type = saved_mods[local]
                chunk_data.modified_tiles[local] = tile_type
            else:
                tile_type = _generate_tile_at(world)

            if tile_type != TileTypes.Type.AIR:
                tiles_to_place.append({
                    "pos": world,
                    "type": tile_type
                })

    # Queue tiles for main thread
    _mutex.lock()
    loaded_chunks[chunk_coord] = chunk_data
    _pending_tiles.append_array(tiles_to_place)
    _mutex.unlock()

func _generate_tile_at(world_pos: Vector2i) -> int:
    # Delegate to terrain generator
    # This will use noise and depth to determine tile type
    return TerrainGenerator.get_tile_at(world_pos)

func _apply_pending_tiles() -> void:
    if _pending_tiles.is_empty():
        return

    _mutex.lock()
    var tiles := _pending_tiles.duplicate()
    _pending_tiles.clear()
    _mutex.unlock()

    # Limit per frame to prevent stuttering
    var BATCH_SIZE := 100
    var applied := 0
    for tile_data in tiles:
        if applied >= BATCH_SIZE:
            # Re-queue remaining
            _mutex.lock()
            _pending_tiles.append_array(tiles.slice(applied))
            _mutex.unlock()
            break
        _place_tile(tile_data.pos, tile_data.type)
        applied += 1

    # Clean up thread if done
    if _generation_queue.is_empty() and _pending_tiles.is_empty():
        if _generation_thread != null:
            _generation_thread.wait_to_finish()
            _generation_thread = null

func _place_tile(world_pos: Vector2i, tile_type: int) -> void:
    if tile_type == TileTypes.Type.AIR:
        tilemap.erase_cell(0, world_pos)
    else:
        # Map tile_type to atlas coords - depends on TileSet setup
        var atlas_coords := _get_atlas_coords(tile_type)
        tilemap.set_cell(0, world_pos, 0, atlas_coords)

func _get_atlas_coords(tile_type: int) -> Vector2i:
    # Map tile types to TileSet atlas coordinates
    # Implementation depends on actual TileSet layout
    match tile_type:
        TileTypes.Type.DIRT: return Vector2i(0, 0)
        TileTypes.Type.STONE: return Vector2i(1, 0)
        # etc
        _: return Vector2i(0, 0)

func _unload_chunk(chunk_coord: Vector2i) -> void:
    if chunk_coord not in loaded_chunks:
        return

    var chunk_data: ChunkData = loaded_chunks[chunk_coord]

    # Save if modified
    if chunk_data.has_modifications():
        SaveManager.save_chunk(chunk_coord, chunk_data.modified_tiles)

    # Clear tiles from TileMap
    var base := chunk_to_world(chunk_coord)
    for x in range(CHUNK_SIZE):
        for y in range(CHUNK_SIZE):
            tilemap.erase_cell(0, base + Vector2i(x, y))

    loaded_chunks.erase(chunk_coord)
    chunk_unloaded.emit(chunk_coord)

## Called when player digs a tile
func dig_tile(world_pos: Vector2i) -> void:
    var chunk_coord := world_to_chunk(world_pos)
    if chunk_coord not in loaded_chunks:
        return

    var local := world_to_local(world_pos)
    var chunk_data: ChunkData = loaded_chunks[chunk_coord]
    chunk_data.clear_tile(local)

    tilemap.erase_cell(0, world_pos)

## Coordinate helpers
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
    return chunk_coord * CHUNK_SIZE
```

## Edge Cases

- Player teleports: Force immediate chunk update, may cause brief stutter
- Rapid movement: Queue limits prevent runaway generation
- Thread cleanup: Always wait_to_finish before null
- Chunk at y=0: Surface chunks generated differently (air above)
- Negative y chunks: Surface/sky area if needed

## Verify

- [ ] Build succeeds with no errors
- [ ] ChunkManager loads chunks in 5x5 area around player
- [ ] Chunks below player load first (priority)
- [ ] Chunks beyond UNLOAD_RADIUS are unloaded
- [ ] Modified chunks are saved before unloading
- [ ] dig_tile removes tile and marks chunk modified
- [ ] No frame stutters during chunk generation (threading works)
- [ ] Tiles appear correctly via TileMap
