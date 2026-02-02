---
title: "implement: Return-to-surface tension indicator"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-02-01T01:08:48.725086-06:00\""
closed-at: "2026-02-02T09:53:37.156065-06:00"
close-reason: Partially implemented (ladder warnings in HUD), remaining covered by inventory-tension-30865491
---

Add visual/audio tension as inventory fills - drives the core loop return.

**NOTE: This is a SIMPLER alternative to `GoDig-implement-deep-dive-2e1f97dc` (unified tension meter).**
Implement this first for MVP, then upgrade to unified meter later.

## Research Findings
- 'Investment Protection' - full inventory creates natural tension
- Dome Keeper: 'panicked adrenaline' when timing returns
- Inventory at 80% should trigger warning (existing design doc)
- Creates 'just fill inventory then stop' natural stopping point

## Implementation
1. At 60% full: subtle UI glow on inventory icon
2. At 80% full: warning chime + icon pulse + 'Almost Full!' toast
3. At 100% full: urgent pulse + 'INVENTORY FULL' prominent display
4. Optional: slight music tension shift as inventory fills
5. HUD depth indicator becomes more prominent as depth increases

## Files
- scripts/ui/hud.gd (inventory warning states)
- scripts/autoload/inventory_manager.gd (emit fill percentage)
- scripts/autoload/sound_manager.gd (warning sounds)

## Verify
- [ ] Visual change at 60% inventory
- [ ] Audio warning at 80% inventory
- [ ] Urgent state at 100% inventory
- [ ] Warnings don't feel annoying (tuned appropriately)
