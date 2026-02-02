---
title: "implement: Depth-aware ladder warning system"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"2026-02-01T02:17:27.356323-06:00\\\"\""
closed-at: "2026-02-02T00:36:21.249581-06:00"
close-reason: "Updated ladder warning to use depth-based formula: safe_ladders = ceil(depth/5). Yellow at 80%, red at 50% of safe minimum. Scales to any depth."
---

## Description
Warn players when their ladder count is dangerously low for their current depth, preventing frustrating stuck situations.

## Context
Core tension in mining games comes from the risk/reward of going deeper. Research shows pressure should build through information, not surprise punishment. Players should always know their risk level.

## Affected Files
- `scripts/ui/hud.gd` - Add ladder warning logic and display
- `scripts/autoload/game_manager.gd` - May need signal for depth changes

## Implementation Notes
### Ladder Safety Calculation
Formula: `safe_ladders = ceil(current_depth / 5)` (approximately 1 ladder per 5m of depth)

This accounts for:
- Wall-jumping covering ~3-5 tiles between ladder placements
- Some horizontal movement (not straight down)
- Buffer for finding exit routes

### Warning Thresholds
| Depth | Safe Minimum | Yellow Warning | Red Warning |
|-------|--------------|----------------|-------------|
| 25m | 5 ladders | <4 ladders | <2 ladders |
| 50m | 10 ladders | <8 ladders | <5 ladders |
| 100m | 20 ladders | <15 ladders | <10 ladders |

### Visual Implementation
- Normal: Ladder count in default color
- Yellow: Subtle pulse on ladder icon, count turns yellow
- Red: More urgent pulse, count turns red, optional warning text

### Warning Messages (Optional Tooltip/Flash)
- Yellow: 'Getting deep. Check your ladders.'
- Red: 'Low on ladders! Consider returning.'

### When to Trigger
- Recalculate on: depth change, ladder placement, ladder pickup
- Only show warning when BELOW safe threshold (not constantly)
- Clear warning when player returns to safe depth/ladder ratio

## Verify
- [ ] No warning when ladder count >= safe minimum for depth
- [ ] Yellow warning triggers at correct threshold
- [ ] Red warning triggers at critical threshold
- [ ] Warning clears when ratio improves
- [ ] Warning recalculates on depth change
- [ ] Warning recalculates on ladder count change
- [ ] Pulse animation visible but not annoying
