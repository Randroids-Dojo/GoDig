---
title: "implement: Portrait UI layout system"
status: closed
priority: 0
issue-type: task
created-at: "\"\\\"2026-01-16T00:39:26.014782-06:00\\\"\""
closed-at: "2026-01-22T05:28:49.247683+00:00"
close-reason: Implemented portrait UI layout system with safe area handling, updated HUD and touch controls, added comprehensive tests
---

Design all UI for portrait orientation. HUD at top, controls at bottom. Inventory grid in portrait format. Touch-friendly button sizes.

## Description

Establish a consistent portrait-mode UI layout system for all game screens. This defines anchor positions, safe areas, and standard layouts to ensure all UI elements work well on 720x1280 portrait screens and scale properly to different mobile devices.

## Context

- Project already configured for 720x1280 portrait (project.godot)
- HUD exists (`scripts/ui/hud.gd`) with health bar and depth display
- Touch controls exist (`scripts/ui/touch_controls.gd`) with joystick and action buttons
- Need consistent layout guidelines for all current and future UI screens
- Mobile devices have notches, rounded corners, and varying aspect ratios

## Affected Files

- `scenes/ui/ui_layout.tscn` - NEW: Base UI layout scene with anchor containers
- `scripts/ui/ui_layout.gd` - NEW: Safe area and scaling utilities
- `scenes/test_level.tscn` - Update UI organization to use layout system
- `scenes/ui/hud.tscn` - Update to use layout anchors
- `scenes/ui/touch_controls.tscn` - Update to use layout anchors
- `scenes/ui/shop.tscn` - Update to use layout anchors
- `scenes/ui/inventory_panel.tscn` - Update to use layout anchors

## Implementation Notes

### Screen Layout Zones (720x1280)

```
+------------------------------------------+
|  STATUS BAR SAFE AREA (60px)             |  <- iOS notch/Android status
+------------------------------------------+
|  TOP HUD ZONE (120px)                    |
|  [Coins] [Depth] [Settings]              |
+------------------------------------------+
|                                          |
|                                          |
|           GAME VIEW AREA                 |
|                                          |
|           (Main gameplay)                |
|                                          |
|           720 x 880px                    |
|                                          |
|                                          |
+------------------------------------------+
|  BOTTOM CONTROLS ZONE (220px)            |
|  [Joystick]            [Actions]         |
+------------------------------------------+
```

### UI Layout Scene Structure

```
UILayout (Control)
+-- SafeAreaContainer (MarginContainer)
|   +-- TopHUD (Control, anchored top)
|   |   +-- LeftInfo (HBoxContainer)
|   |   |   +-- CoinsLabel
|   |   |   +-- DepthLabel
|   |   +-- RightButtons (HBoxContainer)
|   |       +-- PauseButton
|   |       +-- SettingsButton
|   +-- BottomControls (Control, anchored bottom)
|       +-- TouchControls (existing scene)
+-- FullscreenOverlays (Control)
    +-- LowHealthVignette
    +-- PauseOverlay
    +-- PopupContainer
```

### Safe Area Handling

```gdscript
# ui_layout.gd
extends Control

## Get the safe area insets for the current device
func get_safe_area_insets() -> Dictionary:
    var safe_area := DisplayServer.get_display_safe_area()
    var screen_size := DisplayServer.screen_get_size()
    return {
        "top": safe_area.position.y,
        "bottom": screen_size.y - safe_area.end.y,
        "left": safe_area.position.x,
        "right": screen_size.x - safe_area.end.x
    }

func _ready() -> void:
    _apply_safe_area_margins()
    get_tree().root.size_changed.connect(_apply_safe_area_margins)

func _apply_safe_area_margins() -> void:
    var insets := get_safe_area_insets()
    # Apply to SafeAreaContainer margins
    $SafeAreaContainer.add_theme_constant_override("margin_top", max(60, insets["top"]))
    $SafeAreaContainer.add_theme_constant_override("margin_bottom", max(40, insets["bottom"]))
```

### Standard UI Element Sizes

- **Touch buttons**: Minimum 48x48dp (88px @ 720w), recommended 64x64dp (118px)
- **Text labels**: Body 16sp (29px), Headers 20sp (37px), HUD values 24sp (44px)
- **Margins**: Standard 16px, Large 24px, Small 8px
- **Button spacing**: 12px between touch targets

### Anchor Presets

Define consistent anchor presets for common UI positions:

```gdscript
# ui_layout.gd
enum Anchor { TOP_LEFT, TOP_CENTER, TOP_RIGHT,
              CENTER_LEFT, CENTER, CENTER_RIGHT,
              BOTTOM_LEFT, BOTTOM_CENTER, BOTTOM_RIGHT,
              TOP_FULL, BOTTOM_FULL, LEFT_FULL, RIGHT_FULL }

static func apply_anchor(control: Control, anchor: Anchor) -> void:
    match anchor:
        Anchor.TOP_LEFT:
            control.anchor_left = 0.0
            control.anchor_right = 0.0
            control.anchor_top = 0.0
            control.anchor_bottom = 0.0
        Anchor.BOTTOM_FULL:
            control.anchor_left = 0.0
            control.anchor_right = 1.0
            control.anchor_top = 1.0
            control.anchor_bottom = 1.0
        # ... etc
```

### HUD Layout Update

```gdscript
# In hud.gd or hud.tscn
# Position health bar at top-left with padding
$HealthBar.anchor_left = 0.0
$HealthBar.anchor_top = 0.0
$HealthBar.offset_left = 16
$HealthBar.offset_top = 16
$HealthBar.custom_minimum_size = Vector2(200, 32)
```

### Touch Controls Layout Update

```
BottomControls (Control, BOTTOM_FULL anchor)
+-- Joystick (anchored bottom-left)
|   Position: (80, -160) from bottom-left corner
|   Size: 200x200
+-- ActionButtons (anchored bottom-right)
    Position: (-120, -160) from bottom-right corner
    +-- JumpButton (64x64, right side)
    +-- DigButton (80x80, main action, larger)
    +-- InventoryButton (48x48, top corner)
```

### Popup/Modal Layout

All popups should:
- Center horizontally
- Offset from top by 15-20% of screen height
- Max width 90% of screen (648px on 720 base)
- Have rounded corners (8px radius)
- Darken background with semi-transparent overlay

### Responsive Scaling

The project uses `canvas_items` stretch mode which handles most scaling, but:
- Use `custom_minimum_size` for fixed elements
- Use `size_flags` for flexible elements
- Test on 720x1280, 1080x1920, 1440x2960 aspect ratios

## Edge Cases

- Devices with extreme aspect ratios (foldables, tablets in portrait)
- Devices with large notches (iPhone 14 Pro)
- Split-screen mode on Android
- Accessibility zoom enabled

## Verify

- [ ] Build succeeds with no errors
- [ ] HUD elements display in top zone with proper safe area padding
- [ ] Touch controls display in bottom zone
- [ ] Game view area is unobstructed by UI
- [ ] Popups center correctly and don't overlap controls
- [ ] UI scales properly at different resolutions (test 720, 1080, 1440 widths)
- [ ] Safe area margins work on iOS notch simulator
- [ ] Text is readable at all specified sizes
- [ ] Touch targets are at least 88px (48dp) for accessibility
- [ ] Pause menu and shop UI follow the same layout guidelines
