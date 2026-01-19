---
title: "implement: Layer depth and hardness tests"
status: open
priority: 1
issue-type: task
created-at: "2026-01-18T23:33:00.696764-06:00"
---

## Description

Add PlayGodot tests verifying DataRegistry layer loading and depth-based hardness from the 3-4 Layer Types spec (GoDig-mvp-3-4-42c5e3a3).

## Context

The DataRegistry and LayerData resources exist and work, but the Verify criteria are not covered by tests. These tests ensure layer progression works correctly.

## Affected Files

- `tests/test_layers.py` - NEW: Layer-specific tests
- `tests/helpers.py` - MAY MODIFY: Add layer helper constants

## Implementation Notes

### Required Tests

1. **test_dataregistry_has_layers** - Verify layers array is populated
2. **test_topsoil_depth_range** - Topsoil.min_depth=0, check hardness at depth 25
3. **test_stone_depth_range** - Stone at depth 300 has higher hardness than topsoil
4. **test_layer_at_depth_returns_correct** - get_layer_at_depth(100) returns subsoil
5. **test_deep_stone_at_extreme_depth** - depth 600+ returns deep_stone

### PlayGodot Pattern

```python
@pytest.mark.asyncio
async def test_dataregistry_has_layers(game):
    layers_size = await game.call_method(PATHS['data_registry'], 
                                          'layers.size')
    assert layers_size >= 4, 'Should have at least 4 layer types'
```

### Expected Layer Data

| Layer | Depth Range | Base Hardness |
|-------|-------------|---------------|
| topsoil | 0-50m | 10-15 |
| subsoil | 50-200m | 15-25 |
| stone | 200-500m | 30-50 |
| deep_stone | 500m+ | 50-80 |

## Verify

- [ ] Build succeeds
- [ ] All 5 layer tests pass
- [ ] Hardness values match spec ranges
- [ ] CI workflow passes
