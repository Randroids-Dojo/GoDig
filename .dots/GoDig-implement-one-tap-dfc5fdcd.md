---
title: "implement: One-tap ladder placement from HUD"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T02:09:15.321456-06:00"
---

## Description
Allow placing ladders with a single tap on the HUD quick-slot, without opening inventory.

## Context
Research: 'Interface inefficiency' is a common complaint. Every action should be ONE tap. Current ladder placement requires opening inventory, selecting ladder, placing - too many steps during tense moments.

## Implementation
1. HUD shows ladder icon with count (e.g., ladder icon + 'x5')
2. When tapped:
   - Places ladder at player's current position
   - Decrements count immediately
   - Brief visual confirmation (ladder 'drops' into place)
3. Button disabled when:
   - Already a ladder at current position
   - No ladders in inventory
   - Player is falling
4. Long-press: opens inventory to ladder item (for selling, etc.)

## Affected Files
- scripts/ui/hud.gd - Tap handler for ladder slot
- scripts/world/dirt_grid.gd - place_ladder_at(pos) method
- scripts/autoload/inventory_manager.gd - consume ladder

## Verify
- [ ] Single tap places ladder
- [ ] Count decrements immediately
- [ ] Works while standing, climbing
- [ ] Disabled while falling
- [ ] Long-press opens inventory
- [ ] Sound effect plays on placement
