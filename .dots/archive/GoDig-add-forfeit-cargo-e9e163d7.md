---
title: "Add 'Forfeit Cargo' quick escape option"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-01T00:40:14.285294-06:00\\\"\""
closed-at: "2026-02-02T02:50:23.513495-06:00"
close-reason: "Implemented Forfeit Cargo escape option: lose ore/gems but keep ladders/tools, with confirmation dialog and auto-save"
---

## Context
Current recovery options are too extreme:
- Emergency Rescue: Lose EVERYTHING (too harsh)
- Reload Save: Lose time progress (feels like cheating)

Need a middle-ground for "stuck without ladders" scenario.

## Design
New pause menu option: **"Forfeit Cargo & Escape"**

**What you LOSE:**
- All ORE items (coal, copper, iron, etc.)
- All GEM items (ruby, diamond, etc.)

**What you KEEP:**
- Ladders, ropes, torches (traversal items)
- Tools and equipment
- Coins already earned

**Behavior:**
- Returns player to surface instantly
- No HP penalty
- Auto-saves after

## Implementation
1. Add `clear_cargo()` to InventoryManager - removes items where category == "ore" or "gem"
2. Add button to pause_menu.gd between Resume and Emergency Rescue
3. Add confirmation dialog: "You will lose all ore and gems. Keep ladders and tools."
4. Emit signal, teleport player to surface

## Files
- scripts/ui/pause_menu.gd (new button + confirmation)
- scripts/autoload/inventory_manager.gd (clear_cargo function)

## Acceptance Criteria
- [ ] Button appears in pause menu
- [ ] Confirmation dialog explains what's lost/kept
- [ ] Only ore/gem items removed
- [ ] Ladders, ropes, tools preserved
- [ ] Player teleported to surface
- [ ] Game auto-saves after
