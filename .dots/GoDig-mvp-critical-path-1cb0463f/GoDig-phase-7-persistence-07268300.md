---
title: "research: Persistence"
status: closed
priority: 0
issue-type: task
created-at: "\"\\\"2026-01-16T00:41:41.456846-06:00\\\"\""
closed-at: "2026-01-19T10:11:49.437212-06:00"
close-reason: Persistence fully implemented - SaveManager, SaveData, chunk persistence, auto-save
---

Save player state, save chunk modifications, auto-save system.

## Research Findings

### Fully Implemented

The persistence system is **complete**:

1. **SaveManager** (`scripts/autoload/save_manager.gd`)
   - 3 save slots with new/load/delete operations
   - Auto-save every 60 seconds (configurable)
   - Emergency save on app pause/background (mobile)
   - Save debouncing (5s minimum between saves)
   - Signals: save_started, save_completed, load_started, load_completed

2. **SaveData Resource** (`resources/save/save_data.gd`)
   - Version tracking for migrations (CURRENT_VERSION = 1)
   - Player state: position, depth, coins, equipped_tool
   - Inventory: Dictionary[item_id, quantity]
   - Progression: max_depth_reached, milestones, achievements
   - Statistics: blocks_mined, ores_collected, deaths, playtime
   - World seed for reproducible terrain

3. **Chunk Persistence**
   - Binary files in `user://chunks/slot_N/chunk_X_Y.dat`
   - Compressed storage with store_var()
   - Only modified chunks are saved
   - Auto-cleanup when slot deleted

4. **Integration**
   - GameManager: coins, depth, milestones
   - InventoryManager: items and slot count
   - Auto-save on depth milestones
   - Auto-save on shop transactions

### Auto-Save Triggers

1. Time-based: Every 60 seconds
2. Depth milestones: 10, 25, 50, 100, 150, 200, 300, 500, 750, 1000m
3. Shop transactions (sell/buy)
4. App pause/background (mobile)
5. Window close (desktop)

### Related Implementation Tasks

Most persistence specs can be closed as already implemented:
- GoDig-dev-auto-save-35a35d40: Implemented in SaveManager
- GoDig-dev-player-state-610929b3: Implemented in SaveData
- GoDig-dev-world-state-a4e2fccc: Chunk persistence implemented
- GoDig-dev-chunk-persistence-547befe4: Binary chunk files implemented

### Remaining Gaps

- Main menu integration (new game/continue buttons)
- Save slot selection UI
- Player position saving needs dirt_grid integration
