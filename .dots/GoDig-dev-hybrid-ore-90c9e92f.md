---
title: "implement: Hybrid ore generation (noise + walk)"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T00:42:53.971384-06:00"
after:
  - GoDig-dev-integrate-ores-3f8b9c4b
  - GoDig-dev-vein-expansion-3cb3cd9f
---

## Description

Implement hybrid ore generation combining noise-based density zones with random walk vein expansion. Noise determines WHERE ore can spawn (high-probability zones), random walk determines the SHAPE of veins within those zones.

## Context

Two approaches exist for ore generation:
1. **Pure Noise**: Sample noise at each tile, place ore above threshold. Creates uniform blobs.
2. **Pure Random Walk**: Start at random point, walk to create vein. Hard to control density.

Hybrid approach gives best of both:
- Noise creates natural "ore-rich" regions
- Random walk creates satisfying vein shapes
- Rarer ores have tighter thresholds AND smaller veins

See `Docs/research/ore-generation.md` for full research.

## Affected Files

- `scripts/world/terrain_generator.gd` - Integrate hybrid generation
- `scripts/world/ore_generator.gd` - NEW: Dedicated ore generation class
- `resources/ores/*.tres` - OreData already has vein_size_min/max

## Implementation Notes

### OreGenerator Class

```gdscript
# scripts/world/ore_generator.gd
class_name OreGenerator
extends RefCounted

## Generates ore veins using hybrid noise + random walk approach

static var _ore_noises: Dictionary = {}  # ore_id -> FastNoiseLite
static var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
static var _is_initialized: bool = false

## Initialize noise generators with world seed
static func initialize(world_seed: int) -> void:
    if _is_initialized:
        return
    _is_initialized = true

    var ore_ids := DataRegistry.get_all_ore_ids()
    for i in range(ore_ids.size()):
        var ore_id: String = ore_ids[i]
        var ore_data := DataRegistry.get_ore(ore_id)

        var noise := FastNoiseLite.new()
        noise.seed = world_seed + 2000 + i
        noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
        noise.frequency = ore_data.noise_frequency
        _ore_noises[ore_id] = noise


## Check if position is in an ore-rich zone and potentially start a vein
static func check_ore_at(world_pos: Vector2i, depth: int, placed_ores: Dictionary) -> String:
    # Skip if already has ore (from another vein)
    if placed_ores.has(world_pos):
        return ""

    # Get available ores at this depth, sorted by rarity (rarest first)
    var available_ores := DataRegistry.get_ores_at_depth(depth)
    available_ores.sort_custom(func(a, b): return a.spawn_threshold > b.spawn_threshold)

    for ore in available_ores:
        if _is_in_ore_zone(world_pos, ore):
            return ore.id

    return ""


## Check if position is in a noise-defined ore zone
static func _is_in_ore_zone(world_pos: Vector2i, ore) -> bool:
    var noise: FastNoiseLite = _ore_noises.get(ore.id)
    if noise == null:
        return false

    var noise_value := noise.get_noise_2d(world_pos.x, world_pos.y)
    noise_value = (noise_value + 1.0) / 2.0  # Normalize to 0-1

    # Depth bonus: slightly easier spawn deeper in valid range
    var depth := world_pos.y
    var depth_bonus := (depth - ore.min_depth) / 2000.0 * 0.03
    var adjusted_threshold := ore.spawn_threshold - depth_bonus

    return noise_value > adjusted_threshold


## Generate a vein from seed position using random walk
static func generate_vein(start_pos: Vector2i, ore_id: String, placed_ores: Dictionary) -> Array[Vector2i]:
    var ore := DataRegistry.get_ore(ore_id)
    if ore == null:
        return []

    var vein: Array[Vector2i] = [start_pos]
    var target_size := ore.get_random_vein_size(_rng)

    # Use position for deterministic RNG
    _rng.seed = start_pos.x * 10000 + start_pos.y + ore_id.hash()

    var current := start_pos
    var attempts := 0
    var max_attempts := target_size * 4

    while vein.size() < target_size and attempts < max_attempts:
        attempts += 1

        # Random walk in 4 directions (favor vertical for natural veins)
        var directions := [
            Vector2i(0, 1),   # Down (40%)
            Vector2i(0, 1),   # Down
            Vector2i(0, -1),  # Up (20%)
            Vector2i(1, 0),   # Right (20%)
            Vector2i(-1, 0),  # Left (20%)
        ]
        var dir: Vector2i = directions[_rng.randi() % directions.size()]
        var next := current + dir

        # Validate position
        if not _is_valid_vein_pos(next, start_pos, ore, placed_ores):
            continue

        # Skip if already in vein (but still move there for branching)
        if next in vein:
            current = next
            continue

        vein.append(next)
        current = next

    return vein


## Validate a position for vein expansion
static func _is_valid_vein_pos(pos: Vector2i, origin: Vector2i, ore, placed_ores: Dictionary) -> bool:
    # Check world bounds
    if pos.x < 0 or pos.x >= GameManager.GRID_WIDTH:
        return false

    # Check depth requirements
    var depth := pos.y - GameManager.SURFACE_ROW
    if not ore.can_spawn_at_depth(depth):
        return false

    # Don't spread too far from origin
    const MAX_SPREAD := 5
    if abs(pos.x - origin.x) > MAX_SPREAD or abs(pos.y - origin.y) > MAX_SPREAD:
        return false

    # Don't overwrite existing ore
    if placed_ores.has(pos):
        return false

    return true
```

### Integration with Chunk Generation

```gdscript
# In terrain_generator.gd or chunk_manager.gd
func _generate_chunk_ores(chunk_coord: Vector2i) -> Dictionary:
    var ores: Dictionary = {}  # Vector2i -> ore_id
    var base := ChunkManager.chunk_to_world(chunk_coord)

    # Process each tile in chunk
    for x in range(ChunkManager.CHUNK_SIZE):
        for y in range(ChunkManager.CHUNK_SIZE):
            var world_pos := base + Vector2i(x, y)
            var depth := world_pos.y - GameManager.SURFACE_ROW
            if depth < 0:
                continue

            # Check if this position triggers a vein
            var ore_id := OreGenerator.check_ore_at(world_pos, depth, ores)
            if ore_id.is_empty():
                continue

            # Generate vein from this seed position
            var vein := OreGenerator.generate_vein(world_pos, ore_id, ores)
            for vein_pos in vein:
                # Only add if within this chunk
                var local := vein_pos - base
                if local.x >= 0 and local.x < ChunkManager.CHUNK_SIZE and \
                   local.y >= 0 and local.y < ChunkManager.CHUNK_SIZE:
                    ores[vein_pos] = ore_id

    return ores
```

### Cross-Chunk Vein Handling

Veins may cross chunk boundaries. Handle by:
1. Generate veins for slightly larger area (+2 tiles each edge)
2. Only place tiles within actual chunk bounds
3. Neighbor chunks will regenerate overlapping portions identically (deterministic)

## Edge Cases

- Vein crosses chunk boundary: Deterministic RNG ensures consistency
- Multiple veins overlap: First vein wins (rarest ore checked first)
- Vein hits world edge: `_is_valid_vein_pos` rejects
- Very rare ore (small vein): May be just 1-2 tiles
- Performance: Limit vein size checks per chunk

## Verify

- [ ] Build succeeds with no errors
- [ ] Coal veins are 3-8 connected tiles
- [ ] Diamond veins are 1-2 tiles (rare, small)
- [ ] Veins form natural branching shapes (not uniform blobs)
- [ ] Veins don't cross world boundaries
- [ ] Same seed produces identical vein layouts
- [ ] Rarer ores don't get overwritten by common ores
- [ ] Cross-chunk veins appear continuous
