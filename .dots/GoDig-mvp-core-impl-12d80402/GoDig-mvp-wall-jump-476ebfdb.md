---
title: "implement: Wall-jump ability"
status: open
priority: 0
issue-type: task
created-at: "2026-01-16T00:34:23.291608-06:00"
---

## Description

Implement wall-jump as the core traversal mechanic for returning to the surface. This is available from game start (not an unlock) and is the primary way players escape deep shafts.

## Context

Wall-jump transforms "getting stuck" from game-over to a skill challenge. It creates satisfying gameplay where players feel clever escaping tight spots. This is essential for the dig-down mining game loop.

## Affected Files

- `scripts/player/player.gd` - Add wall detection, wall slide, wall jump states
- `scenes/player/player.tscn` - Add RayCast2D nodes for wall detection (left/right)

## Implementation Notes

### State Machine Extension

Add new states to the existing State enum:
```gdscript
enum State { IDLE, MOVING, MINING, WALL_SLIDING, WALL_JUMPING }
```

### Wall Detection

Add two RayCast2D nodes to player scene:
- `WallDetectLeft` - Points left, length ~16px (one tile)
- `WallDetectRight` - Points right, length ~16px

Use `is_colliding()` to detect adjacent walls.

### Wall Slide Behavior

When player is:
1. Not on floor
2. Falling (velocity.y > 0)
3. Pressing toward a detected wall
4. Adjacent to a wall (RayCast colliding)

Then:
- Reduce fall speed to `WALL_SLIDE_SPEED` (e.g., 50 pixels/sec)
- Play wall slide animation (optional for MVP)
- Allow wall jump input

### Wall Jump

When in wall slide state and jump is pressed:
1. Apply velocity away from wall: `velocity.x = WALL_JUMP_FORCE_X * wall_direction`
2. Apply upward velocity: `velocity.y = -WALL_JUMP_FORCE_Y`
3. Enter WALL_JUMPING state briefly to prevent immediate re-grab
4. `wall_direction` is -1 if on right wall, +1 if on left wall

### Constants

```gdscript
const WALL_SLIDE_SPEED: float = 50.0
const WALL_JUMP_FORCE_X: float = 200.0
const WALL_JUMP_FORCE_Y: float = 350.0
const WALL_JUMP_COOLDOWN: float = 0.2  # Prevent instant re-grab
```

### Integration with Grid Movement

Current player uses grid-based movement (tweened). Wall-jump needs physics-based movement during air time. Consider:
- Wall-jump only activates when player is falling (not grid-moving)
- After wall-jump, return to grid when landing
- Or: keep wall-jump as "break from grid" mechanic

### Touch Controls

Add jump button to touch controls (right side). Wall-jump triggers when:
- Jump button pressed while wall sliding

## Edge Cases

- Wall-jump should work on dug tunnel walls, not just solid rock
- Cannot wall-jump off the edge of the world
- Wall-jump should respect world boundaries

## Verify

- [ ] Build succeeds with no errors
- [ ] Player can wall-slide when falling next to a wall
- [ ] Wall slide reduces fall speed significantly
- [ ] Jump button during wall slide launches player away from wall
- [ ] Player can chain wall-jumps to ascend a shaft
- [ ] Wall-jump works with touch controls (jump button)
- [ ] Cannot wall-jump when no wall is adjacent
