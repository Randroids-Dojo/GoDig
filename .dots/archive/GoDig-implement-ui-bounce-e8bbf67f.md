---
title: "implement: UI bounce and pop effects"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-19T01:35:30.663386-06:00\""
closed-at: "2026-01-25T02:17:03.446183+00:00"
close-reason: Implemented pop/bounce effect for floating text
---

Button press feedback, coin counter animation, inventory icon bounce on pickup. Makes UI feel responsive and alive.

## Description

Add bounce, scale, and pop animations to UI elements to make interactions feel satisfying. Includes button press feedback, number counting animations, and icon bounces.

## Context

- UI is currently static - buttons don't respond visually
- Mobile games need extra feedback to compensate for lack of tactile buttons
- Number animations make progress feel more real
- See Docs/research/game-feel-juice.md for UI bounce/pop patterns

## Affected Files

- `scripts/ui/ui_effects.gd` - NEW: Utility class for UI animations
- `scripts/ui/touch_controls.gd` - Add button press feedback
- `scripts/ui/coin_counter.gd` - Add number counting animation (if exists)
- Any UI button scripts - Connect pressed signals

## Implementation Notes

### UI Effects Utility Class

```gdscript
# ui_effects.gd
class_name UIEffects
extends RefCounted

## Bounce a control - shrink then grow then return
static func bounce(control: Control, scale_down: float = 0.85, scale_up: float = 1.15, duration: float = 0.15) -> void:
    var original_scale := control.scale
    var pivot := control.size / 2
    control.pivot_offset = pivot

    var tween := control.create_tween()
    tween.tween_property(control, "scale", original_scale * scale_down, duration * 0.3)
    tween.tween_property(control, "scale", original_scale * scale_up, duration * 0.3)
    tween.tween_property(control, "scale", original_scale, duration * 0.4)


## Pop effect - quick scale up then return
static func pop(control: Control, scale: float = 1.2, duration: float = 0.1) -> void:
    var original_scale := control.scale
    control.pivot_offset = control.size / 2

    var tween := control.create_tween()
    tween.tween_property(control, "scale", original_scale * scale, duration * 0.4)
    tween.tween_property(control, "scale", original_scale, duration * 0.6)


## Shake a control horizontally (for errors/invalid actions)
static func shake(control: Control, intensity: float = 10.0, duration: float = 0.3) -> void:
    var original_pos := control.position
    var tween := control.create_tween()

    for i in 4:
        var offset := intensity * (1.0 - (i / 4.0))
        tween.tween_property(control, "position:x", original_pos.x + offset, duration / 8)
        tween.tween_property(control, "position:x", original_pos.x - offset, duration / 8)

    tween.tween_property(control, "position", original_pos, duration / 8)


## Count up/down number animation
static func animate_number(label: Label, from: int, to: int, duration: float = 0.5, format: String = "%d") -> void:
    var tween := label.create_tween()
    tween.tween_method(
        func(val: float): label.text = format % int(val),
        float(from),
        float(to),
        duration
    ).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
```

### Button Press Feedback

```gdscript
# For any Button or TouchScreenButton
func _on_button_pressed() -> void:
    UIEffects.bounce(self)
    # Optionally trigger haptics
    if HapticsManager:
        HapticsManager.light()

# Connect in _ready()
func _ready() -> void:
    pressed.connect(_on_button_pressed)
```

### Touch Controls Integration

```gdscript
# touch_controls.gd additions
func _on_jump_button_pressed() -> void:
    UIEffects.bounce($JumpButton, 0.8, 1.1, 0.1)
    player.trigger_jump()

func _on_dig_button_pressed() -> void:
    UIEffects.bounce($DigButton, 0.85, 1.1, 0.1)
    # ...dig logic...
```

### Coin Counter Animation

```gdscript
# coin_counter.gd (or wherever coin display is)
@onready var coin_label: Label = $CoinLabel
var _displayed_coins: int = 0

func _ready() -> void:
    GameManager.coins_changed.connect(_on_coins_changed)
    _displayed_coins = GameManager.coins

func _on_coins_changed(new_amount: int) -> void:
    # Animate from current displayed value to new value
    UIEffects.animate_number(coin_label, _displayed_coins, new_amount, 0.3, "%d")
    _displayed_coins = new_amount

    # Pop the icon if coins increased
    if new_amount > _displayed_coins:
        UIEffects.pop($CoinIcon, 1.3, 0.15)
```

### Inventory Slot Bounce

```gdscript
# When item is added to inventory, bounce the slot
func _on_item_added(item: ItemData, slot_index: int) -> void:
    var slot := inventory_slots[slot_index]
    UIEffects.pop(slot, 1.2, 0.15)
```

### Error/Invalid Feedback

```gdscript
# When player can't afford something
func _on_purchase_failed() -> void:
    UIEffects.shake($PriceLabel, 8.0, 0.2)
    # Optionally flash red
    var tween := create_tween()
    tween.tween_property($PriceLabel, "modulate", Color.RED, 0.1)
    tween.tween_property($PriceLabel, "modulate", Color.WHITE, 0.2)
```

### Animation Timing Guide

| Element | Effect | Scale/Duration |
|---------|--------|----------------|
| Button press | bounce | 0.85 -> 1.15, 0.15s |
| Pickup icon | pop | 1.3, 0.15s |
| Number change | count | 0.3-0.5s |
| Error/invalid | shake | 10px, 0.3s |
| Achievement | pop | 1.4, 0.2s |
| Menu open | scale in | 0 -> 1.0, 0.2s |

### Performance Note

- Tween-based animations are very lightweight
- Avoid creating new tweens if one is already running (kill first)
- UI effects should never impact game performance

## Verify

- [ ] Pressing any button triggers visible bounce
- [ ] Coin counter counts up when receiving coins
- [ ] Inventory icon pops when item is added
- [ ] Failed purchase shakes the price label
- [ ] Animations don't stack/compound
- [ ] No visual glitches on rapid button pressing
- [ ] Animations feel snappy, not sluggish
- [ ] Effects work on all screen sizes
