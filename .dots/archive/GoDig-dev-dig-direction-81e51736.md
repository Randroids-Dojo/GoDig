---
title: "implement: Dig direction restriction"
status: closed
priority: 1
issue-type: task
created-at: "\"2026-01-16T01:05:01.654798-06:00\""
closed-at: "2026-01-19T11:25:55.683913-06:00"
close-reason: Already done - documented in spec
---

## Status: ALREADY IMPLEMENTED

The dig direction restriction is already in place in `scripts/player/player.gd`:

```gdscript
func _get_input_direction() -> Vector2i:
    # Check touch controls first
    if touch_direction != Vector2i.ZERO:
        return touch_direction

    # Fall back to keyboard input
    if Input.is_action_pressed("move_down"):
        return Vector2i(0, 1)
    elif Input.is_action_pressed("move_left"):
        return Vector2i(-1, 0)
    elif Input.is_action_pressed("move_right"):
        return Vector2i(1, 0)
    return Vector2i.ZERO
```

The function explicitly only returns:
- Down: Vector2i(0, 1)
- Left: Vector2i(-1, 0)
- Right: Vector2i(1, 0)
- Zero (no input)

There is NO handling for "move_up" input. Player cannot dig upward.

## Verify

- [x] Player can dig down
- [x] Player can dig left
- [x] Player can dig right
- [x] Player cannot dig upward (no input for this)
