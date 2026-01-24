---
title: "implement: Continue game (load save)"
status: closed
priority: 1
issue-type: task
created-at: "\"2026-01-16T00:47:37.930451-06:00\""
closed-at: "2026-01-24T21:19:56.267615+00:00"
close-reason: SaveManager.load_game() handles continue game with full state restoration
---

## Description

Load an existing save file and restore all game state including player position, inventory, coins, progress, and world modifications.

## Context

When player selects "Continue" from the menu, the game should resume exactly where they left off. All progress must be accurately restored.

## Affected Files

- `scripts/autoload/save_manager.gd` - Load save data from disk
- `scripts/autoload/game_manager.gd` - Restore game state
- `scripts/autoload/inventory_manager.gd` - Restore inventory
- `scripts/autoload/player_data.gd` - Restore player stats
- `scripts/world/dirt_grid.gd` - Regenerate chunks around saved position

## Implementation Notes

### SaveManager.load_game()
```gdscript
# save_manager.gd
func load_game() -> bool:
    if not has_save():
        push_warning("[SaveManager] No save file found")
        return false

    var save_data := _load_from_disk()
    if save_data == null:
        push_error("[SaveManager] Failed to load save file")
        return false

    _current_save = save_data

    # 1. Restore world seed
    GameManager.world_seed = save_data.world_seed

    # 2. Restore game state
    GameManager.set_coins(save_data.coins)
    GameManager.current_depth = save_data.current_depth
    GameManager.set_reached_milestones(save_data.reached_milestones)

    # 3. Restore player data
    PlayerData.set_equipped_tool(save_data.equipped_tool)
    PlayerData.tool_durability = save_data.tool_durability
    PlayerData.max_hp = save_data.max_hp
    PlayerData.current_hp = save_data.current_hp

    # 4. Restore inventory
    InventoryManager.load_from_dict(save_data.inventory)

    # 5. Store position for player to use after scene load
    _pending_player_position = save_data.player_position

    print("[SaveManager] Game loaded successfully")
    return true


func get_pending_player_position() -> Vector2:
    var pos := _pending_player_position
    _pending_player_position = Vector2.ZERO  # Clear after use
    return pos
```

### GameManager.continue_game()
```gdscript
# game_manager.gd (alternative entry point)
func continue_game() -> void:
    var success := SaveManager.load_game()
    if not success:
        push_error("[GameManager] Failed to continue game")
        return

    is_running = true
    game_started.emit()
```

### Player Position Restoration
```gdscript
# In main.gd or test_level.gd after scene load
func _ready() -> void:
    # Check if continuing from save
    var saved_position := SaveManager.get_pending_player_position()
    if saved_position != Vector2.ZERO:
        player.position = saved_position
        player.grid_position = GameManager.world_to_grid(saved_position)
    else:
        # New game: spawn at surface
        player.position = _get_surface_spawn_position()
```

### Chunk Regeneration
```gdscript
# dirt_grid.gd
func restore_for_saved_position(player_position: Vector2) -> void:
    # Clear any existing chunks
    _clear_all_chunks()

    # Calculate player's row
    var player_row := int(player_position.y / BLOCK_SIZE)

    # Generate chunks around player
    for row in range(player_row - ROWS_BEHIND, player_row + ROWS_AHEAD):
        if row >= GameManager.SURFACE_ROW:
            _generate_row(row)

    _lowest_generated_row = player_row + ROWS_AHEAD
```

### Save Data Validation
```gdscript
func _validate_save_data(data: SaveData) -> bool:
    # Check required fields exist
    if data.world_seed == 0:
        return false
    if data.player_position == Vector2.ZERO:
        return false
    # Verify position is valid
    if data.player_position.y < 0:
        return false
    return true
```

## Edge Cases

- Corrupted save file: Show error, offer to start new game
- Save from different game version: Version check and migration
- Player position in invalid location: Reset to surface
- Missing inventory items (removed in update): Skip unknown item IDs

## Verify

- [ ] Build succeeds
- [ ] has_save() returns true when save exists
- [ ] has_save() returns false when no save
- [ ] Coins restored correctly
- [ ] Depth restored correctly
- [ ] Inventory items restored correctly
- [ ] Player position restored correctly
- [ ] Equipped tool restored correctly
- [ ] World seed matches saved value
- [ ] Chunks generate around saved player position
- [ ] Game resumes in playing state
- [ ] Corrupted save handled gracefully
