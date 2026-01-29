---
title: "implement: Teleport scroll item"
status: closed
close_reason: Implemented in session claude/next-ten-tasks-thE2H
priority: 3
issue-type: task
created-at: "2026-01-16T00:43:49.318659-06:00"
after:
  - GoDig-dev-inventory-ui-71ea78b3
  - GoDig-dev-surface-area-379633b2
---

## Description

Implement a rare consumable item that instantly teleports the player back to the surface. Emergency escape option for dangerous situations.

## Context

- Safety net for players who get stuck or are about to die
- Expensive/rare to prevent abuse
- Keeps inventory intact (unlike death penalty)
- Can be found randomly or bought at high cost
- See research: GoDig-research-movement-traversal-cee4601c

## Affected Files

- `resources/items/teleport_scroll.tres` - NEW: Item definition
- `scripts/player/player.gd` - Add use_item() method for consumables
- `scripts/autoload/inventory_manager.gd` - Item use handling
- `scenes/ui/hud.tscn` - Optional: Quick-use slot for scroll
- `scripts/autoload/game_manager.gd` - Teleport execution

## Implementation Notes

### Item Definition

```
# resources/items/teleport_scroll.tres
[resource]
script = ExtResource("item_data.gd")
id = "teleport_scroll"
display_name = "Teleport Scroll"
description = "Instantly return to the surface. Single use."
category = "consumable"
icon = preload("res://assets/items/teleport_scroll.png")
max_stack = 5
sell_value = 500  # Sell for half purchase price
rarity = 2  # Rare
min_depth = 0  # Can be used anywhere
```

### Item Use Flow

```gdscript
# inventory_manager.gd
signal item_used(item: ItemData)

func use_item(item: ItemData) -> bool:
    if item.category != "consumable":
        return false

    if get_item_count(item) <= 0:
        return false

    # Remove one from inventory
    remove_item(item, 1)

    # Emit signal for game to handle effect
    item_used.emit(item)
    return true
```

### Teleport Execution

```gdscript
# game_manager.gd
func _ready() -> void:
    InventoryManager.item_used.connect(_on_item_used)

func _on_item_used(item: ItemData) -> void:
    match item.id:
        "teleport_scroll":
            _teleport_to_surface()
        # Future: other consumables

func _teleport_to_surface() -> void:
    # Visual effect: flash and swirl
    await _play_teleport_effect()

    # Move player to surface spawn
    player.global_position = surface_spawn_position
    player.grid_position = surface_spawn_grid
    player.velocity = Vector2.ZERO
    player.current_state = Player.State.IDLE

    # Update camera
    camera.global_position = player.global_position

    # Clear any active mining/falling states
    player.cancel_current_action()

    # Play arrival effect
    _play_arrival_effect()
```

### Teleport Visual Effects

```gdscript
func _play_teleport_effect() -> Tween:
    # Screen flash white
    var tween := create_tween()
    screen_flash.modulate.a = 0
    tween.tween_property(screen_flash, "modulate:a", 1.0, 0.2)

    # Player spin and shrink
    var player_tween := player.create_tween()
    player_tween.parallel().tween_property(player, "scale", Vector2.ZERO, 0.3)
    player_tween.parallel().tween_property(player, "rotation", TAU * 2, 0.3)

    await tween.finished

func _play_arrival_effect() -> void:
    # Player grow back
    player.scale = Vector2.ZERO
    player.rotation = 0
    var tween := player.create_tween()
    tween.tween_property(player, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK)

    # Screen flash fade out
    var screen_tween := create_tween()
    screen_tween.tween_property(screen_flash, "modulate:a", 0.0, 0.3)

    # Sparkle particles at arrival point (optional)
```

### Acquisition Methods

1. **Shop Purchase**: 1000 coins at General Store
2. **Rare Drop**: 1% chance from epic/legendary ore blocks
3. **Depth Milestone**: Free scroll at 500m, 1000m, 2000m first reach

```gdscript
# dirt_grid.gd - Random drop on rare ore
func _on_block_destroyed(pos: Vector2i, ore_id: String) -> void:
    var ore := DataRegistry.get_ore(ore_id)
    if ore and ore.rarity >= 3:  # Epic or Legendary
        if randf() < 0.01:  # 1% chance
            _spawn_item_drop(pos, "teleport_scroll")
```

### HUD Quick-Use (Optional)

Similar to ladder quick-slot, show scroll count with one-tap use:

```gdscript
# scroll_quickslot.gd
func _on_pressed() -> void:
    var scroll := DataRegistry.get_item("teleport_scroll")
    if InventoryManager.use_item(scroll):
        # Effect handled by GameManager
        pass
    else:
        _flash_empty()
```

### Use Restrictions

- Cannot use during active mining animation
- Cannot use while in shop UI
- Cannot use if already at surface (waste prevention)
- Can use while falling (emergency save)

```gdscript
func can_use_teleport_scroll() -> bool:
    if player.current_state == Player.State.MINING:
        return false
    if GameManager.current_state == GameManager.GameState.SHOPPING:
        return false
    if player.grid_position.y <= GameManager.SURFACE_ROW:
        return false  # Already at surface
    return true
```

## Edge Cases

- Used while falling: Teleport immediately, cancel fall
- Used with full inventory: Keep all items (no penalty)
- Multiple scrolls: Only consumes one
- Used at surface: Prevent use, show "Already at surface"
- No scrolls: Button disabled/grayed

## Verify

- [ ] Build succeeds
- [ ] Teleport scroll appears in shop for 1000 coins
- [ ] Using scroll teleports player to surface
- [ ] One scroll consumed on use
- [ ] Visual teleport effect plays
- [ ] Inventory preserved after teleport
- [ ] Cannot use when already at surface
- [ ] Cannot use during mining animation
- [ ] Can use while falling (emergency)
- [ ] Scroll drops rarely from epic+ ores
