# Underground Layers & Biomes Research

## Sources
- [Terraria Layers Wiki](https://terraria.wiki.gg/wiki/Layers)
- [Terraria Cavern Layer](https://terraria.wiki.gg/wiki/Cavern)
- [Terraria Biomes Guide](https://gamefaqs.gamespot.com/pc/630609-terraria/faqs/79113/biomes-simple)
- [Motherload Classic](https://free-aigames.com/game/motherload)

## Terraria Layer System (Reference)

### Five Distinct Layers
1. **Space** - Reduced gravity, floating islands
2. **Surface** - Multiple biomes (forest, desert, snow)
3. **Underground** - Dirt, stone, clay, basic ores
4. **Cavern** - Lava pools, underground biome variants
5. **Underworld** - Bottom 400ft, hellscape, boss area

### Key Design Insights
- Each layer has distinct visual identity
- Layers transition gradually (not hard cutoffs)
- Underground versions of surface biomes add variety
- Deepest layer is unique/special (hell/boss)

## GoDig Layer Design

### Proposed Layer Structure

```
SURFACE (0m)
├── Grass/dirt top
└── Building zone

TOPSOIL (0-50m)
├── Soft dirt (easy digging)
├── Clay patches
├── Coal, Copper (common)
└── Low danger

SUBSOIL (50-200m)
├── Dense dirt
├── Stone patches begin
├── Iron, Tin (uncommon)
├── Small caves
└── First hazards (water pools)

STONE LAYER (200-500m)
├── Mostly stone
├── Harder digging
├── Silver, Gold (rare)
├── Cave systems
├── Underground lakes
└── Enemies begin appearing?

DEEP STONE (500-1000m)
├── Dense stone/granite
├── Slow digging without upgrades
├── Platinum, Gems (very rare)
├── Large caverns
├── Lava pools begin
└── Environmental hazards

CRYSTAL CAVES (1000-2000m)
├── Crystalline formations
├── Mythril, Diamond (legendary)
├── Unique visual style
├── Glowing crystals (natural light)
└── Special enemies

MAGMA ZONE (2000-5000m)
├── Volcanic rock
├── Lava everywhere
├── Heat damage without gear
├── Adamantine, Stardust (mythical)
└── Ultimate challenge

VOID DEPTHS (5000m+)
├── Unknown material
├── Mysterious/alien aesthetic
├── Void Crystals (ultimate rarity)
├── End-game content
└── Special mechanics?
```

### Layer Properties

| Layer | Depth | Hardness | Ores | Hazards | Lighting |
|-------|-------|----------|------|---------|----------|
| Topsoil | 0-50m | 10-15 | T1 | None | Good |
| Subsoil | 50-200m | 15-25 | T2 | Water | Medium |
| Stone | 200-500m | 30-50 | T3 | Caves, water | Low |
| Deep Stone | 500-1km | 50-80 | T4 | Lava, gas | Dark |
| Crystal | 1-2km | 80-120 | T5-6 | Enemies | Glow |
| Magma | 2-5km | 120-180 | T7 | Heat, lava | Red glow |
| Void | 5km+ | 200+ | T8 | Unknown | None |

## Biome Variants

### Horizontal Variation
Within each depth layer, have horizontal biomes:

**In Stone Layer (200-500m):**
- Normal Stone - Gray, standard
- Ice Caves - Blue tint, slippery, frozen water
- Mushroom Caverns - Bioluminescent, special plants
- Ancient Ruins - Man-made structures, artifacts

**Implementation:**
```gdscript
func get_biome_at(pos: Vector2i) -> String:
    var biome_noise = biome_noise_gen.get_noise_2d(pos.x, 0)

    if biome_noise < -0.5:
        return "ice"
    elif biome_noise > 0.5:
        return "mushroom"
    elif pos.x % 500 < 50:  # Every 500 tiles
        return "ruins"
    else:
        return "normal"
```

### Visual Differentiation
Each layer/biome needs:
- Unique background color/texture
- Different block sprites
- Ambient particles (dust, drips, embers)
- Distinct music/ambient sounds

## Cave Generation

### Natural Caves
- Appear in Stone layer and below
- Use noise + cellular automata
- Contains air pockets
- May have water/lava at bottom
- Rare treasure rooms

### Cave Types
1. **Tunnels** - Long narrow passages
2. **Chambers** - Large open spaces
3. **Lake Caverns** - Underground water bodies
4. **Lava Tubes** - In Magma zone
5. **Crystal Grottos** - In Crystal layer

### Cave Generation Code
```gdscript
func generate_caves(chunk: Vector2i):
    for x in range(CHUNK_SIZE):
        for y in range(CHUNK_SIZE):
            var world_pos = chunk_to_world(chunk) + Vector2i(x, y)
            var cave_noise = cave_noise_gen.get_noise_2d(world_pos.x, world_pos.y)

            # Caves more common at certain depths
            var depth = world_pos.y
            var cave_threshold = 0.6 - (depth / 5000.0) * 0.2

            if cave_noise > cave_threshold:
                # This is a cave tile (air)
                set_tile(world_pos, TILE_AIR)
```

## Transition Zones

### Smooth Blending
Don't hard-cut between layers:

```gdscript
func get_layer_blend(depth: int) -> Dictionary:
    # Transition zones of ~20 tiles
    if depth >= 180 and depth < 220:
        var blend = (depth - 180) / 40.0
        return {
            "primary": "subsoil",
            "secondary": "stone",
            "blend": blend
        }
    # ... etc
```

### Visual Indicators
- Gradual color shift
- Mixed tile types in transitions
- "You're entering Stone Layer" popup?

## Hazards by Layer

### Environmental
| Layer | Hazard | Effect | Mitigation |
|-------|--------|--------|------------|
| Subsoil | Water pools | Slows movement | None needed |
| Stone | Unstable rocks | Fall damage | Watch for cracks |
| Deep Stone | Gas pockets | Damage over time | Gas mask |
| Crystal | Enemies | Combat | Weapons/armor |
| Magma | Lava | Instant death | Heat suit |
| Magma | Heat | Gradual damage | Heat suit |
| Void | ??? | ??? | ??? |

## Questions to Resolve
- [ ] How many unique layers?
- [ ] Hard transitions or gradual blending?
- [ ] Horizontal biomes or just vertical?
- [ ] Enemies in mining game?
- [ ] Special mechanics for deepest layer?
