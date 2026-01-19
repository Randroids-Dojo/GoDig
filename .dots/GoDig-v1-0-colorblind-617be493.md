---
title: "implement: Colorblind mode"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T01:48:58.412465-06:00"
---

## Description

Implement colorblind accessibility features so players with color vision deficiencies can distinguish ore types and UI elements. ~8% of men and ~0.5% of women are colorblind, making this a critical accessibility feature.

## Context

Ore colors (coal-black, copper-orange, iron-gray, silver-white, gold-yellow, ruby-red) may be difficult to distinguish for players with protanopia (red-blind), deuteranopia (green-blind), or tritanopia (blue-blind). This is a "basic" level accessibility feature per Game Accessibility Guidelines.

## Affected Files

- `scripts/autoload/settings_manager.gd` - NEW: Store colorblind mode preference
- `resources/ores/ore_data.gd` - MODIFY: Add symbol/pattern field
- `scripts/world/dirt_grid.gd` - MODIFY: Apply symbols when colorblind mode enabled
- `scenes/ui/settings_menu.tscn` - MODIFY: Add colorblind toggle
- `resources/sprites/ore_symbols.png` - NEW: Symbol overlay spritesheet

## Implementation Notes

### Colorblind Mode Options

1. **Off** (default) - Standard colors
2. **Symbols** - Add distinctive symbols to each ore type
3. **High Contrast** - Use patterns/textures instead of colors

### Symbol Assignments (unique shapes)

| Ore | Symbol |
|-----|--------|
| Coal | Circle (filled) |
| Copper | Triangle |
| Iron | Square |
| Silver | Diamond |
| Gold | Star |
| Ruby | Heart |

### Settings Storage

```gdscript
# settings_manager.gd
enum ColorblindMode { OFF, SYMBOLS, HIGH_CONTRAST }
var colorblind_mode: ColorblindMode = ColorblindMode.OFF
```

### Visual Implementation

When colorblind mode is enabled:
- Draw small symbol icon in center of ore block
- Symbol should be high-contrast (white with black outline)
- Symbol size: 32x32 pixels on 128x128 block

### Edge Cases

- Symbols must be visible at all zoom levels
- Symbols must not interfere with mining damage visual
- Settings persist across sessions
- Can be changed mid-game without restart

## Verify

- [ ] Build succeeds
- [ ] Colorblind mode toggle appears in settings
- [ ] Symbols mode shows distinct symbols on each ore type
- [ ] Symbols are visible and distinguishable
- [ ] Setting persists after app restart
- [ ] Works correctly with ore spawning in dirt_grid
