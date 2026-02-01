---
title: "implement: One-hand friendly HUD layout"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T08:10:43.223380-06:00"
---

Reposition HUD elements for one-handed mobile play based on Subway Thumb grip research.

## Context
Research shows 49-75% of mobile users operate one-handed. 59% disengage if controls are uncomfortable. The 'Subway Thumb' grip (holding phone with same hand used for input) is the most casual and common grip.

## Description
Audit and reposition all HUD elements to green/yellow zones (thumb-reachable areas):
- Quick-buy ladder button: bottom-right corner (green zone)
- Inventory panel trigger: bottom center (green zone)
- Shop access: bottom of screen (green zone)
- Depth indicator: top-center (info only, no interaction needed)
- Pause/settings: top-right (infrequent access acceptable)

## Affected Files
- scenes/ui/hud.tscn - Layout changes
- scripts/ui/hud.gd - Button positioning logic
- scenes/ui/quick_buy_panel.tscn - Panel positioning
- themes/hud_theme.tres - Touch target sizing

## Implementation Notes
- Minimum touch target: 44x44 pixels (Apple HIG)
- Consider left-handed mode (mirror layout)
- Test with actual thumb-reach patterns
- Flyout menus from bottom instead of full-page

## Verify
- [ ] All frequently-used buttons are in bottom 2/3 of screen
- [ ] Quick-buy is within easy thumb reach
- [ ] Touch targets are minimum 44x44px
- [ ] Can complete full game loop one-handed
- [ ] No critical actions require top corners
