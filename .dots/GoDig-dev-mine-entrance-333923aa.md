---
title: "implement: Mine entrance on surface"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T01:02:14.671077-06:00"
after:
  - GoDig-dev-surface-area-379633b2
---

## Description

Create a mine shaft entrance on the surface that serves as the visual transition point between surface and underground. Players descend through this entrance to start mining.

## Context

- Surface is the "home base" with shop and buildings
- Mine entrance is how players transition to underground mining
- Provides visual grounding for the game world
- Could show current depth or deepest reached depth

## Affected Files

- `scenes/surface/mine_entrance.tscn` - NEW: Mine entrance scene
- `scripts/surface/mine_entrance.gd` - NEW: Entrance behavior
- Surface scene - Add mine entrance instance
- `scripts/world/dirt_grid.gd` - May need to leave space for entrance

## Implementation Notes

### Mine Entrance Scene

```
MineEntrance (Node2D)
├── Background (ColorRect or Sprite2D)
│   └── Dark shaft visual
├── Frame (Sprite2D)
│   └── Wooden frame around entrance
├── DepthSign (Node2D)
│   └── Label showing depth
└── EntryArea (Area2D)
    └── CollisionShape2D (trigger for transition)
```

### Mine Entrance Script

```gdscript
# mine_entrance.gd
extends Node2D

signal player_entering_mine
signal player_exiting_mine

@onready var depth_label: Label = $DepthSign/Label
@onready var entry_area: Area2D = $EntryArea

var _player_inside: bool = false


func _ready() -> void:
    entry_area.body_entered.connect(_on_body_entered)
    entry_area.body_exited.connect(_on_body_exited)
    _update_depth_display()

    # Connect to depth changes
    if GameManager:
        GameManager.max_depth_changed.connect(_update_depth_display)


func _on_body_entered(body: Node2D) -> void:
    if body.name == "Player" or body.is_in_group("player"):
        _player_inside = true
        player_entering_mine.emit()


func _on_body_exited(body: Node2D) -> void:
    if body.name == "Player" or body.is_in_group("player"):
        _player_inside = false
        player_exiting_mine.emit()


func _update_depth_display(_max_depth: int = 0) -> void:
    if GameManager:
        var max_depth := GameManager.get_max_depth_reached()
        depth_label.text = "Deepest: %dm" % max_depth
    else:
        depth_label.text = ""
```

### Visual Design

For MVP, the mine entrance should:
- Be 2-3 blocks wide (256-384 pixels)
- Have a dark interior (black/dark gray)
- Wooden support frame (brown colored)
- Sign showing deepest depth reached

```
    [MINE]
   ========
   ||    ||
   ||    ||
   ||    ||  <- Dark shaft interior
   ||    ||
   ========
```

### Integration with Surface

The surface layout should position the mine entrance centrally:

```
[Shop] ---- [Mine Entrance] ---- [Future Building Slot]
           Ground Level (y=0)
-------------------------------------------
           Underground starts here
```

### Player Descent Behavior

When player walks into the mine entrance:
1. Camera follows player down
2. Surface remains visible above
3. Player can walk back up to surface via ladders or teleport

The mine entrance itself doesn't need special transition logic - the player simply walks down into the underground grid system.

### Depth Sign Options

1. **Max Depth Reached**: "Deepest: 847m"
2. **Current Depth**: Updates as player moves (may be on HUD instead)
3. **Layer Name**: "Currently in: Stone Layer"

For MVP, show max depth on the entrance sign, current depth on HUD.

## Edge Cases

- First play (depth 0): Show "Deepest: 0m" or "Start your descent!"
- Player at mine entrance but not underground: Sign shows max, not current
- Very deep (1000+): Consider "1.2km" format

## Verify

- [ ] Build succeeds
- [ ] Mine entrance appears on surface
- [ ] Visual clearly shows "this is the way down"
- [ ] Depth sign shows max depth reached
- [ ] Player can walk into entrance
- [ ] Camera follows player down smoothly
- [ ] Player can return to surface via entrance
- [ ] Entrance does not block underground generation
