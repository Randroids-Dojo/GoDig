---
title: "implement: Block hardness data resource"
status: closed
priority: 2
issue-type: task
created-at: "2026-01-16T00:37:43.116244-06:00"
close-reason: Implemented via LayerData base_hardness, DataRegistry.get_block_hardness(), and DirtBlock using it in activate()
---

## Description

NOTE: This functionality already exists via LayerData. This spec documents what exists and may be marked complete.

LayerData (resources/layers/layer_data.gd) provides `base_hardness` per layer with variance via `get_hardness_at(grid_pos)`. DataRegistry.get_block_hardness() uses this to return hardness for any grid position.

## Already Implemented

- `LayerData.gd` - `base_hardness` field and `get_hardness_at()` method with +/-10% variance
- `DataRegistry.gd` - `get_block_hardness(grid_pos)` returns hardness based on depth/layer
- `DirtBlock.gd` - Uses DataRegistry.get_block_hardness() in `activate()`

## Layer Hardness Values (Current)

| Layer | Depth Range | Base Hardness |
|-------|-------------|---------------|
| Topsoil | 0-50 | 10.0 |
| Subsoil | 50-200 | 25.0 |
| Stone | 200-500 | 40.0 |
| Deep Stone | 500+ | 60.0 |

## Remaining Work

Consider if additional block types need hardness (e.g., ore blocks). Currently OreData has `hardness` field but it's not used in DirtBlock - DirtBlock only uses layer hardness.

## Verify

- [x] LayerData.gd has base_hardness field
- [x] get_hardness_at() returns varied hardness per position
- [x] DataRegistry.get_block_hardness() works
- [x] DirtBlock uses hardness from DataRegistry
- [ ] Consider: Should ore hardness override layer hardness?
