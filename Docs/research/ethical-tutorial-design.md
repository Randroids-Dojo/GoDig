# Ethical Tutorial Design: Avoiding Dark Patterns in Onboarding

## Overview

This research documents dark patterns in mobile game onboarding that frustrate players and damage trust, along with ethical alternatives that build player confidence. Applied to GoDig's tutorial pacing, monetization introduction timing, progression transparency, and first upgrade experience.

## Sources

- [Level Up or Game Over: Dark Patterns in Mobile Games - arXiv (2024)](https://arxiv.org/html/2412.05039v1)
- [Dark Patterns in Games: Empirical Harmfulness Study - SciTePress (2025)](https://www.scitepress.org/Papers/2025/133658/133658.pdf)
- [Prevent UI/UX Dark Patterns in F2P Mobile Games - PocketGamer](https://www.pocketgamer.biz/feature/78594/prevent-ui-ux-dark-patterns-f2p-mobile-games/)
- [Dark Patterns in Gaming: Lawsuits Target Manipulation - Rain Intelligence](https://www.rainintelligence.com/blog/dark-patterns-in-gaming-lawsuits-target-manipulative-monetization-tactics)
- [From Dark Patterns to Fair Play - Fair Patterns (2025)](https://www.fairpatterns.com/post/from-dark-patterns-to-fair-play-why-gaming-must-change-now)
- [State of Dark Patterns in Game Design - Psychology of Games (2025)](https://www.psychologyofgames.com/2025/03/the-state-of-dark-patterns-in-game-design-teaser/)
- [Role of Ethics in Gaming Design - IEEE Computer](https://www.computer.org/publications/tech-news/trends/role-of-ethics-in-gaming)
- [Ethics in Game Design - SDLC Corp](https://sdlccorp.com/post/ethics-in-game-design-key-considerations-for-developers/)
- [Ethical Games: Evidence-Based Guidance - ACM](https://dl.acm.org/doi/10.1145/3685207)
- [Introduction to Trust in Gaming - Digital Thriving Playbook](https://digitalthrivingplaybook.org/big-idea/introduction-to-trust-in-gaming/)
- [Strategies to Increase Mobile Gaming App Retention - Segwise](https://segwise.ai/blog/boost-mobile-game-retention-strategies)
- [Best Way to Optimize Your Game Tutorial - devtodev](https://devtodev.medium.com/best-way-to-optimize-your-game-tutorial-1d4938efffed)
- [Forced Tutorial - TV Tropes](https://tvtropes.org/pmwiki/pmwiki.php/Main/ForcedTutorial)
- [FOMO as Behavioral Manipulation - Medium](https://medium.com/@milijanakomad/product-design-and-psychology-the-exploitation-of-fear-of-missing-out-fomo-in-video-game-design-5b15a8df6cda)
- [How Video Games Abuse FOMO - Game Wisdom](https://game-wisdom.com/critical/fomo)
- [Predatory Monetization Destroying Player Trust - Wayline](https://www.wayline.io/blog/predatory-monetization-mobile-gaming)
- [FOMO in Mobile Games - GamingOnPhone](https://gamingonphone.com/editorial/do-mobile-games-abuse-the-fear-of-missing-out/)
- [Clash Royale Sticky FTUE - Medium](https://medium.com/@Matthewwspencerr/clash-royale-creating-a-sticky-first-time-user-experience-113e17b18f36)
- [A Game of Dark Patterns: Healthy Mobile Games - ACM CHI](https://dl.acm.org/doi/fullHtml/10.1145/3491101.3519837)

## The State of Dark Patterns (2024-2025)

### Prevalence

A December 2024 study analyzing 1,496 mobile games found dark patterns are not only widespread in games typically seen as problematic but are also present in games perceived as benign. Seven types of dark patterns were identified within three categories: temporal, monetary, and social capital-based.

### Legal Consequences

- **Epic Games (2024)**: $245 million in FTC refunds + $200 million in fines for deceptive purchasing in Fortnite
- **Budge Studios (2024)**: Lawsuit over stealth advertising and parasocial manipulation in children's games
- **Belgium/Finland/Netherlands**: Declared loot boxes as gambling with real-money restrictions

### Player Impact

- **74%** of surveyed gamers feel pressured to make purchases due to misleading mechanics
- **64%** express discomfort with hidden fees or unclear monetization
- **60%** of players leave some games after only one day
- D30 retention for mobile gaming is only **2.4%**

## Dark Patterns to Avoid in GoDig

### 1. Forced Tutorial Length

**The Problem**: When it is impossible to skip the tutorial, the ratio of players who churn versus those who complete it can be alarming. One case study showed a game with 120 tutorial steps where the greatest churn occurred on invisible loading levels.

**Evidence**: Research shows longer onboarding frustrates users and increases churn rate.

**GoDig Approach**:
- Tutorial should be completable in under 60 seconds
- Essential mechanics only: dig, collect, return to surface
- Allow skip after first playthrough
- No invisible loading disguised as tutorial steps

### 2. Fake Difficulty to Sell Solutions

**The Problem**: Games use difficulty that radically spikes so purchases become necessary to progress. The FTC specifically identified "grinding" as a dark pattern in 2022.

**Evidence**: Electronic Arts disclosed designing difficulty adjustment to push loot box purchases.

**GoDig Approach**:
- Difficulty progression is transparent and skill-based
- No artificial walls that require purchases
- Upgrades make gameplay smoother, not mandatory
- First upgrade should feel earned through play, not purchased out of frustration

### 3. Artificial Time Gates

**The Problem**: "Playing by appointment" dark pattern forces daily returns. Time-limited boosters and events create FOMO anxiety.

**Evidence**: Studies link FOMO to activity in the amygdala (threat) and ventral striatum (reward), causing stress oscillation.

**GoDig Approach**:
- No "energy" or "hearts" that gate play
- No daily login requirements for core progression
- Optional bonuses for returning, not penalties for absence
- See existing research: `ethical-return-rewards.md`

### 4. Hidden Complexity (Bait-and-Switch)

**The Problem**: Games appear simple initially but reveal predatory complexity later. Monetization mechanics hidden during FTUE then aggressively introduced.

**Evidence**: 64% of players are uncomfortable with hidden fees or unclear monetization.

**GoDig Approach**:
- What you see in tutorial is what the game is
- Monetization (if any) introduced after trust is established
- No mechanics that only appear after significant investment
- Economy rules are consistent from day 1

### 5. FOMO Pressure

**The Problem**: Time-limited events, exclusive content, and social comparison loops provoke anxiety about missing out. Can push vulnerable players into compulsive behaviors.

**Evidence**: Research shows FOMO leads to player burnout where players disengage entirely. Can cause "potential financial ruin" in gacha-heavy games.

**GoDig Approach**:
- No time-limited exclusive content
- No "limited edition" items that create urgency
- Events extend gameplay, not restrict it
- See existing research: `seasonal-events-no-fomo.md`

### 6. Pay-to-Win Mechanics

**The Problem**: Players who spend money gain unfair competitive advantages, making free play feel futile.

**Evidence**: "Pay to Win" identified as one of the most frustrating dark patterns.

**GoDig Approach**:
- Single-player focus eliminates competitive pressure
- Purchases are cosmetic or time-saving, never power
- Free players can access all content through play
- No leaderboards that reward spending

## Ethical Patterns to Implement

### 1. Respect Player Autonomy

**Principle**: Allow players to have agency over their decisions. Ethical game design ensures choices lead to impactful, non-exploitative outcomes.

**GoDig Implementation**:
- Tutorial teaches, doesn't manipulate
- Players choose when to return to surface
- No artificial urgency or pressure
- Clear consequence preview for decisions

### 2. Transparent Mechanics

**Principle**: Provide transparent information about game mechanics, monetization strategies, and data usage. Avoid misleading players about features.

**GoDig Implementation**:
- Ore values are visible before collection
- Upgrade costs clearly displayed
- No hidden currencies or exchange rates
- Probability shown for any randomized rewards

### 3. Informed Consent

**Principle**: Obtaining informed consent entails providing clear information regarding data collection, privacy, and potential risks.

**GoDig Implementation**:
- Tutorial explains core risk (can lose progress if trapped)
- Monetization explained clearly if/when introduced
- No surprise mechanics or hidden costs

### 4. Player Well-Being Features

**Principle**: Break reminders, optional time limits, and spending summaries demonstrate care for player well-being.

**GoDig Implementation**:
- Session length tracking (optional)
- No guilt mechanics for taking breaks
- Natural stopping points built into loop
- Celebrate completed sessions, not streaks

### 5. Build Trust Through Fairness

**Principle**: When players trust the game, they are more likely to stay. Trust translates into higher retention, loyalty, and organic growth.

**GoDig Implementation**:
- Consistent rules from first session
- No "gotcha" moments or bait-and-switch
- Failures feel fair and teachable
- Upgrades feel proportionally impactful

## Tutorial Design Best Practices

### Learning Through Doing (Supercell Model)

Clash Royale's onboarding principles:
- Strike balance between coaching and exploration
- Intelligently ramped difficulty
- Players never feel hand-held through tutorial
- Learn through self-created experience
- Only two forced coaching moments (both critical mechanics)

**Key Insight**: People learn better in defeat than victory. Early loss forces strategy reconsideration and introduces new concepts.

### Skip Option Design

**Research Finding**: Experienced users should be able to skip tutorials while new players can revisit instructions if needed.

**GoDig Implementation**:
```
First-ever session:
  - Quick interactive tutorial (under 60 seconds)
  - No skip option - ensures everyone knows basics
  - Ends naturally after first ore collected

Returning players (new game):
  - "Skip tutorial?" prompt
  - Returns directly to gameplay

Tutorial revisit:
  - Accessible from settings menu
  - Broken into discrete lessons
  - Can replay specific mechanics
```

### Gradual Mechanic Introduction

**Research Finding**: Introduce mechanics gradually, highlighting only essential features initially, with secondary mechanics introduced progressively.

**GoDig Phase Approach**:

| Session | Mechanics Introduced |
|---------|---------------------|
| 1 | Dig, collect ore, return to surface, sell |
| 2-3 | Upgrade tools, deeper layers |
| 4-5 | Inventory management, ladders |
| 6+ | Advanced features (optional) |

### Reward Tutorial Completion

**Research Finding**: Gamified onboarding helps - reward users for completing tutorials with in-game currency or power-ups.

**GoDig Rewards**:
- First ore is guaranteed within 3 blocks
- First sell gives generous price (teaches value)
- First upgrade is affordable and impactful
- Each tutorial stage gives small bonus

## Monetization Introduction Timing

### The D3 Rule

**Research Finding**: Players need to build trust before encountering monetization. Introducing it too early damages retention.

**GoDig Approach**:
- No monetization visible in first session
- No IAP prompts during FTUE
- Shop unlocks naturally through progression
- First 3 runs are pure gameplay

### Ethical Monetization Framing

When monetization is eventually introduced:

| Do | Don't |
|-----|-------|
| "Support the developer" framing | "You need this to progress" |
| Cosmetic/convenience options | Power advantages |
| One-time purchases | Recurring consumables |
| Clear prices, no fake currency | Gem/coin conversion confusion |
| Optional, never required | Gates or blocks without purchase |

## Measuring Tutorial Success

### Key Metrics

| Metric | Target | Red Flag |
|--------|--------|----------|
| Tutorial completion rate | >80% | <60% |
| D1 retention after tutorial | >40% | <25% |
| Time to first core action | <30 seconds | >2 minutes |
| Tutorial skip rate (returning) | <50% | >80% (may indicate it's too long) |
| Player-reported confusion | <10% | >25% |

### Churn Analysis

Use "Tutorial Steps" funnel to identify:
- Steps with maximum churn
- Invisible loading causing abandonment
- Confusing or frustrating moments
- Points where players feel manipulated

## GoDig FTUE Timeline

Based on ethical design principles:

```
0-10 seconds:   Game loads, player sees character at surface
10-20 seconds:  First tap to dig, immediate feedback
20-30 seconds:  Discover first ore (guaranteed within 3 blocks)
30-45 seconds:  Return to surface naturally
45-60 seconds:  Sell ore, see coin increase
60-90 seconds:  View shop, see upgrade goal
90-120 seconds: Begin second dig (self-directed)
```

### What's NOT in First Session

- No monetization prompts
- No time-limited offers
- No social features or leaderboards
- No complex inventory management
- No danger/death mechanics (first area is safe)

## Trust Building Checklist

Before launching GoDig, verify:

- [ ] Tutorial completable under 60 seconds
- [ ] Skip option for returning players
- [ ] No fake difficulty spikes in first 10 runs
- [ ] Monetization invisible for first 3 runs
- [ ] No time-limited content creating FOMO
- [ ] Clear, transparent upgrade system
- [ ] Natural stopping points (not artificial)
- [ ] Failures teach, don't punish unfairly
- [ ] First upgrade feels earned and impactful
- [ ] No hidden mechanics that appear later

## Key Takeaways

1. **Dark patterns are legally risky** - FTC fines and class actions are increasing
2. **74% of players resent manipulation** - They recognize and remember it
3. **Trust drives retention** - Ethical design creates loyal players
4. **Tutorial length kills retention** - Under 60 seconds for core mechanics
5. **Skip options respect players** - Returning users shouldn't repeat tutorials
6. **Learning by doing beats reading** - Interactive > text-heavy
7. **First upgrade must feel earned** - Not purchased out of frustration
8. **Monetization after trust** - Never in the first 3 sessions
9. **FOMO destroys long-term engagement** - No time-limited pressure
10. **Fairness is a feature** - Consistent, transparent rules from day 1

## Related GoDig Research

- `tutorial-skip-patterns.md` - Skip mechanisms and returning player flows
- `ethical-return-rewards.md` - Welcome-back without guilt mechanics
- `seasonal-events-no-fomo.md` - Events that don't pressure players
- `ftue-critical-path-timing.md` - First session timeline optimization
- `monetization-strategy.md` - Ethical monetization if implemented
