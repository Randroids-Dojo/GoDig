---
title: "implement: Keyboard input fallback"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-16T01:07:56.192586-06:00\""
closed-at: "2026-01-19T19:34:38.730304-06:00"
close-reason: Keyboard input in player.gd
---

## Description

Add keyboard controls for desktop testing and non-touch devices. Hide touch UI when keyboard is detected.

## Context

Development happens on desktop where touch simulation is awkward. Keyboard fallback makes testing faster and supports potential desktop release.

## Affected Files

- `scripts/player/player.gd` - Add keyboard input handling
- `scripts/autoload/platform_detector.gd` - Detect input method
- `project.godot` - Define input actions

## Implementation Notes

### Input Actions (project.godot)

```ini
[input]

move_left={
"deadzone": 0.5,
"events": [Object(InputEventKey, keycode=4194319, ...), Object(InputEventKey, keycode=65, ...)]
}
move_right={
"deadzone": 0.5,
"events": [Object(InputEventKey, keycode=4194321, ...), Object(InputEventKey, keycode=68, ...)]
}
move_up={
"deadzone": 0.5,
"events": [Object(InputEventKey, keycode=4194320, ...), Object(InputEventKey, keycode=87, ...)]
}
move_down={
"deadzone": 0.5,
"events": [Object(InputEventKey, keycode=4194322, ...), Object(InputEventKey, keycode=83, ...)]
}
jump={
"deadzone": 0.5,
"events": [Object(InputEventKey, keycode=32, ...)]
}
interact={
"deadzone": 0.5,
"events": [Object(InputEventKey, keycode=69, ...)]
}
dig={
"deadzone": 0.5,
"events": [Object(InputEventKey, keycode=32, ...), Object(InputEventMouseButton, button_index=1, ...)]
}
```

### Key Mappings

| Action | Primary | Secondary |
|--------|---------|-----------|
| Move Left | A | Left Arrow |
| Move Right | D | Right Arrow |
| Move Up | W | Up Arrow |
| Move Down | S | Down Arrow |
| Jump | Space | - |
| Interact | E | - |
| Dig | Space (while adjacent) | Left Click |
| Pause | Escape | - |

### Player Input Handling

```gdscript
# player.gd
func _process(delta: float) -> void:
    if not PlatformDetector.is_touch_device():
        _handle_keyboard_input()

func _handle_keyboard_input() -> void:
    var input_dir := Vector2.ZERO
    input_dir.x = Input.get_axis("move_left", "move_right")
    input_dir.y = Input.get_axis("move_up", "move_down")

    if input_dir != Vector2.ZERO:
        move_direction = input_dir.normalized()
    else:
        move_direction = Vector2.ZERO

    if Input.is_action_just_pressed("jump"):
        if can_jump():
            jump()

    if Input.is_action_just_pressed("interact"):
        try_interact()
```

### Mouse Click to Dig (Desktop)

```gdscript
func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            var grid_pos := world_to_grid(get_global_mouse_position())
            if _is_adjacent(grid_pos):
                dig_at(grid_pos)
```

### Platform Detection

```gdscript
# platform_detector.gd
signal input_method_changed(is_touch: bool)

var _last_input_was_touch: bool = false

func _input(event: InputEvent) -> void:
    var is_touch := event is InputEventScreenTouch or event is InputEventScreenDrag
    if is_touch != _last_input_was_touch:
        _last_input_was_touch = is_touch
        input_method_changed.emit(is_touch)
```

### Touch UI Visibility

```gdscript
# touch_controls.gd
func _ready() -> void:
    PlatformDetector.input_method_changed.connect(_on_input_method_changed)
    visible = PlatformDetector.is_touch_device()

func _on_input_method_changed(is_touch: bool) -> void:
    visible = is_touch
```

## Verify

- [ ] Build succeeds
- [ ] WASD/Arrow keys move player
- [ ] Space triggers jump
- [ ] E triggers interaction when near interactable
- [ ] Left click on adjacent block digs it
- [ ] Touch UI hides when keyboard used
- [ ] Touch UI shows when touch detected
- [ ] Escape opens pause menu
