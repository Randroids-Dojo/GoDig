---
title: "research: Push-your-luck moments and close-call design"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-01T02:00:00.004980-06:00\\\"\""
closed-at: "2026-02-01T02:01:23.258676-06:00"
close-reason: Completed research on push-your-luck design, created implementation spec for close-call celebration
---

Research how to create satisfying near-miss/close-call moments that make players feel clever for escaping. SteamWorld Dig's 'sweated, then escaped, felt awesome' pattern.

## Research Findings

### The Sweet Spot: Tension-Relief Pacing

From [horror game design research](https://medium.com/@algoryte/the-art-of-fear-level-design-secrets-for-spine-chilling-horror-games-8a3e10059c09):
- "Letting players breathe between scares isn't weakness; it's a setup"
- "Constant fear leads to emotional numbness, but contrast makes every scare sharper"
- Designers alternate tense, high-stress moments with calm periods to prevent exhaustion

**GoDig Application**: The return trip IS the tension phase. Reaching surface IS the relief phase. This natural loop already exists - we need to celebrate the relief moment better.

### Player Agency Creates Satisfaction

From [Number Analytics](https://www.numberanalytics.com/blog/art-of-player-agency-game-design):
- "Players who experienced a sense of agency reported higher levels of enjoyment"
- Players making meaningful choices = engagement and immersion
- The "aha" moment when game supports player's creative solution

**GoDig Application**: Wall-jumping out of tight spots is emergent player agency. When player escapes using clever wall-jumps + last ladder, they feel smart. We should CELEBRATE this.

### Emergent Gameplay Moments

From [Game Design Skills](https://gamedesignskills.com/game-design/emergent-gameplay/):
- "That 'aha' moment when players realize the game supports their choices"
- Mechanics flexible enough for unintended solutions
- Player creates unique solution = accomplishment and satisfaction

**GoDig Application**: The stuck-and-escape pattern is emergent gameplay. Different players will develop different "escape routines" - this is GOOD. Some wall-jump masters, some ladder-conservative, some risk-takers.

### SteamWorld Dig's Design Philosophy

From earlier research:
- Developers knew they hit sweet spot when "testers fell down a hole, sweated a bit, then found a clever way of getting back up again, feeling awesome"
- Wall-jumping transformed "stuck" from binary failure to gray zone
- Players use wits and tools to escape most situations

### Close-Call Detection Mechanics

To celebrate clever escapes, we need to detect them:
1. **Last-ladder escape**: Player places final ladder while deep
2. **Low-HP return**: Player reaches surface with <30% HP
3. **Full-inventory clutch**: Player returns with full inventory + 0-1 ladders remaining
4. **Depth record with escape**: New depth record + successful return

### Implementation Implications

Created implementation spec: `GoDig-implement-close-call-celebration`

## Sources
- [Horror Game Level Design - Medium](https://medium.com/@algoryte/the-art-of-fear-level-design-secrets-for-spine-chilling-horror-games-8a3e10059c09)
- [Player Agency Guide - Number Analytics](https://www.numberanalytics.com/blog/art-of-player-agency-game-design)
- [Emergent Gameplay - Game Design Skills](https://gamedesignskills.com/game-design/emergent-gameplay/)
- [SteamWorld Dig Deep Dive - Gamedeveloper](https://www.gamedeveloper.com/design/game-design-deep-dive-the-digging-mechanic-in-i-steamworld-dig-i-)
