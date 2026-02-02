---
title: "implement: Guaranteed first ore within 3 blocks"
status: closed
priority: 0
issue-type: task
created-at: "\"\\\"2026-02-01T08:03:46.492895-06:00\\\"\""
closed-at: "2026-02-01T22:12:21.785630-06:00"
close-reason: Implemented guaranteed coal ore at (4, 9) - 3 blocks below spawn. Uses first_ore_spawned flag in SaveData.
---

Ensure new players discover their first ore within 30 seconds by guaranteeing ore spawns in the first few blocks.

## Description

New players MUST find their first ore quickly. This is the hook moment. Procedural generation should guarantee ore appears within the first 3 blocks of a new game.

## Context

From Session 9 research:
- 'First few minutes determine whether user stays or churns'
- First ore discovery anchors positive emotional memory
- Variable rewards work AFTER the player understands the reward exists
- Need to SHOW the reward quickly, then make it variable

## Implementation

### Ore Guarantee Logic

When generating chunks for a new game (first session only):
1. First block below surface: always dirt (teaches mining)
2. Second block: always dirt (builds rhythm)  
3. Third block: GUARANTEED coal ore
4. Subsequent blocks: normal procedural generation

### Code Approach

In chunk generation:
```gdscript
func _generate_tile(x: int, y: int, is_new_game: bool) -> BlockData:
    # Guarantee first ore for new games
    if is_new_game and y == 2 and x == player_start_x:  # 3rd block down
        return DataRegistry.get_block('coal')
    
    # Normal procedural generation
    return _procedural_tile(x, y)
```

Track in SaveManager:
```gdscript
var tutorial_ore_spawned: bool = false
```

### Visual Enhancement

The guaranteed first ore should:
- Have subtle shimmer effect (draws eye)
- Be coal (easiest to recognize as ore)
- Be directly below player spawn (no horizontal searching)

## Affected Files

- scripts/world/chunk_manager.gd - Ore guarantee logic
- scripts/world/tile_generator.gd - Special first-game handling
- scripts/autoload/save_manager.gd - Track tutorial_ore_spawned flag

## Verify

- [ ] New game: first ore appears within 3 blocks of spawn
- [ ] Ore is directly below spawn point (y=2 or y=3)
- [ ] Ore is coal (recognizable, not confusing)
- [ ] Existing saves not affected
- [ ] After first ore found, generation returns to normal
- [ ] Player discovers ore within 30 seconds of starting
- [ ] Time from game launch to first ore pickup < 30 seconds

## Dependencies

- None (this is foundational)

## Why P0

This is the FIRST dopamine hit in the game. If players dig for 60+ seconds without finding anything, they churn. The guaranteed ore shows them what they're looking for, then normal procedural generation adds variability.
