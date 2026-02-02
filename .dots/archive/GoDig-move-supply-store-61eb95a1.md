---
title: Move Supply Store unlock to 0m or add ladders to General Store
status: closed
priority: 1
issue-type: task
created-at: "\"2026-02-01T00:39:59.929745-06:00\""
closed-at: "2026-02-01T22:13:16.457208-06:00"
close-reason: Already implemented in game_manager.gd. Supply Store unlock_depth is 0 in BUILDING_UNLOCK_ORDER.
---

## Context
Supply Store currently unlocks at 100m depth, but players need ladders by 10-25m.

**Critical for core loop**: Players MUST have access to ladders early to learn the risk/return mechanic. This is THE fundamental tension in mining games - digging deeper vs having escape resources.

## Research Insights
- SteamWorld Dig: Wall-jumping transformed "stuck" from failure to challenge
- Dome Keeper: Resource management creates strategic decisions
- Mining game psychology: "Investment protection" drives return trips

## Recommendation: Option A (simplest)
Change Supply Store unlock from 100m to 0m. This is the cleanest solution because:
1. Players see dedicated building for supplies
2. No UI complexity added to General Store
3. Natural discovery: "Oh, that's where I buy ladders"

## Implementation
1. In `scripts/surface.gd`, change BUILDING_SLOTS line 17:
   ```gdscript
   {"x": 512, "unlock_depth": 0, "type": "supply_store", "name": "Supply Store"},
   ```

2. Verify Supply Store is visible on new game start

## Files to modify
- scripts/surface.gd (BUILDING_SLOTS unlock_depth on line 17)

## Why This is P0 (Critical for Core Loop)
From Session 4 research:
- "Worst performing games lose 46% of installs by minute 5"
- First complete loop (dig -> sell -> upgrade) must happen in under 5 minutes
- Without Supply Store at 0m, players can't buy escape resources before getting stuck
- This is THE gate blocking the entire core loop from functioning

## Verify
- [ ] Supply Store building visible at game start
- [ ] Player can enter Supply Store immediately
- [ ] Ladders purchasable for $10 each
- [ ] Player can afford 3+ ladders after selling first trip's ore
- [ ] Tutorial mentions Supply Store exists
