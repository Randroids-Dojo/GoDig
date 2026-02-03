# Passive Income Systems in Idle Games

## Overview

Research into how successful idle games balance passive income with active play. Understanding when to unlock automation, how to prevent passive from making active pointless, and how to communicate offline earnings effectively.

## Core Design Principles

### The Idle Game Loop

```
Active Play (manual) → Unlock Automation → Passive Income →
Return to Collect → Reinvest → More Automation → Deeper Play
```

**Key Insight:**
> "While progress is fastest with active reinvestment (similar to continuously compounding interest), you don't lose all that much from pauses."

### Active vs Passive Balance

**The Ratio Matters:**
- 1 week inactive ≈ 2 days active play
- 1 month inactive ≈ 3 days active play
- Offline gains always worse than active, but not punishingly so

**Why This Works:**
- Respects player time when absent
- Rewards engagement without punishing absence
- Creates clear value for active sessions

### The "No Punishment" Rule

> "One of the core mechanics is the lack of punishment for missed time in the game. This allows you to advance without playing regularly."

But with limits...

## Offline Income Limits

### Why Limits Exist

> "To push players to come back, there needs to be a limit for offline income, after which accumulation stops, creating a feeling of lost opportunity."

**All top games limit idle income. This is not punishment—it's a return trigger.**

### Limit Types

| Type | How It Works | Example |
|------|--------------|---------|
| Time Cap | Max hours of accumulation | 8 hours offline max |
| Amount Cap | Max resources stored | 10 cheese max |
| Percentage Cap | Reduced earnings rate | 50% after 4 hours |
| Storage Cap | Building-specific limits | Each mine has capacity |

### Example: The Creamery Pattern

> "The Creamery produces Cheese every 30 minutes, has a maximum stash of 10. If Cheese remains uncollected for 5 hours, the stash fills and production stops."

**Result:** Players encouraged to return every 5 hours to optimize.

## Unlock Timing

### The First 10-30 Minutes

> "Games avoid overwhelming players in the early stages. Heavy monetization is rare in the first 10-30 minutes. Players settle into the loop, build trust, and feel ownership."

**Best Practice:**
1. Start with manual/active gameplay
2. Introduce automation gradually
3. One new variable at a time (currency, automation, prestige)
4. Fast feedback first (earnings per tap)
5. Then introduce passive income

### Progression Sequence

| Phase | Time | Player Experience |
|-------|------|-------------------|
| Manual | 0-10 min | Learn core mechanics |
| First Automation | 10-30 min | Feel value of upgrades |
| Passive Income | 30-60 min | Realize game plays for you |
| Offline Progress | 1+ hour | Return to meaningful rewards |

### Why This Order Matters

> "This creates a satisfying loop where players use earnings to enhance automation and boost production, fueling further progress."

**Players must feel the pain of manual work before they appreciate automation.**

## Idle Miner Tycoon Case Study

### Overview

- 8 continents, 33 mines
- Event mines, seasonal events, weekly updates
- Top idle game with structured automation

### Automation System

**Manager Roles:**
- Oversee miners, elevators, transports
- Each brings unique bonus (speed, cash multiplier, special effects)
- Assign manager → task runs automatically

**Key Mechanic:**
> "Automation transforms persistent tapping into relaxing, ongoing progress."

### Offline Progress

- Collect earnings whether playing or not
- No penalty for missing a day
- Mining tool continues working offline

### Premium Features

- 2x offline income boost
- Higher-tiered managers
- Special automation features
- Balanced: 150-200% improvements, not game-breaking

## Preventing "Pointless Active Play"

### The Problem

If passive income is too strong, active play feels pointless.

### Solutions

**1. Offline Rate Reduction**
- Offline earnings = 50-75% of active rate
- Clear incentive to play actively

**2. Active-Only Features**
- Special events require active participation
- Bonus rewards for being present
- Story/content progression needs engagement

**3. Meaningful Decisions**
- Active play allows strategic choices
- Passive accumulates resources
- Active decides how to spend them

**4. Milestone Gates**
- Major unlocks require active completion
- Passive income accelerates, doesn't replace

### The Ideal Ratio

| Activity | Earnings Rate | Player Feeling |
|----------|---------------|----------------|
| Active Play | 100% | Engaged, rewarded |
| Background (app open) | 80-90% | Relaxed but present |
| Offline (app closed) | 40-60% | Progress continues |
| Offline (capped) | 0% | Time to return |

## Communicating Offline Earnings

### Return Screen Design

**Do:**
- Show total accumulated
- Celebrate the amount
- Offer "double earnings" ad option
- Clear call to action for next steps

**Don't:**
- Overwhelm with numbers
- Make player do math
- Create guilt for time away
- Punish long absences

### Push Notification Strategy

> "The most straightforward way is to tie notifications to rewards, new content, and important events. But don't overdo it—too many will irritate users."

**Notification Triggers:**
- Storage reaching capacity (return trigger)
- Special event starting
- New content available
- Achievement nearly complete

**Timing:**
- Not immediately after closing app
- When offline cap is approaching
- At regular play times (learned from user)

### Avoiding Overwhelm

> "Incremental complexity will occur but rarely overwhelm."

**Principles:**
- One new system at a time
- Clear objectives
- Deep sense of incremental accomplishment
- Complexity grows with player skill

## Premium Monetization Balance

### Standard Premium Boosts

| Feature | Multiplier | Fair Range |
|---------|------------|------------|
| Offline earnings boost | 1.5-2x | Yes |
| Production speed | 2-3x | Yes |
| Storage capacity | 2x | Yes |
| Manager effectiveness | 2-5x | Moderate |

**Key Insight:**
> "Premium options are carefully designed to provide modest, balanced improvements—typically 2-5x—ensuring the game remains fair."

### Revenue Split (Industry Standard)

- In-app advertising: 60-70%
- In-app purchases: 30-40%

## Recommendations for GoDig

### When to Introduce Passive Income

**Not at Game Start**

Players should:
1. Mine manually first (feel the loop)
2. Sell ore, buy first upgrade
3. Reach ~50-100m depth
4. THEN unlock passive income option

**Suggested Unlock:**
- Auto-Miner Station building at 500m depth
- Or after first prestige
- Premium option to unlock earlier (2-3x faster)

### Passive Income Types for Mining Game

**Option 1: Auto-Miner (Building)**
- Generates coins over time
- Rate scales with upgrades
- Cap based on building level

**Option 2: Offline Ore Generation**
- Finds ore while away
- Stored in inventory
- Must sell manually on return

**Option 3: Depth-Based Passive**
- Earn from "claimed" depths
- Deeper = better passive rate
- Encourages going deep first

### Recommended Balance

| Mode | Mining Rate | Ore Quality |
|------|-------------|-------------|
| Active Mining | 100% | 100% |
| Background | 50% | 75% |
| Offline | 25% | 50% |
| Offline (capped) | 0% | 0% |

### Offline Cap Design

**8-Hour Cap Recommended:**
- Fills during sleep/work
- Return morning/evening
- Not punishing for busy days
- Clear when to return

### Return Screen Design

```
Welcome back, Miner!

While you were away:
- Coal found: 45
- Iron found: 12
- Coins earned: 1,250

[Collect] [Double with Ad]

Your Auto-Miner is at capacity!
Upgrade to store more.
```

### Avoid These Mistakes

1. **Passive too early** - Players skip core loop
2. **Passive too strong** - Active play feels pointless
3. **No limits** - No reason to return
4. **Confusing notifications** - Turn off all push
5. **Guilt for absence** - "You missed 500 coins!"

## Sources

- [Adrian Crook - Passive Resource Systems in Idle Games](https://adriancrook.com/passive-resource-systems-in-idle-games/)
- [The Mind Studios - Idle Clicker Game Design](https://games.themindstudios.com/post/idle-clicker-game-design-and-monetization/)
- [Computools - Idle Games Mechanics and Monetization](https://computools.com/idle-games-the-mechanics-and-monetization-of-self-playing-games/)
- [Gamigion - Engagement and Monetization in Idle Games 2025](https://www.gamigion.com/idle/)
- [AppTrove - Idle Games Complete Guide](https://apptrove.com/a-guide-to-idle-games/)
- [Wikipedia - Incremental Games](https://en.wikipedia.org/wiki/Incremental_game)
- [Eric Guan - Idle Game Design Principles](https://ericguan.substack.com/p/idle-game-design-principles)
- [AppLovin - Idle Games Glossary](https://www.applovin.com/glossary/idle-games/)
- [Adjoe - Idle Games Demographics & Monetization](https://adjoe.io/glossary/idle-games-mobile/)
- [App Store - Idle Miner Tycoon](https://apps.apple.com/us/app/idle-miner-tycoon-money-games/id1116645064)

## Related Implementation Tasks

- `Implement passive income upgrade system` - GoDig-implement-passive-income-712159e3
- `implement: Automation building simple optimization (v1.1)` - GoDig-implement-automation-building-496db9d0
- `implement: Welcome-back rewards without streak guilt` - GoDig-implement-welcome-back-35b0e559
