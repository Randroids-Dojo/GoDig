---
title: "implement: Tool tier gating for ores"
status: open
priority: 2
issue-type: task
created-at: "2026-01-18T23:46:41.324136-06:00"
after:
  - GoDig-dev-player-stats-41460a18
  - GoDig-dev-tool-tier-ea2c98b0
---

Check OreData.required_tool_tier when player attempts to mine. If player tool tier is too low, show visual feedback (red X, bounce) and don't damage the block. Requires PlayerStats tracking current tool tier.

## Description

Certain ores should only be mineable with upgraded tools. Gold (required_tool_tier=1) shouldn't be mineable with the starter pickaxe (tier 0). This creates progression and gives value to tool upgrades.

## Context

- OreData.required_tool_tier exists but is never checked
- No PlayerStats system yet to track current tool tier
- Player starts with tier 0 pickaxe, can upgrade via shop

## Affected Files

- `scripts/world/dirt_grid.gd` - Add `can_mine_block()` check, modify `hit_block()`
- `scripts/player/player.gd` - Check minable before starting mining animation
- `scripts/autoload/game_manager.gd` OR new `scripts/autoload/player_stats.gd` - Track current tool tier

## Implementation Notes

### PlayerStats (or GameManager) Addition

```gdscript
# player_stats.gd (or add to game_manager.gd)
var current_tool_tier: int = 0

func upgrade_tool(new_tier: int) -> void:
    current_tool_tier = new_tier
    tool_upgraded.emit(new_tier)
```

### DirtGrid Gating Check

```gdscript
# dirt_grid.gd
func can_mine_block(pos: Vector2i, player_tool_tier: int) -> bool:
    ## Returns true if player can mine this block
    if not _ore_map.has(pos):
        return true  # Regular dirt is always mineable

    var ore = DataRegistry.get_ore(_ore_map[pos])
    if ore == null:
        return true

    return player_tool_tier >= ore.required_tool_tier


func hit_block(pos: Vector2i, tool_tier: int = 0) -> Dictionary:
    ## Hit a block, returns {destroyed: bool, blocked: bool}
    if not _active.has(pos):
        return {destroyed = true, blocked = false}

    # Check tool tier requirement
    if not can_mine_block(pos, tool_tier):
        return {destroyed = false, blocked = true}

    var block = _active[pos]
    var destroyed: bool = block.take_hit()
    # ... rest of existing logic
    return {destroyed = destroyed, blocked = false}
```

### Player Mining Feedback

```gdscript
# player.gd
func _start_mining(direction: Vector2i, target_block: Vector2i) -> void:
    var tool_tier := GameManager.current_tool_tier  # or PlayerStats.current_tool_tier
    if not dirt_grid.can_mine_block(target_block, tool_tier):
        # Show "can't mine" feedback
        _show_blocked_feedback(target_block)
        return

    # ...existing mining code...


func _show_blocked_feedback(target: Vector2i) -> void:
    # Option 1: Screen shake
    # Option 2: Red X particle at target
    # Option 3: Bounce animation on player
    # Option 4: Sound effect
    pass
```

### Required Tool Tiers (Current)

From ore .tres files:
- coal: required_tool_tier = 0 (starter pickaxe)
- copper: required_tool_tier = 0
- iron: required_tool_tier = 0
- silver: required_tool_tier = 0
- gold: required_tool_tier = 1 (need copper pickaxe)
- ruby: required_tool_tier = 1 (assumed)

## Verify

- [ ] Starter pickaxe can mine coal, copper, iron, silver
- [ ] Starter pickaxe CANNOT mine gold - shows feedback
- [ ] After upgrade to tier 1, gold becomes mineable
- [ ] Visual/audio feedback clearly indicates "can't mine this"
- [ ] Mining animation doesn't play for blocked ores
