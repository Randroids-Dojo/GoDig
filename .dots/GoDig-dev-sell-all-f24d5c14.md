---
title: "implement: Sell all button"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T00:45:21.954561-06:00"
after:
  - GoDig-dev-shop-interaction-698ee28c
---

## Description

Add a "Sell All" button to the shop UI that sells all sellable items in the player's inventory with a single tap. This is critical for mobile gameplay flow.

## Context

- Players will make frequent trips to sell ore
- Manual selling item-by-item is tedious on mobile
- Quick sell = better session pacing
- MVP requirement per inventory design doc

## Affected Files

- `scripts/ui/shop.gd` - Add sell_all() method
- `scenes/ui/shop.tscn` - Add Sell All button
- `scripts/autoload/inventory_manager.gd` - May need sell_all helper

## Implementation Notes

### Shop Script

```gdscript
# shop.gd
@onready var sell_all_button: Button = $SellAllButton
@onready var total_value_label: Label = $TotalValueLabel

func _ready() -> void:
    sell_all_button.pressed.connect(_on_sell_all_pressed)
    _update_sell_all_preview()


func _on_sell_all_pressed() -> void:
    var total_earned := 0
    var items_sold := 0

    # Get all sellable items
    var inventory := InventoryManager.get_all_items()
    for slot in inventory:
        if slot.item == null:
            continue
        if not _is_sellable(slot.item):
            continue

        var value := slot.item.sell_value * slot.quantity
        total_earned += value
        items_sold += slot.quantity
        InventoryManager.remove_item(slot.item, slot.quantity)

    if total_earned > 0:
        GameManager.add_coins(total_earned)
        _show_sell_feedback(items_sold, total_earned)
    else:
        _show_nothing_to_sell()

    _update_sell_all_preview()


func _is_sellable(item: ItemData) -> bool:
    # All ores and gems are sellable
    # Tools and equipment are NOT sellable (prevent accidental loss)
    return item.category in ["ore", "gem", "treasure"]


func _update_sell_all_preview() -> void:
    var total_value := 0
    var inventory := InventoryManager.get_all_items()
    for slot in inventory:
        if slot.item == null:
            continue
        if not _is_sellable(slot.item):
            continue
        total_value += slot.item.sell_value * slot.quantity

    if total_value > 0:
        total_value_label.text = "Sell All: %d coins" % total_value
        sell_all_button.disabled = false
    else:
        total_value_label.text = "Nothing to sell"
        sell_all_button.disabled = true


func _show_sell_feedback(count: int, total: int) -> void:
    # Show floating text or notification
    # "Sold 15 items for 250 coins!"
    pass


func _show_nothing_to_sell() -> void:
    # Brief message if button pressed with empty inventory
    pass
```

### UI Layout

```
Shop (Control)
├── Header
│   └── "General Store"
├── InventoryDisplay (shows what player has)
├── TotalValueLabel ("Sell All: 150 coins")
├── SellAllButton (large, prominent)
└── CloseButton
```

### Mobile-Friendly Design

- Sell All button should be large (at least 64px touch target)
- Positioned prominently (center-bottom or right side)
- Show preview of total value before pressing
- Haptic feedback on successful sale (if enabled)

### Edge Cases

- Empty inventory: Disable button, show "Nothing to sell"
- Only non-sellable items: Same as empty
- Very large sale (100+ items): Show summary, not individual items
- Sell during shop open: Update preview in real-time if items change

## Verify

- [ ] Build succeeds
- [ ] Sell All button visible in shop UI
- [ ] Button shows total value of sellable items
- [ ] Pressing button sells all ores/gems
- [ ] Coins are added correctly to player balance
- [ ] Items are removed from inventory
- [ ] Button disabled when nothing to sell
- [ ] Non-sellable items (tools) are NOT sold
- [ ] Visual/audio feedback on sale
