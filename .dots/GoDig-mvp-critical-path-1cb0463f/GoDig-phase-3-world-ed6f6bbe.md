---
title: "research: World Generation"
status: closed
priority: 0
issue-type: task
created-at: "\"2026-01-16T00:41:37.178137-06:00\""
closed-at: "2026-01-19T10:01:58.801372-06:00"
close-reason: "Expanded 5 implementation specs with complete details: ore integration, layer selection, layer visuals, hybrid ore gen, surface chunks"
---

## Summary

World generation research is complete. All implementation specs have been expanded with detailed guidance.

## Completed Research

### Chunk System
- 16x16 tile chunks for optimal mobile performance
- 5x5 chunk area (25 chunks max) loaded around player
- Background threading for stutter-free generation
- Priority: chunks below player loaded first (digging direction)
- Implementation spec: `GoDig-dev-chunkmanager-load-11c71de3`

### Layer Generation (4 types implemented)
- **Topsoil** (0-50m): Brown, easy digging, coal/copper
- **Subsoil** (50-200m): Dark brown/clay, medium difficulty
- **Stone** (200-500m): Gray, hard digging, caves begin
- **Deep Stone** (500m+): Dark gray/granite, very hard

Layer features:
- Transition zones with gradual color blending
- Background darkens with depth
- Layer entry notifications
- Implementation specs: `GoDig-dev-layer-selection-57bd2ca9`, `GoDig-dev-layer-visual-1b50e3c1`

### Ore Generation (6 types defined)
- **Coal**: Depth 0-500m, threshold 0.75, vein size 3-8
- **Copper**: Depth 10-300m, threshold 0.78, vein size 2-6
- **Iron**: Depth 50-600m, threshold 0.82, vein size 2-5
- **Silver**: Depth 200-800m, threshold 0.88, vein size 2-4
- **Gold**: Depth 300-1000m, threshold 0.92, vein size 1-3
- **Diamond**: Depth 800m+, threshold 0.97, vein size 1-2

Generation approach: Hybrid noise + random walk
- Noise determines density zones (where ore CAN spawn)
- Random walk creates vein shapes (satisfying clusters)
- Rarest ores checked first to preserve valuable finds
- Implementation specs: `GoDig-dev-integrate-ores-3f8b9c4b`, `GoDig-dev-vein-expansion-3cb3cd9f`, `GoDig-dev-hybrid-ore-90c9e92f`

### Noise Configuration
- TerrainGenerator uses FastNoiseLite
- World seed from SaveManager for determinism
- Separate noise per ore type (different frequencies)
- Cave noise starts at depth 200m
- Implementation spec: `GoDig-dev-noise-based-3afe498c`

### Surface System
- Endless horizontal expansion with chunk-based loading
- Building slots at regular intervals
- Mine entrance at world x=0
- Implementation spec: `GoDig-dev-surface-chunk-a12c2b46`

## Implementation Spec Status

All world generation specs expanded with:
- Complete code examples
- Affected file lists
- Edge case handling
- Verification checklists

| Spec | Status |
|------|--------|
| ChunkManager | Complete (detailed) |
| TerrainGenerator (noise) | Complete (detailed) |
| Ore integration | Expanded this session |
| Vein expansion | Complete (detailed) |
| Layer selection | Expanded this session |
| Layer visuals | Expanded this session |
| Hybrid ore gen | Expanded this session |
| Surface chunks | Expanded this session |

## Dependencies

World generation depends on:
- TileTypes enum (existing)
- DataRegistry (existing, loads LayerData/OreData)
- SaveManager world_seed (existing)
- GameManager constants (existing)

## Questions Resolved

- Chunk size: 16x16 (mobile optimized)
- Layer count: 4 for MVP (topsoil, subsoil, stone, deep_stone)
- Ore count: 6 for MVP (coal, copper, iron, silver, gold, diamond)
- Cave generation: Start at depth 200m, noise-based
- Vein approach: Hybrid (noise zones + random walk shapes)

## Future Considerations (v1.0+)

- Crystal Caves layer (1000-2000m)
- Magma Zone layer (2000-5000m)
- Void Depths layer (5000m+)
- Horizontal biomes within layers
- Gems as separate spawning system
