---
title: "research: Block/tile size documentation inconsistency"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-01-19T11:08:52.321588-06:00\\\"\""
closed-at: "2026-01-19T11:09:17.485887-06:00"
close-reason: Analyzed tile size confusion - documentation refers to art assets (16px), implementation uses screen blocks (128px). No fix needed, just documentation clarity.
---

## Description

Documentation and implementation have different block sizes. This needs clarification.

## Findings

### Documentation (Docs/GAME_DESIGN_SUMMARY.md)

> "Grid-Based Digging: 16x16 pixel tiles (player-sized)"

> "Chunk size: 16x16 tiles (optimal for mobile)"

### Implementation

- `GameManager.BLOCK_SIZE = 128` (128x128 pixels)
- `ChunkData` uses 16x16 tiles per chunk
- Player moves in 128px increments

### Analysis

The documentation appears to use "16x16" to refer to two different things:
1. **Pixel art tile size** - Sprites are 16x16 pixels (or scaled up)
2. **Chunk dimensions** - 16x16 blocks per chunk

The implementation uses 128x128 pixel blocks because:
- 720px viewport width / 5 blocks = 144px (rounded to 128)
- This gives comfortable mobile touch targets
- 16x16 pixel art scaled 8x = 128x128 display size

### Conclusion

This is likely intentional - the design doc refers to art asset size (16x16 px sprites) which are then scaled up for the 720x1280 mobile display. The chunk system uses 16x16 *blocks* (not pixels).

## Recommendations

No code changes needed. Consider updating GAME_DESIGN_SUMMARY.md to clarify:
- "16x16 pixel art tiles, displayed at 128x128 for mobile screens"
- "Chunks are 16x16 blocks (each block is 128x128 pixels on screen)"
