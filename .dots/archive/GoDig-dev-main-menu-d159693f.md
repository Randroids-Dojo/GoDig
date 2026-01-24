---
title: "implement: Main menu scene"
status: closed
priority: 1
issue-type: task
created-at: "\"2026-01-16T00:47:34.656713-06:00\""
closed-at: "2026-01-24T21:19:38.343888+00:00"
close-reason: main_menu.tscn exists with new game, continue, settings buttons
---

## Description

Create the main menu scene with New Game, Continue, and Settings buttons. Simple portrait layout optimized for mobile touch.

## Context

This is the entry point of the game. Player lands here on launch. The Continue button should only appear if a save file exists. Settings provides access to audio/control options.

## Affected Files

- `scenes/main_menu.tscn` - NEW: Main menu scene
- `scripts/ui/main_menu.gd` - NEW: Menu controller
- `scenes/ui/settings_menu.tscn` - NEW: Settings popup/panel
- `project.godot` - Set main_menu.tscn as initial scene

## Implementation Notes

### Scene Structure
```
MainMenu (Control)
├── Background (ColorRect or TextureRect)
│   └── Gradient or simple color
├── TitleContainer (VBoxContainer)
│   ├── GameTitle (Label "GoDig")
│   └── Subtitle (Label "A Mining Adventure" - optional)
├── ButtonContainer (VBoxContainer)
│   ├── NewGameButton (Button)
│   ├── ContinueButton (Button) - hidden if no save
│   └── SettingsButton (Button)
└── VersionLabel (Label "v0.1.0")
```

### Layout (720x1280 Portrait)
```
┌──────────────────────────┐
│                          │
│         [LOGO]           │  Top 1/3
│         GoDig            │
│                          │
├──────────────────────────┤
│                          │
│      [ New Game ]        │  Center
│      [ Continue ]        │  (hidden if no save)
│      [ Settings ]        │
│                          │
├──────────────────────────┤
│                          │
│         v0.1.0           │  Bottom
│                          │
└──────────────────────────┘
```

### Menu Script
```gdscript
# main_menu.gd
extends Control

@onready var continue_button: Button = $ButtonContainer/ContinueButton
@onready var settings_panel: Control = $SettingsPanel

func _ready() -> void:
    # Show continue only if save exists
    continue_button.visible = SaveManager.has_save()

    # Connect button signals
    $ButtonContainer/NewGameButton.pressed.connect(_on_new_game)
    $ButtonContainer/ContinueButton.pressed.connect(_on_continue)
    $ButtonContainer/SettingsButton.pressed.connect(_on_settings)


func _on_new_game() -> void:
    GameManager.start_new_game()
    get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_continue() -> void:
    SaveManager.load_game()
    get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_settings() -> void:
    settings_panel.visible = true
```

### Button Styling
- Large touch targets (min 60px height)
- High contrast text
- Clear visual hierarchy
- Disabled state for Continue when no save

### Mobile Considerations
- Buttons: 80%+ screen width for easy tapping
- Font size: 24-32px for readability
- Spacing: 20-30px between buttons
- No hover states needed (touch-first)

## Verify

- [ ] Build succeeds
- [ ] Main menu loads as initial scene
- [ ] Title displays correctly
- [ ] New Game button visible and clickable
- [ ] Continue button hidden when no save exists
- [ ] Continue button appears when save exists
- [ ] Settings button opens settings panel
- [ ] New Game transitions to main.tscn
- [ ] Continue loads save and transitions to main.tscn
- [ ] Version label shows correct version
- [ ] Layout looks good in portrait 720x1280
