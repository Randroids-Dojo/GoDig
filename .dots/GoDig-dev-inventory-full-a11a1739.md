---
title: "implement: Inventory full notification"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T01:07:00.113755-06:00"
after:
  - GoDig-dev-inventory-system-bbefbf8d
---

## Description

Show a clear notification when the player's inventory is full and they try to collect more items. The notification should be visible on mobile without blocking gameplay.

## Context

- Inventory has limited slots (8 default, upgradeable)
- When full, mining ore drops items on the ground or destroys them
- Player needs clear feedback that inventory is the problem
- Creates tension and encourages surface trips to sell

## Affected Files

- `scripts/autoload/inventory_manager.gd` - Emit `inventory_full` signal
- `scripts/ui/hud.gd` - Display notification
- `scenes/ui/hud.tscn` - Add notification UI element
- `scripts/test_level.gd` - Connect signals

## Implementation Notes

### InventoryManager Signal

```gdscript
# inventory_manager.gd
signal inventory_full(item: ItemData, overflow_amount: int)

func add_item(item: ItemData, amount: int) -> int:
    # ... existing add logic ...

    var leftover := _add_to_existing_stacks(item, amount)
    if leftover > 0:
        leftover = _add_to_empty_slots(item, leftover)

    if leftover > 0:
        inventory_full.emit(item, leftover)

    return leftover
```

### HUD Notification Display

```gdscript
# hud.gd
@onready var notification_label: Label = $NotificationLabel
var _notification_tween: Tween = null

func _ready() -> void:
    InventoryManager.inventory_full.connect(_on_inventory_full)
    notification_label.visible = false


func _on_inventory_full(item: ItemData, overflow: int) -> void:
    _show_notification("Inventory Full!", Color.RED)


func _show_notification(text: String, color: Color = Color.WHITE) -> void:
    if _notification_tween and _notification_tween.is_running():
        _notification_tween.kill()

    notification_label.text = text
    notification_label.add_theme_color_override("font_color", color)
    notification_label.visible = true
    notification_label.modulate.a = 1.0

    # Fade out after delay
    _notification_tween = create_tween()
    _notification_tween.tween_interval(2.0)  # Show for 2 seconds
    _notification_tween.tween_property(notification_label, "modulate:a", 0.0, 0.5)
    _notification_tween.tween_callback(func(): notification_label.visible = false)
```

### Notification UI Design

```
NotificationLabel (Label)
- Position: Top center of screen
- Font: Bold, size 28
- Color: Red (#FF4444)
- Outline: Black for visibility
- Animation: Fade in, hold 2s, fade out
```

### Visual Feedback Options

1. **Screen flash**: Brief red tint on screen edges
2. **Icon pulse**: Inventory icon pulses/shakes
3. **Floating text**: "+0" or "X" floating up from pickup location

```gdscript
# Option: Screen flash
func _on_inventory_full(item: ItemData, overflow: int) -> void:
    _show_notification("Inventory Full!", Color.RED)
    _flash_screen(Color(1, 0, 0, 0.2), 0.3)  # Red flash

func _flash_screen(color: Color, duration: float) -> void:
    var overlay := $ScreenOverlay
    overlay.color = color
    overlay.visible = true
    var tween := create_tween()
    tween.tween_property(overlay, "color:a", 0.0, duration)
    tween.tween_callback(func(): overlay.visible = false)
```

### Sound Cue (Optional)

```gdscript
@onready var full_sound: AudioStreamPlayer = $FullSound

func _on_inventory_full(item: ItemData, overflow: int) -> void:
    _show_notification("Inventory Full!", Color.RED)
    if full_sound:
        full_sound.play()
```

Use a short "error" or "denied" sound (like trying to do something invalid).

### Cooldown to Prevent Spam

If player keeps mining while full, don't spam notifications:

```gdscript
var _last_full_notification: float = 0.0
const NOTIFICATION_COOLDOWN := 3.0  # Seconds

func _on_inventory_full(item: ItemData, overflow: int) -> void:
    var now := Time.get_ticks_msec() / 1000.0
    if now - _last_full_notification < NOTIFICATION_COOLDOWN:
        return  # Don't spam

    _last_full_notification = now
    _show_notification("Inventory Full!", Color.RED)
```

## Edge Cases

- Multiple items overflow at once: Show single notification
- Player spamming dig on ore: Cooldown prevents notification spam
- Notification during screen transition: Ensure it's on CanvasLayer
- Very fast pickups: Batch notifications

## Verify

- [ ] Build succeeds
- [ ] Mining with full inventory shows "Inventory Full!" notification
- [ ] Notification is clearly visible (top center, red text)
- [ ] Notification fades out after ~2 seconds
- [ ] Rapid mining doesn't spam multiple notifications
- [ ] Notification works on all screen sizes
- [ ] Optional: Sound plays on notification
- [ ] Optional: Screen flashes red briefly
