---
title: "implement: Building slot system"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T01:52:19.819573-06:00"
after:
  - GoDig-dev-surface-area-379633b2
---

## Description

Implement a slot-based building system on the surface where players can unlock and place shops/buildings. Starts with 3 slots, expandable to 10. Each slot can hold one building type.

## Context

- MVP uses fixed slots rather than free-form placement (simpler UI)
- Buildings provide shops, upgrades, and passive income
- Slot unlocking is a coin sink that creates progression
- See research: GoDig-research-slot-based-3222713b

## Affected Files

- `scripts/surface/building_slot.gd` - NEW: Slot controller
- `scenes/surface/building_slot.tscn` - NEW: Slot scene with visual indicator
- `scripts/autoload/game_manager.gd` - Track unlocked slots, building assignments
- `scenes/surface.tscn` - Add slot positions

## Implementation Notes

### Slot Positions (Portrait Layout)

Slots are evenly spaced horizontally on the surface:

```
Surface Layout (720x visible):
 [Slot 1] [Slot 2] [Slot 3] ... [Slot 10]
     100     220     340          ...
```

### Building Slot Scene Structure

```
BuildingSlot (Node2D)
├── LockedIndicator (Sprite2D) - Padlock icon when locked
├── EmptyIndicator (Sprite2D) - Construction frame when unlocked but empty
├── BuildingContainer (Node2D) - Holds instantiated building
└── InteractionArea (Area2D) - Player detection for menu trigger
```

### Building Slot Script

```gdscript
# building_slot.gd
extends Node2D

signal slot_selected(slot_index: int)

enum State { LOCKED, EMPTY, OCCUPIED }

@export var slot_index: int = 0
@export var unlock_cost: int = 100  # Increases per slot

var state: State = State.LOCKED
var building: Node2D = null

@onready var locked_indicator: Sprite2D = $LockedIndicator
@onready var empty_indicator: Sprite2D = $EmptyIndicator
@onready var building_container: Node2D = $BuildingContainer

func _ready() -> void:
    _update_visuals()

func unlock() -> void:
    if state != State.LOCKED:
        return
    state = State.EMPTY
    _update_visuals()

func place_building(building_scene: PackedScene) -> void:
    if state != State.EMPTY:
        return
    building = building_scene.instantiate()
    building_container.add_child(building)
    state = State.OCCUPIED
    _update_visuals()

func remove_building() -> void:
    if building != null:
        building.queue_free()
        building = null
    state = State.EMPTY
    _update_visuals()

func _update_visuals() -> void:
    locked_indicator.visible = (state == State.LOCKED)
    empty_indicator.visible = (state == State.EMPTY)
    building_container.visible = (state == State.OCCUPIED)
```

### Slot Unlock Costs

| Slot | Cost  | Notes |
|------|-------|-------|
| 1-3  | Free  | Available at start |
| 4    | 500   | First purchase |
| 5    | 1000  | |
| 6    | 2000  | |
| 7    | 5000  | |
| 8    | 10000 | |
| 9    | 25000 | |
| 10   | 50000 | Final expansion |

### GameManager Integration

```gdscript
# game_manager.gd
var unlocked_slots: int = 3
var slot_buildings: Array = [null, null, null, null, null, null, null, null, null, null]

func unlock_slot(index: int) -> bool:
    var cost = get_slot_unlock_cost(index)
    if coins < cost or index < unlocked_slots:
        return false
    coins -= cost
    unlocked_slots = max(unlocked_slots, index + 1)
    return true

func get_slot_unlock_cost(index: int) -> int:
    match index:
        0, 1, 2: return 0
        3: return 500
        4: return 1000
        5: return 2000
        6: return 5000
        7: return 10000
        8: return 25000
        9: return 50000
        _: return -1  # Invalid

func assign_building(slot_index: int, building_id: String) -> void:
    if slot_index < unlocked_slots:
        slot_buildings[slot_index] = building_id
```

### Save/Load

```gdscript
# Save data includes:
{
    "unlocked_slots": 5,
    "slot_buildings": ["general_store", "blacksmith", null, null, "supply_store", ...]
}
```

## Edge Cases

- Player tries to unlock already unlocked slot: No-op
- Player tries to place building in locked slot: Show "Unlock for X coins" prompt
- Removing a building: Confirm dialog, building goes back to "available" pool
- Loading save with more slots than expected: Cap at 10

## Verify

- [ ] Build succeeds
- [ ] 3 slots are available at game start
- [ ] Locked slots show padlock indicator
- [ ] Empty slots show construction frame
- [ ] Can unlock slot 4 for 500 coins
- [ ] Cannot unlock slot without sufficient coins
- [ ] Can place building in empty slot
- [ ] Occupied slot shows building sprite
- [ ] Slot state persists across save/load
- [ ] Cannot place building in locked slot
