---
title: "implement: Hit pause (hitstop) effect"
status: open
priority: 2
issue-type: task
created-at: "2026-01-19T01:34:57.806529-06:00"
---

Brief game freeze on mining hard blocks and finding rare items for impact feedback. Creates satisfying "weight" to actions.

## Description

Implement a "hitstop" or "hit pause" effect - a brief freeze (20-50ms) when breaking hard blocks or discovering rare ores. This technique, popularized by fighting games, makes actions feel more impactful.

## Context

- Currently mining feels weightless - blocks just disappear
- Hit pause is a classic "juice" technique (see Vlambeer's "Art of Screen Shake")
- Must be very brief (imperceptible as a pause, perceived as weight)
- Should NOT pause UI or music - only game world
- See Docs/research/game-feel-juice.md

## Affected Files

- `scripts/autoload/game_manager.gd` - Add hit_pause() function
- `scripts/world/dirt_grid.gd` - Trigger on hard block break
- `scripts/player/player.gd` - Mark as pausable

## Implementation Notes

### Hit Pause Function

```gdscript
# game_manager.gd additions
var _hitstop_active: bool = false

func hit_pause(duration_ms: int = 30) -> void:
    ## Brief freeze for impact feedback. Duration in milliseconds.
    if _hitstop_active:
        return  # Don't stack
    if duration_ms <= 0:
        return

    _hitstop_active = true

    # Pause only game world, not UI
    get_tree().paused = true

    # Resume after duration
    await get_tree().create_timer(duration_ms / 1000.0, true, false, true).timeout

    get_tree().paused = false
    _hitstop_active = false
```

### Process Mode for Nodes

Set nodes that should NOT pause:
```gdscript
# In UI nodes, music players, etc.
func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
```

Set nodes that SHOULD pause (default):
```gdscript
# Player, blocks, particles (default behavior)
# PROCESS_MODE_INHERIT or PROCESS_MODE_PAUSABLE
```

### Hitstop Duration Table

| Event | Duration (ms) | Notes |
|-------|---------------|-------|
| Soft block break | 0 | No pause |
| Hard block break | 20 | Subtle weight |
| Very hard break | 30 | Noticeable impact |
| Ore discovery | 30 | Excitement pause |
| Rare gem found | 40-50 | Dramatic moment |
| Taking damage | 40 | Pain feedback |

### Integration in DirtGrid

```gdscript
# dirt_grid.gd
func hit_block(grid_pos: Vector2i) -> bool:
    var block := _blocks.get(grid_pos)
    if block == null:
        return false

    var hardness := block.max_health
    var destroyed := block.take_hit()

    if destroyed:
        # Hit pause for hard blocks
        if hardness >= 20.0:  # Stone or harder
            var duration := clampi(int(hardness / 2), 20, 50)
            GameManager.hit_pause(duration)

        # ...rest of destruction logic...
        return true

    return false
```

### Special Case: Rare Discovery

```gdscript
func _on_rare_ore_found(ore: OreData) -> void:
    # Longer pause for rare finds
    match ore.rarity:
        2: GameManager.hit_pause(30)  # Rare
        3: GameManager.hit_pause(40)  # Epic
        4: GameManager.hit_pause(50)  # Legendary
```

### Settings Toggle

```gdscript
# game_manager.gd
var hitstop_enabled: bool = true

func hit_pause(duration_ms: int = 30) -> void:
    if not hitstop_enabled:
        return
    # ...rest of function...
```

### Combine with Other Effects

Hit pause works best combined with:
- Screen shake (start immediately after)
- Particle burst (visible during/after pause)
- Sound effect (play at moment of impact)

```gdscript
func _on_hard_block_break(grid_pos: Vector2i, hardness: float) -> void:
    # All effects together
    GameManager.hit_pause(int(hardness / 2))
    camera.shake(hardness / 10.0)
    spawn_particles(grid_pos)
    play_break_sound()
```

## Verify

- [ ] Breaking stone causes brief, barely perceptible pause
- [ ] Breaking dirt does NOT cause any pause
- [ ] Finding rare gem causes noticeable pause (40-50ms)
- [ ] UI remains responsive during pause
- [ ] Music continues playing during pause
- [ ] Pauses don't stack (rapid mining doesn't compound delay)
- [ ] Pause feels like "weight", not "lag"
- [ ] Can be disabled in settings
