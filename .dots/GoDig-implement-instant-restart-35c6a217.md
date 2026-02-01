---
title: "implement: Instant restart after emergency rescue"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T08:40:47.278709-06:00"
---

## Description

When player triggers emergency rescue (stuck/death), minimize friction to get back into the game. The 'one more run' addiction requires near-instant restart.

## Context

Research (Session 14) found:
- Roguelike design: 'near-instant restart after failure prevents antagonizing frustrated players'
- 'One more game mentality = strong addiction factor'
- Menus getting in the way can 'potentially end the session'
- Death should be 'quick + restart immediate'
- Emergency rescue should feel like 'consequence but not punishment'

Current flow may have too many screens/confirmations between death and next attempt.

## Implementation

### Current Pain Points to Fix
1. Death animation too long
2. 'You Died' screen requires button press
3. Respawn position not optimal for quick retry
4. Inventory loss message interrupts flow

### New Flow
1. Death/stuck triggers → 1 second death animation max
2. Brief message overlay: 'Emergency Rescue - Cargo Lost' (auto-dismiss 1.5s)
3. Instant respawn at surface shop entrance
4. Player immediately ready to buy supplies and dig again

### Forfeit Cargo Option
- If player triggers rescue BEFORE death (low ladders)
- Show quick confirm: 'Forfeit cargo to return safely?' (Y/N)
- 'Yes' = instant surface teleport, cargo lost
- This gives agency and prevents 'unfair death' feeling

### Post-Rescue State
- Player has 0 ore (cargo forfeited)
- Player keeps coins already banked
- Player keeps equipment/upgrades
- Ladders reset to last-purchased amount

### Quick-Dive Button
After rescue, show prominent 'Dive Again?' button that:
- Opens ladder purchase if ladders = 0
- Starts descent immediately if ladders > 0

## Affected Files
- `scripts/player/player.gd` - Faster death sequence
- `scripts/autoload/game_manager.gd` - Rescue flow
- `scenes/ui/rescue_overlay.tscn` - Streamlined rescue UI
- `scenes/ui/hud.gd` - Quick-dive button post-rescue

## Verify
- [ ] Death to playable state < 3 seconds total
- [ ] No required button presses between death and respawn
- [ ] Forfeit cargo option available before death
- [ ] Player spawns ready to immediately start new run
- [ ] Quick-dive button prominent after rescue
- [ ] No inventory/stat screens interrupting flow
