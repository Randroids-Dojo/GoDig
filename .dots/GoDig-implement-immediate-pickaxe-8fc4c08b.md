---
title: "implement: Immediate pickaxe power feel after upgrade"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T02:09:25.838029-06:00"
---

## Description
When player upgrades their pickaxe, the next few blocks should OBVIOUSLY feel easier to break. This validates the purchase and creates the 'power fantasy' moment.

## Context
Research from Rogue Legacy: 'Players get stronger and struggle less - bosses that brought them close to death appear like normal enemies later.' Dome Keeper: 'This immediately provides visible feedback in the form of faster digging... This kind of tangible feedback feels great.'

## Implementation
1. After purchase, store 'just_upgraded' flag
2. For next 5 blocks broken:
   - Extra particle burst (empowered strike)
   - Slightly louder/deeper dig sound
   - Optional: brief 'empowered' aura around pickaxe (golden glow)
3. Animation speed visibly faster for already-fast swings
4. Clear the flag after 5 blocks or 30 seconds

## Affected Files
- scripts/autoload/player_data.gd - just_upgraded flag
- scripts/player/player.gd - Check flag in mining state
- scripts/effects/empowered_strike.tscn - Enhanced particles
- scripts/autoload/sound_manager.gd - Empowered dig sounds

## Verify
- [ ] First blocks after upgrade feel noticeably different
- [ ] Visual distinction is obvious (particles, glow)
- [ ] Effect fades after 5 blocks
- [ ] Player 'gets it' that they're stronger now
- [ ] Normal mining resumes after effect ends
