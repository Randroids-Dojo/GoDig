---
title: "implement: Fall damage calculation"
status: open
priority: 1
issue-type: task
created-at: "2026-01-19T00:52:30.847520-06:00"
blocks:
  - GoDig-implement-player-hp-4f3e9af1
---

## Description

Track player fall distance and apply damage when landing based on height fallen.

## Context

Fall damage is the core hazard that creates risk when going deep. Players must manage their descent carefully or use tools like ladders.

## Affected Files

- `scripts/player/player.gd` - Add fall tracking, damage on land
- `resources/blocks/` - Add softness property to block data

## Implementation Notes

### Fall Tracking
```gdscript
# player.gd
const TILE_SIZE: int = 16
const FALL_DAMAGE_THRESHOLD: int = 3  # tiles
const DAMAGE_PER_TILE: float = 10.0
const MAX_FALL_DAMAGE: float = 100.0

var fall_start_y: float = 0.0
var is_tracking_fall: bool = false

func _physics_process(delta):
    # Start tracking when leaving ground and moving down
    if not is_on_floor() and velocity.y > 0:
        if not is_tracking_fall:
            is_tracking_fall = true
            fall_start_y = position.y

    # Calculate damage on landing
    elif is_on_floor() and is_tracking_fall:
        is_tracking_fall = false
        var fall_distance_px = position.y - fall_start_y
        var fall_tiles = int(fall_distance_px / TILE_SIZE)
        apply_fall_damage(fall_tiles)

func apply_fall_damage(fall_tiles: int):
    if fall_tiles <= FALL_DAMAGE_THRESHOLD:
        return

    var excess_tiles = fall_tiles - FALL_DAMAGE_THRESHOLD
    var damage = excess_tiles * DAMAGE_PER_TILE

    # Apply modifiers (future: boots, surface)
    # damage *= (1.0 - boots_reduction)
    # damage *= surface_hardness_multiplier

    damage = min(damage, MAX_FALL_DAMAGE)
    take_damage(int(damage), 'fall')
```

### Surface Softness (v1.0 Enhancement)
```gdscript
func get_surface_hardness_multiplier() -> float:
    var landing_tile = get_tile_at_feet()
    match landing_tile.category:
        'dirt': return 0.8
        'stone': return 1.0
        'metal': return 1.2
        'water': return 0.3
        _: return 1.0
```

### Fall Damage Table
| Tiles Fallen | Damage (no boots) |
|--------------|-------------------|
| 0-3 | 0 |
| 4 | 10 |
| 5 | 20 |
| 6 | 30 |
| 7 | 40 |
| 8 | 50 |
| 10 | 70 |
| 13+ | 100 (lethal) |

## Edge Cases

- Wall-jumping resets fall tracking (player touches wall)
- Climbing ladder resets fall tracking
- Don't track horizontal movement as fall

## Verify

- [ ] Build succeeds
- [ ] Falling 3 tiles or less does no damage
- [ ] Falling 4 tiles does 10 damage
- [ ] Falling 10 tiles does 70 damage
- [ ] Falling 13+ tiles is lethal (100 damage)
- [ ] Wall-sliding/jumping resets fall tracking
- [ ] Ladder climbing resets fall tracking
- [ ] Visual/audio feedback on fall damage
