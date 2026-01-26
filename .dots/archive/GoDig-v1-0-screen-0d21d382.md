---
title: "implement: Screen shake effects"
status: closed
priority: 2
issue-type: task
created-at: "2026-01-16T01:01:24.199538-06:00"
---

Add screen shake to GameCamera for impactful feedback on mining hard blocks, landing from falls, and finding rare items.

## Description

Screen shake creates satisfying "weight" to player actions. The camera should shake briefly when:
- Breaking hard blocks (stone, granite, obsidian)
- Landing from falls
- Discovering rare gems/ores
- Taking damage

## Context

- Camera is currently a simple follower (`scripts/camera/game_camera.gd`)
- No visual feedback exists for mining impact
- Screen shake is a core "juice" element (see Docs/research/game-feel-juice.md)
- Must be optional (accessibility/motion sensitivity concerns)

## Affected Files

- `scripts/camera/game_camera.gd` - Add shake functionality
- `scripts/world/dirt_grid.gd` - Trigger shake when hard block breaks
- `scripts/player/player.gd` - Trigger shake on landing after falls
- `scripts/autoload/game_manager.gd` - Store shake_enabled setting

## Implementation Notes

### Camera Shake System

```gdscript
# game_camera.gd additions
var shake_intensity: float = 0.0
var shake_decay: float = 8.0  # How fast shake fades
var _original_offset: Vector2

func _ready() -> void:
    _original_offset = offset
    # ...existing code...

func _process(delta: float) -> void:
    if shake_intensity > 0:
        offset = _original_offset + Vector2(
            randf_range(-shake_intensity, shake_intensity),
            randf_range(-shake_intensity, shake_intensity)
        )
        shake_intensity = lerp(shake_intensity, 0.0, shake_decay * delta)
    else:
        offset = _original_offset

func shake(intensity: float, duration: float = 0.1) -> void:
    if not GameManager.screen_shake_enabled:
        return
    shake_intensity = intensity
    # Optional: use timer for hard cutoff
```

### Shake Intensity Scale

| Event | Intensity (px) | Duration |
|-------|----------------|----------|
| Soft block break (dirt) | 0 | - |
| Hard block break (stone) | 2-3 | 0.05s |
| Very hard break (granite) | 4-5 | 0.1s |
| Land from short fall | 1-2 | 0.05s |
| Land from long fall | 3-6 | 0.1s |
| Rare gem found | 3-4 | 0.15s |
| Taking damage | 5-8 | 0.15s |

### Signal Connection

```gdscript
# dirt_grid.gd - when block destroyed
func _on_block_destroyed(grid_pos: Vector2i, block_hardness: float) -> void:
    if block_hardness >= 20.0:  # Stone or harder
        var intensity := clamp(block_hardness / 10.0, 2.0, 6.0)
        # Access camera through player node
        player.get_node("GameCamera").shake(intensity)
```

### Settings Toggle

```gdscript
# game_manager.gd
var screen_shake_enabled: bool = true

func set_screen_shake(enabled: bool) -> void:
    screen_shake_enabled = enabled
    # Save to settings
```

## Verify

- [ ] Breaking stone triggers visible but subtle shake (2-3px)
- [ ] Breaking granite triggers stronger shake (4-5px)
- [ ] Soft blocks (dirt, clay) do NOT trigger shake
- [ ] Landing from 3+ block fall triggers shake
- [ ] Camera returns to smooth position after shake fades
- [ ] Disabling screen shake in settings prevents all shakes
- [ ] Shake feels impactful but not nauseating
- [ ] No visual jitter when shake_intensity is 0
