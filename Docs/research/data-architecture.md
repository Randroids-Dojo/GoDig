# Data Architecture Research

## Overview
How game data (ores, blocks, tools, buildings) is structured affects maintainability, modding potential, and ease of balancing.

## Godot Resource System

### Why Use Resources?
- Separate data from code
- Edit in Inspector
- Easy to serialize (save/load)
- Reusable across scenes
- Hot-reload during development

---

## Core Data Resources

### 1. BlockData Resource

```gdscript
# block_data.gd
class_name BlockData extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var base_hardness: float = 10.0
@export var tile_atlas_coords: Vector2i = Vector2i.ZERO
@export var break_particles_color: Color = Color.BROWN
@export var category: String = "dirt"  # dirt, stone, ore, special
@export var drops: Array[DropData] = []
@export_multiline var description: String = ""
```

**Example: Stone Block**
```tres
[resource]
script = preload("res://scripts/resources/block_data.gd")
id = "stone"
display_name = "Stone"
base_hardness = 30.0
tile_atlas_coords = Vector2i(1, 0)
break_particles_color = Color(0.5, 0.5, 0.5)
category = "stone"
```

### 2. OreData Resource

```gdscript
# ore_data.gd
class_name OreData extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var icon: Texture2D
@export var base_value: int = 10
@export var rarity: String = "common"  # common, uncommon, rare, epic, legendary
@export var min_depth: int = 0
@export var max_depth: int = -1  # -1 = no max
@export var spawn_chance: float = 0.1
@export var vein_size_min: int = 1
@export var vein_size_max: int = 5
@export var glow_color: Color = Color.TRANSPARENT
@export_multiline var description: String = ""
```

### 3. ToolData Resource

```gdscript
# tool_data.gd
class_name ToolData extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var icon: Texture2D
@export var tier: int = 1
@export var damage: float = 10.0
@export var speed_modifier: float = 1.0
@export var unlock_depth: int = 0
@export var buy_cost: int = 0
@export var can_dig_up: bool = false
@export var special_ability: String = ""
@export_multiline var description: String = ""
```

### 4. BuildingData Resource

```gdscript
# building_data.gd
class_name BuildingData extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var icon: Texture2D
@export var sprite_sheet: Texture2D
@export var unlock_depth: int = 0
@export var build_cost: int = 1000
@export var upgrade_costs: Array[int] = [0, 2000, 5000, 15000, 50000]
@export var category: String = "shop"  # shop, utility, production
@export var shop_inventory: Array[ShopItemData] = []
@export_multiline var description: String = ""
```

### 5. LayerData Resource

```gdscript
# layer_data.gd
class_name LayerData extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var min_depth: int = 0
@export var max_depth: int = 100
@export var primary_block: BlockData
@export var secondary_blocks: Array[BlockData] = []
@export var secondary_chance: float = 0.2
@export var ambient_color: Color = Color.WHITE
@export var background_texture: Texture2D
@export var music_track: AudioStream
@export var ambient_sounds: Array[AudioStream] = []
```

---

## Data Organization

### File Structure
```
resources/
├── blocks/
│   ├── dirt.tres
│   ├── clay.tres
│   ├── stone.tres
│   └── ...
├── ores/
│   ├── coal.tres
│   ├── iron.tres
│   ├── gold.tres
│   └── ...
├── tools/
│   ├── rusty_pickaxe.tres
│   ├── copper_pickaxe.tres
│   └── ...
├── buildings/
│   ├── general_store.tres
│   ├── blacksmith.tres
│   └── ...
├── layers/
│   ├── topsoil.tres
│   ├── stone_layer.tres
│   └── ...
└── config/
    ├── game_balance.tres
    └── layer_progression.tres
```

### Registry Pattern
```gdscript
# data_registry.gd
extends Node

var blocks: Dictionary = {}
var ores: Dictionary = {}
var tools: Dictionary = {}
var buildings: Dictionary = {}
var layers: Array[LayerData] = []

func _ready():
    _load_all_data()

func _load_all_data():
    # Load blocks
    var block_files = DirAccess.get_files_at("res://resources/blocks/")
    for file in block_files:
        var block = load("res://resources/blocks/" + file) as BlockData
        blocks[block.id] = block

    # Similar for ores, tools, buildings...

func get_block(id: String) -> BlockData:
    return blocks.get(id)

func get_layer_at_depth(depth: int) -> LayerData:
    for layer in layers:
        if depth >= layer.min_depth and (layer.max_depth == -1 or depth < layer.max_depth):
            return layer
    return layers[-1]  # Default to deepest
```

---

## Configuration Resources

### GameBalance Resource
Centralized balance values that might need tweaking:

```gdscript
# game_balance.gd
class_name GameBalance extends Resource

# Economy
@export var starting_coins: int = 100
@export var sell_price_multiplier: float = 1.0
@export var depth_value_bonus: float = 0.001  # Per meter depth

# Difficulty
@export var hardness_depth_scaling: float = 0.005
@export var hazard_start_depth: int = 200

# Progression
@export var inventory_start_slots: int = 8
@export var inventory_max_slots: int = 30

# Session
@export var auto_save_interval: float = 60.0
```

### Advantages
- One place to tweak balance
- Can A/B test different configs
- Easy to create difficulty modes

---

## Localization Integration

### Localized Names
```gdscript
# In resource
@export var id: String = "gold_ore"
# Name comes from translation file

# In code
func get_display_name() -> String:
    return tr("ORE_" + id.to_upper())  # ORE_GOLD_ORE

# Translation file (en.csv)
# KEY, en
# ORE_GOLD_ORE, "Gold Ore"
# ORE_GOLD_ORE_DESC, "A precious metal found deep underground."
```

---

## Save Data Structure

### Player Save Data
```gdscript
# player_save_data.gd
class_name PlayerSaveData extends Resource

@export var coins: int = 0
@export var depth_record: int = 0
@export var inventory: Array[InventorySlotData] = []
@export var equipped_tool_id: String = "rusty_pickaxe"
@export var unlocked_tools: Array[String] = []
@export var unlocked_buildings: Array[String] = []
@export var statistics: Dictionary = {}
@export var settings: Dictionary = {}
@export var last_position: Vector2 = Vector2.ZERO
@export var last_save_time: int = 0
```

### World Save Data
```gdscript
# world_save_data.gd
class_name WorldSaveData extends Resource

@export var seed: int = 0
@export var modified_chunks: Dictionary = {}  # chunk_coord -> ChunkData
@export var placed_ladders: Array[Vector2i] = []
@export var building_states: Dictionary = {}  # building_id -> level
@export var elevator_depth: int = 0
```

---

## Modding Considerations (v2.0+)

### If Supporting Mods
- Use external JSON/YAML for data
- Load from user:// directory
- Validate mod data on load
- Version compatibility checks

### Data-Driven Design
By using resources, the game is already semi-moddable:
- Add new ores by creating .tres files
- Adjust balance without code changes
- Community can share balance configs

---

## Implementation Checklist

### MVP
- [x] BlockData resource
- [x] OreData resource
- [x] ToolData resource
- [x] DataRegistry singleton
- [x] Basic save data structure

### v1.0
- [x] BuildingData resource → Custom Resource class
- [x] LayerData resource → Custom Resource class
- [x] GameBalance config → JSON or Resource, hot-reloadable
- [x] Full save/load system → JSON for player, binary for chunks
- [x] Translation integration → Godot tr() with CSV files

### v1.1+
- [x] Achievement data → Custom Resource, v1.0
- [x] Quest/challenge data → v1.1+ feature
- [x] Mod support structure → Not planned
- [x] Data validation system → Debug builds only

---

## Code Examples

### Loading and Using Data
```gdscript
# In player dig code
func dig_block(tile_pos: Vector2i):
    var block_id = world.get_block_id(tile_pos)
    var block_data = DataRegistry.get_block(block_id)
    var tool_data = DataRegistry.get_tool(equipped_tool_id)

    var break_time = block_data.base_hardness / tool_data.damage
    break_time /= tool_data.speed_modifier

    start_dig_animation(break_time)
    await dig_complete

    for drop in block_data.drops:
        inventory.add_item(drop.item_id, drop.quantity)
```

### Creating Data in Editor
1. Right-click resources folder
2. New Resource → Select type (BlockData, etc.)
3. Fill in exported properties in Inspector
4. Save as .tres file

---

## Questions Resolved
- [x] Use Godot Resources for game data
- [x] Registry pattern for data access
- [x] Separate config resource for balance
- [x] Localization through translation keys
- [x] Save data as Resources for easy serialization
