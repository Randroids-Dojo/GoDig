---
title: "implement: Inventory slots preview HUD"
status: closed
priority: 2
issue-type: task
created-at: "2026-01-16T00:39:28.307927-06:00"
---

## Description

Display a compact inventory status in the HUD showing used slots vs total slots (e.g., "6/8"). Optionally show small icons of recently collected items.

## Context

Players need to know when their inventory is getting full without opening the full inventory screen. This creates tension and drives the core loop: when full, return to surface to sell.

## Affected Files

- `scenes/ui/hud.tscn` - Add inventory preview panel
- `scripts/ui/hud.gd` - Update inventory display
- `scripts/autoload/inventory_manager.gd` - Already has signals for changes

## Implementation Notes

### HUD Layout

```
┌──────────────────────────────────────┐
│  Depth: 45m     $1,234   [6/8]  [⛏]  │  Top HUD bar
└──────────────────────────────────────┘
```

### Inventory Preview Scene Structure

```
InventoryPreview (HBoxContainer)
├─ BagIcon (TextureRect) - Small backpack icon
├─ SlotLabel (Label) - "6/8" text
└─ WarningIndicator (TextureRect) - Red flash when near full
```

### HUD Script Updates

```gdscript
# hud.gd
@onready var slot_label: Label = $InventoryPreview/SlotLabel
@onready var warning_indicator: TextureRect = $InventoryPreview/WarningIndicator

func _ready() -> void:
    InventoryManager.inventory_changed.connect(_update_inventory_display)
    InventoryManager.inventory_full.connect(_on_inventory_full)
    _update_inventory_display()

func _update_inventory_display() -> void:
    var used := InventoryManager.get_used_slots()
    var total := InventoryManager.get_total_slots()
    slot_label.text = "%d/%d" % [used, total]

    # Color code based on fullness
    var fill_ratio := float(used) / float(total)
    if fill_ratio >= 1.0:
        slot_label.add_theme_color_override("font_color", Color.RED)
    elif fill_ratio >= 0.75:
        slot_label.add_theme_color_override("font_color", Color.ORANGE)
    else:
        slot_label.add_theme_color_override("font_color", Color.WHITE)

func _on_inventory_full() -> void:
    # Flash the warning indicator
    _flash_warning()

func _flash_warning() -> void:
    var tween = create_tween()
    tween.tween_property(warning_indicator, "modulate:a", 1.0, 0.1)
    tween.tween_property(warning_indicator, "modulate:a", 0.0, 0.3)
    tween.set_loops(3)
```

### Visual Design

- Font size: 18-20px for readability
- Position: Top-right area of HUD
- Colors: White (normal), Orange (75%+), Red (full)
- Optional: Animated backpack icon that "bulges" when adding items

### Recent Items (Optional Enhancement)

Show last 3 collected items as small icons next to the slot count:
```
[6/8] [Coal] [Iron] [Gold]
```

## Verify

- [ ] Build succeeds
- [ ] HUD shows slot count "X/Y" format
- [ ] Count updates when items added/removed
- [ ] Color changes at 75% and 100% capacity
- [ ] Warning flash triggers when inventory full
- [ ] Backpack upgrades reflect in total count
- [ ] Readable on mobile screen size
