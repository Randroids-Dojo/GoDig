---
title: "research: Save slots and autosave"
status: closed
priority: 0
issue-type: task
created-at: "\"\\\"2026-01-18T23:39:36.992317-06:00\\\"\""
closed-at: "2026-01-19T01:13:27.253738-06:00"
close-reason: Documented 3-slot save system, autosave triggers (60s + events), save data structure (player/world/chunks), Continue vs New Game flow, slot selection UI. Implementation dots already exist.
---

How does the save system work? Questions: How many save slots? (3 recommended) When does autosave trigger? (depth milestone, time interval, on surface?) What gets saved? (position, inventory, coins, world state, unlocks) How is chunk modification persisted? What's the save file format? How does 'Continue' vs 'New Game' work?

---

## Research Findings

### Save Slot Design

**Number of Slots: 3**
- Standard mobile game convention
- Allows experimentation without losing progress
- Family sharing friendly

**Slot Structure:**
```
user://saves/
├── slot_1/
│   ├── player.tres       # Player state resource
│   ├── world.tres        # World metadata
│   └── chunks/           # Modified chunk data
│       ├── chunk_0_5.res
│       └── chunk_1_7.res
├── slot_2/
│   └── ...
└── slot_3/
    └── ...
```

### What Gets Saved

#### Player State (player.tres)
```gdscript
class_name PlayerSaveData extends Resource

# Position
@export var position: Vector2 = Vector2.ZERO
@export var current_depth: int = 0

# Stats
@export var current_hp: int = 100
@export var max_hp: int = 100

# Economy
@export var coins: int = 0
@export var lifetime_coins: int = 0

# Inventory
@export var inventory_items: Dictionary = {}  # {item_id: count}
@export var equipped_tool: String = "rusty_pickaxe"
@export var equipped_boots: String = ""
@export var equipped_helmet: String = ""

# Progression
@export var max_depth_reached: int = 0
@export var tools_unlocked: Array[String] = []
@export var buildings_unlocked: Array[String] = []
@export var achievements: Array[String] = []

# Session
@export var total_playtime: float = 0.0
@export var last_save_timestamp: int = 0
```

#### World State (world.tres)
```gdscript
class_name WorldSaveData extends Resource

@export var world_seed: int = 0
@export var buildings_placed: Array[Dictionary] = []
@export var modified_chunk_coords: Array[Vector2i] = []
```

#### Chunk Modifications (chunks/chunk_X_Y.res)
```gdscript
class_name ChunkSaveData extends Resource

@export var coord: Vector2i
@export var dug_tiles: Array[Vector2i] = []  # List of dug positions
@export var placed_ladders: Array[Vector2i] = []
@export var placed_objects: Array[Dictionary] = []  # {type, pos, data}
```

### Autosave Triggers

| Trigger | Interval/Condition | Priority |
|---------|-------------------|----------|
| Timed | Every 60 seconds | Low |
| Surface Return | When reaching y <= 0 | High |
| Shop Transaction | After buy/sell | High |
| Depth Milestone | Every 100m new depth | Medium |
| App Background | On NOTIFICATION_APPLICATION_PAUSED | Critical |
| Significant Action | Tool upgrade, achievement | Medium |

### Autosave Implementation
```gdscript
# save_manager.gd
const AUTO_SAVE_INTERVAL: float = 60.0
var time_since_save: float = 0.0
var current_slot: int = 1

func _process(delta):
    time_since_save += delta
    if time_since_save >= AUTO_SAVE_INTERVAL:
        autosave()

func autosave():
    save_to_slot(current_slot)
    time_since_save = 0.0

func _notification(what):
    if what == NOTIFICATION_APPLICATION_PAUSED:
        # Critical: Save before app goes to background
        autosave()

# Called from game events
func on_surface_reached():
    autosave()

func on_shop_transaction():
    autosave()

func on_depth_milestone(new_depth: int):
    if new_depth > player_data.max_depth_reached:
        player_data.max_depth_reached = new_depth
        if new_depth % 100 == 0:  # Every 100m
            autosave()
```

### Save File Format

**Use Custom Resources (.tres/.res):**
- Type-safe with @export
- Automatic serialization
- Fast loading
- Godot-native

**Chunk Data: Binary (.res):**
- Smaller file size
- Faster read/write
- Good for large world data

### Continue vs New Game Flow

#### Main Menu Options
```
┌─────────────────────────────┐
│       GoDig                 │
│                             │
│   [Continue]    (if save)   │
│   [New Game]                │
│   [Settings]                │
│                             │
└─────────────────────────────┘
```

#### Continue Button
- Shows only if at least one save slot has data
- Opens slot selection screen if multiple saves
- Auto-loads most recent save if only one

#### New Game Button
- Opens slot selection screen
- Shows existing saves with: depth, coins, playtime
- Empty slots show "Empty Slot"
- Selecting existing save warns: "Overwrite save?"

#### Slot Selection UI
```
┌─────────────────────────────────────┐
│         Select Save Slot            │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Slot 1: Depth 523m          │   │
│  │ Coins: 12,450 | 2h 15m      │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Slot 2: Empty               │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Slot 3: Depth 89m           │   │
│  │ Coins: 1,230 | 0h 45m       │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Back]                             │
└─────────────────────────────────────┘
```

### Delete Save Confirmation

When player selects "Delete" on a save slot:
```
┌─────────────────────────────┐
│     Delete Save?            │
│                             │
│   This cannot be undone.    │
│   Depth: 523m | 2h 15m      │
│                             │
│   [Delete]     [Cancel]     │
└─────────────────────────────┘
```

### Save Indicator UI

Show subtle save indicator when autosaving:
- Small floppy disk icon in corner
- Brief "Saving..." text
- Checkmark on complete
- Duration: ~1 second visible

### Error Handling

```gdscript
func save_to_slot(slot: int) -> bool:
    var error = ResourceSaver.save(player_data, get_player_path(slot))
    if error != OK:
        push_error("Failed to save player data: " + str(error))
        show_save_error_toast()
        return false

    # Save world data
    error = ResourceSaver.save(world_data, get_world_path(slot))
    if error != OK:
        push_error("Failed to save world data: " + str(error))
        show_save_error_toast()
        return false

    # Save modified chunks
    for coord in world_data.modified_chunk_coords:
        save_chunk(slot, coord)

    return true

func show_save_error_toast():
    # Non-blocking notification
    toast.show("Save failed - please try again")
```

---

## Questions Resolved

- [x] How many save slots? -> **3 slots**
- [x] When does autosave trigger? -> **60s interval + surface return + shop transaction + depth milestone + app background**
- [x] What gets saved? -> **Player state (position, inventory, coins, equipment, unlocks) + World state (seed, buildings, chunk modifications)**
- [x] Chunk modification persistence? -> **Per-chunk .res files storing dug tiles, ladders, objects**
- [x] Save file format? -> **Custom Resources (.tres) for player/world, binary (.res) for chunks**
- [x] Continue vs New Game? -> **Continue loads most recent or shows slot picker; New Game creates in empty slot or confirms overwrite**

---

## Implementation Tasks Created

1. `implement: SaveManager singleton` - Core save/load API
2. `implement: Save slot selection UI` - Main menu slot picker
3. `implement: Autosave system with triggers` - Timed + event-based saves
4. `implement: Chunk modification persistence` - Per-chunk save files
