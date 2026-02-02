---
title: "implement: First upgrade dramatic impact - Copper Pickaxe feels transformative"
status: closed
priority: 0
issue-type: task
created-at: "\"2026-02-01T09:58:35.146449-06:00\""
closed-at: "2026-02-01T09:58:52.010616-06:00"
close-reason: Duplicate of GoDig-implement-upgrade-instant-a98283f7 which already specifies dramatic first upgrade impact. Session 25 research reinforces those findings.
---

## Description
The first pickaxe upgrade (Copper) must feel dramatically different from the starting pickaxe. Not 10% better - visibly, audibly, and mechanically transformative.

## Context
Research shows: 'First upgrade should feel transformative. Not 10% better - 50%+ noticeable improvement.' SteamWorld Dig is praised because each upgrade has 'noticeable effect.' Mobile games that fail at first upgrade lose players before the hook sets.

## Affected Files
- `resources/items/pickaxes/` - Pickaxe definitions
- `scripts/player/mining_controller.gd` - Mining speed/power
- `scripts/effects/mining_effects.gd` - Visual/audio feedback per tier
- `resources/audio/sfx/` - Distinct pickaxe sounds

## Implementation Notes
- Copper Pickaxe should break basic blocks in 1 hit (vs 2+ for starter)
- Unique swing animation for Copper (faster, more confident)
- Distinct impact sound (deeper, more satisfying thunk)
- Different particle colors/sizes for each tier
- Brief celebratory effect on first use after purchase
- Consider 'A' vs 'B' side-by-side comparison in shop

## Verify
- [ ] Stone Pickaxe breaks Dirt in 2 hits
- [ ] Copper Pickaxe breaks Dirt in 1 hit (50%+ improvement)
- [ ] Visual difference is immediately noticeable
- [ ] Sound is distinctly different between tiers
- [ ] Playtester reaction: 'Wow, this is way better'
