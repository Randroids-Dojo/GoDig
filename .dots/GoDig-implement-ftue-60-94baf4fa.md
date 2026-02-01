---
title: "implement: FTUE 60-second hook - dig, find ore, return"
status: open
priority: 0
issue-type: task
created-at: "2026-02-01T08:59:50.273331-06:00"
---

## Description

Design the First Time User Experience (FTUE) to hook players in 60 seconds with the complete core loop: dig -> find ore -> return -> sell. No menus, no tutorials, no splash screens - just play.

## Context

Mobile onboarding research: "First thing players need is to PLAY! Don't make them click/choose/sign in." FTUE covers first 60 seconds + first 15 minutes. Full onboarding covers first 7 days.

## FTUE Timeline (60 seconds)

| Time | Event | Player Action | Feedback |
|------|-------|---------------|----------|
| 0-5s | Game loads | Player sees surface | Minimal UI, finger pointing down |
| 5-15s | First dig | Tap below character | Satisfying dig sound, particles |
| 15-30s | Find first ore | Continue digging | Guaranteed ore spawn, celebration sound |
| 30-40s | Collect ore | Touch ore | Pickup animation, "Got [ore name]!" |
| 40-50s | Return to surface | Climb up (wall-jump or starter ladder) | Arrow pointing to shop |
| 50-60s | First sell | Enter shop, tap sell | Coin cascade, money counter goes up |

## Critical Requirements

1. **No splash screens** - Load directly into gameplay
2. **Guaranteed ore** - First ore MUST spawn within 3 blocks of surface
3. **Clear return path** - Starter ladders or obvious wall-jump tutorial
4. **Instant sell** - Auto-trigger sell on first shop visit
5. **Celebrate everywhere** - Sound, particles, screen shake for every milestone

## Affected Files

- `scripts/main.gd` - Skip menus on first launch
- `scripts/world/ore_spawner.gd` - Guaranteed first ore placement
- `scripts/ui/ftue_overlay.gd` - Minimal guidance arrows
- `scripts/player/player.gd` - First-time player flags
- `scripts/shops/shop_controller.gd` - Auto-sell on first visit
- `scripts/autoload/save_manager.gd` - Track FTUE completion

## Implementation Notes

- Save flag `ftue_completed` to only run this flow once
- After first sell, show minimal "Well done!" then fade to normal gameplay
- Tutorial systems (shop details, upgrades, etc.) introduced on Day 2+ sessions
- If player dies during FTUE, instant respawn with no penalty

## Verify

- [ ] Build succeeds
- [ ] New game starts directly in gameplay (no menus)
- [ ] First ore spawns within 3 blocks of starting position
- [ ] Player can complete dig->collect->return->sell in under 60 seconds
- [ ] Celebration feedback on: first dig, first ore, first sell
- [ ] FTUE only runs once per save file
- [ ] After FTUE, normal game flow resumes
- [ ] Death during FTUE = instant respawn, no punishment
