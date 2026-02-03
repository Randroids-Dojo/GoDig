# DirtGrid vs ChunkManager Architecture Assessment

## Overview

This research assesses whether GoDig should migrate from the current DirtGrid implementation to a ChunkManager architecture for MVP, or defer chunk migration to v1.0.

## Current State

### DirtGrid (Current Implementation)

The current `dirt_grid.gd` is a **hybrid system** that already incorporates many chunk-based concepts:

**Architecture:**
- Uses 16x16 tile chunks (CHUNK_SIZE = 16)
- Object pooling with 400-block pool
- 2-chunk load radius (5x5 grid = 25 chunks loaded)
- Chunk-based loading/unloading around player
- Chunk-based persistence (dirty chunk tracking)
- Deterministic ore generation using position-based seeds

**Key Features:**
- `_loaded_chunks: Dictionary` - tracks loaded chunks
- `_dirty_chunks: Dictionary` - tracks chunks with unsaved changes
- `_world_to_chunk()` / `_grid_to_chunk()` - coordinate conversion
- `_generate_chunk()` / `_unload_chunk()` - chunk lifecycle
- `_load_chunk_dug_tiles()` / `_save_chunk_dug_tiles()` - persistence
- Ore vein expansion with cluster algorithm
- Cave generation with noise
- Near-ore hint system
- Fossil and traversal item drops

**What It's Missing:**
- TileMap integration (uses ColorRect blocks)
- Background threading for generation
- Formal ChunkData resource usage

### ChunkData (Prepared Resource)

The `chunk_data.gd` resource class is already implemented with:
- 16x16 chunk size constant
- Coordinate conversion utilities
- Modified tile tracking (delta compression)
- Placed object tracking
- Serialization (to_dict/from_dict)
- Generation state tracking

### ChunkManager (Specified but Not Implemented)

The ChunkManager spec in `.dots/archive/GoDig-dev-chunkmanager-load-11c71de3.md` describes:
- TileMap-based rendering
- Background threading for generation
- Mutex-protected generation queue
- Batch tile application (100 tiles/frame limit)
- TerrainGenerator delegation

## Analysis

### What DirtGrid Already Does Well

| Feature | Status | Notes |
|---------|--------|-------|
| Chunk-based loading | Implemented | 5x5 grid around player |
| Chunk-based persistence | Implemented | Dirty chunk tracking |
| Object pooling | Implemented | 400-block pool |
| Ore generation | Implemented | Noise + vein expansion |
| Cave generation | Implemented | Noise-based |
| Visual effects | Implemented | Sparkles, borders, hints |
| Coordinate systems | Implemented | Grid/chunk/world conversions |

### What ChunkManager Would Add

| Feature | Benefit | MVP Necessity |
|---------|---------|---------------|
| TileMap rendering | Better performance, auto-culling | Nice-to-have |
| Background threading | No frame stutters | Nice-to-have |
| ChunkData integration | Cleaner architecture | Nice-to-have |
| TerrainGenerator | Separation of concerns | Nice-to-have |

### Trade-offs

**Arguments for Migrating to ChunkManager for MVP:**

1. **TileMap Performance**: Godot's TileMap has built-in culling and batching that could improve performance over ColorRect blocks
2. **Cleaner Architecture**: Separation between ChunkManager and TerrainGenerator
3. **Future-proofing**: Easier to add horizontal biomes, special caves
4. **Threading**: Background generation prevents frame stutters

**Arguments for Keeping DirtGrid for MVP:**

1. **It Works**: DirtGrid already implements the core chunk system correctly
2. **Risk**: Migration introduces new bugs with no functional gain
3. **Time**: MVP timeline is better served by polish, not refactoring
4. **Incremental**: Can migrate chunk-by-chunk after MVP
5. **Performance is Fine**: Object pooling and chunk loading already prevent issues

### Performance Comparison

**DirtGrid (Current):**
- ~400 ColorRect nodes in pool
- 25 chunks loaded = ~6400 potential blocks max
- Object pool prevents allocation churn
- No threading = generation happens on main thread
- Typical chunk generation: <1ms for small chunks, <10ms for full chunks

**ChunkManager (Proposed):**
- TileMap with atlas coords
- Background threading
- Batch application (100 tiles/frame)
- Typical chunk generation: offloaded to background thread

For MVP scope (simple visuals, no complex shaders), the performance difference is likely negligible on target devices.

### Functional Analysis

Both systems would support MVP requirements:
- [x] Grid-based digging
- [x] Ore spawning with depth gating
- [x] Cave generation
- [x] Chunk persistence
- [x] Object pooling
- [x] Infinite depth

The **ChunkManager spec is actually implemented inside DirtGrid**, just not using TileMap or threading. The naming is confusing, but functionally DirtGrid is already a chunk manager.

## Recommendation

### For MVP: Keep DirtGrid

**Rationale:**
1. DirtGrid already implements chunk-based architecture
2. It's working and tested
3. Migration adds risk without functional benefit
4. MVP time is better spent on gameplay polish

### For v1.0: Consider Partial Migration

If performance profiling reveals issues:
1. Add background threading to DirtGrid's chunk generation
2. Consider TileMap migration only if draw calls become problematic
3. Use ChunkData resource for cleaner persistence

### Specific Migration Path

If migration becomes necessary:

**Phase 1 (Low-risk):**
- Add optional background threading to DirtGrid's `_generate_chunk()`
- Keep everything else the same

**Phase 2 (Medium-risk):**
- Replace ColorRect blocks with TileMap
- Update visual effects to work with TileMap
- Keep chunk logic unchanged

**Phase 3 (High-risk):**
- Full ChunkManager refactor
- Separate TerrainGenerator
- Only if horizontal expansion requires it

## Decision Matrix

| Factor | Keep DirtGrid | Migrate to ChunkManager |
|--------|--------------|-------------------------|
| MVP Timeline | Faster | Slower |
| Risk | Lower | Higher |
| Performance | Adequate | Potentially better |
| Architecture | Good enough | Cleaner |
| Future expansion | Minor refactor later | Ready now |

**Verdict: Keep DirtGrid for MVP, evaluate migration for v1.0 based on profiling data.**

## Implementation Notes

### If Threading is Needed

Add threading to DirtGrid without full migration:

```gdscript
# Add to dirt_grid.gd
var _gen_thread: Thread = null
var _gen_mutex: Mutex = Mutex.new()
var _gen_queue: Array[Vector2i] = []
var _gen_complete: Array[Vector2i] = []

func _generate_chunks_around(center_chunk: Vector2i) -> void:
    for x in range(center_chunk.x - LOAD_RADIUS, center_chunk.x + LOAD_RADIUS + 1):
        for y in range(center_chunk.y - LOAD_RADIUS, center_chunk.y + LOAD_RADIUS + 1):
            var chunk_pos := Vector2i(x, y)
            if not _loaded_chunks.has(chunk_pos):
                _queue_chunk_generation(chunk_pos)

func _queue_chunk_generation(chunk_pos: Vector2i) -> void:
    _gen_mutex.lock()
    if chunk_pos not in _gen_queue:
        _gen_queue.append(chunk_pos)
    _gen_mutex.unlock()
    _start_gen_thread_if_needed()
```

### If TileMap is Needed

Keep DirtGrid's chunk logic, just swap rendering:

```gdscript
# Replace ColorRect creation with TileMap cells
func _acquire(grid_pos: Vector2i) -> void:
    var tile_type := _get_tile_type_for_pos(grid_pos)
    var atlas_coord := _get_atlas_coord(tile_type)
    _tilemap.set_cell(0, grid_pos, 0, atlas_coord)
    _active[grid_pos] = tile_type

func _release(grid_pos: Vector2i) -> void:
    _tilemap.erase_cell(0, grid_pos)
    _active.erase(grid_pos)
```

## Conclusion

The DirtGrid vs ChunkManager dichotomy is somewhat misleading. DirtGrid **is** a chunk manager - it just:
1. Uses ColorRect instead of TileMap
2. Generates on main thread instead of background
3. Doesn't use the ChunkData resource class

For MVP, these differences don't matter functionally. The recommendation is to **keep DirtGrid** and only migrate specific components (threading, rendering) if profiling data justifies the effort.

The ChunkData resource can still be used for cleaner persistence if desired, but even the current string-key dictionary approach works fine for MVP scope.

## Action Items

1. **Close this research task** - Decision made: Keep DirtGrid for MVP
2. **Update ChunkManager task** - Mark as v1.0 scope, not MVP-blocking
3. **Create profiling task** - Add mobile profiling to v1.0 roadmap
4. **Document decision** - Note in DEVELOPMENT_ROADMAP.md that DirtGrid is the chunk system
