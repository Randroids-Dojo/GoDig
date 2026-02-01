---
title: "implement: Ore discovery feedback enhancement"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T01:08:42.225890-06:00"
---

Enhance the moment of discovering ore - the core 'variable reward' hit.

## Research Findings
- 'Variable Ratio Reinforcement' makes discoveries more compelling
- Ore discovery should trigger dopamine: visual + audio + haptic
- Rare finds need BIG celebration (jackpot moments)
- Sound design: satisfying 'discovery chimes' per material

## Implementation
1. Enhance ore reveal animation (glow pulse before break)
2. Add tier-based discovery sounds (common/uncommon/rare/epic)
3. Screen flash on rare+ discoveries
4. Haptic feedback: light/medium/heavy by rarity
5. Floating text with item name + value

## Files
- scripts/world/dirt_grid.gd (discovery detection)
- scripts/effects/ore_sparkle.gd (enhance glow)
- scripts/autoload/sound_manager.gd (discovery sounds)
- scripts/autoload/haptic_feedback.gd (rarity-based vibration)
- scripts/ui/floating_text.gd (item reveal text)

## Verify
- [ ] Ore blocks have visible sparkle/glow
- [ ] Breaking ore plays tier-appropriate sound
- [ ] Rare ores trigger screen flash
- [ ] Haptic feedback works on mobile
- [ ] Floating text shows item name
