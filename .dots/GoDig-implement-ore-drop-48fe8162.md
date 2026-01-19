---
title: "implement: Ore drop floating text"
status: open
priority: 3
issue-type: task
created-at: "2026-01-18T23:46:41.438558-06:00"
---

When InventoryManager.item_added signal fires, spawn floating text at player position showing '+1 Coal' with ore's color. Fade up and out over 1 second. Listen to signal in test_level.gd or create dedicated UI component.

## Description

Provide satisfying visual feedback when the player picks up ore. A floating text label rises from the mined block position showing the item name and quantity, colored to match the ore.

## Context

- `InventoryManager.item_added(item: ItemData, amount: int)` signal exists but nothing listens to it
- No floating text system exists yet
- Good "juice" makes mining feel rewarding

## Affected Files

- `scenes/ui/floating_text.tscn` - NEW: Simple Label scene with script
- `scripts/ui/floating_text.gd` - NEW: Tween-based animation
- `scripts/test_level.gd` - Connect to item_added signal, spawn floating text

## Implementation Notes

### FloatingText Scene

Create a simple scene with just a Label node:

```
FloatingText (Control)
└─ Label (centered)
```

### FloatingText Script

```gdscript
# floating_text.gd
extends Control

@onready var label: Label = $Label

func show_text(text: String, color: Color, world_pos: Vector2) -> void:
    label.text = text
    label.modulate = color

    # Convert world position to screen position
    global_position = get_viewport().get_camera_2d().get_screen_center_position()
    # Actually need to convert properly - use CanvasLayer or project position

    # Animate up and fade
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(self, "position:y", position.y - 50, 1.0)
    tween.tween_property(self, "modulate:a", 0.0, 1.0).set_delay(0.3)
    tween.chain().tween_callback(queue_free)
```

### Better Approach: CanvasLayer for UI

Add a CanvasLayer for floating text so it renders in screen space:

```gdscript
# test_level.gd
@onready var floating_text_layer: CanvasLayer = $FloatingTextLayer

func _ready() -> void:
    # ...existing code...
    InventoryManager.item_added.connect(_on_item_added)


func _on_item_added(item: ItemData, amount: int) -> void:
    var text_scene = preload("res://scenes/ui/floating_text.tscn")
    var floating = text_scene.instantiate()
    floating_text_layer.add_child(floating)

    # Get screen position from player world position
    var screen_pos := get_viewport().get_canvas_transform() * player.global_position
    floating.show_pickup("+%d %s" % [amount, item.display_name], _get_item_color(item), screen_pos)


func _get_item_color(item: ItemData) -> Color:
    # Try to get ore color if available
    var ore = DataRegistry.get_ore(item.id)
    if ore:
        return ore.color
    return Color.WHITE
```

### Pooling (Optional, for Performance)

If lots of pickups happen rapidly, consider pooling floating text instances instead of instantiating/freeing.

## Verify

- [ ] Mining coal shows "+1 Coal" floating text in black/gray
- [ ] Mining gold shows "+1 Gold" floating text in gold color
- [ ] Text rises upward and fades out over ~1 second
- [ ] Text is readable against all background colors
- [ ] Multiple pickups in quick succession all show their text
- [ ] No memory leak (texts are freed after animation)
