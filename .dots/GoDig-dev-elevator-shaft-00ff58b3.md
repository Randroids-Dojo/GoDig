---
title: "implement: Elevator shaft building"
status: open
priority: 3
issue-type: task
created-at: "2026-01-16T00:43:49.321885-06:00"
after:
  - GoDig-dev-building-slot-0c645dc8
  - GoDig-dev-surface-area-379633b2
---

## Description

Implement an elevator building on the surface that allows fast travel to depths the player has previously reached. The elevator shaft must be connected by digging a continuous vertical path down.

## Context

- Reduces tedious backtracking as players go deeper
- Creates "checkpoint" system for progress
- Requires investment: digging vertical shaft AND building purchase
- See research: GoDig-research-movement-traversal-cee4601c

## Affected Files

- `scenes/surface/elevator_building.tscn` - NEW: Elevator building scene
- `scripts/surface/elevator_building.gd` - NEW: Elevator logic
- `scenes/ui/elevator_menu.tscn` - NEW: Depth selection UI
- `scripts/ui/elevator_menu.gd` - NEW: Menu controller
- `scripts/autoload/game_manager.gd` - Track elevator depths

## Implementation Notes

### Elevator Building Scene

```
ElevatorBuilding (Node2D)
├── Sprite2D (shaft house visual)
├── InteractionArea (Area2D)
│   └── CollisionShape2D
└── ShaftIndicator (Line2D) - Shows connected depth visually
```

### Elevator Building Script

```gdscript
# elevator_building.gd
extends Node2D

signal elevator_activated(max_depth: int)

@export var building_cost: int = 5000

@onready var interaction_area: Area2D = $InteractionArea

var max_connected_depth: int = 0

func _ready() -> void:
    interaction_area.body_entered.connect(_on_player_entered)
    interaction_area.body_exited.connect(_on_player_exited)

func _on_player_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        GameManager.show_elevator_button(true)

func _on_player_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        GameManager.show_elevator_button(false)

func interact() -> void:
    # Calculate max connected depth
    _calculate_connected_depth()
    elevator_activated.emit(max_connected_depth)

func _calculate_connected_depth() -> void:
    # Check for continuous vertical shaft from surface
    var depth := 0
    var shaft_x := int(global_position.x / 128)  # Grid column

    while true:
        depth += 1
        var check_pos := Vector2i(shaft_x, depth)

        if not _is_tile_empty(check_pos):
            break  # Hit solid block

        max_connected_depth = depth

    # Cap at deepest reached
    max_connected_depth = mini(max_connected_depth, GameManager.deepest_reached)
```

### Elevator Menu UI

```gdscript
# elevator_menu.gd
extends Control

signal depth_selected(depth: int)

@onready var depth_slider: VSlider = $DepthSlider
@onready var depth_label: Label = $DepthLabel
@onready var descend_button: Button = $DescendButton

var max_depth: int = 0

func open(available_depth: int) -> void:
    max_depth = available_depth
    depth_slider.max_value = max_depth
    depth_slider.value = 0
    _update_display()
    show()

func _on_slider_changed(value: float) -> void:
    _update_display()

func _update_display() -> void:
    var depth := int(depth_slider.value)
    depth_label.text = "%dm" % depth

    # Show layer name at depth
    var layer_name := DataRegistry.get_layer_name(depth)
    depth_label.text += " (%s)" % layer_name

func _on_descend_pressed() -> void:
    var depth := int(depth_slider.value)
    depth_selected.emit(depth)
    hide()
```

### Fast Travel Execution

```gdscript
# game_manager.gd
func travel_to_depth(depth: int) -> void:
    # Fade out
    await screen_fade.fade_out()

    # Move player to elevator shaft at depth
    var shaft_x := elevator_building.global_position.x
    player.global_position = Vector2(shaft_x, depth * 128)
    player.grid_position = Vector2i(int(shaft_x / 128), depth)

    # Update camera
    camera.global_position = player.global_position

    # Fade in
    await screen_fade.fade_in()
```

### Shaft Connection Rules

1. Elevator placed on surface at fixed column
2. Player must dig continuous vertical path downward
3. Any solid block breaks the connection
4. Ladders do NOT break connection (placed objects OK)
5. Max travel = min(shaft_depth, deepest_reached)

### Building Cost and Unlock

| Requirement | Value |
|-------------|-------|
| Building Cost | 5000 coins |
| Unlock Depth | 200m reached |
| Surface Slot | Uses 1 building slot |

### Visual Feedback

- Show shaft depth as vertical line indicator
- Animate descent (blur + speed lines) during travel
- Play "descending" sound effect

## Edge Cases

- Shaft blocked mid-way: Travel limited to point before blockage
- Player hasn't dug shaft: Elevator shows "Connect shaft first"
- Building not purchased: Show "Available at General Store"
- Player at max depth: Show "You are here" indicator

## Verify

- [ ] Build succeeds
- [ ] Elevator building appears on surface
- [ ] Walking near building shows interact button
- [ ] Elevator menu opens on interaction
- [ ] Slider shows depths up to connected shaft
- [ ] Cannot travel deeper than shaft connects
- [ ] Cannot travel deeper than deepest_reached
- [ ] Player teleports to selected depth
- [ ] Camera follows to new position
- [ ] Blocked shaft limits travel depth
- [ ] Elevator state persists across save/load
