---
title: "research: Mobile idle game patterns"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-01-18T23:42:37.017157-06:00\\\"\""
closed-at: "2026-01-19T00:31:22.513464-06:00"
close-reason: Completed analysis of idle game patterns, session design, retention mechanics. Created 2 implementation tasks for offline income and upgrade goal HUD.
---

Research successful mobile idle/incremental games. Look at: progression hooks, session length design, retention mechanics, satisfying feedback loops. What makes players return? How do they handle AFK progress? Check game design blogs, GDC talks, mobile game postmortems. Apply learnings to GoDig's loop.

## Research Findings

### Key GDC Talks Referenced

- **"Quest for Progress: The Math and Design of Idle Games"** (Anthony Pecorella) - Third in series on self-playing games, covers growth, cost, prestige, and generator balancing
- **"Idle Games: The Mechanics and Monetization of Self-Playing Games"** - Examines why retention is "insanely high" and viable free-to-play revenue

---

### Session Length Statistics (2025)

- Average mobile session: **4-5 minutes** (down from previous years)
- Median session: **5-6 minutes**
- Top 25% performers: **8-9 minutes**
- Idle games specifically: **8 minutes average** (higher than other hyper-casual)
- Idle game stickiness: **18%** vs 10.5% for other hyper-casual
- Top 25% idle games: **42% D1 retention**

---

### The Three Pillars of Idle Game Design

1. **Easy, low barrier core loop** - Tap/click earns reward (currency)
2. **Sophisticated economy** - Reason to spend currency and return to core loop
3. **Achievement counter** - Visible resource generation (per minute/hour)

---

### Retention Mechanics

#### Offline Income
- **Key principle**: Virtual world keeps evolving when not playing
- **Critical design**: Must have a CAP on offline income
  - Creates "lost opportunity" feeling
  - Motivates regular return
  - Common cap: 8-18 hours
- **Return reward**: Players feel accomplishment when returning

#### Natural Session Ending
- Push players out naturally for pacing/retention
- "Strong reasons to come back AND strong reasons to leave"
- Eventually the smart choice requires WAITING
- Players think long-term, not just clicking

#### Psychological Hooks
- Variable rewards
- Milestone goals
- Delayed gratification
- Fear of missing out (FOMO)

---

### Math of Idle Games

#### Growth Formula
- **Exponential growth** works in idle games
- Everything increases exponentially to feel noticeable
- Example: Each level = x1.1 production increase

#### Cost Balancing
- **Exponential costs** slow progression
- Example: Each level = x1.15 cost increase
- Standard growth rate: **1.07 to 1.15**
- This creates satisfying "big purchases" that require planning

#### Prestige Systems
- Reset progress for permanent bonuses
- Creates infinite gameplay loop
- Must feel meaningful without invalidating previous progress

---

### Session Design Best Practices

#### "Easy In, Easy Out"
- Quick game state understanding on return
- Allow leaving at ANY moment
- Life takes priority - don't fight it

#### Bite-Sized Tasks
- Each task completable in few seconds
- Hide long-term goals until short-term complete
- Task list visible on return

#### Things to AVOID
- Requiring memory from previous sessions
- Long intricate story to remember
- Many complex steps per action
- Penalizing player for leaving
- Requiring >1 minute continuous play

#### First 20 Minutes
- Hard to get players past 20 min first session
- Don't front-load with many options/features
- Make those 20 min engaging, frustration-free
- Leave in state conducive to return

---

### Modern Trends (2025+)

- **Hybrid genres**: Idle + RPG, Idle + Merge, Idle + Strategy
- **Active experience integration**: Depth while maintaining engagement
- **Layered economies**: Multiple currencies/resources
- **Multiplayer mechanics**: Social features in idle games

---

## Recommendations for GoDig

### MVP Priority (Must-Have)

1. **Quick game state display** - Show coins, depth, inventory on return immediately
2. **Auto-save on exit** - Never lose progress
3. **Simple core loop visibility** - Clear "dig -> collect -> sell -> upgrade" path
4. **Bite-sized goals** - "Reach depth 10", "Sell 5 coal", "Buy first upgrade"

### V1.0 Priority (Should-Have)

1. **Offline income (limited)**
   - Miners or buildings generate coins while away
   - Cap at 4-8 hours
   - Show "earned while away" on return
   - Example: "Earned 150 coins while away (max reached)"

2. **Milestone notifications**
   - "New ore unlocked!"
   - "Reached depth 50!"
   - Achievement system

3. **Session rewards**
   - Reward longer sessions with bonus
   - "Play for 5 min to unlock bonus chest"

4. **Clear upgrade path**
   - Always show next upgrade goal
   - Make cost visible vs current coins

### V1.1+ Priority (Could-Have)

1. **Prestige system**
   - Reset depth for permanent bonuses
   - "Rebirth" when reaching certain depth
   - Gems/stars carry over as multipliers

2. **Automation buildings**
   - Auto-miners that dig while away
   - Purchasable with late-game currency

3. **Push notifications** (optional)
   - "Your storage is full!"
   - "New daily bonus available"

---

## Economy Balancing Recommendations

### Progression Curve

```
Tool Cost Growth:    x1.15 per tier
Mining Speed Growth: x1.5 per tier
Ore Value Growth:    x2.0 per depth tier
Offline Cap:         4 hours (V1.0), 8 hours (V1.1)
```

### Session Targets

- **Minimum meaningful session**: 2 minutes
- **Average target session**: 5-8 minutes
- **Max required continuous action**: 30 seconds
- **Time between "big" purchases**: 3-5 minutes active

---

## Implementation Tasks

### Existing Tasks Aligned with Research

- `GoDig-mvp-auto-save-d75d685e` - Auto-save system (critical)
- `GoDig-dev-coin-counter-20fcfefb` - Coin counter HUD (quick state)
- `GoDig-dev-depth-milestone-8365ab8c` - Depth notifications
- `GoDig-v1-0-achievement-371826b1` - Achievement system
- `GoDig-v1-1-prestige-d7d2cd31` - Prestige/rebirth system

### New Tasks Created

- `GoDig-implement-offline-income-0e47c928` - Offline income system with cap (includes earned-while-away popup)
- `GoDig-implement-next-upgrade-9b11f5f1` - Next upgrade goal HUD display
- Session reward system - deferred to V1.1 (not critical for MVP/V1.0)
