---
title: "implement: Auto-save system"
status: open
priority: 0
issue-type: task
created-at: "2026-01-16T00:34:28.141025-06:00"
after:
  - GoDig-mvp-basic-inventory-851ca931
  - GoDig-mvp-2-3-e92f5253
---

## Description

Implement automatic saving of player progress. Saves player data (coins, inventory, tools, position) and world modifications (dug blocks). Auto-save triggers on timer and key events.

## Context

Mobile players may close the app at any time. Auto-save ensures no progress is lost. Players should never manually save - the game handles it transparently.

## Affected Files

- `scripts/autoload/save_manager.gd` - NEW: Singleton handling all save/load
- `resources/save/save_data.gd` - NEW: Resource class for player data
- `resources/save/chunk_data.gd` - NEW: Resource class for chunk modifications
- `project.godot` - Add SaveManager to autoload

## Implementation Notes

### SaveData Resource

```gdscript
class_name SaveData extends Resource

# Meta
@export var save_version: int = 1
@export var world_seed: int = 0
@export var total_playtime: float = 0.0
@export var last_save_timestamp: int = 0

# Player state
@export var player_position: Vector2 = Vector2.ZERO
@export var player_grid_pos: Vector2i = Vector2i.ZERO

# Economy
@export var coins: int = 0

# Progression
@export var max_depth_reached: int = 0
@export var equipped_tool_id: String = "rusty_pickaxe"

# Inventory (Dictionary: item_id -> quantity)
@export var inventory: Dictionary = {}
```

### ChunkData Resource

```gdscript
class_name ChunkData extends Resource

@export var chunk_coord: Vector2i
# Key: local position as "x,y" string, Value: -1 for dug, else ore_id
@export var modified_tiles: Dictionary = {}
@export var placed_objects: Array[Dictionary] = []  # Ladders, etc
```

### SaveManager Singleton

```gdscript
extends Node

const SAVE_PATH = "user://save.tres"
const CHUNKS_DIR = "user://chunks/"
const AUTO_SAVE_INTERVAL = 60.0  # seconds

signal save_started
signal save_completed

var current_save: SaveData
var _auto_save_timer: float = 0.0
var _modified_chunks: Dictionary = {}  # Track chunks needing save

func _ready():
    DirAccess.make_dir_recursive_absolute(CHUNKS_DIR)
    load_game()

func _process(delta):
    _auto_save_timer += delta
    if _auto_save_timer >= AUTO_SAVE_INTERVAL:
        save_game()
        _auto_save_timer = 0.0

func _notification(what):
    # Mobile: save when app goes to background
    if what == NOTIFICATION_APPLICATION_PAUSED:
        save_game()
    elif what == NOTIFICATION_APPLICATION_FOCUS_OUT:
        save_game()
```

### Save Game Logic

```gdscript
func save_game():
    save_started.emit()

    # Update timestamps
    current_save.last_save_timestamp = Time.get_unix_time_from_system()

    # Gather current state from singletons
    _sync_from_game_state()

    # Save player data
    var error = ResourceSaver.save(current_save, SAVE_PATH)
    if error != OK:
        push_error("Save failed: " + str(error))
        return

    # Save modified chunks
    for coord in _modified_chunks:
        _save_chunk(coord, _modified_chunks[coord])
    _modified_chunks.clear()

    save_completed.emit()
    print("[SaveManager] Game saved")

func _sync_from_game_state():
    current_save.coins = EconomyManager.coins
    current_save.equipped_tool_id = PlayerData.equipped_tool_id
    current_save.max_depth_reached = PlayerData.max_depth_reached
    current_save.inventory = InventoryManager.to_dictionary()
    # Player position synced when player moves
```

### Load Game Logic

```gdscript
func load_game():
    if ResourceLoader.exists(SAVE_PATH):
        current_save = ResourceLoader.load(SAVE_PATH)
        _sync_to_game_state()
        print("[SaveManager] Save loaded")
    else:
        _create_new_save()
        print("[SaveManager] New save created")

func _sync_to_game_state():
    EconomyManager.coins = current_save.coins
    PlayerData.equipped_tool_id = current_save.equipped_tool_id
    PlayerData.max_depth_reached = current_save.max_depth_reached
    InventoryManager.from_dictionary(current_save.inventory)
    GameManager.world_seed = current_save.world_seed

func _create_new_save():
    current_save = SaveData.new()
    current_save.world_seed = randi()
    current_save.save_version = 1
    save_game()
```

### Chunk Persistence

```gdscript
func mark_chunk_modified(coord: Vector2i, tile_changes: Dictionary):
    if coord not in _modified_chunks:
        _modified_chunks[coord] = ChunkData.new()
        _modified_chunks[coord].chunk_coord = coord
    _modified_chunks[coord].modified_tiles.merge(tile_changes, true)

func _save_chunk(coord: Vector2i, data: ChunkData):
    var path = CHUNKS_DIR + "chunk_%d_%d.res" % [coord.x, coord.y]
    ResourceSaver.save(data, path)

func load_chunk(coord: Vector2i) -> ChunkData:
    var path = CHUNKS_DIR + "chunk_%d_%d.res" % [coord.x, coord.y]
    if ResourceLoader.exists(path):
        return ResourceLoader.load(path)
    return null

func has_modified_chunk(coord: Vector2i) -> bool:
    var path = CHUNKS_DIR + "chunk_%d_%d.res" % [coord.x, coord.y]
    return FileAccess.file_exists(path)
```

### Auto-Save Triggers

1. **Timer**: Every 60 seconds
2. **Surface Return**: When player enters surface area
3. **Shop Transaction**: After buy/sell
4. **App Background**: Mobile lifecycle event
5. **Depth Milestone**: First time reaching new depth tier

```gdscript
# In relevant scripts:
func _on_player_reached_surface():
    SaveManager.save_game()

func _on_shop_transaction_complete():
    SaveManager.save_game()
```

### Save Indicator UI

Show brief indicator during save (optional for MVP):

```gdscript
func save_game():
    save_started.emit()  # UI shows "Saving..."
    # ... save logic ...
    save_completed.emit()  # UI hides indicator
```

## Edge Cases

- Corrupted save file: Create new save, log warning
- Missing chunk file: Generate fresh chunk
- Save during gameplay: Don't interrupt player (save in background)
- Multiple rapid saves: Debounce to prevent excessive writes
- Web platform: Use IndexedDB (Godot handles automatically)

## Verify

- [ ] Build succeeds with no errors
- [ ] SaveManager autoload registered in project.godot
- [ ] New game creates new save with random world seed
- [ ] Coins persist after closing and reopening game
- [ ] Inventory persists after restart
- [ ] Equipped tool persists after restart
- [ ] Dug blocks remain dug after restart
- [ ] Auto-save triggers every 60 seconds
- [ ] App background triggers save (test on mobile/web)
- [ ] Corrupted save doesn't crash game (creates new save)
