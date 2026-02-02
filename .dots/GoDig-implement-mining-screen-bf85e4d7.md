---
title: "implement: Mining screen shake feedback"
status: active
priority: 2
issue-type: task
created-at: "\"2026-02-01T02:24:26.077981-06:00\""
---

## Description
Add subtle screen shake on block hits to make mining feel impactful and weighty.

## Context
Screen shake is one of the most effective 'juice' techniques. Must be subtle for normal blocks, more pronounced for hard blocks and ore discoveries.

## Affected Files
- `scripts/camera/game_camera.gd` - Add shake functionality
- `scripts/player/player.gd` - Trigger shake on block hits

## Implementation Notes
### Shake Parameters
| Event | Magnitude | Duration | Notes |
|-------|-----------|----------|-------|
| Normal block hit | 2-4px | 0.1s | Barely noticeable but adds feel |
| Hard block hit | 4-6px | 0.15s | Player feels resistance |
| Block break | 6-8px | 0.15s | Satisfaction of completion |
| Ore discovery | 8-10px | 0.2s | Celebration\! |
| Rare gem | 12px + slowmo | 0.25s | Special moment |

### Technical Implementation
1. Use smooth easing (ease-out) for natural feel
2. Randomize direction slightly
3. Don't interrupt gameplay flow
4. Optionally disable in settings (accessibility)

### Formula
```gdscript
func shake(magnitude: float, duration: float) -> void:
    var tween = create_tween()
    for i in range(int(duration * 60)):  # 60fps
        var offset = Vector2(
            randf_range(-magnitude, magnitude),
            randf_range(-magnitude, magnitude)
        ) * (1.0 - float(i) / (duration * 60))  # Decay
        tween.tween_property(self, "offset", offset, 0.016)
```

## Verify
- [ ] Normal blocks have subtle, barely-noticeable shake
- [ ] Hard blocks have more pronounced shake
- [ ] Ore discovery has satisfying strong shake
- [ ] Shake decays smoothly (no abrupt stop)
- [ ] Can be disabled in settings
- [ ] Does not cause motion sickness at normal levels
