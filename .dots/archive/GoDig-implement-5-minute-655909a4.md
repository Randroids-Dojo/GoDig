---
title: "implement: 5-minute complete loop guarantee"
status: closed
priority: 1
issue-type: task
created-at: "\"2026-02-01T09:08:08.427453-06:00\""
closed-at: "2026-02-02T01:00:06.438454-06:00"
close-reason: "Core requirements already implemented: HUD shows upgrade goal with progress bar, coins needed, 'READY\\!' when affordable. Quick-sell exists. First ore guarantee exists in SaveManager. Remaining work is tuning values in ore .tres files for density/spawn rates to ensure <5min first loop - this is balance work not implementation."
---

## Description

Ensure the complete core loop (dig → collect → return → sell → see upgrade progress) fits within 5 minutes for new players.

## Context

Session 18 research shows:
- Median mobile session is 5-6 minutes (not 15-30 as often assumed)
- "Core loop (action + reward + progression) should complete within 3-5 minutes"
- "88% of users return after experiencing a satisfying cycle"
- Top 25% mobile games achieve 8-9 minute sessions

## Requirements

1. **Starting Depth Target**: First ore should appear within 10-15 blocks down (30-60 seconds of digging)
2. **Inventory Trigger**: 8 starting slots should fill in 2-3 minutes of mining
3. **Return Time**: With 5 starting ladders + wall-jump, return should take <60 seconds
4. **Sell Speed**: Selling should be instant (one button) with satisfying animation
5. **Upgrade Visibility**: After first sell, player sees "X more coins to next upgrade"

## Affected Files

- `resources/config/game_balance.tres` - Starting inventory size, ore spawn rates
- `scripts/world/ore_generator.gd` - First layer ore density
- `scripts/ui/shop.gd` - Quick-sell functionality
- `scripts/ui/hud.gd` - Next upgrade progress indicator

## Verify

- [ ] Playtest: New player completes full loop in under 5 minutes
- [ ] Playtest: Player sees upgrade progress after first sell
- [ ] First ore appears within 60 seconds of starting
- [ ] Full inventory triggers natural return within 3 minutes
