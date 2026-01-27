---
title: "implement: Time since last save HUD indicator"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-19T00:51:00.290527-06:00\""
closed-at: "2026-01-27T06:04:37.383683+00:00"
close-reason: Added save indicator label to HUD showing time since last save with color coding
---

## Description

Add a small indicator in the HUD showing time since last autosave, helping players know when it's 'safe' to exit or take risks.

## Context

Mobile players often need to quit unexpectedly. Showing last save time gives confidence that progress is safe. Also supports the reload feature by setting expectations.

## Affected Files

- `scenes/ui/hud.tscn` - Add save indicator area
- `scripts/ui/hud.gd` - Update time display, show save animation
- `scripts/autoload/save_manager.gd` - Track and broadcast save events

## Implementation Notes

### HUD Element Location
- Top-right corner, subtle
- Format: Small save icon + 'Saved X ago'
- Shows checkmark animation on save

### Visual Design
```
[checkmark] Saved 30s ago
```

### Update Logic
```gdscript
func _process(delta):
    if save_timer > 1.0:  # Update every second
        save_timer = 0
        update_save_time_display()

func update_save_time_display():
    var seconds = SaveManager.get_seconds_since_last_save()
    if seconds < 60:
        save_label.text = 'Saved %ds ago' % seconds
    else:
        save_label.text = 'Saved %dm ago' % (seconds / 60)
    
    # Color based on staleness
    if seconds < 120:  # Green - recent
        save_label.modulate = Color.GREEN
    elif seconds < 300:  # Yellow - getting old
        save_label.modulate = Color.YELLOW
    else:  # Red - very old
        save_label.modulate = Color.RED

func on_game_saved():
    # Flash save indicator
    save_icon.play('save_flash')
    save_label.text = 'Saved just now'
```

### Save Event Signal
```gdscript
# In SaveManager
signal game_saved

func save_game():
    # ... save logic ...
    game_saved.emit()
```

### Optional: Hide When Recent
- Could hide indicator entirely when <30 seconds (assumed safe)
- Shows only when save is getting stale (2+ minutes)

## Verify

- [ ] Build succeeds
- [ ] Save indicator appears in HUD
- [ ] Time updates correctly (seconds, then minutes)
- [ ] Color changes based on time since save
- [ ] Animation plays when game saves
- [ ] Does not obstruct important UI elements
- [ ] Responsive to different screen sizes
