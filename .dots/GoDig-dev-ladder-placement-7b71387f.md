---
title: "implement: Ladder placement system"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T01:58:30.849009-06:00"
---

Grid-based ladder placement with validation and visual feedback. See ladder-traversal-items.md

## Description

Implement the system for placing ladders in dug-out tiles. Ladders are bought from shop, carried in inventory, and placed via tap on valid tiles.

## Context

Ladders are the primary traversal consumable. Players need strategic placement to create escape routes from deep tunnels.

## Affected Files

- `scenes/world/ladder.tscn` - Ladder scene with Area2D
- `scripts/world/ladder.gd` - Ladder behavior (climbing detection)
- `scripts/world/chunk.gd` or `world.gd` - Ladder storage and rendering
- `scripts/player/player.gd` - Placement action handler

## Implementation Notes

### Ladder Scene Structure
```
Ladder (Area2D)
├── Sprite2D - 16x16 ladder sprite
└── CollisionShape2D (RectangleShape2D) - Detection zone
```

### Placement Validation
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

    # No existing ladder
    if has_ladder_at(tile_pos):
        return false

    return true
```

### Placement Flow
1. Player selects ladder from quick-slot
2. Valid placement tiles highlight green
3. Player taps valid tile
4. Ladder item consumed from inventory
5. Ladder instantiated at tile position
6. Ladder registered in chunk data

### Visual Feedback
- Valid tiles: Green tint overlay
- Invalid tiles: Red tint (optional)
- Ghost preview: Semi-transparent ladder sprite at cursor

### Ladder Data for Chunk Storage
```gdscript
# In chunk data
var placed_ladders: Array[Vector2i] = []

func add_ladder(local_pos: Vector2i):
    placed_ladders.append(local_pos)
    var ladder = LadderScene.instantiate()
    ladder.position = local_to_world(local_pos)
    add_child(ladder)
```

## Verify

- [ ] Build succeeds
- [ ] Can only place in empty (dug) tiles
- [ ] Can only place in adjacent tiles (within 1 tile)
- [ ] Cannot place where ladder already exists
- [ ] Ladder item consumed from inventory on placement
- [ ] Ladder appears visually at correct position
- [ ] Ladder registered in chunk data for persistence
- [ ] Visual feedback shows valid/invalid tiles
