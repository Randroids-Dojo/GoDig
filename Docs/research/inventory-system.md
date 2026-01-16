# Inventory System Research

## Sources
- [GLoot Universal Inventory](https://github.com/peter-kish/gloot)
- [Expresso Bits Inventory System](https://github.com/expressobits/inventory-system)
- [Godot Forum Grid Inventory](https://forum.godotengine.org/t/how-to-make-inventory-system-in-godot-tutorial/86730)
- [Supermatrix Studio RPG Inventory](https://supermatrix.studio/blog/creating-a-simple-inventory-system-for-a-2d-rpg-in-godot)
- [GameDev Academy Tutorial](https://gamedevacademy.org/godot-inventory-system-tutorial/)

## Design Goals for Mining Game

### Primary Functions
1. Store collected ores and gems
2. Limit capacity (forces return to surface)
3. Track quantities (stacking)
4. Quick sell interface
5. Mobile-friendly UI

### Constraints Options
- **Slot-based**: Fixed number of slots (Minecraft-style)
- **Weight-based**: Total weight capacity (Diablo-style)
- **Hybrid**: Slots + weight limit

## Recommended: Slot + Stack System

### Why Not Weight?
- Simpler for mobile UI
- Easier to understand
- Clear "full" state

### Slot Design
```
┌────┐ ┌────┐ ┌────┐ ┌────┐
│Coal│ │Iron│ │Gold│ │ -- │
│ 25 │ │ 12 │ │  3 │ │    │
└────┘ └────┘ └────┘ └────┘
┌────┐ ┌────┐ ┌────┐ ┌────┐
│ -- │ │ -- │ │ -- │ │ -- │
└────┘ └────┘ └────┘ └────┘
```
- Start with 8 slots
- Upgrade to 12, 16, 20, etc.
- Each slot holds one resource type
- Stack size varies by resource

## Item Resource Definition

```gdscript
# item_data.gd
class_name ItemData extends Resource

@export var id: String = ""
@export var name: String = ""
@export var icon: Texture2D
@export var description: String = ""
@export var category: String = "ore"  # ore, gem, artifact, tool
@export var max_stack: int = 99
@export var sell_value: int = 1
@export var tier: int = 1
@export var rarity: String = "common"  # common, uncommon, rare, etc.
```

## Inventory Implementation

### Inventory Manager Singleton
```gdscript
# inventory_manager.gd
extends Node

signal inventory_changed
signal inventory_full

var slots: Array[InventorySlot] = []
var max_slots: int = 8

class InventorySlot:
    var item: ItemData = null
    var quantity: int = 0

func _ready():
    _initialize_slots()

func _initialize_slots():
    slots.clear()
    for i in range(max_slots):
        slots.append(InventorySlot.new())
```

### Add Item Logic
```gdscript
func add_item(item: ItemData, amount: int = 1) -> int:
    """Add item to inventory. Returns amount that couldn't fit."""
    var remaining = amount

    # First, try to stack with existing
    for slot in slots:
        if slot.item == item:
            var space = item.max_stack - slot.quantity
            var to_add = min(space, remaining)
            slot.quantity += to_add
            remaining -= to_add
            if remaining <= 0:
                inventory_changed.emit()
                return 0

    # Then, try empty slots
    for slot in slots:
        if slot.item == null:
            slot.item = item
            var to_add = min(item.max_stack, remaining)
            slot.quantity = to_add
            remaining -= to_add
            if remaining <= 0:
                inventory_changed.emit()
                return 0

    # Inventory full
    if remaining > 0:
        inventory_full.emit()

    inventory_changed.emit()
    return remaining
```

### Remove/Consume Items
```gdscript
func remove_item(item: ItemData, amount: int = 1) -> bool:
    """Remove item from inventory. Returns true if successful."""
    if get_item_count(item) < amount:
        return false

    var to_remove = amount
    for slot in slots:
        if slot.item == item:
            var removed = min(slot.quantity, to_remove)
            slot.quantity -= removed
            to_remove -= removed
            if slot.quantity <= 0:
                slot.item = null
            if to_remove <= 0:
                break

    inventory_changed.emit()
    return true

func get_item_count(item: ItemData) -> int:
    var total = 0
    for slot in slots:
        if slot.item == item:
            total += slot.quantity
    return total
```

### Sell All
```gdscript
func sell_all() -> int:
    """Sell all items, return total coins earned."""
    var total_value = 0

    for slot in slots:
        if slot.item != null and slot.item.category in ["ore", "gem"]:
            total_value += slot.item.sell_value * slot.quantity
            slot.item = null
            slot.quantity = 0

    inventory_changed.emit()
    return total_value
```

## UI Design for Mobile

### Compact View (During Mining)
```
┌─────────────────────────────┐
│ [6/8 slots]  $1,234 coins   │
└─────────────────────────────┘
```
- Shows slot usage
- Tap to open full inventory

### Full Inventory Screen
```
┌─────────────────────────────────┐
│         INVENTORY (6/8)         │
├─────────────────────────────────┤
│  ┌────┐  ┌────┐  ┌────┐  ┌────┐ │
│  │Coal│  │Iron│  │Gold│  │Ruby│ │
│  │ 25 │  │ 12 │  │  3 │  │  1 │ │
│  │ $25│  │$120│  │$300│  │$500│ │
│  └────┘  └────┘  └────┘  └────┘ │
│  ┌────┐  ┌────┐  ┌────┐  ┌────┐ │
│  │Gems│  │ -- │  │ -- │  │ -- │ │
│  │  8 │  │    │  │    │  │    │ │
│  │ $80│  │    │  │    │  │    │ │
│  └────┘  └────┘  └────┘  └────┘ │
├─────────────────────────────────┤
│  Total Value: $1,025            │
│  ┌─────────────────────────────┐│
│  │     [SELL ALL - $1,025]    ││
│  └─────────────────────────────┘│
│  ┌────────────┐ ┌──────────────┐│
│  │  [CLOSE]   │ │[SORT BY VALUE││
│  └────────────┘ └──────────────┘│
└─────────────────────────────────┘
```

### Slot UI Node Structure
```
InventorySlot (Control)
├── Background (TextureRect) - Rarity color border
├── Icon (TextureRect) - Item sprite
├── QuantityLabel (Label) - "x25"
└── ValueLabel (Label) - "$100" (optional)
```

### Slot Script
```gdscript
# inventory_slot_ui.gd
extends Control

@onready var icon = $Icon
@onready var quantity_label = $QuantityLabel
@onready var background = $Background

var slot_data: InventoryManager.InventorySlot

func update_display(data: InventoryManager.InventorySlot):
    slot_data = data

    if data.item == null:
        icon.texture = null
        quantity_label.text = ""
        background.modulate = Color.WHITE
    else:
        icon.texture = data.item.icon
        quantity_label.text = "x%d" % data.quantity
        background.modulate = get_rarity_color(data.item.rarity)

func get_rarity_color(rarity: String) -> Color:
    match rarity:
        "common": return Color.WHITE
        "uncommon": return Color.GREEN
        "rare": return Color.BLUE
        "epic": return Color.PURPLE
        "legendary": return Color.ORANGE
        _: return Color.WHITE
```

## Upgrade System

### Backpack Upgrades
```gdscript
var backpack_levels = [
    {"slots": 8, "cost": 0, "name": "Starter Pouch"},
    {"slots": 12, "cost": 1000, "name": "Leather Bag"},
    {"slots": 16, "cost": 5000, "name": "Canvas Sack"},
    {"slots": 20, "cost": 15000, "name": "Mining Pack"},
    {"slots": 25, "cost": 50000, "name": "Deep Hauler"},
    {"slots": 30, "cost": 150000, "name": "Master's Vault"}
]

func upgrade_backpack():
    var current_level = get_backpack_level()
    if current_level >= backpack_levels.size() - 1:
        return false  # Max level

    var next = backpack_levels[current_level + 1]
    if coins >= next.cost:
        coins -= next.cost
        max_slots = next.slots
        _initialize_slots()
        return true
    return false
```

## Stack Size by Resource Type

| Category | Stack Size | Rationale |
|----------|------------|-----------|
| Common Ore | 99 | Collect lots |
| Uncommon Ore | 50 | Less common |
| Rare Ore | 25 | Valuable |
| Gems | 20 | Special |
| Artifacts | 1 | Unique items |
| Tools | 1 | Equipped |
| Consumables | 50 | Ladders, etc. |

## Auto-Pickup vs Manual

### Auto-Pickup (Recommended)
- Automatically collect resources when dug
- Shows floating "+1 Coal" indicator
- Cleaner gameplay

### Manual Pickup
- Resources drop on ground
- Player must collect
- Adds complexity, little value

## Questions to Resolve
- [ ] Use existing plugin (GLoot) or custom?
- [ ] Start with 8 or more slots?
- [ ] Show individual values or just total?
- [ ] Sort options (type, value, quantity)?
- [ ] Quick-sell from HUD without opening full inventory?
