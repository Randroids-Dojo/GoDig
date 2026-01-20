---
title: "implement: 16x16 chunk configuration"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-16T00:51:32.572362-06:00\""
closed-at: "2026-01-19T19:34:24.921600-06:00"
close-reason: CHUNK_SIZE = 16 in dirt_grid.gd
---

## Description

Configure the chunk system to use 16x16 tiles per chunk. This is the optimal size for mobile performance based on research (see GoDig-blocker-chunk-size-865f9942).

## Context

Chunk size affects:
- Memory usage per chunk
- Generation speed
- Loading/unloading frequency
- Save file size

16x16 was chosen as the balance point:
- 8x8: Too small (frequent loading, overhead)
- 32x32: Too large (memory spikes on mobile)
- 16x16: Good balance (256 tiles, manageable memory)

## Affected Files

- `scripts/autoload/game_manager.gd` - Define CHUNK_SIZE constant
- `scripts/world/chunk_manager.gd` - Use CHUNK_SIZE for calculations
- `scripts/world/chunk.gd` - Generate CHUNK_SIZE x CHUNK_SIZE blocks
- `scripts/autoload/save_manager.gd` - Chunk serialization uses CHUNK_SIZE

## Implementation Notes

### GameManager Constants

```gdscript
# game_manager.gd
const CHUNK_SIZE: int = 16  # 16x16 tiles per chunk
const TILE_SIZE: int = 128  # Pixels per tile (player is 128x128)
const CHUNK_SIZE_PX: int = CHUNK_SIZE * TILE_SIZE  # 2048 pixels
```

### Chunk Coordinate Math

```gdscript
# Convert world position to chunk coordinates
func world_to_chunk(world_pos: Vector2) -> Vector2i:
    return Vector2i(
        int(floor(world_pos.x / CHUNK_SIZE_PX)),
        int(floor(world_pos.y / CHUNK_SIZE_PX))
    )

# Convert chunk coords to world position (top-left corner)
func chunk_to_world(chunk_pos: Vector2i) -> Vector2:
    return Vector2(
        chunk_pos.x * CHUNK_SIZE_PX,
        chunk_pos.y * CHUNK_SIZE_PX
    )

# Convert world position to local tile within chunk
func world_to_local_tile(world_pos: Vector2, chunk_pos: Vector2i) -> Vector2i:
    var chunk_origin := chunk_to_world(chunk_pos)
    var local_pos := world_pos - chunk_origin
    return Vector2i(
        int(local_pos.x / TILE_SIZE),
        int(local_pos.y / TILE_SIZE)
    )
```

### Chunk Generation

```gdscript
# chunk.gd
func generate() -> void:
    blocks.clear()

    for local_y in range(GameManager.CHUNK_SIZE):
        for local_x in range(GameManager.CHUNK_SIZE):
            var world_tile := Vector2i(
                chunk_position.x * GameManager.CHUNK_SIZE + local_x,
                chunk_position.y * GameManager.CHUNK_SIZE + local_y
            )
            _generate_tile(world_tile, Vector2i(local_x, local_y))
```

### Memory Estimation

Per chunk (16x16 = 256 tiles):
- Block data: ~64 bytes per tile = 16KB per chunk
- Render: One TileMap layer or 256 sprites
- With 9 chunks loaded (3x3 around player): ~144KB block data

This is comfortable for mobile devices with 2GB+ RAM.

### Load Radius

With 16x16 chunks (2048px per chunk) and a 720x1280 viewport:
- Horizontal: 720px = ~0.35 chunks visible
- Vertical: 1280px = ~0.63 chunks visible
- Recommended load radius: 1 chunk in each direction (3x3 = 9 chunks total)

```gdscript
# chunk_manager.gd
const LOAD_RADIUS: int = 1  # Load chunks within 1 chunk of player
const UNLOAD_RADIUS: int = 2  # Unload chunks 2+ chunks away
```

## Edge Cases

- Player on chunk boundary: All adjacent chunks should be loaded
- Fast player movement: May need larger load radius or predictive loading
- Vertical bias: Player moves vertically more than horizontally, consider asymmetric radius

## Verify

- [ ] Build succeeds
- [ ] CHUNK_SIZE = 16 in GameManager
- [ ] Chunks generate 16x16 tiles correctly
- [ ] World-to-chunk coordinate conversion is correct
- [ ] Chunk boundaries align properly (no gaps or overlaps)
- [ ] Memory usage is acceptable on target device
- [ ] Loading/unloading happens at correct distances
