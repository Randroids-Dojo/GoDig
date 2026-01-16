# Ladder & Traversal Items Research

## Overview
Traversal items are essential for returning to the surface. They create resource management gameplay and strategic decisions.

## Traversal Item Types

### 1. Ladders

#### Design
- Most common traversal item
- Player-placed in dug blocks
- Permanent once placed
- Climbable in both directions

#### Mechanics
```gdscript
# ladder.gd
extends Area2D

func _ready():
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body):
    if body.name == "Player":
        body.enter_climbing_state(self)

func _on_body_exited(body):
    if body.name == "Player":
        body.exit_climbing_state()
```

#### Placement Rules
- Can only place in empty (dug) tiles
- One ladder per tile
- Cannot place in water/lava
- Player must be adjacent to tile

#### Ladder Data
| Property | Value |
|----------|-------|
| Stack Size | 50 |
| Buy Price | 10 coins |
| Sell Price | 5 coins |
| Unlock | Start (Supply Store) |

### 2. Ropes

#### Design
- Faster than ladders
- More expensive
- Can extend downward from anchor point
- Good for quick descents

#### Mechanics
```gdscript
# rope.gd
extends Node2D

@export var max_length: int = 10  # tiles

func deploy(anchor_pos: Vector2i, direction: Vector2i):
    position = tile_to_world(anchor_pos)

    # Extend rope until hitting solid or max length
    var current_length = 0
    while current_length < max_length:
        var check_pos = anchor_pos + direction * current_length
        if world.is_solid(check_pos):
            break
        add_rope_segment(current_length)
        current_length += 1
```

#### Rope Data
| Property | Value |
|----------|-------|
| Stack Size | 20 |
| Buy Price | 50 coins |
| Sell Price | 25 coins |
| Max Length | 10 tiles |
| Unlock | Depth 100m |

### 3. Grappling Hook (Permanent Tool)

#### Design
- Mid-game unlock
- Reusable (not consumable)
- Aim and fire mechanic
- Cooldown between uses

#### Mechanics
```gdscript
# grappling_hook.gd
func fire(direction: Vector2):
    if cooldown_remaining > 0:
        return

    # Raycast to find anchor point
    var result = raycast_for_anchor(direction)
    if result:
        pull_player_to(result.position)
        cooldown_remaining = cooldown_duration
```

#### Grappling Hook Data
| Property | Value |
|----------|-------|
| Max Range | 15 tiles |
| Cooldown | 3 seconds |
| Buy Price | 25,000 coins |
| Unlock | Depth 500m (Gadget Shop) |

### 4. Teleport Scroll (Emergency)

#### Design
- Expensive single-use item
- Instant return to surface
- Emergency escape option
- Prevents frustrating "stuck" situations

#### Mechanics
```gdscript
# teleport_scroll.gd
func use():
    if inventory.remove_item("teleport_scroll", 1):
        # Fancy teleport effect
        play_teleport_vfx()
        await get_tree().create_timer(0.5).timeout

        # Move player to surface
        player.position = surface_spawn_point

        # Optional: keep inventory (merciful)
        # Or lose inventory (punishing)
```

#### Teleport Scroll Data
| Property | Value |
|----------|-------|
| Stack Size | 5 |
| Buy Price | 500 coins |
| Sell Price | 250 coins |
| Unlock | Start (Supply Store) |

### 5. Elevator (Building)

#### Design
- Late-game permanent solution
- Connects surface to deep points
- Requires building shaft down
- Major quality-of-life upgrade

#### Mechanics
- Starts at surface
- Player extends downward by spending resources
- Can call elevator from any connected depth
- Fast travel system

#### Elevator Data
| Property | Value |
|----------|-------|
| Build Cost | 50,000 coins |
| Extend Cost | 100 coins per 10m |
| Travel Speed | Instant (loading screen) |
| Unlock | Depth 500m |

---

## Placement System

### Grid-Based Placement

#### UI Flow
```
1. Select item from inventory (or quick-slot)
2. Valid placement tiles highlight
3. Tap tile to place
4. Consume item from inventory
5. Item appears in world
```

#### Placement Validation
```gdscript
func can_place_ladder(tile_pos: Vector2i) -> bool:
    # Must be empty (dug out)
    if world.get_tile(tile_pos) != TILE_EMPTY:
        return false

    # Must be adjacent to player
    var player_tile = world.get_tile_at(player.position)
    if (tile_pos - player_tile).length() > 1.5:
        return false

    # Can't place in hazards
    if world.has_hazard(tile_pos):
        return false

    return true
```

### Visual Feedback
- Valid tiles: Green highlight
- Invalid tiles: Red highlight
- Placement preview: Ghost sprite

---

## Persistence

### Saving Traversal Items
```gdscript
# Ladders stored per-chunk
var chunk_data = {
    "tiles": [...],
    "ladders": [
        {"x": 5, "y": 12},
        {"x": 5, "y": 13},
        # ...
    ],
    "ropes": [...]
}
```

### Loading
- Reinstantiate traversal items when chunk loads
- Remove from memory when chunk unloads
- Persist across sessions

---

## Economy Balance

### Early Game (0-200m)
- Wall-jump is free (built-in skill)
- Ladders cheap and plentiful
- Encourage ladder use to learn mechanic

### Mid Game (200-500m)
- Ladders still useful
- Ropes offer convenience
- Grappling hook as goal

### Late Game (500m+)
- Elevator solves deep travel
- Teleport scrolls for emergencies
- Drill allows upward digging

### Price Progression
| Item | Price | Use Case |
|------|-------|----------|
| Ladder | 10 | Common, bulk purchase |
| Rope | 50 | Convenience |
| Teleport Scroll | 500 | Emergency |
| Grappling Hook | 25,000 | Permanent tool |
| Elevator | 50,000 | Late-game investment |

---

## Mobile Controls

### Quick Placement
- Quick-slot for ladders (always accessible)
- One-tap placement on highlighted tile
- Auto-select next ladder after placing

### Control Scheme
```
┌─────────────────────────────────────┐
│                                     │
│              GAME VIEW              │
│         [Ladder highlights]         │
│                                     │
│  ┌───┐                       ┌───┐  │
│  │JOY│                       │DIG│  │
│  └───┘                       └───┘  │
│        [LADDER: 25]                 │
└─────────────────────────────────────┘
```

---

## Visual Design

### Ladder Sprite
- Simple wooden rungs
- 16x16 per segment
- Connects visually when stacked

### Rope Sprite
- Braided texture
- Slightly animated (sway)
- Clear grab point indicators

### Grappling Hook
- Aim indicator when equipped
- Hook flight animation
- Pull line visual

---

## Questions Resolved
- [x] Ladder placement: single tiles
- [x] Rope mechanics: extend from anchor
- [x] Grappling hook: permanent tool with cooldown
- [x] Teleport scroll: emergency use
- [x] Elevator: late-game building
- [x] Mobile controls: quick-slot + tap placement
