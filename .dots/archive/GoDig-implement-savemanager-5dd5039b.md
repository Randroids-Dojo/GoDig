---
title: "implement: SaveManager integration tests"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"2026-02-03T11:14:45.225945-06:00\\\"\""
closed-at: "2026-02-03T11:16:26.300911-06:00"
close-reason: Created test_save_manager.py with 59 comprehensive tests. Version bumped to 0.59.32.
---

Create comprehensive integration tests for SaveManager autoload covering:
- Singleton existence
- Constants (SAVE_DIR, CHUNKS_DIR, MAX_SLOTS, AUTO_SAVE_INTERVAL)
- Slot management (has_save, get_save_path, get_all_slot_summaries)
- Load/save state properties (current_slot, auto_save_enabled, is_game_loaded)
- Error tracking properties
- Offline income methods
- FTUE tracking methods
- First upgrade tracking methods
- Backup/recovery methods
- Chunk persistence methods
- All signals
