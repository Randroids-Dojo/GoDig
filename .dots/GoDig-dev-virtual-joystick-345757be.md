---
title: "implement: Virtual joystick (left side)"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T00:39:15.599486-06:00"
---

## Description

Implement a fixed-position virtual joystick on the left side of the screen for player movement on mobile devices.

## Context

Mobile players need touch-based movement. A fixed joystick (always visible in same spot) is easier to use than a dynamic one (appears where you touch) for this type of game where quick repositioning matters.

## Affected Files

- `scenes/ui/touch_controls.tscn` - Add joystick node
- `scripts/ui/virtual_joystick.gd` - NEW: Joystick input handling
- `scripts/player/player.gd` - Read joystick input for movement

## Implementation Notes

### Joystick Structure

```
VirtualJoystick (Control)
├─ Base (TextureRect) - The circular background
├─ Knob (TextureRect) - The draggable inner circle
└─ CollisionShape/Area - Touch detection zone
```

### Joystick Script

```gdscript
extends Control

signal joystick_input(direction: Vector2)

@export var dead_zone: float = 0.2
@export var max_radius: float = 64.0

@onready var base: TextureRect = $Base
@onready var knob: TextureRect = $Knob

var _is_pressed: bool = false
var _touch_index: int = -1
var _center: Vector2

func _ready() -> void:
    _center = base.size / 2

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and _is_inside_base(event.position):
            _is_pressed = true
            _touch_index = event.index
            _update_knob(event.position)
        elif not event.pressed and event.index == _touch_index:
            _release()
    elif event is InputEventScreenDrag:
        if event.index == _touch_index:
            _update_knob(event.position)

func _update_knob(touch_pos: Vector2) -> void:
    var local_pos = touch_pos - global_position - _center
    var distance = local_pos.length()
    var clamped = local_pos.limit_length(max_radius)

    knob.position = _center + clamped - knob.size / 2

    var direction = clamped / max_radius
    if direction.length() < dead_zone:
        direction = Vector2.ZERO

    joystick_input.emit(direction)

func _release() -> void:
    _is_pressed = false
    _touch_index = -1
    knob.position = _center - knob.size / 2
    joystick_input.emit(Vector2.ZERO)
```

### Visual Design

- Base: 128x128px semi-transparent circle
- Knob: 64x64px opaque circle
- Position: Bottom-left, ~80px from edges
- Opacity: ~60% when idle, 100% when touched

### Integration with Player

```gdscript
# player.gd
@onready var joystick: Control = $"../UI/TouchControls/VirtualJoystick"

func _ready() -> void:
    if joystick:
        joystick.joystick_input.connect(_on_joystick_input)

func _on_joystick_input(direction: Vector2) -> void:
    move_direction = direction
```

## Verify

- [ ] Build succeeds
- [ ] Joystick appears at bottom-left on mobile
- [ ] Touching inside base starts tracking
- [ ] Knob follows finger within max_radius
- [ ] Releasing returns knob to center
- [ ] Dead zone prevents accidental small movements
- [ ] Player moves in direction of joystick
- [ ] Joystick hidden on desktop (keyboard mode)
