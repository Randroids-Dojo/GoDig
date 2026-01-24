---
title: "implement: SettingsManager singleton"
status: closed
priority: 1
issue-type: task
created-at: "\"2026-01-19T03:39:11.244863-06:00\""
closed-at: "2026-01-24T07:17:51.020864+00:00"
close-reason: Already fully implemented with signals, validation, persistence, and audio bus integration
---

## Description

Create a central SettingsManager autoload that handles all game settings including accessibility preferences. This singleton stores settings, persists them to disk, and emits signals when settings change so UI can react.

## Context

Multiple accessibility features (colorblind mode, text size, one-hand mode, haptics, reduced motion) need a common settings system. Having a dedicated SettingsManager keeps settings logic separate from game logic and ensures consistency.

## Affected Files

- `scripts/autoload/settings_manager.gd` - NEW: Settings singleton
- `project.godot` - MODIFY: Register SettingsManager autoload
- `user://settings.cfg` - NEW: Settings save file location

## Implementation Notes

### SettingsManager Structure

```gdscript
extends Node

## Signals for reactive UI updates
signal text_size_changed(scale: float)
signal colorblind_mode_changed(mode: int)
signal hand_mode_changed(mode: int)
signal haptics_changed(enabled: bool)
signal reduced_motion_changed(enabled: bool)
signal audio_changed()

## Enums
enum ColorblindMode { OFF, SYMBOLS, HIGH_CONTRAST }
enum HandMode { STANDARD, LEFT_HAND, RIGHT_HAND }

## Settings values with defaults
const TEXT_SCALES := [0.85, 1.0, 1.25, 1.5, 2.0]

var text_size_level: int = 1:
    set(value):
        text_size_level = clampi(value, 0, TEXT_SCALES.size() - 1)
        text_size_changed.emit(get_text_scale())
        _save_settings()

var colorblind_mode: ColorblindMode = ColorblindMode.OFF:
    set(value):
        colorblind_mode = value
        colorblind_mode_changed.emit(value)
        _save_settings()

var hand_mode: HandMode = HandMode.STANDARD:
    set(value):
        hand_mode = value
        hand_mode_changed.emit(value)
        _save_settings()

var haptics_enabled: bool = true:
    set(value):
        haptics_enabled = value
        haptics_changed.emit(value)
        _save_settings()

var reduced_motion: bool = false:
    set(value):
        reduced_motion = value
        reduced_motion_changed.emit(value)
        _save_settings()

## Audio settings
var master_volume: float = 1.0
var sfx_volume: float = 1.0
var music_volume: float = 1.0

const SETTINGS_PATH := "user://settings.cfg"

func _ready() -> void:
    _load_settings()

func get_text_scale() -> float:
    return TEXT_SCALES[text_size_level]

func _save_settings() -> void:
    var config := ConfigFile.new()
    config.set_value("accessibility", "text_size_level", text_size_level)
    config.set_value("accessibility", "colorblind_mode", colorblind_mode)
    config.set_value("accessibility", "hand_mode", hand_mode)
    config.set_value("accessibility", "haptics_enabled", haptics_enabled)
    config.set_value("accessibility", "reduced_motion", reduced_motion)
    config.set_value("audio", "master_volume", master_volume)
    config.set_value("audio", "sfx_volume", sfx_volume)
    config.set_value("audio", "music_volume", music_volume)
    config.save(SETTINGS_PATH)

func _load_settings() -> void:
    var config := ConfigFile.new()
    if config.load(SETTINGS_PATH) != OK:
        return  # Use defaults

    text_size_level = config.get_value("accessibility", "text_size_level", 1)
    colorblind_mode = config.get_value("accessibility", "colorblind_mode", ColorblindMode.OFF)
    hand_mode = config.get_value("accessibility", "hand_mode", HandMode.STANDARD)
    haptics_enabled = config.get_value("accessibility", "haptics_enabled", true)
    reduced_motion = config.get_value("accessibility", "reduced_motion", false)
    master_volume = config.get_value("audio", "master_volume", 1.0)
    sfx_volume = config.get_value("audio", "sfx_volume", 1.0)
    music_volume = config.get_value("audio", "music_volume", 1.0)

func reset_to_defaults() -> void:
    text_size_level = 1
    colorblind_mode = ColorblindMode.OFF
    hand_mode = HandMode.STANDARD
    haptics_enabled = true
    reduced_motion = false
    master_volume = 1.0
    sfx_volume = 1.0
    music_volume = 1.0
```

### Register Autoload

In `project.godot`:
```
[autoload]
SettingsManager="*res://scripts/autoload/settings_manager.gd"
```

Load order: SettingsManager should load early (before UI systems that need settings).

### Usage in Other Systems

```gdscript
# In touch_controls.gd
func _ready() -> void:
    SettingsManager.hand_mode_changed.connect(_on_hand_mode_changed)
    _apply_hand_mode(SettingsManager.hand_mode)

# In haptics_manager.gd
func vibrate(type: HapticType) -> void:
    if not SettingsManager.haptics_enabled:
        return
    # ...
```

### Edge Cases

- Settings file may not exist on first launch (use defaults)
- Settings file may be corrupted (reset to defaults)
- Settings must be available immediately on _ready()
- Avoid saving on every frame (debounce if needed)

## Verify

- [ ] Build succeeds
- [ ] SettingsManager loads as autoload
- [ ] Settings persist across app restarts
- [ ] Signals emit when settings change
- [ ] Default values used when no save file exists
- [ ] Invalid/corrupted save file handled gracefully
- [ ] All accessibility features can read settings
