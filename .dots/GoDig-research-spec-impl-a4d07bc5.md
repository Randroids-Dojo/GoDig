---
title: "research: Spec implementation status audit"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T08:48:40.996718-06:00"
---

## Purpose

Audit existing implementation specs to identify:
1. Which P0/P1 specs are NOT YET implemented in code
2. Inconsistencies between specs and actual code
3. Duplicate/overlapping specs that should be consolidated

## Findings from Code Review

### Supply Store Unlock Inconsistency
- game_manager.gd line 422: unlock_depth = 0
- surface.gd line 17: unlock_depth = 100
**Action**: surface.gd needs to be updated to match game_manager.gd

### Starting Ladders Not Implemented
- save_manager.gd new_game() function does NOT give starting ladders
- Spec GoDig-give-player-2-8f4b2912 describes the implementation needed
**Action**: Implement starting ladder provision in new_game()

### Duplicate Sell Animation Specs
- GoDig-implement-sell-animation-58af35a8 (P2)
- GoDig-implement-satisfying-sell-150bde42 (P1, supplements above)
**Action**: Consider merging or marking one as 'superseded'

## Verification Steps
- [ ] Check all P0 specs against actual code
- [ ] Check all P1 specs against actual code
- [ ] Identify specs that are already implemented
- [ ] Mark implemented specs as done
- [ ] Flag inconsistencies for implementor

## Why This Matters
Implementors should know exactly what needs building vs what exists. Specs that describe already-implemented features waste time.
