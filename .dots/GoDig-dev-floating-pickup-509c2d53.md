---
title: "implement: Floating pickup text"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T01:01:24.196969-06:00"
after:
  - GoDig-dev-auto-pickup-9886859c
---

## Description

Show floating text feedback when items are collected or coins earned. Text appears at the collection point, floats upward, and fades out. Examples: "+1 Coal", "+5 Copper", "+25 coins".

## Context

Player feedback is critical for satisfying game feel. When mining ore:
1. Block is destroyed
2. Item automatically added to inventory
3. Visual feedback (floating text) shows what was collected

InventoryManager already emits `item_added(item: ItemData, amount: int)` signal that can trigger the floating text.

## Affected Files

- `scripts/ui/floating_text.gd` - NEW: Floating text component
- `scenes/ui/floating_text.tscn` - NEW: Scene for the text
- `scripts/test_level.gd` - Connect signals to spawn floating text
- `scripts/player/player.gd` - Provide position for text spawn

## Implementation Notes

### FloatingText Scene Structure

```
FloatingText (Control)
└── Label (centered, styled)
```

### FloatingText Script

```gdscript
# scripts/ui/floating_text.gd
extends Control
class_name FloatingText

@onready var label: Label = $Label

const FLOAT_DISTANCE := 80.0  # Pixels to float up
const FLOAT_DURATION := 1.0    # Seconds to complete
const FADE_DELAY := 0.5        # Start fading after this

var _start_position: Vector2
var _elapsed: float = 0.0


static func create(text: String, color: Color = Color.WHITE) -> FloatingText:
    var scene := load("res://scenes/ui/floating_text.tscn")
    var instance: FloatingText = scene.instantiate()
    instance.set_text(text, color)
    return instance


func set_text(text: String, color: Color = Color.WHITE) -> void:
    if label:
        label.text = text
        label.add_theme_color_override("font_color", color)


func _ready() -> void:
    _start_position = position
    # Start the animation
    _animate()


func _animate() -> void:
    var tween := create_tween()
    tween.set_parallel(true)

    # Float upward
    tween.tween_property(self, "position:y", _start_position.y - FLOAT_DISTANCE, FLOAT_DURATION) \
        .set_ease(Tween.EASE_OUT)

    # Fade out (after delay)
    tween.tween_property(self, "modulate:a", 0.0, FLOAT_DURATION - FADE_DELAY) \
        .set_delay(FADE_DELAY) \
        .set_ease(Tween.EASE_IN)

    # Queue free when done
    tween.tween_callback(queue_free).set_delay(FLOAT_DURATION)
```

### FloatingText Theme

```gdscript
# In floating_text.tscn Label node
# Font: bold, size 24-32 for readability
# Outline: black outline for visibility on any background
# Alignment: center
```

### Spawning Floating Text

```gdscript
# In test_level.gd or game.gd
@onready var floating_text_container: CanvasLayer = $FloatingTextLayer

func _ready() -> void:
    InventoryManager.item_added.connect(_on_item_added)
    GameManager.coins_changed.connect(_on_coins_changed)


func _on_item_added(item: ItemData, amount: int) -> void:
    var text := "+%d %s" % [amount, item.display_name]
    var color := _get_rarity_color(item)
    _spawn_floating_text(text, color)


func _on_coins_changed(new_total: int, delta: int) -> void:
    if delta > 0:
        var text := "+%d coins" % delta
        _spawn_floating_text(text, Color.GOLD)


func _spawn_floating_text(text: String, color: Color) -> void:
    var floating := FloatingText.create(text, color)

    # Position above player
    if player:
        var screen_pos := camera.unproject_position(player.global_position)
        floating.position = screen_pos - Vector2(0, 50)  # Offset above head

    floating_text_container.add_child(floating)


func _get_rarity_color(item: ItemData) -> Color:
    # Use DataRegistry rarity colors
    match item.rarity:
        "common": return Color.WHITE
        "uncommon": return Color.GREEN
        "rare": return Color.CYAN
        "epic": return Color.PURPLE
        "legendary": return Color.GOLD
        _: return Color.WHITE
```

### Screen Space vs World Space

For mobile, floating text should be in screen space (CanvasLayer) so it's always readable regardless of zoom level.

```
Game (Node2D)
├── World
│   ├── Player
│   └── Terrain
├── Camera2D
└── FloatingTextLayer (CanvasLayer)
    └── (dynamically spawned FloatingText instances)
```

### Stacking Prevention

Multiple pickups in quick succession shouldn't overlap. Options:
1. Stagger spawn positions
2. Combine consecutive same-item pickups
3. Queue and space out spawns

```gdscript
var _last_text_time: float = 0.0
const TEXT_SPACING: float = 0.2  # Minimum seconds between texts
var _pending_texts: Array = []

func _spawn_floating_text(text: String, color: Color) -> void:
    var now := Time.get_ticks_msec() / 1000.0
    if now - _last_text_time < TEXT_SPACING:
        # Combine with previous or queue
        _pending_texts.append({"text": text, "color": color})
        return

    _last_text_time = now
    _do_spawn(text, color)
```

## Edge Cases

- Rapid pickups: Combine or stagger text spawns
- Screen edge: Clamp text to visible area
- Camera moving: Text stays in screen space
- Very long item names: Truncate or use short name
- Zero delta: Don't show "+0" text

## Verify

- [ ] Build succeeds with no errors
- [ ] Mining ore shows "+1 [ore name]" floating text
- [ ] Text floats upward and fades out
- [ ] Rarity colors are applied correctly
- [ ] Coin gains show "+X coins" in gold
- [ ] Text is readable on any background (outline)
- [ ] Rapid pickups don't overlap excessively
- [ ] Text stays on screen (not clipped at edges)
