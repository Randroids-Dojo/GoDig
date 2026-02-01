---
title: "implement: Two-tier juice system - subtle mining vs discovery celebration"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T09:36:35.068373-06:00"
---

## Description

Reserve intense visual/audio effects for discoveries and upgrades. Regular mining should have subtle, satisfying feedback only.

## Context

Research shows over-juicing harms game design. 'If combat lacks strategic depth, designers might just add more screen shake.' Animation communicates weight better than particle effects. Players get fatigued by constant intense feedback.

## Implementation

### Tier 1: Subtle Mining Feedback (Every Block)
- Small dust particle on hit (2-4 particles)
- Quiet crisp tap sound
- NO screen shake for normal blocks
- Minimal visual flash

### Tier 2: Discovery Celebration (Ore Found)
- Larger particle burst (10-15 particles with glow)
- Distinct 'discovery' sound (higher pitch, sparkle)
- Brief hitstop (0.05s)
- Subtle screen shake (intensity 2-3)
- Ore shimmer effect

### Tier 3: Major Events (Upgrades, Depth Milestones)
- Full celebration (confetti, coin cascade, screen flash)
- Extended sound effect
- Stronger screen shake (intensity 4-5)
- UI celebration overlay

## Affected Files
- scripts/player/player.gd - Mining feedback calls
- scripts/effects/particle_manager.gd - Tiered particle systems
- scripts/audio/audio_manager.gd - Sound categories
- resources/audio/sfx/ - Tiered sound files

## Verify
- [ ] Regular block mining feels satisfying but not overwhelming
- [ ] Ore discovery creates noticeable excitement spike
- [ ] After 5 minutes of play, feedback doesn't feel repetitive
- [ ] Contrast between tiers is clear

