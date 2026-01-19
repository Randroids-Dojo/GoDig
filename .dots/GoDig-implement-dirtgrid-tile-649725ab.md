---
title: "implement: DirtGrid tile persistence for save/load"
status: open
priority: 1
issue-type: task
created-at: "2026-01-19T12:07:08.803843-06:00"
---

Add dug tile tracking to DirtGrid that integrates with SaveManager.

## Description

Track which tiles have been dug in DirtGrid and persist them via SaveManager's existing chunk interface. When loading a save, restore dug tiles so player's mine shaft is preserved.

## Context

DirtGrid currently regenerates rows from scratch with no memory of player changes. For MVP, we need to save the player's progress (dug tiles). SaveManager already has save_chunk/load_chunk methods ready.

## Affected Files

- scripts/world/dirt_grid.gd - Add _dug_tiles Dictionary, track on hit_block
- scripts/autoload/save_manager.gd - Already has chunk persistence (may need row-based variant)

## Implementation Notes

### DirtGrid Changes

```gdscript
# Track dug tiles: Dictionary[Vector2i, bool]
var _dug_tiles: Dictionary = {}

# In hit_block, when block is destroyed:
func hit_block(pos: Vector2i, tool_damage: float = -1.0) -> bool:
    # ... existing code ...
    if destroyed:
        _dug_tiles[pos] = true  # Mark as dug
        # Signal for persistence
        # ...
    return destroyed

# On initialize, load dug tiles from SaveManager
func initialize(player: Node2D, surface_row: int) -> void:
    _player = player
    _lowest_generated_row = surface_row
    _load_dug_tiles()  # NEW
    for row in range(surface_row, surface_row + ROWS_AHEAD):
        _generate_row(row)

# Skip spawning blocks that were already dug
func _generate_row(row: int) -> void:
    for col in range(GameManager.GRID_WIDTH):
        var pos := Vector2i(col, row)
        if _dug_tiles.has(pos):
            continue  # Skip dug tiles
        if not _active.has(pos):
            _acquire(pos)
            _determine_ore_spawn(pos)
```

### SaveManager Integration

Option A: Use existing chunk interface with row-based grouping
Option B: Add dedicated dug_tiles persistence (simpler for row-based system)

Recommend Option B:
```gdscript
# save_manager.gd additions
func save_dug_tiles(tiles: Dictionary) -> bool
func load_dug_tiles() -> Dictionary
```

## Edge Cases

- Very deep mines: May have many dug tiles; consider saving only modified rows
- Row cleanup: When rows are cleaned up, dug_tiles entries persist for reload
- New game: Must clear dug_tiles for fresh start

## Verify

- [ ] Build succeeds
- [ ] Digging a tile marks it in _dug_tiles
- [ ] Saving game persists dug tiles
- [ ] Loading game restores dug tiles (mined shaft visible)
- [ ] New game starts with empty dug_tiles
- [ ] Deep mines (100+ rows) perform acceptably
