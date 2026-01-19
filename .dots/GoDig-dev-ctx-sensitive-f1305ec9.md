---
title: "implement: Context-sensitive action button"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T00:59:26.005327-06:00"
after:
  - GoDig-implement-shop-building-25de6397
  - GoDig-dev-ladder-placement-7b71387f
---

## Description

Replace static action buttons with a context-sensitive button that changes based on the player's situation. The button shows the most relevant action at any time.

## Context

Mobile screens have limited space. Instead of showing multiple buttons (shop, place ladder, climb, etc.), show one dynamic button that adapts to context.

## Affected Files

- `scripts/ui/touch_controls.gd` - Add context button logic
- `scenes/ui/touch_controls.tscn` - Add context button node
- `scripts/ui/context_action_button.gd` - NEW: Button controller
- `scripts/player/player.gd` - Expose context state

## Implementation Notes

### Context Priority (highest to lowest)

1. **Interact** - Near interactive object (shop, NPC)
2. **Climb** - On or adjacent to ladder
3. **Place** - Holding placeable item (ladder segment)
4. **Dig** - Default action when facing a block

### Context Button Controller

```gdscript
# context_action_button.gd
extends TouchScreenButton

enum ContextAction { DIG, PLACE, CLIMB, INTERACT }

signal action_triggered(action: ContextAction)

var current_action: ContextAction = ContextAction.DIG
var player: Node2D  # Reference to player

@export var icon_dig: Texture2D
@export var icon_place: Texture2D
@export var icon_climb: Texture2D
@export var icon_interact: Texture2D


func _process(_delta: float) -> void:
    _update_context()


func _update_context() -> void:
    var new_action := _determine_context()
    if new_action != current_action:
        current_action = new_action
        _update_visuals()


func _determine_context() -> ContextAction:
    if player == null:
        return ContextAction.DIG

    # Check for interactable nearby (shop, etc.)
    if player.is_near_interactable():
        return ContextAction.INTERACT

    # Check if on/near ladder
    if player.is_on_ladder() or player.is_adjacent_to_ladder():
        return ContextAction.CLIMB

    # Check if holding placeable item
    if player.is_holding_placeable():
        return ContextAction.PLACE

    return ContextAction.DIG


func _update_visuals() -> void:
    match current_action:
        ContextAction.DIG:
            texture_normal = icon_dig
        ContextAction.PLACE:
            texture_normal = icon_place
        ContextAction.CLIMB:
            texture_normal = icon_climb
        ContextAction.INTERACT:
            texture_normal = icon_interact


func _on_pressed() -> void:
    action_triggered.emit(current_action)
```

### Player Context Methods

Add to player.gd:
```gdscript
func is_near_interactable() -> bool:
    # Check for shops, NPCs in range
    # Requires interaction system to be implemented
    return false

func is_on_ladder() -> bool:
    # Check if standing on ladder tile
    return current_state == State.CLIMBING

func is_adjacent_to_ladder() -> bool:
    # Check adjacent tiles for ladders
    return false

func is_holding_placeable() -> bool:
    # Check inventory for selected placeable item
    return false
```

### TouchControls Integration

```gdscript
# touch_controls.gd
@onready var context_button: TouchScreenButton = $ActionButtons/ContextButton

func _ready():
    context_button.action_triggered.connect(_on_context_action)

func _on_context_action(action: ContextActionButton.ContextAction) -> void:
    match action:
        ContextActionButton.ContextAction.DIG:
            dig_pressed.emit()
        ContextActionButton.ContextAction.PLACE:
            # Emit place signal or call player.place_item()
            pass
        ContextActionButton.ContextAction.CLIMB:
            # Toggle climb mode
            pass
        ContextActionButton.ContextAction.INTERACT:
            # Open interaction (shop, etc.)
            interaction_pressed.emit()
```

## Dependencies

- Shop building must exist for INTERACT context
- Ladder system must exist for CLIMB/PLACE context

## Verify

- [ ] Build succeeds
- [ ] Button shows DIG icon by default
- [ ] Button shows INTERACT when near shop
- [ ] Button shows CLIMB when on/near ladder
- [ ] Button shows PLACE when holding ladder item
- [ ] Pressing button triggers correct action for context
- [ ] Context updates in real-time as player moves
- [ ] Visual transition between icons is smooth
