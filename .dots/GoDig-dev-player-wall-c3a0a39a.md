---
title: "implement: Player wall-jump ability"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T00:38:04.471213-06:00"
---

## Description

Implement wall-jump ability for the player character. This is the primary traversal mechanic that prevents players from getting stuck and enables vertical navigation without consumables. Player can grab walls during falling and jump off them.

## Context

Wall-jump is already partially implemented in `player.gd` with these states:
- `State.WALL_SLIDING` - Slow descent while pressed against wall
- `State.WALL_JUMPING` - Horizontal leap away from wall

The core mechanic exists, but needs refinement and testing. Key design decisions:
- Wall-jump is available from game start (core mechanic, not unlock)
- Can only grab walls while falling and pressing toward the wall
- Jump sends player away from wall with upward momentum
- Cooldown prevents instant re-grab

## Affected Files

- `scripts/player/player.gd` - Existing implementation to refine
- `scripts/ui/touch_controls.gd` - Jump button triggers wall-jump

## Implementation Notes

### Current Implementation (in player.gd)

```gdscript
# Constants
const WALL_SLIDE_SPEED: float = 50.0
const WALL_JUMP_FORCE_X: float = 200.0
const WALL_JUMP_FORCE_Y: float = 450.0
const WALL_JUMP_COOLDOWN: float = 0.2

# State tracking
var _wall_direction: int = 0  # -1 = left wall, 1 = right wall
var _wall_jump_timer: float = 0.0
```

### Wall Detection

```gdscript
func _update_wall_direction() -> void:
    _wall_direction = 0
    if dirt_grid == null:
        return

    var current_grid := _world_to_grid(position)

    # Check left wall
    var left_pos := current_grid + Vector2i(-1, 0)
    if left_pos.x >= 0 and dirt_grid.has_block(left_pos):
        _wall_direction = -1
        return

    # Check right wall
    var right_pos := current_grid + Vector2i(1, 0)
    if right_pos.x < GameManager.GRID_WIDTH and dirt_grid.has_block(right_pos):
        _wall_direction = 1
```

### Wall Grab Conditions

To grab a wall:
1. Player must be falling (velocity.y > 0)
2. Wall must exist adjacent to player
3. Player must be pressing toward the wall
4. Cooldown must have expired (prevents instant re-grab)

```gdscript
func _handle_falling(delta: float) -> void:
    velocity.y += GRAVITY * delta
    _update_wall_direction()

    if _wall_direction != 0 and _wall_jump_timer <= 0:
        var input_dir := _get_input_direction()
        if (input_dir.x < 0 and _wall_direction == -1) or \
           (input_dir.x > 0 and _wall_direction == 1):
            _start_wall_slide()
            return
```

### Wall Slide State

```gdscript
func _handle_wall_sliding(delta: float) -> void:
    velocity.y = WALL_SLIDE_SPEED  # Slow descent
    position.y += velocity.y * delta

    _update_wall_direction()

    # Release if wall disappears
    if _wall_direction == 0:
        current_state = State.FALLING
        return

    # Jump off wall
    if _check_jump_input():
        _do_wall_jump()
        return

    # Release if stop pressing toward wall
    var input_dir := _get_input_direction()
    var pressing_toward := (input_dir.x < 0 and _wall_direction == -1) or \
                          (input_dir.x > 0 and _wall_direction == 1)
    if not pressing_toward:
        current_state = State.FALLING
        return

    _check_landing()
```

### Wall Jump Execution

```gdscript
func _do_wall_jump() -> void:
    current_state = State.WALL_JUMPING
    _wall_jump_timer = WALL_JUMP_COOLDOWN

    # Jump away from wall
    velocity.x = WALL_JUMP_FORCE_X * (-_wall_direction)
    velocity.y = -WALL_JUMP_FORCE_Y

    # Face jump direction
    sprite.flip_h = (_wall_direction > 0)
```

### Potential Refinements

1. **Visual feedback**: Dust particles when grabbing wall
2. **Audio feedback**: Scrape sound while sliding
3. **Animation**: Wall-slide sprite, wall-jump launch sprite
4. **Stamina**: Limit wall-slide duration (v1.0 feature?)
5. **Tuning**: Adjust WALL_JUMP_FORCE values for feel

## Edge Cases

- Wall disappears while sliding (dug out): Transition to FALLING
- Hit ceiling during wall-jump: Stop upward velocity
- Wall at world edge: Use world bounds check
- Multiple walls (corner): Prioritize left check first
- Land during wall-slide: Snap to grid, return to IDLE

## Verify

- [ ] Build succeeds with no errors
- [ ] Player can grab wall by pressing toward it while falling
- [ ] Wall-slide slows descent (not instant fall)
- [ ] Pressing jump while wall-sliding launches player away
- [ ] Cooldown prevents immediate re-grab after wall-jump
- [ ] Releasing direction key releases wall grab
- [ ] Player faces correct direction after wall-jump
- [ ] Works with both keyboard and touch controls
