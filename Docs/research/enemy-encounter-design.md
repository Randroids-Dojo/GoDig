# Enemy Encounter Design in Mining Games

## Overview

Research into how mining and digging games handle enemies and combat. Understanding when enemies enhance versus interrupt the core mining flow, and how to balance tension without frustrating players.

## Design Philosophies

### Optional vs. Mandatory Combat

**Spelunky Approach (Enemies as Obstacles):**
> "The aim of the game is to explore tunnels, gathering as much treasure as possible while avoiding traps and enemies."

- Combat is **optional** - can fight, avoid, or use environment
- Multiple solutions to each enemy encounter
- Whip, jump-on, throw objects, or simply evade

**Spelunky 1 vs Spelunky 2 Shift:**
- Spelunky 1: Most enemies dispatched with single hit, avoidable
- Spelunky 2: More persistent enemies (moles stalk you through walls)
- Community reaction: Some players prefer avoidable design

**Key Insight:**
> "Spelunky looks like a game of execution, but it's really a game about information and decision-making."

### Enemies Enhance Mining Flow

**SteamWorld Dig 2:**
- Combat is "limited, which is good" given short-range pickaxe
- Enemies become obstacles to navigate around
- Later weapons (pressure cannon) enable more combat
- Challenge falls off when fully upgraded

**The Balance:**
> "Retains the original's addictive resource-gathering gameplay but supplements it with exploration, combat, platforming, and puzzle solving."

### Enemies Create Time Pressure

**Dome Keeper:**
- Alternating phases: Mining → Defense
- Timer ticks during mining, dome defenseless until you return
- Creates tension: "Do you push deeper or play safe?"

**The Genius:**
> "The game manages to feel both cozy and frantic. You are completely safe as you mine, yet the time until the next wave constantly ticks away."

## Case Studies

### SteamWorld Dig 2

**Combat Design:**
- Short-range pickaxe limits combat options
- Can't attack while in air
- Pressure cannon unlocks later as primary weapon
- Combat loadouts possible via upgrade cogs

**Enemy Variety:**
- Each area has unique enemies and traps
- Multiple mines (standard, underground forest, lava ruins)
- Bosses mark progression milestones

**Critique:**
> "When you are a fully upgraded murder machine, the challenge tends to fall off."

### Dome Keeper

**Wave System:**
- Mining sessions ~1 minute before warning alarm
- Failure to return = dome vulnerable
- Escalating waves with varied enemy types
- Air and ground attackers with unique patterns

**Tension Mechanics:**
- Mining is safe, but time-constrained
- Resources needed for both upgrades AND defense
- Higher difficulty = faster wave periods

**Critical Reception:**
> "A simple yet nuanced roguelike packed with interesting decisions, tense fights and lots of digging."

### Terraria

**Depth-Based Progression:**
- Surface: Basic slimes, zombies (night)
- Underground: Red/Yellow slimes
- Cavern: Increased spawn rates, better drops
- Biome-specific: Jungle, Corruption, etc.

**Spawning Mechanics:**
- 64-82 blocks horizontal from player
- 35-47 blocks vertical
- Biome blocks determine enemy types
- Player-placed walls block spawns (farm design)

**Design Lesson:** Enemy variety tied to both depth AND biome creates distinct zones.

### Spelunky 1 & 2

**Enemy Philosophy:**
- Enemies designed like Pac-Man ghosts
- Different behaviors, unified experience
- Information over execution

**Avoidability Spectrum:**

| Spelunky 1 | Spelunky 2 |
|------------|------------|
| Most enemies 1-hit | Many have invulnerability windows |
| Can be avoided | Moles tunnel to chase you |
| Giant Spider = rare exception | More mandatory engagement |

### Noita

**Physics-Based Hazards:**
- Every pixel destructible (fire, oil, water, etc.)
- Environmental hazards as dangerous as enemies
- Chain reactions can kill faster than creatures

**Enemy Interaction:**
- Enemies affected by same physics as player
- Double gold for physics-based kills
- Some bleed toxic blood or lava

**Exploration Tension:**
> "The player must weigh if further exploration is worth it, before moving to the next checkpoint."

**Risk-Reward:**
- New wands might be useless
- Dangerous enemies = more gold
- Limited health creates real stakes

## Design Patterns

### Pattern 1: Mining Phase / Combat Phase

**Best For:** Games where mining IS the core experience

**Implementation (Dome Keeper style):**
1. Mining phase: Safe exploration, gather resources
2. Warning signal: Return to surface
3. Combat phase: Defend against waves
4. Cycle repeats with escalation

**Pros:**
- Clear separation of concerns
- Mining flow uninterrupted
- Combat feels like separate mini-game

**Cons:**
- Can feel formulaic
- Timer can stress some players
- Less organic emergent gameplay

### Pattern 2: Avoidable Hazards

**Best For:** Games emphasizing exploration over combat

**Implementation (Spelunky 1 style):**
1. Enemies patrol predictable patterns
2. Can be killed easily OR avoided
3. Environment provides multiple paths
4. Combat rewards optional (drops)

**Pros:**
- Player choice in engagement
- Skill expression through avoidance
- Mining flow maintained

**Cons:**
- Some players want combat challenge
- Can feel too easy if always avoidable
- Less tension from enemies

### Pattern 3: Depth-Gated Encounters

**Best For:** Mining games with vertical progression

**Implementation (Terraria style):**
1. Surface layer: No enemies OR tutorial enemies
2. Shallow: Basic hazards, avoidable
3. Mid-depth: Enemy variety increases
4. Deep: Mandatory combat zones
5. Boss depths: Climactic encounters

**Pros:**
- Natural difficulty curve
- New players have safe zone
- Veteran reward for going deep

**Cons:**
- Can make surface feel boring later
- Depth gates might feel artificial
- Balance complexity increases

### Pattern 4: Physics-Based Emergent Combat

**Best For:** Sandbox/simulation mining games

**Implementation (Noita style):**
1. Enemies and player share physics rules
2. Environment can kill anything
3. Creative solutions encouraged
4. Bonus rewards for environmental kills

**Pros:**
- Highly replayable
- Emergent stories
- Skill ceiling very high

**Cons:**
- Can be frustrating (chain reactions)
- Unpredictable difficulty
- Learning curve steep

## Mining Games and Enemy Types

### Ground-Based Enemies

| Type | Behavior | Mining Impact |
|------|----------|---------------|
| Patrol | Walk back and forth | Timing challenge |
| Chase | Follow player | Must be dealt with |
| Ambush | Hidden until triggered | Jump scares |
| Burrowing | Move through terrain | Unpredictable |

### Flying Enemies

| Type | Behavior | Mining Impact |
|------|----------|---------------|
| Hover | Float in place | Area denial |
| Swoop | Dive at player | Interrupt mining |
| Ranged | Shoot projectiles | Must take cover |
| Swarm | Multiple weak units | Overwhelming |

### Environmental "Enemies"

| Type | Behavior | Mining Impact |
|------|----------|---------------|
| Lava | Flows down | Route blocking |
| Gas | Spreads in caves | Area denial |
| Collapse | Cave-ins | Timing hazard |
| Creatures | Neutral until provoked | Optional engagement |

## Recommendations for GoDig

### Core Philosophy

**Mining should feel good without enemies.**

Enemies are enhancement, not requirement. The core loop of dig-collect-return-upgrade must be satisfying on its own.

### Enemy Implementation (If Added)

**Recommended: Depth-Gated + Avoidable**

| Depth | Enemy Presence | Combat Required |
|-------|----------------|-----------------|
| 0-100m | None | No |
| 100-300m | Critters (harmless, flavor) | No |
| 300-500m | Basic hazards (avoidable) | Optional |
| 500-1000m | Enemies in caves only | Avoidable |
| 1000m+ | "Infested Zones" (optional areas) | Player choice |

### Enemy Types for Mining

**Tier 1: Critters (Flavor Only)**
- Bats that scatter when approached
- Cave spiders that scurry away
- No damage, adds life to world

**Tier 2: Avoidable Hazards**
- Stationary slimes that block paths
- Sleeping creatures that wake if disturbed
- Can be mined around or killed easily

**Tier 3: Active Threats**
- Patrol enemies in cave systems
- Ranged attackers in deep zones
- Can be avoided with careful play

**Tier 4: Infested Zones (Optional)**
- Marked clearly before entry
- Higher rewards for clearing
- Player chooses to engage

### Combat Rewards

If enemies exist, killing should provide:
- Bonus coins (small)
- Rare drops (traversal items)
- Achievement progress
- NOT required for core progression

### What to Avoid

1. **Enemies that interrupt mining mid-dig**
2. **Mandatory combat to progress**
3. **Enemies that spawn on player location**
4. **Combat that requires special weapons**
5. **Health gates (must kill to proceed)**

### Alternative to Enemies: Environmental Hazards

Consider depth-based hazards instead of enemies:

| Depth | Hazard | Challenge |
|-------|--------|-----------|
| 200m+ | Water pools | Path planning |
| 400m+ | Gas pockets | Timing |
| 600m+ | Lava flows | Route management |
| 800m+ | Cave-ins | Speed/awareness |
| 1000m+ | Heat damage | Resource management |

These create tension without requiring combat systems.

## Sources

- [Steam - SteamWorld Dig 2](https://store.steampowered.com/app/571310/SteamWorld_Dig_2/)
- [Source Gaming - SteamWorld Dig 2 Review](https://sourcegaming.info/2017/09/20/steamworld-dig-2-review/)
- [Steam - Dome Keeper](https://store.steampowered.com/app/1637320/Dome_Keeper/)
- [Gideon's Gaming - Dome Keeper Review](https://gideonsgaming.com/dome-keeper-review/)
- [Game Developer - Spelunky Design Analysis](https://www.gamedeveloper.com/design/a-spelunky-game-design-analysis---pt-2)
- [Scientific Gamer - Spelunky 2 Thoughts](https://scientificgamer.com/thoughts-spelunky-2/)
- [Terraria Wiki - NPC Spawning](https://terraria.wiki.gg/wiki/NPC_spawning)
- [Terraria Wiki - Enemy Farming Guide](https://terraria.wiki.gg/wiki/Guide:Enemy_farming)
- [GDC Vault - Exploring the Tech and Design of Noita](https://www.gdcvault.com/play/1025695/Exploring-the-Tech-and-Design/)
- [Third Coast Review - Noita Review](https://thirdcoastreview.com/2020/10/25/game-review-noita)
- [Game Design Skills - Enemy Design](https://gamedesignskills.com/game-design/enemy-design/)
- [National Coal Mining Museum - Mining in Games](https://www.ncm.org.uk/news/datamines-mining-in-games-hazardous-environments-minecarts/)

## Related Implementation Tasks

- `Complete enemy system` - GoDig-complete-enemy-system-f6a7dc90
- `implement: Optional danger zones for risk/reward` - GoDig-implement-optional-danger-cc87675c
- `implement: No sudden-death from RNG` - GoDig-implement-no-sudden-d164debb
