---
title: "implement: Ore discovery micro-celebration system"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T08:11:29.025956-06:00"
---

Implement Balatro-style variable reward satisfaction for each ore discovery.

## Context
Balatro won GDCA 2025 Game of the Year with 'making numbers go up' satisfaction. Each card draw is a micro-uncertainty moment. Our block mining should have similar micro-anticipation/reward cycle.

## Description
Create a tiered celebration system for ore discovery:

**Common Ore (Coal, Copper)**:
- Subtle sparkle effect
- Quiet 'ding' sound
- Small +1 floating text

**Uncommon Ore (Iron, Silver)**:
- Moderate particle burst
- Satisfying 'chime' sound
- Bouncing number popup
- Brief screen flash

**Rare Ore (Gold)**:
- Full particle explosion
- Chord sound effect
- Large animated number
- Haptic feedback
- Brief pause (50ms) for impact

**Epic/Legendary (Gems)**:
- Jackpot celebration
- Music sting
- Screen shake
- Extended haptic rumble
- 'Jackpot!' label
- Glow effect persists briefly

## Affected Files
- scripts/world/ore_block.gd - Discovery event
- scenes/effects/ore_discovery.tscn - Particle effects
- scripts/autoload/audio_manager.gd - Sound tiers
- scripts/ui/floating_text.gd - Number animations
- scripts/utils/haptics.gd - Haptic patterns

## Implementation Notes
- Effects should scale with ore rarity, not overwhelm
- Frequent discoveries (coal) must not fatigue
- Rare discoveries should feel SPECIAL
- Consider combo multiplier for consecutive finds

## Verify
- [ ] Coal discovery feels satisfying but subtle
- [ ] Gold discovery feels exciting
- [ ] Gem discovery feels like winning lottery
- [ ] No effect fatigue after 50+ discoveries
- [ ] Haptics work on mobile
