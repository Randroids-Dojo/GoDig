---
title: "research: Spec implementation status audit"
status: closed
priority: 1
issue-type: task
created-at: "\"2026-02-01T08:48:40.996718-06:00\""
closed-at: "2026-02-01T09:26:31.210729-06:00"
close-reason: "Audit complete: identified supply store unlock + starting ladders as P0 blockers, found 3 sets of duplicate specs to merge"
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

## Session 20 Code Audit Findings

### Supply Store Unlock Depth Inconsistency - CONFIRMED

**game_manager.gd line 422:**
```
{"id": "supply_store", "name": "Supply Store", "unlock_depth": 0},
```

**surface.gd line 17:**
```
{"x": 512, "unlock_depth": 100, "type": "supply_store", "name": "Supply Store"},
```

**Recommendation**: surface.gd controls actual building placement. Spec `GoDig-move-supply-store-61eb95a1` correctly identifies this needs alignment to 0m for early ladder access.

### Starting Ladders - NOT IMPLEMENTED

**save_manager.gd new_game() function (lines 237-273):**
- Resets InventoryManager, PlayerData, PlayerStats, etc.
- Does NOT call `InventoryManager.add_item_by_id("ladder", 5)` or similar
- ladder.tres EXISTS at `resources/items/ladder.tres`

**Recommendation**: Spec `GoDig-give-player-2-8f4b2912` is NOT implemented. Simple fix in new_game().

### Duplicate Specs Identified

1. **Sell Animation** - Two specs overlap:
   - `GoDig-implement-sell-animation-58af35a8` (P2)
   - `GoDig-implement-satisfying-sell-150bde42` (P1)
   Both describe coin cascade. Should consolidate.

2. **Surface Home Base** - Multiple specs:
   - `GoDig-implement-surface-home-81016105`
   - `GoDig-implement-surface-home-6963fed9`
   - `GoDig-implement-surface-cozy-e7e78188`
   These overlap. Should consolidate.

3. **Safe Return Celebration** - Two specs:
   - `GoDig-implement-safe-return-a8427f4a`
   - `GoDig-implement-safe-return-6aad4c11`
   Identical titles. Duplicates.

### Core Systems Exist (Enhancement Needed)

- `haptic_feedback.gd` - System exists, needs polish per spec
- `milestone_notification.gd` - Notification system exists
- `block_particles.gd` - Particle effects exist
- `ore_sparkle.gd` - Ore discovery effects exist
- `floating_text.gd` - Text feedback exists
- `tutorial_overlay.gd` - Tutorial system exists

## Action Items

1. **Immediate P0 blockers**:
   - Implement starting ladders in new_game()
   - Align supply_store unlock_depth to 0m

2. **Cleanup duplicate specs**:
   - Merge sell animation specs
   - Merge surface home specs
   - Merge safe return specs

3. **Enhancement specs** (foundations exist):
   - Haptic patterns need definition
   - Particle variety needs expansion
   - Tutorial needs FTUE flow

## Status

Research complete. Key blockers identified.
