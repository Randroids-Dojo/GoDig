---
title: "implement: Ladder placement decision feedback"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T08:04:02.423611-06:00"
---

Add subtle feedback when placing ladders to reinforce the risk/reward decision-making.

## Description

Each ladder placement is a strategic decision. The game should subtly acknowledge this through visual/audio feedback that reinforces the player is building their escape infrastructure.

## Context

From Session 9 research (Spelunky Analysis):
- 'Spelunky is a game about information and decision-making'
- Every micro-decision has risk/reward calculation
- Our ladder system creates similar meaningful decisions
- Players should feel clever when they build good escape routes

Unlike Spelunky's time pressure, GoDig uses resource pressure (ladder count). Each placement is a commitment - you can't get it back.

## Implementation

### Placement Feedback

When player places a ladder:
1. **Sound**: Satisfying 'thunk' sound (wood against stone)
2. **Visual**: Brief dust particles at placement
3. **HUD pulse**: Ladder count briefly flashes as it decreases
4. **Audio pitch variation**: Higher pitch when ladder count is high (confident), lower pitch when count is low (tension)

### Ladder Count Awareness

As ladder count decreases:
- 5+ ladders: Green count, confident sound
- 3-4 ladders: Yellow count, neutral sound  
- 1-2 ladders: Orange count, slightly concerned sound
- 0 ladders: Red, no more available (already covered in low ladder warning spec)

### Escape Route Visualization (Optional Enhancement)

When player places a ladder adjacent to existing ladder:
- Brief 'connection' effect (line pulse upward)
- Reinforces they're building a route HOME
- Creates ownership: 'I made this path'

## Affected Files

- scripts/items/ladder.gd - Placement effects
- scripts/ui/hud.gd - Ladder count color coding
- audio/sfx/ladder_place_*.ogg - Sound variations

## Verify

- [ ] Placing ladder plays satisfying sound
- [ ] Dust particles appear briefly
- [ ] Ladder count flashes on HUD
- [ ] Sound pitch varies with remaining count
- [ ] Color coding reflects resource scarcity
- [ ] Connected ladders show brief route pulse (optional)
- [ ] Feedback is subtle, not distracting from gameplay

## Why P2

This is polish that reinforces the core mechanic. The core loop works without it, but this makes the experience feel more intentional and strategic.
