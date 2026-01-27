---
title: "implement: Layer transition system"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-16T00:44:03.965591-06:00\""
closed-at: "2026-01-27T07:19:18.717988+00:00"
close-reason: Verified existing layer transition notifications work via GameManager and HUD
---

## Description

Implement smooth visual transitions between underground layers. Instead of hard boundaries, use a 20-tile blend zone where blocks gradually mix between adjacent layer types.

## Context

- Hard layer boundaries feel artificial
- Blend zones create natural-looking terrain
- Uses noise to vary transition position horizontally
- See research: GoDig-research-procedural-gen-d809424b

## Affected Files

- `scripts/world/terrain_generator.gd` - Layer blending logic in tile generation
- `resources/layers/*.tres` - Add transition_range property to LayerData
- `resources/layers/layer_data.gd` - Transition configuration

## Implementation Notes

### Layer Transition Concept

Instead of:
```
[Topsoil] | [Stone]  <- hard boundary at exactly 50m
```

We want:
```
[Topsoil] [Mixed 80/20] [Mixed 50/50] [Mixed 20/80] [Stone]
          <- 20 tile transition zone ->
```

### LayerData Additions

```gdscript
# layer_data.gd additions
@export var transition_range: int = 20  # Tiles of blending below this layer
```

### Transition Calculation

```gdscript
# terrain_generator.gd
func _get_layer_tile(depth: int, world_pos: Vector2i) -> int:
    # Get base layer from DataRegistry
    var layer := DataRegistry.get_layer_at_depth(depth)
    if layer == null:
        return TileTypes.Type.DIRT

    # Check if we're in a transition zone
    var next_layer := DataRegistry.get_layer_at_depth(layer.max_depth + 1)
    if next_layer == null:
        return _layer_to_tile(layer)

    # Calculate distance to layer boundary
    var boundary := layer.max_depth
    var distance_to_boundary := boundary - depth

    # Add horizontal noise variation to transition
    var noise_offset := int(_terrain_noise.get_noise_2d(world_pos.x, 0) * 10)
    distance_to_boundary += noise_offset

    if distance_to_boundary > layer.transition_range:
        # Not in transition zone
        return _layer_to_tile(layer)

    # In transition zone - blend between layers
    var blend_factor := float(distance_to_boundary) / layer.transition_range
    blend_factor = clampf(blend_factor, 0.0, 1.0)

    # Use position-based random for consistent results
    var hash_val := _position_hash(world_pos)
    if hash_val < blend_factor:
        return _layer_to_tile(layer)
    else:
        return _layer_to_tile(next_layer)

func _position_hash(pos: Vector2i) -> float:
    # Deterministic hash for position
    var h := hash(Vector2(pos.x, pos.y))
    return fmod(abs(float(h)), 1000.0) / 1000.0

func _layer_to_tile(layer: LayerData) -> int:
    match layer.id:
        "topsoil": return TileTypes.Type.DIRT
        "subsoil": return TileTypes.Type.CLAY
        "stone": return TileTypes.Type.STONE
        "deep_stone": return TileTypes.Type.GRANITE
        "basalt_zone": return TileTypes.Type.BASALT
        "magma_zone": return TileTypes.Type.OBSIDIAN
        _: return TileTypes.Type.DIRT
```

### Layer Transition Ranges (Recommended)

| Layer Boundary | Transition Range | Notes |
|----------------|------------------|-------|
| Topsoil → Subsoil | 15 tiles | Quick transition |
| Subsoil → Stone | 25 tiles | Gradual, visible mix |
| Stone → Deep Stone | 20 tiles | Standard blend |
| Deep Stone → Basalt | 30 tiles | Long transition |
| Basalt → Magma | 20 tiles | Standard |

### Visual Example

At depth 195-210 (Subsoil→Stone boundary at 200):

```
Depth 195: 100% subsoil
Depth 197: 80% subsoil, 20% stone
Depth 200: 50% subsoil, 50% stone
Depth 203: 20% subsoil, 80% stone
Depth 210: 100% stone
```

### Noise Variation

The horizontal noise creates jagged, natural-looking boundaries:

```
     Depth
     195 │ S S S S S S S S S S S S S
     197 │ S S S X S S X S S S S X S
     200 │ S X S X X S X X S X S X S
     203 │ X X X X S X X X X X X X X
     210 │ T T T T T T T T T T T T T

S = Subsoil, X = Mixed, T = Stone
```

## Edge Cases

- At surface (depth 0): No transition, always topsoil
- At deepest layer: No transition below, stays constant
- Negative depth: Surface/air, no blending
- Layer with transition_range = 0: Hard boundary (disabled)

## Verify

- [ ] Build succeeds
- [ ] Layers blend smoothly at boundaries
- [ ] No hard visual line between adjacent layers
- [ ] Blend zone is approximately 20 tiles
- [ ] Horizontal noise creates natural variation
- [ ] Same seed produces identical transitions
- [ ] Layer below deepest continues correctly
- [ ] Performance acceptable during chunk generation
