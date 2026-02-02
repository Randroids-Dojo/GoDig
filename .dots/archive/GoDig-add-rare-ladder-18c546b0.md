---
title: Add rare ladder/rope drops from mining blocks
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-01T00:40:08.566768-06:00\\\"\""
closed-at: "2026-02-02T02:46:02.897635-06:00"
close-reason: "Implemented rare traversal item drops: 3% ladder in 0-50m, 2% ladder + 1% rope in 50-100m, no drops below 100m to preserve shop economy"
---

## Context
Reward exploration with occasional traversal item drops.
Creates excitement and provides backup for players who don't buy enough.

**Priority upgraded from P3 to P2** based on Session 3 ladder economy research.

## Research Backing (Session 3)
- Ladder drops add variable reward excitement
- Creates "rescue moments" when player finds a ladder when low
- 3% drop rate in top 100m balances economy without breaking it
- Effectively gives player ~2-3 extra ladders per 25m dive

## Implementation
1. Add drop chance to ALL blocks (not just ore) in top 100m
2. Base rate: 3% chance for ladder
3. Rope drops: 1% chance, only below 50m
4. Depth scaling:
   - 0-50m: 3% ladder, 0% rope
   - 50-100m: 2% ladder, 1% rope
   - 100m+: 0% (must buy)
5. Show pickup notification with mini-celebration (players love free stuff)

## Files
- scripts/world/dirt_grid.gd (drop logic in _break_block)
- resources/drops/ladder_drop.tres (drop definition)
- scripts/effects/pickup_effect.gd (celebration for rare drops)

## Verify
- [ ] Ladder drops ~3% in top 50m
- [ ] Rope drops ~1% in 50-100m
- [ ] No drops below 100m
- [ ] Pickup notification shows
- [ ] Drop doesn't break ladder economy (test: is buying ladders still strategic?)
- [ ] Drop animation feels rewarding
