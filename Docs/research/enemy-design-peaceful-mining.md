# Enemy Design Philosophy for Peaceful Mining Games

> Research on integrating enemies without disrupting the meditative mining loop

## Executive Summary

GoDig's core appeal is the peaceful, meditative mining experience. Adding enemies risks disrupting this. This research analyzes how successful mining games introduce combat without destroying the relaxing core loop.

**Key Finding**: The most successful approaches treat enemies as **environmental hazards** rather than combat encounters, and always provide **optional safe modes** for players who prefer pure mining.

---

## Game Analysis Matrix

| Game | Enemy Role | Safe Option | Tension Source | Combat Weight |
|------|------------|-------------|----------------|---------------|
| **Terraria** | Threat + loot source | NPC town biome | Exploration risk | High |
| **SteamWorld Dig** | Environmental obstacle | Low spawns, no respawn | Time/resource pressure | Low |
| **Spelunky** | Deadly hazard | None (core difficulty) | Permadeath stakes | Medium |
| **Dome Keeper** | Wave defense | N/A (core loop) | Return timer | High |
| **Minecraft** | Resource gatekeeper | Peaceful mode | Darkness/exploration | Configurable |

---

## Deep Dive: Terraria NPC Safe Zones

### Spawn Rate System

Terraria uses a sophisticated spawn system:
- Default: 1/600 chance per tick (0.17%)
- ~9.52% chance of spawn per second
- Maximum 5 active enemies normally

### NPC Town Protection

> "When 3 or more friendly town NPCs are present nearby, a town mini-biome is formed and no enemies will spawn."

The mechanic is elegant:
- Build houses for NPCs
- NPCs move in = safe zone
- Effect multiplies with more NPCs
- Creates player investment in building

### Spawn Zone Distance

- Enemies spawn 62+ tiles away (off-screen at 1080p)
- Never "unfair" spawns directly on player
- Can be further modified with items:
  - Peace Candle (reduces spawns)
  - Water Candle (increases spawns)
  - Sunflower (reduces spawns)

### Design Lessons

1. **Player-Created Safety**: Bases aren't arbitrarily safe; players earn it
2. **Transparent Rules**: Spawn mechanics are documented and predictable
3. **Modifiers Available**: Items let players tune the experience
4. **Events Override**: Blood Moons etc. temporarily remove safety (keeps tension)

---

## Deep Dive: SteamWorld Dig Combat

### Enemy Design Philosophy

SteamWorld Dig prioritizes mining over combat:

> "Combat is neither compelling nor rewarding. Rudimentary enemy patterns and limited offensive options leave you feeling lucky when you succeed, but more often, just wishing you could avoid enemies altogether."

This is actually **intentional design** - enemies are obstacles, not content.

### Key Design Decisions

1. **Enemies Don't Respawn**: Once cleared, an area stays safe
2. **Limited Attack Options**: Mining is the verb, not fighting
3. **Handcrafted Caves**: Enemy-heavy areas are designed, not random
4. **Death Penalty**: Lose items at death location, retrieve on respawn

### Enemy Placement

> "In SteamWorld Dig 2, the entire game world is hand-crafted, with only enemy and ore placement being randomized."

This hybrid approach:
- Designers control encounter density
- Randomization adds variety within bounds
- Players encounter appropriate threats at appropriate times

### The Metroidvania Integration

> "Power-ups act as keys for progression, but they serve more to provide variety to the dig rather than to facilitate exploration."

Enemies gate progress but don't define the game:
- Need pickaxe upgrade to break harder blocks
- Need health upgrade to survive deeper enemies
- Need light upgrade to see in dark areas with ambushes

---

## Deep Dive: Spelunky Fair Difficulty

### Core Philosophy

> "One design tenet is that players need complete information to make strategic decisions. In Spelunky, the trick is that you do have all the information you need—everything can (and will) kill you."

### Enemy Design Principles

1. **Block-Based Consistency**: Everything measured in block units
   - Player = 1 block
   - Enemies = measured in blocks
   - Attacks = measured in blocks

2. **Predictable Behavior**: Enemy patterns are learnable
   > "Players adapted to enemy behavior and environmental hazards each new world provides."

3. **Emergent Interactions**: Enemies affect each other
   - Plants eat cavemen
   - Fire frogs create explosions
   - Arrow traps kill shopkeepers
   - "These details help make the core design dynamic"

### Fairness Guarantees

> "It is imperative to guarantee that levels remain fair while still being challenging—this involves ensuring that a level can technically be completed without incurring damage if played perfectly."

Procedural generation rules:
- Critical rooms always present
- Connectivity enforced
- No impossible scenarios

### The Death Feedback Loop

> "Death is permanent, but it just leaves the player wanting another go. The learning curve is perfect: in the beginning death comes early and often."

Enemies contribute to learning:
- Each enemy teaches a lesson
- Death is information, not punishment
- 1,200+ playthroughs reveal new content

---

## Deep Dive: Dome Keeper Wave Defense

### Tension Through Timer

Dome Keeper's enemies create tension through time pressure, not direct threat:

> "Mining underground is strangely peaceful, bordering on meditative, as you're completely safe while you dig. But the tension always hangs in the background as you have to be able to make it back."

### Wave Structure Design

> "A distinctive feature is the mechanic that extends time between waves based on the extent of caves excavated."

This creates positive feedback:
- Dig more = more time before next wave
- Incentivizes mining (core loop)
- Combat is punctuation, not the sentence

### Sound Design for Tension

> "Music during battle actually decreased the tension, so they leaned heavily on sound design."

Enemy audio design:
- Each monster has unique ambience
- Volume attenuates based on enemy count
- Experienced players "read" the soundscape

### The Mining/Defense Loop

> "Both modes are tied together, with mining needed to survive battles, and battles putting constraints on mining."

Key insight: **combat serves mining**, not the reverse.

---

## Deep Dive: Minecraft Peaceful Mode

### Complete Combat Removal

Minecraft's Peaceful mode demonstrates the value of optional enemies:

> "Peaceful is the difficulty you pick when you want the game to feel like a building and exploration sandbox first, and a combat game never."

In Peaceful:
- No hostile mob spawns
- No hunger management
- Faster health regeneration
- Focus on building/exploration

### Trade-offs by Design

> "Because of gameplay changes and absence of many mob types, many blocks and items are unavailable."

Peaceful mode has intentional limitations:
- Can't activate End portals
- Missing mob-drop crafting recipes
- Some progression gated behind combat

### The "Peaceful Table" Solution

> "The Peaceful Table allows players on Peaceful difficulty to access crafting recipes that traditionally require materials from hostile mobs."

This mod/feature shows community desire for complete non-combat experience with full content access.

### Difficulty Flexibility

> "You can adjust the difficulty mode at any time."

Players can:
- Start peaceful, switch to normal for specific encounters
- Build in peaceful, then enable combat
- Choose moment-to-moment

---

## Design Patterns: Enemies as Environmental Hazards

### The Hazard Approach (Recommended for GoDig)

Instead of "combat system," treat enemies as hazards like:
- Falling rocks
- Lava pools
- Poison gas

Hazard-style enemies:
- Predictable behavior
- Avoidable with skill
- Don't require "fighting back"
- Damage through contact

### Examples from Research

| Game | Enemy as Hazard |
|------|-----------------|
| Spelunky | Spikes, arrow traps, bats |
| SteamWorld | Blocking enemies, environmental placement |
| Dome Keeper | Surface threat constrains mining time |
| Terraria | Slimes (easy), Cave Bats (dark areas) |

### Contact Damage Model

Simple enemy interaction:
1. Enemy exists in space
2. Touching enemy = damage
3. Avoiding enemy = mining uninterrupted
4. Killing enemy = optional (clear path)

No complex combat mechanics required.

---

## Design Recommendations for GoDig

### Core Principles

1. **Enemies as Optional Content**: Core loop works without enemies
2. **Hazard Over Combat**: Contact damage, predictable patterns
3. **Clear Safe Zones**: Surface always safe; deep "Infested Zones" optional
4. **Player Choice**: Peaceful mode or difficulty toggle
5. **Mining First**: Enemies constrain mining, don't replace it

### Suggested Implementation

#### Option A: Depth-Gated Infested Zones (Recommended)

- 0-500m: No enemies, pure mining
- 500m+: Optional "Infested Caves" marked on map
- Infested Zones: Higher ore density, enemy presence
- Player chooses to enter or mine around them

Benefits:
- Peaceful early game
- Optional challenge
- Risk/reward for brave players

#### Option B: Dome Keeper Model (Wave Defense)

- Surface has periodic enemy waves
- Mining interrupted for defense
- Tension from time pressure

Concerns:
- Changes core loop significantly
- May not suit mobile sessions
- Adds complexity

#### Option C: Terraria Model (NPC Safe Zones)

- Enemies spawn everywhere underground
- Build "outposts" with NPCs for safe zones
- Investment creates safety

Concerns:
- Requires building system expansion
- Constant enemy pressure may feel stressful

### Enemy Type Suggestions

If implementing enemies, prioritize:

| Type | Behavior | Purpose |
|------|----------|---------|
| **Slime** | Slow, contact damage | Introduce enemy concept |
| **Cave Bat** | Patrols dark areas | Encourage light upgrades |
| **Rock Worm** | Burrows through terrain | Creates dynamic environment |
| **Elemental** | Guards rare ore | Risk/reward gatekeeper |

### Peaceful Mode Requirements

Every GoDig enemy feature should include:

1. **Complete Toggle**: Disable all enemies
2. **No Content Gating**: All ores accessible without combat
3. **Clear UI**: Indicate peaceful mode in settings
4. **No Judgment**: Don't call it "easy mode"

### What to Avoid

1. **Required Combat**: Never gate core progression behind fighting
2. **Unpredictable Spawns**: Enemies should have clear spawn rules
3. **Complex Combat Systems**: Keep it simple (move away from enemy)
4. **Combat-First Design**: Mining is the game; enemies are optional
5. **Punishing Difficulty**: Deaths should teach, not frustrate

---

## Implementation Priority

### Phase 0: Design Decision (Now)
- Confirm enemy approach (optional infested zones recommended)
- Define peaceful mode scope

### Phase 1: Simple Hazards (v1.1)
- Contact damage enemies
- Depth-gated appearance
- Clear visual distinction

### Phase 2: Infested Zones (v1.2)
- Optional marked areas
- Higher risk/reward
- Peaceful mode bypass

### Phase 3: Enemy Variety (v1.3)
- Multiple enemy types
- Biome-specific enemies
- Environmental interactions

---

## Sources

- [NPC Spawning - Official Terraria Wiki](https://terraria.wiki.gg/wiki/NPC_spawning)
- [Terraria: How to Stop Enemies Spawning - Alphr](https://www.alphr.com/terraria-how-to-stop-enemies-spawning/)
- [SteamWorld Dig Review - Metroidvania Review](https://metroidvaniareview.com/2020/01/13/steamworld-dig/)
- [SteamWorld Dig - Wikipedia](https://en.wikipedia.org/wiki/SteamWorld_Dig)
- [Fairness, Discovery & Spelunky - Game Developer](https://www.gamedeveloper.com/design/fairness-discovery-spelunky)
- [Spelunky: A Game Design Gold Mine - Critical Gaming](https://critical-gaming.com/blog/2009/2/17/spelunky-a-game-design-gold-mine.html)
- [How Dome Keeper Focuses on Systems - Game Developer](https://www.gamedeveloper.com/business/how-dome-keeper-focuses-on-systems-that-feed-into-one-another)
- [Why Was Dome Keeper So Good - Retro Style Games](https://retrostylegames.com/blog/why-dome-keeper-so-good/)
- [Minecraft Difficulty - Official Wiki](https://minecraft.wiki/w/Difficulty)
- [Getting Resources on Peaceful - ScalaCube](https://scalacube.com/blog/minecraft/getting-resources-on-peaceful-difficulty-in-minecraft)

---

*Research completed: 2026-02-02*
*Supports: GoDig-complete-enemy-system-f6a7dc90*
