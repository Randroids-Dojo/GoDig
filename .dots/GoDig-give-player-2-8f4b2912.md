---
title: Give player 5 starting ladders in new game
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T00:40:04.032000-06:00"
---

## Context
New players don't understand they need ladders until they're stuck.
Starting with enough ladders teaches the mechanic and enables a comfortable first dive.

**This is a P1 for fun factor**: First-time players WILL get stuck without ladders. Having 5 starting ladders:
1. Teaches the mechanic by having it available
2. Provides safety net for first dive (can reach 25m+ comfortably)
3. Creates "aha!" moment when they use one
4. Allows first trip to be profitable (not break-even)

## Research Insights (Session 3 Ladder Economy)
- SteamWorld Dig: Players who fell into holes initially panicked, then discovered clever escape routes
- Economy modeling: 3 ladders = break-even first trip, 5 ladders = profitable first trip
- First upgrade (Copper Pickaxe 500 coins) should be achievable in 2-3 trips
- With wall-jumping, 5 ladders reaches 25-30m safely

## Implementation
1. In `save_manager.gd`, modify new_game() function
2. After initializing inventory, add starting items:
   ```gdscript
   # Give player starting supplies
   var ladder_item = DataRegistry.get_item("ladder")
   if ladder_item:
       InventoryManager.add_item(ladder_item, 5)  # 5 ladders, not 3
   ```

## Files
- scripts/autoload/save_manager.gd (new_game function)

## Verify
- [ ] New game starts with 5 ladders in inventory
- [ ] HUD shows ladder count (5) immediately
- [ ] Ladders work when placed
- [ ] Tutorial hint suggests trying to place a ladder
- [ ] Existing saves not affected (only new games)
- [ ] First dive with 5 ladders reaches ~25m comfortably
