---
title: "implement: Ladder quick-slot HUD"
status: open
priority: 3
issue-type: task
created-at: "2026-01-16T01:58:35.016433-06:00"
after:
  - GoDig-dev-ladder-placement-7b71387f
---

## Description

Add a dedicated quick-slot in the HUD showing ladder count with one-tap placement. Allows fast ladder placement without opening inventory menu.

## Context

- Ladders are the primary traversal consumable
- Quick access is essential for reactive escape situations
- Shows count so player knows reserves at a glance
- Tapping places ladder at current valid position

## Affected Files

- `scenes/ui/hud.tscn` - Add ladder quick-slot area
- `scripts/ui/ladder_quickslot.gd` - NEW: Quick-slot controller
- `scripts/player/player.gd` - Handle quick-place action
- `scripts/autoload/inventory_manager.gd` - Helper for ladder count

## Implementation Notes

### HUD Layout Position

```
Portrait HUD Layout (720x1280):
┌────────────────────────────────┐
│ [Coins] [Depth]    [Ladders:5] │  <- Top bar
│                                │
│                                │
│                                │
│     [Joystick]      [Actions]  │  <- Bottom
└────────────────────────────────┘

Ladder quick-slot: Top-right corner
Size: 64x64 touch target
```

### Quick-Slot Scene Structure

```
LadderQuickSlot (Control)
├── Background (TextureRect) - Slot frame
├── Icon (TextureRect) - Ladder sprite
├── CountLabel (Label) - "x5"
└── TouchButton (Button) - Invisible touch area
```

### Quick-Slot Script

```gdscript
# ladder_quickslot.gd
extends Control

signal place_requested

const LADDER_ITEM_ID := "ladder"

@onready var icon: TextureRect = $Icon
@onready var count_label: Label = $CountLabel
@onready var touch_button: Button = $TouchButton

var ladder_count: int = 0

func _ready() -> void:
    InventoryManager.inventory_changed.connect(_update_display)
    touch_button.pressed.connect(_on_pressed)
    _update_display()

func _update_display() -> void:
    ladder_count = InventoryManager.get_item_count_by_id(LADDER_ITEM_ID)
    count_label.text = "x%d" % ladder_count

    # Visual feedback when empty
    if ladder_count == 0:
        icon.modulate = Color(0.5, 0.5, 0.5)  # Grayed out
        count_label.modulate = Color.RED
    else:
        icon.modulate = Color.WHITE
        count_label.modulate = Color.WHITE

func _on_pressed() -> void:
    if ladder_count > 0:
        place_requested.emit()
    else:
        # Flash red to indicate empty
        _flash_empty()

func _flash_empty() -> void:
    var tween := create_tween()
    tween.tween_property(self, "modulate", Color.RED, 0.1)
    tween.tween_property(self, "modulate", Color.WHITE, 0.2)
```

### Placement Logic Integration

```gdscript
# In test_level.gd or main game controller
func _ready() -> void:
    ladder_quickslot.place_requested.connect(_on_quick_place_ladder)

func _on_quick_place_ladder() -> void:
    # Find valid placement position (below player)
    var placement_pos := _find_ladder_placement()
    if placement_pos == Vector2i(-1, -1):
        _show_invalid_placement_feedback()
        return

    # Check inventory
    if not InventoryManager.remove_item_by_id("ladder", 1):
        return

    # Place ladder
    world.place_ladder(placement_pos)
    _show_placement_success(placement_pos)

func _find_ladder_placement() -> Vector2i:
    # Priority: below player > left > right
    var player_pos := player.grid_position

    # Check below
    var below := player_pos + Vector2i(0, 1)
    if _can_place_ladder_at(below):
        return below

    # Check sides
    for dir in [Vector2i(-1, 0), Vector2i(1, 0)]:
        var pos := player_pos + dir
        if _can_place_ladder_at(pos):
            return pos

    return Vector2i(-1, -1)  # No valid position
```

### Visual Feedback

**On successful placement:**
- Brief green flash on quick-slot
- Ladder "flies" from HUD to world position (optional juice)
- Satisfying placement sound

**On invalid/empty:**
- Red flash on quick-slot
- Shake animation
- Error sound (subtle)

### Keyboard Shortcut (Desktop)

```gdscript
# player.gd or input handler
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("quick_ladder"):  # e.g., 'L' key
        _on_quick_place_ladder()
```

## Edge Cases

- No ladders in inventory: Flash red, no action
- No valid placement position: Flash red, show tooltip
- Player falling: Prevent placement while falling
- Already ladder at position: Find next valid position
- Inventory full when buying: Quick-slot reflects accurate count

## Verify

- [ ] Build succeeds
- [ ] Quick-slot appears in top-right of HUD
- [ ] Shows correct ladder count from inventory
- [ ] Tapping with ladders places one below player
- [ ] Tapping with zero ladders flashes red
- [ ] Count updates when ladder added/removed
- [ ] Grayed out appearance when empty
- [ ] Placement fails gracefully when no valid position
- [ ] Works on mobile touch targets (64x64 minimum)
- [ ] Keyboard shortcut works on desktop
