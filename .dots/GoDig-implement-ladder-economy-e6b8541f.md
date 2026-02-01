---
title: "implement: Ladder economy abundance/scarcity cycle tuning"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T09:52:19.930950-06:00"
---

## Description
Tune ladder economy to create satisfying abundance/scarcity rhythm across game progression.

## Context
Mobile economy research (2025) shows: 'Alternate between resource abundance (rewarding) and scarcity (planning/purchasing).' 62% of players abandon due to unfair scarcity. Our ladders are the core scarcity lever.

## Implementation
1. Early game (first 5 mins): Abundance
   - 5 starting ladders (guaranteed exploration)
   - First shop visit affordable (~3 more ladders)
   - Player feels capable, not restricted
2. Mid-game (5-30 mins): Tension
   - Ladder cost increases with shop tier
   - Depth-based danger creates planning decisions
   - 'Just enough' ladders to reach goals with good planning
3. Late-game (30+ mins): Relief via infrastructure
   - Elevator unlocks reduce ladder dependency
   - Teleport scrolls for emergency bailout
   - Premium feel: 'I've earned this convenience'

## Affected Files
- resources/items/ladder.tres (base cost)
- scripts/shops/supply_store.gd (pricing curve)
- scripts/player/inventory.gd (starting items)

## Verify
- [ ] New players never stuck in first 5 minutes
- [ ] Mid-game creates meaningful ladder decisions
- [ ] Late-game elevator feels like genuine relief
- [ ] No 'unfair' resource shortage complaints
