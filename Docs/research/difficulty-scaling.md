# Difficulty Scaling Research

## Core Challenge: Infinite Depth Balance

The game has infinite procedural depth, so difficulty must scale infinitely while remaining fun and achievable with proper upgrades.

## Scaling Dimensions

### 1. Block Hardness

#### Hardness Formula
```gdscript
func calculate_hardness(depth: int, block_type: String) -> float:
    var base_hardness = BLOCK_BASE_HARDNESS[block_type]
    var depth_multiplier = 1.0 + (depth / 100.0) * 0.5  # +50% per 100m
    return base_hardness * depth_multiplier
```

#### Hardness Curve
| Depth | Dirt | Stone | Granite | Obsidian |
|-------|------|-------|---------|----------|
| 0m | 10 | 30 | 60 | 100 |
| 100m | 15 | 45 | 90 | 150 |
| 500m | 35 | 105 | 210 | 350 |
| 1000m | 60 | 180 | 360 | 600 |
| 2000m | 110 | 330 | 660 | 1100 |

#### Design Goal
Player should always be able to dig, but deeper = slower without upgrades.

### 2. Tool Power Scaling

#### Tool Damage Progression
| Tier | Tool | Damage | Unlock Depth | Cost |
|------|------|--------|--------------|------|
| 1 | Rusty Pickaxe | 10 | Start | Free |
| 2 | Copper Pickaxe | 25 | 50m | 500 |
| 3 | Iron Pickaxe | 50 | 150m | 2,000 |
| 4 | Steel Pickaxe | 100 | 300m | 8,000 |
| 5 | Silver Pickaxe | 180 | 500m | 25,000 |
| 6 | Gold Pickaxe | 300 | 750m | 75,000 |
| 7 | Mythril Pickaxe | 500 | 1000m | 200,000 |
| 8 | Diamond Pickaxe | 800 | 1500m | 500,000 |
| 9 | Void Pickaxe | 1200 | 2000m | 1,500,000 |

#### Balance Principle
Tool at depth X should dig layer X blocks in ~1 second, deeper blocks take longer.

### 3. Break Time Calculation

```gdscript
func get_break_time(block_hardness: float, tool_damage: float) -> float:
    var base_time = block_hardness / tool_damage
    var min_time = 0.1  # Never instant
    var max_time = 5.0  # Never too long
    return clamp(base_time, min_time, max_time)
```

#### Expected Break Times
| Scenario | Break Time | Feel |
|----------|------------|------|
| Right tool for depth | 0.5-1.0s | Satisfying |
| Slightly underpowered | 1.0-2.0s | Challenging |
| Very underpowered | 2.0-4.0s | Tedious (signal upgrade needed) |
| Overpowered | 0.2-0.5s | Powerful, rewarding |

## Avoiding Difficulty Walls

### Problem: Hard Cutoffs
Bad: "You need Tier 5 pickaxe to dig past 500m"
This creates frustrating walls.

### Solution: Soft Gates
Good: "You CAN dig at 500m with Tier 4, but it's slow. Tier 5 makes it comfortable."

```gdscript
# No hard requirements, just efficiency curves
func is_tool_sufficient(tool_tier: int, depth: int) -> String:
    var recommended_tier = get_recommended_tier(depth)
    var tier_diff = recommended_tier - tool_tier

    if tier_diff <= 0:
        return "optimal"
    elif tier_diff == 1:
        return "challenging"
    elif tier_diff == 2:
        return "slow"
    else:
        return "very_slow"  # Still possible!
```

## Layer Transitions

### Gradual Introduction
Each layer type appears gradually, not suddenly.

```
Depth 0-50m:    100% Dirt
Depth 50-100m:  80% Dirt, 20% Clay
Depth 100-200m: 50% Clay, 50% Stone
Depth 200-400m: 80% Stone, 20% Granite
... etc
```

### Transition Zones
20-50 tile transition zones where layers blend.

## Resource Value Scaling

### Problem: Deep Resources Must Be Worth It
If resources at 1000m aren't significantly better than 100m, why go deep?

### Solution: Exponential Value
```gdscript
func get_ore_value(ore_type: String, found_depth: int) -> int:
    var base_value = ORE_BASE_VALUES[ore_type]
    var depth_bonus = 1.0 + (found_depth / 500.0) * 0.5  # +50% per 500m
    return int(base_value * depth_bonus)
```

### Value Tiers
| Ore | Base Value | At 500m | At 1000m | At 2000m |
|-----|------------|---------|----------|----------|
| Coal | 5 | 7 | 10 | 15 |
| Iron | 15 | 22 | 30 | 45 |
| Gold | 50 | 75 | 100 | 150 |
| Diamond | 200 | 300 | 400 | 600 |
| Void Crystal | 1000 | 1500 | 2000 | 3000 |

## Hazard Scaling

### Environmental Hazards by Depth
| Depth | Hazards | Mitigation |
|-------|---------|------------|
| 0-200m | None | N/A |
| 200-500m | Water pools | Slow movement only |
| 500-1000m | Gas pockets | Gas mask (shop) |
| 1000-1500m | Cave-ins | Helmet upgrade |
| 1500-2000m | Lava pools | Heat suit |
| 2000m+ | Void corruption | Void resistance |

### Hazard Frequency
```gdscript
func get_hazard_chance(depth: int, hazard_type: String) -> float:
    var start_depth = HAZARD_START_DEPTHS[hazard_type]
    if depth < start_depth:
        return 0.0

    var depth_into_zone = depth - start_depth
    var base_chance = 0.01  # 1% at zone start
    var max_chance = 0.15   # 15% max

    return min(base_chance + (depth_into_zone / 1000.0) * 0.1, max_chance)
```

## Player Power Curve

### Early Game (0-200m)
- Quick progression
- Frequent upgrades
- Learning mechanics
- Low frustration

### Mid Game (200-1000m)
- Slower progression
- Meaningful upgrade choices
- Introduce all mechanics
- Strategic play emerges

### Late Game (1000-2000m)
- Long-term goals
- Prestige consideration
- Mastery mechanics
- Automation options

### End Game (2000m+)
- Prestige loops
- Min-maxing
- Leaderboard competition
- Content extensions

## Upgrade Pacing

### Time Between Meaningful Upgrades
| Phase | Target Time | Examples |
|-------|-------------|----------|
| Tutorial | 2-5 min | First pickaxe upgrade |
| Early | 10-15 min | Tool tier, first building |
| Mid | 30-60 min | Major upgrades |
| Late | 2-4 hours | End-game items |

### Avoid Dead Zones
- Always have SOMETHING to work toward
- Multiple progression tracks (tools, gear, buildings)
- Short and long-term goals simultaneously

## Difficulty Settings (Optional)

### Casual Mode
- 50% block hardness
- 150% resource spawn
- No hazards until deeper
- Forgiving inventory

### Normal Mode
- Standard balance
- As designed

### Challenge Mode
- 150% block hardness
- 75% resource spawn
- Earlier hazards
- For veterans

## Testing Metrics

### Balance Indicators
- Time to first tool upgrade: 5-10 min
- Time to reach 500m: 1-2 hours
- Time to reach 1000m: 5-8 hours
- Upgrade purchase rate: Should be steady, not spiky

### Red Flags
- Players stopping at consistent depth (wall)
- Long periods without upgrades (pacing issue)
- Skipping upgrade tiers (poor balance)
- Avoiding deep areas (reward insufficient)

## Questions to Resolve
- [ ] Exact hardness formula coefficients
- [ ] Tool tier count (9 seems good?)
- [ ] Hazard damage values
- [ ] Difficulty setting implementation?

## Implementation Checklist

### MVP
1. Basic hardness scaling (linear)
2. 5 tool tiers
3. No hazards (simpler)
4. Soft gates only

### v1.0
1. Full hardness curve
2. 9 tool tiers
3. Basic hazards
4. Difficulty settings

### v1.1+
1. Dynamic difficulty
2. Challenge modes
3. Leaderboard categories
