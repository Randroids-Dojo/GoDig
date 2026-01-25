---
title: "implement: Tool tier definitions"
status: closed
priority: 2
issue-type: task
created-at: "2026-01-16T00:38:18.020345-06:00"
---

## Description

Create ToolData .tres files for MVP tool tiers: Rusty, Copper, and Iron pickaxes. These define the tool progression that gates mining depth.

## Context

Tool damage vs block hardness determines break time. Better tools let players mine deeper layers efficiently. MVP needs 3 tiers to demonstrate the upgrade loop.

From GAME_DESIGN_SUMMARY.md:
| Tier | Tool | Damage | Speed | Cost | Unlock |
|------|------|--------|-------|------|--------|
| 1 | Rusty Pickaxe | 10 | 1.0x | Free | Start |
| 2 | Copper Pickaxe | 20 | 1.0x | 500 | 25m |
| 3 | Iron Pickaxe | 35 | 1.0x | 2,000 | 100m |

## Affected Files

- `resources/tools/rusty_pickaxe.tres` - NEW: Starting tool
- `resources/tools/copper_pickaxe.tres` - NEW: First upgrade
- `resources/tools/iron_pickaxe.tres` - NEW: Second upgrade
- `scripts/autoload/data_registry.gd` - Add `_load_all_tools()` if not present

## Implementation Notes

### ToolData .tres File Format

Each tool file should set these properties (from ToolData resource class):

```tres
[gd_resource type="Resource" script_class="ToolData" ...]

[resource]
id = "rusty_pickaxe"
display_name = "Rusty Pickaxe"
description = "A worn pickaxe. Better than nothing."
tier = 1
damage = 10
speed_multiplier = 1.0
cost = 0
unlock_depth = 0
max_durability = 100  # Optional, if using durability system
icon = ExtResource("path_to_icon")
```

### Tier 1: Rusty Pickaxe
- id: "rusty_pickaxe"
- damage: 10
- speed: 1.0x
- cost: 0 (free, starting tool)
- unlock_depth: 0

### Tier 2: Copper Pickaxe
- id: "copper_pickaxe"
- damage: 20
- speed: 1.0x
- cost: 500
- unlock_depth: 25

### Tier 3: Iron Pickaxe
- id: "iron_pickaxe"
- damage: 35
- speed: 1.0x
- cost: 2000
- unlock_depth: 100

### Break Time Formula
```gdscript
break_time = block.hardness / tool.damage / tool.speed_multiplier
```

Example: Stone (hardness 30) with Rusty Pickaxe (damage 10) = 3 hits

## Verify

- [ ] Build succeeds
- [ ] All three .tres files load without errors
- [ ] DataRegistry.get_tool("rusty_pickaxe") returns valid ToolData
- [ ] DataRegistry.get_tool("copper_pickaxe") returns valid ToolData
- [ ] DataRegistry.get_tool("iron_pickaxe") returns valid ToolData
- [ ] Tool damage values match design spec
- [ ] Tool costs are correct (0, 500, 2000)
- [ ] Unlock depths are correct (0, 25, 100)
