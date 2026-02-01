---
title: "research: Session length and natural stopping points"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-01T01:36:53.489854-06:00\\\"\""
closed-at: "2026-02-01T01:38:40.378784-06:00"
close-reason: "Completed: Target 5-8 min sessions via 8-slot inventory + ladder economy. No artificial reminders needed."
---

## Question
What creates ideal 5-15 minute sessions with natural stopping points?

## Current Stopping Points
1. Inventory full - must return to sell
2. Out of ladders - must return to buy
3. Death - respawn at surface

## Potential Issues
- Sessions too long = mobile unfriendly
- Sessions too short = no progression feeling
- Forced stops = frustrating
- No stops = endless grind

## Research Tasks
- [x] Analyze: what triggers players to stop playing similar games?
- [x] Calculate: average time to fill 8 slots with ore
- [x] Check: do other mobile games have session length data?
- [x] Consider: should we add soft 'time to go back' reminders?

## Research Findings

### Mobile Game Session Length Data (2025)

From [Udonis](https://www.blog.udonis.co/mobile-marketing/mobile-games/mobile-gaming-statistics) and [SQ Magazine](https://sqmagazine.co.uk/mobile-games-statistics/):

| Game Type | Average Session | Sessions/Day |
|-----------|-----------------|--------------|
| Mobile overall | 4-5 min | 4-6 |
| Top 25% mobile | 8-9 min | 3-4 |
| Casual games | 7-8 min | 4-5 |
| Coin Master | 11 min | 4.6 |
| Gardenscapes | 18 min | 5.3 |

**Key insight**: Top performing mobile games achieve 8-9 minute sessions. Our target of 5-15 minutes is aligned with industry best.

### Natural Stopping Points in Idle Games

From [Mobile Free To Play](https://mobilefreetoplay.com/why-you-should-care-about-idle-games/) and [Machinations](https://machinations.io/articles/idle-games-and-how-to-design-them):

- "The perfect mobile session finds a way to naturally push players out"
- "Eventually the smart choice is the one where the player must wait"
- 73% of daily users return at least twice per day when friction is tuned right

**GoDig's natural stops**:
1. **Inventory full** - hard stop, must return to sell (this is good)
2. **Out of ladders** - soft stop, can wall-jump but risky (creates tension)
3. **Achieved goal** - bought upgrade, saved game, natural break

### Session Pacing Best Practices

From [GameAnalytics](https://www.gameanalytics.com/blog/how-to-make-an-idle-game-adjust):

- "Avoid overwhelming players in first 10-30 minutes"
- "Let players settle into the loop, build trust"
- "When pace slows, the value of spending becomes obvious"
- Games with well-paced loops see 10-15% D7 retention vs 8% typical

**Smart friction** = habit first, then choice. GoDig should:
- First trip: easy success (5 ladders, generous ore)
- Second trip: introduce shop choices
- Third trip: feel upgrade impact

### Time to Fill 8 Inventory Slots (Estimate)

**Assumptions**:
- Dig speed: ~1 block per second average (varies by tool)
- Ore density: 1 ore every 10-15 blocks early game
- Collect + position: ~3 seconds per ore

**Estimate**:
- 8 ores × 15 blocks/ore × 1s/block = 120 seconds digging
- 8 ores × 3 seconds pickup/positioning = 24 seconds
- Total collection: ~2.5 minutes

**Add return trip**: 1-2 minutes with ladders/wall-jump
**Add selling**: 30 seconds

**Total session**: ~4-5 minutes for efficient play

This matches mobile casual benchmarks perfectly.

### Should We Add Soft Reminders?

**Analysis**: GoDig already has organic stopping points:
- Inventory warnings at 60%/80%/100% (already specced)
- Ladder warnings when low (new spec)
- Safe return celebration (new spec)

**Recommendation**: NO explicit "time to stop" reminders
- They feel artificial and patronizing
- Inventory/ladder systems provide natural friction
- Let players choose their own session length

## Recommendations

### Session Design Targets

| Metric | Target | Rationale |
|--------|--------|-----------|
| Session length | 5-8 min | Matches mobile casual benchmarks |
| Sessions/day | 3-5 | Typical for casual genre |
| Time to first upgrade | 3-5 min | Hook players before churn |
| Time to inventory full | 3-4 min | Creates natural return trip |

### Implementation Priorities

1. **Inventory warning system** (already specced) - Creates "should I return?" moment
2. **Ladder warning system** (new spec) - Adds tension layer
3. **Quick-buy ladder from HUD** (already specced) - Reduces friction on return
4. **Safe return celebration** (new spec) - Rewards completing the loop

### What NOT To Do

- Don't add timers or energy systems
- Don't add pop-ups telling players to take breaks
- Don't cap inventory artificially low (8 is correct)
- Don't make ladders so cheap they're not a decision

## Expected Outcome
**Target 5-8 minute sessions** achieved through:
- 8-slot inventory (~4 min to fill)
- Natural return trip (~1-2 min)
- Shop/upgrade decisions (~1 min)
- Celebration/save moment (natural break)
