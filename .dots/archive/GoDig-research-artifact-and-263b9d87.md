---
title: "research: Artifact and collectible systems in mining games"
status: closed
priority: 2
issue-type: research
created-at: "\"2026-02-02T22:25:32.493474-06:00\""
closed-at: "2026-02-02T22:32:04.605195-06:00"
close-reason: Completed research on artifact/collectible systems from Stardew Valley museum, Hollow Knight relics, and collection psychology. Documented museum design, discovery journal rewards, and pity systems.
---

## Research Question

What makes finding unique items feel special in mining games? How do collection completion rewards and discovery journals create long-term engagement?

## Key Findings

### 1. Stardew Valley Museum System - The Gold Standard

**Core Design:**
- 95 total items to donate (artifacts + minerals)
- Rewards at regular intervals (every 5 donations early, every 10 later)
- "The progression of rewards feels so natural"

**What Makes It Work:**
- Each artifact has a description that "adds to the rich lore"
- "Deepens your connection to the game world"
- Visual satisfaction: "There's an undeniable joy in seeing the museum's cases fill up"
- Community contribution feeling: "enriching Pelican Town"

**Key Rewards:**
- Rusty Key (unlocks Sewers) - opens new area
- Magnifying Glass (unlocks Secret Notes) - enables new discovery
- Dwarvish Translation Guide - unlocks NPC communication
- Rewards are "critical for farm progression, combat efficiency, and unlocking new areas"

**Design Principle:** Rewards are functional, not just cosmetic. They change gameplay.

### 2. Hollow Knight's Environmental Discovery

**Storytelling Through Items:**
- "Story is a puzzle that can be pieced together through cutscenes, dialogues, lore tablets and Hunter's Journal"
- "Environmental storytelling requires players to interpret ruins, enemy behaviors, and ambient sounds"
- Items have intrinsic meaning, not just value

**Relic System:**
- Relic Seeker Lemm buys items for Geo
- Items found in hidden rooms and secret areas
- Arcane Eggs, King's Idols - multiple per type to find
- Discovery is self-motivated, not quest-driven

**Hidden Room Design:**
- Secrets "tucked behind platforming challenges or ability gates"
- Shrine of Believers - backer names as in-universe lore
- "There's always something new to uncover"

### 3. Collection Psychology

**What Drives Collectors:**
- "Innate desire for... collection completionism"
- Variable-ratio reinforcement (unpredictable rewards)
- "Anticipation and excitement of potentially obtaining a rare item"
- Dopamine release on discovery

**Making Items Feel Special:**
- "True uniqueness stems from a blend of factors" beyond numerical stats
- Rarity tiers (common to legendary) create "sense of accomplishment"
- Visual distinctiveness matters
- Story/lore connection creates emotional investment

**Pity Systems:**
- "Guarantee a rare reward after a set number of unsuccessful draws"
- "Helps players feel their investment will eventually pay off"
- Duplicate conversion reduces frustration

### 4. Collection Completion Design

**Milestone Rewards:**
- Small boosts early on
- Key unlocks mid-game (areas, NPCs)
- "Incredible endgame items" for completion
- Spacing creates "natural motivation"

**100% Completion:**
- Stardew: Museum completion required for "perfection"
- Creates long-term goal
- "Many dedicated players strive for"

**Visual Progress:**
- See how many items found vs total
- Compare against other players (social element)
- Empty slots create "pull" to fill them

## Application to GoDig

### Museum Building Design

**Core Concept: Underground History Museum**
- Unlock at 200m depth
- Curator NPC buys/displays artifacts
- Each artifact tells story of what lived/existed at that depth

**Artifact Categories:**
| Category | Examples | Found At |
|----------|----------|----------|
| Fossils | Ancient fish, plant fossils | 0-500m |
| Ancient Tools | Old pickaxes, mining lamps | 200-800m |
| Crystal Formations | Unique gem clusters | 500-1500m |
| Mysterious Relics | Unknown technology | 1000m+ |
| Void Artifacts | Strange void materials | 2000m+ |

### Discovery Journal System

**Hunter's Journal Equivalent:**
- Auto-tracks first discovery of each ore type
- Records deepest depth reached
- Logs unique finds and their locations
- Unlocks lore snippets about world history

**Journal Rewards:**
- 10 entries: Slight ore radar range increase
- 25 entries: Rare ore sparkle visibility
- 50 entries: Artifact dowsing ability
- 100 entries: Legendary item hint system

### Making Discoveries Feel Special

**Visual Feedback:**
- Unique glow/particle effect for artifacts
- Screen flash on first-time discovery
- Special sound cue (different from regular ore)
- "NEW" badge in journal

**Narrative Integration:**
- Each artifact has flavor text
- References to ancient miners, civilizations
- Builds world history organically
- Optional deep lore for interested players

### Collection Completion Rewards

**Tier System:**
| Completion | Reward |
|------------|--------|
| 25% | Artifact Compass (shows nearby artifacts) |
| 50% | Ancient Map (reveals hidden cave rooms) |
| 75% | Void Scanner (detects rare ores through walls) |
| 100% | Legendary Pickaxe (unique visual, small stat boost) |

### Anti-Frustration Features

**From Research:**
1. **Pity system**: Guaranteed artifact after X blocks mined at eligible depth
2. **Duplicate value**: Repeated artifacts sell for good coins
3. **Progress visibility**: Show "X/Y artifacts at this depth" on HUD
4. **Location hints**: After 50% completion, hint at remaining artifact locations

### Depth-Based Discovery Zones

| Depth | New Discovery Type | Rarity |
|-------|-------------------|--------|
| 0-100m | Common fossils, old coins | Every run |
| 100-300m | Mining tools, early relics | Most runs |
| 300-500m | Crystal formations, rare fossils | Some runs |
| 500-1000m | Ancient machinery parts | Occasional |
| 1000-2000m | Mysterious relics | Rare |
| 2000m+ | Void artifacts | Very rare |

## Implementation Recommendations

### Phase 1 (v1.0): Basic Artifacts
- 10-15 unique artifacts
- Simple journal tracking
- Sell to general store for bonus coins
- Visual feedback on discovery

### Phase 2 (v1.1): Museum Building
- Dedicated display building
- Curator NPC with dialogue
- Milestone rewards
- Artifact descriptions and lore

### Phase 3 (v1.2+): Complete System
- Full 50+ artifact collection
- Discovery journal with rewards
- Location hints for completionists
- Social comparison features

## Design Principles

1. **Functional Rewards** - Artifacts should DO something, not just exist
2. **Lore Connection** - Each item tells part of the world's story
3. **Visual Distinctiveness** - Must look special when found
4. **Progress Visibility** - Always show how close to completion
5. **Pacing** - Regular discoveries, not too sparse or too common
6. **Respect Time** - Pity systems ensure effort is rewarded

## Sources

- [Stardew Valley Museum Wiki](https://stardewvalleywiki.com/Museum)
- [Stardew Museum Rewards Guide - Wonderful Museums](https://www.wonderfulmuseums.com/museum/stardew-museum-rewards/)
- [Donating to Museum Guide - Wonderful Museums](https://www.wonderfulmuseums.com/museum/donating-to-museum-stardew/)
- [Hollow Knight Lore Wiki](https://hollowknight.wiki.fextralife.com/Lore)
- [Hollow Knight Collectibles Guide - Steam Community](https://steamcommunity.com/sharedfiles/filedetails/?id=3059319613)
- [Attracting Players with Collection Systems - GameRefinery](https://www.gamerefinery.com/attracting-and-retaining-players-with-collection-systems/)
- [Psychology Behind Gacha Games - ultimategacha.com](https://ultimategacha.com/opinion-psychology-of-gacha-games/)

## Status

Research complete. Provides foundation for artifact system and museum building implementation.
