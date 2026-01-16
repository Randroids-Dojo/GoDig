# Surface Expansion Design

## Core Concept
The surface is an endless horizontal plane where players build a mining town. As they progress underground, they unlock and build new shops and facilities on the surface.

## Technical Implementation

### Endless Horizontal World

#### Chunk-Based Surface
```gdscript
const SURFACE_CHUNK_WIDTH = 32  # tiles
var loaded_surface_chunks = {}

func _update_surface_around_player(player_x: float):
    var current_chunk = int(player_x / (SURFACE_CHUNK_WIDTH * TILE_SIZE))

    # Load chunks in view + buffer
    for i in range(-2, 3):
        var chunk_id = current_chunk + i
        if chunk_id not in loaded_surface_chunks:
            _load_surface_chunk(chunk_id)

    # Unload distant chunks
    _cleanup_surface_chunks(current_chunk)
```

#### Surface Generation
- Mostly flat terrain with slight undulation
- Occasional features (trees, rocks, grass)
- Building plots at regular intervals
- Mine entrance at origin (x=0)

### Infinite Scrolling Implementation

#### Camera Boundaries
- Camera follows player horizontally
- No left/right world boundaries
- Vertical boundary at surface level
- Smooth scroll, no jarring transitions

#### Parallax Background
- Sky layer (fixed)
- Cloud layer (slow parallax)
- Mountain layer (medium parallax)
- Hills layer (fast parallax)
- Ground layer (1:1 with player)

### World Origin
- **Mine entrance at x=0**
- Player starts here
- Buildings expand left AND right from origin
- Creates "town center" at mine entrance

## Building Placement System

### Option A: Slot-Based (Recommended for MVP)

#### Predetermined Slots
```
... [SLOT] [SLOT] [MINE] [SLOT] [SLOT] [SLOT] ...
         ←  West    |    East  →
```

- Fixed positions for buildings
- Simple implementation
- Clear progression path
- Each slot has a cost to "unlock"

#### Slot Implementation
```gdscript
var building_slots = [
    {"position": -3, "building": null, "unlocked": false, "cost": 0},      # Mine
    {"position": -2, "building": null, "unlocked": true, "cost": 0},       # General Store (free)
    {"position": -1, "building": null, "unlocked": true, "cost": 0},       # Supply Store (free)
    {"position": 1, "building": null, "unlocked": false, "cost": 1000},    # Slot 1
    {"position": 2, "building": null, "unlocked": false, "cost": 5000},    # Slot 2
    {"position": 3, "building": null, "unlocked": false, "cost": 15000},   # Slot 3
    # ... more slots at increasing costs
]
```

#### Pros
- Simple UI: "Unlock slot for X coins"
- Clear progression
- No collision detection needed
- Easy to balance

#### Cons
- Less player agency
- Predetermined feel
- Can't optimize layout

### Option B: Free Placement (v1.1+)

#### Grid-Based Free Placement
- Buildings occupy tiles
- Check for collision with existing buildings
- Minimum spacing requirements
- Player chooses exact location

#### Complexity
- Need building footprints
- Collision detection
- Pathfinding around buildings
- Save/load building positions

### Hybrid Approach (Recommended)

#### MVP: Slot-based
- Unlock slots with coins
- Assign building type to slot
- Simple and clear

#### v1.0: Semi-free
- Choose which building goes in which slot
- Swap buildings between slots
- Upgrade slots for better bonuses

#### v1.1+: Full town builder
- Free placement
- Building adjacency bonuses
- Town layout optimization

## Building Types & Progression

### Starting Buildings (Always Present)
1. **Mine Entrance** - Center of town, entry to underground
2. **General Store** - Sell resources (starts unlocked)
3. **Supply Store** - Buy basics (starts unlocked)

### Early Unlocks (Depth 50-200m)
4. **Blacksmith** - Tool upgrades
5. **Equipment Shop** - Gear purchases
6. **Warehouse** - Storage expansion

### Mid-Game Unlocks (Depth 200-500m)
7. **Gem Appraiser** - Better gem prices
8. **Gadget Shop** - Utility items
9. **Elevator Station** - Fast travel

### Late-Game Unlocks (Depth 500m+)
10. **Refinery** - Process ores
11. **Research Lab** - Tech tree
12. **Museum** - Collections

### End-Game Unlocks (Depth 1000m+)
13. **Auto-Miner Station** - Automation
14. **Portal Hub** - Deep teleportation
15. **Exchange** - Premium trading

## Building Visuals

### Visual Progression
Each building has upgrade levels with visual changes:

```
Level 1: Small wooden shack
Level 2: Stone foundation, bigger
Level 3: Two-story building
Level 4: Decorated, signs
Level 5: Grand establishment with lights
```

### Building Size
- All buildings same width (simplifies slots)
- Height varies by type/level
- Consistent art style

### Animation
- Smoke from chimneys
- Signs swaying
- NPCs walking around (optional)
- Lights on/off by time?

## Town Atmosphere

### Day/Night Cycle (Optional)
- Shops close at night?
- Different ambiance
- Lamp posts light up
- Stars appear

### Weather (Optional)
- Rain particles
- Snow in winter?
- Purely cosmetic
- Affects nothing mechanically

### NPCs (Optional, v1.1+)
- Shopkeepers visible in buildings
- Random townspeople walking
- Adds life to the town
- Dialog/story?

## Technical Considerations

### Save Data
```gdscript
var surface_save_data = {
    "slots": [
        {"id": 0, "building_type": "general_store", "level": 2},
        {"id": 1, "building_type": "blacksmith", "level": 1},
        {"id": 2, "building_type": null, "unlocked": false},
        # ...
    ],
    "unlocked_buildings": ["general_store", "supply_store", "blacksmith"],
    "total_coins_spent_on_surface": 50000
}
```

### Performance
- Only render visible buildings
- LOD for distant buildings (simpler sprites)
- Cull off-screen decorations
- Efficient building pooling

## Interaction System

### Entering Buildings
1. Player walks to building
2. "Enter" button appears (or auto-enter on collision)
3. Transition to shop UI
4. Full-screen shop interface
5. Exit returns to surface

### Building Information
- Hover/tap shows building name
- Level indicator above building
- "Upgrade available!" icon when affordable

## Progression Feeling

### Starting Town
```
[empty] [empty] [Store] [MINE] [Supply] [empty] [empty]
```
Small, humble beginning

### Mid-Game Town
```
[Equip] [Blacksmith] [Store] [MINE] [Supply] [Gems] [Gadgets]
```
Growing prosperity

### End-Game Town
```
[Portal] [Research] [Museum] [Refinery] [Equip] [Blacksmith] [Store] [MINE] [Supply] [Gems] [Gadgets] [Elevator] [Auto-Mine] [Exchange]
```
Bustling mining empire

## Questions to Resolve
- [x] Slot-based vs free placement for MVP? → Slot-based for MVP
- [x] How many total building slots? → 10 for MVP, 15+ for v1.0
- [x] Building upgrade levels (max 5?) → 3 for MVP, 5 for v1.0
- [x] Day/night cycle in v1.0 or later? → v1.1+ (cosmetic only)
- [x] NPCs: worth the effort? → v1.1+ (optional, adds atmosphere)

## Recommendation Summary

### MVP
- 10 building slots (5 each direction from mine)
- Slot-based placement
- 3 upgrade levels per building
- No day/night, no NPCs
- Simple but functional

### v1.0
- 15+ building slots
- All building types available
- 5 upgrade levels
- Building swapping
- Visual polish

### v1.1+
- Free placement option
- Day/night cycle
- NPCs
- Town events
- Building adjacency bonuses
