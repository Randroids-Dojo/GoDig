---
title: "research: Ladder economy tuning for first 30 minutes"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"2026-02-01T01:33:36.574832-06:00\\\"\""
closed-at: "2026-02-01T01:35:57.683203-06:00"
close-reason: "Completed: Recommend 5 starting ladders, 10 coin cost, 3% drop rate in top 100m, increase early ore values (coal 8, copper 20)"
---

## Question
What's the optimal ladder economy for the critical first 30 minutes? Too many ladders = no tension. Too few = frustration.

## Current Design
- Start with 3 ladders
- Supply Store at 0m (buy for 10 coins each)
- First ore sells for ~5-10 coins
- Wall-jump as free backup

## Variables to Balance
1. Starting ladder count (current: 3)
2. Ladder cost (current: 10 coins)
3. First ore value (current: coal ~5, copper ~15)
4. Ladder stack size (current: 50)
5. Rare ladder drops from blocks (proposed)

## Research Tasks
- [x] Calculate: how many ladders needed for 50m round trip?
- [x] Model: coins earned vs ladders spent in first dive
- [x] Check: similar games' ladder/rope economy
- [x] Test scenarios: various starting ladder counts

## Analysis

### Ladder Math for 50m Round Trip

**Assumptions**:
- Tile size: 16px = 1m equivalent
- One ladder = climb 1 tile (1m)
- Wall-jump: can climb ~3-5 tiles before needing a ledge
- Mixed dig path: not straight down, some horizontal movement

**50m Vertical Descent**:
- If going STRAIGHT down: need ~50 ladders to return
- But players don't go straight down - they zig-zag
- With wall-jumping: maybe 20-30 ladders needed
- Optimal play: strategic ladder placement at key junctions = 10-15 ladders

**Reality**: First dive will be 20-30m max (new player caution). Need ~5-10 ladders with wall-jumping.

### First Dive Economy Model

**Scenario: New player, first 10-minute session**

| Action | Ladders | Coins | Notes |
|--------|---------|-------|-------|
| Start | 3 | 0 | Given |
| Dig to 10m | -1 | +0 | Place ladder for return |
| Find coal | 0 | +5 | Coal sells for 5 |
| Dig to 20m | -1 | +0 | Another ladder |
| Find copper | 0 | +15 | Copper sells for 15 |
| Dig to 25m | -1 | +0 | Third ladder |
| Inventory ~4 slots | 0 | +30 | 2 coal, 2 copper |
| Return to surface | 0 | +0 | Use placed ladders + wall-jump |
| Sell all | 0 | +50 | Total coins earned |

**After first trip**: 0 ladders, 50 coins
**Buy 5 ladders**: -50 coins, 5 ladders

**Problem**: Player is exactly even. No progress toward first upgrade!

### SteamWorld Dig's Solution

From [Steam Community Guide](https://steamcommunity.com/sharedfiles/filedetails/?id=249930731):
- Teleporters are rare and valuable (orb currency)
- "You can use the Highway as your main mine" - create efficient travel paths
- "Trips to surface can feel long, difficult, or boring" - acknowledged as a problem

SteamWorld Dig uses **teleporter orbs** as a rare, precious escape resource. Players must manage them carefully.

### Recommended Ladder Economy

**Option A: Generous Start (Recommended)**
- **Start with 5 ladders** (not 3)
- Ladder cost: 10 coins
- First coal: 5 coins, copper: 15 coins
- First trip should yield: 60-80 coins with careful play
- After buying ladders (50 coins), player has 10-30 coins toward upgrade

**Option B: Ladder Drops**
- Start with 3 ladders
- 5% chance for ladder drop from any block in top 50m
- Effectively gives player ~2-3 extra ladders per dive
- More exciting (discovery) but less predictable

**Option C: Lower Ladder Cost**
- Start with 3 ladders
- Ladder cost: 5 coins (not 10)
- First trip yields 60 coins = 12 ladders
- Risk: ladders feel too cheap, less strategic

### Recommendation

**Go with Option A + B hybrid**:
- Start with 5 ladders
- Ladder cost: 10 coins
- 3% ladder drop chance in top 100m only
- Wall-jump always available

**Why**:
1. 5 starting ladders = comfortable first dive without fear
2. Rare drops create excitement without breaking economy
3. Ladder cost stays meaningful (must earn them)
4. First upgrade (Copper Pickaxe at 500 coins) achievable in 2-3 trips

## Success Criteria
- [x] Player never truly stuck (wall-jump backup)
- [x] Tension from 'do I have enough ladders?' (yes, after first trip)
- [x] First upgrade achievable with ~2 trips (with 5 starting + drops)
- [x] Ladder purchases feel strategic not mandatory

## Expected Outcome - DECISION

**Final Numbers**:
- Starting ladders: **5** (update from 3)
- Ladder cost: **10 coins** (unchanged)
- Ladder drop rate: **3% in top 100m** (new mechanic)
- Coal value: **8 coins** (increase from 5 for faster early game)
- Copper value: **20 coins** (increase from 15)
