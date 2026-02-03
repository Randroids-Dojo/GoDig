---
title: "research: Asymmetric risk design in roguelites"
status: closed
priority: 2
issue-type: research
created-at: "\"2026-02-02T22:25:34.657075-06:00\""
closed-at: "2026-02-02T22:30:13.568589-06:00"
close-reason: Completed research on asymmetric risk design from Dome Keeper, Hades, Dead Cells. Documented push-your-luck mechanics, depth-based risk gradient, and self-balancing systems.
---

## Research Question

How do games like Hades, Dead Cells, and Dome Keeper balance early-game safety with late-game danger? What creates the "push your luck" tension that makes mining games compelling?

## Key Findings

### 1. The Core Pattern: Depth = Risk

**Dome Keeper's Design Philosophy:**
- "The further down you go, the more frequent and precious materials get, but you also become farther away from protecting your dome"
- Called "a masterpiece in game design" for its risk-reward balance
- Uses waves between mining trips to force decision-making
- Players "must weigh up the pros and cons of each journey"

**Weight-Based Scaling:**
- Dome Keeper calculates difficulty from inventory totals
- More resources = harder waves (iron: 0.6 weight, sand: 2.2, water: 1.2)
- Elegant self-balancing: success makes the game harder

### 2. Push Your Luck Mechanics

**Core Definition:**
"Players must decide between settling for existing gains, or risking them all for further rewards"

**Classic Example - Incan Gold:**
- Binary decision: explore further or go home with treasure
- Two identical hazards = lose all accumulated treasure
- Players who leave early keep their loot
- Those who push furthest get biggest rewards

**Deep Sea Adventure Pattern:**
- Shared oxygen supply creates communal pressure
- More treasure = more oxygen consumed
- Must return before oxygen runs out
- Creates natural tension curve

### 3. Roguelite Difficulty Curves

**The Biome Principle:**
"A good early biome teaches, later zones test, endgame pushes mastery"

**Hades Approach:**
- "Early on, generous resources and forgiving enemy patterns help players acclimate"
- As proficiency grows, game ramps up with new challenges
- Heat system lets players control their difficulty
- "Even failed runs yield story progress and upgrades"

**Risk of Rain 2:**
- Real-time scaling ensures tension rises organically
- "Players control the pace, deciding whether to search for more loot or rush"
- Staying longer = harder enemies but better gear

**Dead Cells:**
- Early biomes allow experimentation with minimal pressure
- Later areas introduce complex patterns and traps
- Boss Cells (difficulty modifiers) earned by success
- "The difficulty isn't arbitrarily imposed but is a direct consequence of the player's achievement"

### 4. The Investment Problem

**Permanent Upgrades Risk:**
- Can create "difficulty on a slider that always starts too hard and ends up too easy"
- Some view this as "a lazy way to handle balance"
- Darkest Dungeon critique: can't complete challenges "because they haven't farmed enough meta-party power"

**Solution - Tied to Skill:**
- Rewards should come from both skill AND persistence
- Failed runs still yield progress
- No session should feel wasted

### 5. Self-Balancing Systems

**Push Your Luck Self-Balance:**
- "The game self-balances because... the fewer players still in, the more their potential reward"
- Those who continue pushing earn greater rewards
- Risk and reward scale together naturally

**Blend with Other Mechanics:**
- "Push your luck if it's the whole game can get a bit tiresome"
- "Has some interesting things to it if it's blended with other mechanics"
- Mining provides the blend: resource gathering + traversal + survival

## Application to GoDig

### Recommended Risk Gradient

| Depth | Risk Level | Design Elements |
|-------|------------|-----------------|
| 0-100m | Safe/Tutorial | Easy blocks, common ores, quick return |
| 100-300m | Low | Harder blocks, better ores, fall damage starts |
| 300-500m | Medium | Caves appear, inventory pressure builds |
| 500-1000m | High | Hazards active, rare ores, significant travel time |
| 1000m+ | Extreme | Elite enemies, unique treasures, commitment required |

### Core Tension Systems

**1. Inventory as Risk Meter**
- Empty inventory = nothing to lose
- Full inventory = everything at stake
- Visual indicator of how much you're risking

**2. Distance as Commitment**
- Further from surface = longer return trip
- Each depth meter adds return time
- Natural "point of no return" feeling

**3. Resource Quality vs Quantity**
- Deep ores worth more but fewer chances to get them
- Surface ores common but low value
- Creates natural push-your-luck decisions

### Anti-Frustration Measures

**1. Escalating Warnings**
- HP low warnings
- Inventory full notifications
- "Far from surface" indicators
- Audio cues that increase with depth

**2. Retreat Options**
- Ladders for guaranteed return
- Teleport scrolls for emergencies
- Cairn checkpoints for partial progress saves

**3. Partial Loss System (from existing research)**
- Death loses 10-30% of inventory, not all
- Structures remain
- Learning opportunity, not total punishment

### Dome Keeper Lessons for GoDig

1. **Wave Pressure Alternative:** Instead of waves, use HP degradation or inventory limits as return pressure
2. **Weight System:** Consider ore weight affecting movement speed (already researched)
3. **Clear Visual Feedback:** Show depth vs dome/surface distance clearly
4. **Escalating Stakes:** Each trip deeper should feel like a bigger commitment

### The "One More Trip" Psychology

**What Creates It:**
- Just found valuable ore = want to find more
- Almost have enough for upgrade = push a bit further
- New depth milestone visible = must reach it
- Inventory not quite full = room for one more

**Design to Support:**
- Show nearby valuable ore hints
- Display progress to next upgrade
- Celebrate depth milestones
- Make "just a bit more" feel achievable

## Design Principles Summary

1. **Depth = Risk**: Make the relationship clear and consistent
2. **Loot = Stakes**: Full inventory means everything to lose
3. **Time = Tension**: Further from surface = higher stakes
4. **Choice = Agency**: Player decides when to push vs retreat
5. **Failure = Learning**: Every death teaches something
6. **Progress = Earned**: Difficulty scales with player success

## Sources

- [Dome Keeper Review - TheXboxHub](https://www.thexboxhub.com/dome-keeper-review/)
- [Dome Keeper Wiki - Technical Terms](https://domekeeper.wiki.gg/wiki/Technical_Terms)
- [Push Your Luck - BoardGameGeek](https://boardgamegeek.com/boardgamemechanic/2661/push-your-luck)
- [Game Mechanics: Push Your Luck - Board Game Design Course](https://boardgamedesigncourse.com/game-mechanics-sometimes-you-want-to-push-your-luck/)
- [Roguelikes That Balance Difficulty Perfectly - GameRant](https://gamerant.com/roguelikes-with-perfect-difficulty-balance/)
- [Reversing the Difficulty Curve - Game Wisdom](https://game-wisdom.com/critical/reversing-the-difficulty-curve-in-game-design)
- [Dead Cells Difficulty as Design - Medium](https://medium.com/@tunganh0806/difficulty-as-design-dead-cells-progressive-challenge-and-player-engagement-74f086064bf6)

## Status

Research complete. Provides foundation for risk gradient implementation and push-your-luck mechanics.
