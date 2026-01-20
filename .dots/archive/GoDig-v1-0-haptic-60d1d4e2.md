---
title: "implement: Haptic feedback system"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-16T01:48:43.176758-06:00\""
closed-at: "2026-01-19T19:35:08.578303-06:00"
close-reason: Haptics setting in settings_manager.gd
---

Vibration on dig, pickup, and achievements. Essential mobile feedback that replaces physical button feedback.

## Description

Implement a haptic feedback system for mobile devices. Short vibrations provide tactile feedback for actions, making the game feel more responsive on touchscreens where there's no physical button feedback.

## Context

- Mobile games rely heavily on haptic feedback to compensate for lack of physical buttons
- Godot provides `Input.vibrate_handheld(duration_ms)` for mobile vibration
- Must be optional (battery drain, user preference)
- See Docs/research/audio-sound-design.md for vibration patterns

## Affected Files

- `scripts/autoload/haptics_manager.gd` - NEW: Singleton for haptic control
- `scripts/autoload/game_manager.gd` - Store haptics_enabled setting
- `project.godot` - Register HapticsManager autoload
- `scripts/player/player.gd` - Trigger haptics on mining, landing
- `scripts/world/dirt_grid.gd` - Trigger haptics on block break

## Implementation Notes

### HapticsManager Autoload

```gdscript
# haptics_manager.gd
extends Node

enum HapticType {
    LIGHT,   # 10ms - button press, soft block
    MEDIUM,  # 25ms - ore found, landing
    HEAVY,   # 50ms - rare gem, damage
    PATTERN  # Custom pattern for special events
}

const DURATIONS := {
    HapticType.LIGHT: 10,
    HapticType.MEDIUM: 25,
    HapticType.HEAVY: 50,
}

var enabled: bool = true
var _is_mobile: bool = false

func _ready() -> void:
    _is_mobile = OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios")

func vibrate(type: HapticType) -> void:
    if not enabled or not _is_mobile:
        return
    Input.vibrate_handheld(DURATIONS.get(type, 10))

func vibrate_pattern(pattern: Array[int]) -> void:
    ## Vibrate with a custom pattern [vibrate_ms, pause_ms, vibrate_ms, ...]
    if not enabled or not _is_mobile:
        return
    for i in pattern.size():
        if i % 2 == 0:
            Input.vibrate_handheld(pattern[i])
        else:
            await get_tree().create_timer(float(pattern[i]) / 1000.0).timeout

func light() -> void:
    vibrate(HapticType.LIGHT)

func medium() -> void:
    vibrate(HapticType.MEDIUM)

func heavy() -> void:
    vibrate(HapticType.HEAVY)

func damage_pattern() -> void:
    vibrate_pattern([50, 30, 30, 30, 50])  # Heavy-pause-light-pause-heavy
```

### Register Autoload

In `project.godot`:
```
[autoload]
HapticsManager="*res://scripts/autoload/haptics_manager.gd"
```

### Haptic Events Table

| Event | Haptic Type | Duration |
|-------|-------------|----------|
| Soft block hit | LIGHT | 10ms |
| Hard block hit | MEDIUM | 25ms |
| Block break | LIGHT | 10ms |
| Ore found | MEDIUM | 25ms |
| Rare gem found | HEAVY | 50ms |
| Landing (short) | LIGHT | 10ms |
| Landing (long) | MEDIUM | 25ms |
| Damage taken | PATTERN | 50-30-50 |
| Button press | LIGHT | 10ms |
| Purchase success | MEDIUM | 25ms |
| Achievement | HEAVY | 50ms |

### Integration Examples

```gdscript
# player.gd - on landing
func _land_on_grid(landing_grid: Vector2i) -> void:
    # ...existing code...
    HapticsManager.light()

# dirt_grid.gd - on block break
func _on_block_destroyed(grid_pos: Vector2i) -> void:
    HapticsManager.light()

# When finding rare ore
func _on_rare_ore_found() -> void:
    HapticsManager.heavy()
```

### Settings Integration

```gdscript
# game_manager.gd
var haptics_enabled: bool = true

func set_haptics(enabled: bool) -> void:
    haptics_enabled = enabled
    HapticsManager.enabled = enabled
    # Save to settings

func _ready() -> void:
    # Load setting
    HapticsManager.enabled = haptics_enabled
```

### Battery Considerations

- Keep vibrations short (under 50ms for most actions)
- Avoid continuous/repeating vibrations
- Disable during intensive gameplay if battery is low (optional)

## Verify

- [ ] Haptics work on Android device/emulator
- [ ] Haptics work on iOS device/simulator
- [ ] Mining triggers short vibration
- [ ] Finding rare gem triggers longer vibration
- [ ] Taking damage triggers pattern vibration
- [ ] Disabling haptics in settings stops all vibrations
- [ ] No vibration on desktop/web platforms (graceful no-op)
- [ ] No battery drain concerns with typical gameplay
