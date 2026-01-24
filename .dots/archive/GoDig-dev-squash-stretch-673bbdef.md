---
title: "implement: Squash/stretch on landing"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-16T01:50:04.302752-06:00\""
closed-at: "2026-01-24T21:20:58.664174+00:00"
close-reason: Player has squash/stretch animation on landing in player.gd
---

Player squash on land, stretch on jump, and squash during mining. Classic animation principle for satisfying movement.

## Description

Apply squash and stretch to the player sprite to make movement feel bouncy and alive. This is a fundamental animation principle that adds significant "juice" to the game feel.

## Context

- Player sprite is AnimatedSprite2D at `$AnimatedSprite2D`
- Player has distinct states: IDLE, MOVING, MINING, FALLING, WALL_SLIDING, WALL_JUMPING
- Landing happens in `_land_on_grid()` function
- Wall-jump happens in `_do_wall_jump()` function
- See Docs/research/game-feel-juice.md for reference

## Affected Files

- `scripts/player/player.gd` - Add squash/stretch tween calls

## Implementation Notes

### Squash/Stretch Helper

```gdscript
# player.gd additions
var _scale_tween: Tween

func _squash_stretch(squash_scale: Vector2, stretch_scale: Vector2, squash_duration: float = 0.05, stretch_duration: float = 0.1) -> void:
    if _scale_tween:
        _scale_tween.kill()

    _scale_tween = create_tween()
    # Squash first
    _scale_tween.tween_property(sprite, "scale", squash_scale, squash_duration)
    # Then stretch/recover
    _scale_tween.tween_property(sprite, "scale", stretch_scale, stretch_duration)
    # Return to normal
    _scale_tween.tween_property(sprite, "scale", Vector2.ONE, 0.1)
```

### On Landing

```gdscript
func _land_on_grid(landing_grid: Vector2i) -> void:
    # ...existing code...
    # Squash on landing - wider and shorter
    _squash_stretch(
        Vector2(1.3, 0.7),  # Squash
        Vector2(1.0, 1.0),  # Return to normal
        0.05, 0.15
    )
```

### On Wall-Jump

```gdscript
func _do_wall_jump() -> void:
    # ...existing code...
    # Stretch during jump - taller and thinner
    _squash_stretch(
        Vector2(0.8, 1.2),  # Stretch up
        Vector2(1.0, 1.0),
        0.03, 0.2
    )
```

### On Mining Swing

```gdscript
func _start_mining(direction: Vector2i, target_block: Vector2i) -> void:
    # ...existing code...
    # Quick squash anticipation before swing
    if _scale_tween:
        _scale_tween.kill()
    _scale_tween = create_tween()
    _scale_tween.tween_property(sprite, "scale", Vector2(1.1, 0.9), 0.03)
    _scale_tween.tween_property(sprite, "scale", Vector2.ONE, 0.1)
```

### Animation Timing

| Action | Squash Scale | Stretch Scale | Squash Time | Stretch Time |
|--------|--------------|---------------|-------------|--------------|
| Land (short) | (1.2, 0.85) | (1.0, 1.0) | 0.04s | 0.12s |
| Land (long) | (1.35, 0.7) | (1.0, 1.0) | 0.05s | 0.15s |
| Wall-jump | (0.8, 1.2) | (1.0, 1.0) | 0.03s | 0.2s |
| Mining swing | (1.1, 0.9) | (1.0, 1.0) | 0.03s | 0.1s |
| Block break | (0.9, 1.1) | (1.0, 1.0) | 0.02s | 0.08s |

### Scale by Fall Distance

```gdscript
var _fall_start_y: float = 0.0

func _start_falling() -> void:
    current_state = State.FALLING
    velocity = Vector2.ZERO
    _fall_start_y = position.y

func _land_on_grid(landing_grid: Vector2i) -> void:
    var fall_distance := position.y - _fall_start_y
    var intensity := clamp(fall_distance / 500.0, 0.1, 1.0)

    var squash_x := 1.0 + (0.3 * intensity)  # 1.0 to 1.3
    var squash_y := 1.0 - (0.3 * intensity)  # 1.0 to 0.7

    _squash_stretch(
        Vector2(squash_x, squash_y),
        Vector2.ONE,
        0.03 + (0.02 * intensity),
        0.1 + (0.05 * intensity)
    )
    # ...rest of landing code...
```

## Verify

- [ ] Landing from any fall triggers visible squash
- [ ] Longer falls create more pronounced squash
- [ ] Wall-jumping shows stretch effect
- [ ] Mining shows slight anticipation squash
- [ ] Sprite returns smoothly to normal scale
- [ ] No jerky transitions when interrupting animations
- [ ] Squash/stretch is subtle, not cartoony
- [ ] Effects work with flipped sprite (left/right facing)
