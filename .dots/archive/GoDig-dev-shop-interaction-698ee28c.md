---
title: "implement: Shop interaction system"
status: closed
priority: 2
issue-type: task
created-at: "2026-01-16T01:02:03.895696-06:00"
after:
  - GoDig-implement-shop-building-25de6397
close-reason: Implemented in scripts/test_level.gd with _connect_shop_building, _on_shop_building_entered/exited handlers that show shop button and open shop UI
---

## Description

Implement the full shop interaction flow: player approaches shop, HUD shows "Shop" button, player taps button, shop UI opens, player can buy/sell items, closing shop returns to gameplay.

## Context

This connects the shop building detection (GoDig-implement-shop-building-25de6397) to the existing shop UI (`scenes/ui/shop.tscn`). The shop building emits signals when the player is nearby; this system responds to those signals and manages the shop UI lifecycle.

## Affected Files

- `scripts/ui/hud.gd` - Add shop button visibility control
- `scenes/ui/hud.tscn` - Add hidden "Shop" button
- `scripts/autoload/game_manager.gd` - Add shop state management
- `scenes/ui/shop.tscn` - Existing shop UI (may need close button)
- `scripts/ui/shop.gd` - Connect to GameManager for state changes

## Implementation Notes

### HUD Shop Button

```gdscript
# hud.gd (additions)
@onready var shop_button: Button = $ShopButton

func _ready():
    shop_button.visible = false
    shop_button.pressed.connect(_on_shop_button_pressed)
    GameManager.shop_interaction_available.connect(_on_shop_available)

func _on_shop_available(available: bool) -> void:
    shop_button.visible = available

func _on_shop_button_pressed() -> void:
    GameManager.open_shop()
```

### GameManager Shop State

```gdscript
# game_manager.gd (additions)
signal shop_interaction_available(available: bool)
signal shop_opened
signal shop_closed

var shop_ui: Control  # Set by level scene
var _player_near_shop: bool = false

func set_shop_available(available: bool) -> void:
    _player_near_shop = available
    shop_interaction_available.emit(available)

func open_shop() -> void:
    if not _player_near_shop:
        return
    if shop_ui:
        shop_ui.visible = true
        shop_ui.refresh()  # Update inventory/prices
    get_tree().paused = true  # Pause gameplay
    shop_opened.emit()

func close_shop() -> void:
    if shop_ui:
        shop_ui.visible = false
    get_tree().paused = false
    shop_closed.emit()
```

### Shop UI Close Handler

```gdscript
# shop.gd (additions)
func _on_close_button_pressed() -> void:
    GameManager.close_shop()

func _input(event: InputEvent) -> void:
    # Allow closing with back/escape
    if event.is_action_pressed("ui_cancel"):
        GameManager.close_shop()
```

### Level Wiring

```gdscript
# test_level.gd or main.gd
func _ready():
    # Wire shop building to GameManager
    shop_building.player_entered.connect(func(): GameManager.set_shop_available(true))
    shop_building.player_exited.connect(func(): GameManager.set_shop_available(false))

    # Give GameManager reference to shop UI
    GameManager.shop_ui = $HUD/ShopUI
```

## Edge Cases

- Player dies near shop: Close shop, respawn flow takes over
- Player opens shop while falling: Should not be possible (check state)
- Shop closed while transaction pending: Cancel/complete transaction first
- Multiple shop buildings: Only one should be active at a time

## Verify

- [ ] Build succeeds
- [ ] Walking near shop shows "Shop" button in HUD
- [ ] Walking away hides the button
- [ ] Tapping "Shop" button opens shop UI
- [ ] Game pauses while shop is open
- [ ] Closing shop resumes gameplay
- [ ] Back/Escape closes shop
- [ ] Player cannot move while shop is open
- [ ] Shop refreshes inventory display when opened
