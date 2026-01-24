---
title: "implement: GameManager autoload singleton"
status: active
priority: 1
issue-type: task
created-at: "\"2026-01-16T00:37:35.694949-06:00\""
---

## Description

Expand the existing GameManager autoload to be the central hub for game state, grid constants, scene management, and cross-system communication. Currently has basic structure - needs expansion for full game loop.

## Context

GameManager already exists with grid constants (BLOCK_SIZE, GRID_WIDTH) and basic signals. Needs expansion to handle game flow (start/pause/resume), scene transitions, and coordinate system utilities.

## Affected Files

- `scripts/autoload/game_manager.gd` - MODIFY: Expand existing file
- Already registered in project.godot

## Current Implementation

**ALREADY IMPLEMENTED** in `scripts/autoload/game_manager.gd`:
- Grid constants (BLOCK_SIZE=128, GRID_WIDTH=5, SURFACE_ROW=7, VIEWPORT dimensions)
- Signals: game_started, game_over, depth_updated, depth_milestone_reached, coins_changed, coins_added, coins_spent
- Coordinate conversion: grid_to_world(), world_to_grid()
- is_running state
- Currency system: add_coins(), spend_coins(), can_afford(), get_coins(), set_coins()
- Depth milestones: tracking, auto-save on milestone
- TileSet caching: terrain_tileset, get_terrain_tileset()

**NOT YET IMPLEMENTED** (still needed):

## Implementation Notes - Additions Needed

### Game State Machine

```gdscript
enum GameState { MENU, PLAYING, PAUSED, SHOP, GAME_OVER }

var state: GameState = GameState.MENU

signal state_changed(new_state: GameState)

func set_state(new_state: GameState) -> void:
    var old_state := state
    state = new_state
    state_changed.emit(new_state)

    match new_state:
        GameState.PLAYING:
            get_tree().paused = false
        GameState.PAUSED, GameState.SHOP:
            get_tree().paused = true
        GameState.GAME_OVER:
            _handle_game_over()

func is_playing() -> bool:
    return state == GameState.PLAYING
```

### Scene Management

```gdscript
const SCENE_MAIN_MENU := "res://scenes/ui/main_menu.tscn"
const SCENE_GAME := "res://scenes/main.tscn"
const SCENE_GAME_OVER := "res://scenes/ui/game_over.tscn"

func go_to_main_menu() -> void:
    set_state(GameState.MENU)
    get_tree().change_scene_to_file(SCENE_MAIN_MENU)

func start_new_game() -> void:
    SaveManager.new_game(SaveManager.current_slot)
    _load_game_scene()

func continue_game() -> void:
    if SaveManager.has_save(SaveManager.current_slot):
        SaveManager.load_game(SaveManager.current_slot)
        _load_game_scene()

func _load_game_scene() -> void:
    get_tree().change_scene_to_file(SCENE_GAME)
    await get_tree().process_frame
    set_state(GameState.PLAYING)
    TerrainGenerator.initialize(SaveManager.current_save.world_seed)
```

### Player Reference

```gdscript
var player: CharacterBody2D = null

func register_player(p: CharacterBody2D) -> void:
    player = p

func get_player_position() -> Vector2:
    if player:
        return player.position
    return Vector2.ZERO

func get_player_grid_position() -> Vector2i:
    return world_to_grid(get_player_position())
```

### Shop/UI Integration

```gdscript
signal shop_requested
signal shop_closed

func open_shop() -> void:
    set_state(GameState.SHOP)
    shop_requested.emit()

func close_shop() -> void:
    set_state(GameState.PLAYING)
    shop_closed.emit()
```

### Pause System

```gdscript
func pause_game() -> void:
    if state == GameState.PLAYING:
        set_state(GameState.PAUSED)

func resume_game() -> void:
    if state == GameState.PAUSED:
        set_state(GameState.PLAYING)

func toggle_pause() -> void:
    if state == GameState.PLAYING:
        pause_game()
    elif state == GameState.PAUSED:
        resume_game()
```

### Mobile Lifecycle

```gdscript
func _notification(what: int) -> void:
    match what:
        NOTIFICATION_APPLICATION_PAUSED:
            # Mobile: app went to background
            if state == GameState.PLAYING:
                SaveManager.save_game()
                pause_game()
        NOTIFICATION_APPLICATION_RESUMED:
            # Mobile: app returned to foreground
            pass  # Stay paused, player can resume
```

## Edge Cases

- Player not registered: Return zero position, do not crash
- State transitions during scene load: Queue state changes
- Save during pause: Already handled by auto-save triggers
- Multiple pause calls: Idempotent, do not stack

## Verify

- [ ] Build succeeds with no errors
- [ ] GameState enum covers all needed states
- [ ] set_state correctly pauses/unpauses tree
- [ ] start_new_game initializes fresh save
- [ ] continue_game loads existing save
- [ ] pause_game/resume_game toggle correctly
- [ ] Mobile lifecycle saves on background
- [ ] Player reference accessible after registration
