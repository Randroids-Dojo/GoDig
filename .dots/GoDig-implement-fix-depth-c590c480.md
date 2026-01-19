---
title: "implement: Fix depth signal connection bug"
status: open
priority: 0
issue-type: task
created-at: "2026-01-19T11:05:55.637320-06:00"
---

## Description

BUG FIX: The depth display in the HUD never updates as the player digs deeper because the signal connection is missing.

## Context

Found during signal connection audit (GoDig-research-test-level-67f2a6e2). The handler function exists but is never connected to the player's signal.

## Affected Files

- `scripts/test_level.gd` - Add missing signal connection

## Implementation Notes

Add this line in `_ready()` after the touch controls setup (around line 35):

```gdscript
# Connect depth tracking
player.depth_changed.connect(_on_player_depth_changed)
```

The handler function `_on_player_depth_changed(depth: int)` already exists at line 54 and correctly:
1. Updates the depth label text
2. Calls `GameManager.update_depth(depth)`

## Verify

- [ ] Build succeeds
- [ ] Depth label updates when player moves down
- [ ] Depth label updates when player moves up
- [ ] GameManager.current_depth is correct
- [ ] Depth resets to 0 when player returns to surface (row 7 or above)
