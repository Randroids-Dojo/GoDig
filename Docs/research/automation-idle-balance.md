# Automation and Idle Progression Balance

> Research on balancing player agency with automation in active-idle hybrid games

## Executive Summary

GoDig straddles the line between active mining gameplay and idle progression. This research analyzes how successful games balance automation features without trivializing the core loop. The key insight: **automation should amplify player decisions, not replace them**.

**Key Finding**: The ideal balance is approximately 60% idle progression / 40% active engagement. Automation should arrive as a reward for mastery, not a replacement for learning.

---

## Game Analysis Matrix

| Game | Automation Type | Active Element | Balance Mechanism |
|------|-----------------|----------------|-------------------|
| **Idle Miner Tycoon** | Manager hiring | Manager selection, upgrade timing | Bottleneck management |
| **Melvor Idle** | Skill progression | Combat, activity switching | Mode selection, progression gating |
| **Cookie Clicker** | Building production | Golden cookie clicking | Variable rewards, massive scaling |
| **Factorio** | Factory building | Design, defense, optimization | Pollution-driven enemies |

---

## Deep Dive: Idle Miner Tycoon Manager System

### How It Works

Managers automate mining operations:
- Purchase at Mine Shaft level 5
- Three ranks: Junior, Senior, Executive
- Separate managers for Mine Shaft, Elevator, Warehouse

> "Managers remove the burden of manual tapping, keeping production flowing and letting you focus on strategy instead of micromanagement."

### The Bottleneck Balance

> "If miners collect resources faster than the elevator can handle, profits stall."

The game creates **flow management** decisions:
- Upgrade mine shafts? (more collection)
- Upgrade elevator? (faster transport)
- Upgrade warehouse? (better selling)

Automation doesn't eliminate choices - it **shifts them to a higher level**.

### Super Manager System

Kolibri Games added "Super Managers" with active + passive abilities. Combining managers creates powerful synergies, but requires:
- Knowledge of ability interactions
- Timing active abilities
- Resource allocation

**Design Lesson**: Automation can have an active component (ability timing) layered on top.

### Offline Caps

> "Idle Miner Tycoon caps offline income at around two hours without upgrades."

This prevents indefinite AFK progress and creates:
- Check-in incentive (collect before cap)
- Upgrade motivation (extend offline capacity)
- Active vs. idle trade-off

---

## Deep Dive: Melvor Idle Active/Idle Modes

### Core Philosophy

> "Inspired by RuneScape, Melvor Idle takes the core of what makes an adventure game addictive and strips it down to its purest form."

### Offline Progression

> "There is no actual difference between being Online and being Offline when it comes to getting items/experience."

- Progress continues up to 24 hours offline
- Returns simulate as if game was open
- No penalty for closing the game

### Active vs. Idle Playstyles

The game explicitly supports both:

**Laid Back (Idle)**:
- Check in once or twice daily
- Set long-term skills running
- Minimal interaction required

**Combat Focus (Active)**:
- Engage when online
- Manual combat decisions
- Switch between modes freely

> "Start the Laid Back version and do the Combat Focus section when you're active. Then go back to idling."

### Mode-Based Progression Gating

**Adventure Mode**: Start with only melee combat. Pay gold to unlock each skill.
- Forces meaningful choices about progression order
- Can't automate everything simultaneously
- Creates personalized routes through content

**Ancient Relics Mode**: Skills capped at level 10. Must complete dungeons to raise caps.
- Active content (dungeons) gates idle progress
- Players earn automation through engagement

**Design Lesson**: Different game modes can cater to different engagement levels without splitting the playerbase.

---

## Deep Dive: Cookie Clicker Golden Cookies

### The Core Tension

Cookie Clicker exemplifies the active-idle split:

**Idle**: Buildings produce cookies automatically, forever
**Active**: Golden cookies appear randomly, providing massive temporary bonuses

### Variable Reward Psychology

> "Golden cookies are one of the most powerful mechanics, offering temporary but substantial boosts. Effects like 'Frenzy' (7x production) can massively accelerate progress."

The psychological hook:
- Random appearance time (1.25 to 3.5 minutes)
- Requires attention to catch
- Missing one isn't punishing, catching one is rewarding

> "Variable rewards are a key aspect of the addictive design of slot machines."

### Active vs. Idle Trade-Off

> "Active players who frequently click and monitor golden cookies will progress faster but require more time investment."

Cookie Clicker is honest: you CAN progress idly, but active attention multiplies gains. This is the ideal balance for GoDig.

### The Achievement Hook

The "Black Cat's Paw" achievement requires clicking 7,777 golden cookies - "months of active play."

This creates:
- Long-term engagement for dedicated players
- No penalty for casual players who ignore it
- Bragging rights / completionist motivation

**Design Lesson**: Active play bonuses should be significant but optional.

---

## Deep Dive: Factorio Pollution-Driven Difficulty

### The Automation Paradox

Factorio is about automation - but more automation = more danger.

> "The more you pollute, the faster [aliens] evolve. Players must consider the balance between production and enemy aggressiveness."

### Three Evolution Factors

1. **Time**: Slight increase regardless of actions
2. **Pollution**: Factory output accelerates evolution
3. **Spawner Kills**: Destroying nests triggers adaptation

### Design Philosophy

> "Military and defense is in service to the main point: designing your base and automating away your problems. Biters give you more things to think about as you design."

Enemies don't prevent automation - they make automation **require more thought**.

### Player-Controlled Scaling

> "Biter waves are proportional to pollution that reaches them. The same difficulty setting may feel anywhere from peaceful to hardcore depending on pollution management."

Players can:
- Build compact, efficient factories (low pollution)
- Sprawl with heavy defenses (high pollution)
- Choose peaceful mode (no threat)

**Design Lesson**: Automation can create its own challenges rather than eliminating them.

---

## Idle Game Design Principles

### The 60/40 Rule

> "Aim for 60% of progress from idle mechanics and 40% from active engagement. This keeps the game accessible while rewarding dedicated players."

Applied to GoDig:
- 60%: Passive income from surface buildings, automation upgrades
- 40%: Active mining runs, strategic decisions, ore discovery

### Don't Automate Too Early

> "Don't automate too early - manual engagement often provides bonuses."

Players should:
1. Learn the system manually
2. Feel the friction of repetition
3. **Earn** automation as a reward
4. Appreciate the improvement

### Meaningful Choices Over Cosmetic Clicks

> "Mixed amongst cosmetic choices should be gear and upgrade choices that make the player feel their actions matter."

Automation decisions should have consequences:
- Which building to upgrade first?
- Automate mining OR transport?
- Invest in depth OR efficiency?

### Resource Caps as Engagement Hooks

> "Resource caps prevent players from hoarding excessive resources and encourage consistent interaction."

Without caps:
- Players stockpile indefinitely
- Return to game with "solved" economy
- No engagement hook

With caps:
- Must check in to collect
- Upgrade caps = meaningful progression
- Natural session rhythm

### The Trivialization Danger

> "Without drains, resources would accumulate indefinitely, eventually making all challenges trivial."

IGN describes the idle paradox: "Players feel both powerful and weak simultaneously, as they chase exponential growth."

**Solution**: Always introduce new sinks alongside new sources.

---

## Design Recommendations for GoDig

### Core Principles

1. **Automation as Reward**: Unlock automation through active achievement
2. **Active Bonuses**: Mining runs should always beat passive income
3. **Strategic Choices**: Which automation to unlock, in what order
4. **Scaling Sinks**: New expenses arrive with new income sources
5. **No Trivialization**: Active gameplay remains meaningful at all stages

### Suggested Automation Progression

| Stage | Unlock | Automation | Active Bonus |
|-------|--------|------------|--------------|
| **Early** | First 10 runs | None | Learn core loop |
| **Mid** | 200m depth | Auto-sell common ores | Rare ores require manual runs |
| **Late** | 500m depth | Passive income building | Active runs 3x income |
| **End** | 1000m+ | Full auto-miner | Deep dives for unique loot |

### Automation Building Spec

Based on research, the v1.1 Auto-Miner should:

1. **Require Investment**
   - Unlock at significant depth milestone
   - Expensive to purchase
   - Upgrades cost rare resources

2. **Produce Subset of Resources**
   - Common ores only (coal, copper, iron)
   - Rare ores require active mining
   - Unique treasures never automated

3. **Cap at Percentage of Active Income**
   - Auto-miner produces 20-30% of active run income
   - Never exceeds 50% even fully upgraded
   - Active play always superior for progression

4. **Have Offline Limits**
   - 2-hour offline cap (upgradeable to 8 hours)
   - Creates natural check-in rhythm
   - Prevents indefinite accumulation

### Active Engagement Hooks

Even with automation, active play should offer:

| Hook | Description | Multiplier |
|------|-------------|------------|
| **Deep Runs** | Go past automated depth for rare ores | 3-5x value |
| **Discovery Moments** | Golden ore veins, cave treasures | Random bonus |
| **Challenge Runs** | Optional difficulty = cosmetic rewards | Status symbol |
| **Events** | Time-limited bonuses for active play | 2x income |

### What to Avoid

1. **Early Automation**: Don't let players skip the learning curve
2. **Full AFK Optimization**: Active should always beat passive
3. **Automation Without Decisions**: Each upgrade should involve trade-offs
4. **Static Income**: Automation should have diminishing returns without active reinvestment
5. **Removal of Core Loop**: Mining should always be the fastest path

### The "One More Run" Test

Before implementing any automation feature, ask:
> "Does this make players want to do one more active run, or does it make them feel they can skip the run?"

If automation reduces desire to play actively, it's too strong.

---

## Implementation Priority

### Phase 1: Passive Income Building (v1.1)
- Simple coin generation while offline
- Capped at 2 hours
- Produces 10% of average run income

### Phase 2: Auto-Miner Station (v1.2)
- Produces common ores while away
- Requires periodic "maintenance" (check-in)
- Upgradeable capacity and depth

### Phase 3: Manager/Worker System (v1.3)
- Hire workers to mine specific depths
- Worker efficiency = player's best run at that depth
- Creates investment in active record-setting

---

## Sources

- [Idle Miner Tycoon Automation Guide - Tap Guides](https://tap-guides.com/2025/09/25/idle-miner-tycoon-automation-guide-best-afk-strategies-for-maximum-profit/)
- [Idle Miner Tycoon Managers - Fandom Wiki](https://idleminertycoon.fandom.com/wiki/Managers)
- [Super Manager 2.0 - Kolibri Games](https://www.kolibrigames.com/blog/introducing-super-manager-2-0/)
- [Melvor Idle Game Modes - Wiki](https://wiki.melvoridle.com/w/Game_Mode)
- [Melvor Idle Offline Progression - Wiki](https://wiki.melvoridle.com/w/Offline_Progression)
- [Cookie Clicker - Wikipedia](https://en.wikipedia.org/wiki/Cookie_Clicker)
- [Golden Cookie - Cookie Clicker Wiki](https://cookieclicker.fandom.com/wiki/Golden_Cookie)
- [Addictive Psychology of Clicker Games - Softonic](https://en.softonic.com/articles/addictive-psychology-clicker-games)
- [Factorio - Wikipedia](https://en.wikipedia.org/wiki/Factorio)
- [Factorio Pollution Discussion - Forums](https://forums.factorio.com/viewtopic.php?t=49778)
- [How to Design Idle Games - Machinations](https://machinations.io/articles/idle-games-and-how-to-design-them)
- [Passive Resource Systems - Adrian Crook](https://adriancrook.com/passive-resource-systems-in-idle-games/)
- [Idle vs Incremental vs Tycoon - Medium](https://medium.com/tindalos-games/idle-vs-incremental-vs-tycoon-understanding-the-core-mechanics-f12d62f4b9f7)
- [Idle Game Design Principles - Eric Guan](https://ericguan.substack.com/p/idle-game-design-principles)

---

*Research completed: 2026-02-02*
*Supports: GoDig-implement-automation-building-496db9d0*
