# Godot 4.6 WorkerThreadPool Patterns for Async Chunk Generation

> Research on using Godot 4's threading capabilities for background chunk generation in 2D games. Covers WorkerThreadPool, thread-safe patterns, TileMap limitations, and recommended architectures for GoDig.
> Last updated: 2026-02-02 (Session 27)

## Executive Summary

Godot 4's WorkerThreadPool provides managed threading for background tasks, but **TileMap/scene tree modifications MUST happen on the main thread**. The recommended pattern is: generate chunk DATA in a background thread, then apply it to the TileMap via `call_deferred()`. This research covers the limitations, patterns, and specific implementations for chunk-based 2D games.

---

## 1. Thread Safety Fundamentals

### The Golden Rule

> **The scene tree is NOT thread-safe.**
>
> Any operation that modifies the scene tree (`add_child()`, `set_cell()`, `queue_free()`) must be called from the main thread or deferred.

### What CAN Run in Background Threads

| Safe | Unsafe |
|------|--------|
| Noise generation | TileMap.set_cell() |
| Array/Dictionary operations | Node.add_child() |
| Math calculations | Signal emission (mostly) |
| Data structure manipulation | Tree queries (get_children, get_parent) |
| Resource loading (with care) | Rendering operations |

### Godot 4.1+ Restrictions

Godot 4.1 introduced stricter thread safety checks. Calling tree-traversal functions like `get_children()` or `get_parent()` from threads now throws:

```
Error: Caller thread can't call this function in this node.
Use call_deferred() or call_thread_group() instead.
```

**Workaround:** Cache node references outside the thread:

```gdscript
# Store reference before thread work
@onready var tilemap: TileMap = $TileMap

func _in_thread():
    # Use call_deferred to modify from thread
    tilemap.set_cell.call_deferred(0, Vector2i(x, y), source_id, atlas_coords)
```

---

## 2. WorkerThreadPool API

### Overview

`WorkerThreadPool` is a singleton that manages a pool of worker threads, automatically sized based on CPU cores. It's preferred over manual `Thread` objects for task-based work.

### Key Methods

| Method | Purpose |
|--------|---------|
| `add_task(callable)` | Submit a task, returns task ID |
| `add_group_task(callable, elements)` | Parallel task across N elements |
| `wait_for_task_completion(id)` | Block until task completes |
| `wait_for_group_task_completion(id)` | Block until all group tasks complete |
| `is_task_completed(id)` | Check if task is done (non-blocking) |

### Critical Warning

> **Every task must be waited for completion at some point.**
>
> Memory for tasks is not automatically managed. Call `wait_for_task_completion()` or the task memory will leak.

### Basic Pattern

```gdscript
var _pending_tasks: Array[int] = []

func _start_chunk_generation(chunk_coords: Vector2i) -> void:
    var task_id = WorkerThreadPool.add_task(
        func(): _generate_chunk_data(chunk_coords)
    )
    _pending_tasks.append(task_id)

func _process(_delta: float) -> void:
    # Check and clean up completed tasks
    var completed: Array[int] = []
    for task_id in _pending_tasks:
        if WorkerThreadPool.is_task_completed(task_id):
            WorkerThreadPool.wait_for_task_completion(task_id)
            completed.append(task_id)

    for task_id in completed:
        _pending_tasks.erase(task_id)
```

---

## 3. TileMap Threading Limitations

### The Core Problem

`TileMap.set_cell()` and especially `set_cell_terrain_connect()` are expensive operations that block the main thread. When loading chunks with many tiles, this causes visible stutters.

From community experience:

> "Each chunk does set_cell and set_cell_terrain_connect operations... the main thread is blocked by the slow set_cell_terrain_connect method."

### What Does NOT Work

1. **Direct set_cell from thread** - Crashes immediately
2. **Modifying TileMap in scene tree from thread** - Crashes
3. **Creating TileMap node in thread, then add_child** - Still crashes/glitches
4. **set_cell on node before add_child** - Can work but fragile

### What DOES Work

1. **Generate data in thread, apply via call_deferred**
2. **Use individual Thread with call_deferred for set_cell**
3. **Spread set_cell calls across multiple frames**
4. **Avoid set_cell_terrain_connect for interior tiles**

---

## 4. Recommended Chunk Generation Pattern

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     MAIN THREAD                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │ ChunkManager │───▶│ Apply Tiles  │───▶│   TileMap    │  │
│  │ (requests)   │    │ (deferred)   │    │   (render)   │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
│         │                   ▲                               │
│         ▼                   │                               │
│  ┌──────────────┐    ┌──────────────┐                      │
│  │  Task Queue  │    │  Data Queue  │                      │
│  └──────────────┘    └──────────────┘                      │
│         │                   ▲                               │
└─────────│───────────────────│───────────────────────────────┘
          │                   │
          ▼                   │
┌─────────────────────────────────────────────────────────────┐
│                  WORKER THREAD POOL                         │
│  ┌──────────────┐    ┌──────────────┐                      │
│  │ ChunkWorker  │───▶│ Chunk Data   │                      │
│  │ (generation) │    │ (no nodes)   │                      │
│  └──────────────┘    └──────────────┘                      │
└─────────────────────────────────────────────────────────────┘
```

### Implementation

```gdscript
# chunk_manager.gd
class_name ChunkManager
extends Node

signal chunk_ready(chunk_coords: Vector2i, data: ChunkData)

const CHUNK_SIZE := 16
const LOAD_RADIUS := 3
const UNLOAD_DISTANCE := 5
const MAX_TILES_PER_FRAME := 50  # Prevent stutter

var _loaded_chunks: Dictionary = {}  # Vector2i -> ChunkData
var _pending_generation: Dictionary = {}  # Vector2i -> task_id
var _apply_queue: Array[ChunkData] = []
var _noise: FastNoiseLite

@onready var _tilemap: TileMap = $TileMap

func _ready() -> void:
    _noise = FastNoiseLite.new()
    _noise.seed = 42
    _noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH

func _process(_delta: float) -> void:
    _check_pending_tasks()
    _apply_queued_chunks()

func update_loaded_chunks(player_chunk: Vector2i) -> void:
    # Queue chunks to load
    for x in range(-LOAD_RADIUS, LOAD_RADIUS + 1):
        for y in range(-LOAD_RADIUS, LOAD_RADIUS + 1):
            var coords := player_chunk + Vector2i(x, y)
            if not _loaded_chunks.has(coords) and not _pending_generation.has(coords):
                _request_chunk_generation(coords)

    # Unload distant chunks
    var to_unload: Array[Vector2i] = []
    for coords in _loaded_chunks.keys():
        if coords.distance_to(player_chunk) > UNLOAD_DISTANCE:
            to_unload.append(coords)

    for coords in to_unload:
        _unload_chunk(coords)

func _request_chunk_generation(coords: Vector2i) -> void:
    var task_id := WorkerThreadPool.add_task(
        func(): _generate_chunk_data_threaded(coords)
    )
    _pending_generation[coords] = task_id

func _generate_chunk_data_threaded(coords: Vector2i) -> void:
    # This runs in background thread - NO scene tree access!
    var data := ChunkData.new()
    data.coords = coords
    data.tiles = []

    var world_offset := coords * CHUNK_SIZE

    for local_x in CHUNK_SIZE:
        for local_y in CHUNK_SIZE:
            var world_pos := world_offset + Vector2i(local_x, local_y)
            var noise_value := _noise.get_noise_2d(world_pos.x, world_pos.y)

            var tile_type := _determine_tile_type(noise_value, world_pos.y)
            data.tiles.append({
                "pos": world_pos,
                "type": tile_type
            })

    # Queue data for main thread - call_deferred is thread-safe
    _on_chunk_generated.call_deferred(data)

func _determine_tile_type(noise_value: float, depth: int) -> int:
    # Your ore/block generation logic here
    if noise_value > 0.6:
        return TileTypes.STONE
    elif noise_value > 0.4:
        return TileTypes.DIRT
    else:
        return TileTypes.EMPTY

func _on_chunk_generated(data: ChunkData) -> void:
    # This runs on main thread via call_deferred
    _apply_queue.append(data)

func _check_pending_tasks() -> void:
    var completed: Array[Vector2i] = []

    for coords in _pending_generation.keys():
        var task_id: int = _pending_generation[coords]
        if WorkerThreadPool.is_task_completed(task_id):
            WorkerThreadPool.wait_for_task_completion(task_id)
            completed.append(coords)

    for coords in completed:
        _pending_generation.erase(coords)

func _apply_queued_chunks() -> void:
    if _apply_queue.is_empty():
        return

    var tiles_applied := 0

    while not _apply_queue.is_empty() and tiles_applied < MAX_TILES_PER_FRAME:
        var data: ChunkData = _apply_queue[0]

        # Apply tiles from this chunk
        while data.apply_index < data.tiles.size() and tiles_applied < MAX_TILES_PER_FRAME:
            var tile: Dictionary = data.tiles[data.apply_index]
            _tilemap.set_cell(0, tile.pos, 0, _get_atlas_coords(tile.type))
            data.apply_index += 1
            tiles_applied += 1

        # Check if chunk is fully applied
        if data.apply_index >= data.tiles.size():
            _loaded_chunks[data.coords] = data
            _apply_queue.pop_front()
            chunk_ready.emit(data.coords, data)

func _unload_chunk(coords: Vector2i) -> void:
    var data: ChunkData = _loaded_chunks[coords]

    # Clear tiles
    var world_offset := coords * CHUNK_SIZE
    for local_x in CHUNK_SIZE:
        for local_y in CHUNK_SIZE:
            _tilemap.set_cell(0, world_offset + Vector2i(local_x, local_y))

    _loaded_chunks.erase(coords)

func _get_atlas_coords(tile_type: int) -> Vector2i:
    # Map tile type to atlas coordinates
    match tile_type:
        TileTypes.DIRT:
            return Vector2i(0, 0)
        TileTypes.STONE:
            return Vector2i(1, 0)
        _:
            return Vector2i(-1, -1)  # Empty

# chunk_data.gd
class_name ChunkData
extends RefCounted

var coords: Vector2i
var tiles: Array  # Array of {pos: Vector2i, type: int}
var apply_index: int = 0  # For incremental application
```

---

## 5. Alternative: Thread Class Pattern

For simpler projects, using the `Thread` class directly can work:

```gdscript
var _spawn_thread: Thread
var _kill_thread: Thread

func _add_chunk(coords: Vector2i) -> void:
    if _spawn_thread != null and _spawn_thread.is_alive():
        return  # Thread busy

    _spawn_thread = Thread.new()
    _spawn_thread.start(_load_chunk.bind(coords))

func _load_chunk(coords: Vector2i) -> void:
    # Generate chunk data (thread-safe operations only)
    var chunk_data := _generate_data(coords)

    # Return to main thread for scene tree operations
    call_deferred("_apply_chunk", chunk_data)

func _apply_chunk(data: Dictionary) -> void:
    # Now on main thread - safe to modify scene tree
    for tile in data.tiles:
        tilemap.set_cell(0, tile.pos, tile.source, tile.atlas)

    # Clean up thread
    _spawn_thread.wait_to_finish()
```

---

## 6. Performance Optimization Strategies

### Spread Tile Application Across Frames

Don't apply all tiles at once - spread them to avoid frame spikes:

```gdscript
const MAX_TILES_PER_FRAME := 50

func _apply_tiles_incrementally() -> void:
    var applied := 0
    while _tile_queue.size() > 0 and applied < MAX_TILES_PER_FRAME:
        var tile = _tile_queue.pop_front()
        _tilemap.set_cell(0, tile.pos, tile.source, tile.atlas)
        applied += 1
```

### Avoid set_cell_terrain_connect()

`set_cell_terrain_connect()` is significantly slower than `set_cell()`:

```gdscript
# SLOW - Causes major stutters
tilemap.set_cell_terrain_connect(0, pos, terrain_set, terrain_id)

# FAST - Use for interior tiles
tilemap.set_cell(0, pos, source_id, atlas_coords)

# HYBRID - Only use terrain_connect for edges
func _apply_tile(pos: Vector2i, is_edge: bool) -> void:
    if is_edge:
        tilemap.set_cell_terrain_connect(0, pos, terrain_set, terrain_id)
    else:
        tilemap.set_cell(0, pos, source_id, atlas_coords)
```

### Use Coordinate-Based Chunk Detection

O(1) coordinate check vs O(n) distance calculations:

```gdscript
# FAST - O(1)
func _get_player_chunk(player_pos: Vector2) -> Vector2i:
    return Vector2i(
        int(player_pos.x) / CHUNK_SIZE,
        int(player_pos.y) / CHUNK_SIZE
    )

func _should_load_chunk(chunk_coords: Vector2i, player_chunk: Vector2i) -> bool:
    var diff := (chunk_coords - player_chunk).abs()
    return diff.x <= LOAD_RADIUS and diff.y <= LOAD_RADIUS

# SLOW - O(n) where n = number of chunks
func _should_load_distance_based(chunk_coords: Vector2i, player_pos: Vector2) -> bool:
    var chunk_center := Vector2(chunk_coords) * CHUNK_SIZE + Vector2(CHUNK_SIZE/2, CHUNK_SIZE/2)
    return chunk_center.distance_to(player_pos) < LOAD_DISTANCE
```

### Chunk Hysteresis

Prevent chunk thrashing at boundaries:

```gdscript
const LOAD_RADIUS := 3
const UNLOAD_DISTANCE := 5  # Greater than load radius

# Chunk loads at radius 3, unloads at distance 5
# This prevents rapid load/unload when player is at boundary
```

---

## 7. Signals and Thread Communication

### Safe Signal Patterns

```gdscript
# Pattern 1: call_deferred for direct calls
func _in_thread():
    _on_complete.call_deferred(result)

func _on_complete(result):
    some_signal.emit(result)

# Pattern 2: CONNECT_DEFERRED flag
func _ready():
    some_signal.connect(_on_signal, CONNECT_DEFERRED)

# Pattern 3: Lambda wrapper
func _in_thread():
    call_deferred(func(): chunk_ready.emit(data))
```

### Avoiding Race Conditions

```gdscript
var _mutex := Mutex.new()
var _shared_data: Array = []

func _add_to_queue_thread_safe(data: Variant) -> void:
    _mutex.lock()
    _shared_data.append(data)
    _mutex.unlock()

func _get_from_queue_thread_safe() -> Variant:
    _mutex.lock()
    var result = _shared_data.pop_front() if _shared_data.size() > 0 else null
    _mutex.unlock()
    return result
```

---

## 8. GoDig-Specific Recommendations

### Current Architecture

GoDig uses a `DirtGrid` approach rather than TileMap for the underground. This may actually be advantageous for threading:

| Approach | Threading Difficulty |
|----------|---------------------|
| TileMap.set_cell() | Hard - main thread only |
| DirtBlock nodes | Medium - add_child deferred |
| Custom rendering | Easy - data + shader |

### Recommended Implementation for GoDig

1. **Generate chunk terrain data in WorkerThreadPool**
   - Noise sampling
   - Ore placement logic
   - Block type determination

2. **Store data in thread-safe queue**
   - Use Mutex for queue access
   - ChunkData class (RefCounted)

3. **Apply to grid incrementally on main thread**
   - MAX_BLOCKS_PER_FRAME = 30-50
   - Use call_deferred for DirtBlock instantiation

4. **Consider pre-generation buffer**
   - Generate chunks ahead of player movement
   - 2-3 chunk buffer in movement direction

### Performance Targets

| Metric | Target | Measurement |
|--------|--------|-------------|
| Chunk generation | < 50ms | WorkerThreadPool time |
| Chunk application | < 16ms total/frame | Spread across frames |
| Frame spikes | < 5ms | Profiler |
| Memory per chunk | < 100KB | sizeof(ChunkData) |

---

## 9. Troubleshooting

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| "Caller thread can't call this function" | Scene tree access from thread | Use call_deferred() |
| Crash on add_child | Adding node created in thread | Create node on main thread |
| Memory leak | Not calling wait_for_task_completion | Always wait for tasks |
| Visual glitches | TileMap modified from thread | Apply tiles via call_deferred |
| Frame stutter | Too many set_cell per frame | Limit tiles per frame |

### Debug Pattern

```gdscript
func _generate_chunk_debug(coords: Vector2i) -> void:
    var start_time := Time.get_ticks_msec()

    # Generation logic...

    var elapsed := Time.get_ticks_msec() - start_time
    print("Chunk %s generated in %dms" % [coords, elapsed])
```

---

## Sources

- [Godot Documentation - WorkerThreadPool](https://docs.godotengine.org/en/stable/classes/class_workerthreadpool.html)
- [Godot Documentation - Using Multiple Threads](https://docs.godotengine.org/en/stable/tutorials/performance/using_multiple_threads.html)
- [Threaded Chunks with Godot - Dennis Smuda](https://dennissmuda.com/blog/godot-chunk-loading-tutorial/)
- [Infinite TileMap with Godot 4 - Roger Clotet](https://clotet.dev/blog/infinite-tilemap-with-godot-4/)
- [Godot Forum - TileMap Chunking Discussion](https://forum.godotengine.org/t/godot-tilemap-chunking-is-this-impossible/66509)
- [Godot Forum - Chunking System Stutters](https://forum.godotengine.org/t/chunking-system-causing-stutters/66007)
- [GitHub - TileMap Performance Issue #31020](https://github.com/godotengine/godot/issues/31020)
- [Godot Asset Library - Chunk Manager](https://godotengine.org/asset-library/asset/3281)

## Related Implementation Tasks

- `DEV: Threaded chunk generation` - GoDig-dev-threaded-chunk-648dcec7
- `DEV: ChunkManager - load/unload around player` - (existing task)
