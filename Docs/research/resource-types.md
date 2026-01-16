# Resource Types Research

## Sources
- [Mr. Mine Blog: Mineral Rarity](https://blog.mrmine.com/how-mineral-rarity-changes-with-depth-in-mrmine/)
- [Terraria Ores Guide](https://www.playterraria.com/terraria-ores/)
- [Mining Tech Wiki: Ores](https://mining-tech.fandom.com/wiki/Ores)
- [GameDev.net: Different Ore Types](https://www.gamedev.net/forums/topic/637736-different-ore-types/)

## Tier System Design

### Standard Rarity Tiers
1. **Common** (T1) - 1 in 20
2. **Uncommon** (T2) - 1 in 100
3. **Rare** (T3) - 1 in 1,000
4. **Very Rare** (T4) - 1 in 5,000
5. **Ultra Rare** (T5) - 1 in 50,000
6. **Legendary** (T6) - 1 in 500,000
7. **Mythical** (T7) - 1 in 5,000,000
8. **Impossible** (T8) - 1 in 50,000,000

### Exponential Rarity Curve
- Each tier is ~10x rarer than the previous
- Creates satisfying "jackpot" moments for rare finds
- Variable reward system = addictive loop

## Resource Categories

### Basic Ores (Early Game)
| Resource | Tier | Depth Range | Value | Notes |
|----------|------|-------------|-------|-------|
| Coal | T1 | 0-50m | $ | Fuel? Crafting? |
| Copper | T1 | 0-100m | $ | First metal |
| Tin | T1 | 0-100m | $ | Alloy ingredient |
| Iron | T2 | 20-200m | $$ | Core progression |
| Lead | T2 | 30-250m | $$ | Heavy, toxic? |

### Mid-Game Ores
| Resource | Tier | Depth Range | Value | Notes |
|----------|------|-------------|-------|-------|
| Silver | T3 | 100-500m | $$$ | Precious metal |
| Gold | T3 | 150-600m | $$$$ | High value |
| Tungsten | T4 | 300-800m | $$$$$ | Hard material |
| Platinum | T4 | 400-1000m | $$$$$$ | Premium |

### Gems (All Depths, Varying Rarity)
| Gem | Tier | Value | Notes |
|-----|------|-------|-------|
| Quartz | T1 | $ | Common, decorative |
| Amethyst | T2 | $$ | Purple, mystical |
| Topaz | T3 | $$$ | Yellow/orange |
| Emerald | T4 | $$$$ | Green, rare |
| Ruby | T5 | $$$$$ | Red, valuable |
| Sapphire | T5 | $$$$$ | Blue, valuable |
| Diamond | T6 | $$$$$$ | Ultimate gem |

### Special/Fantasy Resources
| Resource | Tier | Depth | Notes |
|----------|------|-------|-------|
| Obsidian | T4 | 500m+ | Near lava layers |
| Mithril | T5 | 800m+ | Fantasy metal |
| Adamantine | T6 | 1000m+ | Unbreakable |
| Stardust | T7 | 2000m+ | Cosmic rarity |
| Void Crystal | T8 | 5000m+ | Ultimate material |

### Artifacts/Treasures
Non-ore special finds:
- **Fossils** - Sell to museum, collection
- **Ancient Coins** - Historical value
- **Buried Chests** - Random loot
- **Relics** - Quest items or special powers
- **Alien Tech** - Deep underground secrets

## Depth-Based Distribution

### The Mining Curve
```
Depth 0-50m:    Coal, Copper, Tin (abundant, low value)
Depth 50-200m:  Iron, Lead, Quartz (common, moderate value)
Depth 200-500m: Silver, Topaz (uncommon, good value)
Depth 500-1km:  Gold, Emerald, Obsidian (rare, high value)
Depth 1-2km:    Platinum, Ruby/Sapphire (very rare)
Depth 2-5km:    Mithril, Diamond (legendary)
Depth 5km+:     Adamantine, Stardust (mythical)
```

### Vein Clustering
- Ores should appear in veins, not scattered
- Veins have 3-15 blocks of same ore
- Finding a vein = satisfying discovery
- Encourages exploration over strip mining

## Design Decisions for GoDig

### Core Resources
1. **Currency Ores**: Sell for coins
2. **Crafting Ores**: Used for upgrades
3. **Fuel Resources**: Coal for lantern/machines?
4. **Special Finds**: Artifacts, fossils, chests

### Value Scaling
- Each tier = 5-10x more valuable
- Depth unlock feels rewarding
- Early game: dozens of coins
- Late game: millions of coins

### Collection/Museum System?
- Track found resources
- Bonus for completing sets
- Achievements for rare finds

## Questions to Resolve
- [ ] How many unique resource types?
- [ ] Crafting system or pure sell?
- [ ] Weight/stack limits per resource?
- [ ] Gem vs Ore distinction meaningful?
- [ ] Fantasy elements or realistic?
