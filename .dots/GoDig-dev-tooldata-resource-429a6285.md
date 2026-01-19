---
title: "implement: ToolData resource class"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T00:38:18.017856-06:00"
---

## Description

Create tool tier definitions using the existing ToolData resource class.

## Context

The ToolData class already exists at `resources/tools/tool_data.gd` with all required properties (damage, speed_multiplier, cost, unlock_depth, tier). What's missing is the actual .tres definition files for each tool tier.

## Current State

- `resources/tools/tool_data.gd` - EXISTS with properties: id, display_name, damage, speed_multiplier, cost, unlock_depth, tier, icon, sprite, description
- No .tres files exist yet

## Affected Files

- `resources/tools/pickaxe_wood.tres` - NEW: Starter tool (tier 1)
- `resources/tools/pickaxe_stone.tres` - NEW: Early upgrade (tier 2)
- `resources/tools/pickaxe_iron.tres` - NEW: Mid-game tool (tier 3)
- `resources/tools/pickaxe_steel.tres` - NEW: Late tool (tier 4)
- `resources/tools/pickaxe_diamond.tres` - NEW: End-game tool (tier 5)
- `scripts/autoload/data_registry.gd` - Add tool loading and lookup

## Implementation Notes

### Tool Tier Definitions

| Tier | Name | Damage | Speed | Cost | Unlock Depth |
|------|------|--------|-------|------|--------------|
| 1 | Wooden Pickaxe | 10 | 1.0 | 0 | 0 |
| 2 | Stone Pickaxe | 20 | 1.1 | 100 | 25 |
| 3 | Iron Pickaxe | 35 | 1.25 | 500 | 100 |
| 4 | Steel Pickaxe | 60 | 1.5 | 2000 | 300 |
| 5 | Diamond Pickaxe | 100 | 2.0 | 10000 | 750 |

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
- [ ] All 5 tool .tres files load without errors
- [ ] `DataRegistry.get_tool("pickaxe_wood")` returns ToolData
- [ ] `DataRegistry.get_tools_available_at_depth(0)` returns only wooden pickaxe
- [ ] `DataRegistry.get_tools_available_at_depth(100)` returns wood, stone, iron
- [ ] Each tier has higher damage and speed than the previous
