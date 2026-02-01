---
title: "research: Sell flow and shop satisfaction moments"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-01T01:25:25.981512-06:00\\\"\""
closed-at: "2026-02-01T01:27:25.195509-06:00"
close-reason: "Created 3 implementation dots: sell animation, upgrade stat comparison, affordable upgrade indicator"
---

## Questions Answered

### Q1: What makes the 'sell all' moment satisfying?

**Key Patterns from Research:**
1. **Direct visual flow** - Currency visibly travels from source to wallet/counter
2. **Audio punch** - Satisfying sound that matches visual impact
3. **Pause for recognition** - Brawl Stars pauses animation mid-flight to force player to register the reward
4. **Spread vs line** - Coins spreading out > forming a line (more visual drama)

**From Game Economist Consulting analysis:**
- Beatstar: Coins flip and spin with light reflection
- Brawl Stars (winner): Strategic pause, exact amount displayed, spread animation
- Clash Royale: Cascade effect evoking "diving into wealth"

**Psychology:** Currency animations are "classically conditioned reward triggers" - visual/audio cues that anticipate value (Pavlovian)

### Q2: How should coin gain be visualized?

**Best Practices:**
1. Animated counter that rolls up (slot machine effect)
2. Coins/icons that fly from inventory to wallet
3. Sound pitch that increases as amount increases
4. Brief slowmo on large gains (hitstop effect)

**Progress Bar Design (Medium - Maxim Kosyakoff):**
- On completion: color change animation + "success" state
- Sound accompaniment for all state changes
- Clear visual feedback at each milestone

### Q3: Should upgrades have 'before/after' stat comparison?

**YES - Critical UX requirement**

From Game Wisdom research:
- "If the Player equips a new item, don't forget to show how the stats will change before they commit"
- Show green/red arrows for improved/reduced stats
- Make comparison visible AT A GLANCE, not requiring calculation

**Format recommendation:**
```
Damage: 20 → 35 (+75%)  [green arrow up]
Speed:  1.0x → 1.1x     [green arrow up]
```

### Q4: How to make shop visit quick but not boring?

**Principles:**
- "One-tap buy" for frequent purchases (ladders)
- Category tabs, not deep menus
- "Affordable upgrades" highlighted/pulsing
- Auto-sell option for quick cash-in

**Anti-patterns:**
- Too many options at once = choice paralysis
- Hidden stats behind multiple taps
- Forcing scroll to find common items

### Q5: What signals 'ready to upgrade' without nagging?

**Subtle indicators:**
- Green glow/badge on shop icon when affordable upgrade exists
- "NEW" tag on newly unlocked items
- Tooltip on hover: "Copper Pickaxe available!"
- Avoid: modal popups, audio alerts, blocking UI

## Research Sources
- [Game Economist Consulting: Best Currency Animations](https://www.gameeconomistconsulting.com/the-best-currency-animations-of-all-time/)
- [Game UI Database](https://www.gameuidatabase.com/)
- [Gamedeveloper: How to Power up Players with Upgrades](https://www.gamedeveloper.com/design/how-to-power-up-players-with-upgrades)
- [Medium: Progress Bar Design](https://medium.com/@MaxKosyakoff/fill-the-progress-fc0fa99cabac)

## Implementation Dots Created
- implement: Sell animation with coin flow
- implement: Upgrade stat comparison UI
- implement: Affordable upgrade indicator
