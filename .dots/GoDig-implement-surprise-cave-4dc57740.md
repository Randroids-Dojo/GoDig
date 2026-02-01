---
title: "implement: Surprise cave biome generation"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T09:52:10.528160-06:00"
---

## Description
Add rare surprise cave biomes that override normal procedural generation, creating discovery moments.

## Context
Starbound research shows: 'Underground caves can spawn in place of generic layer - special rare zones with unique characteristics.' This creates exploration surprise.

## Implementation
1. Define 3-4 special cave types:
   - Crystal Cavern (sparkly, extra gems)
   - Mushroom Grotto (organic, ladder drops)
   - Ancient Mining Camp (lore items, abandoned equipment)
   - Lava Pocket (dangerous but rich ore)
2. Each has ~5% spawn chance per layer (rare but expected)
3. Distinct visual appearance immediately signals 'special'
4. Unique drops/features per cave type

## Affected Files
- scripts/world/chunk_generator.gd (biome spawn logic)
- resources/biomes/*.tres (new biome definitions)
- scenes/biomes/*.tscn (biome prefabs)

## Verify
- [ ] Cave biomes spawn at appropriate rarity
- [ ] Each biome is visually distinct
- [ ] Biomes offer unique rewards
- [ ] Player feels genuine 'discovery' excitement
