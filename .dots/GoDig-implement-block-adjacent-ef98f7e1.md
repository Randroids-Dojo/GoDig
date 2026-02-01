---
title: "implement: Block-adjacent ore shimmer hint"
status: open
priority: 3
issue-type: task
created-at: "2026-02-01T08:11:37.475639-06:00"
---

Add subtle visual hints for blocks adjacent to ore veins (Spelunker Potion pattern).

## Context
Research on near-miss psychology: 'Near-misses activate same reward systems as actual wins.' Terraria's Spelunker Potion makes ores visible through walls. We can use a subtler version as baseline mechanic.

## Description
Blocks immediately adjacent to ore veins have a subtle visual shimmer:
- Very subtle effect (players may not consciously notice)
- Increases anticipation without revealing exact location
- Different shimmer intensity based on ore rarity
- Can be upgraded (Spelunker Potion equivalent) to make more visible

## Visual Approach
- Occasional sparkle particle (1-2 per second)
- Slight color tint shift toward ore color
- Edge highlight on one side (directional hint)
- Effect only visible when player is within 5 tiles

## Affected Files
- scripts/world/dirt_block.gd - Adjacency detection
- shaders/ore_hint.gdshader - Shimmer effect
- scenes/world/dirt_block.tscn - Particle emitter
- scripts/items/spelunker_potion.gd - Enhancement item

## Implementation Notes
- Performance: Only active blocks near player
- Subtle by design - don't make mining trivial
- Consider as unlockable upgrade (Miner's Intuition)
- A/B test: does this improve or reduce satisfaction?

## Verify
- [ ] Shimmer visible but subtle near ores
- [ ] No shimmer on blocks not adjacent to ore
- [ ] Effect doesn't make finding ore trivial
- [ ] Performance acceptable with many blocks
- [ ] Spelunker upgrade makes effect stronger
