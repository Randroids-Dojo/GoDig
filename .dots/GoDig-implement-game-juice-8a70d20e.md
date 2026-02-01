---
title: "implement: Game juice accessibility options"
status: open
priority: 3
issue-type: task
created-at: "2026-02-01T09:08:28.350381-06:00"
---

## Description

Add accessibility options to customize the intensity of visual and audio feedback effects.

## Context

Session 18 research (Game Juice Best Practices 2025):
- "When used correctly, screen shake creates engaging game feel; if overused, players feel nauseous"
- "Accessibility: Implement options to customize intensity of visual/audio effects"
- Screen shake should be 0.1-0.3 seconds, not constant
- Mining is CONSTANT activity - effects must not fatigue players

## Options to Add

1. **Screen Shake Intensity**: Off / Low / Medium / High
2. **Particle Density**: Minimal / Normal / Rich
3. **Flash Effects**: Off / Reduced / Normal
4. **Hit Stop**: Off / Subtle / Normal
5. **Sound Variation**: Subtle / Normal / Dynamic

## Default Settings

- Screen Shake: Medium (most players expect it)
- Particle Density: Normal
- Flash Effects: Reduced (accessible default)
- Hit Stop: Subtle
- Sound Variation: Normal

## Affected Files

- `resources/config/accessibility_settings.tres` - New config file
- `scripts/autoload/settings_manager.gd` - Persist accessibility prefs
- `scripts/effects/screen_shake.gd` - Respect intensity setting
- `scripts/effects/particles.gd` - Respect density setting
- `scenes/ui/settings_menu.tscn` - Add accessibility tab

## Verify

- [ ] Screen shake can be disabled completely
- [ ] Particle effects scale with density setting
- [ ] Settings persist between sessions
- [ ] Reduced motion preset available for motion-sensitive players
