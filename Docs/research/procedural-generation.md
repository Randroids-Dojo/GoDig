# Procedural Generation Research

## Sources
- [Infinite TileMap with Godot 4](https://clotet.dev/blog/infinite-tilemap-with-godot-4/)
- [godot-chunking-system](https://github.com/DennisSmuda/godot-chunking-system)
- [godot-infinite-worldmap](https://github.com/edwin-cox/godot-infinite-worldmap)
- [GDQuest Procedural Generation](https://github.com/gdquest-demos/godot-procedural-generation)

## Chunk-Based Architecture

### Core Concept
- World divided into fixed-size chunks (e.g., 16x16 or 32x32 tiles)
- Only chunks near player are loaded
- Far chunks are unloaded to save memory
- New chunks generated on demand

### Node Structure
```
Main (Node2D)
├── Map (Node2D) - Script manages chunk logic
│   └── TileMap - Contains actual tiles
├── Player
└── ChunkTriggers (VisibleOnScreenNotifier2D nodes)
```

### Key Implementation Pattern
```gdscript
const CHUNK_SIZE = 16
var loaded_chunks = {}

func _generate_chunks_around_player(player_pos: Vector2):
    var chunk_coord = world_to_chunk(player_pos)
    for x in range(-2, 3):  # 5x5 chunk area
        for y in range(-2, 3):
            var chunk = Vector2i(chunk_coord.x + x, chunk_coord.y + y)
            if chunk not in loaded_chunks:
                _load_chunk(chunk)

func _load_chunk(chunk_coord: Vector2i):
    # Generate tiles for this chunk
    for x in range(CHUNK_SIZE):
        for y in range(CHUNK_SIZE):
            var world_pos = chunk_to_world(chunk_coord) + Vector2i(x, y)
            var tile = _generate_tile_at(world_pos)
            tilemap.set_cell(0, world_pos, tile_source, tile_atlas)
    loaded_chunks[chunk_coord] = true
```

## Threading for Performance

### Problem
- Generating many tiles causes frame stutters
- TileMap.set_cell() is main-thread only

### Solution
```gdscript
var generation_thread: Thread

func _generate_chunk_threaded(chunk_coord: Vector2i):
    generation_thread = Thread.new()
    generation_thread.start(_generate_chunk_data.bind(chunk_coord))

func _generate_chunk_data(chunk_coord: Vector2i):
    var tile_data = []
    for x in range(CHUNK_SIZE):
        for y in range(CHUNK_SIZE):
            var world_pos = chunk_to_world(chunk_coord) + Vector2i(x, y)
            tile_data.append({
                "pos": world_pos,
                "tile": _calculate_tile(world_pos)
            })
    # Queue tile placement on main thread
    _apply_tiles.call_deferred(tile_data)

func _apply_tiles(tile_data: Array):
    for data in tile_data:
        tilemap.set_cell(0, data.pos, ...)
    generation_thread.wait_to_finish()
```

## Noise-Based Generation

### FastNoise / OpenSimplex
- Perlin noise or OpenSimplex for natural-looking terrain
- Consistent output for same coordinates (deterministic)
- Multiple noise layers for complexity

### Depth-Based Layer System
```gdscript
func _get_layer_at_depth(y: int) -> String:
    if y < 50:
        return "topsoil"
    elif y < 200:
        return "dirt"
    elif y < 500:
        return "stone"
    elif y < 1000:
        return "granite"
    elif y < 2000:
        return "basite"
    else:
        return "magma"
```

### Ore Distribution
```gdscript
func _should_place_ore(pos: Vector2i, depth: int) -> bool:
    var noise_value = ore_noise.get_noise_2d(pos.x, pos.y)
    var depth_modifier = depth / 1000.0  # Rarer ores deeper
    return noise_value > (0.7 - depth_modifier * 0.1)

func _get_ore_type(pos: Vector2i, depth: int) -> String:
    # Check from rarest to most common
    if depth > 1000 and randf() < 0.001:
        return "diamond"
    if depth > 500 and randf() < 0.01:
        return "gold"
    # ... etc
```

## Cleanup Strategy

### Remove Distant Chunks
```gdscript
func _cleanup_distant_chunks(player_pos: Vector2):
    var player_chunk = world_to_chunk(player_pos)
    var chunks_to_remove = []

    for chunk_coord in loaded_chunks.keys():
        var distance = (chunk_coord - player_chunk).length()
        if distance > UNLOAD_DISTANCE:
            chunks_to_remove.append(chunk_coord)

    for chunk in chunks_to_remove:
        _unload_chunk(chunk)
        loaded_chunks.erase(chunk)

func _unload_chunk(chunk_coord: Vector2i):
    var base = chunk_to_world(chunk_coord)
    for x in range(CHUNK_SIZE):
        for y in range(CHUNK_SIZE):
            tilemap.erase_cell(0, base + Vector2i(x, y))
```

## Trigger-Based Loading

### VisibleOnScreenNotifier2D Approach
- Place invisible trigger nodes at chunk boundaries
- When player crosses boundary, generate new chunk
- More efficient than constant position checking

### Implementation
```gdscript
func _on_chunk_boundary_exited(direction: Vector2):
    var new_chunk = current_chunk + direction
    if new_chunk not in loaded_chunks:
        _generate_chunk_threaded(new_chunk)
```

## For GoDig: Vertical Focus

### Unique Considerations
- Primarily vertical movement (digging down)
- Horizontal surface is secondary
- Need to handle:
  - Very deep chunk coordinates (y could be 10000+)
  - Layer transitions (soil → rock → lava)
  - Persistent changes (dug blocks stay dug)

### Chunk Priority
```
Priority 1: Chunks below player (digging direction)
Priority 2: Chunks at same level (horizontal exploration)
Priority 3: Chunks above (already explored, for return trip)
```

### Persistence Approach
```gdscript
var modified_tiles = {}  # Dictionary of changed tiles

func _dig_tile(pos: Vector2i):
    tilemap.erase_cell(0, pos)
    modified_tiles[pos] = "dug"  # Save change

func _generate_tile_at(pos: Vector2i):
    if pos in modified_tiles:
        return modified_tiles[pos]  # Respect previous changes
    return _calculate_natural_tile(pos)
```

## Questions to Resolve
- [ ] Chunk size for mobile performance (16x16? 8x8?)
- [ ] How to save/load modified chunks?
- [ ] Maximum loaded chunks at once?
- [ ] Pre-generate chunks ahead of player?
- [ ] Seed system for world sharing?
