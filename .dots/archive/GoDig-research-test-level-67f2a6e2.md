---
title: "research: Test level signal connection audit"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-01-19T11:05:24.193670-06:00\\\"\""
closed-at: "2026-01-19T11:06:13.126423-06:00"
close-reason: Found depth signal bug, created implementation task GoDig-implement-fix-depth-c590c480
---

## Description

Audit test_level.gd for missing signal connections to ensure all game systems are properly wired together.

## Findings

### Bug Found: Depth Signal Not Connected

In `scripts/test_level.gd`:
- Line 54 defines `_on_player_depth_changed(depth: int)` handler function
- This function updates the depth label and calls `GameManager.update_depth()`
- **BUG**: The function is NEVER connected to `player.depth_changed` signal in `_ready()`

In `scripts/player/player.gd`:
- Line 8 declares `signal depth_changed(depth: int)`
- Line 243 emits the signal in `_update_depth()` which is called after every move

**Impact**: The depth label in the HUD never updates as the player digs deeper. The GameManager depth tracking also never updates.

### Signal Audit Results

| Signal | Source | Handler | Connected? |
|--------|--------|---------|------------|
| `block_dropped` | dirt_grid | `_on_block_dropped` | Yes |
| `direction_pressed` | touch_controls | `player.set_touch_direction` | Yes |
| `direction_released` | touch_controls | `player.clear_touch_direction` | Yes |
| `jump_pressed` | touch_controls | `player.trigger_jump` | Yes |
| `dig_pressed` | touch_controls | `player.trigger_dig` | Yes |
| `dig_released` | touch_controls | `player.stop_dig` | Yes |
| `inventory_pressed` | touch_controls | `_on_inventory_pressed` | Yes |
| `coins_changed` | GameManager | `_on_coins_changed` | Yes |
| `hp_changed` | player | (via hud.connect_to_player) | Yes |
| `player_died` | player | `_on_player_died` | Yes |
| **`depth_changed`** | **player** | **`_on_player_depth_changed`** | **NO - BUG** |

## Recommendations

Create implementation task to fix the missing connection:

```gdscript
# In test_level.gd _ready(), add:
player.depth_changed.connect(_on_player_depth_changed)
```

This is a simple one-line fix that will enable depth tracking.
