---
title: "research: Analyze core loop timing and session pacing"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"2026-02-01T01:08:14.704201-06:00\\\"\""
closed-at: "2026-02-01T01:14:24.567030-06:00"
close-reason: "Completed timing analysis. Found 8-min to first upgrade (target 3-5 min). Created implementation dots: increase ore values and reduce Copper Pickaxe cost."
---

Measure and optimize the core loop timing based on research findings. Target: 5-15 minute ideal sessions with natural stopping points.

## Key Findings from Research
- Dome Keeper: 2-3 minute cycles work well
- Idle games: 18% stickiness vs 10.5% for other hyper-casual
- Mining games: 'Just one more layer' psychology critical
- Full inventory should happen every 3-8 minutes early game

## Analysis Results

### Current Game Constants
| Parameter | Value |
|-----------|-------|
| Starting inventory | 8 slots |
| Block size | 128px |
| Rusty Pickaxe damage | 10 |
| Tap mine interval | 0.15s |
| Copper Pickaxe cost | $500 |
| Copper Pickaxe unlock | 25m depth |

### Layer Hardness Progression
| Layer | Depth | Base Hardness | Hits (Rusty) | Break Time |
|-------|-------|---------------|--------------|------------|
| Topsoil | 0-30m | 10 | 1 | 0.15s |
| Clay | 30-80m | 15 | 2 | 0.30s |
| Subsoil | 80-180m | 20 | 2 | 0.30s |

### Ore Economics (Early Game)
| Ore | Sell Value | Spawn Depth | Est. Frequency |
|-----|------------|-------------|----------------|
| Coal | $1 | 0-500m | 60% of ores |
| Copper | $5 | 10-300m | 30% of ores |
| Iron | $10 | 50m+ | 10% of ores |

**Weighted average ore value**: $3.10
**Ore spawn rate**: ~20% of blocks

### Timing Analysis

#### 1. Block Breaking Speed
- Topsoil: 0.15s per block (instant feel)
- Clay: 0.30s per block (noticeable but fast)
- Stone: 0.45s per block (strategic choice)

**Verdict**: Block breaking feels snappy. GOOD.

#### 2. Inventory Fill Time
With 8 slots and ~20% ore rate:
- Need ~40 blocks dug to collect ~8 ore
- At 0.15s per block = ~6 seconds digging
- Add movement, exploration = ~45s per mini-expedition

**Issue**: Inventory fills VERY slowly with current ore rates.

#### 3. First Upgrade Timeline
To afford $500 Copper Pickaxe:
- Average ore value: $3.10
- Need ~161 ore to reach $500
- At 20% ore rate, need ~805 blocks

With current pacing:
- ~75 blocks per trip = 15 ore = $46
- Need ~11 trips
- At ~45s per trip = ~8 minutes

**Verdict**: 8 minutes to first upgrade is slightly long.
Target is 2-5 minutes. NEEDS TUNING.

#### 4. Session Length
Current cycle: ~45-60 seconds per dive
Target: 3-8 minutes per session

**Verdict**: Sessions too short OR inventory fills too slowly.

## Issues Identified

### Issue 1: Coal Value Too Low
Coal at $1 feels unrewarding. Players get excited finding ore but disappointed at sell price.

**Fix**: Increase coal to $3-5

### Issue 2: Ore Spawn Rate May Be Low
20% ore rate means lots of "empty" digging.

**Fix Options**:
- Increase early game ore rate to 25-30%
- Add early ore veins (guaranteed coal clusters at 5-15m)
- Or: make dirt blocks occasionally drop coins ($1-2)

### Issue 3: Time to First Upgrade
8 minutes exceeds 2-5 minute target.

**Fix Options**:
- Reduce Copper Pickaxe cost from $500 to $200-300
- Increase early ore values
- Add starting coins ($100 head start)

### Issue 4: Return Trip Tedium
Wall-jumping up 25-50m takes time, especially for new players who don't know the technique well.

**Fix**: Starting ladders + ladder drops solve this.

## Recommendations

### Immediate Fixes (No New Systems)
1. **Coal value**: $1 -> $5 (5x increase)
2. **Copper value**: $5 -> $8
3. **Copper Pickaxe cost**: $500 -> $250

**Effect**: First upgrade in ~3 minutes

### Medium-Term Improvements
1. Add guaranteed coal vein at 10m depth (tutorial area)
2. Increase ore rate in topsoil (0-30m) to 30%
3. Starting coins: $50 (enough to buy 1 ladder immediately)

### Implementation Dots Needed
1. `implement: Tune early ore values for faster progression`
2. `implement: Add guaranteed ore vein for tutorial`
3. Consider reducing Copper Pickaxe unlock depth (25m -> 15m)

## Session Flow Diagram

```
NEW GAME START
    │
    ├─> Tutorial popup: "Dig down to find ores!"
    │
    ├─> Depth 5-10m: Hit guaranteed coal vein (excitement!)
    │         Collect 3-5 coal ($15-25)
    │
    ├─> Depth 10-15m: Find copper cluster
    │         Collect 2-3 copper ($16-24)
    │
    ├─> Depth 15-20m: Inventory ~50% full
    │         Optional: place starting ladder
    │
    ├─> Depth 20-25m: Inventory full OR low HP
    │         NATURAL BREAK POINT: Return to surface
    │
    └─> SURFACE: Sell ores (~$80-120)
              │
              ├─> Can afford: 2-3 ladders ($100-150)
              │   OR
              └─> After 2 trips: Copper Pickaxe ($250)
                  FIRST UPGRADE ACHIEVED (~3-5 min)
```

## Deliverables Complete
- [x] Block break timing analysis
- [x] Ore economics analysis
- [x] First upgrade timeline
- [x] Session flow diagram
- [x] Recommendations

## Follow-Up Dots to Create
- `implement: Increase early ore sell values`
- `implement: Add guaranteed tutorial ore vein`
- `implement: Reduce Copper Pickaxe cost to $250`
