---
title: "implement: New game initialization"
status: closed
priority: 1
issue-type: task
created-at: "\"2026-01-16T00:47:36.553477-06:00\""
closed-at: "2026-01-19T12:04:56.390066-06:00"
close-reason: Functionality distributed across main_menu.gd (triggers new_game), SaveManager.new_game() (creates save), and test_level._ready() (starts game). All requirements met.
---

## Description

Initialize a new game with fresh save data, default values, world seed generation, and player starting equipment.

## Context

When player selects "New Game" from the menu, all state must be reset and initialized properly. This sets up the foundation for a fresh play session.

## Affected Files

- `scripts/autoload/game_manager.gd` - Add start_new_game() method
- `scripts/autoload/save_manager.gd` - Create fresh save
- `scripts/autoload/inventory_manager.gd` - Clear and initialize starter items
- `scripts/autoload/player_data.gd` - Reset player stats

## Implementation Notes

### GameManager.start_new_game()
```gdscript
# game_manager.gd
func start_new_game() -> void:
    print("[GameManager] Starting new game...")

    # 1. Generate world seed
    var seed_value := _generate_world_seed()
    world_seed = seed_value

    # 2. Reset game state
    is_running = true
    current_depth = 0
    coins = 0
    reset_milestones()

    # 3. Initialize player data
    PlayerData.reset_to_defaults()
    PlayerData.set_equipped_tool("basic_pickaxe")

    # 4. Clear inventory and add starter items
    InventoryManager.clear_all()
    InventoryManager.add_item_by_id("basic_pickaxe", 1)
    # Optional starter ladder: InventoryManager.add_item_by_id("ladder", 3)

    # 5. Create fresh save file
    SaveManager.create_new_save()

    # 6. Emit signal
    game_started.emit()

    print("[GameManager] New game initialized with seed: %d" % seed_value)


func _generate_world_seed() -> int:
    # Use system time for randomness
    var rng := RandomNumberGenerator.new()
    rng.randomize()
    return rng.randi()
```

### PlayerData.reset_to_defaults()
```gdscript
# player_data.gd
func reset_to_defaults() -> void:
    equipped_tool = "basic_pickaxe"
    max_hp = 100
    current_hp = 100
    tool_durability = 1.0
    # ... other defaults
```

### SaveManager.create_new_save()
```gdscript
# save_manager.gd
func create_new_save() -> void:
    var save_data := SaveData.new()
    save_data.world_seed = GameManager.world_seed
    save_data.coins = 0
    save_data.current_depth = 0
    save_data.player_position = _get_surface_spawn_position()
    save_data.inventory = {}
    save_data.equipped_tool = "basic_pickaxe"
    save_data.created_at = Time.get_unix_time_from_system()
    save_data.play_time = 0.0

    _current_save = save_data
    save_game()  # Write to disk
```

### Starter Equipment
- **Basic Pickaxe**: Default tool, 10 damage, infinite durability for MVP
- **Optional**: 3 ladders for early traversal help

### Surface Spawn Position
```gdscript
func _get_surface_spawn_position() -> Vector2:
    # Center of grid, at surface row
    var x := (GameManager.GRID_WIDTH / 2) * GameManager.BLOCK_SIZE + GameManager.GRID_OFFSET_X
    var y := (GameManager.SURFACE_ROW - 1) * GameManager.BLOCK_SIZE  # One row above first dirt
    return Vector2(x, y)
```

## Edge Cases

- Existing save overwrite: Prompt user to confirm or create slot system
- Mid-game new game: Ensure all state properly reset
- Seed collision: Extremely unlikely, not a concern

## Verify

- [ ] Build succeeds
- [ ] start_new_game() resets coins to 0
- [ ] start_new_game() resets depth to 0
- [ ] World seed is generated and stored
- [ ] PlayerData reset to defaults
- [ ] Inventory cleared and starter pickaxe added
- [ ] Save file created on disk
- [ ] Player spawns at surface position
- [ ] Game transitions to playing state
