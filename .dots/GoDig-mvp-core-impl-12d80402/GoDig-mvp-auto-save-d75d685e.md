---
title: "implement: Auto-save system"
status: open
priority: 0
issue-type: task
created-at: "2026-01-16T00:34:28.141025-06:00"
after:
  - GoDig-dev-savemanager-autoload-d6e0ad94
  - GoDig-mvp-basic-inventory-851ca931
  - GoDig-mvp-2-3-e92f5253
---

## Description

Extend SaveManager with automatic save triggers. This task adds auto-save behavior on top of the base SaveManager implementation (see GoDig-dev-savemanager-autoload-d6e0ad94).

## Context

Mobile players may close the app at any time. Auto-save ensures no progress is lost. Players should never manually save - the game handles it transparently.

**Note:** The base SaveManager singleton spec (GoDig-dev-savemanager-autoload-d6e0ad94) handles save/load mechanics, SaveData structure, and chunk persistence. This spec adds the automatic trigger logic.

## Affected Files

- `scripts/autoload/save_manager.gd` - MODIFY: Add auto-save timer and trigger logic

## Implementation Notes

### Auto-Save Timer

Add to existing SaveManager:

```gdscript
const AUTO_SAVE_INTERVAL := 60.0  # seconds

var _auto_save_timer: float = 0.0

func _process(delta: float) -> void:
    if current_save == null:
        return
    _auto_save_timer += delta
    if _auto_save_timer >= AUTO_SAVE_INTERVAL:
        save_game()
        _auto_save_timer = 0.0
```

### Mobile Lifecycle Triggers

Add to existing SaveManager:

```gdscript
func _notification(what: int) -> void:
    match what:
        NOTIFICATION_APPLICATION_PAUSED:
            # Mobile: app went to background
            save_game()
        NOTIFICATION_APPLICATION_FOCUS_OUT:
            # Desktop: window lost focus (optional save)
            pass
        NOTIFICATION_WM_CLOSE_REQUEST:
            # Window closing
            save_game()
```

### Event-Based Triggers

Other systems should trigger saves at key moments:

```gdscript
# In shop.gd after transaction:
func _on_transaction_complete():
    SaveManager.save_game()

# In player.gd when reaching surface:
func _on_reached_surface():
    SaveManager.save_game()

# In game_manager.gd on depth milestone:
func _on_depth_milestone_reached(depth: int):
    SaveManager.save_game()
```

### Auto-Save Trigger Points

1. **Timer**: Every 60 seconds of gameplay
2. **Surface Return**: When player enters surface area
3. **Shop Transaction**: After any buy/sell
4. **App Background**: Mobile lifecycle event (critical)
5. **Depth Milestone**: First time reaching new depth tier (10m, 50m, 100m, etc.)
6. **Tool Upgrade**: After purchasing a new tool

### Debouncing

Prevent excessive saves when multiple triggers fire rapidly:

```gdscript
var _last_save_time: int = 0
const MIN_SAVE_INTERVAL_MS := 5000  # 5 seconds minimum between saves

func save_game() -> void:
    var current_time := Time.get_ticks_msec()
    if current_time - _last_save_time < MIN_SAVE_INTERVAL_MS:
        return  # Skip, too soon
    _last_save_time = current_time

    # ... rest of save logic from base spec ...
```

### Save Indicator UI (Optional)

Brief indicator during save:

```gdscript
# SaveManager signals (already in base spec):
signal save_started
signal save_completed

# In HUD scene, connect to show indicator:
func _on_save_started():
    $SaveIndicator.show()

func _on_save_completed():
    $SaveIndicator.hide()
```

## Edge Cases

- Rapid triggers: Debounce prevents excessive writes
- Save during pause: Should still save (pause doesn't block auto-save)
- Background while saving: Let current save finish, don't double-save
- Web platform: IndexedDB used automatically (no special handling)

## Verify

- [ ] Build succeeds with no errors
- [ ] Auto-save triggers every 60 seconds during gameplay
- [ ] App background (mobile) triggers immediate save
- [ ] Shop transaction triggers save
- [ ] Returning to surface triggers save
- [ ] Rapid triggers don't cause multiple saves (debounce works)
- [ ] Save indicator appears/disappears if implemented
