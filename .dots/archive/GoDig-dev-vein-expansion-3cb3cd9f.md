---
title: "implement: Vein expansion (random walk)"
status: closed
priority: 1
issue-type: task
created-at: "\"2026-01-16T00:38:20.884878-06:00\""
closed-at: "2026-01-24T21:30:15.379117+00:00"
close-reason: Implemented random walk vein expansion in dirt_grid.gd using ore vein_size_min/max
---

generate_vein() creates 1-8 connected ore blocks. Natural branching shapes. Adds visual interest.

## Description

Implement vein-based ore generation that creates clusters of connected ore blocks instead of individual random spawns. Uses random walk algorithm to expand from a seed point, creating natural-looking ore veins.

## Context

- Current ore spawning checks each block independently
- OreData has vein_size_min/vein_size_max fields (unused)
- Real mining games have veins, not scattered individual ores
- Veins make mining more satisfying (hit one ore, find more nearby)

## Affected Files

- `scripts/world/dirt_grid.gd` - Modify `_determine_ore_spawn()` to use vein expansion
- `scripts/world/ore_generator.gd` - NEW (optional): Dedicated ore generation class

## Implementation Notes

### Algorithm Overview

1. When noise threshold triggers ore spawn at position P
2. Determine vein size from OreData.vein_size_min/max
3. Random walk from P to create connected positions
4. Mark all positions as this ore type in `_ore_map`

### Random Walk Vein Generation

```gdscript
func _generate_vein(start_pos: Vector2i, ore: OreData) -> Array[Vector2i]:
    var vein_positions: Array[Vector2i] = [start_pos]
    var target_size := ore.get_random_vein_size(_rng)

    var current := start_pos
    var attempts := 0
    var max_attempts := target_size * 4  # Prevent infinite loops

    while vein_positions.size() < target_size and attempts < max_attempts:
        attempts += 1

        # Pick random adjacent direction (4-way)
        var directions := [
            Vector2i(0, 1),   # down
            Vector2i(0, -1),  # up
            Vector2i(1, 0),   # right
            Vector2i(-1, 0),  # left
        ]
        var dir: Vector2i = directions[_rng.randi() % 4]
        var next := current + dir

        # Validate position
        if not _is_valid_vein_position(next, start_pos, ore):
            continue

        # Skip if already in vein
        if next in vein_positions:
            # Still move there to allow branching
            current = next
            continue

        # Add to vein
        vein_positions.append(next)
        current = next

    return vein_positions


func _is_valid_vein_position(pos: Vector2i, origin: Vector2i, ore: OreData) -> bool:
    # Check bounds
    if pos.x < 0 or pos.x >= GameManager.GRID_WIDTH:
        return false

    # Check depth requirements
    var depth := pos.y - GameManager.SURFACE_ROW
    if not ore.can_spawn_at_depth(depth):
        return false

    # Don't expand too far from origin (optional constraint)
    var max_spread := 5
    if abs(pos.x - origin.x) > max_spread or abs(pos.y - origin.y) > max_spread:
        return false

    # Don't overwrite existing ore
    if _ore_map.has(pos):
        return false

    return true
```

### Integration with Existing Code

Modify `_determine_ore_spawn()`:

```gdscript
func _determine_ore_spawn(pos: Vector2i) -> void:
    # Skip if this position already has ore (from a previous vein)
    if _ore_map.has(pos):
        return

    var depth := pos.y - GameManager.SURFACE_ROW
    if depth < 0:
        return

    var available_ores := DataRegistry.get_ores_at_depth(depth)
    if available_ores.is_empty():
        return

    # Seed RNG for this position
    var seed_value := pos.x * 10000 + pos.y
    _rng.seed = seed_value

    # Check each ore (rarest first)
    available_ores.sort_custom(func(a, b): return a.spawn_threshold > b.spawn_threshold)

    for ore in available_ores:
        var noise_val := _generate_ore_noise(pos, ore.noise_frequency)
        if noise_val > ore.spawn_threshold:
            # Generate vein starting from this position
            var vein := _generate_vein(pos, ore)
            for vein_pos in vein:
                _ore_map[vein_pos] = ore.id
                _apply_ore_visual(vein_pos, ore)
            return
```

### Vein Shapes

Common patterns to encourage:
- Linear: Mostly horizontal or vertical spread
- Blob: Compact cluster
- Branch: Y or T shapes

Can weight direction choices to favor certain shapes:
```gdscript
# Favor vertical veins (more realistic geology)
var directions := [
    Vector2i(0, 1),   # down  (40% chance)
    Vector2i(0, 1),   # down
    Vector2i(0, -1),  # up    (20% chance)
    Vector2i(1, 0),   # right (20% chance)
    Vector2i(-1, 0),  # left  (20% chance)
]
```

### Performance Considerations

- Vein generation happens once per row during `_generate_row()`
- Keep track of processed rows to avoid re-generating veins
- Existing blocks that become part of a vein need visual update

## Verify

- [ ] Ore spawns form connected clusters instead of isolated blocks
- [ ] Vein sizes respect OreData min/max settings
- [ ] Veins don't cross world boundaries
- [ ] Veins don't overwrite other ore types
- [ ] Visual consistency - all blocks in vein have same ore color
- [ ] Performance acceptable (no lag when generating many veins)
- [ ] Deterministic - same seed produces same veins
