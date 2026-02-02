---
title: "implement: Pickaxe upgrade comparison UI"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-02-01T01:33:19.268707-06:00\""
closed-at: "2026-02-02T09:53:06.009647-06:00"
close-reason: Duplicate of upgrade-stat-5658fcef, already implemented in shop.gd
---

## Description
Show before/after stats when purchasing a pickaxe upgrade. Players need to FEEL the upgrade is worthwhile.

## Context
Research: 'Slow pickaxe -> fast pickaxe should be FELT.' Dome Keeper found that 'tangible feedback feels great.' The upgrade moment is a milestone that should show exactly what's improving.

## Implementation
1. When player opens Blacksmith and selects upgrade:
   - Show current pickaxe stats on left
   - Show new pickaxe stats on right
   - Highlight improvements in green with up arrows
2. Stats to compare:
   - Damage: 10 -> 20 (+100%)
   - Speed: 1.0x -> 1.1x (+10%)
   - Break time estimate: ~2s -> ~0.9s
3. Add 'Test swing' preview animation
4. After purchase: brief celebration (screen shake + sound)

## Affected Files
- scripts/ui/blacksmith_shop.gd - Comparison panel logic
- scenes/ui/upgrade_comparison.tscn - UI layout
- scripts/autoload/sound_manager.gd - Upgrade celebration sound

## Verify
- [ ] Stats comparison shows before/after clearly
- [ ] Improvements highlighted in green
- [ ] Purchase triggers celebration
- [ ] UI fits on mobile screens
- [ ] Animation preview feels satisfying
