---
title: "implement: Touch screen action buttons"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T00:32:03.631279-06:00"
---

## Description

Create touch screen action buttons (Jump, Dig, Inventory) with multitouch support for mobile play. Buttons appear on the right side of the screen and map to input actions.

## Context

The core touch control system is implemented in `touch_controls.tscn`. Current state:
- VirtualJoystick on left side - DONE
- JumpButton, DigButton, InventoryButton - DONE (basic)
- ActionButton script with visual feedback - DONE

Remaining work is polish and integration testing.

## Affected Files

- `scenes/ui/touch_controls.tscn` - Button scene hierarchy (EXISTS)
- `scripts/ui/touch_controls.gd` - Touch control coordinator (EXISTS)
- `scripts/ui/action_button.gd` - Button behavior script (EXISTS)
- `scripts/player/player.gd` - Connect button signals to actions

## Implementation Notes

### Current Button Layout (Right Side)
```
ActionButtons (Control) - bottom-right anchor
├── JumpButton (80x80) at position (100, 80)
│   ├── JumpVisual (ColorRect - blue)
│   └── JumpLabel ("JUMP")
├── DigButton (80x80) at position (0, 80)
│   ├── DigVisual (ColorRect - orange)
│   └── DigLabel ("DIG")
└── InventoryButton (80x60) at position (100, 180)
    ├── InventoryVisual (ColorRect - green)
    └── InventoryLabel ("INV")
```

### Signal Flow
```
TouchScreenButton.pressed/released
    → ActionButton._on_pressed/_on_released (visual feedback)
    → TouchControls._on_*_pressed signals
    → Player.trigger_jump() / set_touch_direction()
```

### Remaining Polish Tasks

1. **Wire buttons to player** - Currently signals emit but may not be fully connected
2. **Add proper textures** - Replace ColorRect placeholders with icons
3. **Improve touch target sizes** - Ensure 80x80 minimum for easy tapping
4. **Add haptic feedback** (future) - Vibrate on press

### Connection to Player
```gdscript
# In main scene or level setup
func _ready():
    var touch_controls = $UI/TouchControls
    touch_controls.jump_pressed.connect(_on_jump)
    touch_controls.dig_pressed.connect(_on_dig)
    touch_controls.inventory_pressed.connect(_on_inventory)

func _on_jump():
    player.trigger_jump()

func _on_dig():
    # Dig in current facing direction
    player.try_dig()

func _on_inventory():
    # Toggle inventory panel
    inventory_panel.visible = !inventory_panel.visible
```

## Edge Cases

- Simultaneous button presses (multitouch) - handled by separate TouchScreenButton instances
- Button held during scene transition - release handled by Godot
- Desktop mode - buttons hidden via PlatformDetector

## Verify

- [ ] Build succeeds
- [ ] Touch controls visible on mobile/touch devices
- [ ] Touch controls hidden on desktop
- [ ] Jump button triggers player.trigger_jump()
- [ ] Dig button connects to dig action
- [ ] Inventory button toggles inventory panel
- [ ] Multitouch: Can move and jump simultaneously
- [ ] Visual feedback on button press (color change)
- [ ] Buttons positioned correctly in portrait mode
