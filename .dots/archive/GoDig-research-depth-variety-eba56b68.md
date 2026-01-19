---
title: "research: Depth variety and surprises"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-01-18T23:42:37.350157-06:00\\\"\""
closed-at: "2026-01-19T02:40:58.831666-06:00"
close-reason: Documented depth variety framework, surprise mechanics, visual system, and fatigue prevention strategies
---

Research ways to keep deeper exploration interesting. Ideas: unique biomes, rare discoveries, environmental hazards, treasure rooms, fossils, artifacts. What do similar games do at depth 100, 500, 1000? How do we prevent 'seen it all' fatigue? What unexpected moments delight players?

## Research Findings

### Core Insight: Variety at Every Scale

"Seen it all" fatigue happens when depth only changes numbers (harder blocks, rarer ores) without new experiences. To prevent this, introduce variety at multiple scales:

1. **Micro-variety** (every 10-50m): New ore colors, slight visual changes
2. **Mid-variety** (every 100-200m): New hazards, layer transitions, unlock notifications
3. **Macro-variety** (every 500m): Completely new biome aesthetics, unique mechanics

### Depth Milestone Framework

#### 0-50m: Tutorial Zone (Safe Introduction)
- **Mechanics learned**: Basic digging, picking up ores
- **Visual**: Bright, earthy dirt tones
- **Ores**: Coal (common), Copper (starts at 10m)
- **Hazards**: None
- **Surprise moments**: First ore pickup, first coin earned

#### 50-100m: First Challenge
- **New mechanic**: Fall damage becomes relevant
- **Visual**: Darker dirt, stone patches begin
- **Ores**: Iron appears (depth 50+)
- **Hazards**: Fall damage
- **Surprise moments**: "Blacksmith Unlocked!" (50m), first iron vein
- **Unlock**: Tool upgrades become available

#### 100-200m: Exploration Expands
- **New mechanic**: Equipment shop, backpack pressure
- **Visual**: Transition to stone layer, cave pockets
- **Ores**: Iron plentiful, Silver teases at 200m
- **Hazards**: Unstable sand blocks
- **Surprise moments**: First natural cave, "Equipment Shop Unlocked!"

#### 200-300m: Precious Metals
- **New mechanic**: Silver requires tool tier 1
- **Visual**: Distinct stone layer, blue-gray tones
- **Ores**: Silver (200+), Gold teases at 300m
- **Hazards**: Small water pools, more caves
- **Surprise moments**: First silver, first gem (Amethyst at 200m)

#### 300-500m: Deep Mining Begins
- **New mechanic**: Gas pockets, deeper caves
- **Visual**: Darker, larger caverns
- **Ores**: Gold (300+), rare gems
- **Hazards**: Stale air, larger water features
- **Surprise moments**: First artifact ("Ancient Coin"), first treasure chest

#### 500-1000m: Challenge Zone
- **New mechanic**: Lava pools visible, heat damage
- **Visual**: Reddish tint in deep areas
- **Ores**: Platinum, rare diamonds
- **Hazards**: Explosive gas, flooding
- **Surprise moments**: First lava sighting, legendary artifact

#### 1000m+: Mastery Content
- **New mechanic**: Crystal Caves biome, end-game ores
- **Visual**: Glowing crystals, unique aesthetic
- **Ores**: Mythril, Void Crystals
- **Hazards**: All combined, requires preparation
- **Surprise moments**: First void crystal, prestige eligibility

### Surprise Mechanics Catalog

#### 1. First-Time Discovery Bonuses
Award 2x coins for first discovery of any item type. Creates 50+ unique "first time" moments across the game.

#### 2. Rare Environmental Features
| Feature | Depth | Rarity | Reward |
|---------|-------|--------|--------|
| Natural Cave | 100m+ | 10% per chunk | Easy ore access |
| Underground Lake | 300m+ | 5% per chunk | Aquatic treasures |
| Crystal Grotto | 1000m+ | 2% per chunk | Gem clusters |
| Ancient Ruins | 500m+ | 1% per chunk | Artifacts |
| Treasure Room | 400m+ | 0.5% per chunk | Chest with rare loot |

#### 3. Milestone Notifications
At key depths, show celebration:
- "You've reached 100m!" + small reward
- "New area discovered: Stone Layer"
- "Achievement unlocked: Deep Diver"

#### 4. Random Events (v1.0+)
- "A vein of gold sparkles nearby" (compass reveals location)
- "You feel a tremor..." (cave-in warning)
- "Something glitters in the darkness" (nearby treasure)

### Visual Variety System

#### Color Palettes by Layer
| Layer | Primary | Secondary |
|-------|---------|-----------|
| Topsoil | Brown (#8B4513) | Tan (#A0522D) |
| Subsoil | Gray-brown (#696969) | Slate (#808080) |
| Stone | Blue-gray (#708090) | Steel (#778899) |
| Deep Stone | Dark teal (#2F4F4F) | Olive (#556B2F) |
| Crystal | Purple (#9370DB) | Sky (#87CEEB) |
| Magma | Dark red (#8B0000) | Orange (#FF4500) |
| Void | Navy (#191970) | Black (#000000) |

#### Ambient Effects by Depth
| Depth | Particle | Sound | Screen Effect |
|-------|----------|-------|---------------|
| 0-100 | Dirt dust | Bird chirps fade | None |
| 100-300 | Rock dust | Dripping water | Slight darken |
| 300-500 | Cave mist | Echoes | Darker |
| 500-1000 | Embers | Rumbling | Red tint |
| 1000+ | Crystal sparkle | Ethereal hum | Color shift |

### Preventing "Seen It All" Fatigue

1. **Unlock pacing**: Something new every 50m in early game, 100m in mid game
2. **Collection goals**: 50+ unique collectibles spread across depths
3. **Visual freshness**: Each 200m zone has distinct palette
4. **Mechanical novelty**: New hazard types introduced gradually
5. **Random discoveries**: Rare events keep exploration surprising
6. **Progression visibility**: Always show "next unlock at Xm"

### Similar Game Analysis

**Motherload**: Depth unlocks new ore tiers, visual layers change, boss at bottom
**Terraria**: Biomes create horizontal variety, layers have unique enemies
**SteamWorld Dig**: Puzzle rooms break up digging, collectibles everywhere

### Implementation Priority

**MVP** (must have):
- 7 layer visual transitions
- 5 ore types with depth gating
- Depth milestone notifications
- First-discovery bonus system

**v1.0** (should have):
- Natural cave generation
- Treasure chests
- Artifacts/collectibles (10+)
- Environmental hazards (fall, lava)

**v1.1+** (nice to have):
- Horizontal biomes
- Random events
- 50+ collectibles
- Museum system

## Decisions Made

- [x] What creates surprise? -> First discoveries, rare finds, visual transitions
- [x] How often should something new appear? -> Every 50-100m early game
- [x] What prevents fatigue? -> Collection goals, visual variety, unlock pacing
- [x] MVP priority? -> Layer visuals and ore gating (no caves/artifacts)

## Related Implementation Specs

- `GoDig-dev-layer-visual-1b50e3c1` - Layer visual differentiation
- `GoDig-dev-layer-transition-fe3a551c` - Layer transition system
- `GoDig-dev-depth-milestone-8365ab8c` - Depth milestone notifications
- `GoDig-v1-0-cave-6982cf83` - Cave generation
- `GoDig-v1-0-artifact-76e2f78d` - Artifact spawning
