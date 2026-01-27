---
title: "implement: Floating pickup indicator"
status: closed
priority: 2
issue-type: task
created-at: "2026-01-16T00:45:21.949176-06:00"
close-reason: Implemented with scripts/ui/floating_text.gd and scenes/ui/floating_text.tscn, connected via test_level.gd _on_item_added handler
---

## Description

Display floating text when player collects resources from mining. Shows "+1 Coal" or similar with the item color, floating upward and fading out.

## Context

Provides satisfying visual feedback for resource collection. Common pattern in mobile games. Helps player know what they collected without checking inventory. Improves game feel and "juice".

## Affected Files

- `scripts/ui/floating_text.gd` - NEW: Floating text node script
- `scenes/ui/floating_text.tscn` - NEW: Prefab scene for floating text
- `scripts/test_level.gd` - Spawn floating text on item pickup
- (Alternative) `scripts/world/dirt_grid.gd` - Spawn at block position

## Implementation Notes

### FloatingText Scene Structure

```
FloatingText (Node2D)
└── Label
```

### FloatingText Script

```gdscript
# scripts/ui/floating_text.gd
extends Node2D

const FLOAT_SPEED := 50.0  # pixels per second
const DURATION := 1.0      # seconds before despawn
const FADE_START := 0.5    # start fading at this fraction of duration

@onready var label: Label = $Label

var _timer: float = 0.0
var _initial_color: Color

func setup(text: String, color: Color = Color.WHITE, scale_val: float = 1.0) -> void:
    label.text = text
    label.add_theme_color_override("font_color", color)
    _initial_color = color
    scale = Vector2(scale_val, scale_val)

func _ready() -> void:
    # Center the label
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _process(delta: float) -> void:
    _timer += delta

    # Float upward
    position.y -= FLOAT_SPEED * delta

    # Fade out in second half
    if _timer > DURATION * FADE_START:
        var fade_progress := (_timer - DURATION * FADE_START) / (DURATION * (1.0 - FADE_START))
        var alpha := 1.0 - fade_progress
        label.modulate.a = alpha

    # Despawn when done
    if _timer >= DURATION:
        queue_free()
```

### Spawning in Test Level

```gdscript
# test_level.gd
const FloatingTextScene = preload("res://scenes/ui/floating_text.tscn")

func _on_block_dropped(grid_pos: Vector2i, item_id: String) -> void:
    if item_id.is_empty():
        return

    var item = DataRegistry.get_item(item_id)
    if item == null:
        return

    var leftover := InventoryManager.add_item(item, 1)
    if leftover == 0:
        # Show floating text at block position
        _spawn_floating_text(grid_pos, item)

func _spawn_floating_text(grid_pos: Vector2i, item) -> void:
    var text_instance = FloatingTextScene.instantiate()
    var world_pos := Vector2(
        grid_pos.x * 128 + GameManager.GRID_OFFSET_X + 64,
        grid_pos.y * 128
    )
    text_instance.global_position = world_pos
    text_instance.setup("+1 " + item.display_name, item.color if item.has("color") else Color.WHITE)
    add_child(text_instance)
```

### Alternative: Use InventoryManager Signal

```gdscript
# test_level.gd
func _ready() -> void:
    InventoryManager.item_added.connect(_on_item_added)

func _on_item_added(item: ItemData, amount: int) -> void:
    # Spawn at player position (simpler, less accurate)
    _spawn_floating_text_at_player("+%d %s" % [amount, item.display_name], item)
```

### Visual Polish

- Use outline shader for readability against any background
- Consider icon + text (small ore icon before "+1")
- Multiple pickups stack: "+3 Coal" instead of three "+1 Coal"

## Edge Cases

- Multiple items picked up simultaneously: Queue or stack text
- Inventory full: Don't show floating text (item not collected)
- Very long item names: Truncate or use smaller font

## Verify

- [ ] Build succeeds
- [ ] FloatingText scene exists and works
- [ ] Mining ore shows "+1 [ore name]" floating text
- [ ] Text floats upward and fades out
- [ ] Text color matches ore/item color
- [ ] No floating text for plain dirt blocks
- [ ] No floating text when inventory is full
