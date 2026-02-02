---
title: "implement: Instant respawn at surface after death"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"2026-02-01T02:09:05.283311-06:00\\\"\""
closed-at: "2026-02-02T00:15:24.177494-06:00"
close-reason: "Added 'TAP TO RETRY' quick retry button that appears immediately on death, ultra-fast respawn with minimal feedback, full menu panel delays to encourage quick retry"
---

## Description
After player death, minimize time to restart. No loading screens, no menu navigation.

## Context
Research: 'Near-instant restart after failure - Menus getting in the way antagonizes frustrated players.' Death should be a speedbump, not a wall. The faster players can try again, the more likely they continue.

## Implementation
1. On death: brief fade to black (0.3s)
2. Skip death screen for quick respawn option
3. Add 'Retry' button that:
   - Respawns player at surface spawn point
   - Clears inventory (death penalty applied)
   - Restores HP to full
   - Does NOT reload scene (just repositions)
4. 'View Stats' button for those who want death screen
5. Player can start digging within 2 seconds of death

## Affected Files
- scripts/ui/death_screen.gd - Add quick retry flow
- scripts/player/player.gd - respawn_at_surface() method
- scripts/autoload/game_manager.gd - respawn logic

## Verify
- [ ] Death to dig-again takes under 3 seconds (time this!)
- [ ] Player spawns at surface with empty inventory
- [ ] HP is full
- [ ] Game state is correct (depth 0, correct position)
- [ ] Optional: view full death stats
