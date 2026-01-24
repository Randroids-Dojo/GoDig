---
title: "implement: Pause menu"
status: closed
priority: 2
issue-type: task
created-at: "2026-01-16T01:01:44.043469-06:00"
---

## Description

Create a pause menu that pauses the game and shows resume, settings, and quit options. Mobile: trigger via pause button in HUD or when app goes to background.

## Context

Players need a way to pause during gameplay. On mobile, this is critical when interrupted (phone call, notification). Auto-pause on app background is standard UX. The pause menu is also the access point for settings, emergency rescue, and reload features.

## Affected Files

- `scenes/ui/pause_menu.tscn` - NEW: Pause menu UI scene
- `scripts/ui/pause_menu.gd` - NEW: Pause menu controller
- `scripts/autoload/game_manager.gd` - Add pause state handling
- `scenes/ui/hud.tscn` - Add pause button (top-right area)
- `scripts/ui/hud.gd` - Wire pause button

## Implementation Notes

### Pause Menu Scene Structure

```
PauseMenu (CanvasLayer)
├── Background (ColorRect, semi-transparent black)
├── Panel (PanelContainer)
│   ├── VBoxContainer
│   │   ├── TitleLabel ("PAUSED")
│   │   ├── ResumeButton
│   │   ├── SettingsButton
│   │   ├── RescueButton (emergency teleport)
│   │   ├── ReloadButton (reload last save)
│   │   └── QuitButton
└── (CanvasLayer.layer = 100 to render above everything)
```

### Pause Menu Script

```gdscript
# pause_menu.gd
extends CanvasLayer

signal resumed
signal settings_opened
signal rescue_requested
signal reload_requested
signal quit_requested

@onready var resume_btn: Button = $Panel/VBox/ResumeButton
@onready var settings_btn: Button = $Panel/VBox/SettingsButton
@onready var rescue_btn: Button = $Panel/VBox/RescueButton
@onready var reload_btn: Button = $Panel/VBox/ReloadButton
@onready var quit_btn: Button = $Panel/VBox/QuitButton

func _ready() -> void:
    resume_btn.pressed.connect(_on_resume)
    settings_btn.pressed.connect(_on_settings)
    rescue_btn.pressed.connect(_on_rescue)
    reload_btn.pressed.connect(_on_reload)
    quit_btn.pressed.connect(_on_quit)
    visible = false

func show_menu() -> void:
    visible = true
    get_tree().paused = true

func hide_menu() -> void:
    visible = false
    get_tree().paused = false

func _on_resume() -> void:
    hide_menu()
    resumed.emit()

func _on_settings() -> void:
    settings_opened.emit()

func _on_rescue() -> void:
    # Confirm dialog before teleporting
    rescue_requested.emit()

func _on_reload() -> void:
    # Confirm dialog before reloading
    reload_requested.emit()

func _on_quit() -> void:
    # Auto-save then quit
    SaveManager.save_game()
    quit_requested.emit()

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("pause"):
        if visible:
            _on_resume()
        else:
            show_menu()
```

### GameManager Integration

```gdscript
# game_manager.gd
enum GameState { MENU, PLAYING, PAUSED, SHOPPING, DEAD }

func pause_game() -> void:
    if current_state == GameState.PLAYING:
        current_state = GameState.PAUSED
        get_tree().paused = true

func resume_game() -> void:
    if current_state == GameState.PAUSED:
        current_state = GameState.PLAYING
        get_tree().paused = false
```

### HUD Pause Button

Add a small pause icon (||) in the top-right corner of the HUD:
- 48x48 pixel touch target minimum
- Visible but non-intrusive
- Triggers pause_menu.show_menu()

### App Background Auto-Pause

```gdscript
# game_manager.gd or main scene
func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
        if current_state == GameState.PLAYING:
            pause_game()
```

## Edge Cases

- Pause while falling: Game freezes mid-air, resumes correctly
- Pause while mining animation: Animation pauses, resumes from same frame
- Pause in shop: Already not PLAYING state, pause button disabled or redirects
- Double-pause: Check state before pausing
- Quit without saving: Always auto-save before quit

## Verify

- [ ] Build succeeds
- [ ] Pause button visible in HUD during gameplay
- [ ] Tapping pause button shows pause menu
- [ ] Game freezes when paused (no player movement, no spawning)
- [ ] Resume button hides menu and unpauses
- [ ] Settings button opens settings (if implemented)
- [ ] Quit button saves game and returns to main menu
- [ ] App going to background auto-pauses
- [ ] Pressing back/escape while paused resumes game
- [ ] Pause works correctly in all game states
