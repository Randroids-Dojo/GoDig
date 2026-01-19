---
title: "implement: BlockData resource class"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T00:43:21.060619-06:00"
---

## Description

NOTE: This overlaps significantly with LayerData. Evaluate whether a separate BlockData class is needed or if LayerData suffices.

The original intent was hardness values per block type. Currently LayerData handles hardness per underground layer (topsoil, subsoil, stone, etc.).

## Current State

LayerData already provides:
- `base_hardness` per layer
- `get_hardness_at(grid_pos)` with variance
- Visual identity (colors)

## When BlockData Might Be Needed

A separate BlockData class could be useful if:
1. Individual block variants within a layer have different properties (e.g., clay pockets in topsoil)
2. Special blocks need unique behavior (lava, water, bedrock)
3. Blocks need properties beyond what LayerData provides

## Recommendation

Do NOT create a separate BlockData class for MVP. LayerData + OreData covers the use cases.

Consider this spec **complete via LayerData** unless special block types are added (lava, water, etc.) that need unique resource definitions.

## Affected Files

If implemented in future:
- `resources/blocks/block_data.gd` - NEW
- `resources/blocks/*.tres` - NEW block definitions
- `scripts/world/dirt_block.gd` - Update to use BlockData if present

## Verify

- [x] LayerData handles hardness per depth zone
- [x] OreData handles ore-specific hardness
- [ ] Decision: Is BlockData needed beyond LayerData?
