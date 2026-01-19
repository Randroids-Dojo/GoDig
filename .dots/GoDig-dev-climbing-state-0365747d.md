---
title: "implement: Climbing state for player"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T01:58:32.068581-06:00"
---

Player enters climbing state on ladder/rope, different movement rules. See ladder-traversal-items.md

## Description

Add CLIMBING state to player state machine. When overlapping a ladder, player moves up/down without gravity.

## Context

Climbing is essential for using placed ladders to return to the surface. Different physics rules apply while climbing.

## Affected Files

- `scripts/player/player.gd` - Add CLIMBING state, enter/exit logic
- `scripts/world/ladder.gd` - Emit signals for player overlap

## Implementation Notes

### State Machine Addition
```gdscript
enum State { IDLE, MOVING, MINING, FALLING, WALL_SLIDING, WALL_JUMPING, CLIMBING }
```

### Ladder Signals
```gdscript
# ladder.gd
extends Area2D

func _ready():
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body):
    if body.name == "Player" or body.is_in_group("player"):
        body.enter_climbing_state(self)

func _on_body_exited(body):
    if body.name == "Player" or body.is_in_group("player"):
        body.exit_climbing_state()
```

### Player Climbing Logic
```gdscript
# player.gd
var is_climbing: bool = false
var current_ladder: Node2D = null
const CLIMB_SPEED: float = 100.0

func enter_climbing_state(ladder: Node2D):
    is_climbing = true
    current_ladder = ladder
    velocity = Vector2.ZERO  # Stop all movement
    state = State.CLIMBING

func exit_climbing_state():
    is_climbing = false
    current_ladder = null
    if is_on_floor():
        state = State.IDLE
    else:
        state = State.FALLING

func _handle_climbing(delta):
    # Vertical movement only
    var input_y = Input.get_axis("move_up", "move_down")
    velocity.y = input_y * CLIMB_SPEED
    velocity.x = 0

    # Allow horizontal exit
    var input_x = Input.get_axis("move_left", "move_right")
    if abs(input_x) > 0.5 and not is_overlapping_ladder():
        exit_climbing_state()
        velocity.x = input_x * MOVE_SPEED

    # No gravity while climbing
    move_and_slide()

func _physics_process(delta):
    match state:
        State.CLIMBING:
            _handle_climbing(delta)
        # ... other states
```

### Climbing Restrictions
- Cannot dig while climbing
- Cannot wall-jump while climbing (must exit first)
- No gravity applied
- Horizontal input while on ladder edge exits climbing

### Edge Cases
- Ladder destroyed while climbing -> Fall
- Reach top of ladder -> Check if can exit up
- Reach bottom of ladder -> Land on ground or continue falling

## Verify

- [ ] Build succeeds
- [ ] Player enters CLIMBING state when touching ladder
- [ ] Player moves up/down with input while climbing
- [ ] No gravity while climbing
- [ ] Horizontal input exits climbing state
- [ ] Cannot dig while climbing
- [ ] Fall tracking resets when starting to climb
- [ ] Exits climbing properly at ladder top/bottom
