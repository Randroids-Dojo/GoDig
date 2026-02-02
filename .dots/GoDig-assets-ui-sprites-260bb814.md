---
title: "implement: UI sprites (buttons, frames)"
status: open
priority: 3
issue-type: task
created-at: "2026-01-16T00:39:51.708683-06:00"
---

## Description

Create UI sprites for buttons, frames, and panels with mobile-friendly touch targets. Visual style should match the game's art direction.

## Context

Mobile games require larger touch targets (48px minimum). UI needs to be clear and readable on small screens. Current implementation uses Godot default theme. Custom sprites improve game feel and branding.

## Affected Files

- `assets/ui/buttons/` - NEW: Button sprite images
- `assets/ui/panels/` - NEW: Panel background sprites
- `assets/ui/icons/` - NEW: Icon sprites (pause, settings, etc.)
- `resources/themes/game_theme.tres` - NEW: Custom theme with sprites

## Implementation Notes

### Touch Target Requirements

- Minimum button size: 48x48 pixels
- Recommended button size: 64x64 pixels for primary actions
- Spacing between buttons: 8px minimum

### Button Types Needed

1. Primary action buttons (large, prominent)
   - Dig button
   - Jump button
   - Shop button
2. Secondary buttons (medium)
   - Settings, Pause, Close
3. Inventory slots (64x64 or 80x80)

### Panel/Frame Sprites

- Nine-patch sprites for scalable panels
- Inventory slot frame
- Shop panel background
- Tooltip frame
- Modal dialog frame

### Icons Needed

- Pause (||)
- Settings (gear)
- Close (X)
- Coin (for currency display)
- Heart (for HP display)
- Backpack (for inventory)

### Placeholder Approach (MVP)

For MVP, use Godot's default theme with:
- Custom button colors via theme overrides
- Simple rectangles with borders
- Text-based icons

## Verify

- [ ] All buttons are at least 48x48 pixels
- [ ] Buttons have clear pressed/normal/hover states
- [ ] Panel nine-patch scales without distortion
- [ ] Icons are readable at small sizes
- [ ] Theme applies consistently across all UI scenes
- [ ] No overlap between touch targets
