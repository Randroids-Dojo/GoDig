---
title: "implement: Noise-based terrain generation"
status: open
priority: 1
issue-type: task
created-at: "2026-01-16T00:37:51.430503-06:00"
after:
  - GoDig-dev-chunk-data-0fe0f614
---

## Description

Create a TerrainGenerator class that uses FastNoiseLite to generate terrain tiles based on depth and position. Handles layer transitions (dirt -> stone -> granite), ore placement, and cave generation. Used by ChunkManager to populate chunks.

## Current State Note

**The current codebase uses a different architecture:**
- `DirtGrid` with ColorRect-based blocks (object pooling, not TileMap)
- `DataRegistry` with OreData/LayerData resources for ore/layer properties
- Ore spawning uses hash-based noise in `DirtGrid._determine_ore_spawn()`

This spec describes a TileSet/TileMap approach that could replace the current system for better performance with very large worlds. Consider this a future refactor or alternative implementation. The current DirtGrid approach works for MVP.

## Context

The infinite world needs deterministic generation - the same seed should always produce the same terrain. FastNoiseLite provides smooth noise that creates natural-looking variation. Depth determines layer (dirt/stone/etc), noise adds horizontal variation.

## Affected Files

- `scripts/world/terrain_generator.gd` - NEW: Static terrain generation class
- Depends on: TileTypes, world seed from SaveManager

## Implementation Notes

### TerrainGenerator Class

```gdscript
# scripts/world/terrain_generator.gd
class_name TerrainGenerator
extends RefCounted

# Noise generators (initialized once with world seed)
static var _terrain_noise: FastNoiseLite
static var _cave_noise: FastNoiseLite
static var _ore_noises: Dictionary = {}  # ore_type -> FastNoiseLite
static var _is_initialized: bool = false

## Initialize with world seed - call once at game start
static func initialize(world_seed: int) -> void:
    if _is_initialized:
        return
    _is_initialized = true

    # Main terrain variation noise
    _terrain_noise = FastNoiseLite.new()
    _terrain_noise.seed = world_seed
    _terrain_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
    _terrain_noise.frequency = 0.02

    # Cave generation noise
    _cave_noise = FastNoiseLite.new()
    _cave_noise.seed = world_seed + 1000
    _cave_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
    _cave_noise.frequency = 0.04

    # Ore-specific noises (different seed per ore type)
    var ore_types := [
        TileTypes.Type.COAL,
        TileTypes.Type.COPPER,
        TileTypes.Type.IRON,
        TileTypes.Type.SILVER,
        TileTypes.Type.GOLD,
        TileTypes.Type.DIAMOND
    ]
    for i in range(ore_types.size()):
        var noise := FastNoiseLite.new()
        noise.seed = world_seed + 2000 + i
        noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
        noise.frequency = 0.05 + i * 0.01  # Rarer ores have tighter clusters
        _ore_noises[ore_types[i]] = noise


## Main entry point: get tile type at world position
static func get_tile_at(world_pos: Vector2i) -> int:
    var depth := world_pos.y

    # Above surface = air
    if depth < 0:
        return TileTypes.Type.AIR

    # Surface row = special (grass/entrance)
    if depth == 0:
        return TileTypes.Type.DIRT

    # Check for caves first
    if _is_cave(world_pos, depth):
        return TileTypes.Type.AIR

    # Check for ores (rarest first)
    var ore := _check_ore_at(world_pos, depth)
    if ore != -1:
        return ore

    # Return base layer type
    return _get_layer_tile(depth, world_pos)


## Determine base terrain type by depth
## Uses DataRegistry.get_layer_at_depth() for layer boundaries (defined in LayerData resources)
static func _get_layer_tile(depth: int, world_pos: Vector2i) -> int:
    # Add noise variation to layer boundaries
    var noise_offset := int(_terrain_noise.get_noise_2d(world_pos.x, 0) * 15)
    var adjusted_depth := depth - noise_offset

    # Use DataRegistry for data-driven layer lookup
    var layer := DataRegistry.get_layer_at_depth(adjusted_depth)
    if layer == null:
        return TileTypes.Type.DIRT  # Fallback

    # Map layer ID to tile type
    match layer.id:
        "topsoil": return TileTypes.Type.DIRT
        "subsoil": return TileTypes.Type.CLAY
        "stone": return TileTypes.Type.STONE
        "deep_stone": return TileTypes.Type.GRANITE
        # Future layers:
        # "basalt": return TileTypes.Type.BASALT
        # "obsidian": return TileTypes.Type.OBSIDIAN
        _: return TileTypes.Type.DIRT


## Check if position should be a cave (empty)
static func _is_cave(world_pos: Vector2i, depth: int) -> bool:
    # Caves start appearing below 200m
    if depth < 200:
        return false

    var cave_value := _cave_noise.get_noise_2d(world_pos.x, world_pos.y)

    # Threshold decreases with depth (more caves deeper)
    var threshold := 0.6 - (depth / 5000.0) * 0.15
    threshold = max(threshold, 0.4)  # Cap at 40% cave density

    return cave_value > threshold


## Check if position should be an ore
static func _check_ore_at(world_pos: Vector2i, depth: int) -> int:
    # Check from rarest to most common (priority order)
    var ore_checks := [
        [TileTypes.Type.DIAMOND, 800, -1, 0.97],    # [type, min_depth, max_depth, threshold]
        [TileTypes.Type.GOLD, 300, 1200, 0.92],
        [TileTypes.Type.SILVER, 200, 900, 0.88],
        [TileTypes.Type.IRON, 50, 700, 0.82],
        [TileTypes.Type.COPPER, 10, 400, 0.78],
        [TileTypes.Type.COAL, 0, 500, 0.75],
    ]

    for check in ore_checks:
        var ore_type: int = check[0]
        var min_depth: int = check[1]
        var max_depth: int = check[2]  # -1 means no max
        var threshold: float = check[3]

        if depth < min_depth:
            continue
        if max_depth > 0 and depth > max_depth:
            continue

        if not _ore_noises.has(ore_type):
            continue

        var noise: FastNoiseLite = _ore_noises[ore_type]
        var noise_value := noise.get_noise_2d(world_pos.x, world_pos.y)

        # Normalize from [-1, 1] to [0, 1]
        noise_value = (noise_value + 1.0) / 2.0

        # Slight bonus deeper in valid range
        var depth_bonus := (depth - min_depth) / 2000.0 * 0.03
        var adjusted_threshold := threshold - depth_bonus

        if noise_value > adjusted_threshold:
            return ore_type

    return -1  # No ore


## Get the layer name for display (depth indicator, achievements)
## Uses DataRegistry for data-driven layer names
static func get_layer_name(depth: int) -> String:
    var layer := DataRegistry.get_layer_at_depth(depth)
    if layer:
        return layer.display_name
    return "Unknown Depths"
```

### Layer Depth Configuration

Layer boundaries are now defined in LayerData resources (`resources/layers/*.tres`) and loaded by DataRegistry. This allows data-driven configuration without code changes.

See existing layer files:
- `resources/layers/topsoil.tres` - 0-50m
- `resources/layers/subsoil.tres` - 50-200m
- `resources/layers/stone.tres` - 200-500m
- `resources/layers/deep_stone.tres` - 500m+

To add new layers (e.g., basalt, obsidian), create new `.tres` files with appropriate `min_depth`/`max_depth` values.

### Ore Spawn Data

Define ore properties for balance tuning:

```gdscript
const ORE_DATA := {
    TileTypes.Type.COAL: {
        "min_depth": 0,
        "max_depth": 500,
        "sell_value": 2,
        "hardness": 2
    },
    TileTypes.Type.COPPER: {
        "min_depth": 10,
        "max_depth": 400,
        "sell_value": 5,
        "hardness": 3
    },
    TileTypes.Type.IRON: {
        "min_depth": 50,
        "max_depth": 700,
        "sell_value": 10,
        "hardness": 4
    },
    TileTypes.Type.SILVER: {
        "min_depth": 200,
        "max_depth": 900,
        "sell_value": 25,
        "hardness": 5
    },
    TileTypes.Type.GOLD: {
        "min_depth": 300,
        "max_depth": 1200,
        "sell_value": 50,
        "hardness": 6
    },
    TileTypes.Type.DIAMOND: {
        "min_depth": 800,
        "max_depth": -1,
        "sell_value": 200,
        "hardness": 10
    }
}
```

## Edge Cases

- Surface row (depth=0): Always dirt, no ores
- Negative depth: Always air (above ground)
- Very deep (>5000): Continue obsidian, maintain ore spawns
- Cave at surface level: Not allowed (check depth >= 200)
- Multiple ore types at same position: Rarest wins (priority order)

## Verify

- [ ] Build succeeds with no errors
- [ ] TerrainGenerator.initialize() accepts world seed
- [ ] get_tile_at() returns correct layer types at expected depths
- [ ] Ores only spawn within their depth ranges
- [ ] Rarer ores have priority over common ores
- [ ] Caves appear below depth 200
- [ ] Same seed produces identical terrain
- [ ] get_layer_name() returns correct string for depth
