---
title: "implement: Inventory UI (mobile-friendly)"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-16T00:38:32.802842-06:00\""
closed-at: "2026-01-19T19:35:43.581413-06:00"
close-reason: Inventory UI in shop.tscn
---

## Description

Create a mobile-friendly inventory UI that displays the player's collected ores and items in a grid layout. Supports touch interaction for selection and selling.

## Context

The inventory is a core part of the game loop. Players need to see what they've collected, understand when they're running low on space, and quickly sell items at the shop. The UI must work well on portrait mobile screens with touch input.

## Affected Files

- `scenes/ui/inventory_panel.tscn` - NEW: Inventory panel scene
- `scripts/ui/inventory_panel.gd` - NEW: Panel controller script
- `scenes/ui/inventory_slot.tscn` - NEW: Slot prefab scene
- `scripts/ui/inventory_slot.gd` - NEW: Slot controller script
- `scripts/autoload/inventory_manager.gd` - Connect to inventory_changed signal

## Implementation Notes

### Layout Structure

```
InventoryPanel (Control)
├── Background (Panel)
├── TitleLabel ("Inventory")
├── GridContainer (slots holder)
│   ├── InventorySlot x 8-30 (dynamic)
└── SlotCountLabel ("8/8")
```

### Slot Display

Each slot shows:
- Item icon (or empty placeholder)
- Quantity number (bottom-right, only if >1)
- Rarity border color (based on item rarity)
- Highlight state when selected

### Touch Interaction

- Tap slot: Select the slot (for selling in shop)
- Tap selected slot again: Deselect
- In shop context: Selected slot enables "Sell" button
- Outside shop: Tapping shows item tooltip briefly

### Inventory Panel Script

```gdscript
# inventory_panel.gd
extends Control

signal slot_selected(slot_index: int)
signal slot_deselected

@export var slot_scene: PackedScene
@onready var grid: GridContainer = $GridContainer
@onready var count_label: Label = $SlotCountLabel

var slots: Array[InventorySlot] = []
var selected_slot: int = -1

func _ready() -> void:
    InventoryManager.inventory_changed.connect(_refresh_display)
    _create_slots()
    _refresh_display()

func _create_slots() -> void:
    # Clear existing
    for child in grid.get_children():
        child.queue_free()
    slots.clear()

    # Create slots based on max capacity
    for i in range(InventoryManager.max_slots):
        var slot = slot_scene.instantiate()
        slot.slot_index = i
        slot.pressed.connect(_on_slot_pressed.bind(i))
        grid.add_child(slot)
        slots.append(slot)

func _refresh_display() -> void:
    for i in range(slots.size()):
        var slot_data = InventoryManager.slots[i] if i < InventoryManager.slots.size() else null
        if slot_data and not slot_data.is_empty():
            slots[i].display_item(slot_data.item, slot_data.quantity)
        else:
            slots[i].display_empty()

    # Update count
    var used = InventoryManager.get_used_slots()
    var total = InventoryManager.get_total_slots()
    count_label.text = "%d/%d" % [used, total]

    # Change color when nearly full
    if used >= total - 1:
        count_label.add_theme_color_override("font_color", Color.RED)
    else:
        count_label.remove_theme_color_override("font_color")

func _on_slot_pressed(index: int) -> void:
    if selected_slot == index:
        # Deselect
        slots[selected_slot].set_selected(false)
        selected_slot = -1
        slot_deselected.emit()
    else:
        # Select new slot
        if selected_slot >= 0:
            slots[selected_slot].set_selected(false)
        selected_slot = index
        slots[selected_slot].set_selected(true)
        slot_selected.emit(index)
```

### Slot Script

```gdscript
# inventory_slot.gd
extends Button

signal pressed

var slot_index: int = 0
var current_item: ItemData = null

@onready var icon: TextureRect = $Icon
@onready var quantity_label: Label = $QuantityLabel
@onready var border: Panel = $Border

func display_item(item: ItemData, quantity: int) -> void:
    current_item = item
    icon.texture = item.icon
    icon.visible = true

    if quantity > 1:
        quantity_label.text = str(quantity)
        quantity_label.visible = true
    else:
        quantity_label.visible = false

    # Set border color based on rarity
    var rarity_color = _get_rarity_color(item.rarity)
    border.modulate = rarity_color

func display_empty() -> void:
    current_item = null
    icon.visible = false
    quantity_label.visible = false
    border.modulate = Color(0.3, 0.3, 0.3, 0.5)  # Dim gray

func set_selected(selected: bool) -> void:
    if selected:
        modulate = Color(1.2, 1.2, 1.2)  # Slight brighten
    else:
        modulate = Color.WHITE

func _get_rarity_color(rarity: int) -> Color:
    match rarity:
        0: return Color.GRAY       # Common
        1: return Color.GREEN      # Uncommon
        2: return Color.BLUE       # Rare
        3: return Color.PURPLE     # Epic
        4: return Color.ORANGE     # Legendary
        _: return Color.WHITE
```

### Mobile Sizing

- Slot size: 80x80 pixels (good touch target)
- Grid columns: 4 (fits 720px portrait width with margins)
- Rows: 2-8 depending on max_slots / 4

## Edge Cases

- Inventory capacity upgrade: Recreate slots dynamically
- Item added while UI open: Refresh displays correctly
- Item removed while selected: Deselect and refresh
- Empty inventory: Show all empty slots

## Verify

- [ ] Build succeeds with no errors
- [ ] Grid displays correct number of slots (8 initially)
- [ ] Items show with icon and quantity
- [ ] Tapping slot selects it (visual highlight)
- [ ] Tapping selected slot deselects it
- [ ] Slot count label shows "X/Y" format
- [ ] Count label turns red when 1 slot remaining
- [ ] Rarity borders show correct colors
- [ ] Refresh updates correctly when items added/removed
- [ ] Slots resize appropriately for portrait screen
