# Upgrade Paths & Tech Tree Research

## Sources
- [Idle Game Upgrade Design](https://gameanalytics.com/blog/idle-game-design/)
- [Meaningful Choices in Upgrades](https://www.gamedeveloper.com/design/meaningful-progression)
- [Mobile Game Monetization via Upgrades](https://blog.appsflyer.com/mobile-game-monetization/)

## Upgrade Philosophy

### Core Principles
1. **Every upgrade should feel impactful**
2. **No "trap" upgrades** (all paths viable)
3. **Clear visual/mechanical feedback**
4. **Multiple viable builds**
5. **No pay-to-win required upgrades**

### Upgrade Categories
1. **Tools** - Direct mining improvements
2. **Equipment** - Player stats/abilities
3. **Buildings** - Passive bonuses
4. **Consumables** - Temporary boosts
5. **Permanent** - Prestige unlocks

## Tool Upgrade Path

### Pickaxe Tiers
| Tier | Name | Damage | Speed | Cost | Unlock |
|------|------|--------|-------|------|--------|
| 0 | Rusty | 10 | 1.0x | Free | Start |
| 1 | Wooden | 15 | 1.0x | 100 | - |
| 2 | Copper | 25 | 1.0x | 500 | 25m |
| 3 | Iron | 40 | 1.1x | 2,000 | 100m |
| 4 | Steel | 60 | 1.1x | 8,000 | 250m |
| 5 | Silver | 85 | 1.2x | 25,000 | 400m |
| 6 | Gold | 100 | 1.0x | 50,000 | 500m |
| 7 | Mythril | 150 | 1.3x | 150,000 | 750m |
| 8 | Diamond | 220 | 1.4x | 400,000 | 1000m |
| 9 | Void | 350 | 1.5x | 1,000,000 | 1500m |

### Specialization Branches (v1.1+)
After Tier 5, player can specialize:

```
                    [Silver Pickaxe]
                          |
            +-------------+-------------+
            |             |             |
    [Power Focus]   [Speed Focus]   [Luck Focus]
    +40% damage     +40% speed      +30% rare
    -10% speed      -10% damage     -10% both
```

### Tool Upgrade UI
```
┌─────────────────────────────────────┐
│  BLACKSMITH - Tool Upgrades         │
├─────────────────────────────────────┤
│  [Current Tool Icon]                │
│  Iron Pickaxe (Tier 3)              │
│                                     │
│  Damage: 40 → 60 (+50%)             │
│  Speed:  1.1x → 1.1x                │
│                                     │
│  Cost: 8,000 coins                  │
│  Requires: Depth 250m ✓             │
│                                     │
│  [UPGRADE TO STEEL]                 │
└─────────────────────────────────────┘
```

## Equipment Upgrade Paths

### Helmet (Light)
| Level | Name | Light Radius | Cost |
|-------|------|--------------|------|
| 1 | Miner's Cap | 80px | 200 |
| 2 | Lantern Helm | 120px | 1,000 |
| 3 | Bright Helm | 160px | 5,000 |
| 4 | Beacon Helm | 200px | 20,000 |
| 5 | Sun Helm | 250px | 80,000 |

### Boots (Movement)
| Level | Name | Effect | Cost |
|-------|------|--------|------|
| 1 | Work Boots | -10% fall damage | 300 |
| 2 | Sturdy Boots | -25% fall damage | 1,500 |
| 3 | Spring Boots | -50% fall, +10% speed | 6,000 |
| 4 | Rocket Boots | -75% fall, +20% speed | 25,000 |
| 5 | Void Boots | No fall, +30% speed | 100,000 |

### Backpack (Inventory)
| Level | Slots | Cost |
|-------|-------|------|
| 1 | 8 | Free |
| 2 | 12 | 500 |
| 3 | 16 | 2,500 |
| 4 | 20 | 10,000 |
| 5 | 24 | 40,000 |
| 6 | 30 | 150,000 |

### Gloves (Dig Speed)
| Level | Bonus | Cost |
|-------|-------|------|
| 1 | +5% dig | 400 |
| 2 | +10% dig | 2,000 |
| 3 | +20% dig | 8,000 |
| 4 | +30% dig | 32,000 |
| 5 | +50% dig | 120,000 |

## Building Upgrade Paths

### General Store
| Level | Sell Bonus | Unlock |
|-------|------------|--------|
| 1 | Base prices | Start |
| 2 | +5% sell | 1,000 coins |
| 3 | +10% sell | 5,000 coins |
| 4 | +15% sell | 20,000 coins |
| 5 | +25% sell | 100,000 coins |

### Blacksmith
| Level | Discount | Features |
|-------|----------|----------|
| 1 | - | Basic tools |
| 2 | -5% | Tier 1-4 tools |
| 3 | -10% | Tier 1-6 tools |
| 4 | -15% | All tools |
| 5 | -20% | Specializations |

### Supply Store
| Level | Stock | Features |
|-------|-------|----------|
| 1 | Ladders only | - |
| 2 | +Ropes | -5% prices |
| 3 | +Torches | -10% prices |
| 4 | +Bombs | -15% prices |
| 5 | +All items | -20% prices |

## Upgrade Cost Scaling

### Formula
```gdscript
func calculate_upgrade_cost(base_cost: int, level: int) -> int:
    # Exponential scaling with diminishing returns
    var multiplier = pow(2.5, level - 1)
    return int(base_cost * multiplier)
```

### Cost Curve Example
```
Level 1: 100 coins
Level 2: 250 coins
Level 3: 625 coins
Level 4: 1,562 coins
Level 5: 3,906 coins
```

### Avoiding Grind Walls
- Multiple upgrade paths = always progress somewhere
- Cheaper upgrades available at each tier
- Side-grades (not strictly better) add variety

## Tech Tree (v1.1+)

### Research System
Spend coins + time to unlock permanent bonuses:

```
[Mining]                    [Economy]
   |                           |
[Basic Mining]           [Basic Trade]
   |                           |
[Efficient Dig]          [Haggling]
   |      \                    |
[Multi-Block] [Deep Mining] [Bulk Sell]
```

### Research Node Example
```gdscript
const RESEARCH_NODES = {
    "efficient_dig": {
        "name": "Efficient Digging",
        "description": "+10% dig speed permanently",
        "cost": 5000,
        "time": 60,  # seconds (can pay to skip)
        "requires": ["basic_mining"],
        "effect": {"dig_speed": 0.1}
    }
}
```

## Unlock Requirements

### Depth-Gated Unlocks
| Depth | Unlocks |
|-------|---------|
| 25m | Copper tools, Basic equipment |
| 100m | Iron tools, Supply Store L2 |
| 250m | Steel tools, Gem Appraiser |
| 500m | Silver/Gold tools, Elevator |
| 750m | Mythril tools, Research Lab |
| 1000m | Diamond tools, Portal |
| 1500m | Void tools, Prestige |

### Collection-Gated Unlocks
| Collection | Unlocks |
|------------|---------|
| 5 ore types | Ore Scanner |
| 3 gem types | Gem Appraiser |
| All fossils (set) | Museum bonus |
| 10 artifacts | Artifact Detector |

## Visual Upgrade Feedback

### Player Appearance Changes
```gdscript
# Equipment affects player sprite
func update_player_appearance():
    $HelmetSprite.texture = get_helmet_texture(helmet_level)
    $PickaxeSprite.texture = get_pickaxe_texture(pickaxe_tier)
    $BackpackSprite.visible = backpack_level > 1
```

### World Effect Changes
- Better pickaxe = bigger break particles
- Better helmet = larger light circle
- Better boots = jump effect particles

## Upgrade Data Structure

### GDScript Resource
```gdscript
# upgrade_data.gd
class_name UpgradeData
extends Resource

@export var id: String
@export var name: String
@export var description: String
@export var category: String  # tool, equipment, building
@export var base_cost: int
@export var cost_multiplier: float = 2.5
@export var max_level: int
@export var unlock_depth: int = 0
@export var effects: Dictionary = {}

func get_cost(level: int) -> int:
    return int(base_cost * pow(cost_multiplier, level - 1))

func get_effect_at_level(effect_name: String, level: int) -> float:
    if effect_name in effects:
        return effects[effect_name] * level
    return 0.0
```

## Questions to Resolve
- [x] Linear upgrades or branching? → Linear for MVP, branching v1.1+
- [x] Research/tech tree? → v1.1+ feature
- [x] How many equipment slots? → 4 slots (pickaxe, helmet, boots, backpack)
- [x] Upgrade costs? → Exponential scaling, 2-3 trips per upgrade
- [x] Visual changes for upgrades? → Yes, sprite variants per tier
