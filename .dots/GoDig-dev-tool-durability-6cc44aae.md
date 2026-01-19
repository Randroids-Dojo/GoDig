---
title: "implement: Tool durability HUD"
status: open
priority: 3
issue-type: task
created-at: "2026-01-16T00:39:28.311011-06:00"
---

Display tool durability in the HUD if/when tool durability system is implemented.

## Description

Add a durability indicator to the HUD that shows the remaining durability of the currently equipped tool. This provides feedback to players about when they need to return to the surface for repairs.

## Context

- **MVP Status**: Tool durability is OPTIONAL for MVP. Basic infinite tools work fine.
- If durability is implemented, this HUD element becomes necessary
- See session-design.md: "Tool durability (if implemented) paces returns"
- See surface-shops.md: Blacksmith can upgrade durability

## Prerequisites

Before implementing this HUD element:
- Decide: Is tool durability in MVP scope? (Current decision: NO)
- If YES to durability: Implement ToolData.durability system first
- If NO: This task can be deferred to v1.0+

## Affected Files

- `scripts/ui/hud.gd` - Add durability display
- `scenes/ui/hud.tscn` - Add durability UI elements
- `scripts/autoload/player_data.gd` - Expose current tool durability
- `resources/tools/tool_data.gd` - Add max_durability, current_durability

## Implementation Notes

### HUD Element Design

```
┌──────────────────────────────────────────┐
│ [Pickaxe Icon] ████████░░ 78%            │
│ or                                       │
│ [Pickaxe Icon] ▓▓▓▓▓▓▓▓░░░░ (bar style) │
└──────────────────────────────────────────┘
```

### Durability Bar Script

```gdscript
# hud.gd additions
@onready var durability_bar: ProgressBar = $ToolDurability/Bar
@onready var durability_label: Label = $ToolDurability/Label
@onready var tool_icon: TextureRect = $ToolDurability/Icon

func _process(_delta: float) -> void:
    _update_durability_display()

func _update_durability_display() -> void:
    if not PlayerData:
        return

    var tool := PlayerData.get_equipped_tool()
    if tool == null or tool.max_durability <= 0:
        # No durability system or infinite tool
        $ToolDurability.visible = false
        return

    $ToolDurability.visible = true
    var percent := PlayerData.tool_durability / tool.max_durability
    durability_bar.value = percent
    durability_label.text = "%d%%" % int(percent * 100)
    tool_icon.texture = tool.icon

    # Color code based on durability
    if percent <= 0.1:
        durability_bar.modulate = Color.RED
    elif percent <= 0.25:
        durability_bar.modulate = Color.ORANGE
    else:
        durability_bar.modulate = Color.WHITE
```

### Low Durability Warning

```gdscript
# Flash or pulse when durability is low
var _low_durability_warning: bool = false

func _update_durability_display() -> void:
    # ...existing code...

    # Warn at 10%
    var should_warn := percent <= 0.1 and percent > 0
    if should_warn and not _low_durability_warning:
        _low_durability_warning = true
        _start_durability_warning_pulse()
    elif not should_warn and _low_durability_warning:
        _low_durability_warning = false
        _stop_durability_warning_pulse()
```

### Integration with Tool Breaking

When tool breaks (durability reaches 0):
1. Play break animation/sound
2. Show "Tool Broken!" notification
3. Auto-switch to next available tool (or bare hands)
4. HUD element shows "No Tool" or repair prompt

## Edge Cases

- Tool with infinite durability (max_durability = 0): Hide bar
- No tool equipped: Hide bar or show "No Tool"
- Tool breaks while mining: Interrupt mining, show message
- Multiple tools: Show durability of equipped tool only

## Verify

- [ ] Build succeeds
- [ ] Durability bar hidden when tool has infinite durability
- [ ] Durability bar shows correct percentage
- [ ] Bar turns orange at 25%, red at 10%
- [ ] Warning pulse appears at 10%
- [ ] Breaking tool shows notification
- [ ] Tool icon updates when tool changes
