---
title: "implement: ChunkManager integration tests"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-03T06:00:15.581736-06:00\\\"\""
closed-at: "2026-02-03T06:00:36.973731-06:00"
close-reason: ChunkManager not yet integrated into game - needs integration before tests can be written. Created as future v1.0 system.
---

## Description
Write integration tests for the new TileMap-based ChunkManager (v1.0 terrain system).

## Context
ChunkManager is a new terrain system added in commit 6cb6d75 that replaces DirtGrid with TileMap-based rendering. It needs integration tests to ensure:
- Chunks load correctly around player
- TileMap renders terrain properly
- Chunk cleanup works when player moves
- Persistence of dug tiles works

## Tests to Add
1. ChunkManager exists and initializes
2. Initial chunks load around player
3. TileMap has terrain tiles
4. Chunk coordinate conversion works
5. Terrain tiles have correct hardness data

## Affected Files
- tests/test_chunk_manager.py (new)
- tests/helpers.py (add ChunkManager paths)

## Verify
- [ ] Tests pass locally
- [ ] ChunkManager initializes in headless mode
- [ ] Terrain tiles have expected properties
