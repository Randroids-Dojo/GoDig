---
title: "implement: Fall damage calculation"
status: open
priority: 1
issue-type: task
created-at: "2026-01-19T00:52:30.847520-06:00"
after:
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

**IMPORTANT**: This game uses 128x128 pixel blocks (BLOCK_SIZE), not 16x16 tiles. The existing player.gd already uses grid-based movement with BLOCK_SIZE = 128.

```gdscript
# player.gd (add to existing constants section)
const FALL_DAMAGE_THRESHOLD: int = 3  # blocks
const DAMAGE_PER_BLOCK: float = 10.0
const MAX_FALL_DAMAGE: float = 100.0

var fall_start_y: float = 0.0
var is_tracking_fall: bool = false

# Integrate into existing _start_falling() and _check_landing() methods
func _start_falling() -> void:
    current_state = State.FALLING
    velocity = Vector2.ZERO
    # Start tracking fall from current position
    if not is_tracking_fall:
        is_tracking_fall = true
        fall_start_y = position.y

# Modify existing _land_on_grid() to include fall damage
func _land_on_grid(landing_grid: Vector2i) -> void:
    # Calculate and apply fall damage before snapping
    if is_tracking_fall:
        is_tracking_fall = false
        var fall_distance_px = position.y - fall_start_y
        var fall_blocks = int(fall_distance_px / BLOCK_SIZE)
        apply_fall_damage(fall_blocks)

    # Existing landing logic
    grid_position = landing_grid
    position = _grid_to_world(grid_position)
    velocity = Vector2.ZERO
    current_state = State.IDLE
    _update_depth()

func apply_fall_damage(fall_blocks: int):
    if fall_blocks <= FALL_DAMAGE_THRESHOLD:
        return

    var excess_blocks = fall_blocks - FALL_DAMAGE_THRESHOLD
    var damage = excess_blocks * DAMAGE_PER_BLOCK

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
| Blocks Fallen | Damage (no boots) |
|---------------|-------------------|
| 0-3 | 0 |
| 4 | 10 |
| 5 | 20 |
| 6 | 30 |
| 7 | 40 |
| 8 | 50 |
| 10 | 70 |
| 13+ | 100 (lethal) |

Note: Each block is 128x128 pixels, so falling 4 blocks = 512 pixels.

## Edge Cases

- Wall-jumping resets fall tracking (player touches wall)
- Climbing ladder resets fall tracking
- Don't track horizontal movement as fall

## Verify

- [ ] Build succeeds
- [ ] Falling 3 blocks or less does no damage
- [ ] Falling 4 blocks does 10 damage
- [ ] Falling 10 blocks does 70 damage
- [ ] Falling 13+ blocks is lethal (100 damage)
- [ ] Wall-sliding/jumping resets fall tracking (set is_tracking_fall = false in _start_wall_slide)
- [ ] Ladder climbing resets fall tracking (future: when ladder system implemented)
- [ ] Visual/audio feedback on fall damage (player flash red)
