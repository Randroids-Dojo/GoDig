# GoDig - Game Design Summary

> **Comprehensive design document consolidating decisions from 48 research documents.**

## Game Concept

**Genre**: Idle mining / dig-down adventure
**Platform**: Mobile (iOS/Android) + Web
**Engine**: Godot 4.3+
**Inspiration**: Motherload, SteamWorld Dig, Terraria

### Core Fantasy
Dig endlessly downward through procedurally generated terrain, discovering increasingly rare treasures, then return to the surface to sell resources and upgrade your equipment for deeper expeditions.

---

## Core Game Loop

```
1. DIG DOWN → Mine resources, break blocks
2. COLLECT → Fill inventory with ores/gems
3. RETURN → Navigate back to surface (wall-jump, ladders, ropes)
4. SELL → Exchange resources at shops
5. UPGRADE → Buy better tools, expand capacity
6. REPEAT → Go deeper, find rarer resources
```

---

## World Structure

### Surface (Endless Horizontal)
- Scrolls infinitely left/right
- Slot-based building placement (MVP)
- Shop buildings unlock progressively
- Starting point for all expeditions

### Underground (Infinite Depth)

| Layer | Depth | Hardness | Ores | Hazards |
|-------|-------|----------|------|---------|
| Topsoil | 0-50m | 10-15 | Coal, Copper | None |
| Subsoil | 50-200m | 15-25 | Iron, Tin | Water pools |
| Stone | 200-500m | 30-50 | Silver, Gold | Caves |
| Deep Stone | 500-1km | 50-80 | Platinum, Gems | Lava, gas |
| Crystal | 1-2km | 80-120 | Mythril, Diamond | Enemies |
| Magma | 2-5km | 120-180 | Adamantine | Heat damage |
| Void | 5km+ | 200+ | Void Crystals | Unknown |

### Horizontal Biomes (per layer)
- **Normal** - Standard terrain
- **Ice Caves** - Blue tint, slippery
- **Mushroom Caverns** - Bioluminescent
- **Ancient Ruins** - Man-made structures, artifacts

---

## Mining Mechanics

### Grid-Based Digging
- 16x16 pixel tiles (player-sized)
- Dig directions: **Down, Left, Right**
- **No digging up** at start
- **Drill tool** unlocks upward digging at 500m depth

### Break Time Formula
```gdscript
break_time = block.hardness / tool.damage / tool.speed_multiplier
```

### The Core Tension
> "The risk of getting stuck creates natural strategic thinking about routes."

Wall-jumping transforms "stuck" from binary failure to a challenge, making players feel clever when they escape tight spots.

---

## Tool Progression

| Tier | Tool | Damage | Speed | Cost | Unlock |
|------|------|--------|-------|------|--------|
| 1 | Rusty Pickaxe | 10 | 1.0x | Free | Start |
| 2 | Copper Pickaxe | 20 | 1.0x | 500 | 25m |
| 3 | Iron Pickaxe | 35 | 1.0x | 2,000 | 100m |
| 4 | Steel Pickaxe | 55 | 1.1x | 8,000 | 250m |
| 5 | Silver Pickaxe | 75 | 1.0x | 25,000 | 400m |
| 6 | Gold Pickaxe | 80 | 0.9x | 50,000 | 500m |
| 7 | Mythril Pickaxe | 120 | 1.0x | 100,000 | 700m |
| 8 | Diamond Pickaxe | 180 | 1.2x | 300,000 | 1000m |
| 9 | Void Pickaxe | 250 | 1.3x | 1,000,000 | 2000m |

---

## Traversal System

### Built-in Mechanics
- **Wall-Jump** - Core return mechanic, free (built-in skill)
- **Climbing** - On ladders and ropes

### Consumable Items
| Item | Stack | Cost | Purpose |
|------|-------|------|---------|
| Ladder | 50 | 10 | Permanent placement, climbable both ways |
| Rope | 20 | 50 | Extends downward from anchor, 10 tiles max |
| Teleport Scroll | 5 | 500 | Emergency return to surface |

### Permanent Tools
| Item | Cost | Unlock | Function |
|------|------|--------|----------|
| Grappling Hook | 25,000 | 500m | Aim-and-fire, 15 tile range, 3s cooldown |
| Drill | Special | 500m | Enables digging upward |

### Buildings
- **Elevator** - 50,000 coins at 500m, fast travel to any connected depth

---

## Surface Buildings

### Starting (Always Available)
1. **General Store** - Sell resources
2. **Supply Store** - Buy ladders, ropes, consumables

### Early Unlocks (50-200m)
3. **Blacksmith** - Tool upgrades
4. **Equipment Shop** - Helmet, boots, gloves, backpack
5. **Warehouse** - Storage expansion

### Mid-Game (200-500m)
6. **Gem Appraiser** - Better gem prices
7. **Gadget Shop** - Compass, detector, grappling hook
8. **Elevator Shaft** - Fast travel system

### Late-Game (500m+)
9. **Refinery** - Process ore into ingots
10. **Research Lab** - Tech tree unlocks
11. **Museum** - Collection bonuses

### End-Game (1000m+)
12. **Auto-Miner Station** - Idle resource generation
13. **Portal** - Deep teleportation
14. **Precious Metals Exchange** - Premium trading

---

## Economy

### Currency
- **Single currency: Coins** (simple, universal)
- Specific ores required for crafting upgrades

### Price Scaling
```
Tier N cost ≈ Tier N-1 cost × 2 to 4
```

### Pacing Targets
- First upgrade: 2-5 minutes
- Mid-game: 1-2 hours
- Soft end: 10-20 hours
- 100% completion: 50+ hours

---

## Inventory System

### Slot-Based Design
- Start: 8 slots
- Max (upgradeable): 30 slots
- Items stack within slots
- Full inventory forces return to surface

### QoL Features
- Auto-pickup nearby items
- Stack similar items automatically
- Quick-sell button (sell all common)
- Inventory full warning at 80%

---

## Technical Architecture

### Chunk-Based World Generation
- **Chunk size**: 16x16 tiles (optimal for mobile)
- Load 5x5 chunk area around player
- Threaded generation to prevent stutters
- Noise-based terrain with deterministic seed

### Data Architecture (Godot Resources)
```gdscript
# Example Resource pattern
class_name BlockData extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var base_hardness: float = 10.0
@export var tile_atlas_coords: Vector2i = Vector2i.ZERO
@export var category: String = "dirt"
@export var drops: Array[DropData] = []
```

### Registry Pattern
- DataRegistry singleton loads all .tres files at startup
- `DataRegistry.get_block(id)`, `DataRegistry.get_ore(id)`, etc.

### Save System
- **Player data**: Godot Resources (.tres)
- **Chunk modifications**: Binary/compressed (.res)
- **Auto-save**: Every 2 minutes + on background
- **Web storage**: IndexedDB (~50MB limit)

---

## Camera System

### Follow Behavior
- Smooth lerp with look-ahead
- Surface: 2.0x zoom (wider view)
- Underground: 2.5x zoom (tighter focus)

### Darkness/Lighting
- Helmet light radius (upgradeable)
- Shader-based darkness at edges
- Glow from gems and lava in deep zones

| Helmet Level | View Radius | Cost |
|--------------|-------------|------|
| None | 3 tiles | Free |
| Basic | 5 tiles | 1,000 |
| Improved | 7 tiles | 5,000 |
| Advanced | 10 tiles | 20,000 |
| Master | 15 tiles | 100,000 |

---

## Mobile Controls

### Primary Layout
```
┌─────────────────────────────────────┐
│  [Coins]    [Depth]    [Inv] [Menu] │
│                                     │
│              GAME VIEW              │
│         (tap blocks to dig)         │
│                                     │
│  ┌───┐                       ┌───┐  │
│  │JOY│                       │JMP│  │
│  │   │                       │   │  │
│  └───┘                       └───┘  │
│        [LADDER: 25]                 │
└─────────────────────────────────────┘
```

### Control Scheme
- **Left**: Virtual joystick (movement, climbing)
- **Right**: Tap on blocks to dig (if adjacent)
- **Jump button**: Right side
- **Quick-slot**: Ladder placement

---

## Visual Style

### Art Direction
- **16x16 pixel art** tiles
- Fantasy-lite aesthetic (real ores + magical effects)
- Layer-based color palettes

### Layer Color Themes
| Layer | Primary | Accent |
|-------|---------|--------|
| Dirt | Brown #8B4513 | Tan |
| Stone | Gray #808080 | Blue-gray |
| Deep | Dark blue-gray #2F4F4F | Crystal blue |
| Magma | Obsidian #1A1A1A | Orange #FF4500 |

### Player Animations
- Idle (4 frames), Walk (6), Jump (3), Fall (2), Dig (4), Climb (4)

---

## Sound Design

### Material-Based SFX
- Each block type has unique dig/break sounds
- Ores have satisfying "discovery" chimes
- Pickups have positive audio feedback

### Dynamic Music
- Surface: Upbeat, adventurous
- Underground: Ambient, mysterious
- Deep zones: Tense, bass-heavy

### Haptics (Mobile)
- Light tap on block break
- Medium pulse on ore discovery
- Strong pulse on rare find

---

## Session Design

### Target Session Length
- **Ideal**: 5-15 minutes
- **Natural stopping points**: Return to surface, shop visits

### Retention Hooks
- Daily rewards (ethical, non-punishing)
- Depth milestones with celebrations
- "Just one more run" psychology

---

## Death & Respawn

### Death Penalty (Depth-Scaled)
| Depth | Inventory Loss | Coin Loss | Equipment |
|-------|---------------|-----------|-----------|
| 0-500m | 10% | 0% | Minor damage |
| 500-2000m | 20% | 5% | Moderate damage |
| 2000m+ | 30% | 10% | Heavy damage |

### Key Rules
- **Always respawn at surface** - Simple, predictable
- **No permadeath** - Optional hardcore mode v1.1+
- **Player structures protected** - Hazards cannot destroy ladders
- **Hazard tutorials** - First-encounter contextual popups

---

## Monetization (Freemium)

### Core Principles
- **Never pay-to-win**
- **Respect player time**
- **No artificial frustration**

### Revenue Streams
1. **Cosmetics** - Skins, effects, themes
2. **Convenience** - Inventory expansion, auto-features
3. **Supporter Pack** - One-time purchase, removes ads
4. **Optional Ads** - Watch for bonus rewards (never forced)

---

## Accessibility

### Visual
- High contrast mode
- Colorblind palettes (3 options)
- Scalable UI (80-120%)

### Motor
- One-hand play mode
- Adjustable joystick position/size
- Auto-dig option

### Audio
- Visual cues for all sound-based info
- Subtitle support
- Screen reader compatibility for menus

---

## MVP Scope

### Must Have
1. Grid-based digging (down, left, right)
2. 3-4 layer types with hardness
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
8. **Prestige system** (essential for retention)

### Nice to Have (v1.1+)
1. Skill trees (post-prestige)
2. Underground biomes
3. Optional enemies (Infested Zones)
4. Automation buildings
5. Cloud save
6. Daily/weekly challenges

---

## File Structure

```
godig/
├── scenes/
│   ├── main.tscn
│   ├── player/player.tscn
│   ├── world/world.tscn, chunk.tscn
│   ├── ui/hud.tscn, inventory.tscn, shop.tscn
│   └── surface/buildings/
├── scripts/
│   ├── autoload/game_manager.gd, save_manager.gd, data_registry.gd
│   ├── player/
│   ├── world/
│   └── ui/
├── resources/
│   ├── blocks/, ores/, tools/, buildings/, layers/
│   └── config/game_balance.tres
└── assets/
    ├── sprites/, audio/, fonts/
```

---

## Key Design Principles

1. **Restriction creates depth** - No mid-air digging, no upward digging (until unlocked)
2. **Risk vs reward tension** - Easy to go down, challenging to return
3. **Meaningful progression** - Each upgrade should feel impactful
4. **Avoid dead zones** - Something new every 10-15 minutes
5. **Mobile-first** - Large touch targets, portrait orientation, battery-conscious
6. **Respect the player** - No artificial frustration, ethical monetization

---

## Research Document Index

Full research documentation available in `Docs/research/`:
- Core mechanics (mining, traversal, inventory)
- World generation (procedural, layers, ores)
- Economy (shops, progression, upgrades)
- Technical (save system, performance, data)
- Polish (audio, visual, game feel, accessibility)
- Strategy (monetization, session design, competitive analysis)

**Total**: 48 research documents covering all aspects of game design.
