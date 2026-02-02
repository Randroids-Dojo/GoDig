---
title: "implement: Upgrade instant feel - dramatic first upgrade impact"
status: closed
priority: 0
issue-type: task
created-at: "\"\\\"2026-02-01T09:44:49.127847-06:00\\\"\""
closed-at: "2026-02-01T23:03:34.019408-06:00"
close-reason: Implemented dramatic first upgrade feel - Copper Pickaxe now 50% faster (1.5x), added tier-specific audio pitch, first-dig celebration after upgrade, fixed progression for all pickaxes
---

Research Session 23 emphasized that upgrades must be FELT, not just seen in stats. The first pickaxe upgrade is critical for retention.

## Context
Research findings:
- Dark Souls: 'immensely satisfying to return to areas that kicked your ass once levelled up'
- 'You really feel the journey from fragile weakling to god slayer'
- Visual changes matter: Bioshock guns transform aesthetically with upgrades
- First upgrade must feel TRANSFORMATIVE - not 10% better, but 50%+ noticeable

## Specification

### First Upgrade (Copper Pickaxe)
Current: Stone Pickaxe takes 3 hits per block
Target: Copper Pickaxe takes 2 hits per block (33% reduction)

Plus:
- Noticeably faster swing animation
- Different dig sound (higher pitch, more satisfying)
- Different particle effects (more sparks)
- Brief 'power up' moment when first equipping

### Implementation Approach
1. Ensure upgrade stat change is dramatic enough to notice
2. Add visual/audio differences per tier
3. Consider brief 'test run' after upgrade - dig a practice block to feel difference
4. Store 'just upgraded' flag to trigger celebration on first dig

## Affected Files
- Pickaxe resource definitions - ensure dramatic stat jumps
- Mining.gd - tier-specific dig sounds/particles
- Shop/upgrade UI - add brief celebration/preview on purchase
- Player animation - different swing speed per tier

## Verify
- [ ] Build succeeds
- [ ] Copper Pickaxe feels noticeably faster than Stone
- [ ] Audio changes between tiers
- [ ] Particle effects differ between tiers
- [ ] First dig after upgrade triggers micro-celebration
