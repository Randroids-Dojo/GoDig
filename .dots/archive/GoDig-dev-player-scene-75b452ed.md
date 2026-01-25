---
title: "DEV: Player scene (CharacterBody2D)"
status: closed
priority: 1
issue-type: task
created-at: "\"2026-01-16T00:38:04.464635-06:00\""
closed-at: "2026-01-24T21:18:54.737334+00:00"
close-reason: "Player.gd is a full CharacterBody2D with state machine: IDLE, MOVING, MINING, FALLING, WALL_SLIDING, WALL_JUMPING"
---

## Description

Create the Player scene with CharacterBody2D, grid-based movement, mining system, wall-jump, fall damage, and HP system. The player is 128x128 pixels (same size as one dirt block).

## Context

The player is the core gameplay entity. Must support:
- Grid-based movement on a 5-column grid
- Mining blocks by holding direction toward them
- Wall-jump for vertical traversal
- Fall damage for depth risk
- HP system with death handling
- Touch input (tap-to-dig, touch controls)

## Current Implementation Status

**ALREADY IMPLEMENTED** in `scripts/player/player.gd`:
- State machine: IDLE, MOVING, MINING, FALLING, WALL_SLIDING, WALL_JUMPING
- Grid-based movement with tween animation
- Mining with swing animation
- Wall-jump physics (grab, slide, jump away)
- Fall damage system (threshold: 3 blocks)
- HP system (take_damage, heal, die, revive)
- Tap-to-dig (tap/hold adjacent blocks to mine)
- Touch input integration (joystick direction, jump/dig buttons)
- Save/load for HP state

## Affected Files

- `scripts/player/player.gd` - Player controller script (IMPLEMENTED)
- Player scene embedded in `scenes/test_level.tscn` (not standalone scene)

## Scene Structure (in test_level.tscn)

```
Player (CharacterBody2D)
├── CollisionShape2D (120x120 RectangleShape2D)
├── AnimatedSprite2D (miner_animation.tres)
└── Camera2D (game_camera.gd)
```

## Implementation Notes

### Grid Constants
```gdscript
const BLOCK_SIZE := 128
const MOVE_DURATION := 0.15  # seconds per tile
```

### State Machine
```gdscript
enum State { IDLE, MOVING, MINING, FALLING, WALL_SLIDING, WALL_JUMPING }
```

### Signals
```gdscript
signal block_destroyed(grid_pos: Vector2i)
signal depth_changed(depth: int)
signal jump_pressed
signal hp_changed(current_hp: int, max_hp: int)
signal player_died(cause: String)
```

### Touch Input Interface
- `set_touch_direction(direction: Vector2i)` - Set movement direction from joystick
- `clear_touch_direction()` - Release direction
- `trigger_jump()` - Request wall-jump
- `trigger_dig()` / `stop_dig()` - Manual dig button

### Tap-to-Dig
- Tap adjacent block: Hit once
- Hold adjacent block (0.2s+): Continuous mining every 0.15s
- Only down, left, right (no digging up in MVP)

### HP System
- MAX_HP: 100
- Fall damage: (blocks - 3) * 10 damage (max 100)
- Low HP threshold: 25%
- Death triggers `player_died` signal

## Remaining Work

The player is largely implemented. Remaining items:
1. Extract Player scene to standalone `scenes/player/player.tscn` (optional refactor)
2. Add death animation in `play_death_animation()` method (currently just print)
3. Consider exposing player stats via PlayerData autoload

## Verify

- [ ] Build succeeds
- [ ] Player moves smoothly on 5-column grid
- [ ] Mining animation plays when hitting blocks
- [ ] Block destroyed after enough hits
- [ ] Player moves into destroyed block space
- [ ] Wall-slide activates when pressing toward wall while falling
- [ ] Wall-jump launches player away from wall
- [ ] Fall damage applied when falling more than 3 blocks
- [ ] HP reduces on damage, triggers death at 0
- [ ] Tap-to-dig works with touch and mouse
- [ ] Touch controls move player correctly
