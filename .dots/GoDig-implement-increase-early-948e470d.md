---
title: "implement: Increase early ore sell values for faster first upgrade"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T01:14:18.224330-06:00"
---

Ore values too low for satisfying early progression. Based on Session 3 ladder economy research:
- First trip with 5 ladders should yield 60-80 coins
- First upgrade (Copper Pickaxe 500 coins) achievable in 2-3 trips
- Target: First upgrade in 3-5 minutes

## Changes
1. Coal: current -> $8 (common ore should still feel rewarding)
2. Copper: current -> $20 (main early-game income)
3. Iron: current -> $25 (unlocks at 50m, slightly better)

## Research Backing
From ladder economy model:
- 5 starting ladders
- Typical first trip: 2-3 coal + 2-3 copper
- With new values: 2×8 + 2×20 = 56 coins minimum
- After buying 5 ladders (50 coins), player has 6+ coins toward upgrade
- With luck (more ores): 80-100 coins per trip = upgrade in 2-3 trips

## Files
- resources/ores/coal.tres (sell_value: 8)
- resources/ores/copper.tres (sell_value: 20)
- resources/ores/iron.tres (sell_value: 25)

## Verify
- [ ] Coal sells for $8 at General Store
- [ ] Copper sells for $20 at General Store
- [ ] First trip earns ~$60-80
- [ ] Copper Pickaxe (500 coins) affordable in ~6 trips max
- [ ] Economy doesn't break mid-game (iron/silver still valuable)
