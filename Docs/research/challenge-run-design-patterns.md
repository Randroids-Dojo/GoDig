# Challenge Run Design Patterns in Roguelites

> Research on player-controlled difficulty systems: Heat, Ascension, NG+, and Artifacts

## Executive Summary

Player-controlled difficulty systems have become a defining feature of modern roguelites. Instead of traditional Easy/Normal/Hard presets, these systems let players customize their challenge through individual modifiers. This research analyzes successful implementations to inform GoDig's v1.1 Challenge Run system.

**Key Finding**: The best difficulty systems give players **agency over challenge type**, not just challenge level. Players choose *how* the game gets harder, creating personalized mastery experiences.

---

## System Comparison Matrix

| Game | System Name | Unlock Method | Modifiers | Rewards | Community |
|------|-------------|---------------|-----------|---------|-----------|
| **Hades** | Pact of Punishment (Heat) | Beat final boss | 15-16 individual modifiers | Resources (Titan Blood, Diamonds) | Leaderboards by weapon |
| **Slay the Spire** | Ascension | Win at current level | 20 cumulative levels | Achievement, harder content | Daily runs, seeded sharing |
| **Dead Cells** | Boss Cells | Collect from bosses | 5 NG+ levels | New biomes, items, endings | Community routing |
| **Risk of Rain 2** | Artifacts | Code puzzles | 18 toggles (mix-and-match) | None (challenge is reward) | Artifact combos |
| **Celeste** | Assist Mode | Always available | 5+ sliders (easier) | None | Accessibility model |

---

## Deep Dive: Hades Heat System

### Why It Works

The Pact of Punishment is "an excellent approach to difficulty levels, essentially personalizing it for you." Each modifier makes the game harder in a specific way: tougher enemies, weaker player, time limits. The question becomes: **which challenges are tolerable for YOU?**

### Design Philosophy

1. **Personalized Difficulty**: No two players have the same "best" heat configuration
2. **Diegetic Integration**: Heat is part of the story - Hades allows Zagreus to make it harder
3. **Resource Gating**: Higher heat = more rewards, but only up to a point
4. **Skill Expression**: Heat 32 requires "in-depth knowledge, high mechanical skill, and luck"

### Modifier Tiers (By Heat Cost)

| Cost | Modifier Type | Examples |
|------|---------------|----------|
| 1-2 Heat | Manageable tweaks | +20% enemy damage, longer boss fights |
| 3-4 Heat | Strategy shifts | No mid-boss healing, tighter timers |
| 5+ Heat | Run-defining | Elite enemies, extreme damage scaling |

### Critical Insight for GoDig

> "Pact of Punishment simply allows you to earn more resources at the cost of increasing difficulty. If you only care about the story, you can stay at Heat 0 forever."

**GoDig Application**: Challenge runs should offer cosmetic rewards, not gameplay advantages. Keep the core progression separate from challenge completion.

---

## Deep Dive: Slay the Spire Ascension

### Progressive Difficulty Philosophy

> "Progressive difficulty is not about 'one size fits all' difficulty modifiers. Each level of difficulty will tweak an aspect of the game."

Unlike traditional settings, Ascension levels are **cumulative** - each new level adds to all previous modifiers. This creates a clear skill ladder.

### Examples of Ascension Modifications

- Add "trash cards" to starting deck (force deckbuilding decisions)
- Reduce shop item quality
- Start with less max HP
- Enemies gain more strength per turn

### Key Design Elements

1. **No Content Gating**: "The game doesn't force you to run ascensions. You can unlock everything despite ascension."
2. **Expert Mountain**: "Progressive difficulty acts as both a gatekeeper to harder modes AND a mountain for expert players to climb"
3. **Transparent Stacking**: Players know exactly what each level adds

### Custom Mode Alternative

Slay the Spire also offers custom mode with "modifiers that can increase or decrease difficulty" - this serves casual players who want variety without the climb.

---

## Deep Dive: Dead Cells Boss Cells

### Earned Escalation Design

> "The difficulty isn't arbitrarily imposed but is a direct consequence of the player's achievement, keeping them invested in overcoming the next hurdle."

Boss Cells represent a **narrative of progression** - each stem cell you absorb unlocks new content alongside new difficulty.

### How Difficulty Scales

| BC Level | Changes | Content Unlocked |
|----------|---------|------------------|
| 0 | Baseline | Core game |
| 1 | Fewer healing fountains, stronger enemies | New biomes |
| 2 | Enemies teleport when distant | More items |
| 3+ | Major strategy shifts required | True endings |

### The Difficulty Gap Problem

Community feedback revealed BC1 felt "insane" compared to BC0. Motion Twin addressed this by:

- Making BC0 slightly harder to teach fundamentals
- Smoothing the BC2 curve ("shouldn't beat you up and take your lunch money anymore")

**Lesson for GoDig**: Monitor community feedback on difficulty jumps. First modifier should feel like a "comfortable stretch," not a wall.

### Baked-In vs. Optional

> "Dead Cells handles difficulty better than even Hades because its challenge progression is baked into the game's structure rather than tacked on."

**Counter-argument for GoDig**: Our core loop is about relaxing progression, not mastery. Optional challenges (Hades model) fit better than mandatory difficulty gates (Dead Cells model).

---

## Deep Dive: Risk of Rain 2 Artifacts

### Discovery-Based Unlocking

Artifacts require players to:
1. Reach Stage 5 (skill gate)
2. Find hidden codes scattered through levels (exploration reward)
3. Complete an unlock trial in "Bulwark's Ambry" (skill verification)

This creates **earned ownership** - players who unlock Artifacts feel they discovered something.

### Mix-and-Match Design

> "There isn't any limit on artifacts a player can activate. The synergies are quite fun to explore."

Examples:
- **Artifact of Command**: Choose item drops (easier)
- **Artifact of Honor**: Enemies spawn as elites only (harder)
- **Artifact of Sacrifice**: Monsters drop items, no chests (different)

Some artifacts make the game easier, some harder, some just *different*. This sidesteps the "easier = less skilled" stigma.

### No External Rewards

Artifacts offer no unlock rewards beyond the artifact itself. **The challenge IS the reward** - players activate them for personal satisfaction or variety.

**GoDig Application**: Consider offering some modifiers that are "sideways" rather than strictly harder. Example: "No Wall-Jump but Infinite Ladders" changes playstyle without pure difficulty increase.

---

## Deep Dive: Celeste Assist Mode

### The Accessibility Model

Celeste takes the opposite approach: instead of making the game harder, Assist Mode makes it **more accessible**. Key options:

- Game speed reduction (50-90%)
- Infinite stamina/dashes
- Invincibility
- Dash direction assist

### Philosophy Statement

> "Celeste was designed to be challenging but accessible. We recommend playing without Assist Mode first. However, we understand every player is different."

### Non-Judgmental Design

> "The goal is a fluid experience where players are safe to float between difficulty levels, without judgement that they aren't playing 'as intended.'"

Key elements:
- No achievements disabled
- No content locked
- Accessible from pause menu anytime
- Labeled as accessibility, not "easy mode"

### Balancing Hard + Easy

> "The ability of Assist Mode to make the game less challenging served as a counterbalance to the optional harder content."

**Critical insight**: If you're adding challenge modifiers, consider **also** adding accessibility options. B-sides AND assist mode.

---

## Daily Challenges & Community Engagement

### Seeded Runs

> "Daily challenges use a preset random seed so each player has the same encounters; players compete via online leaderboards."

Benefits:
- Fair competition (same RNG)
- Community discussion ("How did you handle room 3?")
- Content creation (streamers race the same seed)

### Implementation Examples

| Game | Daily Feature | Community Element |
|------|---------------|-------------------|
| Slay the Spire | Daily climb | Global leaderboard |
| Spelunky 2 | Daily challenge | Speedrun competition |
| Returnal | House sequences | Weekly rotations |
| Flamebreak | Daily seeds | Friend comparisons |

### Community Events

The 7DRL Challenge shows roguelike communities value shared challenge experiences. Consider:
- Weekly featured modifier combinations
- Community-voted "challenge of the week"
- Streamer challenge partnerships

---

## Reward Psychology

### Tier Structure

Based on WoW Challenge Mode and Hades patterns:

| Tier | Effort Required | Reward Type | Player Feeling |
|------|-----------------|-------------|----------------|
| Bronze/Basic | Complete challenge once | Acknowledgement | "I did it" |
| Silver/Good | Complete efficiently | Cosmetic unlock | "I'm competent" |
| Gold/Expert | Speedrun or combo | Rare cosmetic | "I've mastered this" |
| Platinum/Elite | Extreme conditions | Unique/exclusive | "I'm elite" |

### Cosmetic vs. Gameplay Rewards

Hades gives resources (Titan Blood, Diamonds) - but these are **capped**. After earning max rewards, challenge is purely for personal satisfaction.

Risk of Rain gives **nothing** for artifacts - the experience IS the reward.

**Recommendation for GoDig**: Cosmetic rewards prevent pay-to-win concerns. Players who can't complete challenges don't feel power-gated.

---

## Design Recommendations for GoDig

### Core Principles

1. **Agency Over Type**: Let players choose HOW it's harder, not just how MUCH
2. **No Content Gating**: Challenges unlock cosmetics, not gameplay
3. **Transparent Effects**: Each modifier clearly states its impact
4. **Combinable Modifiers**: More interesting than single difficulty slider
5. **Accessible Alternative**: If adding "hard mode," consider assist options too

### Suggested Modifier Categories

| Category | Examples | Design Purpose |
|----------|----------|----------------|
| **Resource Scarcity** | Fewer starting ladders, reduced ore drops | Heighten core tension |
| **Time Pressure** | Depth timers, sell windows | Create urgency |
| **Movement Restriction** | No wall-jump, slower climbing | Force creative pathing |
| **Fragile Cargo** | Higher loss on rescue, no rescue | Raise stakes |
| **Enemy/Hazard** | More enemies, faster heat buildup | Combat challenge |
| **Meta Restrictions** | No upgrades allowed, single pickaxe | Purity runs |

### Reward Structure

| Tier | Requirement | Reward |
|------|-------------|--------|
| **Tier 1** | Any single modifier | Pickaxe recolor |
| **Tier 2** | Any 3 modifiers | Unique pickaxe skin |
| **Tier 3** | Specific "hard" combos | Badge/title |
| **Elite** | Community challenges | Seasonal exclusive |

### Community Features

1. **Daily Seeded Runs**: Same world seed for fair comparison
2. **Weekly Featured Challenge**: Curated modifier combo
3. **Personal Best Tracking**: Beat your own records
4. **Friend Leaderboards**: Async competition with contacts
5. **Challenge Sharing**: Generate shareable codes for custom combos

### What to Avoid

1. **Mandatory Difficulty Gates**: Don't require challenges for progression
2. **Unclear Modifier Effects**: Each toggle should have exact numbers
3. **Extreme First Step**: Initial modifier should be "stretch," not "wall"
4. **Gameplay Rewards**: Avoid giving challenge completers power advantages
5. **FOMO Pressure**: Daily challenges should rotate, not expire forever

---

## Implementation Priority

### Phase 1: Foundation (v1.1)
- 4-6 basic modifiers
- Per-modifier cosmetic rewards
- Challenge completion tracking

### Phase 2: Depth (v1.2)
- 10+ modifiers with combinations
- Daily seeded challenge
- Friend leaderboards

### Phase 3: Community (v1.3)
- Weekly featured challenges
- Challenge code sharing
- Streaming integration

---

## Sources

- [Hades Pact of Punishment - RPG Site](https://www.rpgsite.net/feature/10287-hades-pact-of-punishment-heat-modifiers-and-how-to-maximize-your-rewards)
- [Hades Game Design - Polydin](https://polydin.com/hades-game-design/)
- [Pact of Punishment - Hades Wiki](https://hades.fandom.com/wiki/Pact_of_Punishment)
- [Slay the Spire - Wikipedia](https://en.wikipedia.org/wiki/Slay_the_Spire)
- [Dead Cells Difficulty as Design - Medium](https://medium.com/@tunganh0806/difficulty-as-design-dead-cells-progressive-challenge-and-player-engagement-74f086064bf6)
- [Boss Stem Cell - Dead Cells Wiki](https://deadcells.fandom.com/wiki/Boss_Stem_Cell)
- [Artifacts - Risk of Rain 2 Wiki](https://riskofrain2.fandom.com/wiki/Artifacts)
- [Adjustable Difficulty - Cogmind](https://www.gridsagegames.com/blog/2017/02/adjustable-difficulty/)
- [Increasing Challenge in Roguelikes - Temple of the Roguelike](https://blog.roguetemple.com/articles/increasing-challenge-in-roguelikes/)
- [Roguelites Deconstructed - LinkedIn](https://www.linkedin.com/pulse/roguelites-deconstructed-svyatoslav-torick-oofgf)
- [How Modern Roguelikes Became More Accessible - Game Developer](https://www.gamedeveloper.com/design/how-modern-roguelikes-are-becoming-more-accessible)
- [Celeste Assist Mode - Game Developer](https://www.gamedeveloper.com/design/check-out-i-celeste-s-i-remarkably-granular-assist-options)
- [Celeste Assist Mode - Celeste Wiki](https://celeste.ink/wiki/Assist_Mode)
- [Celeste Accessibility - Game Accessibility Guidelines](https://gameaccessibilityguidelines.com/celeste-assist-mode/)
- [Roguelike - Wikipedia (Daily Challenges)](https://en.wikipedia.org/wiki/Roguelike)

---

*Research completed: 2026-02-02*
*Supports: GoDig-implement-challenge-run-72cff3dc*
