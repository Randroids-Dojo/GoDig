---
title: "implement: Infinite depth scaling"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T02:01:04.682096-06:00"
after:
  - GoDig-dev-define-7-d4679cf5
  - GoDig-dev-layer-depth-89c9d8ac
---

## Description

Implement infinite depth scaling so the game has no hard depth cap. As players dig deeper, blocks become harder, ores become rarer and more valuable, and the world continues generating endlessly.

## Context

The game is designed for "endless" depth. Rather than hitting a wall, the challenge and rewards should scale smoothly. This requires careful balance so ultra-deep mining remains rewarding but not trivial.

## Affected Files

- `scripts/world/dirt_grid.gd` - Modify hardness calculation for deep blocks
- `scripts/autoload/data_registry.gd` - Add depth multiplier functions
- `resources/layers/*.tres` - Ensure final layer has no max_depth
- `scripts/world/terrain_generator.gd` (if using) - Scale ore thresholds

## Implementation Notes

### Block Hardness Scaling

After the deepest defined layer (e.g., Obsidian at 2000m+), hardness continues to scale:

```gdscript
# data_registry.gd or dirt_grid.gd
func get_block_hardness_at_depth(depth: int) -> float:
    var layer := DataRegistry.get_layer_at_depth(depth)
    var base_hardness := layer.hardness if layer else 50.0

    # After layer definitions end, add depth-based scaling
    var deepest_layer_depth := 2000  # Obsidian starts
    if depth > deepest_layer_depth:
        var extra_depth := depth - deepest_layer_depth
        # +10% hardness per 500m beyond deepest layer
        var multiplier := 1.0 + (extra_depth / 500.0) * 0.1
        return base_hardness * multiplier

    return base_hardness
```

### Ore Value Scaling

Deep ores should be worth more to reward the effort:

```gdscript
func get_ore_sell_value(ore: OreData, depth: int) -> int:
    var base_value := ore.sell_value

    # +5% value per 100m depth (after ore's min_depth)
    var depth_bonus := max(0, depth - ore.min_depth)
    var multiplier := 1.0 + (depth_bonus / 100.0) * 0.05

    # Cap at 3x base value
    multiplier = min(multiplier, 3.0)

    return int(base_value * multiplier)
```

### Ore Rarity Deep Scaling

Even "common" ores become rarer at extreme depths:

```gdscript
func get_ore_spawn_threshold(ore: OreData, depth: int) -> float:
    var base_threshold := ore.spawn_threshold

    # Above 1000m: use base threshold
    if depth < 1000:
        return base_threshold

    # Below 1000m: ores become slightly rarer
    # This ensures deep runs are about quality, not quantity
    var depth_penalty := (depth - 1000) / 5000.0 * 0.05  # +5% threshold per 5000m
    return min(base_threshold + depth_penalty, 0.99)
```

### Layer Repetition for Visual Variety

After all defined layers, cycle through them with tints:

```gdscript
const LAYER_CYCLE := ["obsidian", "void"]  # Post-2000m layers
const CYCLE_DEPTH := 500  # Each repeats every 500m

func get_deep_layer_visual(depth: int) -> Dictionary:
    if depth < 2000:
        return {}  # Use normal layer

    var cycle_index := ((depth - 2000) / CYCLE_DEPTH) % LAYER_CYCLE.size()
    var layer_id := LAYER_CYCLE[cycle_index]
    var tint_factor := 1.0 - ((depth - 2000) % CYCLE_DEPTH) / CYCLE_DEPTH * 0.2

    return {
        "layer_id": layer_id,
        "tint": Color(tint_factor, tint_factor, tint_factor)
    }
```

### Integer Overflow Prevention

At extreme depths (y > 1,000,000), ensure no overflow:

```gdscript
# Use int64 or clamp depth values
const MAX_PRACTICAL_DEPTH := 100000  # 100km - more than anyone will reach

func get_safe_depth(raw_depth: int) -> int:
    return clampi(raw_depth, 0, MAX_PRACTICAL_DEPTH)
```

### Achievement/Milestone System

Track depth milestones for achievements:

```gdscript
const INFINITE_MILESTONES := [1000, 2000, 5000, 10000, 25000, 50000, 100000]

func check_depth_milestone(depth: int) -> void:
    for milestone in INFINITE_MILESTONES:
        if depth >= milestone and not _reached_milestones.has(milestone):
            _reached_milestones.append(milestone)
            emit_signal("milestone_reached", milestone)
```

## Edge Cases

- Depth int overflow: Use int64 or clamp at practical max
- Zero-division: Always add small epsilon to depth divisors
- Extreme values: Cap multipliers to prevent absurd numbers
- Save/load: Deep positions must serialize correctly

## Verify

- [ ] Build succeeds
- [ ] No hard depth cap - game doesn't crash or stop at any depth
- [ ] Block hardness increases beyond deepest defined layer
- [ ] Ore spawn rates adjust at extreme depths
- [ ] Ore values scale with depth
- [ ] Layer visuals cycle or continue beyond defined layers
- [ ] No integer overflow at depth 100,000+
- [ ] Depth milestones trigger at 1k, 2k, 5k, 10k+
- [ ] Save/load works correctly at extreme depths
