---
title: "DEV: Save/Load System"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T00:30:41.467439-06:00"
---

Epic for persistence and save game implementation.

## Status

**CORE IMPLEMENTATION COMPLETE**

Completed subtasks:
- [x] GoDig-dev-player-state-610929b3: Player state persistence (position, coins, inventory)
- [x] GoDig-dev-world-state-a4e2fccc: World state persistence (chunk modifications)
- [x] GoDig-dev-auto-save-35a35d40: Auto-save system (60s interval, milestones, app pause)

## Implemented in SaveManager

`scripts/autoload/save_manager.gd` provides:
- 3 save slots with slot selection support
- Auto-save every 60 seconds (configurable)
- Mobile lifecycle handling (save on pause/background/close)
- Chunk persistence with binary files and compression
- Player position, coins, inventory, depth tracking
- Save version migration support
- Debounce to prevent rapid save spam (5s minimum between saves)

## Remaining Work

- [ ] UI for save slot selection (if not using single-slot auto-save)
- [ ] Error recovery UI for failed loads
- [ ] SaveManager integration tests
