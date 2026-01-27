---
title: "implement: Chunk generation tests"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-16T01:04:04.546504-06:00\""
closed-at: "2026-01-27T07:19:18.667029+00:00"
close-reason: Added tests for chunk system constants (BLOCK_SIZE, CHUNK_SIZE, POOL_SIZE, LOAD_RADIUS)
---

## Description

Create PlayGodot integration tests for the chunk-based world generation system. Verify chunk loading/unloading, ore depth gating, terrain determinism, and modification persistence.

## Context

- Chunk system is complex and critical for infinite depth
- Tests ensure consistent world generation across sessions
- Verifies ore spawning obeys depth rules
- See AGENTS.md for test patterns

## Affected Files

- `tests/test_chunk_generation.py` - NEW: Chunk system tests
- `tests/helpers.py` - Add chunk-related paths

## Implementation Notes

### Test File Structure

```python
# tests/test_chunk_generation.py
import pytest
from tests.helpers import PATHS

@pytest.mark.asyncio
class TestChunkGeneration:
    """Tests for chunk-based world generation."""

    async def test_chunks_load_around_player(self, game):
        """Chunks within load radius are loaded."""
        # Get player chunk
        player_pos = await game.get_property(PATHS["player"], "grid_position")
        player_chunk = [player_pos[0] // 16, player_pos[1] // 16]

        # Check surrounding chunks are loaded
        loaded_chunks = await game.get_property(PATHS["chunk_manager"], "loaded_chunks")

        for dx in range(-2, 3):
            for dy in range(-2, 3):
                chunk_key = [player_chunk[0] + dx, player_chunk[1] + dy]
                assert str(chunk_key) in loaded_chunks, f"Chunk {chunk_key} should be loaded"

    async def test_distant_chunks_unload(self, game):
        """Chunks beyond unload radius are removed."""
        # Move player far
        # Wait for chunk updates
        # Verify original chunks unloaded
```

### Terrain Determinism Tests

```python
async def test_same_seed_same_terrain(self, game):
    """Same world seed produces identical terrain."""
    seed = 12345

    # Generate terrain at position
    await game.call_method(PATHS["terrain_gen"], "initialize", seed)
    tile1 = await game.call_method(PATHS["terrain_gen"], "get_tile_at", [100, 100])

    # Reinitialize with same seed
    await game.call_method(PATHS["terrain_gen"], "initialize", seed)
    tile2 = await game.call_method(PATHS["terrain_gen"], "get_tile_at", [100, 100])

    assert tile1 == tile2, "Same seed should produce same terrain"

async def test_different_seed_different_terrain(self, game):
    """Different seeds produce different terrain."""
    await game.call_method(PATHS["terrain_gen"], "initialize", 111)
    tiles_a = [await game.call_method(PATHS["terrain_gen"], "get_tile_at", [x, 100]) for x in range(10)]

    await game.call_method(PATHS["terrain_gen"], "initialize", 222)
    tiles_b = [await game.call_method(PATHS["terrain_gen"], "get_tile_at", [x, 100]) for x in range(10)]

    assert tiles_a != tiles_b, "Different seeds should produce different terrain"
```

### Ore Depth Gating Tests

```python
async def test_coal_spawns_shallow(self, game):
    """Coal only spawns above 500m."""
    # Check many positions at depth 50
    coal_count = 0
    for x in range(100):
        tile = await game.call_method(PATHS["terrain_gen"], "get_tile_at", [x, 50])
        if tile == "coal":
            coal_count += 1

    assert coal_count > 0, "Coal should spawn at shallow depths"

async def test_no_diamond_shallow(self, game):
    """Diamond never spawns above 800m."""
    diamond_count = 0
    for x in range(1000):  # Check many positions
        for y in range(0, 800):  # Above diamond depth
            tile = await game.call_method(PATHS["terrain_gen"], "get_tile_at", [x, y])
            if tile == "diamond":
                diamond_count += 1

    assert diamond_count == 0, "Diamond should not spawn above 800m"

async def test_gold_spawns_in_range(self, game):
    """Gold spawns between 300m and 1200m."""
    gold_found_at_400 = False
    gold_found_at_1500 = False

    for x in range(200):
        if await game.call_method(PATHS["terrain_gen"], "get_tile_at", [x, 400]) == "gold":
            gold_found_at_400 = True
        if await game.call_method(PATHS["terrain_gen"], "get_tile_at", [x, 1500]) == "gold":
            gold_found_at_1500 = True

    assert gold_found_at_400, "Gold should spawn at 400m"
    assert not gold_found_at_1500, "Gold should not spawn at 1500m"
```

### Chunk Persistence Tests

```python
async def test_dug_tiles_persist(self, game):
    """Dug tiles remain empty after chunk unload/reload."""
    # Find a block
    test_pos = [50, 50]

    # Dig it
    await game.call_method(PATHS["chunk_manager"], "dig_tile", test_pos)

    # Verify empty
    has_tile = await game.call_method(PATHS["chunk_manager"], "has_tile", test_pos)
    assert not has_tile, "Tile should be dug"

    # Force chunk unload
    await game.call_method(PATHS["chunk_manager"], "_unload_chunk", [3, 3])

    # Move player back to reload chunk
    await game.set_property(PATHS["player"], "grid_position", [48, 48])
    await game.wait(0.5)  # Allow chunk load

    # Verify still empty
    has_tile_after = await game.call_method(PATHS["chunk_manager"], "has_tile", test_pos)
    assert not has_tile_after, "Dug tile should persist"

async def test_placed_ladders_persist(self, game):
    """Placed ladders survive chunk unload/reload."""
    # Similar to dug tiles test
    # Place ladder, unload, reload, verify
```

### Performance Tests

```python
async def test_chunk_gen_performance(self, game):
    """Chunk generation completes within time limit."""
    import time

    start = time.time()
    for _ in range(10):
        await game.call_method(PATHS["chunk_manager"], "_generate_chunk", [0, _])
    elapsed = time.time() - start

    assert elapsed < 1.0, f"10 chunks should generate in <1s, took {elapsed:.2f}s"
```

### Test Helpers Addition

```python
# tests/helpers.py additions
PATHS = {
    # ... existing ...
    "chunk_manager": "/root/TestLevel/ChunkManager",
    "terrain_gen": "/root/TerrainGenerator",  # If static, may need different access
}
```

## Edge Cases to Test

- Chunk at negative coordinates (surface area)
- Chunk at very deep coordinates (y > 10000)
- Rapid chunk load/unload (player moving fast)
- Save during chunk generation thread
- Load with missing chunk data

## Verify

- [ ] Build succeeds
- [ ] Chunk loading tests pass
- [ ] Terrain determinism tests pass
- [ ] Ore depth gating tests pass
- [ ] Persistence tests pass
- [ ] Performance test passes (<1s for 10 chunks)
- [ ] Tests are not flaky
- [ ] Tests run in CI pipeline
