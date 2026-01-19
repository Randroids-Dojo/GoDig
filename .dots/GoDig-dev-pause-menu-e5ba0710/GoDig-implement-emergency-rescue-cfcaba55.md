---
title: "implement: Emergency rescue from pause menu"
status: open
priority: 1
issue-type: task
created-at: "2026-01-19T00:50:31.953043-06:00"
---

## Description

Add 'Emergency Rescue' option to pause menu that teleports player to surface at the cost of their current inventory.

## Context

This is the primary stuck recovery mechanism. Players who find themselves in unwinnable situations can always escape, but lose their cargo as a meaningful penalty.

## Affected Files

- `scenes/ui/pause_menu.tscn` - Add Emergency Rescue button
- `scripts/ui/pause_menu.gd` - Handle rescue action
- `scripts/player/player.gd` - Add rescue teleport method
- `scripts/autoload/game_manager.gd` - Coordinate rescue flow

## Implementation Notes

### Pause Menu Button
- Add between Continue and Settings buttons
- Label: 'Emergency Rescue'
- Color: Warning yellow/orange

### Confirmation Dialog
- Title: 'Call for Rescue?'
- Message: 'A rescue team will bring you to the surface, but your cargo will be left behind.'
- Buttons: [Yes] [No]

### Rescue Logic
```gdscript
func execute_rescue():
    # Clear inventory (ores, gems, consumables)
    InventoryManager.clear_cargo()  # Keep equipped tool, backpack
    
    # Teleport to surface spawn
    player.position = GameManager.surface_spawn_position
    
    # Visual effect (optional)
    play_rescue_animation()
    
    # Close pause menu
    resume_game()
```

### What to Keep
- Coins (already banked)
- Equipped tool
- Equipped gear (helmet, boots)
- Backpack capacity
- All unlocks and progress
- Lifetime stats

### What to Clear
- All inventory items (ore stacks, gems, consumables)
- NOT ladders in quick-slot? (design decision - probably clear these too)

## Verify

- [ ] Build succeeds
- [ ] Emergency Rescue button appears in pause menu
- [ ] Confirmation dialog shows before action
- [ ] Player teleports to surface after confirming
- [ ] Inventory is cleared but coins and equipment remain
- [ ] Works when player is deep underground (500m+)
- [ ] Cancel returns to pause menu without action
