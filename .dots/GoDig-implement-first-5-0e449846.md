---
title: "implement: First 5 minute economy tuning"
status: open
priority: 0
issue-type: task
created-at: "2026-02-01T07:53:09.516546-06:00"
---

## Description

Balance ore values, upgrade costs, and starting resources to ensure a new player can complete their first upgrade within 5 minutes of gameplay. This is the most critical retention gate.

## Context

From Session 8 research:
- "First few minutes determine whether user stays or churns"
- Players who complete first upgrade cycle have 88% higher retention
- Worst performing games lose 46% of installs by minute 5
- Core loop (action -> reward -> progression) must complete in 3-5 minutes

## Current Values (Need Analysis)

Check these files for current economy values:
- `resources/tools/copper_pickaxe.tres` - Cost (target: achievable in 2-3 trips)
- `resources/ores/*.tres` - Sell values for coal, copper
- `scripts/surface.gd` - Starting buildings available

## Proposed Economy Model

### Trip 1 (with 5 starting ladders)
- Reach: 20-25m depth
- Collect: ~8 coal (avg 3 coins each) + 2 copper (avg 8 coins each)
- Return: Use 3-4 ladders, wall-jump the rest
- Sell: ~40 coins
- Buy: 3 replacement ladders (30 coins)
- Net: +10 coins (total: 10)

### Trip 2
- Now have 4-5 ladders
- Reach: 25-35m depth
- Collect: ~4 coal + 4 copper
- Return: Easier with existing ladder infrastructure
- Sell: ~50 coins
- Net: +30 coins after restocking (total: 40)

### Trip 3
- Comfortable ladder supply (5+)
- Reach: 35-50m depth (iron appears!)
- Collect: 2 coal, 3 copper, 2 iron
- Sell: ~80 coins
- Net: +60 coins (total: ~100)

### Trip 4 (if needed)
- Similar to Trip 3
- Total should approach 150-200 coins

### Target First Upgrade Cost
Copper Pickaxe should cost: **150-200 coins**
- Achievable in 3-4 trips
- 3-4 trips at 1.5 minutes each = 4.5-6 minutes
- Within the 5-minute target (with good play)

## Implementation

1. Review current ore sell values:
   - Coal: should be ~3-5 coins
   - Copper: should be ~8-12 coins
   - Iron: should be ~15-20 coins

2. Review Copper Pickaxe cost:
   - Current: ? (check resources/tools/)
   - Target: 150-200 coins

3. If values don't match model, adjust:
   - `resources/ores/coal.tres`
   - `resources/ores/copper.tres`
   - `resources/tools/copper_pickaxe.tres`

4. Add starting coins if needed (0 is fine, forces first trip)

## Affected Files

- `resources/ores/coal.tres`
- `resources/ores/copper_ore.tres`
- `resources/tools/copper_pickaxe.tres`
- `scripts/surface.gd` (if starting coins needed)

## Verify

- [ ] Start new game with 5 ladders
- [ ] Time first 5 minutes of gameplay
- [ ] Track coins earned per trip
- [ ] Confirm first upgrade purchasable within 5-6 minutes
- [ ] Confirm economy feels rewarding (not grindy)
- [ ] Each trip should feel profitable, not break-even

## Dependencies

- `GoDig-give-player-2-8f4b2912` (5 starting ladders)
- `GoDig-move-supply-store-61eb95a1` (Supply Store at 0m)

## Related Specs (Consolidates)

This spec provides the holistic view. These related specs cover specific pieces:
- `GoDig-implement-increase-early-948e470d` - Increase ore sell values
- `GoDig-implement-reduce-copper-cdb35c77` - Reduce Copper Pickaxe cost

The implementation should consider BOTH levers (ore value AND upgrade cost) to hit the 5-minute target.
