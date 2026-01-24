---
title: "implement: Shop building on surface with interaction"
status: closed
priority: 1
issue-type: task
created-at: "\"2026-01-18T23:49:26.149740-06:00\""
closed-at: "2026-01-24T05:39:14.907415+00:00"
close-reason: Shop button now shows/hides based on player proximity to shop building
---

Create shop_building.tscn with Area2D for player detection. When player enters, emit signal to show 'Shop' button in HUD. When player exits, hide button. Requires surface scene to exist first.

## Description

Create the physical shop building on the surface that the player can walk up to and interact with. The building uses Area2D to detect when the player is nearby, which triggers a HUD button to appear.

## Context

- Shop UI exists (`scenes/ui/shop.tscn`) but there's no way to access it in-game
- MVP spec calls for walking to shop area and seeing a "Shop" button
- This creates the physical presence and interaction trigger

## Affected Files

- `scenes/surface/shop_building.tscn` - NEW: Physical building with Area2D
- `scripts/surface/shop_building.gd` - NEW: Interaction detection script
- `scripts/ui/hud.gd` or similar - Show/hide shop button based on proximity
- Test level or surface scene - Add shop building instance

## Implementation Notes

### Shop Building Scene Structure

```
ShopBuilding (Node2D)
├─ Sprite2D (visual representation)
└─ InteractionArea (Area2D)
   └─ CollisionShape2D (2x player width detection zone)
```

### Shop Building Script

```gdscript
# shop_building.gd
extends Node2D

signal player_entered
signal player_exited

@onready var interaction_area: Area2D = $InteractionArea


func _ready() -> void:
    interaction_area.body_entered.connect(_on_body_entered)
    interaction_area.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
    if body.name == "Player" or body.is_in_group("player"):
        player_entered.emit()


func _on_body_exited(body: Node2D) -> void:
    if body.name == "Player" or body.is_in_group("player"):
        player_exited.emit()
```

### HUD Shop Button Integration

Option A: GameManager signals (cleaner)
```gdscript
# game_manager.gd
signal shop_interaction_available(available: bool)

func set_shop_available(available: bool) -> void:
    shop_interaction_available.emit(available)
```

Option B: Direct connection in level script
```gdscript
# test_level.gd or surface.gd
shop_building.player_entered.connect(func(): shop_button.visible = true)
shop_building.player_exited.connect(func(): shop_button.visible = false)
```

### Visual Design Notes

For MVP, use a simple colored rectangle or placeholder sprite. The shop should:
- Be clearly visible on the surface
- Be wide enough for player to walk in front of
- Have a sign or indicator (e.g., "$" symbol)

## Verify

- [ ] Shop building appears on surface at correct position
- [ ] Walking near shop shows "Shop" button in HUD
- [ ] Walking away hides the button
- [ ] Tapping button opens shop UI
- [ ] Shop works correctly when opened from HUD button
- [ ] Player can still move while near shop (until shop is opened)
