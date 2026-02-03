# Skill Tree and Specialization Depth in Progression Games

## Executive Summary

This research examines how games create meaningful build diversity without overwhelming new players. The key insight: **progressive revelation beats upfront complexity**. The best systems gate complexity behind unlocks, provide cheap respec options, and ensure no choice is obviously "wrong." Hades' Mirror of Night represents the gold standard for elegant progression.

## Case Studies

### Path of Exile - Complexity Extreme

**Scale:**
- 1000+ passive nodes across one massive shared tree
- All classes use same tree but start in different positions
- 99 passive points from levels + 23-24 from quests
- 20 refund points from quests for mistake correction

**Player Experience:**
> "When you first start playing Path of Exile and open the Passive Skill Tree, you might feel pretty overwhelmed."

**Managing Complexity:**

| Technique | Implementation |
|-----------|----------------|
| Zoom function | Focus on local area, not whole tree |
| Cluster organization | "Suburbs" (stat clusters) connected by "roads" (attribute paths) |
| Notable focus | Guide new players to key nodes, ignore the rest |
| Refund points | Allow fixing small-medium mistakes |

**Key Lesson:** PoE succeeds despite complexity by targeting hardcore players who enjoy theorycraft. Not appropriate for casual/mobile audiences.

### Hades Mirror of Night - Elegant Simplicity

**Why It Works:**
> "Hades circumnavigates this problem by presenting a linear selection of upgrades - go down the Mirror and buy them when you can. It doesn't overwhelm you with options straight away."

**Design Principles:**

1. **Linear Progression:** Upgrades presented top-to-bottom, not as a branching tree
2. **Key-Gated Unlocks:** Future upgrades locked behind collectible keys
3. **Cheap Respec:** Reset entire mirror for a few keys (easy to obtain)
4. **Binary Choices:** Each slot has two versions (red/green) unlocked after 300 Darkness

**Unlock Pacing:**
- 65 keys to unlock all upgrades (accumulated over many runs)
- Alternate versions unlock after story conversation with Nyx
- Total Darkness for max: 35,365 (gradual accumulation)

**Key Lesson:**
> "I buy what I can when I can and I slowly and surely get better - it's a perfect roguelite progression system."

### Diablo 4 Paragon Boards - Late-Game Depth

**When It Unlocks:**
- Post-campaign (after Level 60)
- Designed for endgame, not new players
- Cap of 328 points (not infinite like D3)

**Complexity Layers:**

| Node Type | Purpose |
|-----------|---------|
| Normal | Basic stats (foundation) |
| Magical | Enhanced stats |
| Rare | 6 per board, significant buffs |
| Legendary | 1 per board, build-defining |
| Glyph Socket | Most complex, scales with level |

**Board Connection System:**
- 8 distinct boards per class
- Connect boards together for combined benefits
- Strategic pathing minimizes point waste

**Glyph Complexity:**
- Radius 3 at base, increases to 5 at Level 46
- Affect/affected by nodes within radius
- Prerequisites for secondary bonuses

**Key Lesson:** Paragon shows how to add depth for veterans without burdening new players - separate system that only matters at endgame.

### Vampire Survivors - Maximally Simple

**System Design:**
- 24 permanent PowerUps purchasable with gold
- All apply to all characters automatically
- No tree structure - just a list
- Additive stacking (simple math)

**Pricing:**
- Each purchase increases next by 10% of base
- Refund button returns all gold (minus negligible amount)
- Order doesn't matter (since v0.7.2)

**Why It Works:**
> "While a lot of the progression in Vampire Survivors is about you learning the interactions between weapons and items and how they evolve, you can gain some pretty sizeable buffs thanks to the PowerUps."

**Key Lesson:** Not every game needs a skill tree. A simple list of buyable upgrades can provide meaningful progression if the core gameplay is compelling.

## Respec Economics

### Two Schools of Thought

**Liberal Respec (Borderlands, Hades):**
- Cheap, accessible, infinite respec
- Encourages experimentation
- Risk: undermines player commitment to build identity

**Strict Respec (Path of Exile, classic RPGs):**
- Limited or expensive respec
- Choices have weight
- Risk: punishes new players who make mistakes

### Best Practice for Mobile/Casual

> "In most cases, allow full Respec of a Skill Tree, at a high-cost for the player. It will allow corrections without watering-down your system."

**Recommended Approach:**
- Free respec during early game (learning phase)
- Increasing cost later (commitment phase)
- Never fully locked (respect player time)

## Progressive Disclosure Patterns

### Gating Techniques

| Technique | Effect |
|-----------|--------|
| Level gates | Basic nodes early, advanced later |
| Currency gates | Must play to unlock (Hades keys) |
| Story gates | Tied to narrative progression |
| Achievement gates | Unlock by demonstrating mastery |

### Reducing Choice Paralysis

> "If there's too many to pick from, choice paralysis sets in. It's like shopping for soap - being faced with 36 different choices stops you in your tracks."

**Solutions:**
- Limit initial choices to 3-5 options
- Expand choices as player demonstrates understanding
- Provide clear "recommended" paths
- Show one branch at a time, not entire tree

## Mobile-Specific Considerations

### Session Length Impact
Mobile players have shorter sessions. Skill tree decisions should:
- Be quick to make (not require spreadsheets)
- Have clear visual feedback
- Not require external research to understand

### Touch Interface
- Large, tappable nodes
- Clear connection lines
- Zoom/pan for larger trees
- Preview before confirmation

### Monetization Opportunities
> "Skill trees boost player retention, add depth, and support monetization without alienating free players."

**Ethical approaches:**
- Sell respec tokens (convenience, not power)
- Cosmetic node skins
- XP boosters (faster unlock, same power)

**Avoid:**
- Pay-to-unlock exclusive nodes
- Power nodes behind paywall
- Respec as premium-only feature

## Design Recommendations for GoDig

### Phase 1: Simple Upgrade Tiers

Start with linear upgrades (no branching):

```
Pickaxe: Level 1 → Level 2 → Level 3 → Level 4 → Level 5
Health:  Level 1 → Level 2 → Level 3 → Level 4 → Level 5
Carry:   Level 1 → Level 2 → Level 3 → Level 4 → Level 5
```

**Why:** New players understand "higher number = better"

### Phase 2: Sidegrade Branches (Late-Game)

After max tier, offer sidegrades:

```
Pickaxe Level 5 branches into:
  - Mining Mastery: +damage, slower speed
  - Speed Mining: +speed, same damage
  - Lucky Strikes: +rare ore chance

Can only have one active. Switch costs gold.
```

**Why:** Creates build identity without early-game confusion

### Phase 3: Specialization Trees (Post-Launch)

If player data shows demand for depth:

```
Miner Specializations:
  - Prospector: Ore detection, value bonuses
  - Demolition: Wide mining, cave discovery
  - Survivalist: Health, fall resistance, ladder efficiency
```

**Implementation:**
- Unlock after reaching certain depth milestone
- Free respec first time, costs increase
- Visual indicator showing current spec
- Max 3-5 nodes per tree

### Anti-Patterns to Avoid

| Don't | Why |
|-------|-----|
| Show full tree to new players | Choice paralysis |
| Lock respec behind premium | Punishes experimentation |
| Make one path clearly optimal | Kills build diversity |
| Require math to compare options | Cognitive overload |
| Deep trees early in game life | Add complexity later based on data |

## Balance Principles

### Meaningful Choice Criteria

> "An interesting choice is a set of options that are different, balanced, clear, and limited."

For each upgrade choice, verify:
1. **Different:** Options do meaningfully different things
2. **Balanced:** No option is strictly superior
3. **Clear:** Player understands what they're getting
4. **Limited:** 2-4 options, not 10+

### Sidegrades vs Upgrades

| Type | Best For |
|------|----------|
| Upgrades | Early game, obvious progression |
| Sidegrades | Late game, build identity |
| Hybrid | Mid-game transition |

### Power Curve Considerations

- Early upgrades should feel impactful (big % gains)
- Late upgrades add refinement (smaller % gains)
- Sidegrades trade one benefit for another (no net power increase)

## Sources

- [Path of Exile Passive Skill Tree](https://www.pathofexile.com/passive-skill-tree)
- [Beginner Guide to Path of Exile: Learning the Passive Tree](https://www.poe-vault.com/guides/path-of-exile-beginner-guide-learning-the-passive-tree)
- [Hades' Mirror Of Night Does Upgrades Right](https://www.thegamer.com/hades-mirror-of-night-roguelite-progression/)
- [Mirror of Night - Hades Wiki](https://hades.fandom.com/wiki/Mirror_of_Night)
- [Paragon Board Selection and Pathing in Diablo 4](https://maxroll.gg/d4/resources/paragon-board-selection-and-pathing)
- [Diablo 4 Paragon Board explained](https://www.pcgamer.com/diablo-4-paragon-board/)
- [PowerUps - Vampire Survivors Wiki](https://vampire-survivors.fandom.com/wiki/PowerUps)
- [Skill Tree Design: Ultimate Guide for Freemium Games](https://adriancrook.com/skill-tree-design-ultimate-guide-for-freemium-games/)
- [Progression Systems in Mobile Games](https://www.blog.udonis.co/mobile-marketing/mobile-games/progression-systems)
- [Keys to Meaningful Skill Trees](https://gdkeys.com/keys-to-meaningful-skill-trees/)

## Research Session

- **Date:** 2026-02-02
- **Focus:** Creating build diversity without overwhelming new players
- **Key Insight:** Progressive revelation beats upfront complexity - gate complexity behind unlocks, provide cheap respec, ensure no choice is obviously wrong
