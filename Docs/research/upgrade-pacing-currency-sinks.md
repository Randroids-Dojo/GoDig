# Upgrade Pacing and Currency Sinks: Preventing Mid-Game Stagnation

> Research on how successful mobile games pace upgrade purchases to maintain engagement, optimal time between upgrades, currency sink design, and avoiding the "nothing to buy" problem.
> Last updated: 2026-02-02 (Session 26)

## Executive Summary

Mid-game stagnation is one of the most common causes of player churn in mobile games. This research synthesizes industry knowledge on **upgrade pacing**, **currency sinks**, **reward schedules**, and solutions for the "nothing to buy" problem. Key findings: aim for a 3:1 earn-to-spend ratio, provide rewards every 5-30 seconds during active play, and use variable ratio schedules for maximum engagement while reserving fixed intervals for predictable milestones.

---

## 1. The Economics of Game Progression

### Taps and Sinks Model

Game economies operate on a fundamental principle:
- **Tap**: Where currency comes from (mining, selling, rewards)
- **Sink**: Where currency goes (upgrades, consumables, unlocks)

> "If the tap is releasing too much currency, the sink will overflow. This results in excess currency, which decreases its value."

**Balance targets**:
| Metric | Target | Source |
|--------|--------|--------|
| Earn-to-spend ratio (end-game) | 3:1 | Industry best practice |
| Weekly stockpile growth cap | <12% | AppMagic study |
| Monthly market price stability | <15% drop | Economy health indicator |

**Sources**: [Adrian Crook - 5 Common Mobile Game Economy Problems](https://adriancrook.com/5-common-mobile-game-economy-problems-solved/), [Udonis - Balanced Mobile Game Economy](https://www.blog.udonis.co/mobile-marketing/mobile-games/balanced-mobile-game-economy)

### The Hoarding Problem

When players accumulate currency without spending, engagement stalls:

> "Looking at all users, it seems that most players are saving their Super Cash for a rainy day! In an ideal 'stable' economy, players would be spending currency at the same rate they receive it."

**Case study - Fallout 76**: Limited resource sinks and lack of engaging monetization led players to accumulate excessive wealth, reducing long-term engagement.

**Impact of poor sink design**:
- 78% of free players churn within 30 days in games lacking proper sink mechanisms (AppMagic 2023 study)
- Resource hoarding reduces the perceived value of new currency earned

---

## 2. Reward Timing and Pacing

### The Neuroscience of Rewards

> "Video games are particularly effective at triggering dopamine release because they provide a perfect trifecta: anticipation, unpredictability, and immediate feedback." - Dr. Sarah Domoff

Dopamine release occurs not just when receiving rewards, but during **anticipation**. Well-designed games trigger dopamine at optimal frequency - not so often rewards become meaningless, but frequently enough to maintain engagement.

**Sources**: [Journal of Computer-Mediated Communication - Dopamine Loops and Player Retention](https://jcoma.com/index.php/JCM/article/download/352/192), [PMC - Video Game Training and the Reward System](https://pmc.ncbi.nlm.nih.gov/articles/PMC4318496/)

### Optimal Reward Frequency

From Ratchet & Clank's design:
> "If the player is moving forward, killing enemies, and breaking crates - they should be getting bursts of bolts about every **5 seconds**. It usually takes less than **30 seconds** to finish an enemy setup."

**Timing guidelines for GoDig**:

| Action Type | Reward Frequency | Example |
|-------------|------------------|---------|
| Micro-reward | 5-10 seconds | Individual ore drop |
| Small milestone | 30-60 seconds | Depth checkpoint |
| Medium milestone | 3-5 minutes | Layer transition |
| Major milestone | 10-15 minutes | Upgrade purchase |

**Sources**: [Gamedeveloper - Reward Schedules and When to Use Them](https://www.gamedeveloper.com/business/reward-schedules-and-when-to-use-them)

### John Hopson's Behavioral Game Design

John Hopson (Ph.D. Behavioral and Brain Sciences, Head of User Research at Bungie) established the foundational framework in his influential 2001 article:

> "A contingency is a rule or set of rules governing when rewards are given out... The anecdote about this discovery is that one day B.F. Skinner ran low on food pellets. Rather than risk running out, he began providing pellets every tenth time the rats pressed the lever instead of every time. Experimenting with different regimens of reward, he found they produced markedly different patterns of response."

**Sources**: [Gamedeveloper - Behavioral Game Design](https://www.gamedeveloper.com/design/behavioral-game-design), [Gamedeveloper - 10 Years of Behavioral Game Design with Bungie's Research Boss](https://www.gamedeveloper.com/design/10-years-of-behavioral-game-design-with-bungie-s-research-boss)

---

## 3. Reward Schedule Types

### The Four Basic Schedules

| Schedule | Definition | Player Behavior | Best Use |
|----------|------------|-----------------|----------|
| **Fixed Ratio** | Reward after N actions | Burst activity, then pause | Predictable milestones (sell 10 ores) |
| **Variable Ratio** | Reward after random N actions | Constant high activity | Core gameplay (ore discovery) |
| **Fixed Interval** | Reward after T time passes | Pause, then accelerate before reward | Daily login rewards |
| **Variable Interval** | Reward after random time | Steady, consistent activity | Background bonuses |

### Variable Ratio: The Engagement Engine

> "Variable ratio schedules produce the highest overall rates of activity of all the schedules discussed."

Variable ratio creates the "slot machine effect":
- Players never know exactly when the next reward comes
- Anticipation maintains engagement between rewards
- Each action could be "the one" that triggers a reward

**GoDig Application**: Each block mined is a micro-uncertainty moment. The player knows ore exists but not which specific block contains it.

**Sources**: [Study.com - Variable Ratio Reinforcement Schedule](https://study.com/learn/lesson/variable-ratio-schedule.html), [Learning Theories - Game Reward Systems](https://learning-theories.com/game-reward-systems.html)

### Ethical Considerations

Hopson's ethical framework:
> "Contingencies in games are ethical if the designer believes the player will have more fun by fulfilling the contingency than they would otherwise."

Rewards should:
- Make the game more enjoyable, not manipulative
- Not exploit psychological vulnerabilities
- Balance profitability with player well-being

---

## 4. Idle Game Progression Mathematics

### Exponential Growth and Cost Curves

> "At the most basic level, idle games are a seesaw between production rates and costs. Early on in a run, your production will exceed costs while eventually costs will become prohibitive."

**The crossover point**:
```
Cost growth rate > Reward growth rate
```

**Example formula** (from Idle Game Design Principles):
- Each upgrade level: production +1.1x
- Each upgrade cost: price +1.15x
- Eventually, cost outpaces value, requiring strategic planning

**Sources**: [Eric Guan - Idle Game Design Principles](https://ericguan.substack.com/p/idle-game-design-principles), [Gamedeveloper - The Math of Idle Games](https://www.gamedeveloper.com/design/the-math-of-idle-games-part-i)

### The 60/40 Rule

Successful idle games target:
- **60%** of progress from idle/passive mechanics
- **40%** of progress from active engagement

This creates a healthy balance where both play styles feel rewarding.

### Engagement Phases

| Phase | Timeline | Player Goal |
|-------|----------|-------------|
| **Hook** | 0-30 minutes | Immediate gratification, clear progress |
| **Habit** | 1-7 days | Regular check-ins, meaningful daily progression |
| **Hobby** | Weeks-Months | Deep systems, long-term goals |

**Sources**: [Machinations.io - How to Design Idle Games](https://machinations.io/articles/idle-games-and-how-to-design-them)

---

## 5. Preventing Mid-Game Stagnation

### Common Causes

1. **Nothing to buy**: Player has currency but no appealing purchases
2. **Savings trap**: Next upgrade is too expensive, creating a grind
3. **Content wall**: All accessible content cleared
4. **Complexity explosion**: Too many systems unlock at once
5. **Resource misalignment**: Wrong resources for desired upgrades

### The Factorio Lesson

> "The 'enjoyment bottleneck' occurs when blue/black/purple/gold science packs all come at once, taking around 20 hours compared to the quick 30-minute setups earlier."

**Key insight**: When multiple complex systems unlock simultaneously, players feel overwhelmed and progress stalls.

**Sources**: [Factorio Forums - Early-Midgame Bottleneck](https://forums.factorio.com/viewtopic.php?t=51419)

### Solution Strategies

**1. Tiered Unlock Pacing**
> "Well-designed mining games do a good job slowly tiering up and encouraging you to explore different branches of the skill tree."

**2. Currency Sinks with Time Limits**
- Limited-time shops
- Event-specific upgrades
- Consumables that create urgency

**3. Prestige/Reset Mechanics**
> "Prestige when your next milestone would take longer than restarting and reaching your current point with new bonuses - typically when progress slows to 10-20% of your peak speed."

**4. Abundance/Scarcity Cycles**
> "Periods of resource abundance encourage players to feel rewarded, while scarcity prompts them to plan their spending."
>
> Example from Genshin Impact: Event rewards create brief abundance, followed by scarcity that encourages resource farming.

**Sources**: [Alts.co - Fundamentals of Game Economy Design](https://alts.co/the-fundamentals-of-game-economy-design-from-basics-to-advanced-strategies/)

---

## 6. Meta-Progression Design

### Two Approaches

**Power-Based (Hades model)**:
> "Players spend meta-currency between runs to upgrade abilities and strengthen themselves for their next run. While this does make the game easier over time, players have to frequently take risks to acquire this meta-currency."

**Content Unlocks (Enter the Gungeon model)**:
> "Unlike many rogue-lites, Enter The Gungeon never directly increases player power. Instead, players unlock new items and guns to discover in their next run."

### The Backlash Risk

Some players reject heavy meta-progression:
> "I've really grown to dislike permanent stat upgrades in roguelites to the point of them killing my interest in games."

**The complaint**: Games "balanced so you need to do 500 runs to get 500 1% health increases before you have a chance at beating it."

### Early Meta-Progression as Tutorial

> "Quick early game meta progression can work well as a tutorial mechanic given that it's relatively quickly unlocked."

Benefits:
- Eases players into mechanics
- Forces early runs to end, giving practice
- Creates investment before harder content

**Risk**: When meta progression is negligible until "a good 20 runs under your belt," players may only have "another 3ish hours of playtime before" losing interest.

**Sources**: [Hamatti - Meta Progression with Gradual Tutorial](https://notes.hamatti.org/gaming/video-games/meta-progression-with-gradual-tutorial-in-roguelike-games), [GameRant - Roguelite Games with Best Progression Systems](https://gamerant.com/roguelite-games-with-best-progression-systems/)

---

## 7. Proven Anti-Stagnation Techniques

### Multi-Currency Systems

> "Unlike Cookie Clicker, games with multiple currencies can create opportunities for playstyle differentiation."

**Differentiation by engagement frequency**:
- Short-clock items for frequent players (15-min check-ins)
- Long-clock items for casual players (daily check-ins)

### Dynamic Price Adjustment

> "Gardenscapes cut inflation by 18% by tweaking prices based on player behavior."

Techniques:
- Lower prices for players approaching churn
- Introduce sales on stagnation triggers
- Adjust based on player economy state

### Meaningful Small Purchases

Even when saving for big upgrades, players should have:
1. **Consumables** that provide immediate benefit
2. **Cosmetics** for expression (if applicable)
3. **Side-grades** that don't require primary currency
4. **Time-skips** for impatient players

### Phased Implementation

> "Introduce changes gradually. Using 7-day resource buffers during updates has been shown to boost retention by 30%."

Results from proper implementation:
- 40% drop in resource hoarding
- 62% reduction in material inflation

---

## 8. GoDig Implementation Recommendations

### Upgrade Timing Targets

| Upgrade Tier | Target Time to Afford | Playtime Context |
|--------------|----------------------|------------------|
| First upgrade | 60-90 seconds | FTUE completion |
| Tier 2 | 3-5 minutes | First session |
| Tier 3-4 | 10-15 minutes | Session 1-2 |
| Mid-game tiers | 1-3 sessions | Week 1 |
| Late-game | Multiple sessions | Ongoing |

### Reward Schedule Implementation

**Variable Ratio (Core Loop)**:
- Ore discovery: random per block
- Gem bonuses: rare surprise
- Depth treasures: semi-random placement

**Fixed Ratio (Milestones)**:
- Every 10m depth: small celebration
- Every 50m depth: resource cache
- Every 100m depth: layer transition

**Fixed Interval (Daily)**:
- Daily login bonus
- 8-hour offline accumulation cap

### Currency Sink Checklist

Essential sinks to prevent hoarding:
- [ ] Tool upgrades (primary sink)
- [ ] Inventory expansion
- [ ] Consumables (ladders, ropes)
- [ ] Building unlocks (surface)
- [ ] Prestige preparation (late-game)

### Anti-Stagnation Features

1. **Always-available purchases**: Consumables at any price point
2. **Goal visualization**: Show next affordable upgrade
3. **Alternative progress**: Multiple upgrade paths
4. **Surprise income**: Random bonuses when savings build up
5. **Milestone bonuses**: Reward approaching big purchases

### Warning Signs to Monitor

| Metric | Threshold | Action |
|--------|-----------|--------|
| Stockpile growth | >12%/week | Add sinks |
| Time between upgrades | >20 minutes (early) | Lower prices |
| Session length drop | >15% | Check pacing |
| Churn at depth X | Spike | Review that layer's progression |

---

## 9. The Ethical Framework

### Hopson's Test

For every reward mechanic, ask:
> "Will the player have more fun by fulfilling this contingency than they would otherwise?"

### Good Practices

- Rewards enhance enjoyment, not manufacture compulsion
- Players feel in control of their progression
- No surprise paywalls after investment
- Clear communication of what rewards require

### Avoiding Dark Patterns

- Don't use variable rewards on monetization
- Don't create artificial scarcity to frustrate
- Don't punish players for not engaging
- Don't hide progression behind random chance without alternatives

---

## Key Takeaways for GoDig

1. **5-30 second micro-rewards**: Players should find something rewarding constantly during active play
2. **60-90 second first upgrade**: Hook players before the 2-minute mark
3. **Variable ratio for discovery**: Ore placement creates natural uncertainty
4. **Fixed ratio for milestones**: Predictable depth rewards feel earned
5. **3:1 earn-to-spend ratio**: Players should be spending regularly
6. **Always-affordable purchases**: Consumables prevent "nothing to buy"
7. **12% weekly stockpile cap**: Monitor and adjust if exceeded
8. **Abundance/scarcity cycles**: Events create spending windows
9. **Early meta-progression**: First few upgrades should unlock quickly
10. **Multiple currency sinks**: Tools, inventory, consumables, buildings

---

## Sources

### Game Economy Design
- [Adrian Crook - 5 Common Mobile Game Economy Problems Solved](https://adriancrook.com/5-common-mobile-game-economy-problems-solved/)
- [Alts.co - Fundamentals of Game Economy Design](https://alts.co/the-fundamentals-of-game-economy-design-from-basics-to-advanced-strategies/)
- [Udonis - How to Create a Balanced Mobile Game Economy](https://www.blog.udonis.co/mobile-marketing/mobile-games/balanced-mobile-game-economy)
- [Machinations.io - Idle Games and How to Design Them](https://machinations.io/articles/idle-games-and-how-to-design-them)

### Reward Psychology
- [Gamedeveloper - Behavioral Game Design (John Hopson)](https://www.gamedeveloper.com/design/behavioral-game-design)
- [Gamedeveloper - 10 Years of Behavioral Game Design](https://www.gamedeveloper.com/design/10-years-of-behavioral-game-design-with-bungie-s-research-boss)
- [Gamedeveloper - Reward Schedules and When to Use Them](https://www.gamedeveloper.com/business/reward-schedules-and-when-to-use-them)
- [Journal of Computer-Mediated Communication - Dopamine Loops and Player Retention](https://jcoma.com/index.php/JCM/article/download/352/192)

### Idle Game Design
- [Eric Guan - Idle Game Design Principles](https://ericguan.substack.com/p/idle-game-design-principles)
- [Gamedeveloper - The Math of Idle Games](https://www.gamedeveloper.com/design/the-math-of-idle-games-part-i)
- [GameAnalytics - How to Make an Idle Game](https://www.gameanalytics.com/blog/how-to-make-an-idle-game-adjust)

### Meta Progression
- [Hamatti - Meta Progression with Gradual Tutorial](https://notes.hamatti.org/gaming/video-games/meta-progression-with-gradual-tutorial-in-roguelike-games)
- [GameRant - Roguelite Games with Best Progression Systems](https://gamerant.com/roguelite-games-with-best-progression-systems/)

### Neuroscience
- [PMC - Video Game Training and the Reward System](https://pmc.ncbi.nlm.nih.gov/articles/PMC4318496/)
