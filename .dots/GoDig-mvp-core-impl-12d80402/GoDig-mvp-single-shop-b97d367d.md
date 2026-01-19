---
title: "implement: Single shop (buy/sell)"
status: open
priority: 0
issue-type: task
created-at: "2026-01-16T00:34:24.664393-06:00"
after:
  - GoDig-mvp-basic-inventory-851ca931
---

## Description

Create a single unified shop for MVP that handles selling resources and buying tool upgrades. Located on surface, accessed when player walks to shop area.

## Context

The shop closes the economy loop: dig resources → sell → buy upgrades → dig better. MVP needs only one shop combining General Store (sell) + Blacksmith (upgrades) functionality. More specialized shops come in v1.0.

## Affected Files

- `scenes/ui/shop.tscn` - NEW: Shop UI scene (popup panel)
- `scripts/ui/shop.gd` - NEW: Shop logic and UI control
- `scenes/surface/shop_building.tscn` - NEW: Interactive building on surface
- `scripts/surface/shop_building.gd` - NEW: Triggers shop open on player interaction
- `scripts/autoload/economy_manager.gd` - NEW: Tracks coins, handles transactions

## Implementation Notes

### EconomyManager Singleton

```gdscript
extends Node

signal coins_changed(amount: int)

var coins: int = 0

func add_coins(amount: int) -> void:
    coins += amount
    coins_changed.emit(coins)

func spend_coins(amount: int) -> bool:
    if coins >= amount:
        coins -= amount
        coins_changed.emit(coins)
        return true
    return false
```

### Shop UI Layout (Portrait)

```
┌─────────────────────────────────┐
│        TRADING POST             │
│     Coins: $1,234               │
├─────────────────────────────────┤
│  [SELL]    [UPGRADES]           │  ← Tab buttons
├─────────────────────────────────┤
│                                 │
│   SELL TAB:                     │
│   ┌────┐ ┌────┐ ┌────┐         │
│   │Coal│ │Iron│ │Gold│         │
│   │x25 │ │x12 │ │ x3 │         │
│   │$25 │ │$120│ │$300│         │
│   └────┘ └────┘ └────┘         │
│                                 │
│   Total: $445                   │
│   [SELL ALL]                    │
│                                 │
├─────────────────────────────────┤
│  [CLOSE]                        │
└─────────────────────────────────┘
```

### Sell Tab Logic

1. Display all sellable items from InventoryManager
2. Show item icon, quantity, total value
3. "Sell All" button sells everything at once
4. Individual tap to sell single item type
5. Update coins via EconomyManager

```gdscript
func sell_all() -> void:
    var total = 0
    for slot in InventoryManager.slots:
        if slot.item != null and slot.item.category in ["ore", "gem"]:
            total += slot.item.sell_value * slot.quantity
    EconomyManager.add_coins(total)
    InventoryManager.clear_sellable()
    _refresh_ui()
```

### Upgrades Tab Layout

```
   UPGRADES TAB:

   Pickaxe: Level 1 → 2
   Damage: 10 → 20
   Cost: 500 coins
   [UPGRADE - $500]

   Backpack: Level 1 → 2
   Slots: 8 → 12
   Cost: 1,000 coins
   [LOCKED - Reach 50m]
```

### Tool Upgrade Data

```gdscript
var tool_upgrades = [
    {"level": 1, "damage": 10, "cost": 0, "name": "Rusty Pickaxe"},
    {"level": 2, "damage": 20, "cost": 500, "name": "Copper Pickaxe"},
    {"level": 3, "damage": 35, "cost": 2000, "name": "Iron Pickaxe"},
]
```

### Shop Building Interaction

1. Player walks into shop Area2D on surface
2. "Shop" button appears in HUD
3. Tap button opens shop UI
4. Shop pauses game (or covers entire screen)
5. Close button exits shop

```gdscript
# shop_building.gd
extends Area2D

func _on_body_entered(body):
    if body.name == "Player":
        GameManager.show_shop_button(true)

func _on_body_exited(body):
    if body.name == "Player":
        GameManager.show_shop_button(false)
```

## Edge Cases

- Selling when inventory empty: Disable sell button, show message
- Buying when insufficient coins: Disable upgrade button, gray out
- Max upgrade level: Show "MAX" instead of upgrade button
- Locked upgrades: Show requirement ("Reach 100m depth")

## Verify

- [ ] Build succeeds with no errors
- [ ] EconomyManager autoload tracks coins correctly
- [ ] Shop opens when player enters shop area and taps button
- [ ] Sell tab shows all sellable inventory items
- [ ] Sell All calculates correct total and updates coins
- [ ] After selling, inventory is emptied and coins increase
- [ ] Upgrades tab shows current tool level and next upgrade
- [ ] Cannot buy upgrade with insufficient coins
- [ ] Buying upgrade deducts coins and updates player tool
- [ ] Shop closes cleanly when Close button tapped
