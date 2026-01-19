---
title: "implement: Reload last save from pause menu"
status: open
priority: 1
issue-type: task
created-at: "2026-01-19T00:50:45.631885-06:00"
---

## Description

Add 'Reload Last Save' option to pause menu that restores the game state to the last autosave point.

## Context

This provides a familiar recovery option for players who want to undo recent progress (including any mistakes that led to being stuck). Shows time since last save so players can make informed decisions.

## Affected Files

- `scenes/ui/pause_menu.tscn` - Add Reload Save button
- `scripts/ui/pause_menu.gd` - Handle reload action, show time since save
- `scripts/autoload/save_manager.gd` - Add reload functionality, track save timestamp

## Implementation Notes

### Pause Menu Button
- Add below Emergency Rescue
- Label: 'Reload Last Save'
- Subtitle: '(3 minutes ago)' - dynamically updated

### Time Since Save Display
```gdscript
func get_time_since_save_text() -> String:
    var seconds = Time.get_unix_time_from_system() - SaveManager.last_save_timestamp
    var minutes = int(seconds / 60)
    if minutes == 0:
        return 'just now'
    elif minutes == 1:
        return '1 minute ago'
    else:
        return '%d minutes ago' % minutes
```

### Confirmation Dialog
- Title: 'Reload Last Save?'
- Message: 'All progress since your last save (X minutes ago) will be lost. This cannot be undone.'
- Buttons: [Reload] [Cancel]

### Reload Logic
```gdscript
func reload_last_save():
    # Close pause menu first
    hide()
    
    # Trigger full game reload from save
    SaveManager.load_game()
    GameManager.restore_from_save()
```

### SaveManager Changes
- Add `last_save_timestamp: int` tracking
- Add `get_seconds_since_last_save() -> int`
- Ensure `load_game()` properly restores all state

## Edge Cases

- If no save exists (new game, never saved): Disable button or show 'No save found'
- If save is corrupted: Show error, don't reload
- Ensure chunk state is also restored (modified tiles)

## Verify

- [ ] Build succeeds
- [ ] Reload Last Save button appears in pause menu
- [ ] Time since save displays correctly and updates
- [ ] Confirmation dialog shows before action
- [ ] Game state fully restores after reload (position, inventory, world)
- [ ] Button is disabled if no save exists
- [ ] Cancel returns to pause menu without action
