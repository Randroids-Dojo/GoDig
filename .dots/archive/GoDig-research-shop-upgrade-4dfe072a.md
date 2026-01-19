---
title: "research: Shop upgrade progression"
status: closed
priority: 0
issue-type: task
created-at: "\"\\\"2026-01-18T23:39:36.464348-06:00\\\"\""
closed-at: "2026-01-19T01:55:44.597083-06:00"
close-reason: Documented upgrade progression, validated pricing against ore economy, confirmed implementation specs exist
---

How does shop-based progression work? Questions: What upgrades can players buy? (tool tiers, backpack slots, etc.) How are prices balanced? Do upgrades unlock at depth milestones or coin thresholds? What's the upgrade order/tree? How does UI show available vs locked upgrades?

## Research Findings

### Current Implementation State
The existing `shop.gd` has a basic upgrade system with:
- **Tool upgrades**: 4 tiers (Rusty → Copper → Iron → Steel)
- **Backpack upgrades**: 4 levels (8 → 12 → 20 → 30 slots)
- Depth-gating via `min_depth` for backpack upgrades
- Fixed prices without material requirements

### Identified Issues
1. **Tool level persistence missing** - `_get_current_tool_level()` always returns 1 (TODO in code)
2. **No PlayerStats integration** - Tool damage not actually applied to player
3. **Price scaling too flat** - Current 4 tiers don't align with research (9 tiers recommended)
4. **No material requirements** - Pure coin-based, missing resource sink

### Recommended Upgrade Categories (MVP)

#### 1. Pickaxe Tiers (Blacksmith)
| Tier | Name | Damage | Cost | Unlock Depth |
|------|------|--------|------|--------------|
| 0 | Rusty Pickaxe | 10 | Free | Start |
| 1 | Copper Pickaxe | 20 | 500 | 25m |
| 2 | Iron Pickaxe | 35 | 2,000 | 100m |
| 3 | Steel Pickaxe | 55 | 8,000 | 250m |

- **For MVP**: 4 tiers is fine, matching current implementation
- **v1.0**: Expand to 9 tiers (Silver, Gold, Mythril, Diamond, Void)
- **Damage formula**: `break_time = block.hardness / tool.damage`

#### 2. Backpack Slots (Equipment Shop)
| Level | Slots | Cost | Unlock Depth |
|-------|-------|------|--------------|
| 1 | 8 | Free | Start |
| 2 | 12 | 1,000 | 50m |
| 3 | 20 | 3,000 | 200m |
| 4 | 30 | 8,000 | 500m |

Current implementation is good. Depth gates create natural progression.

#### 3. v1.0 Equipment (Equipment Shop)
| Slot | Effect | Levels |
|------|--------|--------|
| Helmet | Light radius | 5 levels |
| Boots | Fall damage reduction + speed | 5 levels |
| Gloves | Dig speed bonus | 5 levels |

### Price Balancing Analysis

Using current ore values:
- Coal: 1 coin (depth 0+)
- Copper: 5 coins (depth 10+)
- Iron: 10 coins (depth 50+)
- Silver: 25 coins (depth 200+)
- Gold: 100 coins (depth 300+)

**Economy flow calculation**:
- Inventory: 8-30 slots, avg ~15 slots mid-game
- Full inventory value at depth 100m: ~15 slots × (avg 5 iron) × 10 = 750 coins
- Time to fill inventory: ~2-3 minutes
- Coins per minute: ~250-375

**Target upgrade pacing**:
- First upgrade (500 coins): 2-3 trips, ~8 minutes
- Mid upgrades (2000-3000): 6-10 trips, ~30 minutes
- Late upgrades (8000): 20-30 trips, ~1-2 hours

Current prices are reasonable for MVP.

### Unlock System Design

**Dual-gate approach (recommended)**:
1. **Depth requirement**: Must reach X meters to see upgrade
2. **Coin cost**: Must afford to purchase

**UI indication**:
- `LOCKED - Reach Xm` when depth not met
- `UPGRADE - $X (Need $Y more)` when depth met but can't afford
- `UPGRADE - $X` when purchasable

Current implementation already does this correctly.

### Missing Implementation: PlayerStats Integration

The key gap is wiring upgrades to actual gameplay:

```gdscript
# PlayerStats singleton needed
var current_tool_tier: int = 0
var tool_damage: int = 10

func get_dig_damage() -> int:
    return tool_damage

func upgrade_tool(new_tier: int, new_damage: int) -> void:
    current_tool_tier = new_tier
    tool_damage = new_damage
```

## Implementation Specs Created

1. `implement: Wire tool upgrades to PlayerStats` - Connect shop upgrades to actual gameplay
2. `implement: Tool tier gating for ores` - Enforce required_tool_tier on ore mining

## Decisions Made

- [x] How many tiers MVP? → 4 pickaxe tiers, 4 backpack levels
- [x] Price scaling? → Current prices OK, ~2.5x multiplier per tier
- [x] Unlock method? → Dual-gate (depth + coins)
- [x] Material requirements? → v1.0 feature, pure coins for MVP
- [x] UI pattern? → Gray locked, show requirements, highlight affordable
