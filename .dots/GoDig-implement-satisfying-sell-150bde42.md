---
title: "implement: Satisfying sell animation with coin cascade"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T08:31:11.616576-06:00"
---

## Description

The sell moment is a KEY REWARD BEAT in the core loop. Currently it's just a number change. Need satisfying coin cascade animation + sound to make selling feel rewarding.

## Context (Session 13 Research)

From sell animation psychology research:
- "Accumulated coin piles accompanied by sparkling sounds evoke feelings of achievement"
- "Vivid visuals - shining coins, flashing lights - amplify perceived reward"
- "Awards should be made immediately... player quickly confirms competence"

From Idle Miner Tycoon analysis:
- Players love the "return-from-idle" animation showing earnings
- "Satisfying loop where small actions support big goals"
- The visual feedback IS the reward, not just the number

From mobile game economy research:
- Short-term rewards create momentum
- "Bright flashes, triumphant sounds draw attention to rewards"

## The Problem

Without sell animation:
1. Player digs for 3 minutes collecting ore
2. Returns to surface
3. Taps "Sell"
4. Number goes up
5. ...that's it?

The payoff doesn't match the effort. This is where "one more run" psychology is built or lost.

## Design

### Coin Cascade Animation

When player sells inventory:

1. **Items fly out** of inventory slots toward coin counter
2. **Each item** transforms into appropriate coin value (visual coins)
3. **Coins cascade** with slight delay between each
4. **Coin counter** ticks up rapidly (satisfying number roll)
5. **Final flash** when all coins collected
6. **Sound**: "cha-ching" crescendo building as coins flow

### Scaling by Value

| Sell Value | Effect |
|------------|--------|
| 1-50 coins | Basic cascade, subtle sound |
| 51-200 coins | More coins, longer cascade, building sound |
| 201-500 coins | Sparkling particles, screen glow, triumphant sting |
| 500+ coins | "JACKPOT" style - coins explode outward then collect |

### Implementation

1. Create `SellAnimation` scene:
   - Spawns coin sprites at inventory position
   - Coins arc toward HUD coin counter
   - Coin counter rapidly ticks up
   - Particles and flash at the end

2. Hook into shop sell flow:
   ```gdscript
   func _on_sell_all_pressed():
       var total_value = calculate_sell_value()
       var items_to_sell = get_sellable_items()

       # Don't add coins immediately - let animation do it
       sell_animation.play(items_to_sell, total_value)
       sell_animation.finished.connect(_on_sell_complete)
   ```

3. Sound design:
   - Individual coin clinks (pooled, pitched slightly random)
   - Rising tone as value accumulates
   - Final "cha-ching" or cash register sound

## Affected Files

- `scenes/ui/sell_animation.tscn` - NEW: animation scene
- `scripts/ui/sell_animation.gd` - NEW: animation controller
- `scripts/ui/shop.gd` - Hook animation into sell flow
- `assets/audio/` - Coin clink, sell complete sounds
- `assets/sprites/` - Coin sprite (may already exist)

## Verify

- [ ] Selling 1 item shows visible coin fly to counter
- [ ] Selling full inventory creates satisfying cascade
- [ ] Coin counter ticks up (not instant jump)
- [ ] Sound matches visual timing
- [ ] Large sells (100+ coins) feel special
- [ ] Animation completes in reasonable time (under 2 seconds)
- [ ] Player cannot spam-sell during animation
- [ ] Works on low-end mobile devices

## Dependencies

- Shop UI must be functional
- Inventory sell flow must work

## Related Research

Session 13: Sell animation psychology, Idle Miner Tycoon economy design
Session 12: First Upgrade Hook Psychology - "satisfaction of seeing hero improve"
