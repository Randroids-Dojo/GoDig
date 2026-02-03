---
title: "implement: GameManager integration tests"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"2026-02-03T11:12:25.568696-06:00\\\"\""
closed-at: "2026-02-03T11:14:30.066779-06:00"
close-reason: Created test_game_manager.py with 73 comprehensive tests. Version bumped to 0.59.31.
---

Create comprehensive integration tests for GameManager autoload covering:
- Singleton existence
- Grid constants (BLOCK_SIZE, SURFACE_ROW, VIEWPORT dimensions)
- State management (GameState enum, set_state, is_playing)
- Depth tracking (update_depth, milestones, max_depth)
- Coin system (add_coins, spend_coins, can_afford)
- Tutorial system (advance_tutorial, complete_tutorial)
- Building unlocks (BUILDING_UNLOCK_ORDER, is_building_unlocked)
- Player registration
- Save/load helpers (get/set functions)
- Scene paths constants
