---
title: "implement: Equipped tool affects dig speed"
status: closed
priority: 1
issue-type: task
created-at: "2026-01-16T01:06:09.216253-06:00"
after:
  - GoDig-dev-tooldata-resource-429a6285
  - GoDig-dev-block-hardness-f048d7da
---

## Description

Make the player's equipped tool determine mining speed. Higher tier tools deal more damage per swing, breaking blocks faster. The formula compares tool damage against block hardness.

## Context

This is a core progression mechanic. Early tools require many hits to break stone, but upgraded pickaxes break blocks in fewer hits. This creates the upgrade incentive and progression feel.

The current implementation already passes tool damage through `hit_block()` via PlayerData, but the actual hit calculation in DirtBlock may not be using it correctly.

## Affected Files

- `scripts/world/dirt_block.gd` - Use tool damage in hit calculation
- `scripts/player/player.gd` - Already uses PlayerData.get_tool_damage()
- `resources/tools/*.tres` - Verify damage values are reasonable
- `resources/layers/*.tres` - Verify hardness values create good progression

## Implementation Notes

### Current Flow (Already Exists)

1. Player swings at block (`_on_animation_finished`)
2. Calls `dirt_grid.hit_block(mining_target)` with no damage arg
3. DirtGrid calls `hit_block(pos, tool_damage=-1.0)`
4. If damage < 0, uses `PlayerData.get_tool_damage()` - THIS WORKS
5. DirtBlock.take_hit(damage) applies damage to block health

### Verify DirtBlock.take_hit() Uses Damage Correctly

```gdscript
# dirt_block.gd - Should look like this:
func take_hit(damage: float) -> bool:
    current_health -= damage
    return current_health <= 0
```

### Balance: Tool Damage vs Block Hardness

Current tool definitions:
- Rusty Pickaxe: tier=1, damage=10, speed=1.0 -> effective=10
- Copper Pickaxe: tier=2, damage=20, speed=1.2 -> effective=24
- Iron Pickaxe: tier=3, damage=35, speed=1.3 -> effective=45.5

Current layer hardness (from layer_data.tres files):
- Topsoil: hardness ~10-20
- Subsoil: hardness ~20-40
- Stone: hardness ~40-80
- Deep Stone: hardness ~80-150

### Hits Required Calculation

```
hits_required = ceil(block_hardness / tool_effective_damage)

Examples with Rusty Pickaxe (damage=10):
- Topsoil (15): ceil(15/10) = 2 hits
- Subsoil (30): ceil(30/10) = 3 hits
- Stone (60): ceil(60/10) = 6 hits
- Deep Stone (100): ceil(100/10) = 10 hits

Examples with Iron Pickaxe (damage=45.5):
- Topsoil (15): ceil(15/45.5) = 1 hit
- Subsoil (30): ceil(30/45.5) = 1 hit
- Stone (60): ceil(60/45.5) = 2 hits
- Deep Stone (100): ceil(100/45.5) = 3 hits
```

### Visual Feedback for Hit Progress

```gdscript
# dirt_block.gd - Add hit feedback
func take_hit(damage: float) -> bool:
    current_health -= damage
    _show_hit_effect()
    return current_health <= 0

func _show_hit_effect() -> void:
    # Calculate damage percentage
    var pct: float = 1.0 - (current_health / max_health)

    # Darken color based on damage
    var base_color := color
    color = base_color.darkened(pct * 0.3)

    # Optional: Shake or crack effect
    # Optional: Particle burst on hit
```

## Edge Cases

- Tool not found: Fall back to damage=10 (handled in PlayerData)
- Block hardness=0: Instant break (one hit minimum)
- Very high damage vs low hardness: Still takes 1 hit minimum
- Ore blocks: May have different hardness than surrounding layer

## Verify

- [ ] Build succeeds
- [ ] Rusty pickaxe takes multiple hits on deep stone
- [ ] Iron pickaxe takes fewer hits on same block
- [ ] Block visually shows damage (darkening)
- [ ] Upgrading tool makes digging noticeably faster
- [ ] At least 1 hit required even with overpowered tool
- [ ] Tool damage comes from PlayerData.get_tool_damage()
