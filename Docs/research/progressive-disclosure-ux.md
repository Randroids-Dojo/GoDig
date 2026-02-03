# Progressive Disclosure UX in Mobile Games

## Overview

Progressive disclosure is the practice of gradually revealing complex features and information as users progress, reducing cognitive load while maintaining depth. This research examines how successful mobile games implement progressive disclosure without frustrating players.

## Core Principles

### Why Progressive Disclosure Works

1. **Cognitive Load Reduction**: The human brain can process only 7 +/- 2 things at once, for up to 30 seconds
2. **Natural Learning Curve**: Once users complete one action (jump), they unlock the next (punch)
3. **Reduced Abandonment**: Overwhelming users with options causes them to become lost, make errors, and abandon
4. **Engagement Over Time**: Revealing features gradually encourages continued exploration

### The Balance Challenge

**Risk of Over-Simplification:**
- Dumbed-down interfaces can give the impression that software lacks depth
- Oversimplification affects usability for advanced users
- Players may think "the game has nothing left to offer" too early

**Solution:**
- Use contextual cues to signal hidden depth
- Provide skip options for advanced users
- Balance usability and discoverability

## Industry Case Studies

### Clash Royale: Arena-Based Unlocks

| Arena | Trophy Threshold | Key Unlocks |
|-------|-----------------|-------------|
| Goblin Stadium (1) | 0 | TV Royale, Shop |
| Barbarian Bowl (3) | 400 | Merge Tactics |
| Spell Valley (4) | 600 | Battle Banners, Emotes |
| Builder's Workshop (5) | 800 | Higher Pass Royale rewards |
| Miner's Mine (15) | 4750 | Pass Royale Evolve |
| Executioner's Kitchen (16) | 5000 | Champion Cards |

**Key Design Decisions:**
- **Trophy Gate**: Players cannot drop below their current arena, encouraging experimentation
- **Level Gates**: Ensure balanced progression
- **Delayed Powerful Cards**: Epic cards unlock at Arena 6 (not Arena 2), Legendary at Arena 11 (not Arena 4)

**Lesson for GoDig:** Gate powerful upgrades behind depth milestones, not just currency.

### Stardew Valley: Seasonal Progression

Stardew Valley uses natural time progression as an unlock mechanism:

**First Year Timeline:**
| Season | Feature Unlocks |
|--------|-----------------|
| Spring | Basic farming, foraging, fishing |
| Summer (Day 3) | Spa and train station (earthquake unlocks) |
| Fall | Secret Woods (requires steel axe), Desert (Vault completion) |
| Winter | Sewer key (60 museum donations), mine focus |
| Year 2+ | Greenhouse, advanced content |

**Key Design Decisions:**
- Community Center bundles guide progression naturally
- Seasonal restrictions force patience (can't rush everything)
- Year 2+ content exists for dedicated players

**Lesson for GoDig:** Use depth milestones as natural unlock gates, like seasons in Stardew.

### Mobile Game Onboarding Pattern

From successful mobile games:
1. Start with minimal action (create profile, basic tutorial)
2. Reveal advanced features after core loop is understood
3. Don't disclose features until data exists to use them (solves "blank slate" problem)

## Retention Data and Feature Discovery

### When Players Leave

| Day | Typical Cause | Solution |
|-----|---------------|----------|
| D1 (27%) | Confusing onboarding | Simpler first session |
| D7 (8%) | Core loop lacks depth | Introduce new mechanics |
| D30 (3%) | Endgame content missing | Late-game systems |

### Content Fatigue Prevention

- **New mechanic every 20-30 minutes** during early game
- **Time-to-content exhaustion should be 14+ days** for top players
- **Fresh content monthly** keeps players returning

### The "Nothing Left" Problem

Players perceive "nothing left to do" when:
1. All visible goals are complete
2. No hints of hidden content exist
3. Progression feels stagnant
4. No upcoming content is communicated

## GoDig Progressive Disclosure Design

### Feature Unlock Timeline

#### First Session (0-5 minutes)
| When | Unlock | Why |
|------|--------|-----|
| Start | Basic mining, movement | Core controls |
| First ore found | Inventory UI highlights | Introduce collection |
| Inventory half-full | "Return to sell" prompt | Teach loop |
| First sell | Coin display, shop preview | Show economy |

#### First Hour (5-60 minutes)
| Trigger | Unlock | Why |
|---------|--------|-----|
| 50m depth | Depth indicator prominent | Track progress |
| First upgrade affordable | Upgrade notification | Show progression |
| First tool upgrade | New tool feels explanation | Justify cost |
| 100m depth | Ladder shop unlocks | Enable return strategies |

#### First Day (~2-3 hours)
| Trigger | Unlock | Why |
|---------|--------|-----|
| 200m depth | Stone Layer notification | Layer identity |
| First rare ore | Rarity system explanation | Depth = better rewards |
| 500m depth | Deep Stone Layer, hazard hints | Increase challenge |
| First death (if applicable) | Respawn system explanation | Teach consequences |

#### First Week (5-10 hours)
| Trigger | Unlock | Why |
|---------|--------|-----|
| 1000m depth | Crystal Caves unlock | Visual reward for progress |
| All Tier 1-3 tools purchased | Tool comparison UI | Advanced decision-making |
| 10 surface returns | Statistics screen | Reward for engagement |
| Achievement threshold | Achievement UI prominent | New goal system |

### What to Hide Initially

| Feature | Hide Until | Reason |
|---------|-----------|--------|
| Advanced statistics | 5+ runs | Data needs context |
| Full upgrade tree | First upgrade purchased | Avoid overwhelm |
| Achievement list | First achievement earned | Show by example |
| Depth records | First 100m reached | Needs baseline |
| Endgame content hints | 500m+ depth | Preserve mystery |

### How to Signal Hidden Depth

**Good Signals:**
- "???" on locked upgrade slots (curiosity)
- "More at 500m depth" (goal setting)
- Achievement progress bar (partial completion visible)
- NPC hints about "deeper treasures"

**Bad Signals:**
- Fully visible but grayed-out complex UI
- Long lists of locked content
- "Pay to unlock" on everything

## Notification and Announcement Patterns

### Feature Unlock Notifications

**Effective Pattern:**
```
[New Feature!]
Icon + Brief description
"Ladders now available in shop"
[Got it] button
```

**Guidelines:**
- Maximum 1 feature notification per session
- Allow dismissal without action
- Don't stack notifications
- Show in pause/surface state, not during mining

### Contextual Discovery

Instead of notifications, use context:
- Highlight new shop items with "NEW" badge
- Animate new UI elements briefly
- Use subtle glow/pulse on undiscovered features
- Trigger tutorial tips on first interaction with new feature

## Implementation Checklist

### MVP (v1.0)
- [ ] Core loop only for first 5 minutes
- [ ] Depth-gated shop unlocks (ladders at 50m, etc.)
- [ ] "NEW" badges on newly available items
- [ ] First upgrade prompt after affordable

### v1.1+
- [ ] Full progression unlock timeline
- [ ] Achievement system with partial visibility
- [ ] Statistics screen (unlocks after 5+ runs)
- [ ] Hint system for hidden features
- [ ] Advanced tool comparison UI

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Everything visible but locked | Overwhelming, feels paywall | Progressive UI revelation |
| Tutorial dumps all info | Cognitive overload | One mechanic at a time |
| No skip option | Frustrates experienced users | Always allow skip |
| Features without context | Confusion about value | Unlock when relevant |
| Dead-end progression | "Game has nothing left" | Always hint at more |

## Key Takeaways for GoDig

1. **Depth-Based Unlocks**: Use depth milestones as natural gates (50m, 100m, 500m, 1000m)
2. **Show by Doing**: Unlock features when player first needs them, not before
3. **Signal Hidden Depth**: Use "???" and hints to suggest more exists
4. **New Mechanic Pacing**: One new mechanic every 20-30 minutes early game
5. **Skip Options**: Experienced players should be able to accelerate onboarding
6. **No Dead Ends**: Always have a "next goal" visible, even if vague

## Sources

- [Interaction Design Foundation: Progressive Disclosure](https://www.interaction-design.org/literature/topics/progressive-disclosure)
- [UX Planet: Progressive Disclosure for Mobile Apps](https://uxplanet.org/design-patterns-progressive-disclosure-for-mobile-apps-f41001a293ba)
- [Pendo: Onboarding and Progressive Disclosure](https://www.pendo.io/pendo-blog/onboarding-progressive-disclosure/)
- [LogRocket: Progressive Disclosure Types and Use Cases](https://blog.logrocket.com/ux-design/progressive-disclosure-ux-types-use-cases/)
- [Clash Royale Arenas Guide - SkyCoach](https://skycoach.gg/blog/clash-royale/articles/arenas-guide)
- [Clash Royale Wiki: Arenas](https://clashroyale.fandom.com/wiki/Arenas)
- [Stardew Valley First Year Guide - Game Rant](https://gamerant.com/stardew-valley-first-year-must-dos/)
- [Solsten: D1, D7, D30 Retention in Gaming](https://solsten.io/blog/d1-d7-d30-retention-in-gaming)
- [Tenjin: Retention for Mobile Games 101](https://tenjin.com/blog/retention-for-mobile-games-101/)
- [Feature Upvote: Game Retention Strategies](https://featureupvote.com/blog/game-retention/)
