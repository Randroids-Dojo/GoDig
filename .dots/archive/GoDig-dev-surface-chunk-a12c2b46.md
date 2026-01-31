---
title: "implement: Surface chunk system"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-01-16T01:52:18.355519-06:00\\\"\""
closed-at: "2026-01-31T04:26:37.917711+00:00"
close-reason: Not needed - surface area is fixed size with building slots, no chunking required for optimization
---

## Description

Implement chunk-based loading for the horizontal surface area. The surface expands infinitely left and right, with chunks loaded around the player. Primarily used for walking between buildings on the surface.

## Context

While the main gameplay is vertical (digging down), the surface area provides:
- Building placement zone for shops
- Walking area between buildings
- Entry/exit point for the mine
- Visual town-building progression

Surface differs from underground chunks:
- Only 1-2 rows of terrain (ground level + grass)
- Rest is sky/background (no collision)
- Contains building placement slots
- Mostly flat with minor variation

See `Docs/research/surface-expansion.md` for full design.

## Affected Files

- `scripts/world/surface_manager.gd` - NEW: Manages surface chunks
- `scripts/world/surface_chunk.gd` - NEW: Surface chunk data class
- `scripts/world/chunk_manager.gd` - Coordinate with underground chunks
- `scenes/surface/surface_area.tscn` - Surface scene structure

## Implementation Notes

### SurfaceManager Class

```gdscript
# scripts/world/surface_manager.gd
extends Node2D

## Manages horizontal surface chunk loading

signal chunk_loaded(chunk_x: int)
signal chunk_unloaded(chunk_x: int)

const CHUNK_WIDTH := 32  # Tiles per surface chunk
const TILE_SIZE := 128
const LOAD_RADIUS := 2   # Load 2 chunks each direction
const UNLOAD_RADIUS := 4 # Unload at 4 chunks away

var loaded_chunks: Dictionary = {}  # int chunk_x -> SurfaceChunk
var _player_chunk_x: int = 0

@onready var ground_tilemap: TileMap = $GroundTileMap
@onready var buildings_container: Node2D = $Buildings


func _ready() -> void:
    # Player starts at chunk 0 (mine entrance)
    _update_chunks_around(0)


func update_player_position(world_x: float) -> void:
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

        # Optional: slight terrain variation
        # Use noise to occasionally raise/lower ground by 1 tile


func _apply_chunk_to_tilemap(chunk: SurfaceChunk) -> void:
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
```

### SurfaceChunk Data Class

```gdscript
# scripts/world/surface_chunk.gd
class_name SurfaceChunk
extends RefCounted

## Data for a single surface chunk

var chunk_x: int = 0
var tiles: Dictionary = {}  # Vector2i (local) -> tile_type
var building_slot: int = -1  # Building slot index if chunk has one
var has_building: bool = false
```

### Building Slot Integration

Buildings are placed at specific chunk intervals:

```gdscript
const BUILDING_INTERVAL := 2  # Building every 2 chunks

func get_building_slot_for_chunk(chunk_x: int) -> int:
    # Mine entrance at chunk 0
    if chunk_x == 0:
        return 0  # Mine slot

    # Buildings at every BUILDING_INTERVAL chunks
    if chunk_x % BUILDING_INTERVAL == 0:
        return chunk_x / BUILDING_INTERVAL

    return -1  # No building slot in this chunk
```

### Surface Scene Structure

```
SurfaceArea (Node2D)
├── Background
│   ├── Sky (ParallaxBackground)
│   └── Mountains (ParallaxLayer)
├── SurfaceManager (Node2D)
│   ├── GroundTileMap (TileMap)
│   └── Buildings (Node2D)
│       ├── MineEntrance
│       └── (dynamically added buildings)
└── Player (if on surface)
```

### Coordinate System

Surface uses a different coordinate system than underground:
- Surface Y = 0 is ground level
- Surface Y < 0 is sky (no collision)
- Surface Y > 0 is underground (transitions to chunk system)
- Underground Y maps to depth from GameManager.SURFACE_ROW

```gdscript
## Convert surface position to underground grid position
func surface_to_underground(surface_pos: Vector2i) -> Vector2i:
    return Vector2i(surface_pos.x, GameManager.SURFACE_ROW + surface_pos.y)


## Check if player should transition underground
func should_enter_underground(surface_pos: Vector2i) -> bool:
    return surface_pos.y > 0 and surface_pos.x == 0  # At mine entrance
```

## Edge Cases

- Player at mine entrance (x=0): Transition zone to underground
- Negative chunk indices: Valid, extend left from origin
- Building at chunk boundary: Center on chunk, don't split
- Very fast player movement: Load multiple chunks in one frame

## Verify

- [ ] Build succeeds with no errors
- [ ] Surface chunks load when player moves horizontally
- [ ] Chunks unload when player moves away
- [ ] Ground tiles appear correctly
- [ ] Mine entrance is at world x=0
- [ ] Building slots are at expected intervals
- [ ] No visual gaps between surface chunks
- [ ] Transition to underground works at mine entrance
