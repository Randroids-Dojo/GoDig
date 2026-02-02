---
title: "implement: Depth-based ore value multiplier"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"2026-02-01T09:31:39.957344-06:00\\\"\""
closed-at: "2026-02-01T23:10:55.063291-06:00"
close-reason: Implemented depth-based ore value multiplier with dive depth tracking
---

## Description
Deeper ores should be worth more coins to create proper risk/reward scaling. This reinforces the push-your-luck mechanic - going deeper is riskier (more ladders needed, harder to escape) but more rewarding.

## Context
From Session 21 research on push-your-luck mathematical balance:
- Risk and reward must BOTH increase during turn duration
- Beginning: low risk, low reward - most continue
- Middle: moderate risk, greater reward - should be rewarded for stopping
- End: high risk, highest reward - only for committed players

Currently ore values are flat regardless of depth. This means shallow mining is optimal (lowest risk, same reward).

## Implementation
1. Add depth_multiplier to ore sell calculations
2. Suggested formula: base_value * (1 + depth/100) where depth is in blocks
3. At 50 blocks deep: 1.5x value
4. At 100 blocks deep: 2x value
5. Display multiplier in inventory/HUD when underground

## Affected Files
- scripts/autoload/game_manager.gd - sell calculation
- scripts/ui/hud.gd - display current depth multiplier
- resources/items/*.tres - base ore values

## Verify
- [ ] Ore sells for more at deeper depths
- [ ] Multiplier visible to player
- [ ] Shallow mining feels less rewarding than deep dives
- [ ] Risk/reward feels balanced
