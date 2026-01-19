---
title: "research: Ladder and traversal system"
status: closed
priority: 0
issue-type: task
created-at: "\"\\\"2026-01-18T23:39:36.724226-06:00\\\"\""
closed-at: "2026-01-19T01:12:03.814300-06:00"
close-reason: Documented ladder system (buy from shop, tap to place, permanent), climbing state machine, other traversal items (rope, teleport, grappling hook, elevator). Enhanced existing implementation dots with detailed specs.
---

How do ladders work to escape tunnels? Questions: Are ladders bought from shop or crafted? How are they placed? (tap to place, auto-place?) How many does player carry? Can they be picked back up? Are there other traversal items? (rope, teleport scroll) How does climbing state work? What about the mine entrance on surface?

---

## Research Findings

### Traversal Hierarchy

The game provides multiple traversal options that unlock progressively:

| Method | Type | Cost | Unlock | Purpose |
|--------|------|------|--------|---------|
| Wall-jump | Built-in | Free | Start | Core mechanic, always available |
| Ladders | Consumable | 10 coins | Start | Strategic placement, bulk use |
| Ropes | Consumable | 50 coins | 100m | Fast descent, convenience |
| Teleport Scroll | Consumable | 500 coins | Start | Emergency escape |
| Grappling Hook | Permanent | 25,000 coins | 500m | Reusable mobility |
| Elevator | Building | 50,000 coins | 500m | Fast travel system |
| Drill | Tool | Special | 500m | Dig upward ability |

---

## Ladder System (Core Focus)

### Acquisition
- **Bought from shop** (Supply Store) - NOT crafted
- Sold in stacks for convenience
- Cannot be crafted (simple economy)

### Placement Mechanics
- **Tap to place**: Player taps on adjacent empty tile
- **One ladder per tile**: Single placement model
- **Permanent once placed**: Cannot pick up (simplicity)
- **Quick-slot HUD**: Shows count, one-tap access

### Placement Rules
```gdscript
func can_place_ladder(tile_pos: Vector2i) -> bool:
    # Tile must be empty (dug out)
    if not is_tile_empty(tile_pos):
        return false

    # Player must be adjacent (within 1 tile)
    var player_tile = get_player_tile()
    if (tile_pos - player_tile).length() > 1.5:
        return false

    # No hazards (lava, water)
    if has_hazard_at(tile_pos):
        return false

    return true
```

### Visual Feedback
- **Valid tiles**: Green highlight when ladder selected
- **Invalid tiles**: Red highlight
- **Ghost preview**: Semi-transparent ladder sprite

### Ladder Data
| Property | Value |
|----------|-------|
| Stack Size | 50 |
| Buy Price | 10 coins |
| Sell Price | 5 coins |
| Placement | Adjacent empty tiles only |
| Persistence | Saved with chunk data |

---

## Player Climbing State

### State Machine Addition
```gdscript
enum State { IDLE, MOVING, MINING, FALLING, WALL_SLIDING, WALL_JUMPING, CLIMBING }
```

### Climbing Behavior
- **Enter**: Player overlaps ladder Area2D
- **Movement**: Up/down at climb_speed (no gravity)
- **Exit**: Move horizontally off ladder, or reach top/bottom
- **No dig while climbing**: Must exit state first

### Climbing Code Pattern
```gdscript
var is_climbing: bool = false
var current_ladder: Node2D = null

func enter_climbing_state(ladder: Node2D):
    is_climbing = true
    current_ladder = ladder
    velocity = Vector2.ZERO  # Stop falling
    state = State.CLIMBING

func _handle_climbing(delta):
    var input_y = Input.get_axis("move_up", "move_down")
    velocity.y = input_y * climb_speed
    velocity.x = 0

    # Check for horizontal exit
    var input_x = Input.get_axis("move_left", "move_right")
    if abs(input_x) > 0.5:
        exit_climbing_state()
        velocity.x = input_x * move_speed

func exit_climbing_state():
    is_climbing = false
    current_ladder = null
    state = State.IDLE
```

---

## Other Traversal Items

### Rope (v1.0)
- Extends downward from anchor point
- Max length: 10 tiles
- Good for quick descents into unknown
- Stack size: 20

### Teleport Scroll (v1.0)
- Emergency return to surface
- Keeps inventory (merciful design)
- Stack size: 5
- Already covered in Emergency Rescue feature

### Grappling Hook (v1.0)
- Permanent tool
- Aim and fire mechanic
- 15 tile range, 3 second cooldown
- Unlock at 500m depth

### Elevator (v1.1)
- Building on surface
- Extends downward with resources
- Fast travel between connected depths
- Major investment: 50,000 coins

---

## Mine Entrance on Surface

### Design Decision
- **Visual marker** for where underground begins
- Player walks into mine entrance to descend
- Can be a building slot or fixed location
- Serves as "spawn point" on surface

### Surface to Underground Transition
```
Surface (y <= 0)
    |
    v
Mine Entrance (building or fixed point)
    |
    v
Underground (y > 0, chunks start generating)
```

### Implementation Notes
- Surface is y <= 0, underground is y > 0
- Mine entrance could be visual-only (player just walks down)
- Or could be a building that unlocks (initial barrier)
- Recommendation: Start with simple "walk into hole" for MVP

---

## Mobile Controls Integration

### Quick-Slot HUD
```
┌─────────────────────────────────────┐
│  [Coins] [Depth]      [Inv] [Menu]  │
│                                     │
│              GAME VIEW              │
│                                     │
│  ┌───┐                       ┌───┐  │
│  │JOY│                       │JMP│  │
│  └───┘                       └───┘  │
│        [LADDER: 25]                 │
└─────────────────────────────────────┘
```

- Quick-slot shows ladder count
- Tap quick-slot to select for placement
- Tap valid tile to place
- Auto-deselect after placing (or hold to place multiple)

---

## Questions Resolved

- [x] Are ladders bought or crafted? -> **Bought from Supply Store**
- [x] How placed? -> **Tap adjacent empty tile while ladder selected**
- [x] How many carried? -> **Stack of 50 max**
- [x] Can pick back up? -> **No, permanent once placed**
- [x] Other traversal items? -> **Rope, Teleport Scroll, Grappling Hook, Elevator**
- [x] Climbing state? -> **State machine addition, up/down movement, no gravity**
- [x] Mine entrance? -> **Visual marker or building, simple walk-down for MVP**

---

## Implementation Tasks Created

1. `implement: Ladder item and placement system` - Core ladder mechanics
2. `implement: Player climbing state` - State machine, up/down movement
3. `implement: Ladder quick-slot HUD` - Count display, selection, placement flow
4. `implement: Ladder persistence in chunks` - Save/load with world data
