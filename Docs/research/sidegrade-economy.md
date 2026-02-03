# Sidegrade Economy Design: Late-Game Variety in Roguelites

## Overview

This document explores how roguelites maintain late-game engagement through sidegrades (horizontal progression) rather than pure stat increases (vertical progression). The goal is to avoid the "solved meta" problem and keep GoDig's endgame fresh across hundreds of hours of play.

## Sources
- [Binding of Isaac Synergies - Platinum God](https://tboi.com/synergies)
- [10 Game Breaking Synergies - TheGamer](https://www.thegamer.com/binding-of-isaac-best-item-builds-synergies/)
- [Hades Boon Wiki](https://hades.fandom.com/wiki/Boons)
- [Hades Beginner's Guide - Boons and Builds](https://mygamingtutorials.com/2025/06/10/hades-beginners-guide-mastering-boons-and-builds/)
- [Hades II Boon Synergies](https://vocal.media/gamers/hades-ii-best-builds-and-boon-synergies-explained)
- [Enter the Gungeon Variety Analysis - CBR](https://www.cbr.com/enter-the-gungeon-variety-indie-roguelike/)
- [Deep Rock Galactic Overclocks Wiki](https://deeprockgalactic.wiki.gg/wiki/Weapon_Overclocks)
- [DRG Overclock Analysis](https://ljvmiranda921.github.io/notebook/2022/12/02/drg/)
- [Impurities of Pure Upgrades - Game Wisdom](https://game-wisdom.com/critical/impurities-upgrades-game-design)
- [What Makes Agency in Roguelikes](https://thom.ee/blog/what-makes-or-breaks-agency-in-roguelikes/)
- [Dome Keeper Strategy Guide](https://steamcommunity.com/sharedfiles/filedetails/?id=2869939597)

## The Solved Meta Problem

### What Is It?
When a game's progression system leads to one optimal path that players always take, the system becomes "solved." This kills:
- **Replayability**: No reason to try different approaches
- **Player agency**: Choices don't feel meaningful
- **Discovery joy**: Nothing new to learn after mastery

### Why Pure Upgrades Fail
Pure upgrades (sword does 5 damage -> 20 damage) create monotonically increasing power curves where:
- Early game is hardest
- Late game becomes trivial
- Strategy reduces to "buy the next upgrade"

### Roguelite Examples of the Problem
- Players always take the same build path
- Meta guides kill experimentation
- New content gets "solved" within days of release

## Sidegrade Design Principles

### Definition
A sidegrade provides benefits with tradeoffs rather than pure improvements. The player gains something valuable but gives up something else.

### Core Formula
```
Sidegrade = Benefit + Penalty
Example: +40% damage, -10% speed
```

### Types of Sidegrades

**1. Stat Tradeoffs**
- More damage but slower
- More range but less damage
- More capacity but heavier (slower)

**2. Specialization**
- Effective against one enemy type, weak against others
- Good at shallow depths, struggles deep
- Excels at speed mining, poor at combat

**3. Playstyle Changes**
- Melee-focused vs ranged
- Aggressive vs defensive
- Resource-efficient vs high-output

**4. Risk/Reward Tradeoffs**
- Glass cannon: High damage, low health
- Safe but slow vs risky but fast

## Case Study: Binding of Isaac

### Why Isaac Dominates Late-Game Variety
Isaac has 700+ items with "thousands of synergies" that make every run unique. The key insights:

**Emergent Synergies**
- Items combine in unexpected ways
- Shoot bombs + poison bombs + explosion immunity = poison bomber
- Players discover new combinations hundreds of hours in

**No Objectively Best Build**
- Different items shine in different situations
- Character selection changes optimal strategies
- Random item pools force adaptation

**Transformation Items**
- Entire playstyle shifts mid-run
- Must rebuild strategy around new mechanics
- Keeps mastery curve infinite

### Key Takeaway for GoDig
Items should interact with each other, creating emergent strategies rather than stacking identical effects.

## Case Study: Hades

### Boon System
Each god offers distinct effects that change gameplay:
- Aphrodite: Weak/Charmed debuffs
- Ares: Doom damage, Blade Rifts
- Artemis: Critical hits
- Athena: Deflection
- Zeus: Chain lightning

### Duo Boons
Combining boons from two gods creates powerful hybrids that require building toward specific combinations:
- Requires investment in both gods' boons
- Creates "build paths" within each run
- Rewards knowledge and planning

### Fast vs Slow Attack Design
- Slow attacks want percentage increases (Aphrodite, Artemis)
- Fast attacks want flat damage additions (Zeus, Dionysus)
- This creates meaningful weapon/boon matchups

### Criticism and Lesson
Some players note Hades doesn't create the "unrecognizable from start" feeling of Isaac. The boon system modifies rather than transforms. **Lesson**: Include some transformative options, not just modifiers.

## Case Study: Enter the Gungeon

### Weapon Arsenal as Sidegrades
300+ weapons, each with unique behavior:
- Practical rifles
- Gun that shoots angry bees
- Gun that fires actual sharks
- Microtransaction gun (parody)

### Synergy System
If certain items combine according to recipes, they synergize:
- Scope + Sniper Rifle = 360 No Scope buff
- Same item can function differently based on other items

### Magnificence Score (Hidden)
- Room clear speed affects item quality
- Skilled play rewards better drops
- Creates skill-based late-game variety

### Key Takeaway
Even in a game with simple core mechanics, extreme variety in tools maintains engagement.

## Case Study: Deep Rock Galactic

### Overclock System
Post-promotion weapon mods in three tiers:

**Clean Overclocks (Green)**
- Pure bonus, no penalty
- Essentially an extra mod tier
- Entry-level customization

**Balanced Overclocks (Yellow)**
- Larger boost with equal penalty
- True sidegrades
- Creates distinct playstyles

**Unstable Overclocks (Red)**
- Massive changes, heavy penalties
- Most transformative
- Creates entirely new weapon behaviors

### Example: Burning Hell Minigun
- Burns nearby enemies
- Must get close to use
- Completely changes Gunner gameplay from ranged to aggressive

### Viability Balance
"Almost every overclock can be viable with the right build and playstyle"
- No objectively best option
- Preference and skill matter
- Team composition affects choices

### Key Takeaway
Tiered sidegrades work well - start simple, unlock transformative options.

## Case Study: Dome Keeper

### Starting Options as Sidegrades
- Laser Dome: Ranged defense, upgrade movement/power
- Sword Dome: Melee defense, slice or stab

### Gadget Variety
22 secondary gadgets with distinct functions:
- Shield: Damage absorption
- Repellent: Delay/weaken enemies
- Orchard: Speed/drill buffs via fruit
- Lift: Resource collection automation

### Key Takeaway
Even simple games benefit from branching starting options that create fundamentally different play sessions.

## Application to GoDig

### Current System (Linear Upgrades)
From `upgrade-paths.md`:
- 9 pickaxe tiers (Rusty to Void)
- Pure damage/speed progression
- Risk: Becomes "solved" after players learn optimal path

### Proposed Sidegrade Layer

#### Pickaxe Specializations (Post-Tier 5)
Already designed but expand:
```
                    [Silver Pickaxe]
                          |
            +-------------+-------------+
            |             |             |
    [Power Focus]   [Speed Focus]   [Luck Focus]
    +40% damage     +40% speed      +30% rare finds
    -10% speed      -10% damage     -10% both
```

**Add transformative options:**
```
    [Excavator]        [Precision]        [Prospector]
    Multi-block dig    Crit mining        Ore detection
    Breaks adjacent    2x damage proc     See ores through walls
    2x durability      Cannot break       Cannot break
    loss               multi-block        without ore target
```

#### Equipment Sidegrades

**Helmet Options:**
| Name | Light | Special | Tradeoff |
|------|-------|---------|----------|
| Beacon | 200px | Normal | Balanced |
| Focused | 100px | +50% ahead | -80% behind |
| Pulse | 0-250px | Pulsing light | Inconsistent |
| X-Ray | 80px | See through 1 wall | Dim base light |

**Boot Options:**
| Name | Speed | Special | Tradeoff |
|------|-------|---------|----------|
| Runner | +30% | Normal | Balanced |
| Climber | +5% | Wall cling | Ground slower |
| Featherfall | 0% | No fall damage | No speed bonus |
| Rocket | +50% | Burst movement | Loud (attracts enemies) |

#### Mining Accessories (New Slot)

**Ring Sidegrades:**
| Ring | Benefit | Penalty |
|------|---------|---------|
| Miner's Ring | +20% ore value | -10% movement |
| Lucky Ring | +25% rare chance | -15% dig speed |
| Sturdy Ring | +30% HP | -20% ore drops |
| Greedy Ring | 2x coin pickup radius | -25% ore value |

### Synergy System

**Item Interactions:**
- Precision Pickaxe + Lucky Ring = Critical ore finds (rare ore procs)
- Excavator + Featherfall Boots = Safe tunnel clearing
- X-Ray Helmet + Prospector Pickaxe = Ore targeting build

**Build Archetypes:**
1. **Speed Miner**: Fast extraction, sacrifice value
2. **Deep Diver**: Survivability focus, slower progress
3. **Treasure Hunter**: Rare finds priority, general inefficiency
4. **Balanced**: Jack of all trades

### Unlock Progression

**Stage 1 (0-500m): Linear upgrades**
- Learn basic systems
- Upgrade = strictly better
- No confusing choices early

**Stage 2 (500m+): Sidegrades unlock**
- Specializations become available
- Multiple viable paths
- Player identity emerges

**Stage 3 (1000m+): Transformative options**
- Playstyle-changing equipment
- Synergy-dependent builds
- Deep customization

### Avoiding Solved Meta

**1. No Objectively Best Build**
Every build should have a weakness:
- Speed builds struggle with tough blocks
- Power builds waste time on easy blocks
- Luck builds have inconsistent results

**2. Situational Advantages**
Different biomes favor different builds:
- Soft soil: Speed builds optimal
- Hard rock: Power builds necessary
- Ore-rich: Luck builds pay off

**3. Rotating Challenges**
Weekly modifiers that shift optimal strategies:
- "Dense Week": Harder blocks spawn more
- "Rush Week": Time pressure on surface
- "Jackpot Week": Rare ores more common

**4. Build Discovery System**
Hidden synergies for players to discover:
- Not documented in-game initially
- Community knowledge sharing
- Reward for experimentation

## Implementation Priority

### MVP (v1.0)
- Linear pickaxe upgrades only
- Simple equipment with clear progression
- No sidegrades yet

### Post-Launch (v1.1)
- Pickaxe specializations (3 branches)
- Equipment alternatives (2-3 per slot)
- Basic synergies

### Late Update (v1.2+)
- Full sidegrade system
- Synergy combinations
- Transformative items
- Rotating modifiers

## Design Checklist

When designing sidegrades:

- [ ] Does it change playstyle, not just numbers?
- [ ] Is the tradeoff meaningful, not trivial?
- [ ] Are there situations where it's clearly best?
- [ ] Are there situations where it's clearly worst?
- [ ] Does it enable new strategies?
- [ ] Does it synergize with other equipment?
- [ ] Is it discoverable through play?
- [ ] Can skilled players outperform with any choice?

## Conclusion

The key to late-game variety is **meaningful choice through tradeoffs**. Pure upgrades create solved metas; sidegrades create build diversity. GoDig should:

1. **Start linear** for accessibility
2. **Branch into sidegrades** once players have mastery
3. **Enable synergies** for discovery depth
4. **Rotate situations** so no build dominates
5. **Hide some interactions** for community discovery

This approach, validated by Isaac, Hades, Gungeon, DRG, and Dome Keeper, will keep GoDig engaging well past the 100-hour mark.
