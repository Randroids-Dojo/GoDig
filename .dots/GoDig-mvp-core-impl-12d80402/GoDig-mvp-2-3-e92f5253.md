---
title: "implement: 2-3 tool upgrade tiers"
status: open
priority: 0
issue-type: task
created-at: "2026-01-16T00:34:25.414805-06:00"
after:
  - GoDig-mvp-single-shop-b97d367d
---

## Description

Create 3 pickaxe tiers (Rusty, Copper, Iron) with increasing damage. Higher damage means fewer hits to break blocks. Tools are purchased at the shop.

## Context

Tool upgrades are the primary progression reward. Players feel the difference immediately when they buy a new pickaxe - blocks break faster. This creates the "earn and upgrade" dopamine loop.

## Affected Files

- `resources/tools/tool_data.gd` - NEW: Resource class for tool definitions
- `resources/tools/rusty_pickaxe.tres` - NEW: Starting tool
- `resources/tools/copper_pickaxe.tres` - NEW: First upgrade
- `resources/tools/iron_pickaxe.tres` - NEW: Second upgrade
- `scripts/autoload/player_data.gd` - NEW: Track equipped tool
- `scripts/player/player.gd` - MODIFY: Use equipped tool damage
- `scripts/autoload/data_registry.gd` - MODIFY: Load tool definitions

## Implementation Notes

### ToolData Resource

```gdscript
class_name ToolData extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var damage: float = 10.0
@export var speed_multiplier: float = 1.0
@export var cost: int = 0
@export var unlock_depth: int = 0
@export var tier: int = 1
@export var icon: Texture2D
@export var sprite: Texture2D  # For player holding
```

### Tool Definitions (MVP)

| Tool | Damage | Speed | Cost | Unlock |
|------|--------|-------|------|--------|
| Rusty Pickaxe | 10 | 1.0x | Free | Start |
| Copper Pickaxe | 20 | 1.0x | 500 | 25m |
| Iron Pickaxe | 35 | 1.1x | 2,000 | 100m |

### PlayerData Singleton

Track the equipped tool:

```gdscript
extends Node

signal tool_changed(tool: ToolData)

var equipped_tool_id: String = "rusty_pickaxe"
var max_depth_reached: int = 0

func get_equipped_tool() -> ToolData:
    return DataRegistry.get_tool(equipped_tool_id)

func equip_tool(tool_id: String) -> void:
    equipped_tool_id = tool_id
    tool_changed.emit(get_equipped_tool())
```

### Break Time Calculation

Update player.gd to use tool damage:

```gdscript
func _calculate_hits_needed(block_hardness: float) -> int:
    var tool = PlayerData.get_equipped_tool()
    var effective_damage = tool.damage * tool.speed_multiplier
    return ceil(block_hardness / effective_damage)
```

### Example: Breaking Stone

| Tool | Stone Hardness | Hits Needed |
|------|----------------|-------------|
| Rusty (10 dmg) | 30 | 3 hits |
| Copper (20 dmg) | 30 | 2 hits |
| Iron (35 dmg, 1.1x) | 30 | 1 hit |

### Shop Integration

The shop displays available tool upgrades:

```gdscript
func _get_available_upgrades() -> Array[ToolData]:
    var result: Array[ToolData] = []
    for tool in DataRegistry.tools.values():
        # Skip already owned
        if tool.id == PlayerData.equipped_tool_id:
            continue
        # Skip if better tool already equipped
        if tool.tier <= PlayerData.get_equipped_tool().tier:
            continue
        # Check depth requirement
        if tool.unlock_depth > PlayerData.max_depth_reached:
            continue
        result.append(tool)
    return result

func _buy_tool(tool: ToolData) -> bool:
    if EconomyManager.spend_coins(tool.cost):
        PlayerData.equip_tool(tool.id)
        return true
    return false
```

### Visual Feedback

When tool is upgraded:
1. Show "New Tool!" notification
2. Tool icon changes in HUD (if shown)
3. (v1.0) Player sprite changes to hold new pickaxe

## Edge Cases

- Cannot buy tools out of order (must buy Copper before Iron)
- Depth requirement must be met to see upgrade in shop
- Starting tool (Rusty) is always equipped on new game
- Tool persists across sessions (saved in PlayerData)

## Verify

- [ ] Build succeeds with no errors
- [ ] ToolData resources load in DataRegistry
- [ ] Rusty Pickaxe equipped at game start
- [ ] Block break time decreases with Copper Pickaxe
- [ ] Block break time decreases further with Iron Pickaxe
- [ ] Copper Pickaxe only visible in shop after reaching 25m
- [ ] Iron Pickaxe only visible after reaching 100m
- [ ] Cannot buy tool without enough coins
- [ ] Buying tool deducts coins and updates equipped tool
