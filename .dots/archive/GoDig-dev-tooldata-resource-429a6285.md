---
title: "implement: ToolData resource class"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-16T00:38:18.017856-06:00\""
closed-at: "2026-01-19T11:26:40.020035-06:00"
close-reason: ToolData class exists, 3 tool .tres files exist, DataRegistry has tool loading (get_tool, get_tools_at_depth)
---

## Description

Create tool tier definitions using the existing ToolData resource class.

## Context

The ToolData class already exists at `resources/tools/tool_data.gd` with all required properties (damage, speed_multiplier, cost, unlock_depth, tier). What's missing is the actual .tres definition files for each tool tier.

## Current State

- `resources/tools/tool_data.gd` - EXISTS with properties: id, display_name, damage, speed_multiplier, cost, unlock_depth, tier, icon, sprite, description
- No .tres files exist yet

## Affected Files

- `resources/tools/rusty_pickaxe.tres` - NEW: Starter tool (tier 1)
- `resources/tools/copper_pickaxe.tres` - NEW: Early upgrade (tier 2)
- `resources/tools/iron_pickaxe.tres` - NEW: Mid-game tool (tier 3)
- `scripts/autoload/data_registry.gd` - Add tool loading and lookup

## Implementation Notes

### Tool Tier Definitions (MVP - First 3 Tiers)

From GAME_DESIGN_SUMMARY.md:

| Tier | Name | Damage | Speed | Cost | Unlock Depth |
|------|------|--------|-------|------|--------------|
| 1 | Rusty Pickaxe | 10 | 1.0 | 0 | 0 |
| 2 | Copper Pickaxe | 20 | 1.0 | 500 | 25 |
| 3 | Iron Pickaxe | 35 | 1.0 | 2000 | 100 |

### Future Tiers (post-MVP)

| Tier | Name | Damage | Speed | Cost | Unlock Depth |
|------|------|--------|-------|------|--------------|
| 4 | Steel Pickaxe | 55 | 1.1 | 8000 | 250 |
| 5 | Silver Pickaxe | 75 | 1.0 | 25000 | 400 |
| 6 | Gold Pickaxe | 80 | 0.9 | 50000 | 500 |
| 7 | Mythril Pickaxe | 120 | 1.0 | 100000 | 700 |
| 8 | Diamond Pickaxe | 180 | 1.2 | 300000 | 1000 |
| 9 | Void Pickaxe | 250 | 1.3 | 1000000 | 2000 |

### DataRegistry Tool Methods

Add to `data_registry.gd`:
```gdscript
var tools: Dictionary = {}  # id -> ToolData

func _load_all_tools() -> void:
    _load_tools_from_directory("res://resources/tools/")

func _load_tools_from_directory(path: String) -> void:
    var dir = DirAccess.open(path)
    if dir == null:
        return
    dir.list_dir_begin()
    var file_name = dir.get_next()
    while file_name != "":
        if file_name.ends_with(".tres"):
            var tool_res = load(path + file_name)
            if tool_res is ToolData:
                tools[tool_res.id] = tool_res
        file_name = dir.get_next()

func get_tool(tool_id: String) -> ToolData:
    return tools.get(tool_id, null)

func get_tools_available_at_depth(depth: int) -> Array[ToolData]:
    var result: Array[ToolData] = []
    for t in tools.values():
        if t.unlock_depth <= depth:
            result.append(t)
    result.sort_custom(func(a, b): return a.tier < b.tier)
    return result
```

## Verify

- [ ] Build succeeds
- [ ] All 3 MVP tool .tres files load without errors
- [ ] `DataRegistry.get_tool("rusty_pickaxe")` returns ToolData
- [ ] `DataRegistry.get_tool("copper_pickaxe")` returns ToolData
- [ ] `DataRegistry.get_tool("iron_pickaxe")` returns ToolData
- [ ] `DataRegistry.get_tools_available_at_depth(0)` returns only rusty pickaxe
- [ ] `DataRegistry.get_tools_available_at_depth(100)` returns all 3 MVP tools
- [ ] Each tier has higher damage than the previous
- [ ] Tool costs match design spec (0, 500, 2000)
