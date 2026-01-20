---
title: "implement: Reduced motion accessibility option"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-19T03:39:41.468160-06:00\""
closed-at: "2026-01-19T19:35:08.574949-06:00"
close-reason: Reduced motion in settings_manager.gd
---

## Description

Add a reduced motion setting for players who are sensitive to screen motion, animations, or have vestibular disorders. When enabled, this setting tightens physics, reduces/removes particle effects, disables screen shake, and simplifies animations.

## Context

Apple recommends providing "alternate experiences for reduced motion" in their accessibility guidelines. This doesn't mean removing all animation - it means tightening physics and reducing unnecessary motion. Players with motion sensitivity can still enjoy the game without triggering discomfort.

## Affected Files

- `scripts/autoload/settings_manager.gd` - MODIFY: Add reduced_motion setting
- `scripts/camera/game_camera.gd` - MODIFY: Disable screen shake when reduced_motion
- `scripts/effects/particles_manager.gd` - NEW or MODIFY: Reduce particle effects
- `scripts/player/player.gd` - MODIFY: Simplify squash/stretch, tighten physics
- `scenes/ui/settings_menu.tscn` - MODIFY: Add reduced motion toggle

## Implementation Notes

### What Reduced Motion Affects

| Feature | Normal | Reduced Motion |
|---------|--------|----------------|
| Screen shake | Full | Disabled |
| Particle effects | Full | Minimal/none |
| Squash/stretch on landing | Full | Subtle or none |
| Camera smoothing | Smooth follow | Tighter/instant |
| UI transitions | Animated | Instant/fade |
| Background parallax | Full motion | Reduced/static |
| Floating text | Animated | Static or fade |

### Implementation Approach

```gdscript
# Check setting before applying motion effects
if not SettingsManager.reduced_motion:
    _apply_screen_shake(intensity)

# For animations, use shorter durations
func _get_animation_duration(base_duration: float) -> float:
    if SettingsManager.reduced_motion:
        return base_duration * 0.3  # Much faster
    return base_duration

# For particle effects
func _spawn_particles(type: String) -> void:
    if SettingsManager.reduced_motion:
        return  # Skip entirely or use simplified version
    # ...spawn normal particles
```

### Camera Changes

```gdscript
# game_camera.gd
func shake(intensity: float, duration: float) -> void:
    if SettingsManager.reduced_motion:
        return  # No shake
    # ...normal shake implementation
```

### Player Physics

When reduced motion is enabled:
- Fall physics are tighter (less floaty)
- Landing squash/stretch reduced to 10% or removed
- Movement tweens are faster

### UI Transitions

- Replace slide/bounce with instant appear or quick fade
- Menu transitions use shorter durations
- Notification pop-ups use fade instead of bounce

### Edge Cases

- Setting can be changed mid-game
- Existing particles/animations should stop gracefully
- Core gameplay must remain functional
- Achievement/pickup feedback still visible (just not animated)

## Verify

- [ ] Build succeeds
- [ ] Reduced motion toggle appears in settings
- [ ] Screen shake disabled when setting enabled
- [ ] Particle effects reduced/removed
- [ ] Camera follows player more tightly
- [ ] UI animations simplified
- [ ] Game remains fully playable with setting enabled
- [ ] Setting persists after app restart
