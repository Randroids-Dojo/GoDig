---
title: "implement: One-hand play option"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-16T01:48:59.311348-06:00\""
closed-at: "2026-01-19T19:35:08.572247-06:00"
close-reason: One-hand mode in settings_manager.gd
---

## Description

Implement a one-handed play mode that allows the game to be fully playable with a single hand (thumb). This supports players with limited mobility, temporary injuries, or those who prefer single-handed phone use.

## Context

One-handed mode is increasingly important for mobile games. Players may have only one hand available (holding coffee, on public transit, etc.) or have motor disabilities. Games like "Threes!" and "Way of the Passive Fist" have shown success with one-handed designs.

## Affected Files

- `scripts/autoload/settings_manager.gd` - MODIFY: Add one_hand_mode setting
- `scripts/ui/touch_controls.gd` - MODIFY: Alternate layout for one-hand mode
- `scenes/ui/touch_controls.tscn` - MODIFY: Repositionable UI elements
- `scenes/ui/settings_menu.tscn` - MODIFY: Add one-hand toggle and hand preference

## Implementation Notes

### One-Hand Mode Options

1. **Standard** (default) - Joystick left, buttons right (two-thumb design)
2. **Left Hand** - All controls on left side of screen
3. **Right Hand** - All controls on right side of screen

### Control Layout (One-Hand Mode)

```
Left Hand Mode:           Right Hand Mode:
+------------------+      +------------------+
|                  |      |                  |
|                  |      |                  |
|                  |      |                  |
| [D-pad]  [Jump]  |      |  [Jump]  [D-pad] |
| [Action]         |      |         [Action] |
+------------------+      +------------------+
```

### D-Pad Design for One-Hand

Replace joystick with compact D-pad:
- Four directional buttons in cross pattern
- Larger touch targets (minimum 44x44pt per Apple HIG)
- Well-spaced to prevent mis-taps

### Gesture Alternatives (Optional)

Consider adding gesture support:
- Swipe in direction to move
- Tap to dig/interact
- Long-press for jump

### Settings Storage

```gdscript
enum HandMode { STANDARD, LEFT_HAND, RIGHT_HAND }
var hand_mode: HandMode = HandMode.STANDARD
```

### Edge Cases

- Settings must persist across sessions
- Controls should remain responsive during mode switch
- All game actions must be accessible in one-hand mode
- Shop and pause menu must also be one-hand friendly

## Verify

- [ ] Build succeeds
- [ ] One-hand mode toggle appears in settings
- [ ] Left-hand mode places all controls on left
- [ ] Right-hand mode places all controls on right
- [ ] All game actions are accessible in one-hand mode
- [ ] Touch targets meet minimum 44x44pt size
- [ ] Setting persists after app restart
- [ ] Shop and menus are usable in one-hand mode
