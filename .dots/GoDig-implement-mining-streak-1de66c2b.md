---
title: "implement: Mining streak/combo subtle feedback"
status: open
priority: 3
issue-type: task
created-at: "2026-02-01T02:09:36.759012-06:00"
---

## Description
Add subtle audio/visual feedback when player mines multiple blocks in quick succession. Creates rhythm and flow state without being distracting.

## Context
Research on game feel: 'Sound variation: Randomize pitch/volume to avoid repetition.' Mining is constant - effects must not fatigue players. Reserve intense effects for rare finds. But rhythm building through subtle combos adds satisfaction.

## Implementation
1. Track blocks broken within 2-second window
2. Streak counter: 1, 2, 3, 4, 5+
3. Feedback scaling:
   - 1-2 blocks: normal sound
   - 3 blocks: pitch up slightly (+5%)
   - 4 blocks: pitch up (+10%), tiny particle multiplier
   - 5+ blocks: pitch up (+15%), 'in the zone' subtle screen pulse
4. Reset streak after 2s of no mining or on damage
5. Critical: all effects are SUBTLE - this is background satisfaction

## Affected Files
- scripts/autoload/mining_bonus_manager.gd - Streak tracking
- scripts/autoload/sound_manager.gd - Pitch variation
- scripts/effects/mining_particles.gd - Streak multiplier
- scripts/ui/hud.gd - Optional: tiny combo counter (can disable)

## Verify
- [ ] Streak builds with consecutive mining
- [ ] Sound pitch increases noticeably but not annoyingly
- [ ] Effects reset after pause
- [ ] 5+ blocks feels 'in the zone'
- [ ] Does NOT distract or fatigue after 5 minutes
