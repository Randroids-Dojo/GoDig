---
title: "implement: Surface home base comfort signals"
status: open
priority: 3
issue-type: task
created-at: "2026-02-01T02:09:45.835761-06:00"
---

## Description
Make the surface feel like 'home' - safe, welcoming, restorative. Creates contrast with underground tension.

## Context
Research: 'Home Base Comfort - Surface represents safety. Contrast makes surface feel rewarding.' The cycle between danger (underground) and comfort (surface) creates satisfying rhythm.

## Implementation
1. Visual signals at surface:
   - Brighter ambient light (versus underground darkness)
   - Optional: subtle warm color overlay
   - Shop buildings visible and inviting
2. Audio signals:
   - Calm ambient music (birds? wind?)
   - Different from underground tension music
3. Mechanical signals:
   - HP regeneration (already implemented)
   - 'Safe zone' indicator in HUD (green icon?)
4. Transition feel:
   - When crossing from underground to surface: brief relief sound
   - Optional: very subtle screen brighten effect

## Affected Files
- scripts/autoload/lighting_manager.gd - Surface vs underground lighting
- scripts/autoload/sound_manager.gd - Ambient music zones
- scripts/ui/hud.gd - Safe zone indicator
- scripts/player/player.gd - Surface crossing detection

## Verify
- [ ] Surface FEELS different from underground
- [ ] Lighting is noticeably brighter
- [ ] Sound is noticeably calmer
- [ ] HP regen visible in HUD
- [ ] Transition moment is perceptible
