# GoDig Development Roadmap

## Overview
Task tracking via `dot` command. Run `dot tree` to see full hierarchy.

## Critical Path for MVP

### Phase 0: Decisions (ALL RESOLVED)
All blocking decisions have been made:
1. **Dig upward** - NO for MVP. Drill upgrade in v1.0 allows it.
2. **Fuel mechanic** - NO. Inventory pressure + fall damage creates tension.
3. **Screen orientation** - PORTRAIT (one-handed mobile play)
4. **Chunk size** - 16x16 tiles per chunk
5. **Art style** - FANTASY-LITE (real minerals + fantasy elements like mythril)

### Phase 1: Foundation
```
DEV: Project setup
├── DEV: GameManager autoload
├── DEV: SaveManager autoload
└── ASSETS: Terrain tileset sprites
    └── DEV: Create TileSet with block types
```

### Phase 2: World System
```
DEV: Chunk data structure
├── DEV: ChunkManager - load/unload
├── DEV: Noise-based terrain generation
│   └── DEV: OreGenerator - noise per ore
│       └── DEV: Ore depth-gating
│           └── DEV: Ore vein expansion
└── DEV: Chunk persistence
```

### Phase 3: Player
```
DEV: Player scene (CharacterBody2D)
├── DEV: Player grid-based digging
│   ├── DEV: Player dig animation
│   └── DEV: Auto-pickup on dig
└── DEV: Player wall-jump ability
```

### Phase 4: Resources & Inventory
```
DEV: ItemData resource class
├── DEV: OreData definitions
└── DEV: InventoryManager singleton
    ├── DEV: Inventory add/remove/stack
    └── DEV: Inventory UI (mobile)
```

### Phase 5: Economy
```
DEV: Currency system (coins)
├── DEV: Sell resources for coins
│   └── DEV: Shop scene (buy/sell UI)
├── DEV: ToolData resource class
│   └── DEV: Tool tier definitions
│       └── DEV: Tool upgrade purchase
```

### Phase 6: Mobile Controls
```
DEV: Platform detection
├── DEV: Virtual joystick
├── DEV: Tap-to-dig system
└── DEV: Jump button
```

### Phase 7: HUD
```
DEV: Depth indicator HUD
DEV: Coin counter HUD
DEV: Inventory slots preview HUD
```

## MVP Completion Criteria
All 9 items from research README.md:
- [ ] Grid-based digging (down, left, right)
- [ ] 3-4 layer types with different hardness
- [ ] 5-6 ore types with depth-based rarity
- [ ] Wall-jump for returning to surface
- [ ] Basic inventory system
- [ ] One shop (buy/sell)
- [ ] 2-3 tool upgrade tiers
- [ ] Virtual joystick + tap controls
- [ ] Auto-save system

## Command Reference
```bash
dot ready          # Show unblocked tasks
dot tree           # Show full hierarchy
dot on <id>        # Start working on task
dot off <id>       # Complete task
dot show <id>      # Show task details with blockers
dot blocked        # Show what's blocked
```

## Version Milestones

### MVP (Playable Demo)
Core loop working: dig → collect → sell → upgrade → repeat

### v1.0 (Full Release)
- Ladder placement
- Fall damage
- Cave generation
- Achievement system
- Multiple shop types
- Surface building placement

### v1.1+ (Post-Launch)
- Prestige/rebirth
- Underground biomes
- Enemies
- Automation
- Cloud save

## Research Status

### Completed Research (42 documents)
- Mining mechanics, Resource types, Inventory system
- Chunk system, Underground layers, Ore generation
- Traversal mechanics, Mobile controls, Save system
- Economy progression, Shop types
- Portrait orientation, Tool tiers, Block hardness

### Open Research Questions
All major research questions have been resolved. Remaining items are deferred to v1.0+.

## Stats (Updated: 2026-01-16)
- Total tasks: 310
- Completed: 108
- Open: 202
- Research docs: 48 (100% complete)
- Research questions: 0 open (all resolved)
- All blocking decisions made
- Ready for implementation phase

### Underground Layer System Tasks
- DEV: Define 7 underground layer types (Topsoil→Void)
- DEV: Layer depth boundaries (0-50m, 50-200m, etc.)
- DEV: Layer color palettes (browns→grays→blues→reds)
- DEV: Infinite depth scaling (no hard cap)
- v1.0: Crystal Caves layer (1000-2000m, glowing)
- v1.0: Magma Zone layer (2000-5000m, heat hazards)
- v1.1+: Void Depths layer (5000m+, end-game)

### Traversal System Tasks
- DEV: Ladder placement system (grid-based, validation)
- DEV: Climbing state for player
- DEV: Traversal item persistence
- DEV: Ladder quick-slot HUD
- v1.0: Placeable ladders, Rope item, Grappling hook, Elevator

## Key Design Decisions Made
1. **No fuel mechanic** - Inventory pressure creates return-to-surface tension
2. **No dig upward** - Forces strategic route planning (drill upgrade in v1.0)
3. **Portrait orientation** - One-handed mobile play
4. **16x16 chunk size** - Good performance/memory balance
5. **Fantasy-lite art** - Real minerals with fantasy elements
6. **8 starting inventory slots** - Upgradeable to 30
7. **9 tool tiers** - Rusty to Void pickaxe
8. **7 underground layers** - Topsoil to Void Depths
9. **Hybrid ore generation** - Noise + random walk veins
10. **Slot-based building placement** - Simpler for mobile MVP
