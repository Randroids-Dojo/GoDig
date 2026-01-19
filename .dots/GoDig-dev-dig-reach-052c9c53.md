---
title: "implement: Dig reach validation"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T01:05:01.658029-06:00"
---

## Description

Validate that player can only mine blocks directly adjacent to their current position (within 1 tile). Prevents long-range digging exploits.

## Context

- Current mining system may not properly validate distance
- Players should only mine left, right, or down from current position
- Prevents "tunneling through walls" by clicking distant blocks
- Future tool upgrades could extend reach (v1.1 feature)

## Affected Files

- `scripts/player/player.gd` - Add reach validation in mining logic
- `scripts/world/dirt_grid.gd` - Add `can_reach_block()` helper

## Implementation Notes

### Reach Validation

```gdscript
# player.gd
const DIG_REACH: int = 1  # Tiles - future upgrade can increase

func can_dig_at(target: Vector2i) -> bool:
    # Calculate distance in tiles
    var distance := (target - grid_position).abs()

    # Must be within reach (including diagonals = sqrt(2) ~ 1.41)
    if distance.x > DIG_REACH or distance.y > DIG_REACH:
        return false

    # Must not be diagonal (only cardinal directions allowed)
    if distance.x > 0 and distance.y > 0:
        return false

    # Cannot dig upward (unless drill upgrade)
    if target.y < grid_position.y and not has_drill_upgrade():
        return false

    return true

func _try_move_or_mine(direction: Vector2i) -> void:
    var target := grid_position + direction

    if not can_dig_at(target):
        # Show feedback (optional)
        return

    # ... rest of existing logic
```

### Direction Restrictions

| Direction | Allowed | Notes |
|-----------|---------|-------|
| Down (0, 1) | Yes | Primary digging direction |
| Left (-1, 0) | Yes | Horizontal expansion |
| Right (1, 0) | Yes | Horizontal expansion |
| Up (0, -1) | No* | Requires Drill upgrade |
| Diagonal | No | Never allowed |

*Up direction unlocked with Drill tool upgrade at Equipment Shop

### Visual Feedback (Optional)

Show which blocks can be mined:

```gdscript
func _update_dig_preview() -> void:
    # Highlight mineable blocks when holding dig button
    for dir in [Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
        var target := grid_position + dir
        if can_dig_at(target) and dirt_grid.has_block(target):
            _highlight_block(target, Color.GREEN)
```

### Future: Extended Reach Tool

```gdscript
# Reserved for v1.1
func get_dig_reach() -> int:
    if PlayerData.has_equipment("extended_pickaxe"):
        return 2  # Can dig 2 tiles away
    return DIG_REACH
```

## Edge Cases

- Player at world edge: Check bounds before reach validation
- Block already destroyed: Return early, no validation needed
- Player in air/falling: Prevent mining while falling
- Multiple input directions: Only process one at a time

## Verify

- [ ] Build succeeds
- [ ] Can mine block directly below player
- [ ] Can mine block directly left of player
- [ ] Can mine block directly right of player
- [ ] Cannot mine block diagonally adjacent
- [ ] Cannot mine block 2+ tiles away
- [ ] Cannot mine upward without drill upgrade
- [ ] Cannot mine while falling
- [ ] No errors when attempting invalid dig
