---
title: "implement: Chunk cleanup (unload distant)"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T00:59:08.600546-06:00"
after:
  - GoDig-dev-chunkmanager-load-11c71de3
---

## Description

NOTE: This functionality is already specified in `GoDig-dev-chunkmanager-load-11c71de3` (ChunkManager spec). See `_unload_chunk()` and `UNLOAD_RADIUS` in that spec.

This dot documents the cleanup behavior for reference.

## Already Specified in ChunkManager

The ChunkManager spec includes:
- `UNLOAD_RADIUS := 3` - Unload chunks more than 3 chunks away
- `_unload_chunk(chunk_coord)` - Removes tiles, saves modifications, emits signal
- Unloading happens in `_update_loaded_chunks()` when player moves

## Cleanup Behavior

1. Player moves to new chunk
2. `_update_loaded_chunks()` iterates all loaded chunks
3. Any chunk with distance > UNLOAD_RADIUS is unloaded
4. Before unloading:
   - Check if chunk has modifications (`chunk_data.has_modifications()`)
   - If modified, save to SaveManager
5. Clear tiles from TileMap
6. Remove from `loaded_chunks` dictionary
7. Emit `chunk_unloaded` signal

## Key Constants

```gdscript
const LOAD_RADIUS := 2   # 5x5 area = load within 2 chunks
const UNLOAD_RADIUS := 3 # Unload at 3+ chunks away
```

UNLOAD_RADIUS > LOAD_RADIUS prevents thrashing (loading/unloading same chunk repeatedly).

## Verify

- [ ] ChunkManager spec includes unload logic
- [ ] Modified chunks are saved before unload
- [ ] TileMap tiles are cleared on unload
- [ ] No memory leak (chunks properly removed from dictionary)
- [ ] chunk_unloaded signal is emitted
