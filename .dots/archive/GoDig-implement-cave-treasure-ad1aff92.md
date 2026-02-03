---
title: "implement: Cave treasure chests"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-01T01:20:41.771933-06:00\\\"\""
closed-at: "2026-02-03T03:04:19.863735-06:00"
close-reason: "Implemented treasure chest system in caves: TreasureChestManager autoload, TreasureChest scene with collision-based interaction, 4-tier loot system (Common/Uncommon/Rare/Epic), depth-adjusted loot quality, celebration effects (particles, sound, haptic), save/load persistence"
---

## Description
Spawn treasure chests in cave spaces with randomized loot (coins, items, rare ores, artifacts).

## Context
Caves currently feel empty - player falls into void with nothing to find. Research shows hidden discoveries create strong dopamine response. Treasure chests add a loot-box-style excitement without monetization concerns.

## Implementation
1. In dirt_grid.gd `_is_cave_tile()`, mark caves for chest spawning
2. Add chest spawn logic: ~10% of cave tiles get a chest
3. Create TreasureChest scene (static sprite, click/collide to open)
4. Chest loot table:
   - Common: 50-200 coins
   - Uncommon: 1-3 random ores from current depth range
   - Rare: Artifact item
   - Very Rare: Ladder/rope bundle
5. Opening chest = celebration effect

## Affected Files
- `scripts/world/dirt_grid.gd` - Add chest spawning in caves
- `scenes/world/treasure_chest.tscn` - New chest scene
- `scripts/world/treasure_chest.gd` - Chest interaction and loot logic
- `resources/loot/chest_loot_table.tres` - Loot table resource

## Verify
- [ ] Chests spawn in ~10% of cave spaces
- [ ] Chests are visible with distinct sprite
- [ ] Player can interact with chest (collision or click)
- [ ] Loot is randomized and depth-appropriate
- [ ] Opening chest triggers celebration effect
- [ ] Empty caves still exist (not every cave has a chest)
