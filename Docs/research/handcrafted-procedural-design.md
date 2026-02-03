# Handcrafted + Procedural Level Generation Patterns

> Research from Spelunky, Hades, Dead Cells, Binding of Isaac, and roguelite design principles.
> Last updated: 2026-02-02 (Session 26)

## Executive Summary

The most successful roguelites use a **hybrid approach**: handcrafted content within procedural structure. This creates the "designed feel" of authored levels while maintaining replayability. The key insight is that **constraints and rules produce better results than pure randomness**.

---

## 1. Spelunky's Room Template System

### The Algorithm

Spelunky divides each level into a 4x4 grid of 16 rooms. Each room is selected from a pool of pre-designed templates.

**Three-Phase Generation:**
1. **Layout Phase**: Generate a guaranteed path from entrance (top) to exit (bottom)
2. **Obstacle Phase**: Fill template chunks with randomized obstacles/traps
3. **Monster Phase**: Place enemies where space and conditions permit

### Room Types and Path Guarantee

The path-building algorithm uses three room types:
- **Type 1 (Sides)**: Allows left/right movement
- **Type 2 (Drop)**: Forces downward movement
- **Type 3 (Landing)**: Entry point from above

The algorithm ensures a **guaranteed playable path** by construction:
1. Start in random room at top row
2. Move left/right randomly, or drop down
3. Continue until reaching bottom row (exit)
4. Fill remaining rooms with random templates

### Template Structure

Each template is an 8x10 tile matrix (80 tiles total) with:
- Fixed elements (walls, platforms)
- Variable chunks (5x3 blocks) that get replaced with random obstacles

Example template notation:
```
0000000011
0060000L11
```
- `0`: Empty space
- `1`: Wall/brick
- `L`: Ladder
- `6`: Replaceable with random obstacle

### Playability Constraints

Spelunky imposes hard constraints during generation:
- **Gap widths** limited to player jump distance
- **Pipe heights** ensure player can pass through
- Traps placed only in designated 5x3 zones

**Key Insight**: Constraints are applied during generation, not post-validation.

---

## 2. Dead Cells' Hybrid Approach

### The 50/50 Philosophy

Motion Twin uses approximately 50% handcrafted content and 50% procedural:

**Fixed Elements (Handcrafted):**
- Overall world map layout
- Level interconnections
- Key/lock locations
- Biome transitions

**Procedural Elements:**
- Room arrangement within levels
- Enemy placement
- Loot distribution

### Tile-Based Room Design

Each "tile" (room chunk) is designed for a specific purpose:
- **Combat tiles**: Open spaces for fighting
- **Treasure tiles**: Hidden alcoves with rewards
- **Merchant tiles**: Safe zones with shop access
- **Traversal tiles**: Parkour-focused platforming

**Biome Identity**: Each biome has dedicated tiles. Prison tiles never appear in Sewers. This gives each area "strongly defined identity."

### The Concept Graph

Dead Cells uses a "concept graph" for each biome - a schematic layout that defines:
- Approximate level shape
- Required room connections
- Entrance/exit positions
- Key milestone locations

The procedural algorithm then fills this graph with compatible tiles.

### Enemy Distribution

Calculated based on combat tile density:
- Example ratio: 1 monster per 5 combat tiles
- Each monster type has placement constraints
- Prevents incompatible monster/tile combinations

---

## 3. Hades' Biome-Specific Design

### Design Philosophy Per Area

Supergiant designer Ed Gorinstein explained each biome teaches different skills:

| Biome | Design Principle | Player Lesson |
|-------|------------------|---------------|
| Tartarus | Medium rooms, completely walled | Learn Cast, Wall Slam damage |
| Asphodel | Archipelagos surrounded by lava | Mobility, enemy patterns |
| Elysium | Open arenas, aggressive enemies | Combat mastery |
| Styx | Tight corridors, poison | Precision, resource management |

### Exploration Without Randomness

Hades struggled with roguelike exploration feeling:
> "We tried hiding gold in random shiny walls and making huge rooms with scattered doors, but none of these fit with the game's hand-painted art or high-speed action pacing."

Their solution: **micro-discoveries** within handcrafted rooms:
- Gold urns (destructible)
- Troves (timed challenges)
- Wells (healing)
- Fishing points
- Chaos/Erebus gates (secret areas)

---

## 4. Binding of Isaac's Room Pool

### Scale of Handcrafting

The original Binding of Isaac had **200 handcrafted room layouts**. Rebirth expanded this to **thousands** of designs.

**Per-Floor Generation:**
1. Select 10-20 rooms from the pool
2. Add monsters, items, features procedurally
3. Include fixed rooms (boss room, treasure room)
4. Connect rooms in navigable layout

### Lesson for GoDig

The more handcrafted variety, the longer before players recognize patterns. But even 50-100 well-designed rooms can create significant replay value when combined procedurally.

---

## 5. Entry/Exit Point Design

### Door Matching System

From The Dungeoning's implementation:

Each room template defines **door descriptors**:
- Size (1-tile, 2-tile, etc.)
- Side (left, right, top, bottom)
- Connectivity type (required, optional)

**Generation Process:**
1. Start with root room at center
2. Add all doors to "available doors" list
3. For each available door:
   - Find room with matching door on opposite side
   - Validate no overlaps
   - Place room, add its doors to list
4. Continue until map is full or no valid rooms remain

### Ensuring Connectivity

**Validation before placement:**
- Door alignment matches
- No geometric overlaps
- Within map boundaries

**Post-generation connectivity:**
If areas are isolated, use "breaking through" logic to tunnel between nearby-but-disconnected rooms.

### GoDig Application

For vertical mining, door types could be:
- **Floor Opening**: Drop-down connections
- **Side Opening**: Horizontal connections
- **Ceiling Opening**: Climb-up connections (for later drill upgrade)

---

## 6. Playability Guarantees

### Construction-Time Constraints (Preferred)

Rather than generating then validating, impose limits during construction:

1. **Jump constraints**: Max gap width = player jump distance
2. **Fall constraints**: Max drop height = survivable fall
3. **Reach constraints**: Resources within player reach
4. **Path constraints**: At least one guaranteed route exists

### Post-Construction Validation (Backup)

If construction-time constraints aren't sufficient:
1. Run pathfinding from entrance to exit
2. If no path, add bridges/tunnels
3. If path too long/short, regenerate

### Monster Placement Rules

From Spelunky's Phase 3:
- Scan level for valid spawn locations
- Check: solid ground below, empty space around
- Apply probability limits (e.g., 20% chance for giant spider, once spawned set to 0%)
- Never place in impossible-to-reach locations

---

## 7. GoDig Implementation Recommendations

### Chunk Types for GoDig

Based on research, recommend these chunk types:

| Chunk Type | Purpose | Entry/Exit |
|------------|---------|------------|
| Open Chamber | Large dig space, ore veins | Top+Bottom or Sides |
| Tight Squeeze | Narrow passage, concentrated ore | Top+Bottom only |
| Drop Shaft | Vertical descent, platforms | Top+Bottom |
| Treasure Room | Hidden behind breakable wall | Side only |
| Rest Ledge | Safe platform, ladder-saving spot | Any |
| Ore Pocket | Dense ore concentration | Any |
| Hazard Zone | Crumbling blocks, lava | Top+Bottom |

### Assembly Rules

1. **Entrance**: Always at top center of level
2. **Exit**: At least 50% of level depth below entrance
3. **Connection validation**: Entry/exit points must align
4. **No dead ends**: Every chunk reachable from entrance
5. **Treasure rooms**: Require specific approach angle (side entry only)
6. **At least one safe path**: Exists from entrance to exit

### Template Ratio Recommendation

Based on Dead Cells' 50/50 approach:
- **40% Open/traversal chunks**: Easy movement
- **30% Challenge chunks**: Hazards, tight spaces
- **20% Reward chunks**: Ore pockets, treasures
- **10% Special chunks**: Rare discoveries, secrets

### Per-Layer Identity

Like Hades' biome design, each layer should have:
- Unique chunk pool (Layer 1 chunks don't appear in Layer 4)
- Different challenge focus (see Layer Identity implementation task)
- Distinct visual treatment

---

## Sources

- [Spelunky Level Generation (PCG Book Chapter)](https://antoniosliapis.com/articles/pcgbook_dungeons.php)
- [Dead Cells Level Design - Hybrid Approach (Deepnight)](https://deepnight.net/tutorial/the-level-design-of-dead-cells-a-hybrid-approach/)
- [Hades Level Design (Kotaku)](https://kotaku.com/hades-level-design-is-less-random-than-it-seems-1845254545)
- [Procedural Level Generation in The Dungeoning (Gamedeveloper)](https://www.gamedeveloper.com/design/procedural-level-generation-in-the-dungeoning)
- [Roguelike Level Design: Procedural Layouts (Cogmind)](https://www.gridsagegames.com/blog/2019/03/roguelike-level-design-addendum-procedural-layouts/)
- [How to Effectively Use Procedural Generation (Gamedeveloper)](https://www.gamedeveloper.com/design/how-to-effectively-use-procedural-generation-in-games)

---

## Key Takeaways for GoDig

1. **Hybrid is proven**: 50/50 handcrafted/procedural works in production
2. **Chunks need purpose**: Each room type serves a design goal
3. **Constraints during generation**: Don't generate then validate
4. **Entry/exit matching**: Door descriptors enable seamless connections
5. **Biome identity**: Each layer needs unique chunk pools
6. **Playability by construction**: Rules guarantee completable levels
