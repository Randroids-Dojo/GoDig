---
title: "implement: Sell animation with coin flow"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T01:27:11.381014-06:00"
---

## Description
Add satisfying visual/audio feedback when selling resources - coins fly from inventory to wallet counter with rolling increment.

## Context
Research shows currency animations are 'classically conditioned reward triggers'. The sell moment is where accumulated mining effort becomes tangible reward. This must feel satisfying to motivate another run.

## Implementation
1. When sell button clicked, spawn coin sprites from sold item positions
2. Coins arc toward wallet counter in HUD
3. Use 'spread' pattern not straight line (more visual drama)
4. Counter rolls up with slot-machine effect
5. Sound pitch increases with larger amounts
6. Brief pause (0.1s) when coins reach counter (Brawl Stars pattern)

## Affected Files
- `scripts/ui/shop.gd` - Trigger sell animation
- `scenes/effects/coin_fly.tscn` - Coin sprite with arc motion
- `scripts/effects/coin_fly.gd` - Animation logic
- `scripts/ui/hud.gd` - Rolling counter increment
- `scripts/autoload/sound_manager.gd` - Coin collection sounds

## Verify
- [ ] Coins visibly fly from sold items to wallet
- [ ] Counter rolls up, doesn't just snap to new value
- [ ] Sound pitch scales with amount
- [ ] Animation feels 'juicy' not annoying
- [ ] Performance: works with 20+ items sold at once
