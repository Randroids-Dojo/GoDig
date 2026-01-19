---
title: "implement: Use ore hardness in DirtBlock"
status: open
priority: 2
issue-type: task
created-at: "2026-01-18T23:46:41.221165-06:00"
---

DirtBlock.activate() should check if position has ore in _ore_map and add OreData.hardness to the block's max_health. Currently ore hardness is defined but unused.

## Description

Ore blocks should be harder to mine than regular dirt. Each OreData has a hardness value that should increase the block's health, making rare ores require more hits to break.

## Context

- OreData.hardness exists (coal=2, gold=5, etc.) but is never used
- DirtBlock.activate() only uses layer hardness from DataRegistry
- Ore blocks take same hits as dirt at same depth - not ideal for game feel

## Affected Files

- `scripts/world/dirt_grid.gd` - Pass ore hardness to block on activation
- `scripts/world/dirt_block.gd` - Accept ore hardness parameter in activate()

## Implementation Notes

### Option A: DirtGrid passes hardness bonus

```gdscript
# dirt_grid.gd
func _acquire(grid_pos: Vector2i) -> ColorRect:
    # ...existing code...
    block.activate(grid_pos)

    # Apply ore hardness bonus if this block has ore
    if _ore_map.has(grid_pos):
        var ore = DataRegistry.get_ore(_ore_map[grid_pos])
        if ore:
            block.apply_ore_hardness(ore.hardness)

    _active[grid_pos] = block
    return block

# dirt_block.gd
func apply_ore_hardness(ore_hardness: float) -> void:
    max_health += ore_hardness
    current_health = max_health
```

### Option B: DirtBlock queries ore map (requires reference)

Pass ore_id to activate() and let DirtBlock handle it:

```gdscript
# dirt_block.gd
func activate(pos: Vector2i, ore_id: String = "") -> void:
    # ...existing code...

    if not ore_id.is_empty():
        var ore = DataRegistry.get_ore(ore_id)
        if ore:
            max_health += ore.hardness
            current_health = max_health
```

Option A is cleaner since DirtBlock doesn't need to know about DataRegistry.

### Hardness Values (Current)

From ore .tres files:
- coal: hardness = 2
- copper: hardness = 3
- iron: hardness = 4
- silver: hardness = 4
- gold: hardness = 5
- ruby: hardness = 6 (assumed, check file)

## Verify

- [ ] Coal blocks take more hits than dirt at same depth
- [ ] Gold blocks take more hits than coal blocks
- [ ] Block visual darkening still works correctly with higher health
- [ ] No performance impact (ore lookup is O(1) dictionary access)
