---
title: "implement: Hidden treasure rooms in procedural caves"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T08:46:05.847556-06:00"
---

## Description

Add rare hidden treasure rooms that spawn in procedural caves, creating memorable discovery moments.

## Context

From Session 15 research:
- 'The key is control: randomness should surprise players, but never betray them'
- Terraria: 'unique secrets, including hidden chests, underground temples'
- Hidden corridors offer 'alternative routes if discovered'
- 'It's not just exploration that's required, but also the sense of discovery'

## Implementation

### Treasure Room Types
1. **Supply Cache** (common, 1% per cave)
   - Small room (3x3 blocks cleared)
   - Contains 3-5 ladders or 1-2 ropes
   - Visual: broken crate with items spilling out

2. **Ore Pocket** (uncommon, 0.5% per cave)
   - Medium room (5x5 blocks cleared)
   - Contains 5-10 ore pieces of current depth tier
   - Visual: sparkling ore cluster

3. **Ancient Vault** (rare, 0.1% per cave)
   - Large room (7x7 blocks cleared)
   - Contains artifact + premium ore + coins
   - Visual: stone walls, chest in center
   - Door requires 3 blocks dug to enter

### Generation Rules
- Only spawn in natural caves (not player-dug areas)
- Minimum depth: 100m (no freebies in topsoil)
- Treasure room tier scales with depth
- Visual distinction: different block types for walls
- Glow effect visible from 2 blocks away

### Discovery Feedback
- 'Secret Found!' toast notification
- Sparkle particle effect on room
- Special discovery sound (distinct from ore)
- Achievement: 'Explorer' for finding 10 rooms

## Affected Files
- scripts/world/chunk.gd (add treasure room generation)
- scripts/world/treasure_room.gd (new - room types and spawning)
- resources/treasures/supply_cache.tres (new)
- resources/treasures/ore_pocket.tres (new)
- resources/treasures/ancient_vault.tres (new)

## Verify
- [ ] Treasure rooms spawn at correct rarity per cave
- [ ] Room contents match depth tier
- [ ] Visual glow hints at nearby room
- [ ] Discovery triggers celebration feedback
- [ ] Rooms don't spawn too close together
- [ ] Ancient vault requires digging to enter
