---
title: "research: Assess DirtGrid vs ChunkManager architecture for MVP"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-19T12:04:07.136450-06:00\""
closed-at: "2026-01-19T12:07:25.544736-06:00"
close-reason: "Assessed architectures: DirtGrid sufficient for MVP, ChunkManager deferred to v1.0. Created implementation task for DirtGrid persistence."
---

Current DirtGrid uses row-by-row generation with object pooling. Specs describe 16x16 chunk system (ChunkData, ChunkManager). Evaluate: Is chunk migration required for MVP? What are the trade-offs? Should we keep DirtGrid for MVP and add chunk system for v1.0?

## Research Findings

### Current DirtGrid Architecture

**Location**: `/Users/randroid/Documents/Dev/Godot/GoDig/scripts/world/dirt_grid.gd`

**How it works**:
- Row-by-row generation, not chunk-based
- Uses object pooling with ColorRect nodes (pre-allocates 100 DirtBlock instances)
- Generates ROWS_AHEAD (10) rows below player, cleans up ROWS_BEHIND (5) above
- Block size: 128x128 pixels
- Grid width: 5 blocks (GRID_WIDTH from GameManager)
- Ore spawning integrated via `_determine_ore_spawn()` using DataRegistry
- Emits `block_dropped` signal for mining drops
- Uses hash-based pseudo-noise for deterministic ore placement

**Strengths**:
1. Already working in TestLevel scene
2. Simple mental model (rows, not chunks)
3. Object pooling already implemented
4. Ore spawning integrated with DataRegistry
5. No threading complexity
6. Persistence could be added per-row

**Weaknesses**:
1. Horizontal constraints (fixed 5-block width)
2. No delta compression for persistence (would save every dug tile)
3. Not designed for horizontal expansion
4. Row-based cleanup less efficient than chunk-based for irregular digging patterns
5. No TileMap integration (uses individual ColorRect nodes)

### Proposed ChunkManager Architecture

**Status**: ChunkData resource exists at `/Users/randroid/Documents/Dev/Godot/GoDig/resources/world/chunk_data.gd`

**Specs in**:
- `GoDig-dev-chunk-data-0fe0f614.md`
- `GoDig-dev-chunkmanager-load-11c71de3.md`
- `GoDig-dev-16x16-chunk-113d78e6.md`

**How it would work**:
- 16x16 tile chunks
- 5x5 chunk area loaded around player (25 chunks max)
- Background threading for generation
- TileMap-based rendering
- Delta compression (only modified tiles saved)
- Coordinate conversion: world -> chunk -> local

**Strengths**:
1. Better for infinite worlds (horizontal expansion ready)
2. More efficient persistence (delta compression)
3. TileMap rendering is more performant than individual ColorRects
4. Background threading prevents frame stutters
5. Standard pattern used by many games

**Weaknesses**:
1. More complex implementation
2. ChunkManager not yet implemented
3. Requires threading (complexity, potential bugs)
4. TerrainGenerator dependency not yet built
5. Migration would break current TestLevel

### Key Questions Answered

**Q1: Is chunk migration required for MVP?**

**No.** The current DirtGrid is functional and the MVP scope is:
- Vertical digging only (no horizontal expansion needed)
- Fixed 5-block width matches portrait orientation
- Depth is the primary progression metric
- No complex horizontal navigation

For an MVP that focuses on "dig down, collect ore, sell, upgrade, repeat", the row-based system is sufficient.

**Q2: What are the trade-offs?**

| Aspect | DirtGrid (Current) | ChunkManager (Proposed) |
|--------|-------------------|------------------------|
| Implementation effort | 0 (done) | High (new system) |
| Persistence | Must add row tracking | Built-in delta compression |
| Performance | ColorRects (OK for 5 cols) | TileMap (better for large areas) |
| Threading | None needed | Required for smooth play |
| Horizontal growth | Would need rewrite | Ready for expansion |
| Save file size | Larger (all dug tiles) | Smaller (delta only) |
| Code complexity | Simple | More complex |

**Q3: Recommendation for MVP vs v1.0?**

### RECOMMENDATION: Hybrid Approach

**For MVP (Current Priority)**:
1. Keep DirtGrid for core gameplay
2. Add persistence layer to DirtGrid (track dug tiles per row, store via SaveManager)
3. This gets us a playable, saveable game quickly

**For v1.0 Enhancement**:
1. Implement ChunkManager as a replacement/upgrade
2. Migration path: convert saved row data to chunk format
3. Enable horizontal expansion, cave systems, etc.

### Implementation Tasks Created

Based on this research, the following should happen:

1. **DirtGrid Persistence** (MVP Priority) - Add tile modification tracking to DirtGrid that integrates with SaveManager's existing chunk interface. The SaveManager already has `save_chunk()` and `load_chunk()` methods ready.

2. **ChunkManager** (v1.0 Priority) - Keep existing specs, mark as v1.0 enhancement. The ChunkData resource is already implemented and correct.

3. **Migration Helper** (v1.0) - When implementing ChunkManager, include a migration tool to convert DirtGrid saves to chunk format.

## Decision

**Keep DirtGrid for MVP. Add persistence. Implement ChunkManager for v1.0.**

Rationale:
- MVP goal is a playable vertical loop, not architectural perfection
- DirtGrid works now; ChunkManager would delay MVP by 2-3 weeks
- SaveManager already has chunk persistence interface
- Clean migration path exists for v1.0
