---
title: "implement: Jump button (right side)"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-16T00:39:15.604801-06:00\""
closed-at: "2026-01-19T19:34:24.905392-06:00"
close-reason: Jump button in touch_controls.tscn
---

## Description

Add a touch-friendly jump button on the right side of the screen for mobile players.

## Context

Mobile players need a dedicated jump button since there's no spacebar. The button should be large enough for easy tapping during gameplay and positioned to avoid interfering with the dig area.

## Affected Files

- `scenes/ui/touch_controls.tscn` - Add jump button
- `scripts/ui/touch_controls.gd` - Handle jump button press
- `scripts/player/player.gd` - Connect to jump signal

## Implementation Notes

### Button Setup

Use Godot's TouchScreenButton or a regular Button with touch-friendly sizing.

```
TouchControls (CanvasLayer)
├─ VirtualJoystick (left side)
└─ JumpButton (TextureButton, right side)
    ├─ Normal texture (up arrow or "JUMP" icon)
    └─ Pressed texture (highlighted version)
```

### Touch Controls Script

```gdscript
# touch_controls.gd
extends Control

signal jump_pressed
signal jump_released

@onready var jump_button: Button = $JumpButton

func _ready() -> void:
    jump_button.button_down.connect(_on_jump_down)
    jump_button.button_up.connect(_on_jump_up)

func _on_jump_down() -> void:
    jump_pressed.emit()

func _on_jump_up() -> void:
    jump_released.emit()
```

### Player Integration

```gdscript
# player.gd
func _ready() -> void:
    var touch_controls = get_node_or_null("/root/Main/UI/TouchControls")
    if touch_controls:
        touch_controls.jump_pressed.connect(_on_jump_pressed)

func _on_jump_pressed() -> void:
    if can_jump():
        jump()
```

### Visual Design

- Size: 96x96px (large enough for comfortable tapping)
- Position: Bottom-right, ~80px from edges
- Style: Circular button with up-arrow or "^" icon
- Feedback: Slight scale down on press (0.9x)

### Positioning (Portrait 720x1280)

```
┌───────────────────────────────────┐
│                                   │
│         Game View                 │
│                                   │
├───────────────────────────────────┤
│                                   │
│  [Joystick]            [JUMP]     │  Bottom UI area
│                                   │
└───────────────────────────────────┘
```

## Verify

- [ ] Build succeeds
- [ ] Jump button visible at bottom-right on mobile
- [ ] Tapping button triggers player jump
- [ ] Button has visual feedback when pressed
- [ ] Works with multi-touch (can move + jump simultaneously)
- [ ] Button hidden on desktop (keyboard mode)
- [ ] Button sized appropriately for finger tapping
