---
title: "implement: Near-miss ore hints"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T01:20:15.573945-06:00"
---

## Description
Add visual 'shimmer' or 'glint' hints to blocks adjacent to ore veins, creating anticipation and near-miss psychology.

## Context
Research shows near-misses can be MORE motivating than wins. Currently, blocks either have ore or don't - no 'almost found it' feeling. Adding subtle visual hints for blocks NEAR ore veins creates anticipation and reward for pattern recognition.

## Implementation
1. In `dirt_grid.gd` `_place_ore_at()`, also mark adjacent non-ore blocks as 'near ore'
2. Create new subtle visual effect (dimmer sparkle or color tint) for near-ore blocks
3. Effect should be subtle enough to feel like discovery, not a treasure map
4. Consider depth scaling - more obvious hints early game, subtler as player learns

## Affected Files
- `scripts/world/dirt_grid.gd` - Add near-ore tracking and adjacency check
- `scenes/effects/near_ore_hint.tscn` - New subtle effect scene
- `scripts/effects/near_ore_hint.gd` - Simple shimmer effect (less frequent than ore sparkle)

## Verify
- [ ] Near-ore blocks show subtle shimmer
- [ ] Effect is less prominent than actual ore sparkle
- [ ] Mining near-ore block creates 'getting warmer' feeling
- [ ] Performance: minimal overhead from adjacency checks
