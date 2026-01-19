---
title: "implement: Equipment Shop (gear)"
status: open
priority: 3
issue-type: task
created-at: "2026-01-16T00:28:44.491311-06:00"
---

Helmet (light), boots (speed), gloves (dig speed), backpack (inventory), armor (hazards). Unlocks 50-200m.

## Description

The Equipment Shop sells gear upgrades that provide persistent stat bonuses. It unlocks at depth 100m and offers helmet, boots, gloves, and backpack upgrades.

## Context

- Current `shop.gd` has backpack upgrade in "Upgrades" tab
- For v1.0, equipment moves to dedicated shop
- Equipment provides ongoing benefits (vs consumable items)
- Creates long-term progression goals

## Affected Files

- `scenes/surface/equipment_shop.tscn` - Building on surface
- `scripts/surface/equipment_shop.gd` - Interaction trigger
- `scenes/ui/equipment_shop_ui.tscn` - Equipment UI
- `scripts/ui/equipment_shop_ui.gd` - Purchase/equip logic
- `scripts/autoload/player_stats.gd` - Store equipped gear stats

## Implementation Notes

### Equipment Slots (from upgrade-paths research)

#### Helmet (Light Radius)
| Level | Name | Light Radius | Cost |
|-------|------|--------------|------|
| 1 | Miner's Cap | 80px | 200 |
| 2 | Lantern Helm | 120px | 1,000 |
| 3 | Bright Helm | 160px | 5,000 |
| 4 | Beacon Helm | 200px | 20,000 |
| 5 | Sun Helm | 250px | 80,000 |

#### Boots (Fall Damage + Speed)
| Level | Name | Effect | Cost |
|-------|------|--------|------|
| 1 | Work Boots | -10% fall damage | 300 |
| 2 | Sturdy Boots | -25% fall damage | 1,500 |
| 3 | Spring Boots | -50% fall, +10% speed | 6,000 |
| 4 | Rocket Boots | -75% fall, +20% speed | 25,000 |
| 5 | Void Boots | No fall, +30% speed | 100,000 |

#### Backpack (Inventory Slots)
| Level | Slots | Cost |
|-------|-------|------|
| 1 | 8 | Free |
| 2 | 12 | 500 |
| 3 | 16 | 2,500 |
| 4 | 20 | 10,000 |
| 5 | 24 | 40,000 |
| 6 | 30 | 150,000 |

#### Gloves (Dig Speed)
| Level | Bonus | Cost |
|-------|-------|------|
| 1 | +5% dig | 400 |
| 2 | +10% dig | 2,000 |
| 3 | +20% dig | 8,000 |
| 4 | +30% dig | 32,000 |
| 5 | +50% dig | 120,000 |

### Equipment UI Design

```
+-------------------------------------+
|  EQUIPMENT SHOP                      |
+-------------------------------------+
|  HELMET                              |
|  [Current: Miner's Cap]              |
|  -> Lantern Helm: +40px light        |
|  Cost: $1,000  [UPGRADE]             |
|-------------------------------------|
|  BOOTS                               |
|  [Current: None]                     |
|  -> Work Boots: -10% fall damage     |
|  Cost: $300  [BUY]                   |
+-------------------------------------+
```

### MVP Simplification

For MVP, only backpack upgrade is needed. Current implementation in shop.gd is sufficient. Full equipment shop is v1.0.

## Verify

- [ ] Equipment shop unlocks at depth 100m
- [ ] Can upgrade each equipment slot
- [ ] Stats apply to gameplay (light radius, fall damage, etc.)
- [ ] Equipment persists across save/load
- [ ] Can't buy if can't afford
- [ ] Visual feedback on player when equipped
