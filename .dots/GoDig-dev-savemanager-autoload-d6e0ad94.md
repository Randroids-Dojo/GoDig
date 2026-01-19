---
title: "implement: SaveManager autoload singleton"
status: open
priority: 1
issue-type: task
created-at: "2026-01-16T00:37:35.701203-06:00"
---

## Description

Create a SaveManager autoload singleton that handles all save/load operations. Uses Godot Resources for player data and binary storage for chunk modifications. Supports 3 save slots and auto-save.

## Context

Persistence is critical for a mobile mining game. Players invest time digging deep and collecting resources - losing progress would be devastating. The save system must handle both player state (position, inventory, coins) and world state (which blocks have been dug).

## Affected Files

- `scripts/autoload/save_manager.gd` - NEW: SaveManager singleton
- `resources/save/save_data.gd` - NEW: SaveData resource class
- `project.godot` - Add SaveManager to autoload

## Implementation Notes

### SaveData Resource Class

```gdscript
# resources/save/save_data.gd
class_name SaveData extends Resource

const CURRENT_VERSION := 1

# Meta
@export var save_version: int = CURRENT_VERSION
@export var last_save_time: int = 0
@export var total_playtime: float = 0.0

# Player state
@export var player_grid_position: Vector2i = Vector2i.ZERO
@export var current_depth: int = 0

# Economy
@export var coins: int = 0
@export var lifetime_coins: int = 0

# Inventory (Dictionary of item_id -> quantity)
@export var inventory: Dictionary = {}
@export var max_slots: int = 8
@export var equipped_tool: String = "rusty_pickaxe"

# Progression
@export var max_depth_reached: int = 0
@export var tools_unlocked: Array[String] = ["rusty_pickaxe"]
@export var achievements: Array[String] = []

# World
@export var world_seed: int = 0
```

### SaveManager Singleton

```gdscript
# scripts/autoload/save_manager.gd
extends Node

signal save_completed
signal load_completed
signal save_slot_changed(slot: int)

const SAVE_DIR := "user://saves/"
const CHUNKS_DIR := "user://chunks/"
const MAX_SLOTS := 3

var current_slot: int = 0
var current_save: SaveData = null
var _is_saving: bool = false

func _ready() -> void:
    # Ensure directories exist
    DirAccess.make_dir_recursive_absolute(SAVE_DIR)
    DirAccess.make_dir_recursive_absolute(CHUNKS_DIR)

func get_save_path(slot: int) -> String:
    return SAVE_DIR + "slot_%d.tres" % slot

func has_save(slot: int) -> bool:
    return ResourceLoader.exists(get_save_path(slot))

func save_game() -> void:
    if _is_saving or current_save == null:
        return
    _is_saving = true

    # Update timestamps
    current_save.last_save_time = Time.get_unix_time_from_system()

    # Gather current state from other managers
    _collect_game_state()

    # Save to file
    var error := ResourceSaver.save(current_save, get_save_path(current_slot))
    if error != OK:
        push_error("Failed to save game: %s" % error)

    _is_saving = false
    save_completed.emit()

func load_game(slot: int) -> bool:
    var path := get_save_path(slot)
    if not ResourceLoader.exists(path):
        return false

    current_slot = slot
    current_save = ResourceLoader.load(path)

    # Handle version migrations
    _migrate_if_needed()

    load_completed.emit()
    return true

func new_game(slot: int) -> void:
    current_slot = slot
    current_save = SaveData.new()
    current_save.world_seed = randi()

    # Delete old chunk data for this slot
    _clear_chunk_data(slot)

    save_game()

func delete_save(slot: int) -> void:
    var path := get_save_path(slot)
    if FileAccess.file_exists(path):
        DirAccess.remove_absolute(path)
    _clear_chunk_data(slot)

func _collect_game_state() -> void:
    # Called before saving - gather state from game systems
    # Note: Implementor should call into GameManager, InventoryManager, etc.
    pass

func _migrate_if_needed() -> void:
    if current_save.save_version < SaveData.CURRENT_VERSION:
        # Apply migrations here as versions increase
        current_save.save_version = SaveData.CURRENT_VERSION
        save_game()

func _clear_chunk_data(slot: int) -> void:
    var chunk_path := CHUNKS_DIR + "slot_%d/" % slot
    if DirAccess.dir_exists_absolute(chunk_path):
        var dir := DirAccess.open(chunk_path)
        dir.list_dir_begin()
        var file_name := dir.get_next()
        while file_name != "":
            dir.remove(file_name)
            file_name = dir.get_next()
        dir.list_dir_end()
```

### Chunk Persistence (separate task but interface here)

```gdscript
# Chunk save/load interface used by ChunkManager
func get_chunk_path(slot: int, chunk_coord: Vector2i) -> String:
    return CHUNKS_DIR + "slot_%d/chunk_%d_%d.dat" % [slot, chunk_coord.x, chunk_coord.y]

func save_chunk(chunk_coord: Vector2i, modified_tiles: Dictionary) -> void:
    var path := get_chunk_path(current_slot, chunk_coord)
    DirAccess.make_dir_recursive_absolute(path.get_base_dir())
    var file := FileAccess.open(path, FileAccess.WRITE)
    file.store_var(modified_tiles, true)  # compressed
    file.close()

func load_chunk(chunk_coord: Vector2i) -> Dictionary:
    var path := get_chunk_path(current_slot, chunk_coord)
    if not FileAccess.file_exists(path):
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    var data: Dictionary = file.get_var(true)
    file.close()
    return data

func has_modified_chunk(chunk_coord: Vector2i) -> bool:
    return FileAccess.file_exists(get_chunk_path(current_slot, chunk_coord))
```

### Mobile/Web Considerations

- Use `NOTIFICATION_APPLICATION_PAUSED` to trigger emergency save on mobile
- Keep chunk files small (< 50KB each) for IndexedDB on web
- Consider compression for large worlds

## Edge Cases

- Saving while already saving: Early return with `_is_saving` flag
- Corrupt save file: Catch ResourceLoader errors, fall back to new game
- Out of disk space: Log error, notify player
- Loading non-existent slot: Return false, let caller handle
- Version mismatch: Migrate data forward, never backward

## Verify

- [ ] Build succeeds with no errors
- [ ] SaveManager autoload is registered in project.godot
- [ ] `new_game()` creates fresh SaveData with random seed
- [ ] `save_game()` writes .tres file to user://saves/
- [ ] `load_game()` restores SaveData from file
- [ ] `has_save()` correctly detects existing saves
- [ ] `delete_save()` removes save file and chunk data
- [ ] Chunk data saves/loads correctly
- [ ] Migration runs when save_version is outdated
