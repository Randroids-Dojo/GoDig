---
title: "implement: Subtle mining feedback vs reserved juice for discovery"
status: closed
priority: 1
issue-type: task
created-at: "\"2026-02-01T09:08:41.407059-06:00\""
closed-at: "2026-02-02T01:10:58.605126-06:00"
close-reason: Implemented as part of GoDig-implement-two-tier-614931d2 - same two-tier juice system spec
---

## Description

Implement a two-tier juice system: subtle constant feedback for regular mining, reserved dramatic effects for ore discovery and upgrades.

## Context

Session 18 research:
- Mining is CONSTANT - effects must not fatigue players
- "Reserve intense effects for special occasions"
- "Juice can't fix bad design" - core loop must work without any juice first
- Vampire Survivors insight: "Minimal input but maximum feedback"

## Two-Tier System

### Tier 1: Subtle Constant Feedback (Mining)
- Tiny dust particles on block break (2-4 particles)
- Soft "crunch" sound with slight pitch variation
- Micro screen shake (0.5-1 pixel, optional)
- Quick brightness flash on broken block (50ms)

### Tier 2: Reserved Discovery Juice (Ore/Upgrades)
- Burst of colored particles matching ore type (8-12 particles)
- Distinct "discovery" chime + ore-specific sound
- Medium screen shake (2-3 pixels, 100ms)
- Glow effect radiating from ore
- HUD popup with ore name + value
- Haptic feedback (short burst on mobile)

### Tier 3: Jackpot Moments (Rare/Legendary)
- Full particle explosion (20+ particles)
- Unique legendary sound effect
- Dramatic screen shake (4-5 pixels, 200ms)
- Screen flash with ore color tint
- Large floating text with celebration words
- Strong haptic feedback
- Brief time slowdown (100ms)

## Affected Files

- `scripts/effects/mining_feedback.gd` - Core feedback system
- `scripts/effects/discovery_celebration.gd` - Ore discovery effects
- `scripts/effects/jackpot_moment.gd` - Rare find celebration
- `resources/audio/sfx/mining/` - Sound variations
- `resources/particles/` - Particle definitions

## Verify

- [ ] Regular mining feels satisfying but not overwhelming
- [ ] Ore discovery is noticeably more exciting than regular blocks
- [ ] Rare ore discovery feels like hitting the jackpot
- [ ] 30 minutes of mining doesn't cause visual fatigue
- [ ] All effects work with accessibility settings
