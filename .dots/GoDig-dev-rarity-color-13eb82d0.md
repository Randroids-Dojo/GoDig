---
title: "implement: Rarity color borders"
status: active
priority: 3
issue-type: task
created-at: "\"2026-01-16T00:45:21.951966-06:00\""
---

Per inventory-system.md: White/Green/Blue/Purple/Orange borders for item rarity

## Description

Add colored borders to inventory slot UI elements that indicate item rarity. Colors follow the standard gaming convention (White->Green->Blue->Purple->Orange) to provide instant visual feedback about item value.

## Context

- Inventory UI already exists with slot-based display
- ItemData resources have a `rarity` property (common, uncommon, rare, epic, legendary)
- Color coding helps players quickly identify valuable items
- Also used in floating text when items are picked up

## Affected Files

- `scripts/ui/inventory_slot.gd` - NEW or modify existing slot UI script
- `scenes/ui/inventory_slot.tscn` - Add border ColorRect/TextureRect
- `scripts/ui/floating_text.gd` - Color text by item rarity
- `resources/items/*.tres` - Ensure rarity is set on all items

## Implementation Notes

### Rarity Colors (Standard Gaming Convention)

```gdscript
const RARITY_COLORS := {
    "common": Color(1.0, 1.0, 1.0),      # White
    "uncommon": Color(0.18, 0.8, 0.25),  # Green (#2ECC40)
    "rare": Color(0.2, 0.6, 1.0),        # Blue (#3399FF)
    "epic": Color(0.65, 0.35, 0.85),     # Purple (#A347D9)
    "legendary": Color(1.0, 0.6, 0.1),   # Orange (#FF9900)
}

## Get rarity color for an item
static func get_rarity_color(rarity: String) -> Color:
    if RARITY_COLORS.has(rarity):
        return RARITY_COLORS[rarity]
    return Color.WHITE  # Default to common
```

### Inventory Slot UI Structure

```
InventorySlot (Control)
+-- BorderRect (ColorRect)      <- NEW: Colored border
|   anchors: full rect
|   color: white (default)
+-- BackgroundRect (ColorRect)  <- Darker inner background
|   anchors: with 2px margin from border
+-- ItemIcon (TextureRect)
+-- QuantityLabel (Label)
```

### Slot Script Integration

```gdscript
# inventory_slot.gd
@onready var border_rect: ColorRect = $BorderRect

func update_display(slot: InventoryManager.InventorySlot) -> void:
    if slot.is_empty():
        border_rect.color = Color(0.3, 0.3, 0.3)  # Gray for empty
        # ...hide other elements...
    else:
        border_rect.color = get_rarity_color(slot.item.rarity)
        # ...update icon, quantity...
```

### Floating Text Color Integration

```gdscript
# floating_text.gd
func show_item_pickup(item: ItemData, amount: int) -> void:
    text_label.text = "+%d %s" % [amount, item.display_name]
    text_label.modulate = get_rarity_color(item.rarity)
    # ...animation...
```

### Border Animation for Rare+ Items

Optional polish - animate borders for rare and above:

```gdscript
func _update_border_animation() -> void:
    if _current_rarity in ["rare", "epic", "legendary"]:
        # Subtle glow pulse
        var pulse := (sin(Time.get_ticks_msec() / 500.0) + 1.0) / 2.0
        var base_color := get_rarity_color(_current_rarity)
        border_rect.color = base_color.lightened(pulse * 0.2)
```

### Colorblind Accessibility

Respect SettingsManager.colorblind_mode:
- Mode 0 (OFF): Standard colors
- Mode 1 (SYMBOLS): Add rarity symbols (star, diamond, etc.)
- Mode 2 (HIGH_CONTRAST): Use high-contrast color alternatives

```gdscript
func get_rarity_symbol(rarity: String) -> String:
    match rarity:
        "common": return ""
        "uncommon": return "*"
        "rare": return "**"
        "epic": return "***"
        "legendary": return "****"
        _: return ""
```

## Edge Cases

- Empty slots: Show gray border
- Items without rarity set: Default to "common"
- Colorblind mode enabled: Add symbols or use alternative colors
- Very small screens: Border must remain visible (min 2px)

## Verify

- [ ] Build succeeds
- [ ] Common items show white border
- [ ] Uncommon items show green border
- [ ] Rare items show blue border
- [ ] Epic items show purple border
- [ ] Legendary items show orange border
- [ ] Empty slots show gray/neutral border
- [ ] Floating text matches rarity color
- [ ] Colorblind symbols mode shows stars
- [ ] Colors are distinguishable on mobile screens
