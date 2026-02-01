---
title: "implement: First ore discovery celebration"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T01:33:09.750595-06:00"
---

## Description
Add special celebration for the very first ore discovered in a new game. This anchors the player's first positive memory.

## Context
Research: 'First few minutes determine whether user stays or churns.' The first ore discovery is a critical retention moment. It must feel amazing - sparkles, sounds, maybe even a brief tutorial callout explaining the loop.

## Implementation
1. Track flag in SaveManager: first_ore_discovered (defaults false)
2. On first ore pickup, if flag is false:
   - Extra particle burst (golden sparkles)
   - Special 'discovery' sound (different from normal pickup)
   - Brief pause (0.2s screen freeze for impact)
   - Tutorial toast: 'Your first ore! Sell it at the General Store.'
   - Set flag to true (persisted)
3. Subsequent ore pickups use normal feedback

## Affected Files
- scripts/autoload/save_manager.gd - Track first_ore_discovered flag
- scripts/player/player.gd - Check flag on ore pickup
- scripts/effects/first_discovery.tscn - Special celebration scene
- scripts/ui/tutorial_manager.gd - Tutorial toast

## Verify
- [ ] First ore triggers special celebration
- [ ] Subsequent ores use normal pickup feedback
- [ ] Flag persists across sessions
- [ ] New game resets the flag
- [ ] Tutorial toast is helpful not annoying
