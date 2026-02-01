---
title: "implement: Safe return celebration when reaching surface with loot"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T01:33:00.705112-06:00"
---

## Description
Add satisfying feedback when player successfully returns to surface with inventory items. This completes the 'tension -> relief' arc of the core loop.

## Context
Research: 'Safe return should feel like victory.' The moment of emerging from underground with collected resources should feel earned. Dome Keeper and Deep Rock Galactic both have celebratory extraction moments.

## Implementation
1. Detect: player crosses from underground to surface
2. Check: inventory has at least 1 ore/gem item
3. Trigger celebration:
   - Brief 'whoosh' sound effect (relief/accomplishment)
   - Subtle golden glow around player (0.5s)
   - Toast: 'Safe!' or 'Cargo secured!' (varies by inventory value)
4. Scale feedback to cargo value:
   - Low value: simple sound + toast
   - Medium value: sound + particles
   - High value (>500 coins worth): triumphant fanfare + screen flash

## Affected Files
- scripts/player/player.gd - Detect surface crossing
- scripts/effects/safe_return_effect.tscn - Visual celebration
- scripts/autoload/sound_manager.gd - Celebration sounds
- scripts/ui/notification_manager.gd - Toast display

## Verify
- [ ] No celebration when inventory empty
- [ ] Simple celebration for small hauls
- [ ] Big celebration for jackpot hauls
- [ ] Celebration feels rewarding, not annoying
- [ ] Works when using ladders or wall-jumping up
