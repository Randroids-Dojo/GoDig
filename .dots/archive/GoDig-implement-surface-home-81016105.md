---
title: "implement: Surface home base cozy signals"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-01T08:10:51.556743-06:00\\\"\""
closed-at: "2026-02-03T03:14:07.445759-06:00"
close-reason: "Added warm amber flash, dust particles, 'Welcome Home\\!' toast, music transition, and haptic feedback for cozy surface arrival"
---

Add visual and audio cues that make the surface feel like a safe, cozy home base to create tension/relief rhythm.

## Context
Dome Keeper feedback: 'If pressure is always max, it's just exhausting.' Research shows cozy mining games succeed by providing genuine relief moments. Our surface visits need to feel like coming home.

## Description
Add sensory signals when player returns to surface:
- Visual: Brighter lighting transition, warmer color palette
- Audio: Calming ambient music shift, bird sounds, wind
- UI: 'Safe!' badge briefly appears
- Camera: Subtle zoom out to show buildings (sense of ownership)
- HP: Begin regenerating visibly with satisfying ticks

## Affected Files
- scripts/player/player.gd - Surface detection
- scripts/autoload/audio_manager.gd - Music/ambient transitions
- scenes/levels/test_level.tscn - Surface ambient sounds
- scripts/ui/hud.gd - Safe arrival notification
- shaders/depth_tint.gdshader - Brightness adjustment

## Implementation Notes
- Transition should be gradual (over 0.5-1s), not instant
- Audio crossfade between underground tension and surface calm
- Consider particle effects (dust settling, sunshine rays)
- Works in contrast with underground tension (darker, ambient noise)

## Verify
- [ ] Music shifts when reaching surface
- [ ] Visual brightness increases noticeably
- [ ] 'Safe!' or 'Home!' notification appears briefly
- [ ] Underground areas feel distinctly different from surface
- [ ] Returning feels like relief, not just location change
