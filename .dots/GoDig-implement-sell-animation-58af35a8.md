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

From [Game Economist research](https://www.gameeconomistconsulting.com/the-best-currency-animations-of-all-time/):
> "Currency animations function as classically conditioned injection of dopamine, linking player actions to visible rewards."

## Implementation Details

### Visual Flow (Most Important)
1. Coins must visually flow FROM sold items TO wallet location
2. Use 'spread' pattern (arc outward then converge) - NOT straight lines
3. Coins should spin/rotate and reflect light
4. 5-15 coin sprites, staggered timing (not all at once)
5. Brief 0.1s pause when first coin reaches wallet (Brawl Stars pattern)

### Counter Animation
1. Number ROLLS up, never snaps instantly
2. Rolling speed proportional to amount (bigger = faster increments)
3. Show exact amount being added (+$250)
4. Pulse/glow effect on wallet icon during count-up

### Audio Design
1. Coin "clink" sounds, slightly randomized pitch
2. Volume/intensity scales with sell amount
3. Final "completion" sound when counter stops
4. Consider bass undertone for large sales (>$500)

### Timing Guidelines
| Event | Duration | Notes |
|-------|----------|-------|
| Coins spawn | 0.0s | Immediate on button press |
| First coin arrives | 0.3-0.4s | Arc trajectory |
| All coins collected | 0.6-0.8s | Staggered arrival |
| Counter finishes | 0.2-0.5s | Rolling increment |
| Total animation | 0.8-1.3s | Not too slow |

### Performance Optimization
- Pool coin sprites (don't instantiate each time)
- Max 20 coin sprites even for large sales
- Use tweens, not physics simulation

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
- [ ] Coins spread/arc, not straight line
- [ ] Brief pause when coins reach wallet
- [ ] Large sells (100+ coins) feel special (Session 13)
- [ ] Player cannot spam-sell during animation (Session 13)

## Related Session 13 Research

From sell animation psychology research:
- "Accumulated coin piles accompanied by sparkling sounds evoke feelings of achievement"
- "Vivid visuals - shining coins, flashing lights - amplify perceived reward"
- The sell moment is a KEY REWARD BEAT in the core loop

From Idle Miner Tycoon analysis:
- Players love the "return-from-idle" animation showing earnings
- "Satisfying loop where small actions support big goals"
- The visual feedback IS the reward, not just the number

## Related Specs
- See `GoDig-implement-satisfying-sell-150bde42` for additional Session 13 context
