---
title: "research: Difficulty scaling after mastery"
status: closed
priority: 3
issue-type: task
created-at: "\"2026-02-01T08:11:16.103189-06:00\""
closed-at: "2026-02-01T09:25:07.035925-06:00"
close-reason: "Research complete: Recommend opt-in challenge modifiers for v1.1, NOT auto-scaling. Hades Heat system is the model."
---

Research how to keep early areas challenging after players have mastered the game.

## Context
Hades 2 found that after a few dozen runs, Erebus 'started to feel a bit too easy.' Their solution: spawn new, tougher foes in completed areas.

## Questions to Answer
1. How does GoDig currently scale difficulty by depth?
2. What indicators show a player has 'mastered' early areas?
3. Should we spawn harder blocks/enemies, or add new mechanics?
4. How do other mining games handle this (Terraria hard mode)?
5. Risk: alienating returning players vs boring experienced players

## Research Sources
- Terraria hardmode mechanics
- Spelunky 2 daily challenge system
- Hades 2 difficulty scaling approach
- Dome Keeper wave difficulty
- Dead Cells difficulty cells system

## Expected Output
- Analysis of mastery indicators
- Recommendations for GoDig scaling approach
- implement: dot for chosen approach

## Research Findings (Session 20)

### Hades Difficulty System Analysis

**Key Insight**: Hades does NOT auto-scale difficulty. Instead:
1. **Player skill progression** makes enemies feel manageable over time
2. **Pact of Punishment (Heat System)** lets players opt-in to harder modifiers
3. **God Mode** provides accessibility (damage resistance increases with each death)
4. **Hell Mode** provides challenge for mastery players

**Player perception**: "Enemies tend to feel overwhelming if you're not used to their movement, but as you get used to them, you start wondering why you were ever having trouble."

**Why it works**: "Even failed runs yield story progress and upgrades, ensuring no session feels wasted."

### Roguelike Difficulty Balance Principles

1. **Gradual learning curve** - Early runs are forgiving, later runs demand skill
2. **Rewards tied to skill AND persistence** - Both paths feel valid
3. **Fail-forward design** - No session is wasted, always earning something
4. **Player-controlled challenge** - Opt-in difficulty, not forced scaling

### GoDig Mastery Indicators

Potential signals that a player has "mastered" early areas:
- Consistent 50m+ depths with full cargo return
- First upgrade purchased within X minutes (below target time)
- Zero emergency rescues in last N runs
- Ladder efficiency ratio (ladders used vs depth reached)
- Time to reach specific depths decreasing

### Recommended GoDig Approach

**DO NOT auto-scale early areas.** This alienates casual players who enjoy the comfortable early game.

**Instead, add optional mastery challenges (v1.1)**:

1. **Depth Records & Leaderboards**
   - Track personal best depth
   - Beat-your-record goals create self-challenge

2. **Challenge Runs (Hades Heat-style)**
   - "Start with only 3 ladders" modifier
   - "No wall-jump" modifier
   - "Timer: reach 100m in 2 minutes" modifier
   - Reward: cosmetic pickaxe skins, badges

3. **Prestige System (v1.1)**
   - After reaching max depth, option to reset for permanent bonuses
   - Makes early areas relevant again (but still comfortable)

4. **Daily/Weekly Challenges**
   - Specific seed with leaderboard
   - "Reach 200m with this loadout"
   - Community competition

### Features to AVOID

- **Auto-scaling enemy spawn** - Wrong for our tension model (ladders, not combat)
- **Forced difficulty increase** - Alienates casuals who love early game
- **Removing the "power fantasy"** - Players SHOULD feel strong in early areas after upgrades

### Recommended Implementation Spec

Create: `implement: Challenge run modifier system` (v1.1)
- Player-selectable difficulty modifiers
- Each modifier has cosmetic reward
- Leaderboards for challenge completions

## Status

Research complete. Recommendation: Add opt-in challenge system in v1.1, not auto-scaling.
