---
title: "implement: Retreat percentage rescue system (Loop Hero model)"
status: open
priority: 1
issue-type: task
created-at: "2026-02-02T18:50:43.498194-06:00"
---

## Purpose
Implement emergency rescue as a tiered cargo retention system based on Loop Hero's proven design.

## Loop Hero Model
- Camp return (surface) = 100% cargo kept
- Retreat (emergency rescue) = 60% cargo kept  
- Death/failure = 30% cargo kept

## Design Goals
1. Make rescue feel like a VALID STRATEGY, not punishment
2. Create meaningful risk/reward decisions
3. Player blame themselves for not retreating, not the game

## Implementation
- When player triggers emergency rescue, keep 60% of current inventory
- Show clearly what percentage will be lost BEFORE confirming
- Frame as 'Emergency Evacuation Fee' not punishment
- Deeper depth = same percentage (don't punish exploration)

## Verify
- [ ] Emergency rescue keeps exactly 60% of inventory (rounded up)
- [ ] Pre-rescue confirmation shows what will be lost
- [ ] Players understand rescue is a choice, not failure

## Sources
Loop Hero retreat mechanic analysis - Session 31
