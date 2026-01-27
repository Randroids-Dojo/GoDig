---
title: "implement: Wire tool upgrades to PlayerStats"
status: closed
priority: 1
issue-type: task
created-at: "2026-01-18T23:49:26.252382-06:00"
after:
  - GoDig-mvp-single-shop-b97d367d
---

Shop._on_tool_upgrade() has TODO. Need to track current_tool_tier in GameManager or PlayerStats. When upgraded, update tier and apply damage multiplier to mining. Shop needs to read current tier for UI.

## Description

Connect the shop's tool upgrade system to actual game state. Currently the shop UI displays tool upgrades and handles coin transactions, but the upgrade has no effect on gameplay. This task wires it up so purchased upgrades actually make mining faster.

## Context

- Shop.gd `_on_tool_upgrade()` has TODO comment
- `_get_current_tool_level()` always returns 1 (hardcoded)
- DirtBlock.take_hit() uses DEFAULT_TOOL_DAMAGE constant
- No persistent tool tier tracking exists

## Affected Files

- `scripts/autoload/game_manager.gd` - Add tool tier tracking
- `scripts/ui/shop.gd` - Read/write tool tier from GameManager
- `scripts/world/dirt_block.gd` - Accept tool damage parameter
- `scripts/world/dirt_grid.gd` - Pass tool damage to hit_block()
- `scripts/player/player.gd` - Get tool damage from GameManager for mining

## Implementation Notes

### Add to GameManager

```gdscript
# game_manager.gd

signal tool_upgraded(new_tier: int, damage: float)

var current_tool_tier: int = 1
var current_tool_damage: float = 1.0

## Tool damage per tier (matches shop.gd tool_upgrades array)
const TOOL_DAMAGE_BY_TIER := [1.0, 2.0, 3.5, 5.0]

func upgrade_tool() -> void:
    if current_tool_tier < TOOL_DAMAGE_BY_TIER.size():
        current_tool_tier += 1
        current_tool_damage = TOOL_DAMAGE_BY_TIER[current_tool_tier - 1]
        tool_upgraded.emit(current_tool_tier, current_tool_damage)

func get_tool_tier() -> int:
    return current_tool_tier

func get_tool_damage() -> float:
    return current_tool_damage
```

### Update Shop.gd

```gdscript
func _get_current_tool_level() -> int:
    return GameManager.get_tool_tier()

func _on_tool_upgrade() -> void:
    var current_level := _get_current_tool_level()
    if current_level < tool_upgrades.size():
        var next := tool_upgrades[current_level]
        if GameManager.spend_coins(next.cost):
            GameManager.upgrade_tool()
            print("[Shop] Tool upgraded to level %d" % GameManager.get_tool_tier())
            _refresh_upgrades_tab()
```

### Update DirtGrid.hit_block()

```gdscript
func hit_block(pos: Vector2i, tool_damage: float = 1.0) -> bool:
    # ... existing code ...
    var destroyed: bool = block.take_hit(tool_damage)
    # ...
```

### Update Player Mining

```gdscript
# player.gd
func _on_animation_finished() -> void:
    if current_state != State.MINING:
        return

    if dirt_grid == null:
        current_state = State.IDLE
        return

    var tool_damage := GameManager.get_tool_damage()
    var destroyed: bool = dirt_grid.hit_block(mining_target, tool_damage)
    # ... rest of existing code
```

### Persistence Note

Tool tier needs to be saved/loaded with game state. Add to save data:
```gdscript
"tool_tier": GameManager.current_tool_tier
```

## Verify

- [ ] Fresh game starts with tool tier 1
- [ ] Shop shows correct current tool level
- [ ] Purchasing upgrade increases tool tier in GameManager
- [ ] Mining uses new damage value after upgrade
- [ ] Blocks break faster with upgraded tool
- [ ] Tool tier persists across save/load
