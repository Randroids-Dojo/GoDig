---
title: "implement: Building unlock system"
status: open
priority: 2
issue-type: task
created-at: "2026-01-19T01:56:51.720926-06:00"
blocks:
  - GoDig-dev-surface-area-379633b2
---

Track max_depth_reached in GameManager, emit building_unlocked signals, show toast notifications. Buildings appear on surface when unlocked. v1.0 feature.

## Description

Implement a building unlock system that tracks player progress and unlocks new buildings on the surface as depth milestones are reached. When a building unlocks, show a notification and spawn the building on the surface.

## Context

- MVP has a single combined shop
- v1.0 expands to multiple specialized buildings (Blacksmith, Equipment Shop, etc.)
- Buildings unlock based on max depth reached
- Creates progression goals and rewards exploration

## Affected Files

- `scripts/autoload/game_manager.gd` - Add max_depth tracking and unlock logic
- `resources/buildings/building_data.gd` - NEW: Resource class for building definitions
- `resources/buildings/*.tres` - NEW: Building definition files
- `scripts/surface/surface_manager.gd` - Spawn buildings when unlocked
- `scripts/ui/unlock_toast.gd` - NEW: Notification popup
- `scenes/ui/unlock_toast.tscn` - NEW: Toast scene

## Implementation Notes

### Building Unlock Data

```gdscript
# resources/buildings/building_data.gd
class_name BuildingData extends Resource

@export var id: String
@export var display_name: String
@export var description: String
@export var icon: Texture2D
@export var unlock_depth: int = 0
@export var surface_slot: int = 0
@export var scene_path: String  # Path to building scene
```

### Building Definitions

```gdscript
# game_manager.gd or separate building_registry.gd
const BUILDING_UNLOCK_ORDER := [
    {"id": "mine_entrance", "name": "Mine Entrance", "unlock_depth": 0, "slot": 0},
    {"id": "general_store", "name": "General Store", "unlock_depth": 0, "slot": 1},
    {"id": "supply_store", "name": "Supply Store", "unlock_depth": 0, "slot": 2},
    {"id": "blacksmith", "name": "Blacksmith", "unlock_depth": 50, "slot": 3},
    {"id": "equipment_shop", "name": "Equipment Shop", "unlock_depth": 100, "slot": 4},
    {"id": "gem_appraiser", "name": "Gem Appraiser", "unlock_depth": 200, "slot": 5},
    {"id": "gadget_shop", "name": "Gadget Shop", "unlock_depth": 300, "slot": 6},
    {"id": "warehouse", "name": "Warehouse", "unlock_depth": 500, "slot": 7},
    {"id": "elevator", "name": "Elevator", "unlock_depth": 500, "slot": 8},
]
```

### GameManager Additions

```gdscript
# game_manager.gd

signal building_unlocked(building_id: String, building_name: String)

var max_depth_reached: int = 0
var unlocked_buildings: Array[String] = []

func update_depth(depth: int) -> void:
    current_depth = depth
    depth_updated.emit(depth)

    if depth > max_depth_reached:
        max_depth_reached = depth
        _check_building_unlocks()

func _check_building_unlocks() -> void:
    for building in BUILDING_UNLOCK_ORDER:
        if building.id in unlocked_buildings:
            continue
        if max_depth_reached >= building.unlock_depth:
            unlocked_buildings.append(building.id)
            building_unlocked.emit(building.id, building.name)

func is_building_unlocked(building_id: String) -> bool:
    return building_id in unlocked_buildings
```

### Surface Manager Integration

```gdscript
# surface_manager.gd
func _ready() -> void:
    GameManager.building_unlocked.connect(_on_building_unlocked)
    _spawn_initial_buildings()

func _on_building_unlocked(building_id: String, building_name: String) -> void:
    _spawn_building(building_id)
    _show_unlock_notification(building_name)

func _spawn_building(building_id: String) -> void:
    var building_data = _get_building_data(building_id)
    var building_scene = load(building_data.scene_path)
    var instance = building_scene.instantiate()
    instance.position.x = building_data.slot * SLOT_WIDTH
    add_child(instance)
```

### Toast Notification

```gdscript
# unlock_toast.gd
extends Control

@onready var label: Label = $Panel/Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func show_unlock(building_name: String) -> void:
    label.text = "%s Unlocked!" % building_name
    animation_player.play("fade_in_out")
```

## Verify

- [ ] Starting buildings (General Store, Supply Store) exist from game start
- [ ] Reaching depth 50m unlocks Blacksmith
- [ ] Toast notification appears when building unlocks
- [ ] New building appears on surface at correct position
- [ ] Unlocked buildings persist across save/load
- [ ] Already-unlocked buildings don't re-trigger notification on load
- [ ] Building_unlocked signal emitted only once per building
