# First 5 Minutes Critical Path: FTUE Timing Validation

> Research on specific timing and milestone targets for mobile game first-time user experience, the "60 second hook" principle, competitor FTUE analysis, and first purchase timing.
> Last updated: 2026-02-02 (Session 26)

## Executive Summary

The FTUE (First Time User Experience) encompasses the first 60 seconds to 15 minutes of gameplay and is the single most important determinant of player retention. Key finding: players must experience a "first win" within **60 seconds** and understand the core value proposition within the **first 5 minutes**. Games with well-designed FTUEs see D1 retention rates of 28-40%, while poorly designed ones lose 78% of players within 30 days. This research validates timing targets for GoDig's critical path.

---

## 1. The FTUE Time Windows

### Critical Time Points

| Window | Duration | Player State | Design Goal |
|--------|----------|--------------|-------------|
| **First impression** | 0-3 seconds | Scanning visual hierarchy | Make a "stay" decision |
| **First action** | 3-30 seconds | Learning basic input | Perform core mechanic |
| **First win** | 30-60 seconds | Seeking validation | Experience success |
| **Core loop complete** | 1-5 minutes | Understanding value | Complete one full cycle |
| **FTUE boundary** | 5-15 minutes | Ready for depth | Transition to real gameplay |

> "When a user lands on your product after signup, their brain asks exactly one question: 'Should I stay?' In those three seconds—the time it takes to parse visual hierarchy—they've already made a soft decision."

**Sources**: [Mobile Game Doctor - FTUE & Onboarding](https://mobilegamedoctor.com/2025/05/30/ftue-onboarding-whats-in-a-name/), [Adrian Crook - Best Practices for Mobile Game Onboarding](https://adriancrook.com/best-practices-for-mobile-game-onboarding/)

### The 60-Second Hook

> "The difference between a 5% activation rate and a 20% activation rate isn't better onboarding design. It's the presence of a clear 60-second win: a moment where the user touches something tangible and thinks, 'Oh, I get it.'"

**Time-to-Fun (TTF) benchmarks**:
- Top mobile games: under 60 seconds
- Slack: under 30 seconds
- Target for GoDig: under 60 seconds to first ore discovery

**Sources**: [DEV Community - 60-Second Onboarding](https://dev.to/paywallpro/how-tools-use-60-second-onboarding-to-boost-conversion-18kc)

---

## 2. Retention Impact

### Industry Benchmarks

| Metric | Average | Top Tier |
|--------|---------|----------|
| D1 retention | 24-28% | 35-40% |
| Players who continue for "good progression" | 67.1% | 75%+ |
| Players lost to poor FTUE (within 30 days) | 78% | <50% |

> "The average app loses almost 80% of its users in the first three days after installation. This is the most critical time to influence mobile game retention."

### Why Players Leave During FTUE

1. **Confusion**: Too many mechanics introduced at once
2. **Friction**: Forced account creation, permissions, or ads
3. **Boredom**: No immediate payoff
4. **Frustration**: Unclear goals or controls
5. **Overwhelm**: Information overload

**Sources**: [Udonis - First-Time User Experience in Mobile Games](https://www.blog.udonis.co/mobile-marketing/mobile-games/first-time-user-experience), [PlaytestCloud - Your Game's First Hour](https://start.playtestcloud.com/blog/your-games-first-hour)

---

## 3. The 60-Second Framework

### Three Components of Effective 60-Second Onboarding

**1. One Clear Action**
> "Each case compresses to one interaction: one AI query, one quiz answer, one lesson completed. Mixing multiple features dilutes focus and triggers decision paralysis."

**2. Immediate Feedback**
The action must produce visible, satisfying results within milliseconds.

**3. Ownership at 60 Seconds**
> "End the 60 seconds with something users can claim. Duolingo gives streaks. Figma gives designs. Without ownership, onboarding is passive. With it, users have invested 60 seconds and earned a reason to stay."

### GoDig 60-Second Target

| Second | Event | Player Experience |
|--------|-------|-------------------|
| 0-3 | Game loads | See character, mine entrance |
| 3-10 | First movement prompt | Learn to move |
| 10-20 | First dig prompt | Break first block |
| 20-40 | Continue digging | Build rhythm |
| 40-55 | First ore discovered | **Celebration moment** |
| 55-60 | Ore collected | Ownership established |

---

## 4. Candy Crush Tutorial Analysis

### What Makes It Work

Candy Crush has been studied extensively as one of the most successful FTUEs in mobile gaming:

**1. Guide Character (Mr. Toffee)**
> "The best place to add flair and design to your FTUE is in the guide character. Candy Crush uses 'Mr Toffee' to emphasize the overall theme of the game."

**2. Progressive Complexity**
> "The initial levels are intentionally designed to boost players' confidence through straightforward, almost ridiculously easy challenges that gradually introduce the game's mechanics."

Players learn:
- Level 1: Basic matching
- Later levels: Striped candy, wrapped candy, color bombs
- Each mechanic builds on previous knowledge

**3. Sensory Feedback Loop**
> "This design leverages bright colors, enticing sounds, and tactile feedback like phone vibrations to create a rewarding experience that players want to revisit."

**4. Skip Button**
> "Candy Crush provides a skip button on the tutorial—an overlooked feature that is used by more people than you would think. Not all of your players need guidance."

### Lessons for GoDig

| Candy Crush | GoDig Equivalent |
|-------------|------------------|
| Mr. Toffee guide hand | Contextual arrow prompts |
| Easy first matches | Shallow first ore |
| Match celebration | Ore discovery sparkle |
| Color bomb unlock | Pickaxe upgrade |
| Skip button | Skip tutorial option |

**Sources**: [UX Design - Does Candy Crush Have Good UX](https://uxdesign.cc/does-candy-crush-have-a-good-ux-3c1a865d24e), [TNW - Candy Crush's Brilliant UX](https://thenextweb.com/syndication/2020/03/28/what-designers-can-learn-from-candy-crushs-brilliant-ux/)

---

## 5. SteamWorld Dig Design Insights

### Original Tutorial Problem

> "The tutorial became quite long, almost four times as long as the one they finally shipped. They couldn't space out the tutorial since digging is the main thing you do in the game, so they had to rely on tedious repetition—which wasn't very appreciated by testers."

### Core Tension Design

> "From the very beginning, they had the idea of keeping the player in a constant risk of getting stuck as the main source of tension in the game."

However, they found:
> "Their intent was to teach the player the importance of planning ahead and thinking of the tunnel digging as a spatial puzzle. However, for anyone who has tried the final version, planning ahead isn't really a requirement."

### Progression Flow

1. Dig downward
2. Find loot
3. Continue until told to sell
4. Return to surface
5. Sell to Dorothy
6. Level up based on loot sold
7. Unlock Sharp Pickaxe
8. Return to mining

### First Half Success

> "The first half of SteamWorld Dig is considered fun, as players hunt for increasingly rare minerals to become more efficient miners. Striking precious veins, connecting cave systems, and filling out the map makes players want to keep diving back in."

**Sources**: [Gamedeveloper - Game Design Deep Dive: SteamWorld Dig](https://www.gamedeveloper.com/design/game-design-deep-dive-the-digging-mechanic-in-i-steamworld-dig-i-)

---

## 6. Motherload First Upgrade Analysis

### Early Game Constraint

> "A fuel tank (e.g., Huge Tank) is usually the first upgrade you should buy, since the tank you start with will only last about 30 seconds of digging."

This creates:
- **Immediate tension**: Player knows they're on a timer
- **Clear first goal**: Upgrade fuel tank
- **Teaching moment**: Return-to-surface loop

### Progression Path

1. Start with limited fuel (30 seconds of digging)
2. Surface frequently
3. Sell resources
4. Buy fuel tank upgrade
5. Then buy drill upgrade
6. Repeat with deeper dives

### Lesson for GoDig

Motherload uses **resource constraint** (fuel) to enforce the return loop. GoDig uses **inventory pressure** instead, which is less punishing but still creates return motivation.

**Sources**: [Motherload Wiki](https://motherload.fandom.com/wiki/Motherload)

---

## 7. First Upgrade Timing

### Industry Data on First Purchase

> "25% of first-time purchases happen by Day 2, and nearly 77% of all IAPs occur within the first two weeks."

For non-monetization upgrades (in-game currency):

| Timing | Impact |
|--------|--------|
| First upgrade < 2 minutes | High engagement, may feel too easy |
| First upgrade 2-5 minutes | Optimal for most games |
| First upgrade > 10 minutes | Risk of churn before payoff |

### Design Principle

> "Early in the game, keep it simple. One action gives one reward, which buys one upgrade. This teaches players the ropes without throwing them in the deep end too soon."

### Progression Curve

> "Early wins are easy and engaging, but as the game progresses, rewards should get tougher to earn. This may mean ten actions for one reward, effectively making each action worth just 0.1 of a reward."

**Sources**: [ASO World - Golden Timing of In-App Purchases](https://asoworld.com/blog/mobile-game-market-insight-the-golden-timing-of-in-app-purchases/), [Udonis - Progression Systems](https://www.blog.udonis.co/mobile-marketing/mobile-games/progression-systems)

---

## 8. FTUE Best Practices Checklist

### Do

- [ ] Get players into gameplay within 3 seconds
- [ ] Deliver first win within 60 seconds
- [ ] Use kinesthetic learning (learn by doing)
- [ ] Weave tutorial into gameplay
- [ ] Start with extremely low difficulty
- [ ] Provide rewards and freebies during FTUE
- [ ] Show future value/potential within 2 minutes
- [ ] Allow tutorial skip for returning players
- [ ] Minimize cognitive load (one action at a time)

### Don't

- [ ] Force account creation before gameplay
- [ ] Show ads during FTUE
- [ ] Introduce multiple mechanics simultaneously
- [ ] Use text-heavy instructions
- [ ] Create rigid "on-rails" tutorials
- [ ] Over-tutorialize simple mechanics
- [ ] Block progress with complex decisions
- [ ] Monetize before first loop completion

**Sources**: [Unity - 10 FTUE Tips for Games](https://unity.com/how-to/10-first-time-user-experience-tips-games), [GameAnalytics - Tips for Great FTUE in F2P Games](https://www.gameanalytics.com/blog/tips-for-a-great-first-time-user-experience-ftue-in-f2p-games)

---

## 9. GoDig FTUE Critical Path

### Validated Timing Targets

Based on research, here are the validated targets for GoDig:

| Milestone | Target Time | Rationale |
|-----------|-------------|-----------|
| First movement | 3-5 seconds | Immediate input response |
| First block break | 10-15 seconds | Core mechanic |
| First ore discovery | 30-45 seconds | First win moment |
| First ore collected | 45-60 seconds | Ownership established |
| Return to surface | 90-120 seconds | Complete first loop |
| First sell | 120-150 seconds | Economy understanding |
| First upgrade affordable | 150-180 seconds | Progression hook |
| First upgrade purchased | 180-240 seconds | Investment made |

### Critical Path Flow

```
0s: Game start
↓
5s: Player moves (joystick tutorial)
↓
15s: First dig (tap/button tutorial)
↓
30-45s: FIRST ORE DISCOVERY ← Key hook moment
↓
60s: Continue mining, find 2-3 ores
↓
90s: Inventory notification ("Return to sell!")
↓
120s: Surface return, shop interaction
↓
150s: Sell ores, see coin gain
↓
180s: Upgrade available indicator
↓
240s: FIRST UPGRADE PURCHASED ← Investment hook
```

### Guaranteed First Ore

To ensure the 30-45 second first ore discovery:
- Place ore within 3 blocks of starting position
- Use visual hint (sparkle, color) to guide
- Celebrate discovery with particles + sound

### Session 1 Completion

By end of first 5-minute session, player should have:
- Completed 2-3 full dig-sell loops
- Purchased first upgrade
- Reached 10-20m depth
- Discovered 2+ ore types
- Understood the core loop

---

## 10. Measuring FTUE Success

### Key Metrics

| Metric | Target | Warning |
|--------|--------|---------|
| Time to first action | <5 seconds | >10 seconds |
| Time to first ore | <45 seconds | >90 seconds |
| Time to first sell | <3 minutes | >5 minutes |
| Time to first upgrade | <4 minutes | >7 minutes |
| FTUE completion rate | >70% | <50% |
| D1 retention | >30% | <20% |

### Red Flags

- Players not discovering ore within 60 seconds
- High drop-off before first sell
- Confusion about return-to-surface mechanic
- Long hesitation at shop UI
- Churn spike at specific depth/event

### Playtest Protocol

1. **Pre-test**: No instructions given
2. **0-60s**: Observe without intervention
3. **60s-5min**: Note confusion points
4. **Post-test**: Ask "What was confusing?"
5. **Iterate**: Fix friction points

---

## Key Takeaways for GoDig

1. **60-second hook is real**: First ore MUST be discovered within 45 seconds
2. **One action at a time**: Don't teach movement, digging, and inventory simultaneously
3. **First upgrade by 3-4 minutes**: This is the investment hook
4. **Skip tutorial option**: Respect returning/experienced players
5. **Celebrate early wins**: Ore discovery needs sparkle + sound + ownership
6. **Weave tutorial into gameplay**: No separate tutorial mode
7. **No ads during FTUE**: First 5 minutes must be pure experience
8. **Visual over text**: Arrow prompts, not instruction text
9. **Guarantee success**: Place first ore within 3 blocks
10. **Complete loop by 2-3 minutes**: Dig → Find → Return → Sell → Upgrade

---

## Sources

### FTUE Design
- [Gamedeveloper - Best Practices for Successful FTUE](https://www.gamedeveloper.com/design/best-practices-for-a-successful-ftue-first-time-user-experience-)
- [Udonis - First-Time User Experience in Mobile Games](https://www.blog.udonis.co/mobile-marketing/mobile-games/first-time-user-experience)
- [Unity - 10 FTUE Tips for Games](https://unity.com/how-to/10-first-time-user-experience-tips-games)
- [GameAnalytics - Tips for Great FTUE in F2P Games](https://www.gameanalytics.com/blog/tips-for-a-great-first-time-user-experience-ftue-in-f2p-games)

### Case Studies
- [Gamedeveloper - Game Design Deep Dive: SteamWorld Dig](https://www.gamedeveloper.com/design/game-design-deep-dive-the-digging-mechanic-in-i-steamworld-dig-i-)
- [UX Design - Does Candy Crush Have Good UX](https://uxdesign.cc/does-candy-crush-have-a-good-ux-3c1a865d24e)
- [TNW - Candy Crush's Brilliant UX](https://thenextweb.com/syndication/2020/03/28/what-designers-can-learn-from-candy-crushs-brilliant-ux/)

### Onboarding
- [Mobile Game Doctor - FTUE & Onboarding](https://mobilegamedoctor.com/2025/05/30/ftue-onboarding-whats-in-a-name/)
- [Adrian Crook - Best Practices for Mobile Game Onboarding](https://adriancrook.com/best-practices-for-mobile-game-onboarding/)
- [Apple Developer - Onboarding for Games](https://developer.apple.com/app-store/onboarding-for-games/)

### Progression
- [Udonis - Progression Systems in Mobile Games](https://www.blog.udonis.co/mobile-marketing/mobile-games/progression-systems)
- [ASO World - Golden Timing of In-App Purchases](https://asoworld.com/blog/mobile-game-market-insight-the-golden-timing-of-in-app-purchases/)
- [PlaytestCloud - Your Game's First Hour](https://start.playtestcloud.com/blog/your-games-first-hour)
