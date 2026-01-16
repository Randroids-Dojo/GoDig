# End Game & Long-term Goals Research

## Sources
- [Idle Game Progression Design](https://gameanalytics.com/blog/idle-game-design/)
- [Prestige Systems Analysis](https://www.deconstructoroffun.com/blog/prestige-mechanics)
- [Player Retention in Mobile Games](https://blog.appsflyer.com/mobile-game-retention/)

## The "End Game Problem"

### Challenge
In an infinite procedural mining game, what keeps players engaged after they've:
- Maxed out basic tools?
- Seen most ore types?
- Built all shops?
- Reached extreme depths?

### Solution Framework
Layer multiple progression systems:
1. **Soft Cap** - Natural slowdown point
2. **Prestige Reset** - New game+ with bonuses
3. **Collection Goals** - Long-term targets
4. **Mastery Systems** - Endless optimization

## Progression Phases

### Phase 1: Early Game (0-500m)
**Duration**: 2-5 hours

- Learning mechanics
- First tool upgrades
- Building first shops
- Regular sense of progress

### Phase 2: Mid Game (500-2000m)
**Duration**: 10-20 hours

- Meaningful upgrade choices
- All basic mechanics unlocked
- Collection goals emerge
- Challenge increases

### Phase 3: Late Game (2000m+)
**Duration**: 20-50+ hours

- Prestige consideration
- Rare artifact hunting
- Optimization focus
- Collection completion

### Phase 4: End Game (Post-Prestige)
**Duration**: Indefinite

- Multiple prestige cycles
- Mastery unlocks
- Leaderboards
- Achievement hunting

## Prestige System

### What is Prestige?
A voluntary reset that:
- Returns player to start
- Keeps permanent bonuses
- Grants prestige currency
- Unlocks new content

### Prestige Currency
**"Ancient Gems"** - Earned based on:
- Maximum depth reached
- Total coins earned this run
- Collection completion %
- Time played (diminishing)

```gdscript
func calculate_prestige_gems() -> int:
    var gems = 0

    # Depth bonus
    gems += max_depth / 100  # 1 gem per 100m

    # Wealth bonus (logarithmic)
    gems += log(total_coins_earned) * 2

    # Collection bonus
    gems += collection_percent * 0.5

    return int(gems)
```

### What Resets on Prestige
- Player depth (back to surface)
- Current inventory
- Coins
- Tool upgrades
- Building levels
- World generation (new seed)

### What Persists on Prestige
- Ancient Gems (prestige currency)
- Permanent upgrades (bought with gems)
- Collection progress (fossils, artifacts)
- Achievements
- Statistics

### Prestige Upgrades
| Upgrade | Cost | Effect |
|---------|------|--------|
| Mining Expertise I | 10 | +10% base dig speed |
| Mining Expertise II | 25 | +20% base dig speed |
| Lucky Start | 15 | Begin with +5% luck |
| Head Start | 20 | Begin with Copper Pickaxe |
| Bigger Pockets | 30 | +4 starting inventory |
| Shop Discount | 25 | -10% all prices |
| Treasure Hunter | 50 | +25% rare spawn |
| Deep Knowledge | 75 | Unlock depths 2x faster |
| Master Miner | 100 | +50% all income |

### Prestige Tiers
| Tier | Requirements | Unlock |
|------|--------------|--------|
| Bronze | 1 prestige | New pickaxe skin |
| Silver | 5 prestiges | Auto-collect nearby |
| Gold | 10 prestiges | Teleport upgrade |
| Platinum | 25 prestiges | Legendary artifacts |
| Diamond | 50 prestiges | "Legend" title |

## Collection Goals

### Long-term Targets
Give players something to work toward across multiple runs:

**Gem Collection**
- Find all 8 gem types
- Find all quality variants (32 total)
- Reward: "Gem Master" title + permanent luck boost

**Artifact Collection**
- Find all 20 unique artifacts
- Reward: Special building + prestige multiplier

**Fossil Collection**
- Complete all 4 fossil sets
- Reward: Museum expansion + unique rewards

**Depth Milestones**
- Reach 1km, 2km, 5km, 10km
- Each milestone = achievement + reward

### Collection UI
```
┌────────────────────────────────────┐
│  LIFETIME PROGRESS                 │
├────────────────────────────────────┤
│  Deepest Dive: 3,847m              │
│  Total Gems Found: 1,234           │
│  Unique Artifacts: 15/20           │
│  Prestige Level: Gold (12)         │
│  Play Time: 47h 23m                │
├────────────────────────────────────┤
│  Next Goal: Find Crystal Skull     │
│  Progress: Reach 500m (current)    │
└────────────────────────────────────┘
```

## Mastery Systems

### Skill Trees (Post-Prestige)
Unlock after first prestige, spend XP on specializations:

**Mining Tree**
```
[Dig Speed] → [Multi-Block] → [Drill Mastery]
     ↓
[Hard Rock] → [Efficiency] → [Auto-Break]
```

**Economy Tree**
```
[Haggle] → [Bulk Sell] → [Price Insight]
    ↓
[Luck] → [Rare Eye] → [Treasure Sense]
```

**Survival Tree**
```
[Health] → [Armor] → [Invincibility]
    ↓
[Speed] → [Jump] → [Flight]
```

### Achievement System
Provide goals beyond story/progression:

**Categories**
- Exploration: Depth milestones
- Economy: Coin milestones
- Collection: Find X items
- Speed: Complete challenges fast
- Challenge: Self-imposed difficulty

**Example Achievements**
```
"First Steps" - Reach 50m depth
"Deep Diver" - Reach 1km depth
"Abyss Walker" - Reach 5km depth

"Pocket Change" - Earn 1,000 coins
"Getting Rich" - Earn 100,000 coins
"Millionaire" - Earn 1,000,000 coins

"Quick Hands" - Sell 100 items in one trip
"Speed Runner" - Reach 500m in under 10 minutes
"Pacifist" - Complete prestige without dying
```

## Daily/Weekly Challenges

### Engagement Hooks
Bring players back regularly:

**Daily Challenges**
- "Mine 50 iron ore" (reward: 500 coins)
- "Reach depth 200m" (reward: gem)
- "Sell 1000 coins worth" (reward: artifact chance)

**Weekly Challenges**
- "Find 3 rare gems" (reward: blueprint piece)
- "Complete 5 daily challenges" (reward: prestige gems)
- "Reach new depth record" (reward: unique item)

### Implementation
```gdscript
# daily_challenge.gd
func generate_daily():
    var today = Time.get_date_dict_from_system()
    var seed = today.year * 10000 + today.month * 100 + today.day
    seed(seed)

    var challenge_pool = get_available_challenges()
    return challenge_pool[randi() % challenge_pool.size()]
```

## Leaderboards (Optional)

### Categories
- Deepest single run
- Most coins in one run
- Fastest to 1km
- Most prestiges
- Collection completion %

### Privacy Consideration
- Optional participation
- Anonymous by default
- Friend leaderboards only?

## Content Roadmap

### MVP (v0.1)
- Basic progression to 1km
- No prestige system
- Simple achievements

### v1.0
- Full progression to 2km+
- Basic prestige system
- Collection goals
- Achievement system

### v1.1+
- Skill trees
- Daily challenges
- Leaderboards
- Endless content updates

## Questions to Resolve
- [ ] Prestige at launch or add later?
- [ ] How many prestige upgrades?
- [ ] Mandatory tutorial for prestige?
- [ ] Cross-device progress sync?
- [ ] Seasonal content/events?
