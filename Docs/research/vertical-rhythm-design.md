# Vertical Rhythm and Momentum in Down-Then-Up Game Design

*Research Session 26 - Vertical Exploration Patterns*

## Overview

Games with vertical descent and ascent cycles (dig down, return up) create unique rhythm patterns distinct from horizontal exploration games. This document analyzes how mining games manage the tension between satisfying descent and tedious return trips.

## The Core Challenge

Mining games face a fundamental design tension:

**Descent is exciting:**
- Discovery of new resources
- Deepening danger
- Forward progress feeling

**Ascent can be tedious:**
- Already-explored territory
- No new discoveries
- Feels like "undoing" progress

The best mining games solve this by making both phases engaging or by providing meaningful escape mechanisms.

## Case Study: SteamWorld Dig

### The Problem

From [Gamedeveloper's Design Deep Dive](https://www.gamedeveloper.com/design/game-design-deep-dive-the-digging-mechanic-in-i-steamworld-dig-i-):

> "Going back up to the surface can take several minutes and is an exercise in boredom. Everything should be dead, your path is already carved... you're just running and jumping back up to an exit or a teleporter."

The developers intended tension from the risk of getting stuck, but players found the return trip the real frustration point.

### Solutions Implemented

1. **Teleporters** - Can be placed at will, but limited by economy
2. **Wall-jump** - Skill expression during ascent
3. **Procedural tube systems** (Dig 2) - Fast travel between depths

### Key Insight

> "The pacing of items you need to place teleporters without cutting yourself off from being able to afford new upgrades is too tight."

**Lesson for GoDig**: Traversal items (ladders, teleports) must be affordable enough that players don't feel punished for using them.

## Case Study: Motherload

### The Fuel Rhythm

From [Analysis of Motherload](https://jackjohnsonuni.wordpress.com/2016/10/10/analysis-of-motherload-web-based-game/):

> "The premise is simple: dig, mine, climb, sell. Dig a series of treacherous mine shafts beneath the surface of Mars. Mine every rare substance you can find. Climb your way back out of the hole you've dug for yourself. Sell your rarities to buy fuel, repairs, items, and upgrades."

Fuel creates a **natural rhythm**:
- Descent limited by fuel consumption
- Player naturally times returns before fuel runs out
- Tension builds as fuel depletes

### Emotional Response

One player remembered:
> "The true fear I felt when I was low on fuel flying up to the surface."

This fear is the **positive tension** the game creates - not from the return trip itself, but from the stakes of timing.

### Super Motherload's Change

Super Motherload added underground bases, cutting out long treks:
> "Unlike the original you'll pass subterranean bases with all the amenities of your surface complex, cutting out the long treks up and down of the original."

But this removed some of the emotional stakes:
> "I don't feel fear anymore because when you run out of fuel you just move slower instead of dying."

**Lesson for GoDig**: Safety nets are important, but too many remove meaningful tension.

## Case Study: Dome Keeper

### The External Timer

From [Gamedeveloper](https://www.gamedeveloper.com/business/how-dome-keeper-focuses-on-systems-that-feed-into-one-another):

> "Dome Keeper is built around a compact but demanding gameplay loop. There is no moment of complete safety—only short breaks between threats."

Dome Keeper solves the return trip problem by making the return **urgent**:
- Waves of enemies attack the dome on a timer
- Player must return to defend
- Mining phase is "strangely peaceful, bordering on meditative"
- But "tension always hangs in the background"

### Audio as Tension Indicator

> "Each monster has its own ambience which attenuates based on the enemy number as well, so experienced players can read a lot from the ambience as they hurry back up to defend their dome."

The audio design during combat deliberately avoids music:
> "During the playtest phase, the developers realized that music during the battle actually decreased the tension a bit."

### Three-Phase Design

1. **Mining phase** (~1 minute) - Peaceful digging
2. **Warning phase** - Alarm signals return needed
3. **Defense phase** - Urgent combat at surface

**Lesson for GoDig**: An external timer (waves, hunger, oxygen) can make returns feel purposeful rather than tedious.

## Case Study: Spelunky

### One-Way Descent

From [Spelunky Wikipedia](https://en.wikipedia.org/wiki/Spelunky):

> "The player controls a spelunker who explores a series of caves while collecting treasure, saving damsels, fighting enemies, and dodging traps."

Spelunky avoids the return problem entirely - there IS no return. The goal is to reach the bottom, not to surface.

### Vertical Tools as Risk

> "The spelunker can... use a limited supply of bombs and ropes to navigate the caves."

Ropes are one-way up, creating escape routes but not "return trips." The design choice:
- Descent is the only direction of progress
- Death restarts from the top
- Resources spent going back up are "wasted"

**Lesson for GoDig**: If the game must have returns, make them feel like progress (selling, upgrading) rather than backtracking.

## Vertical Rhythm Principles

### 1. The Descent Momentum

**Good descent feels like:**
- Acceleration (gravity-assisted)
- Discovery (new blocks, ores, caves)
- Investment (deeper = more valuable)
- Danger escalation (harder blocks, rarer resources)

**Bad descent feels like:**
- Grinding through hard blocks
- Monotonous sameness
- No surprises

### 2. The Ascent Motivation

Players need a reason to return that feels **positive**, not just "I ran out of space":

| Motivation | Feel | Example |
|------------|------|---------|
| Inventory full | Neutral/negative | "I have to go back" |
| Sell excitement | Positive | "I can't wait to cash in!" |
| Upgrade waiting | Positive | "I have enough for the next tier!" |
| Safety pressure | Tense/positive | "I'm almost out of fuel/ladders" |
| External timer | Urgent/positive | "The dome is under attack!" |

**GoDig should emphasize**: "I can't wait to sell this haul!" over "I have to go back now."

### 3. Ascent Skill Expression

The return can be engaging if it requires skill:

| Mechanism | Skill Type | Example |
|----------|-----------|---------|
| Wall-jump | Timing/precision | SteamWorld Dig |
| Resource management | Planning | Motherload fuel |
| Ladder conservation | Strategy | GoDig (ours) |
| Shortcut discovery | Exploration | Hidden tunnels |
| Speed optimization | Mastery | Optimal route |

**GoDig advantage**: Ladder depletion creates a unique tension - the return is a puzzle of "can I get back with my remaining ladders?"

### 4. Rhythm Variation

The best games vary the descent/ascent rhythm:

**Early game:**
- Short dives (5-10 blocks down)
- Frequent returns
- Quick gratification

**Mid game:**
- Deeper dives
- Elevator/teleport unlock
- Longer between returns

**Late game:**
- Very deep expeditions
- Emergency tools (teleport scrolls)
- Strategic checkpoint placement

## Avoiding Tedium Patterns

### What Makes Returns Tedious

1. **Dead time** - Nothing happens during ascent
2. **No decisions** - Path is already carved
3. **Too frequent** - Interrupts flow before satisfaction
4. **Too long** - Journey exceeds attention span
5. **Identical every time** - No variation

### Solutions Matrix

| Problem | Solution | Implementation |
|---------|----------|----------------|
| Dead time | Consumable resource | Ladder depletion tension |
| No decisions | Enemies/hazards on return | (Optional for GoDig) |
| Too frequent | Inventory upgrades | Expandable capacity |
| Too long | Fast travel unlocks | Elevator at mid-game |
| Identical | Procedural variation | Random events on return |

## Recommendations for GoDig

### Phase 1: Core Return Experience

1. **Ladder tension** - Primary return mechanic
   - Counting remaining ladders creates natural rhythm
   - Running low triggers "push-your-luck" decision
   - Wall-jump as backup creates skill expression

2. **Sell anticipation** - Frame returns positively
   - Show accumulated value during descent
   - Coin count visible in HUD
   - "You can now afford X" indicator

3. **Return route hints** - Reduce navigation tedium
   - Show optimal path to surface
   - Highlight nearby ladders/exits
   - Mark elevator locations

### Phase 2: Return Variety (v1.0+)

1. **Elevator unlock** - Reduces return length mid-game
2. **Teleport scroll** - Emergency bailout item
3. **Surface events** - Occasionally something happens up top
4. **Depth records** - Celebrate deepest returns

### Phase 3: Mastery Returns (v1.1+)

1. **Challenge returns** - Optional speedrun mode
2. **Efficiency scoring** - Rate return route quality
3. **Ladder-free returns** - Wall-jump mastery achievement

## Key Metrics to Monitor

1. **Average return time** - Target: <30 seconds for early game
2. **Return abandonment** - Players who quit during ascent
3. **Ladder purchase rate** - Are players buying enough?
4. **Elevator usage rate** - Is fast travel satisfying?
5. **Death-during-return rate** - Frustration indicator

## Sources

- [Game Design Deep Dive: The digging mechanic in SteamWorld Dig](https://www.gamedeveloper.com/design/game-design-deep-dive-the-digging-mechanic-in-i-steamworld-dig-i-)
- [How Dome Keeper focuses on systems that feed into one another](https://www.gamedeveloper.com/business/how-dome-keeper-focuses-on-systems-that-feed-into-one-another)
- [Design Dive: Dome Keeper](https://joshanthony.info/2023/05/24/design-dive-dome-keeper/)
- [Analysis of Motherload](https://jackjohnsonuni.wordpress.com/2016/10/10/analysis-of-motherload-web-based-game/)
- [Super Motherload on PS4](https://blog.playstation.com/2013/11/08/super-motherload-on-ps4-exploring-the-story-and-game-modes/)
- [Spelunky - A Study in Good Game Design](https://alconost.medium.com/spelunky-a-study-in-good-game-design-669a18f1a178)
- [Use vertical space and exploration - Game Design Snacks](https://game-design-snacks.fandom.com/wiki/Use_vertical_space_and_exploration)
- [Steam Community - Dome Keeper Strategy Guide](https://steamcommunity.com/sharedfiles/filedetails/?id=2869939597)

## Related Implementation Tasks

- `GoDig-implement-return-route-86fe3653` - Return route efficiency hints
- `GoDig-implement-elevator-unlock-a0099585` - Elevator discovery celebration
- `GoDig-implement-low-ladder-e6f21172` - Low ladder warning
- `GoDig-implement-wall-jump-ec117d74` - Wall-jump mastery feedback
