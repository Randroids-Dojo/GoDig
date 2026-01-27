---
title: "implement: Integrate ores into chunk generation"
status: closed
priority: 1
issue-type: task
created-at: "2026-01-16T00:38:21.629745-06:00"
after:
  - GoDig-dev-noise-based-3afe498c
  - GoDig-dev-vein-expansion-3cb3cd9f
close-reason: Implemented in dirt_grid.gd _generate_chunk calls _determine_ore_spawn for each tile, using depth-based ore distribution
---

## Description

Integrate ore generation into the chunk-based world system. When a chunk is generated, determine which tiles should contain ores based on depth, noise thresholds, and vein expansion. Process ores from rarest to most common to preserve valuable finds.

## Context

Currently `dirt_grid.gd` has basic ore spawning (`_determine_ore_spawn`). This needs to work with the chunk-based system in `TerrainGenerator`. The ore system uses:
- OreData resources with spawn parameters (min/max depth, threshold, frequency)
- Noise-based clustering for natural distribution
- Vein expansion for connected ore deposits

## Affected Files

- `scripts/world/terrain_generator.gd` - Add `_check_ore_at()` integration
- `scripts/world/chunk_manager.gd` - Call ore generation during chunk creation
- `scripts/world/ore_generator.gd` - NEW (optional): Dedicated ore gen utilities

## Implementation Notes

### Ore Integration in TerrainGenerator

```gdscript
## Check if position should be an ore (called after cave check, before base layer)
static func _check_ore_at(world_pos: Vector2i, depth: int) -> int:
    # Get ores available at this depth, sorted rarest-first
    var available_ores := DataRegistry.get_ores_at_depth(depth)
    available_ores.sort_custom(func(a, b): return a.spawn_threshold > b.spawn_threshold)

    for ore in available_ores:
        var noise: FastNoiseLite = _ore_noises.get(ore.id)
        if noise == null:
            continue

        var noise_value := noise.get_noise_2d(world_pos.x, world_pos.y)
        noise_value = (noise_value + 1.0) / 2.0  # Normalize to 0-1

        # Slight depth bonus within valid range
        var depth_bonus := (depth - ore.min_depth) / 2000.0 * 0.03
        var adjusted_threshold := ore.spawn_threshold - depth_bonus

        if noise_value > adjusted_threshold:
            return _get_ore_tile_type(ore.id)

    return -1  # No ore
```

### Ore Noise Initialization

```gdscript
## Called during TerrainGenerator.initialize()
static func _initialize_ore_noises(world_seed: int) -> void:
    var ore_ids := DataRegistry.get_all_ore_ids()
    for i in range(ore_ids.size()):
        var ore_id: String = ore_ids[i]
        var ore_data := DataRegistry.get_ore(ore_id)

        var noise := FastNoiseLite.new()
        noise.seed = world_seed + 2000 + i
        noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
        noise.frequency = ore_data.noise_frequency
        _ore_noises[ore_id] = noise
```

### Ore-to-TileType Mapping

```gdscript
static func _get_ore_tile_type(ore_id: String) -> int:
    match ore_id:
        "coal": return TileTypes.Type.COAL
        "copper": return TileTypes.Type.COPPER
        "iron": return TileTypes.Type.IRON
        "silver": return TileTypes.Type.SILVER
        "gold": return TileTypes.Type.GOLD
        "diamond": return TileTypes.Type.DIAMOND
        _: return -1
```

### Integration Order in get_tile_at()

```gdscript
static func get_tile_at(world_pos: Vector2i) -> int:
    var depth := world_pos.y

    # 1. Above surface = air
    if depth < 0:
        return TileTypes.Type.AIR

    # 2. Check for caves (air pockets)
    if _is_cave(world_pos, depth):
        return TileTypes.Type.AIR

    # 3. Check for ores (rarest first)
    var ore := _check_ore_at(world_pos, depth)
    if ore != -1:
        return ore

    # 4. Return base layer type
    return _get_layer_tile(depth, world_pos)
```

## Edge Cases

- Ore at cave boundary: Cave check runs first, no ore in air
- Multiple ores at same position: Rarest wins (sorted by threshold)
- Ore outside depth range: `can_spawn_at_depth()` filters
- Surface row (depth=0): Ores can spawn (coal starts at 0)
- Noise initialization: Must call `initialize()` before first chunk

## Verify

- [ ] Build succeeds with no errors
- [ ] Coal appears at depth 0-500m
- [ ] Copper appears at depth 10-300m (not at surface)
- [ ] Diamond only appears at depth 800m+
- [ ] Rarer ores don't get overwritten by common ores
- [ ] Ore noise produces consistent results for same seed
- [ ] Ores don't spawn in cave air pockets
