---
title: "implement: Player spawn at surface"
status: closed
priority: 1
issue-type: task
created-at: "\"2026-01-16T01:10:11.173965-06:00\""
closed-at: "2026-01-24T21:20:07.295851+00:00"
close-reason: Player spawns at surface row 7 as defined in GameManager.SURFACE_ROW
---

## Description

Implement player spawning at the surface level near the mine entrance. Handle spawn positioning for new game, continue game, and death/respawn scenarios.

## Context

Currently the player spawns at a hardcoded position. The game needs proper spawn handling that:
- Places new players at the surface
- Restores position on continue (from save)
- Returns player to surface on death

## Affected Files

- `scripts/player/player.gd` - Add spawn/respawn methods
- `scripts/autoload/game_manager.gd` - Coordinate spawning
- `scenes/surface.tscn` - Contains spawn point marker
- `scripts/test_level.gd` - Wire up spawn on level load

## Implementation Notes

### Spawn Point Marker

The surface scene should have a `Marker2D` at the spawn position:

```gdscript
# surface.gd
@onready var spawn_point: Marker2D = $SpawnPoint

func get_spawn_position() -> Vector2:
    return spawn_point.global_position
```

### GameManager Spawn Coordination

```gdscript
# game_manager.gd
var surface: Node2D  # Set by level scene
var player: CharacterBody2D  # Set by level scene

func spawn_player_at_surface() -> void:
    if player == null or surface == null:
        push_error("Cannot spawn: player or surface not set")
        return

    var spawn_pos := surface.get_spawn_position()
    player.global_position = spawn_pos
    player.grid_position = player._world_to_grid(spawn_pos)
    player.velocity = Vector2.ZERO
    player.current_state = player.State.IDLE

func get_spawn_position() -> Vector2:
    if surface:
        return surface.get_spawn_position()
    # Fallback: center of surface row
    return Vector2(
        GRID_OFFSET_X + (GRID_WIDTH / 2) * 128,
        (SURFACE_ROW - 1) * 128
    )
```

### Spawn Scenarios

**New Game:**
```gdscript
func start_new_game() -> void:
    # Reset all progress
    PlayerData.reset()
    InventoryManager.clear()

    # Spawn at surface
    spawn_player_at_surface()

    # Start playing
    change_state(GameState.PLAYING)
```

**Continue Game:**
```gdscript
func continue_game() -> void:
    # Load save data
    var save_data := SaveManager.load_game()

    if save_data.has("player_position"):
        player.global_position = save_data.player_position
        player.grid_position = player._world_to_grid(save_data.player_position)
    else:
        spawn_player_at_surface()

    change_state(GameState.PLAYING)
```

**Death Respawn:**
```gdscript
func respawn_after_death() -> void:
    # Reset HP
    player.current_hp = player.MAX_HP

    # Spawn at surface
    spawn_player_at_surface()

    # Resume play
    change_state(GameState.PLAYING)
```

### Player Spawn Method

```gdscript
# player.gd
func spawn_at(world_pos: Vector2) -> void:
    global_position = world_pos
    grid_position = _world_to_grid(world_pos)
    velocity = Vector2.ZERO
    current_state = State.IDLE
    _update_depth()
```

## Edge Cases

- Surface scene not loaded yet: Queue spawn for after scene ready
- Invalid spawn position (inside block): Find nearest valid position
- Multiple spawn points: Use the one marked as default

## Verify

- [ ] Build succeeds
- [ ] New game spawns player at surface spawn point
- [ ] Continue game loads saved position (or surface if no position saved)
- [ ] Death respawns player at surface
- [ ] Player state is IDLE after spawn
- [ ] Player grid_position matches world position after spawn
- [ ] Depth indicator shows 0 at surface
