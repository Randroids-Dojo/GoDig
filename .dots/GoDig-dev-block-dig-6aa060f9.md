---
title: "implement: Block dig progress indicator"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T01:06:21.068853-06:00"
---

## Description

Show visual progress when digging a block. Currently DirtBlock darkens on damage but this is subtle. Add a more visible crack overlay or progress bar to communicate mining progress.

## Context

- Harder blocks (deeper layers) take more hits to break
- Players need clear feedback that they're making progress
- Mobile players especially need visual confirmation
- Current feedback: block modulate darkens from white to 0.3 gray

## Affected Files

- `scripts/world/dirt_block.gd` - Add crack overlay or progress visualization
- `scenes/world/dirt_block.tscn` - If using a scene (currently just extends ColorRect)
- `assets/sprites/` - Crack textures (if using overlay approach)

## Implementation Options

### Option A: Crack Overlay (Recommended)
Add a Sprite2D child that shows progressive crack textures:
```gdscript
# dirt_block.gd
var crack_sprite: Sprite2D  # Child node

func take_hit(tool_damage: float = DEFAULT_TOOL_DAMAGE) -> bool:
    current_health -= tool_damage

    # Update crack overlay based on damage percentage
    var damage_ratio := 1.0 - (current_health / max_health)
    _update_crack_overlay(damage_ratio)

    return current_health <= 0

func _update_crack_overlay(damage_ratio: float) -> void:
    if damage_ratio < 0.33:
        crack_sprite.visible = false
    elif damage_ratio < 0.66:
        crack_sprite.frame = 0  # Light cracks
        crack_sprite.visible = true
    else:
        crack_sprite.frame = 1  # Heavy cracks
        crack_sprite.visible = true
```

### Option B: Progress Bar
Add a small progress bar above the block:
```gdscript
var progress_bar: ProgressBar  # Child node

func _update_progress_bar(damage_ratio: float) -> void:
    progress_bar.value = damage_ratio * 100
    progress_bar.visible = damage_ratio > 0 and damage_ratio < 1.0
```

### Option C: Enhanced Modulate (Simplest)
Keep current darkening but add shake/pulse:
```gdscript
func take_hit(tool_damage: float = DEFAULT_TOOL_DAMAGE) -> bool:
    current_health -= tool_damage

    # Visual feedback
    var damage_ratio := 1.0 - (current_health / max_health)
    modulate = Color.WHITE.lerp(Color(0.3, 0.3, 0.3), damage_ratio)

    # Quick shake
    var tween = create_tween()
    tween.tween_property(self, "position", position + Vector2(2, 0), 0.05)
    tween.tween_property(self, "position", position - Vector2(2, 0), 0.05)
    tween.tween_property(self, "position", position, 0.05)

    return current_health <= 0
```

## Recommendation

For MVP, use Option C (enhanced modulate with shake) as it requires no new assets. For v1.0, upgrade to Option A (crack overlay) for better visual polish.

## Verify

- [ ] Build succeeds
- [ ] Hitting a block shows visible feedback
- [ ] Multiple hits show progressive damage visually
- [ ] Feedback is clear on mobile (not too subtle)
- [ ] Feedback works for all layer types (dirt, stone, etc.)
- [ ] Performance: no lag when hitting multiple blocks quickly
