# Prestige System Psychology Research

## Overview

Deep dive into prestige/rebirth systems in idle and roguelite games. Understanding when players WANT to prestige versus feeling forced, and how to design permanent bonuses that feel worth the reset.

## Core Mechanics

### What Is Prestige?

A prestige system allows players to reset progress in exchange for permanent bonuses that accelerate future runs. Originally popularized by Cookie Clicker (2013), it's now a crucial mechanic in most modern idle games.

**Two Primary Purposes:**
1. Creates "ladder climbing" effect that makes idle games compelling
2. Reins growth back to manageable numbers (prevents exponential inflation)

### The Psychological Loop

```
Slow Progress → Prestige Decision → Reset with Bonuses →
Fast Early Progress → Reach Previous Point Faster →
Push Further → Slow Progress → Prestige Again
```

The key insight: **After a prestige reset, previously time-consuming stages can be cleared much faster, giving players a renewed sense of progress and empowerment.**

## Player Psychology: WANT vs. FORCED

### When Players WANT to Prestige

**Positive Triggers:**
- Clear mathematical benefit visible (2x multiplier preview)
- Satisfying milestone reached (round number, boss defeated)
- New content promised after prestige
- Player agency in timing decision
- "Power fantasy" of starting strong

**The feeling:** "I'm making a strategic decision that will make me more powerful."

### When Prestige Feels FORCED

**Negative Triggers:**
- Hard walls with no alternative
- Progress becomes impossibly slow
- No meaningful choice in timing
- Early-game grind walls before tools established
- Unclear benefit from resetting

**The feeling:** "The game is making me waste my time."

> "That type of grind wall might be acceptable for people on their 20th or 30th rewind, when they have the tools and enjoyment of the game well established. It is really poor design to hit a new player with that grind wall." - Steam Community Discussion

## Case Studies

### Cookie Clicker (The Original)

**Prestige Currency:** Heavenly Chips + Prestige Levels
**Formula:** Cube root of cookies baked (trillions)

**What You Keep:**
- Heavenly Chips (currency for permanent upgrades)
- Prestige Level (+1% CpS per level, stacking)
- All purchased Heavenly Upgrades

**What Resets:**
- Cookies, buildings, regular upgrades

**First Prestige Timing:**
- Community recommends: 400-1000 prestige levels
- Unlocks at: 1 trillion cookies baked
- Typical timing: Several hours to first prestige

**Key Upgrades:**
- Legacy (1 chip) - Enables prestige bonus
- Heavenly Cookies (3 chips) - +10% permanent multiplier
- Permanent Upgrade Slot (100 chips) - Carry one upgrade through resets

**Design Wisdom:** Anti-abuse design requires at least 1 prestige level gained to count toward achievements.

### Adventure Capitalist

**Prestige Currency:** Angel Investors
**Multiplier:** +2% per Angel (multiplicative)

**Optimal Timing Rule:** "Prestige when you can double your Angels"

**Design Innovation:**
- MegaBucks as secondary prestige currency
- Golden Tickets for permanent business boosts
- Multiple worlds (Earth, Moon, Mars) each with own prestige

### Realm Grinder (Multi-Layer Mastery)

**Multiple Prestige Layers:**
1. **Abdication** - Basic reset for gems
2. **Reincarnation** - Resets abdications for permanent bonuses
3. **Ascension** - Meta-layer that gates new content

**Reincarnation Bonuses:**
- Reincarnation # × 25% production increase
- Reincarnation # × 500% offline production

**Content Unlocks by Reincarnation:**
- R16: Research system
- R40+: Ascension 1
- R100+: New Alignments (Order, Chaos, Balance)
- R240+: Legacy System

**Scaling:** Each reincarnation requires 1000× more gems than previous

### Tap Titans 2

**Prestige Currency:** Relics (for Artifacts)
**Unlock Point:** Stage 600

**What You Keep:**
- Relics, Artifacts, Weapon upgrades
- Diamonds, Equipment, Pets, Perks

**What Resets:**
- Stage progress (back to Stage 1)
- Gold, Hero levels, Skills

**Relic Calculation:**
- Hero levels bonus (1 relic per 1000 hero levels)
- Stage bonus (increases every 15 stages)
- Full team alive bonus (+1 multiplier)

### Hades (Roguelite Model)

**Different Philosophy:** Meta-progression without explicit "prestige"

**Permanent Unlocks:**
- Mirror of Night upgrades (Darkness currency)
- Weapon aspects and modifications
- Contractor upgrades
- Relationship progression
- Keepsakes and companions

**Design Philosophy:**
> "You should never feel like you just wasted your whole run for nothing."

**Post-Completion:** Pact of Punishment allows player-controlled difficulty increase (reverse meta-progression)

## Optimal First Prestige Timing

### By Game Type

| Game Type | First Prestige Timing | Hours to First |
|-----------|----------------------|----------------|
| Cookie Clicker | 400-1000 prestige levels | 2-6 hours |
| Adventure Capitalist | When can double Angels | 1-3 hours |
| Tap Titans 2 | Stage 600+ | 30min-2 hours |
| Revolution Idle | Every 5-15 min early game | Minutes |
| Clicker Heroes | Level 120+ | <1 hour |

### General Guidelines

**Early Game (First 1-3 Prestiges):**
- Short runs to establish the mechanic
- Minimal investment before first reset
- Clear tutorial on what carries over

**Mid Game:**
- Prestige when progress slows significantly
- Rule of thumb: "Two quick 2x rebirths beat one slow 4x rebirth"
- Watch for diminishing returns

**Late Game:**
- Aim to at least double multiplier each prestige
- Prestige timing becomes optimization puzzle
- Multiple prestige layers may unlock

### Warning Signs (Time to Prestige)

1. Upgrade costs grow faster than gains
2. Multiplier growth flattens
3. Next upgrade is unaffordable for several minutes
4. Each stage takes much more effort than previous

## What to Keep vs. Reset

### Preserve Meaningful Progress

**Always Keep:**
- Currencies earned from prestige
- Permanent upgrades purchased
- Unlocked content/features
- Achievement progress
- Collection items

**Consider Keeping:**
- Partial resource carry-over
- Unlocked QoL features
- Tutorial completion flags
- Statistics and records

**Always Reset:**
- Primary currency (gold, cookies, etc.)
- Temporary multipliers
- Level/stage progress
- Basic upgrades

### The Key Balance

> "Some games (like Clicker Heroes 1, Binding of Isaac, Enter the Gungeon) give you variants/unlocks, not explicit power-ups. Others (Cookie Clicker, Adventure Capitalist) give permanent multipliers."

**For GoDig:** Consider hybrid approach:
- Depth unlocks = Variants (new items, mechanics)
- Prestige bonuses = Multipliers (dig speed, ore value)

## Design Recommendations for GoDig

### When to Introduce Prestige

**Not Too Early:**
- Players need core loop established first
- First 10-20 hours should be about upgrades, not resets
- Build attachment before asking to give things up

**Not Too Late:**
- Introduce before progression hits hard wall
- Player should see "the point" of prestige before needing it
- Tease prestige bonuses before unlock

**Recommended:** Unlock prestige option after reaching ~500m depth (mid-game milestone)

### What Should Reset

**Full Reset:**
- Coins (primary currency)
- Current depth position
- Basic tool upgrades
- Current run ore collection

**Partial Reset:**
- Building unlocks (keep some, reset upgrades)
- Ladders/ropes (keep unlocks, reset quantity)

**Preserve:**
- Prestige currency earned
- Permanent dig speed bonuses
- Unlocked content (biomes, ore types)
- Achievements and records
- Cosmetics

### Prestige Bonuses for Mining Game

**Multiplier-Based:**
- +X% dig speed per prestige level
- +X% ore value per prestige level
- +X% carry capacity permanent bonus

**Unlock-Based:**
- New pickaxe types
- Special abilities (detect rare ore, etc.)
- Building upgrades
- Quality of life features

**Content-Based:**
- New biome variants
- Rare ore types only in prestige runs
- Challenge modifiers
- Story/lore progression

### First Prestige Timing for GoDig

**Target:** 2-4 hours of play

**Unlock Trigger:** Reach 500m depth for first time

**Initial Bonus Preview:** Show player what they'll earn before requiring prestige

**Soft Encouragement:**
- Progress slows naturally around 400-500m
- New content visible but gated behind prestige
- Clear preview of post-prestige benefits

### Avoiding Forced Feel

1. **Multiple Progression Paths:** Don't require prestige to continue playing
2. **Clear Benefit Display:** Always show prestige gain before reset
3. **Milestone Rewards:** Give bonuses for reaching depths, not just prestiging
4. **Player Agency:** Never force prestige, only encourage
5. **Content Gates, Not Walls:** New content unlocks with prestige, old content remains playable

## Sources

- [Kongregate - The Math of Idle Games Part III](https://blog.kongregate.com/the-math-of-idle-games-part-iii/)
- [GameAnalytics - Idle Game Mathematics](https://gameanalytics.com/blog/idle-game-mathematics/)
- [Cookie Clicker Wiki - Ascension](https://cookieclicker.fandom.com/wiki/Ascension)
- [Cookie Clicker Wiki - Ascension Guide](https://cookieclicker.wiki.gg/wiki/Ascension_guide)
- [Tap Titans Wiki - Prestige](https://tap-titans.fandom.com/wiki/Prestige)
- [Tap Guides - Tap Titans 2 Prestige Mastery](https://tap-guides.com/2025/10/24/tap-titans-2-mastery-prestige-max-relics/)
- [Realm Grinder Wiki - Reincarnation](https://realm-grinder.fandom.com/wiki/Reincarnation)
- [GameDev.net - Prestige Systems in Games](https://www.gamedev.net/forums/topic/685045-what-is-prestige-system-in-video-games-and-mobile/)
- [Wikipedia - Incremental Games](https://en.wikipedia.org/wiki/Incremental_game)
- [TV Tropes - Reset Milestones](https://tvtropes.org/pmwiki/pmwiki.php/Main/ResetMilestones)
- [Quora - When to Prestige in Idle Games](https://www.quora.com/When-should-you-prestige-in-idle-games-immediately-or-wait-a-little-while)
- [Game Rant - Roguelite Progression Systems](https://gamerant.com/roguelite-games-with-best-progression-systems/)

## Related Implementation Tasks

- `implement: Prestige system` - PrestigeManager exists in autoload, needs full implementation
- `implement: Challenge run modifier system (v1.1)` - Can integrate with prestige unlocks
- `implement: Sidegrade upgrade system` - Post-prestige variety vs pure power
