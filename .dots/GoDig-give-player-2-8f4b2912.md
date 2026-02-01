---
title: Give player 2-3 starting ladders in new game
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T00:40:04.032000-06:00"
---

## Context
New players don't understand they need ladders until they're stuck.
Starting with a few teaches the mechanic early.

**This is a P1 for fun factor**: First-time players WILL get stuck without ladders. Having 2-3 starting ladders:
1. Teaches the mechanic by having it available
2. Provides safety net for first dive
3. Creates "aha!" moment when they use one

## Research Insights
- SteamWorld Dig: Players who fell into holes initially panicked, then discovered clever escape routes
- The goal: transform "stuck" from failure to learning opportunity
- Starting items let players experiment safely

## Implementation
1. In `save_manager.gd`, modify new_game() function
2. After initializing inventory, add starting items:
   ```gdscript
   # Give player starting supplies
   var ladder_item = DataRegistry.get_item("ladder")
   if ladder_item:
       InventoryManager.add_item(ladder_item, 3)
   ```

## Files
- scripts/autoload/save_manager.gd (new_game function)

## Verify
- [ ] New game starts with 3 ladders in inventory
- [ ] HUD shows ladder count (3) immediately
- [ ] Ladders work when placed
- [ ] Tutorial hint suggests trying to place a ladder
- [ ] Existing saves not affected (only new games)
