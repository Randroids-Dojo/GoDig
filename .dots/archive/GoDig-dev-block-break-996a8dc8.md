---
title: "implement: Block break time calculation"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-16T00:43:21.057626-06:00\""
closed-at: "2026-01-19T19:35:43.592259-06:00"
close-reason: Block break time in dirt_block.gd
---

## Description

Implement a consistent formula for calculating how long it takes to break a block, based on block hardness, tool damage, and tool speed modifier. This creates predictable progression feel.

**Status Update:** Core system is already implemented:
- DirtBlock has health-based system with `take_hit()` and visual feedback (darkening)
- ToolData has `damage` and `speed_multiplier` properties
- Dependency `GoDig-dev-equipped-tool-71c36858` was completed (tool damage flows through PlayerData)

Remaining work: Speed modifier integration with animation, optional crack overlay.

## Context

Currently, blocks have a simple health pool that gets hit by tool damage. This works, but the formula for "time to break" should be clear and tunable. The economy-progression research specified: `base_time = hardness / damage * speed_modifier`.

## Affected Files

- `scripts/world/dirt_block.gd` - Add break time calculation (or use existing health system)
- `scripts/player/player.gd` - Display progress indicator (optional)
- `resources/tools/*.tres` - Ensure speed_modifier is defined
- `scripts/ui/hud.gd` - Optional: show mining progress bar

## Implementation Notes

### Current System (Health-Based)

The current implementation uses a health pool:
```gdscript
# dirt_block.gd (current approach)
var current_health: float
var max_health: float  # = hardness from layer

func take_hit(damage: float) -> bool:
    current_health -= damage
    return current_health <= 0
```

This already works. The "break time" is effectively:
```
hits_required = ceil(hardness / tool_damage)
break_time = hits_required * swing_duration
```

### Option A: Keep Health System (Recommended)

The health system is already implemented and works well. Document the formula:

```gdscript
# Break time formula (implicit in current system):
# swing_duration = SWING_ANIMATION_TIME / tool_speed_modifier (default 0.3s)
# hits_required = ceil(block_hardness / tool_damage)
# total_break_time = hits_required * swing_duration

# Example with Rusty Pickaxe (damage=10, speed=1.0) vs Stone (hardness=60):
# hits = ceil(60/10) = 6
# time = 6 * 0.3 = 1.8 seconds
```

### Option B: Time-Based Mining (Alternative)

Instead of discrete hits, continuous progress:

```gdscript
# Alternative: Progress-based mining
var mining_progress: float = 0.0

func _process(delta: float) -> void:
    if is_being_mined:
        var progress_rate = tool_damage / block_hardness * tool_speed
        mining_progress += progress_rate * delta
        if mining_progress >= 1.0:
            break_block()
```

**Recommendation:** Stick with Option A (current health/hit system) - it feels more satisfying with discrete "chunk" feedback.

### Speed Modifier Integration

Tools have a `speed_modifier` that should affect swing animation speed:

```gdscript
# player.gd - when starting mining animation
func _start_mining(direction: Vector2i, target_block: Vector2i) -> void:
    # ... existing code ...
    var tool_speed := PlayerData.get_tool_speed()
    sprite.speed_scale = tool_speed  # 1.0 = normal, 1.5 = 50% faster
    sprite.play("swing")
```

### Balance Table

| Block Type | Hardness | Rusty (10dmg) | Copper (20dmg) | Iron (35dmg) |
|------------|----------|---------------|----------------|--------------|
| Topsoil | 15 | 2 hits (0.6s) | 1 hit (0.3s) | 1 hit (0.3s) |
| Subsoil | 30 | 3 hits (0.9s) | 2 hits (0.6s) | 1 hit (0.3s) |
| Stone | 60 | 6 hits (1.8s) | 3 hits (0.9s) | 2 hits (0.6s) |
| Deep Stone | 100 | 10 hits (3.0s) | 5 hits (1.5s) | 3 hits (0.9s) |
| Granite | 150 | 15 hits (4.5s) | 8 hits (2.4s) | 5 hits (1.5s) |

### Mining Progress Visual

Show damage state visually:

```gdscript
# dirt_block.gd
func take_hit(damage: float) -> bool:
    current_health -= damage

    # Update visual to show damage
    var damage_pct := 1.0 - (current_health / max_health)
    _update_damage_visual(damage_pct)

    return current_health <= 0

func _update_damage_visual(pct: float) -> void:
    # Darken block as it takes damage
    color = base_color.darkened(pct * 0.4)

    # Optional: Add crack overlay at 50% damage
    if pct > 0.5:
        $CrackOverlay.visible = true
```

## Edge Cases

- Zero hardness block: One hit breaks it
- Zero damage tool: Cannot break (would be infinite hits)
- Speed modifier of 0: Clamp to minimum 0.1
- Very high damage vs low hardness: Minimum 1 hit required

## Verify

- [ ] Build succeeds
- [ ] Block with hardness 60 takes 6 hits with damage 10 tool
- [ ] Upgrading tool reduces hits required
- [ ] Block visual shows damage progress (darkening)
- [ ] Speed modifier affects swing animation speed
- [ ] Very soft blocks still require at least 1 hit
- [ ] Breaking time feels balanced (not too fast, not too slow)
