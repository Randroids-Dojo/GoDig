---
title: "implement: MVP tutorial sequence"
status: open
priority: 2
issue-type: task
created-at: "2026-01-19T02:57:27.506231-06:00"
---

5-prompt tutorial: movement, dig, collect, sell, upgrade. Guaranteed copper at depth 4. Tutorial complete flag in save. 3 context hints for stuck/full/shop.

## Description

Implement a minimal tutorial system that guides new players through the core loop in under 5 minutes. Uses visual prompts and guaranteed ore placement to ensure a smooth first experience.

## Context

- New players need to learn: move, dig, collect, sell, upgrade
- Tutorial should be non-intrusive and quick
- Must ensure "first ore" moment happens early
- See research: GoDig-research-onboarding-and-f088bba4

## Affected Files

- `scripts/autoload/game_manager.gd` - Add tutorial_complete flag
- `scripts/ui/tutorial_prompt.gd` - NEW: Simple prompt display
- `scenes/ui/tutorial_prompt.tscn` - NEW: Prompt scene
- `scripts/player/player.gd` - Trigger tutorial state changes
- `scripts/world/dirt_grid.gd` - Guaranteed ore placement for tutorial

## Implementation Notes

### Tutorial State Machine

```gdscript
# game_manager.gd
enum TutorialState {
    MOVEMENT,      # Waiting for player to move
    DIGGING,       # Waiting for first dig
    COLLECTING,    # Waiting for first pickup
    SELLING,       # Waiting for first shop visit
    COMPLETE       # Tutorial done
}

var tutorial_state: TutorialState = TutorialState.MOVEMENT
var tutorial_complete: bool = false

func advance_tutorial(new_state: TutorialState) -> void:
    tutorial_state = new_state
    tutorial_state_changed.emit(new_state)

func complete_tutorial() -> void:
    tutorial_complete = true
    tutorial_state = TutorialState.COMPLETE
    # Save immediately so it persists
    SaveManager.save_game()
```

### Tutorial Prompt UI

```gdscript
# tutorial_prompt.gd
extends Control

@onready var label: Label = $Panel/Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const PROMPTS := {
    TutorialState.MOVEMENT: "Use the joystick to move",
    TutorialState.DIGGING: "Tap DIG to break blocks",
    TutorialState.COLLECTING: "Walk over ores to collect them",
    TutorialState.SELLING: "Enter the shop to sell!",
}

func _ready() -> void:
    GameManager.tutorial_state_changed.connect(_on_state_changed)
    if not GameManager.tutorial_complete:
        show_prompt(GameManager.tutorial_state)

func _on_state_changed(state: TutorialState) -> void:
    if state == TutorialState.COMPLETE:
        hide()
    elif state in PROMPTS:
        show_prompt(state)

func show_prompt(state: TutorialState) -> void:
    label.text = PROMPTS[state]
    animation_player.play("fade_in")
    # Auto-dismiss after 5 seconds
    await get_tree().create_timer(5.0).timeout
    animation_player.play("fade_out")
```

### Guaranteed First Ore

```gdscript
# dirt_grid.gd
func _on_new_game() -> void:
    if not GameManager.tutorial_complete:
        # Place copper 4 blocks below spawn
        var spawn_x = player_spawn_position.x
        var ore_pos = Vector2i(spawn_x, 4)
        force_ore_at(ore_pos, "copper")
```

### Context Hints

```gdscript
# hint_system.gd or player.gd
var stuck_timer: float = 0.0
var last_y: int = 0

func _physics_process(delta: float) -> void:
    if GameManager.tutorial_complete:
        return

    # Stuck detection
    if position.y == last_y and is_in_hole():
        stuck_timer += delta
        if stuck_timer > 15.0:
            show_hint("Climb walls to escape!")
            stuck_timer = 0.0
    else:
        stuck_timer = 0.0
        last_y = position.y

    # Inventory full
    if InventoryManager.is_full() and not hint_shown["inventory_full"]:
        show_hint("Return to surface to sell!")
        hint_shown["inventory_full"] = true
```

### Save Integration

Tutorial state should be saved:
```gdscript
# Save data includes:
{
    "tutorial_complete": GameManager.tutorial_complete,
    "tutorial_state": GameManager.tutorial_state
}
```

## Verify

- [ ] New game shows movement prompt
- [ ] Movement prompt disappears after player moves
- [ ] Dig prompt appears after movement
- [ ] Copper ore exists at depth 4 in new game
- [ ] "Collected" feedback on first pickup
- [ ] Shop prompt appears when near shop
- [ ] Tutorial complete flag saves to disk
- [ ] Returning to saved game skips tutorial
- [ ] Stuck hint appears after 15s in hole
- [ ] Inventory full hint appears once
