---
title: "implement: Text size options"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-16T01:49:00.290494-06:00\""
closed-at: "2026-01-19T19:35:08.581801-06:00"
close-reason: Text size in settings_manager.gd
---

## Description

Implement adjustable text size settings to support players with low vision. After remapping, text size is one of the most commonly complained about accessibility issues. The game should support standard and accessibility-level text sizes.

## Context

Apple's Dynamic Type supports sizes from small to "accessibility extra-extra-extra-large". WCAG recommends text be resizable up to 200% without loss of function. Text size issues affect not just players with visual impairments but also older players and those playing in bright sunlight.

## Affected Files

- `scripts/autoload/settings_manager.gd` - MODIFY: Add text_size setting
- `resources/themes/game_theme.tres` - MODIFY: Define font size presets
- `scripts/ui/ui_scaler.gd` - NEW: Apply text scaling to UI elements
- `scenes/ui/settings_menu.tscn` - MODIFY: Add text size slider/buttons

## Implementation Notes

### Text Size Levels

| Level | Name | Scale | Use Case |
|-------|------|-------|----------|
| 1 | Small | 0.85x | Compact displays |
| 2 | Default | 1.0x | Standard size |
| 3 | Large | 1.25x | Slight vision issues |
| 4 | Extra Large | 1.5x | Low vision |
| 5 | Maximum | 2.0x | Severe vision issues |

### Base Font Sizes (at 1.0x)

| Element | Base Size |
|---------|-----------|
| Body text | 24px |
| Headers | 32px |
| HUD numbers | 28px |
| Button labels | 24px |
| Small labels | 18px |

### Implementation Approach

1. Use Godot Theme system with font size overrides
2. Create UI_SCALE constant that multiplies all font sizes
3. Apply scaling on settings change via signal

```gdscript
# settings_manager.gd
signal text_size_changed(scale: float)

const TEXT_SCALES := [0.85, 1.0, 1.25, 1.5, 2.0]
var text_size_level: int = 1  # Default index

func get_text_scale() -> float:
    return TEXT_SCALES[text_size_level]
```

### UI Adaptation

At higher text sizes:
- UI containers must expand to fit larger text
- Consider hiding less important UI elements
- HUD elements may need repositioning
- Scrolling containers for long text

### Edge Cases

- Text must not overflow containers at max size
- Critical gameplay text (coins, health) always visible
- Shop item descriptions may need scroll
- Settings persist across sessions
- Preview text size before confirming

## Verify

- [ ] Build succeeds
- [ ] Text size setting appears in settings menu
- [ ] All 5 size levels work correctly
- [ ] Text remains readable at minimum size
- [ ] Text doesn't overflow UI at maximum size
- [ ] HUD elements adjust properly
- [ ] Shop text remains usable at all sizes
- [ ] Setting persists after app restart
