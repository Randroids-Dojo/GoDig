---
title: "implement: Layer selection by depth"
status: open
priority: 0
issue-type: task
created-at: "2026-01-16T00:44:09.736706-06:00"
---

## Description

Implement `get_layer_at_depth(y)` in DataRegistry to return the appropriate LayerData based on depth. Handle transition zones between layers with gradual blending for visual interest.

## Context

LayerData resources define underground layers (topsoil, subsoil, stone, deep_stone). Currently 4 layers exist in `resources/layers/*.tres`. DataRegistry already has `get_layer_at_depth()` but transition zone handling needs refinement.

Existing layers:
- topsoil (0-50m): Easy digging, coal/copper
- subsoil (50-200m): Medium difficulty
- stone (200-500m): Hard digging, caves begin
- deep_stone (500m+): Very hard, requires upgrades

## Affected Files

- `scripts/autoload/data_registry.gd` - Enhance `get_layer_at_depth()` and `get_block_color()`
- `resources/layers/*.tres` - Verify layer definitions have proper boundaries

## Implementation Notes

### Enhanced Layer Selection

```gdscript
## Get the layer at a specific depth (in grid rows from surface)
func get_layer_at_depth(depth: int) -> LayerData:
    # Clamp negative depths to 0
    depth = maxi(depth, 0)

    for layer in layers:
        if depth >= layer.min_depth and depth < layer.max_depth:
            return layer

    # Return deepest layer for anything beyond max defined depth
    if layers.size() > 0:
        return layers[layers.size() - 1]

    return null
```

### Transition Zone Detection

```gdscript
## Check if depth is in transition zone between layers
func is_in_transition(depth: int) -> Dictionary:
    const TRANSITION_RANGE := 10  # Tiles of blending

    for i in range(layers.size() - 1):
        var current_layer := layers[i]
        var next_layer := layers[i + 1]
        var boundary := current_layer.max_depth

        # Check if in transition zone (boundary - range to boundary + range)
        if depth >= boundary - TRANSITION_RANGE and depth < boundary + TRANSITION_RANGE:
            var blend := (depth - (boundary - TRANSITION_RANGE)) / float(TRANSITION_RANGE * 2)
            return {
                "in_transition": true,
                "from_layer": current_layer,
                "to_layer": next_layer,
                "blend": clampf(blend, 0.0, 1.0)
            }

    return {"in_transition": false}
```

### Block Color with Transition Blending

```gdscript
## Get the color for a block at a grid position
func get_block_color(grid_pos: Vector2i) -> Color:
    var depth := grid_pos.y - GameManager.SURFACE_ROW
    depth = maxi(depth, 0)

    var transition := is_in_transition(depth)

    if transition.in_transition:
        # Blend colors between layers
        var from_color: Color = transition.from_layer.color_primary
        var to_color: Color = transition.to_layer.color_primary
        var base_color := from_color.lerp(to_color, transition.blend)

        # Add positional variation
        var seed_value := grid_pos.x * 1000 + grid_pos.y
        var rng := RandomNumberGenerator.new()
        rng.seed = seed_value

        if rng.randf() < 0.2:  # 20% accent color
            var accent := transition.from_layer.color_accent.lerp(
                transition.to_layer.color_accent, transition.blend)
            return base_color.lerp(accent, 0.3)

        return base_color

    # Normal layer color
    var layer := get_layer_at_depth(depth)
    if layer == null:
        return Color.BROWN

    # Deterministic variation within layer
    var seed_value := grid_pos.x * 1000 + grid_pos.y
    var rng := RandomNumberGenerator.new()
    rng.seed = seed_value
    if rng.randf() < 0.15:  # 15% accent color
        return layer.color_accent

    return layer.color_primary
```

### Layer Name Display

```gdscript
## Get display name for the current depth (for HUD/milestones)
func get_layer_name_at_depth(depth: int) -> String:
    var layer := get_layer_at_depth(depth)
    if layer:
        return layer.display_name
    return "Unknown"
```

## Edge Cases

- Depth < 0: Clamp to 0, return topsoil
- Depth > max defined: Return deepest layer (infinite scaling)
- Exact boundary: Belongs to lower layer (max_depth is exclusive)
- Empty layers array: Return null, handle gracefully

## Verify

- [ ] Build succeeds with no errors
- [ ] `get_layer_at_depth(0)` returns topsoil
- [ ] `get_layer_at_depth(100)` returns subsoil
- [ ] `get_layer_at_depth(300)` returns stone
- [ ] `get_layer_at_depth(999999)` returns deep_stone (deepest)
- [ ] Transition zones produce blended colors
- [ ] Block colors are deterministic (same position = same color)
- [ ] `get_layer_name_at_depth()` returns correct display names
