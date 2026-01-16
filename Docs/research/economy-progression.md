# Economy & Progression Research

## Sources
- [The Forge Pickaxe Tier List](https://www.theforgewiki.org/pickaxe/)
- [The Forge Progression Guide](https://beebom.com/the-forge-pickaxe-progression-guide/)
- [Core Keeper Mining Wiki](https://corekeeper.atma.gg/en/Mining)
- [Everything Upgrade Tree Mining Guide](https://eutwiki.com/Guide:Mining)
- [Minecraft Tools Guide](https://zap-hosting.com/en/blog/2025/12/ultimate-minecraft-tools-guide-crafting-efficiency-enchantments-optimization-explained/)

## Tool Progression Design

### Key Stats for Tools
1. **Mine Power / Damage** - How fast blocks break
2. **Mining Speed** - Swing frequency modifier
3. **Luck** - Chance for rare drops
4. **Durability** - Uses before breaking
5. **Special Slots** - Rune/enchant capacity

### Progression Philosophy

**Linear but Meaningful**
- Each tier should feel like an upgrade
- Avoid "trap" tiers that aren't worth buying
- Clear milestones with noticeable impact

**Trade-offs Create Choice**
- Speed pickaxe: Fast but low damage
- Power pickaxe: High damage but slow
- Balanced pickaxe: Middle ground
- Luck pickaxe: Better drops, lower power

### Example Tier Structure

| Tier | Name | Damage | Speed | Cost | Unlock |
|------|------|--------|-------|------|--------|
| 1 | Rusty Pickaxe | 10 | 1.0x | Free | Start |
| 2 | Copper Pickaxe | 20 | 1.0x | 500 | Depth 25m |
| 3 | Iron Pickaxe | 35 | 1.0x | 2,000 | Depth 100m |
| 4 | Steel Pickaxe | 55 | 1.1x | 8,000 | Depth 250m |
| 5 | Silver Pickaxe | 75 | 1.0x | 25,000 | Depth 400m |
| 6 | Gold Pickaxe | 80 | 0.9x | 50,000 | Depth 500m |
| 7 | Mythril Pickaxe | 120 | 1.0x | 100,000 | Depth 700m |
| 8 | Diamond Pickaxe | 180 | 1.2x | 300,000 | Depth 1000m |
| 9 | Void Pickaxe | 250 | 1.3x | 1,000,000 | Depth 2000m |

### Damage Formula
```gdscript
# Block break time calculation
func calculate_break_time(block: Block, tool: Tool) -> float:
    var base_time = block.hardness / tool.damage
    var speed_modifier = tool.speed_multiplier
    return base_time / speed_modifier
```

### Block Hardness by Layer
```
Dirt: 10 hardness (0-50m)
Clay: 15 hardness (25-150m)
Stone: 30 hardness (100-500m)
Granite: 50 hardness (300-800m)
Obsidian: 80 hardness (500-1500m)
Magma Rock: 120 hardness (1000m+)
Void Stone: 200 hardness (2000m+)
```

## Currency System

### Single Currency (Simple)
- **Coins** - Universal currency
- Easy to understand
- No conversion complexity

### Multi-Currency (Complex)
- **Coins** - Basic currency (sell ores)
- **Gems** - Premium currency (rare finds)
- **Ore Fragments** - Crafting currency

### Recommended: Single + Crafting
- Coins for buying
- Specific ores for crafting upgrades
- "Need 10 Iron Ingots + 5000 coins for Steel Pickaxe"

## Upgrade Types

### Permanent Upgrades
- Tool tiers
- Equipment slots
- Inventory capacity
- Building unlocks
- Movement abilities

### Consumables
- Ladders
- Ropes
- Dynamite
- Potions/buffs
- Teleport scrolls

### Balance: Permanent vs Consumable
- Permanent: Major progression, expensive
- Consumables: Tactical advantage, affordable
- Don't make consumables mandatory for basic gameplay

## Prestige/Rebirth System

### When to Add Prestige?
- After initial progression is complete
- When numbers get too large
- To add replayability

### Prestige Mechanics
```
Reset: Depth progress, coins, tools
Keep: Prestige currency, permanent bonuses
Gain: Multipliers, cosmetics, new features
```

### Prestige Bonuses
- +10% coin gain per prestige
- +5% dig speed per prestige
- Unlock new tool tiers
- Cosmetic miners

### Soft vs Hard Prestige
**Soft**: Keep some progress, incremental bonuses
**Hard**: Full reset, major bonuses

## Achievement System

### Categories
1. **Depth Milestones**: Reach 100m, 500m, 1km...
2. **Collection**: Find all gem types
3. **Economy**: Earn 1M coins total
4. **Efficiency**: Break 10,000 blocks
5. **Discovery**: Find hidden caves, artifacts
6. **Building**: Own all shop types

### Achievement Rewards
- Cosmetics (skins, effects)
- Small bonuses (+1% luck)
- Titles/badges
- Unlock features

### Example Achievements
```
"First Steps" - Reach depth 50m (Reward: 500 coins)
"Going Deeper" - Reach depth 500m (Reward: Compass unlock)
"Gem Collector" - Find 5 different gem types (Reward: +5% gem spawn)
"Master Miner" - Break 50,000 blocks (Reward: "Master" title)
"Shopkeeper" - Own 10 buildings (Reward: +10% shop income)
```

## Balancing Guidelines

### Pacing Curve
- Early game: Quick upgrades, fast progress
- Mid game: Slower, meaningful choices
- Late game: Long-term goals, prestige prep

### Avoid "Dead Zones"
- No long stretches without meaningful upgrades
- Something new every 10-15 minutes of play

### Cost Scaling
```
Tier N cost ≈ Tier N-1 cost × 2 to 4
```
- Too steep: Feels grindy
- Too shallow: Upgrades feel cheap

### Play Testing Metrics
- Time to first upgrade: 2-5 minutes
- Time to mid-game: 1-2 hours
- Time to "soft end": 10-20 hours
- Time to 100%: 50+ hours

## Questions to Resolve
- [ ] Single or multi-currency?
- [ ] Crafting system or pure purchase?
- [ ] How many tool tiers?
- [ ] Prestige system at launch or later?
- [ ] Achievement rewards: cosmetic or gameplay?
