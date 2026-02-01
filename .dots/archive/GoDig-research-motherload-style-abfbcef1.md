---
title: "research: Motherload-style fuel/air mechanic analysis"
status: closed
priority: 3
issue-type: task
created-at: "\"\\\"2026-02-01T01:33:27.814857-06:00\\\"\""
closed-at: "2026-02-01T01:34:29.818209-06:00"
close-reason: "Completed: Skip fuel mechanic. Ladder economy + inventory provides sufficient tension without mobile-unfriendly frustration."
---

## Question
Should GoDig add a fuel/air mechanic like Motherload? This creates natural tension but adds complexity.

## Motherload Pattern
- Fuel depletes constantly while underground
- Forces return trips even with empty inventory
- Creates constant background tension
- Risk: running out = death/stuck

## Current GoDig Tension Mechanics
- Inventory fills (forces return)
- Ladders deplete (escape resource)
- Depth = harder blocks (time cost)
- Fall damage (minor pressure)

## Questions to Answer
1. Does GoDig have enough tension without fuel?
2. Would fuel add fun or frustration?
3. What's the cognitive load impact?
4. Mobile sessions are short - is fuel mechanic too punishing?

## Research Tasks
- [x] Find player feedback on fuel in similar games
- [x] Analyze Motherload forums for fuel complaints
- [x] Check if other mobile mining games use fuel
- [x] Survey idle game patterns (usually no fuel)

## Research Findings

### Motherload Original - Community Feedback

From [Steam Community](https://steamcommunity.com/app/269110/discussions/0/558752449768338362/):

**Pro-fuel players** said:
- "True fear when I was low on fuel flying up to the surface"
- "Getting aggravated because I didn't keep track of fuel and blew up half way to the surface" - this was memorable

**Anti-fuel frustrations**:
- "Constant bug of accidentally getting stuck on un-dug terrain... badly timed getting stuck may get you dead"
- "Have to restart the whole game" on death

### Super Motherload's Solution

The sequel REMOVED death-on-empty-fuel. When fuel empties:
- Move slower
- Can't dig
- Just reach surface to refuel

**Mixed reception**:
- Some players: "I don't feel fear any more"
- Others: Appreciated the more casual experience
- Only 0.7% of players completed hardcore (permadeath) mode

### Mobile Mining Games

From [Pocket Gamer](https://www.pocketgamer.com/best-games/mining-games/) and [Mr. Mine Blog](https://blog.mrmine.com/top-idle-mining-clicker-games-to-play-in-2025/):

Top mobile mining games (Idle Miner Tycoon, Mr. Mine, Pick Crafter) do NOT use fuel mechanics:
- "Easy-to-play experience with intuitive interface"
- "No need for constant tapping"
- "Play anywhere, anytime, for as short or long as you want"
- Focus on relaxation, not tension

## Analysis

| Factor | Fuel | No Fuel |
|--------|------|---------|
| Tension | High | Medium (via ladders) |
| Frustration risk | High | Low |
| Cognitive load | Higher | Lower |
| Mobile-friendly | No | Yes |
| Session flexibility | Restricted | Flexible |
| Casual appeal | Low | High |

## Recommendation: SKIP FUEL MECHANIC

**Reasons**:
1. **Mobile context**: Short, interruptible sessions don't work with fuel timers
2. **Existing tension**: Ladder economy + inventory limits provide sufficient tension
3. **Casual market**: Top mobile mining games avoid punishing mechanics
4. **Super Motherload lesson**: Even the sequel softened fuel to avoid frustration
5. **Recovery options**: GoDig has wall-jump, forfeit cargo - fuel death would contradict these

**The ladder mechanic is "resource fuel"** - players manage a consumable resource but it's discrete (count) not continuous (timer), making it more mobile-friendly.

## Expected Outcome
**Decision: Skip fuel mechanic.** Current mechanics (ladders, inventory, depth) provide sufficient tension without the frustration.
