---
title: "implement: Basic inventory system"
status: closed
priority: 0
issue-type: task
created-at: "\"\\\"2026-01-16T00:34:24.016141-06:00\\\"\""
closed-at: "2026-01-18T23:25:34.618593-06:00"
close-reason: InventoryManager autoload with slot-based storage, stacking, add/remove logic. 19 tests passing.
---

## Description

Create a slot-based inventory system that stores collected ores and gems. Limited capacity forces return trips to the surface, which is the core tension of the game loop.

## Context

The inventory creates a natural "turn-around" point in expeditions. Players dig until full, then must return to sell. Start with 8 slots, upgradeable to 30.

## Affected Files

- `scripts/autoload/inventory_manager.gd` - NEW: Singleton managing inventory state
- `resources/items/item_data.gd` - NEW: Resource class defining item properties
- `project.godot` - Add InventoryManager to autoload

## Implementation Notes

### InventorySlot Inner Class

```gdscript
class InventorySlot:
    var item: ItemData = null
    var quantity: int = 0
```

### InventoryManager Singleton

```gdscript
extends Node

signal inventory_changed
signal inventory_full

var slots: Array = []  # Array of InventorySlot
var max_slots: int = 8

func _ready():
    _initialize_slots()

func _initialize_slots():
    slots.clear()
    for i in range(max_slots):
        slots.append(InventorySlot.new())
```

### Add Item Logic

1. First, find existing stack of same item type with space
2. Add to that stack up to max_stack
3. If remaining, find empty slot
4. If no space, emit `inventory_full` signal
5. Return amount that couldn't fit (for floating text feedback)

```gdscript
func add_item(item: ItemData, amount: int = 1) -> int:
    var remaining = amount

    # Stack with existing
    for slot in slots:
        if slot.item == item:
            var space = item.max_stack - slot.quantity
            var to_add = min(space, remaining)
            slot.quantity += to_add
            remaining -= to_add
            if remaining <= 0:
                inventory_changed.emit()
                return 0

    # Use empty slots
    for slot in slots:
        if slot.item == null:
            slot.item = item
            var to_add = min(item.max_stack, remaining)
            slot.quantity = to_add
            remaining -= to_add
            if remaining <= 0:
                inventory_changed.emit()
                return 0

    if remaining > 0:
        inventory_full.emit()
    inventory_changed.emit()
    return remaining
```

### Remove Item Logic

```gdscript
func remove_item(item: ItemData, amount: int = 1) -> bool:
    if get_item_count(item) < amount:
        return false
    # Remove from slots...
    return true

func get_item_count(item: ItemData) -> int:
    var total = 0
    for slot in slots:
        if slot.item == item:
            total += slot.quantity
    return total
```

### ItemData Resource

```gdscript
class_name ItemData extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var icon: Texture2D
@export var category: String = "ore"  # ore, gem, artifact, consumable
@export var max_stack: int = 99
@export var sell_value: int = 1
@export var rarity: String = "common"
```

### Auto-Pickup Integration

When player breaks a block that drops items:
1. Block signals destruction with drop data
2. InventoryManager.add_item() called
3. If returns > 0, show "Inventory Full" notification
4. Show floating "+1 Coal" text at block position

### HUD Display (Minimal for MVP)

Show in corner: `[6/8]` (slots used / total)
Tap to open full inventory view (v1.0 feature)

## Edge Cases

- Stack overflow: If stack hits max, spill to new slot
- All slots full: Return remaining amount to caller
- Same item in multiple slots: Sum totals for count queries

## Verify

- [ ] Build succeeds with no errors
- [ ] InventoryManager autoload is registered in project.godot
- [ ] Adding item to empty inventory works
- [ ] Adding item stacks with existing same-type item
- [ ] Adding item creates new slot when existing stacks full
- [ ] inventory_full signal fires when no space left
- [ ] get_item_count returns correct total across all slots
- [ ] remove_item decrements quantity correctly
- [ ] Slot clears (item = null) when quantity reaches 0
