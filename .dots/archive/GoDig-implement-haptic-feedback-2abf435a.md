---
title: "implement: Haptic feedback for ore discovery and upgrades"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-02-01T08:10:35.730454-06:00\""
closed-at: "2026-02-02T09:51:00.867757-06:00"
close-reason: Implemented haptic_feedback.gd autoload with mining, ore discovery, and upgrade haptics
---

Add mobile haptic feedback system for key game moments based on Marvel Snap and industry best practices research.

## Context
Research (Session 10) shows haptic feedback significantly improves mobile game feel. Marvel Snap users report 'feeling the weight of each move'. iOS outperforms Android but both platforms supported.

## Description
Implement haptic feedback for high-value game moments:
- Ore discovery: transient burst (medium-high intensity)
- Upgrade purchase: continuous rumble 0.3s (high intensity)  
- Ladder placement: subtle tap (low intensity)
- Block break: light tap with variation (very low)
- Danger warning: pulse pattern (medium)

## Affected Files
- scripts/player/player.gd - Mining events
- scripts/ui/hud.gd - UI button feedback
- scripts/autoload/game_manager.gd - Upgrade events
- NEW: scripts/utils/haptics.gd - Haptic feedback wrapper

## Implementation Notes
- Use Godot's Input.vibrate_handheld() for basic support
- Consider Nice Vibrations plugin for advanced patterns
- iOS: Full haptic engine support
- Android: Basic vibration support
- Reserve intense haptics for special moments (don't fatigue players)
- Sync precisely with visual/audio events

## Verify
- [ ] Ore discovery triggers haptic on iOS
- [ ] Ore discovery triggers haptic on Android
- [ ] Upgrade celebration includes rumble
- [ ] Haptic settings toggle exists in options
- [ ] No haptics in web build (graceful fallback)
