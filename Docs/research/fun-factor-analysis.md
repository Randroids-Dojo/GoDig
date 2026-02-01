# Fun Factor Analysis - Mining Game Core Loop

> Research compilation from game design analysis, forums, and similar games.
> Last updated: 2026-02-01 (Session 2: Variable Reward Deep Dive)

## Core Loop Summary

```
1. DIG DOWN   -> Mine resources, discover ores (dopamine hits)
2. COLLECT    -> Fill inventory (accumulation satisfaction)
3. TENSION    -> Risk of getting stuck, distance from safety
4. RETURN     -> Navigate back to surface (challenge/relief)
5. SELL       -> Exchange resources (reward realization)
6. UPGRADE    -> Buy better tools (power fantasy)
7. REPEAT     -> Go deeper for rarer resources
```

## What Makes Mining Games Fun (Research Findings)

### 1. The Discovery Loop
- **Variable Ratio Reinforcement**: Unpredictable rewards are more engaging than predictable ones
- Each block broken reveals what's underneath - constant micro-discoveries
- "What's behind this block?" creates anticipation
- Rare finds create memorable "jackpot" moments

**Implementation Priority**: Ore distribution should create surprise, not predictable patterns.

### 2. Risk vs Reward Tension
- Deeper = more danger but better rewards
- Players should choose their risk tolerance
- The fear of losing collected resources drives strategic thinking
- Getting "stuck" should feel like a challenge, not a failure

**Key Insight from SteamWorld Dig**: Wall-jumping transformed "stuck" from binary failure to recoverable predicaments. Players who fell into holes initially panicked, then discovered clever escape routes - creating satisfaction through problem-solving.

### 3. Investment Protection
- "I've collected so much, must get back safely"
- Creates natural tension and stakes
- Makes safe return feel like victory
- Full inventory = immediate goal to return

**Design Implication**: Inventory size directly controls session pacing.

### 4. Upgrade Satisfaction
- Slow pickaxe -> fast pickaxe should be FELT
- Visual upgrade differences matter
- Speed improvements are immediately noticeable
- Power fantasy fulfillment

**Dome Keeper Finding**: "This immediately provides visible feedback in the form of faster digging, and passive feedback in that future upgrades come sooner. This kind of tangible feedback feels great."

### 5. Home Base Comfort
- Surface represents safety
- Shops provide upgrade satisfaction
- Contrast makes surface feel rewarding
- Cycle between danger and comfort creates satisfying rhythm

### 6. Session Design
- Target: 5-15 minute sessions with natural stopping points
- Inventory full is most natural break point
- Should happen every 3-8 minutes early game
- "Just fill inventory then stop" mindset

## Critical Early Game Requirements

1. **First upgrade in 2-5 minutes** - Critical retention moment
2. **Starting ladders available** - Teaches mechanic safely
3. **Supply Store at 0m** - Players need escape items before getting stuck
4. **Clear feedback loops** - Every action has visible reaction

## Juice/Game Feel Priorities

| Element | Priority | Impact |
|---------|----------|--------|
| Ore discovery sound/visual | High | Core dopamine trigger |
| Upgrade celebration | High | Milestone moment |
| Screen shake on hard blocks | Medium | Satisfying feedback |
| Combo/streak sounds | Medium | Rhythm building |
| Inventory warnings | High | Creates return tension |
| Depth milestones | Medium | Progress celebration |

## Anti-Patterns to Avoid

1. **Getting truly stuck with no escape** - Always provide recovery options
2. **Dead zones without meaningful upgrades** - Something new every 10-15 min
3. **Loss that erases too much progress** - Death should sting, not devastate
4. **Artificial waiting/timers** - Respect player time
5. **Tedious return trips** - Elevator unlocks help late game

## Variable Reward & Discovery Psychology (Session 2 Research)

### Variable Ratio Reinforcement - Why It Works

From [Number Analytics](https://www.numberanalytics.com/blog/mastering-reward-schedules-game-design) and [PMC Research](https://pmc.ncbi.nlm.nih.gov/articles/PMC7882574/):

- **Anticipation produces dopamine**: Counter-intuitively, dopamine is released during ANTICIPATION, not just reward receipt
- **Uncertainty is compelling**: "Dopamine cells are most active when there is maximum uncertainty"
- **The perfect trifecta**: Games succeed because they provide anticipation + unpredictability + immediate feedback
- **Variable > Fixed**: Unpredictable rewards are more engaging than predictable schedules

### Near-Miss Psychology

From [Psychology of Games](https://www.psychologyofgames.com/2016/09/the-near-miss-effect-and-game-rewards/):

- Near-misses activate the same reward systems as actual wins
- May be MORE motivating than winning or losing
- Design implication: "Engineer more chances to almost win"
- In mining context: blocks near ore veins could shimmer subtly

### Return Trip Tension - Similar Games

**Deep Rock Galactic**:
- "Delightfully tense" extraction phase
- Limited time to return while fighting enemies
- Risk/reward dynamic praised by reviewers

**Dome Keeper**:
- "Mining is meditative, but tension hangs in background"
- "Each wave forces meaningful decisions - do you push your luck and mine deeper, or play it safe?"
- Enemy is time itself, not monsters

### Roguelike "One More Run" Psychology

From [Hearthstone](https://hearthstone-decks.net/one-more-run-the-most-addictive-roguelike-pc-games/):

- "Every failure feels like a lesson, every win feels like a triumph"
- Meta-progression (Rogue Legacy style) reduces sting of death
- "Just one more run" itch from death + immediate retry

### Game Feel / Juice Best Practices

From [GameAnalytics](https://www.gameanalytics.com/blog/squeezing-more-juice-out-of-your-game-design):

- Juicing = taking working game and adding layers of satisfaction
- Shooting games: make player feel powerful (larger bullets, recoil, screen shake)
- Level-up sounds provide "slower-burning feedback on satisfying progress"
- Synchronized audio-visual cues enhance perceived fairness and satisfaction

## Sources

- [Game Design Deep Dive: SteamWorld Dig](https://www.gamedeveloper.com/design/game-design-deep-dive-the-digging-mechanic-in-i-steamworld-dig-i-)
- [Design Dive: Dome Keeper](https://joshanthony.info/2023/05/24/design-dive-dome-keeper/)
- [The Psychology Behind Idle Game Addictiveness](https://artifexterra.com/the-psychology-behind-idle-game-addictiveness/)
- [Risk-Reward Cycles in Modern Game Design](https://playercounter.com/blog/why-risk-reward-cycles-dominate-modern-game-design/)
- [Core Gameplay Loop Design](https://blog.gamedistribution.com/core-gameplay-loop-design-small-tweaks-big-engagement/)
- [Mining in Games Analysis](http://gamedesignreviews.com/scrapbook/mining-in-games/)
- [Number Analytics: Mastering Reward Schedules](https://www.numberanalytics.com/blog/mastering-reward-schedules-game-design)
- [PMC: Loot Boxes and Arousal](https://pmc.ncbi.nlm.nih.gov/articles/PMC7882574/)
- [Psychology of Games: Near Miss Effect](https://www.psychologyofgames.com/2016/09/the-near-miss-effect-and-game-rewards/)
- [Gamedeveloper: Compulsion Loops & Dopamine](https://www.gamedeveloper.com/design/compulsion-loops-dopamine-in-games-and-gamification)

## Implementation Checklist for Fun Factor

### Phase 1: Critical Path (P1)
- [ ] Supply Store unlock at 0m depth
- [ ] 3 starting ladders on new game
- [ ] First upgrade achievable in under 5 minutes
- [ ] Quick-buy ladder button in HUD
- [ ] Basic ore discovery feedback

### Phase 2: Core Polish (P2)
- [ ] Upgrade celebration effects
- [ ] Depth milestone celebrations
- [ ] Inventory tension indicators (60%/80%/100%)
- [ ] Forfeit Cargo escape option
- [ ] Enhanced ore discovery (haptics, sounds)

### Phase 3: Refinement (P3)
- [ ] Mining combo/streak feedback
- [ ] Surface home base comfort signals
- [ ] Risk indicator for deep dives
- [ ] Rare ladder drops from blocks

### Phase 4: Discovery Polish (P4 - New from Session 2)
- [ ] Near-miss ore hints (shimmer on blocks adjacent to veins)
- [ ] Jackpot celebration for rare/legendary finds
- [ ] First-discovery bonus system
- [ ] Cave treasure chests
- [ ] Deep dive tension meter (unified indicator)
