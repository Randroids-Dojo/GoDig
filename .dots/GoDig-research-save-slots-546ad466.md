---
title: "research: Save slots and autosave"
status: done
priority: 0
issue-type: task
created-at: "2026-01-18T23:39:36.992317-06:00"
---

How does the save system work? Questions: How many save slots? (3 recommended) When does autosave trigger? (depth milestone, time interval, on surface?) What gets saved? (position, inventory, coins, world state, unlocks) How is chunk modification persisted? What's the save file format? How does 'Continue' vs 'New Game' work?

## Research Findings (Verified 2026-01-19)

### Current Implementation Status: COMPLETE

Save system is fully implemented in `scripts/autoload/save_manager.gd` and `resources/save/save_data.gd`.

### Answer to Research Questions

**1. How many save slots?**
- `MAX_SLOTS = 3` slots (slot 0, 1, 2)
- File pattern: `user://saves/slot_0.tres`, etc.

**2. When does autosave trigger?**
- Time interval: `AUTO_SAVE_INTERVAL = 60.0` seconds
- App pause/background (mobile): `NOTIFICATION_APPLICATION_PAUSED`
- Focus loss (desktop): `NOTIFICATION_APPLICATION_FOCUS_OUT`
- Window close: `NOTIFICATION_WM_CLOSE_REQUEST`
- Shop transactions: After each sell/upgrade
- Debounce: `MIN_SAVE_INTERVAL_MS = 5000` (5 seconds minimum between saves)

**3. What gets saved?**

**SaveData Resource fields:**
- `player_grid_position: Vector2i` - Grid coordinates
- `current_depth: int` - Current depth
- `coins: int` - Current coins
- `lifetime_coins: int` - Total coins earned
- `inventory: Dictionary` - {item_id: quantity}
- `max_slots: int` - Inventory capacity
- `equipped_tool: String` - Tool ID
- `max_depth_reached: int` - Deepest depth
- `depth_milestones_reached: Array[int]` - Milestone list
- `tools_unlocked: Array[String]` - Unlocked tool IDs
- `achievements: Array[String]` - Achievement IDs
- `buildings_unlocked: Array[String]` - Building IDs
- `world_seed: int` - Terrain generation seed
- `blocks_mined: int` - Stat tracking
- `ores_collected: int` - Stat tracking
- `deaths: int` - Stat tracking
- `total_playtime: float` - Seconds played
- `last_save_time: int` - Unix timestamp
- `save_version: int` - For migrations

**4. How is chunk modification persisted?**
- Separate binary files: `user://chunks/slot_0/chunk_X_Y.dat`
- Uses `file.store_var(modified_tiles, true)` with compression
- Interface methods: `save_chunk()`, `load_chunk()`, `has_modified_chunk()`
- Cleared when save slot is deleted

**5. What's the save file format?**
- SaveData is a Godot Resource (.tres format)
- Uses `ResourceSaver.save()` and `ResourceLoader.load()`
- Chunk data is binary dictionary with compression

**6. How does 'Continue' vs 'New Game' work?**

**Continue:**
```gdscript
func load_game(slot: int) -> bool:
    # Load SaveData resource
    # Apply state to GameManager, InventoryManager
    # Emit signals: load_started, load_completed, save_slot_changed
```

**New Game:**
```gdscript
func new_game(slot: int, slot_name: String = "") -> bool:
    # Delete existing save and chunks
    # Create fresh SaveData via create_new()
    # Generate new world_seed
    # Save immediately
```

### SaveManager Signals

- `save_started` - Before save begins
- `save_completed(success: bool)` - After save attempt
- `load_started` - Before load begins
- `load_completed(success: bool)` - After load attempt
- `save_slot_changed(slot: int)` - When active slot changes
- `auto_save_triggered` - When auto-save fires

### Version Migration

- `save_version` field tracks format version
- `_migrate_if_needed()` called on load
- Currently at `CURRENT_VERSION = 1`

### Convenience Methods

- `is_game_loaded()` - Check if game is active
- `get_world_seed()` - Get terrain seed
- `get_player_position()` - Get spawn position
- `set_player_position()` - Update position on move
- `get_seconds_since_last_save()` - For UI display
- `get_time_since_save_text()` - Human-readable time

### No Further Work Needed

Save system is complete and fully functional.
