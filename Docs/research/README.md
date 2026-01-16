# GoDig Research Index

## Overview
Research documentation for an endless 2D mining game built in Godot 4 for mobile/web platforms.

## Game Concept
- **Genre**: Idle mining / dig-down adventure
- **Platform**: Mobile (iOS/Android) + Web
- **Inspiration**: Motherload, SteamWorld Dig, Terraria

## Core Loop
1. Dig down through procedurally generated terrain
2. Collect gems, ores, and treasures
3. Navigate back to surface
4. Sell resources at shops
5. Buy upgrades (tools, gear, buildings)
6. Dig deeper, find rarer resources
7. Repeat

## Research Documents

### Core Mechanics
| Document | Status | Key Decisions |
|----------|--------|---------------|
| [Mining Mechanics](mining-mechanics.md) | ✅ Done | Grid-based digging, risk of getting stuck, wall-jump |
| [Resource Types](resource-types.md) | ✅ Done | 8 tiers, exponential rarity, depth-based |
| [Traversal Mechanics](traversal-mechanics.md) | ✅ Done | Ladders, ropes, wall-jump, fall damage |
| [Inventory System](inventory-system.md) | ✅ Done | Slot-based, stackable, upgradeable capacity |

### World Generation
| Document | Status | Key Decisions |
|----------|--------|---------------|
| [Procedural Generation](procedural-generation.md) | ✅ Done | Chunk-based, threaded, noise-based |
| [Underground Layers](underground-layers.md) | ✅ Done | 8 layers, horizontal biomes, caves |
| [Ore Generation](ore-generation.md) | ✅ Done | Noise + random walk veins, depth-gated |

### Surface & Economy
| Document | Status | Key Decisions |
|----------|--------|---------------|
| [Surface Shops](surface-shops.md) | ✅ Done | 6 shop categories, unlock progression |
| [Economy & Progression](economy-progression.md) | ✅ Done | Tool tiers, currency, prestige system |

### Technical
| Document | Status | Key Decisions |
|----------|--------|---------------|
| [Mobile Controls](mobile-controls.md) | ✅ Done | Virtual joystick + tap-to-dig |
| [Save System](save-system.md) | ✅ Done | Resources for player, binary for chunks |

### Polish & UX
| Document | Status | Key Decisions |
|----------|--------|---------------|
| [Audio & Sound Design](audio-sound-design.md) | ✅ Done | Material-based SFX, depth ambient, haptics |
| [Visual Style](visual-style.md) | ✅ Done | 16x16 pixel art, layer color themes, lighting |
| [Tutorial & Onboarding](tutorial-onboarding.md) | ✅ Done | Progressive disclosure, 5-min tutorial |
| [Game Feel & Juice](game-feel-juice.md) | ✅ Done | Screen shake, particles, squash/stretch |
| [Player Onboarding](player-onboarding.md) | ✅ Done | Contextual hints, FTUE flow, skip options |

### Player Psychology & Design
| Document | Status | Key Decisions |
|----------|--------|---------------|
| [Psychology of Mining](psychology-of-mining.md) | ✅ Done | Discovery loop, collection psychology, risk/reward |
| [Session Design](session-design.md) | ✅ Done | 5-15 min target, natural stopping points, retention |
| [Surface Expansion](surface-expansion.md) | ✅ Done | Slot-based MVP, endless horizontal, building progression |

### Content & Challenges
| Document | Status | Key Decisions |
|----------|--------|---------------|
| [Hazards & Challenges](hazards-challenges.md) | ✅ Done | Environmental hazards, depth-based danger, death penalty |
| [Unique Treasures](unique-treasures.md) | ✅ Done | Gems, artifacts, fossils, collection system |
| [End Game & Goals](end-game-goals.md) | ✅ Done | Prestige system, mastery, long-term progression |

### Technical & Optimization
| Document | Status | Key Decisions |
|----------|--------|---------------|
| [Performance Optimization](performance-optimization.md) | ✅ Done | 16x16 chunks, threading, object pooling, battery |
| [Upgrade Paths](upgrade-paths.md) | ✅ Done | Tool tiers, equipment slots, building levels |
| [Accessibility Features](accessibility-features.md) | ✅ Done | Colorblind modes, one-hand play, visual cues |

### Decisions & Social
| Document | Status | Key Decisions |
|----------|--------|---------------|
| [Dig Upward Decision](dig-upward-decision.md) | ✅ Done | No at start, unlock Drill at 500m |
| [Notifications & Engagement](notifications-engagement.md) | ✅ Done | Ethical hooks, daily rewards, opt-in |
| [Social Features](social-features.md) | ✅ Done | Leaderboards, achievements, v1.1+ priority |

## Open Design Questions

### Core Gameplay
- [ ] Fuel/energy mechanic or inventory-pressure only?
- [ ] How punishing is "getting stuck"?
- [x] Can player dig upward? → No at start, Drill unlocks at 500m
- [ ] Combat/enemies in the mine?

### Economy
- [ ] Single currency (coins) or multi-currency?
- [ ] Crafting system or pure buy/sell?
- [ ] Prestige system at launch or add later?
- [ ] How many total resource types?

### Technical
- [ ] Optimal chunk size for mobile (8x8? 16x16?)
- [ ] Landscape or portrait orientation?
- [ ] Fantasy setting or realistic?

## Recommended Starting Point

Based on research, here's the suggested MVP feature set:

### Must Have (MVP)
1. Grid-based digging (down, left, right)
2. 3-4 layer types with different hardness
3. 5-6 ore types with depth-based rarity
4. Wall-jump for returning to surface
5. Basic inventory system
6. One shop (buy/sell)
7. 2-3 tool upgrade tiers
8. Virtual joystick + tap controls
9. Auto-save system

### Should Have (v1.0)
1. Placeable ladders
2. 6+ shop types
3. Building placement on surface
4. Cave generation
5. 8+ ore types
6. Fall damage
7. Achievement system

### Nice to Have (v1.1+)
1. Prestige/rebirth system
2. Underground biomes
3. Enemies
4. Automation buildings
5. Cloud save

## File Structure Recommendation

```
godig/
├── scenes/
│   ├── main.tscn
│   ├── player/
│   │   └── player.tscn
│   ├── world/
│   │   ├── world.tscn
│   │   └── chunk.tscn
│   ├── ui/
│   │   ├── hud.tscn
│   │   ├── inventory.tscn
│   │   └── shop.tscn
│   └── surface/
│       └── buildings/
├── scripts/
│   ├── autoload/
│   │   ├── game_manager.gd
│   │   └── save_manager.gd
│   ├── player/
│   ├── world/
│   └── ui/
├── resources/
│   ├── tiles/
│   ├── items/
│   └── upgrades/
└── assets/
    ├── sprites/
    ├── audio/
    └── fonts/
```

## Next Steps
1. Create prototype with basic digging + movement
2. Implement chunk system with persistence
3. Add shop and upgrade loop
4. Polish controls for mobile
5. Playtest and iterate
