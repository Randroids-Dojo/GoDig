---
title: "implement: Core game loop integration"
status: closed
priority: 0
issue-type: task
created-at: "2026-01-16T00:46:56.254705-06:00"
after:
  - GoDig-implement-shop-building-25de6397
  - GoDig-dev-inventory-ui-71ea78b3
close-reason: Implemented with GameManager states (MENU, PLAYING, PAUSED, SHOP, GAME_OVER), test_level.gd wiring dirt_grid to inventory, shop integration
---

## Description

Wire together the complete game loop: dig blocks, collect ore, return to surface when inventory full, sell at shop, buy upgrades, dig deeper. Implement game state management and transitions.

## Context

The game loop is the core player experience. Current implementation has individual systems (mining, inventory, shop) that need orchestration. The GameManager should coordinate state transitions and ensure smooth flow between activities.

## Affected Files

- `scripts/autoload/game_manager.gd` - Add game state enum and transitions
- `scripts/world/dirt_grid.gd` - Connect block_dropped to inventory
- `scripts/player/player.gd` - Emit events for loop tracking
- `scenes/ui/game_hud.tscn` - Display inventory fullness, depth
- `scenes/main.tscn` - Wire up signal connections

## Implementation Notes

### Game States

```gdscript
# game_manager.gd
enum GameState {
    MENU,       # Main menu
    PLAYING,    # Active mining
    SHOPPING,   # In shop UI
    PAUSED,     # Pause menu
    DEAD,       # Death sequence
}

var current_state: GameState = GameState.MENU

signal state_changed(new_state: GameState, old_state: GameState)

func change_state(new_state: GameState) -> void:
    var old_state := current_state
    current_state = new_state
    state_changed.emit(new_state, old_state)
```

### Loop Event Flow

1. **Dig block** -> `dirt_grid.block_dropped` signal
2. **Collect ore** -> `InventoryManager.add_item()` -> `item_added` signal
3. **Inventory full** -> `InventoryManager.inventory_full` signal -> HUD flash
4. **Return to surface** -> Player reaches y <= surface_row
5. **Enter shop** -> Player interacts with shop building -> state = SHOPPING
6. **Sell items** -> Shop UI calls `InventoryManager.remove_item()` + `GameManager.add_coins()`
7. **Buy upgrade** -> Shop UI calls `GameManager.spend_coins()` + `PlayerData.equip_tool()`
8. **Exit shop** -> state = PLAYING
9. **Dig deeper** -> Loop repeats

### Inventory Full Handling

```gdscript
# In main scene or HUD
func _ready():
    InventoryManager.inventory_full.connect(_on_inventory_full)

func _on_inventory_full():
    # Flash HUD inventory indicator red
    inventory_hud.flash_full_warning()

    # Optional: Show floating message "Inventory Full!"
    show_floating_text("Inventory Full!", player.position, Color.RED)
```

### Surface Detection

```gdscript
# player.gd
signal reached_surface

func _on_move_complete() -> void:
    grid_position = target_grid_position
    _update_depth()

    # Check if player reached surface
    if grid_position.y <= GameManager.SURFACE_ROW:
        reached_surface.emit()

    # ... rest of existing code
```

### Shop Interaction Flow

```gdscript
# shop_building.gd (Area2D near shop sprite)
func _on_body_entered(body):
    if body.is_in_group("player"):
        _show_interaction_prompt()

func _on_body_exited(body):
    if body.is_in_group("player"):
        _hide_interaction_prompt()

func interact():
    GameManager.change_state(GameManager.GameState.SHOPPING)
    shop_ui.open()
```

### Progress Tracking

```gdscript
# game_manager.gd
var total_blocks_mined: int = 0
var total_coins_earned: int = 0
var total_upgrades_purchased: int = 0

func track_block_mined() -> void:
    total_blocks_mined += 1

func track_sale(amount: int) -> void:
    total_coins_earned += amount

func track_upgrade() -> void:
    total_upgrades_purchased += 1
```

## Edge Cases

- Player quits mid-shop: Auto-save before state change
- Inventory full with no surface access: Player must drop items or continue
- Shop closed while shopping: Return to PLAYING state
- Player dies in shop (shouldn't happen): Force respawn

## Verify

- [ ] Build succeeds
- [ ] Mining a block adds ore to inventory
- [ ] Inventory full signal triggers when no space
- [ ] HUD shows inventory count updating
- [ ] Player can reach surface and interact with shop
- [ ] Selling items removes from inventory, adds coins
- [ ] Buying upgrades spends coins, equips tool
- [ ] Game state transitions correctly between states
- [ ] Progress tracking updates on each action
- [ ] Auto-save triggers on state changes
