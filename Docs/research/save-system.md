# Save/Load System Research

## Sources
- [GDQuest: Saving with Resources](https://www.gdquest.com/library/save_game_godot4/)
- [KidsCanCode: File I/O](https://kidscancode.org/godot_recipes/4.x/basics/file_io/index.html)
- [Godot Docs: Saving Games](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html)
- [RPG Save System Tutorial](https://dev.to/christinec_dev/lets-learn-godot-4-by-making-an-rpg-part-20-saving-loading-autosaving-4bl3)

## Save Format Options

### Option A: JSON
**Pros:**
- Human readable
- Easy debugging
- Cross-platform compatible
- Web-friendly

**Cons:**
- No type safety (int vs float)
- Manual serialization
- Larger file size
- Slow for large data

### Option B: Custom Resources (.tres/.res)
**Pros:**
- Type safety with @export
- Automatic serialization
- Works with all Godot types (Vector2, Color, etc.)
- Less code
- Fast loading

**Cons:**
- Godot-specific format
- Not human readable (binary)
- Version compatibility concerns

### Option C: Binary (store_var)
**Pros:**
- Fastest performance
- Smallest file size
- Good for large worlds

**Cons:**
- Not human readable
- Manual structure management

### Recommendation for GoDig
**Use Custom Resources** for:
- Player data
- Inventory
- Progress/achievements
- Settings

**Use Binary/Compressed** for:
- Chunk modifications
- Large world state

## Save Data Structure

### Player Save (Resource)
```gdscript
# save_data.gd
class_name SaveData extends Resource

# Player state
@export var player_position: Vector2 = Vector2.ZERO
@export var current_depth: int = 0
@export var health: int = 100
@export var energy: int = 100

# Economy
@export var coins: int = 0
@export var lifetime_coins: int = 0

# Inventory
@export var inventory: Dictionary = {}
@export var equipped_tool: String = "rusty_pickaxe"
@export var equipped_gear: Dictionary = {}

# Progression
@export var max_depth_reached: int = 0
@export var tools_unlocked: Array[String] = []
@export var buildings_unlocked: Array[String] = []
@export var achievements: Array[String] = []

# World seed
@export var world_seed: int = 0

# Playtime
@export var total_playtime: float = 0.0
@export var last_save_time: int = 0
```

### Chunk Modification Storage
```gdscript
# chunk_data.gd
class_name ChunkData extends Resource

@export var chunk_coord: Vector2i
@export var modified_tiles: Dictionary = {}
# Key: Vector2i (local pos), Value: int (tile type or -1 for dug)

@export var placed_objects: Array[Dictionary] = []
# [{"type": "ladder", "pos": Vector2i(5, 3)}, ...]
```

## Save/Load Implementation

### SaveManager Singleton
```gdscript
# save_manager.gd
extends Node

const SAVE_PATH = "user://godig_save.tres"
const CHUNKS_PATH = "user://chunks/"

var current_save: SaveData

func _ready():
    # Ensure chunks directory exists
    DirAccess.make_dir_recursive_absolute(CHUNKS_PATH)
    load_game()

func save_game():
    current_save.last_save_time = Time.get_unix_time_from_system()
    var error = ResourceSaver.save(current_save, SAVE_PATH)
    if error != OK:
        push_error("Failed to save game: " + str(error))

func load_game():
    if ResourceLoader.exists(SAVE_PATH):
        current_save = ResourceLoader.load(SAVE_PATH)
    else:
        current_save = SaveData.new()
        current_save.world_seed = randi()
```

### Chunk Persistence
```gdscript
func save_chunk(chunk_coord: Vector2i, data: ChunkData):
    var path = CHUNKS_PATH + "chunk_%d_%d.res" % [chunk_coord.x, chunk_coord.y]
    ResourceSaver.save(data, path)

func load_chunk(chunk_coord: Vector2i) -> ChunkData:
    var path = CHUNKS_PATH + "chunk_%d_%d.res" % [chunk_coord.x, chunk_coord.y]
    if ResourceLoader.exists(path):
        return ResourceLoader.load(path)
    return null  # Generate fresh chunk

func has_modified_chunk(chunk_coord: Vector2i) -> bool:
    var path = CHUNKS_PATH + "chunk_%d_%d.res" % [chunk_coord.x, chunk_coord.y]
    return FileAccess.file_exists(path)
```

## Auto-Save System

### Trigger Points
```gdscript
# Auto-save on:
# 1. Returning to surface
# 2. Every N minutes
# 3. Buying/selling at shops
# 4. Major achievements
# 5. App backgrounded (mobile)

var auto_save_interval: float = 120.0  # 2 minutes
var time_since_save: float = 0.0

func _process(delta):
    time_since_save += delta
    if time_since_save >= auto_save_interval:
        save_game()
        time_since_save = 0.0

func _notification(what):
    if what == NOTIFICATION_APPLICATION_PAUSED:
        # Mobile: app went to background
        save_game()
```

### Save Indicator
```gdscript
func save_game():
    show_save_indicator()
    # ... save logic ...
    await get_tree().create_timer(0.5).timeout
    hide_save_indicator()
```

## Web/Mobile Considerations

### Storage Limits
- IndexedDB (web): ~50MB typical
- Mobile: Usually unlimited but check
- Keep chunk files small

### Compression
```gdscript
func save_chunk_compressed(chunk_coord: Vector2i, data: Dictionary):
    var path = CHUNKS_PATH + "chunk_%d_%d.dat" % [chunk_coord.x, chunk_coord.y]
    var file = FileAccess.open(path, FileAccess.WRITE)
    file.store_var(data, true)  # true = full objects (compressed)
    file.close()
```

### Cloud Save (Future)
```gdscript
# Structure for potential cloud sync
var cloud_save_version: int = 1

func export_for_cloud() -> Dictionary:
    return {
        "version": cloud_save_version,
        "save_data": current_save.to_dict(),
        "timestamp": Time.get_unix_time_from_system()
    }
```

## Data Versioning

### Handle Save Upgrades
```gdscript
const CURRENT_SAVE_VERSION = 1

func load_game():
    if ResourceLoader.exists(SAVE_PATH):
        current_save = ResourceLoader.load(SAVE_PATH)
        migrate_save_if_needed()
    else:
        create_new_save()

func migrate_save_if_needed():
    if current_save.save_version < CURRENT_SAVE_VERSION:
        # Apply migrations
        if current_save.save_version < 1:
            # v0 -> v1 migration
            current_save.new_field = default_value
        current_save.save_version = CURRENT_SAVE_VERSION
        save_game()
```

## Chunk Cleanup

### Remove Old/Unused Chunks
```gdscript
func cleanup_old_chunks(days_old: int = 30):
    var dir = DirAccess.open(CHUNKS_PATH)
    var cutoff = Time.get_unix_time_from_system() - (days_old * 86400)

    dir.list_dir_begin()
    var file_name = dir.get_next()
    while file_name != "":
        var path = CHUNKS_PATH + file_name
        var modified = FileAccess.get_modified_time(path)
        if modified < cutoff:
            dir.remove(file_name)
        file_name = dir.get_next()
```

## Questions to Resolve
- [ ] Resource vs Binary for chunks?
- [ ] Auto-save frequency?
- [ ] Max chunk files before cleanup?
- [ ] Cloud save integration?
- [ ] Multiple save slots?
