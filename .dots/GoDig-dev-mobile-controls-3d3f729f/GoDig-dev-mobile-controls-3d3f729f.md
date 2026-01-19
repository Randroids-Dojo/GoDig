---
title: "DEV: Mobile Controls System"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T00:31:53.863236-06:00"
---

Epic for touch controls implementation based on mobile-controls.md

## Status

**LARGELY IMPLEMENTED**

Completed subtasks:
- [x] GoDig-dev-touch-screen-96b93949: Touch screen action buttons (jump, dig, inventory)
- [x] (in player.gd) Tap-to-dig system

Open subtasks:
- [ ] GoDig-dev-tap-to-c2325d86: Tap-to-dig spec (STATUS: ALREADY IMPLEMENTED in player.gd lines 500-635)

## Implemented Files

- `scenes/ui/touch_controls.tscn` - Button layout with VirtualJoystick
- `scripts/ui/touch_controls.gd` - Signal coordinator
- `scripts/ui/virtual_joystick.gd` - Joystick movement handling
- `scripts/ui/action_button.gd` - Button visual feedback
- `scripts/player/player.gd` - Touch input integration (tap-to-dig, direction, jump)

## Remaining Work

- [ ] Virtual joystick spec (GoDig-dev-virtual-joystick-345757be) - may already be implemented
- [ ] Replace ColorRect placeholders with proper button textures
- [ ] Haptic feedback (v1.0 polish task)
