---
title: "implement: Ladder checkpoint rescue system (Cairn-inspired)"
status: open
priority: 2
issue-type: task
created-at: "2026-02-02T18:54:53.734240-06:00"
---

## Purpose
Implement an advanced rescue system where emergency rescue returns player to their highest placed ladder, not the surface.

## Background
From Cairn analysis (Session 32):
- Falls reset to last piton, NOT start - proportional progress loss
- Creates layered safety net: pitons = first checkpoint, camp = final safety
- Indestructible pitons are 'game-changers for long climbs' - reduce mental load

## Proposed Mechanic
1. Player places ladders during descent (existing mechanic)
2. If player triggers emergency rescue:
   - Find player's HIGHEST placed ladder position
   - Teleport player to that ladder (not surface)
   - Apply 60% cargo retention (Loop Hero model)
3. Player can then:
   - Continue climbing down from that position
   - Climb back up to surface with remaining cargo
   - Use another rescue if needed (costs more)

## Benefits
- Ladders become strategic checkpoints, not just traversal
- Reduces punishment for deep exploration
- Creates 'insurance' value for ladder placement
- Aligns with Cairn's proven checkpoint design

## Alternative: Return to Surface
If too complex, simpler model:
- Rescue always returns to surface
- 60% cargo kept
- Ladders remain placed underground
- Player can return to where they were

## Verify
- [ ] Rescue correctly identifies highest placed ladder
- [ ] Player teleports to ladder position safely
- [ ] 60% cargo retention applied correctly
- [ ] UI clearly shows rescue will return to ladder (not surface)

## Sources
- Cairn piton checkpoint analysis (Session 32)
- Loop Hero retreat mechanic (Session 31)
