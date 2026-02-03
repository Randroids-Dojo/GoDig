---
title: "research: Roguelite sidegrade systems - Binding of Isaac, Enter the Gungeon patterns"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-02T18:55:36.215106-06:00\\\"\""
closed-at: "2026-02-02T18:57:27.121618-06:00"
close-reason: "Completed: Isaac pool expansion, Gungeon sidegrade philosophy, Hades Heat system. Recommendations for v1.1 horizontal progression."
---

## Purpose
Analyze successful roguelite games that emphasize OPTIONS over POWER in their progression systems.

## Background
From Session 28/29 research:
- Sidegrade = expand options, not raw stats
- Quote: 'Unlock alternate equipment/starting loadouts rather than pure stat increases'
- Avoids 'treadmill feeling - power matched by difficulty'
- Promotes strategic thinking and player expression

## Games to Analyze
1. **Binding of Isaac** - Item pool expansion, unlock new items/characters
2. **Enter the Gungeon** - Weapon variety, alternate paths
3. **Slay the Spire** - Card unlocks expand deck options
4. **Hades** - Heat system for optional difficulty

## Research Questions
1. How do these games keep early game fresh after many runs?
2. What ratio of sidegrades to stat upgrades works best?
3. How do they prevent 'useless unlock' feeling?
4. How does unlock pacing affect player engagement?

## Expected Outputs
- Sidegrade design patterns for GoDig late-game
- Recommendations for v1.1 horizontal progression

## Research Findings

### Binding of Isaac: Item Pool Expansion System

**How It Works:**
- Each item pool has weighted items (most have weight of 1)
- "Super" items decrease chance of getting other super items in same run
- Unlocks ADD to pool rather than replacing existing items
- D6 allows rerolling items - adds player agency to RNG

**Pool Bloat Problem:**
- Expansions added so many items that new unlocks rarely appear
- "It could take a while to see any new stuff pop up"
- Mitigation: Special items have separate pools

**Key Insight:**
- Unlocking gradually prevents overwhelm
- As you master original items, new ones keep it fresh

### Enter the Gungeon: Sidegrade Philosophy

**Core Design Decision:**
- "Lack of permanent stat upgrades is NOT an oversight, it's a deliberate design decision"
- Hegemony credits unlock new weapons/items that appear in item pool
- "Entirely possible to beat the game without unlocks"

**Why Sidegrades Work:**
- Quote: "Enter the Gungeon is really fun because it constantly adds new items and weapons that totally change up the game, rather than simply making the player stronger"
- Smaller pool than Isaac = higher chance unlocks actually appear
- Each unlock has "greater average chance of appearing and replacing starter pool"

**Player Preference Split:**
- Some players prefer this over Rogue Legacy's stat-based progression
- Others bounce off it specifically BECAUSE no power growth
- Appeals to different player types than direct power progression

### Hades: Heat System - Optional Difficulty

**How Heat Works:**
- Unlocked after first successful escape
- Modifiers add Heat points, each with multiple ranks
- Example: Hard Labor (+20%/+40%/+60% enemy damage)
- Players customize WHICH modifiers to use

**Rewards Structure:**
- Each Heat level unlocks treasures
- Statue unlocks at 8, 16, 32 Heat (cosmetic)
- "Good way to gently push player into increasing challenge"
- "Not expected to play at that level repeatedly - entirely optional"

**Design Philosophy:**
- "Being able to craft a system where you yourself can define what areas are more or less difficult is closer to balanced and well-paced difficulty than any other studio"
- Prevents staleness without forcing difficulty increase

### How These Games Keep Early Game Fresh

1. **Unlock Pacing**: Items unlocked gradually, not all at once
2. **Early Decisions Matter**: "An item you picked up at the very start should still matter by the final boss" (Slay the Spire)
3. **Character Variety**: Different starting conditions change early game completely
4. **Pool Expansion**: New items appear in familiar contexts, creating discovery moments
5. **Build Diversity**: Same early game, different mid/late game based on finds

### Sidegrade vs Power Upgrade Ratio

**Pure Sidegrade Games** (Gungeon, Slay the Spire):
- No permanent stat increases
- All "progress" is skill-based or expands options
- Appeals to mastery-focused players

**Hybrid Games** (Isaac, Hades):
- Some stat unlocks (Hades Mirror)
- But majority is options/variety
- Broader appeal, controversial with purists

**Recommendation for GoDig:**
- Core progression (pickaxe tiers) = vertical power (already exists)
- Late-game/v1.1 = sidegrades (new item types, starting loadouts)
- Consider: Unlockable starting items, alternate inventory layouts, challenge modifiers

### Preventing "Useless Unlock" Feeling

1. **Smaller, Curated Pools**: Gungeon has fewer items than Isaac = higher appearance rate
2. **Direct Achievement Links**: "Complete X to unlock Y" feels earned
3. **Category-Based Unlocks**: New characters vs new items vs new modes
4. **Immediate Usability**: Unlocks that can be used immediately in next run

### GoDig Application: v1.1 Horizontal Progression

**Recommended Sidegrade Categories:**

| Category | Examples | Purpose |
|----------|----------|---------|
| Starting Items | 3 starting ladders vs rope vs jetpack fuel | Changes early strategy |
| Inventory Layouts | Standard vs Deep Pockets vs Specialized | Playstyle expression |
| Challenge Modifiers | No ladders, fast descent, timer | Mastery content |
| Cosmetics | Pickaxe skins, player skins | Pure expression |
| Alternate Ores | Unlock rare ore types that appear | Discovery moments |

**Design Principles:**
1. Core game beatable without any unlocks
2. Unlocks change HOW you play, not power level
3. Smaller unlock pools = each feels impactful
4. Clear unlock conditions (beat Layer X with Y)
5. Some unlocks are purely optional difficulty (Heat-style)
