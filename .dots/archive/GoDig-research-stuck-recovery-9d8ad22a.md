---
title: "research: Stuck recovery and save reload"
status: done
priority: 0
issue-type: task
created-at: "2026-01-18T23:39:37.139024-06:00"
---

How does player recover if stuck? Questions: What counts as 'stuck'? (no ladders, can't dig up, surrounded) Can player reload last autosave from pause menu? Is there a 'rescue' teleport option? (costs coins or free?) How do we prevent soft-locks? Should there be a 'dig up' ability as last resort? What's the UX for choosing to reload?

## Research Findings (Verified 2026-01-19)

### Current Implementation Status: COMPLETE

Stuck recovery is implemented via pause menu in `scripts/ui/pause_menu.gd`.

### Answer to Research Questions

**1. What counts as 'stuck'?**
- Not explicitly detected by the game
- Player self-identifies when they can't progress
- Soft-lock scenarios: surrounded by blocks, no ladders, can't dig up

**2. Can player reload last autosave from pause menu?**
- YES - "Reload Save" button in pause menu
- Shows time since last save: "Reload Save (2 minutes ago)"
- Disabled if no save exists for current slot
- Confirmation dialog: "All progress since your last save will be lost."

**3. Is there a 'rescue' teleport option?**
- YES - "Rescue Me" button in pause menu
- Cost: **Free but loses cargo** (inventory cleared)
- Confirmation: "A rescue team will bring you to the surface, but your cargo will be left behind."
- Implementation: `InventoryManager.clear_all()` then teleport to surface

**4. How do we prevent soft-locks?**
- Wall-jump ability (can climb vertical shafts)
- Emergency rescue (always available)
- Reload save (revert to last checkpoint)
- Future: Ladders, drill (dig up)

**5. Should there be a 'dig up' ability as last resort?**
- Currently NO - player cannot dig upward
- Decision made in earlier research: MVP doesn't allow upward digging
- Future consideration: Drill tool upgrade for v1.0

**6. What's the UX for choosing to reload?**
1. Player presses pause button
2. Pause menu shows with Reload Save button
3. Button shows time since last save
4. Click opens confirmation dialog
5. Confirm reloads, Cancel returns to menu
6. On reload: `SaveManager.load_game()` restores state

### Pause Menu Implementation

**Buttons:**
- Resume - Close menu, unpause
- Settings - (placeholder)
- Rescue Me - Teleport to surface, lose inventory
- Reload Save - Restore last autosave
- Quit - Save and exit

**Confirmation Dialogs:**
```gdscript
# Rescue confirmation
_confirm_dialog.dialog_text = "A rescue team will bring you to the surface,\nbut your cargo will be left behind."

# Reload confirmation
_confirm_dialog.dialog_text = "All progress since your last save (%s) will be lost.\nThis cannot be undone."
```

**Signal Flow:**
1. `pause_menu.rescue_requested` -> `TestLevel._on_pause_menu_rescue()`
2. `TestLevel` teleports player to surface coordinates
3. Game unpauses and continues

**Rescue Teleport Code (TestLevel):**
```gdscript
func _on_pause_menu_rescue() -> void:
    var surface_y := GameManager.SURFACE_ROW * 128 - 128
    var center_x := GameManager.GRID_WIDTH / 2
    var spawn_pos := GameManager.grid_to_world(Vector2i(center_x, GameManager.SURFACE_ROW - 1))
    player.position = spawn_pos
    player.grid_position = GameManager.world_to_grid(spawn_pos)
    player.current_state = player.State.IDLE
    player.velocity = Vector2.ZERO
```

### No Further Work Needed

Stuck recovery mechanisms are complete. Additional prevention (ladders, drill) are separate features.
