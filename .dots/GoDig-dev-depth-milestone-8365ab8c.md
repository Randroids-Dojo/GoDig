---
title: "implement: Depth milestone notifications"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T01:07:14.179000-06:00"
after:
  - GoDig-dev-layer-transition-fe3a551c
---

## Description

Show celebratory notifications when players reach significant depth milestones or enter new underground layers. This provides positive feedback and a sense of progression.

## Context

- Infinite depth can feel overwhelming
- Milestones provide accomplishment markers
- Layer transitions are natural celebration points
- Helps players understand progression without complex mechanics

## Affected Files

- `scripts/autoload/game_manager.gd` - Track depth and emit milestone signals
- `scripts/ui/hud.gd` - Display milestone notifications
- `scenes/ui/milestone_popup.tscn` - NEW: Popup scene
- `scripts/ui/milestone_popup.gd` - NEW: Popup behavior

## Implementation Notes

### GameManager Tracking

```gdscript
# game_manager.gd
signal depth_milestone_reached(depth: int, milestone_name: String)
signal new_layer_entered(layer: LayerData)

var _current_depth: int = 0
var _previous_layer_id: String = ""
var _reached_milestones: Array[int] = []

const DEPTH_MILESTONES := [50, 100, 200, 500, 1000, 2000, 5000]


func update_player_depth(grid_y: int) -> void:
    var depth := grid_y - SURFACE_ROW
    if depth <= 0:
        return

    _current_depth = depth
    _check_milestones(depth)
    _check_layer_change(depth)


func _check_milestones(depth: int) -> void:
    for milestone in DEPTH_MILESTONES:
        if depth >= milestone and milestone not in _reached_milestones:
            _reached_milestones.append(milestone)
            var name := _get_milestone_name(milestone)
            depth_milestone_reached.emit(milestone, name)


func _get_milestone_name(depth: int) -> String:
    if depth >= 1000:
        return "%gkm" % (depth / 1000.0)
    return "%dm" % depth


func _check_layer_change(depth: int) -> void:
    var layer := DataRegistry.get_layer_at_depth(depth)
    if layer == null:
        return

    if layer.id != _previous_layer_id:
        _previous_layer_id = layer.id
        new_layer_entered.emit(layer)
```

### Milestone Popup Scene

```
MilestonePopup (Control)
├── Background (ColorRect with rounded corners)
├── Icon (TextureRect - trophy or star)
├── Title (Label - "MILESTONE!")
├── DepthLabel (Label - "500m reached!")
└── Subtitle (Label - layer name, optional)
```

### Milestone Popup Script

```gdscript
# milestone_popup.gd
extends Control

@onready var title_label: Label = $Title
@onready var depth_label: Label = $DepthLabel
@onready var subtitle_label: Label = $Subtitle

const DISPLAY_DURATION := 3.0
const FADE_DURATION := 0.5


func show_depth_milestone(depth: int, name: String) -> void:
    title_label.text = "MILESTONE!"
    depth_label.text = "%s reached!" % name
    subtitle_label.visible = false
    _animate_popup()


func show_new_layer(layer: LayerData) -> void:
    title_label.text = "NEW LAYER"
    depth_label.text = layer.display_name
    subtitle_label.text = "Keep digging!"
    subtitle_label.visible = true
    _animate_popup()


func _animate_popup() -> void:
    visible = true
    modulate.a = 0.0

    var tween := create_tween()

    # Fade in
    tween.tween_property(self, "modulate:a", 1.0, FADE_DURATION)

    # Hold
    tween.tween_interval(DISPLAY_DURATION)

    # Fade out
    tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION)

    # Hide when done
    tween.tween_callback(func(): visible = false)
```

### HUD Integration

```gdscript
# hud.gd
@onready var milestone_popup: Control = $MilestonePopup

func _ready() -> void:
    GameManager.depth_milestone_reached.connect(_on_depth_milestone)
    GameManager.new_layer_entered.connect(_on_new_layer)


func _on_depth_milestone(depth: int, name: String) -> void:
    milestone_popup.show_depth_milestone(depth, name)


func _on_new_layer(layer: LayerData) -> void:
    milestone_popup.show_new_layer(layer)
```

### Milestone Types

1. **Depth Milestones** (numeric achievements):
   - 50m, 100m, 200m, 500m, 1km, 2km, 5km...
   - Message: "500m reached!"

2. **Layer Transitions** (entering new layer):
   - Topsoil -> Subsoil -> Stone -> Deep Stone
   - Message: "You've entered the Stone Layer!"

3. **First-Time Bonuses** (v1.0 enhancement):
   - First time reaching a milestone could award bonus coins
   - "500m reached! +50 bonus coins"

### Visual Design

- Popup should be prominent but not block gameplay
- Position: Top-center of screen
- Colors: Gold/yellow for milestones, layer color for transitions
- Optional: particle effects around popup

### Sound Effects (Future)

- Fanfare/celebration sound for major milestones
- Layer-specific ambient hint when entering new layer

## Edge Cases

- Multiple milestones at once (rare): Queue and show sequentially
- Layer skipped (fell down a shaft): Still triggers notification
- Return to previous layer (going up): Don't re-trigger layer notification
- Resume saved game: Load reached milestones, don't re-trigger

## Verify

- [ ] Build succeeds
- [ ] Reaching 50m shows milestone popup
- [ ] Reaching 100m, 500m, etc. each show popup
- [ ] Entering Stone layer shows "Stone Layer" notification
- [ ] Notifications don't re-trigger on replay
- [ ] Popup fades in and out smoothly
- [ ] Multiple notifications queue properly
- [ ] Saved games remember reached milestones
