# Ore Vein Generation Research

## Sources
- [Unity: Generating Chunks of Ore](https://discussions.unity.com/t/generating-chunks-of-ore-using-perlin-noise/218414)
- [Minecraft World Generation](https://www.alanzucconi.com/2022/06/05/minecraft-world-generation/)
- [Perlin Noise Algorithm](https://rtouti.github.io/graphics/perlin-noise-algorithm)
- [Procedural Terrain Guide](https://www.jdhwilkins.com/mountains-cliffs-and-caves-a-comprehensive-guide-to-using-perlin-noise-for-procedural-generation)

## Generation Approaches

### Option A: Pure Noise Threshold
Sample noise at each position, place ore if above threshold.

**Pros:** Simple, consistent
**Cons:** Uniform blob shapes

### Option B: Random Walk Veins
Start at random position, "walk" in random directions placing ore.

**Pros:** Natural vein shapes (Minecraft-style)
**Cons:** More complex, harder to make deterministic

### Option C: Hybrid (Recommended)
Use noise for density zones + random walk for vein shapes within zones.

## Godot 4 Implementation

### Noise Setup
```gdscript
# ore_generator.gd
extends Node

var ore_noises: Dictionary = {}  # One noise per ore type

func _ready():
    _initialize_noises()

func _initialize_noises():
    var base_seed = SaveManager.current_save.world_seed

    for ore_type in OreData.ORES:
        var noise = FastNoiseLite.new()
        noise.seed = base_seed + ore_type.hash()
        noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
        noise.frequency = 0.05  # Adjust for cluster size
        ore_noises[ore_type] = noise
```

### Basic Ore Placement
```gdscript
func should_place_ore(pos: Vector2i, ore_type: String) -> bool:
    var depth = pos.y
    var ore_data = OreData.get_ore(ore_type)

    # Check depth requirements
    if depth < ore_data.min_depth:
        return false
    if depth > ore_data.max_depth and ore_data.max_depth > 0:
        return false

    # Get noise value
    var noise = ore_noises[ore_type]
    var noise_value = noise.get_noise_2d(pos.x, pos.y)

    # Noise returns -1 to 1, normalize to 0-1
    noise_value = (noise_value + 1) / 2.0

    # Apply depth modifier (rarer ores need higher thresholds)
    var threshold = ore_data.spawn_threshold

    # Slightly increase spawn rate as you go deeper within valid range
    var depth_factor = (depth - ore_data.min_depth) / 1000.0
    threshold -= depth_factor * 0.05  # Gets slightly easier

    return noise_value > threshold
```

### Ore Data Structure
```gdscript
# ore_data.gd
class_name OreData

const ORES = {
    "coal": {
        "min_depth": 0,
        "max_depth": 500,
        "spawn_threshold": 0.75,
        "frequency": 0.08,  # Larger clusters
        "vein_size": [3, 8],
        "tier": 1
    },
    "copper": {
        "min_depth": 10,
        "max_depth": 300,
        "spawn_threshold": 0.78,
        "frequency": 0.06,
        "vein_size": [2, 6],
        "tier": 1
    },
    "iron": {
        "min_depth": 50,
        "max_depth": 600,
        "spawn_threshold": 0.82,
        "frequency": 0.05,
        "vein_size": [2, 5],
        "tier": 2
    },
    "silver": {
        "min_depth": 200,
        "max_depth": 800,
        "spawn_threshold": 0.88,
        "frequency": 0.04,
        "vein_size": [2, 4],
        "tier": 3
    },
    "gold": {
        "min_depth": 300,
        "max_depth": 1000,
        "spawn_threshold": 0.92,
        "frequency": 0.03,
        "vein_size": [1, 3],
        "tier": 3
    },
    "diamond": {
        "min_depth": 800,
        "max_depth": -1,  # No max
        "spawn_threshold": 0.97,
        "frequency": 0.02,
        "vein_size": [1, 2],
        "tier": 6
    }
}
```

### Vein Expansion (Random Walk)
```gdscript
func generate_vein(start_pos: Vector2i, ore_type: String) -> Array[Vector2i]:
    """Generate a natural-looking vein starting from position."""
    var ore_data = OreData.ORES[ore_type]
    var vein_size = randi_range(ore_data.vein_size[0], ore_data.vein_size[1])
    var positions: Array[Vector2i] = [start_pos]
    var directions = [
        Vector2i(1, 0), Vector2i(-1, 0),
        Vector2i(0, 1), Vector2i(0, -1),
        Vector2i(1, 1), Vector2i(-1, -1),
        Vector2i(1, -1), Vector2i(-1, 1)
    ]

    var current = start_pos
    for i in range(vein_size - 1):
        # Random walk
        var dir = directions[randi() % directions.size()]
        current = current + dir

        # Avoid duplicates
        if current not in positions:
            positions.append(current)

    return positions
```

## Chunk-Based Generation

### Integrate with Chunk System
```gdscript
func generate_chunk_ores(chunk_coord: Vector2i, chunk_tiles: Dictionary):
    """Add ores to generated chunk tiles."""
    var base_pos = chunk_coord * CHUNK_SIZE

    for x in range(CHUNK_SIZE):
        for y in range(CHUNK_SIZE):
            var world_pos = base_pos + Vector2i(x, y)

            # Skip if not stone/dirt (only place ore in solid ground)
            if chunk_tiles[Vector2i(x, y)] not in [TILE_STONE, TILE_DIRT]:
                continue

            # Check each ore type (rarest first to avoid overwriting)
            for ore_type in get_ores_by_rarity_desc():
                if should_place_ore(world_pos, ore_type):
                    # Generate vein
                    var vein = generate_vein(world_pos, ore_type)
                    for vein_pos in vein:
                        var local = vein_pos - base_pos
                        if is_valid_local_pos(local):
                            chunk_tiles[local] = get_ore_tile_id(ore_type)
                    break  # Only one ore type per "seed" position
```

### Depth Zone Visualization
```
Depth 0m    ████████████████████████████████
            Coal █████████████████
            Copper ████████████████

Depth 100m  ████████████████████████████████
            Coal ███████████████
            Copper ██████████████
            Iron █████████████████

Depth 300m  ████████████████████████████████
            Iron ██████████████
            Silver ████████████████
            Gold █████████████

Depth 500m  ████████████████████████████████
            Silver ██████████████
            Gold ██████████████

Depth 800m  ████████████████████████████████
            Gold █████████████
            Diamond ████████████████

Depth 1000m+ ███████████████████████████████
            Diamond █████████████
            (Rare ores)
```

## Advanced: Multi-Octave Noise

### Fractal Brownian Motion (FBM)
```gdscript
func get_fbm_noise(noise: FastNoiseLite, pos: Vector2i, octaves: int = 3) -> float:
    """Combine multiple noise layers for more natural distribution."""
    var value = 0.0
    var amplitude = 1.0
    var frequency = 1.0
    var max_value = 0.0

    for i in range(octaves):
        value += noise.get_noise_2d(pos.x * frequency, pos.y * frequency) * amplitude
        max_value += amplitude
        amplitude *= 0.5  # Lacunarity
        frequency *= 2.0  # Persistence

    return value / max_value
```

## Gem vs Ore Distribution

### Gems: Sparse but Anywhere
```gdscript
# Gems don't follow veins - they're individual finds
func should_place_gem(pos: Vector2i, gem_type: String) -> bool:
    var gem_data = GemData.get_gem(gem_type)
    var depth = pos.y

    if depth < gem_data.min_depth:
        return false

    # Pure random with depth modifier (rarer = lower chance)
    var base_chance = gem_data.base_spawn_chance
    var depth_bonus = min(depth / 5000.0, 0.5)  # Up to +50% deep

    return randf() < (base_chance + depth_bonus * base_chance)
```

### Special Finds: Artifacts, Chests
```gdscript
# Very rare, depth-gated
func should_place_artifact(pos: Vector2i) -> bool:
    var depth = pos.y
    if depth < 500:
        return false

    # 1 in 10,000 chance per tile, increasing with depth
    var chance = 0.0001 * (1 + depth / 1000.0)
    return randf() < chance
```

## Performance Considerations

### Pre-calculate Noise
```gdscript
# Cache noise values for chunk
var noise_cache: Dictionary = {}

func get_cached_noise(pos: Vector2i, ore_type: String) -> float:
    var key = str(pos) + ore_type
    if key not in noise_cache:
        noise_cache[key] = ore_noises[ore_type].get_noise_2d(pos.x, pos.y)
    return noise_cache[key]

func clear_cache():
    noise_cache.clear()
```

### Batch Processing
- Generate all ores for a chunk at once
- Don't query noise per-frame
- Cache results for persistence

## Questions to Resolve
- [x] Vein sizes by ore type? → 3-8 tiles common, 1-3 tiles rare
- [x] Pure noise vs random walk veins? → Hybrid (noise placement + walk expansion)
- [x] Overlap handling? → Rarest ore wins (priority system)
- [x] Special "rich vein" rare events? → Yes, 1% chance for 2x size
- [x] Visible gem sparkle before mining? → Yes, subtle particle effect
