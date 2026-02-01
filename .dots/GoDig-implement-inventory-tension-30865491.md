---
title: "implement: Inventory tension visual system"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T02:17:14.450750-06:00"
---

## Description
Add graduated visual feedback to inventory HUD as it fills up, communicating risk level to player.

## Context
Research shows pressure should BEGIN at 50-60% inventory, not when nearly full. The visual system should create a 'tension runway' that builds gradually.

## Affected Files
- `scripts/ui/hud.gd` - Add inventory fill percentage tracking and color transitions
- `scenes/ui/hud.tscn` - Update inventory display styling

## Implementation Notes
### Color Thresholds
- 0-50%: Green (safe, keep mining)
- 50-75%: Yellow (awareness, 'making good progress')
- 75-90%: Orange (active tension, 'should I head back?')
- 90-100%: Red (crisis, 'must return now')

### Visual Effects
- At 60%+: Backpack icon pulses once per transition
- At 75%+: Single subtle audio cue, bar turns yellow
- At 90%+: Inventory bar shows 'strain' effect (wobble or pressure animation)
- At 100%: Red bar, 'FULL' text appears, stronger audio cue

### Technical Approach
1. Track inventory fill percentage (current slots / max slots)
2. Use shader or tween for color transitions (not abrupt)
3. Optional: Add subtle glow or outline that intensifies with fill level
4. Pulse animation should be quick (0.3s) and not annoying

## Verify
- [ ] Green color shows when inventory <50%
- [ ] Yellow transition visible at 50% fill
- [ ] Orange transition visible at 75% fill
- [ ] Red + FULL text at 100% fill
- [ ] Pulse animation plays on threshold transitions
- [ ] Transitions are smooth, not jarring
- [ ] Does not block or distract from gameplay
