# Underground Rest Station Design

> Research on mid-run safe zones in survival games and roguelites

## Executive Summary

Rest stations in roguelites and survival games serve a critical pacing function: they provide relief from tension, create decision points, and reward progress without undermining the core challenge. This research analyzes how different games implement "safe zones" to inform GoDig's v1.1 Underground Rest Station feature.

**Key Finding**: The best mid-run rest areas are **temporary respites**, not permanent safety. They should heal/restock while maintaining forward pressure, not allow exploitation or infinite camping.

---

## Game Analysis Matrix

| Game | Rest Area | Permanence | Benefits | Tension Maintenance |
|------|-----------|------------|----------|---------------------|
| **Noita** | Holy Mountain | Temporary (collapses) | Spell editing, perks, shop | Collapses on exit; "gods angry" if violated |
| **Spelunky** | Shortcuts | Permanent unlock | Skip early biomes | Trade-off: miss items/upgrades |
| **Don't Starve** | Player bases | Permanent but vulnerable | Storage, crafting, safety | Seasonal events, hound waves destroy bases |
| **Subnautica** | Cyclops | Mobile, destructible | Mobile storage, docking | Leviathan attacks, fire systems |
| **Hades** | Fountain Chambers | Temporary (one-time) | Healing (30-50% HP) | Random appearance, opportunity cost |
| **Caves of Qud** | Settlements | Permanent checkpoints | Respawn on death (new mode) | Optional mode for accessibility |

---

## Deep Dive: Noita Holy Mountain

### Design Philosophy

The Holy Mountain is "an area that acts as a safe room between one level and the next." It serves multiple critical functions:

1. **Strategic Decision Point**: Spells can be removed/added to wands
2. **Resource Exchange**: Buy new wands, spells, or perks with gold
3. **Full Heal**: One guaranteed heal per biome transition

### Tension Through Impermanence

> "Holy Mountain will collapse when they leave, denying a safe place to retreat and forcing them deeper below the earth."

The background music includes "distorted, faint notes" that remind players this safety is temporary. The safe zone **cannot be returned to** - this is crucial for maintaining forward momentum.

### Violation Consequences

If players damage Holy Mountain walls (accidentally or intentionally):
- The gods become angry
- Enemies spawn in the "safe" area
- Future Holy Mountains may be hostile

**Design Lesson**: Safe zones can have rules. Violating them removes the safety.

### Community Debate

> "It's kind of obvious by the game design that it's supposedly some sort of safe haven. That being said, Noita kinda also makes it clear too that NOTHING is safe."

This ambiguity creates interesting tension - players feel relief but remain alert.

---

## Deep Dive: Spelunky Shortcuts

### Purpose

Shortcuts let players skip early biomes after completing unlock requirements:
- First shortcut: $2000 → 1 Bomb → $10000
- Requires speaking to Tunnel/Terra multiple times across runs

### The Intentional Trade-Off

> "Shortcuts just teach you bad habits and make it impossible to do a hell run... you will be much better equipped by running through the whole game than by starting at the temple."

Players who use shortcuts:
- Skip early danger (benefit)
- Miss items, gold, health upgrades (cost)
- Are less prepared for endgame (consequence)

This creates a meaningful choice: practice vs. optimal play.

### Community Usage Patterns

Many players unlock shortcuts but never use them competitively. The unlock is:
1. A learning tool (practice later stages)
2. A completionist goal
3. Not optimal for serious runs

**Design Lesson**: Shortcuts can exist as accessibility without being optimal strategy.

---

## Deep Dive: Don't Starve Bases

### Safety Through Investment

> "Players should find a location relatively safe from enemy encampments. There is nothing worse than going out on a long expedition only to return to a half-destroyed base."

Bases in Don't Starve provide:
- Storage
- Crafting stations
- Fire (warmth, cooking, sanity)
- Defenses (walls, turrets, Ice Flingomatics)

### Tension Through Vulnerability

> "Even the most fortified of bases can fall to these mighty (and random) monsters. It's always better to have a couple of bases."

Sources of base destruction:
- Seasonal giants (Deerclops, Bearger)
- Fire spread
- Hound waves
- Player mistakes

**Key insight**: "Don't Starve Together is downright punishing... In the moments when things are 'too quiet,' players should expect something catastrophic."

### Multiple Base Strategy

Players build backup bases because no single location is truly safe. This creates:
- Resource investment in redundancy
- Strategic routing decisions
- Accepting impermanence

**Design Lesson**: Even "permanent" safe zones can be threatened. The investment in building them creates attachment and stakes.

---

## Deep Dive: Subnautica Cyclops

### Mobile Base Concept

The Cyclops is a submarine that doubles as a mobile base:
- 54m long, dives to 500m (1700m upgraded)
- Can equip with furniture, storage, growbeds
- Docks Seamoth/Prawn Suit

> "This thing isn't just a vehicle; it's a full-blown mobile base."

### Designed for Deep Exploration

> "The Cyclops was really designed for the underground biomes - Lost River and deeper. That area can be very intimidating on a first playthrough."

The mobile base allows extended expeditions without surface returns - directly applicable to GoDig's underground rest station concept.

### Threats and Management

The Cyclops is NOT invulnerable:
- Leviathans can ram it
- Engine overheating causes fires
- Limited storage compared to static bases

> "If something is attacking your Cyclops, turn your engine off. They'll leave you alone."

### Community Advice

> "I don't recommend stocking the Cyclops with all your stuff. Supply it well, but don't put all your eggs in that basket."

**Design Lesson**: Mobile bases enable deeper exploration but shouldn't replace the core loop of returning to surface.

---

## Deep Dive: Hades Fountain Chambers

### Unlockable Rest Points

Fountain Chambers are unlocked via House Contractor purchases:
- Appear randomly in first three biomes
- Provide percentage-based healing (30-50%)
- No combat encounters

> "You have to order projects related to unlocking Fountains... From the moment you get relevant projects, fountains can appear. Their location is random."

### The Opportunity Cost

> "Much of the time you'll have to choose between healing up or taking an upgrade that will make you more powerful in the long term."

Fountains don't replace strategic decision-making - they're ONE option among several:
- Healing from Sisyphus/Patroclus
- Dionysus's After Party boon
- Mirror of Night passives

### Scaling with Progression

Early runs: Fountains are crucial survival tools
Late runs: Fountains are insurance, not dependency

> "Getting access to +50 starting HP makes an absolutely massive difference in the total amount of health across the course of a run."

**Design Lesson**: Rest stations can start as critical and evolve to optional as players master the game.

---

## Roguelike Tension Philosophy

### The Hunger Clock Principle

> "If you could just comfortably explore every single bit of every area, there would be no tension. You'd be silly not to!"

Classic "hunger clocks" that push players forward:
- Rogue: Literal hunger/food
- FTL: Pursuing rebel fleet
- Spelunky: Ghost timer
- GoDig: Ladder depletion

### Rest Areas Must Not Break the Clock

A rest station that allows indefinite safety undermines the core tension loop. Solutions:

1. **One-time use** (Hades fountains)
2. **Collapse after use** (Noita Holy Mountain)
3. **External threats continue** (Don't Starve base raids)
4. **Resource investment required** (Spelunky shortcut unlocks)

### The Mastery Curve

> "Although I enjoy the tension in roguelikes, I don't think it's necessary to allow singular mistakes over just one or two turns to [end a run]."

Rest stations can:
- Reduce punishment for single mistakes
- Reward efficient play (reach station with resources)
- Create "chapters" in a long run

### Caves of Qud's Accessibility Approach

Caves of Qud added optional checkpoint modes:
- **Classic**: Permadeath (original)
- **Roleplay**: Checkpoints at settlements
- **Wander**: Checkpoints, neutral creatures, discovery XP

> "Permadeath works best when you're able to do quick runs with little turnaround time."

**Design Lesson**: Long-form games (like mining games with deep expeditions) may benefit from optional checkpoint systems.

---

## Design Recommendations for GoDig

### Core Principles

1. **Temporary Relief, Not Permanent Safety**: Rest stations should be respites, not homes
2. **Investment Required**: Player must reach them, possibly pay to use them
3. **Forward Pressure Maintained**: Clock/tension continues (ladders still deplete)
4. **Scaling Value**: More useful early game, optional late game

### Suggested Implementation

#### Option A: Noita Model (Collapse After Use)

- Rest stations appear at fixed depth milestones (100m, 250m, 500m, etc.)
- Provide: Healing, ladder resupply, ore sale
- **Collapse when player exits** - cannot return
- Creates clear "chapters" in a deep dive

#### Option B: Hades Model (Random + Unlockable)

- Unlock rest stations via shop purchases
- Appear randomly at lower frequencies
- Provide percentage-based benefits
- One-time use per station per run

#### Option C: Subnautica Model (Player-Built Mobile)

- Unlock "Deep Camp" item at 500m
- Player places it at chosen depth
- Provides limited storage, healing
- Can be **destroyed by hazards** if left unattended
- Must be retrieved to use elsewhere

#### Option D: Spelunky Model (Permanent Shortcuts)

- Unlock rest depths via repeated achievement
- Skip directly to 200m, 500m, etc.
- **Trade-off**: Miss early resources, start with less
- More accessibility than optimal strategy

### Recommended Approach: Hybrid

Combine elements for GoDig's unique loop:

1. **Fixed Milestone Stations** (Noita-style)
   - Appear at 100m, 300m, 500m, 750m, 1000m
   - Provide: Heal to 50%, sell ores, buy ladders
   - **Cannot return** after descending past them

2. **Portable Camp Kit** (v1.1+, Subnautica-style)
   - Purchasable item (expensive)
   - Place anywhere underground
   - Limited uses (3 rests before consumed)
   - Vulnerable to enemy/hazard damage

3. **Emergency Beacon** (accessibility)
   - One-time use item
   - Teleports player + cargo to surface
   - Forfeits depth progress but keeps resources

### What to Avoid

1. **Infinite Safety**: No camping indefinitely
2. **Free Healing**: Always a cost (gold, ladder investment, opportunity)
3. **Breaking Return Journey**: Rest stations shouldn't eliminate the climb back
4. **Required Usage**: Skilled players should be able to skip them

### Tension Maintenance Checklist

- [ ] Ladders still deplete while in rest station
- [ ] Time-limited stay (or consume resources to stay longer)
- [ ] Cannot sell AND resupply fully (choose one)
- [ ] External threats can still reach player (enemies, heat)
- [ ] Visual/audio cues that this is temporary respite

---

## Implementation Priority

### Phase 1: Fixed Milestone Stations (v1.1)
- Simple implementation
- Clear player expectation
- Tests the concept

### Phase 2: Portable Camps (v1.2)
- Player agency in placement
- Resource management layer
- Risk/reward of carrying vs. using

### Phase 3: Checkpoint Modes (v1.3, optional)
- Accessibility option
- Longer session support
- Community feedback-driven

---

## Sources

- [Holy Mountain - Noita Wiki](https://noita.wiki.gg/wiki/Holy_Mountain)
- [The Hidden Depths of Noita - Signal Decay](https://signaldecay.substack.com/p/the-hidden-depths-of-noita)
- [Spelunky Shortcuts - Fandom Wiki](https://spelunky.fandom.com/wiki/Shortcuts)
- [Don't Starve Base Building Tips - Game Rant](https://gamerant.com/dont-starve-base-buildings-tips-tricks-strategy/)
- [Don't Starve Game Design Analysis - Medium](https://annamalecki.medium.com/game-design-analysis-dont-starve-50d06561097d)
- [Cyclops - Subnautica Wiki](https://subnautica.fandom.com/wiki/Cyclops)
- [Cyclops as Mobile Base - Steam Guide](https://steamcommunity.com/sharedfiles/filedetails/?id=2084706535)
- [Hades Chambers and Encounters - Fandom Wiki](https://hades.fandom.com/wiki/Chambers_and_Encounters)
- [Hades Healing Guide - GameSkinny](https://www.gameskinny.com/tips/hades-how-to-heal-guide/)
- [Caves of Qud Checkpoint Modes - Gaming on Linux](https://www.gamingonlinux.com/2021/05/epic-science-fantasy-roguelike-caves-of-qud-adds-new-game-modes-with-checkpoints/)
- [On Roguelikes - Aimlessly Going Forward](https://aimlesslygoingforward.com/blog/2014/01/29/on-roguelikes/)
- [Survival Game Design Principles - Game Design Skills](https://gamedesignskills.com/game-design/survival/)

---

*Research completed: 2026-02-02*
*Supports: GoDig-implement-underground-rest-bf86dfe8*
