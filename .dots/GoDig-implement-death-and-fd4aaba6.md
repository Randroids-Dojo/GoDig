---
title: "implement: Death and respawn system"
status: open
priority: 1
issue-type: task
created-at: "2026-01-19T00:52:47.235475-06:00"
after:
  - GoDig-implement-player-hp-4f3e9af1
  - GoDig-dev-surface-area-379633b2
---

## Description

Handle player death: animation, penalty calculation, and respawn at surface.

## Context

When HP reaches 0, player dies, loses some inventory/coins based on depth, and respawns at surface. Should feel consequential but not frustrating.

## Affected Files

- `scripts/player/player.gd` - Add death signal, death animation method
- `scripts/autoload/game_manager.gd` - Coordinate death/respawn flow, death penalty calc
- `scripts/autoload/inventory_manager.gd` - Add `get_total_item_count()` and `remove_random_item()` methods
- `scenes/ui/death_screen.tscn` - NEW: Death overlay scene
- `scripts/ui/death_screen.gd` - NEW: Show death message and respawn

## Implementation Notes

### Death Flow in GameManager
```gdscript
# game_manager.gd
func _ready():
    player.player_died.connect(_on_player_died)

func _on_player_died():
    # 1. Pause game
    get_tree().paused = true

    # 2. Play death animation
    player.play_death_animation()
    await player.animation_finished

    # 3. Calculate penalty based on depth
    var penalty = calculate_death_penalty(player.current_depth)

    # 4. Apply penalty
    apply_death_penalty(penalty)

    # 5. Fade to black
    await screen_fade.fade_out()

    # 6. Respawn
    player.position = surface_spawn_position
    player.current_hp = player.MAX_HP

    # 7. Show death message
    show_death_message(penalty)

    # 8. Fade in and resume
    await screen_fade.fade_in()
    get_tree().paused = false
```

### Death Penalty Calculation
```gdscript
func calculate_death_penalty(depth: int) -> Dictionary:
    var penalty = {
        'inventory_loss': 0.1,
        'coin_loss': 0.0,
        'equipment_damage': 0.05
    }

    if depth >= 500:
        penalty.inventory_loss = 0.2
        penalty.coin_loss = 0.05
        penalty.equipment_damage = 0.15

    if depth >= 2000:
        penalty.inventory_loss = 0.3
        penalty.coin_loss = 0.10
        penalty.equipment_damage = 0.25

    return penalty
```

### Apply Inventory Loss
```gdscript
func apply_inventory_loss(percent: float):
    var total_items = InventoryManager.get_total_item_count()
    var items_to_remove = int(total_items * percent)

    for i in range(items_to_remove):
        InventoryManager.remove_random_item()
```

### NEW: Required InventoryManager Methods

These methods need to be added to `inventory_manager.gd`:

```gdscript
## Get total count of all items across all slots
func get_total_item_count() -> int:
    var total := 0
    for slot in slots:
        if not slot.is_empty():
            total += slot.quantity
    return total


## Remove one random item from inventory (for death penalty)
## Removes from the slot with the lowest-value item first
func remove_random_item() -> bool:
    # Find all non-empty slots
    var occupied: Array = []
    for i in range(slots.size()):
        if not slots[i].is_empty():
            occupied.append(i)

    if occupied.is_empty():
        return false

    # Pick a random slot
    var target_idx: int = occupied[randi() % occupied.size()]
    var slot = slots[target_idx]

    # Remove one item
    slot.quantity -= 1
    if slot.quantity <= 0:
        slot.clear()

    inventory_changed.emit()
    return true
```

### Death Animation (Simple)
```gdscript
# player.gd
func play_death_animation():
    # Flash red
    for i in range(3):
        modulate = Color.RED
        await get_tree().create_timer(0.1).timeout
        modulate = Color.WHITE
        await get_tree().create_timer(0.1).timeout

    # Collapse/poof
    animation_player.play('death')
```

### Death Messages
```gdscript
const DEATH_MESSAGES = [
    'You blacked out and woke up on the surface.',
    'The rescue team found you. Some cargo was lost.',
    'You barely escaped with your life.',
    'The depths nearly claimed you...'
]
```

## Verify

- [ ] Build succeeds
- [ ] Player death triggers on HP reaching 0
- [ ] Death animation plays before respawn
- [ ] Inventory loss is applied (10-30% based on depth)
- [ ] Coin loss is applied for deep deaths
- [ ] Player respawns at surface spawn point
- [ ] Player HP is restored to full
- [ ] Death message is shown
- [ ] Game unpauses after respawn
