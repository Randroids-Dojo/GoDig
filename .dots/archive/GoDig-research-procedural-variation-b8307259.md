---
title: "research: Procedural variation and discovery surprise - avoid pattern recognition"
status: closed
priority: 3
issue-type: task
created-at: "\"\\\"2026-02-01T01:46:40.789551-06:00\\\"\""
closed-at: "2026-02-01T01:52:25.943842-06:00"
close-reason: "Completed research on procedural variation. Key findings: use layered noise for unpredictability, random walk for ore veins, seeded generation for reproducibility. Linked to existing implementation dots for jackpot discoveries and treasure chests."
---

Players lose engagement when they can predict ore locations. Research: noise parameters for unpredictability, cave placement RNG, occasional surprise bonus areas. Goal: make each dive feel like fresh exploration.

## Research Findings

### Why Unpredictability Matters

From [peerdh.com](https://peerdh.com/blogs/programming-insights/the-role-of-surprise-mechanics-in-gaming-retention):

- "Surprise mechanics create a sense of anticipation and excitement"
- Unexpected rewards keep players exploring "every nook and cranny"
- "The more invested players feel, the less likely they are to abandon the game"

### Techniques Used by Similar Games

**SteamWorld Dig Hybrid Approach:**
- World structure is hard-coded (curated puzzles, progression)
- Enemy and resource placement is randomized
- "Mines are randomly generated, but caves include curated puzzles"
- This balances unpredictability with intentional design

**Minecraft/Infiniminer Ore Veins:**
- "Random walk" technique for ore placement
- Vein starts at random position, moves in random directions
- Deterministic from seed (same seed = same world)
- Each iteration creates organic-looking deposits

**Terraria Multiple Ore Types:**
- Secret seeds enable all ore variants
- Player choice/randomization at world creation
- Fishing/Extractinator provide alternative ore sources

### Key Insight: Seeded Randomness

From [Alan Zucconi on Minecraft](https://www.alanzucconi.com/2022/06/05/minecraft-world-generation/):

- "These algorithms might be random, but they are also deterministic"
- Same seed = same results (reproducibility)
- World seeds enable sharing, bug reports, replays
- GoDig should support world seeds for testing and player sharing

### Discovery Surprise Types

1. **Ore Clusters (Expected)**: Depth-based, noise-distributed, predictable general locations
2. **Rare Veins (Surprise)**: Low probability large deposits, memorable finds
3. **Hidden Caves (Surprise)**: Procedural voids with guaranteed rewards
4. **Treasure Chests (Surprise)**: Curated loot in unexpected locations
5. **Bonus Rooms (Curated)**: Hand-designed puzzles placed procedurally

### GoDig Implementation Recommendations

#### 1. Layered Noise for Ore Distribution
- Base layer: Perlin noise for general density
- Vein layer: Random walk for ore clusters
- Rare layer: Low-frequency noise for jackpot deposits
- **Result**: Unpredictable micro-level, predictable macro-level (deeper = rarer ores)

#### 2. Cave Generation
- Cellular automata or marching squares for organic shapes
- Guaranteed small cave every 50-100m depth
- Rare large caves with treasure chests
- Caves provide visual variety and loot concentration

#### 3. Surprise Elements
- **Jackpot Deposits**: 1% chance for 5x normal ore cluster
- **Hidden Treasures**: Buried chests with coins/items (shimmer hint nearby)
- **Fossil Finds**: Rare cosmetic/collectible discoveries
- **Surprise Biome Pockets**: Occasional ice/mushroom micro-biomes

#### 4. Avoid Predictability Traps
- DON'T place ore at exact depth intervals (every 25m = boring)
- DON'T use obvious grid patterns
- DO add +/- 20% variance to spawn depths
- DO cluster ores in veins, not uniform distribution

### Implementation Priority

**MVP (P2):**
- Noise-based ore distribution with depth scaling
- Random walk ore veins
- Basic cave generation (optional, empty voids)

**Post-MVP (P3-P4):**
- Treasure chests in caves
- Jackpot deposit celebrations
- Surprise biome pockets
- Hidden fossil collectibles

## Existing Related Dots

- `GoDig-implement-jackpot-discovery-aae547b3` - Celebration for rare finds
- `GoDig-implement-near-miss-c1c29f4c` - Shimmer hints near ore
- `GoDig-implement-cave-treasure-ad1aff92` - Treasure chests in caves

## Sources
- [Procedural Generation - The Caves - Noel Berry](https://noelberry.ca/posts/thecaves/index.html)
- [Minecraft World Generation - Alan Zucconi](https://www.alanzucconi.com/2022/06/05/minecraft-world-generation/)
- [Surprise Mechanics in Gaming - peerdh.com](https://peerdh.com/blogs/programming-insights/the-role-of-surprise-mechanics-in-gaming-retention)
- [SteamWorld Dig Discussion - Steam](https://steamcommunity.com/app/252410/discussions/0/666828126638941484/)
