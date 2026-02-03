# Retreat Mechanics and Resource Preservation in Roguelites

> Research on how successful roguelites handle player retreat and cargo preservation.
> Last updated: 2026-02-02 (Session 26)

## Executive Summary

The best roguelites create a **tiered outcome system** where smart players preserve more than reckless ones. Death should sting but not devastate. The key insight: **players tolerate loss better when they feel they had agency** over the outcome.

---

## 1. Loop Hero's Retreat Percentage System

Loop Hero pioneered a clear, tiered resource preservation system:

### Three Outcomes

| Action | Resources Kept | Condition |
|--------|----------------|-----------|
| Safe Retreat | 100% | Return to campfire tile |
| Panic Retreat | 60% | Retreat mid-loop |
| Death | 30% | Die anywhere |

### Design Rationale

> "The last thing you want to do is die and lose 70% of resources you may have spent 30 minutes gathering."

This creates a **risk/reward calculation** players engage with constantly:
- "Am I strong enough for another loop?"
- "Should I retreat now with 100% or push for more?"
- "Is the boss worth the risk?"

### Recovery Option

If players die, they can use "Orbs of Immortality" to return with 100% instead of 30%. This provides:
- A safety valve for frustrating deaths
- Meaningful resource sink
- Player choice over punishment severity

### GoDig Application

A similar tiered system could work:
- **Surface Return**: 100% resources kept
- **Emergency Rescue**: 60% resources kept (ladder/rope cost)
- **Death**: 30% resources kept

---

## 2. Hades' Multi-Currency Preservation

### Six Currency Types, Different Persistence

| Currency | Persistence | Purpose |
|----------|-------------|---------|
| Obols (Gold) | Lost on death | In-run purchases |
| Darkness | Kept always | Permanent upgrades |
| Gemstones | Kept always | Base customization |
| Keys | Kept always | Unlocks |
| Nectar | Kept always | Relationship building |
| Diamonds/Ambrosia | Kept always | End-game progression |

### Key Insight

> "You never truly start from scratch in Hades because of your growing strength between each run."

The genius is **splitting currencies** so that:
- In-run resources (gold) create tension
- Meta resources (everything else) ensure progress
- Death is a setback, not a reset

### Narrative Integration

Death returns players to the House of Hades where:
- Story progresses (new dialogue)
- Relationships develop
- Permanent upgrades await

> "Hades rewards death in a lot of ways, and that makes it very addicting and cuts down on the frustration."

### GoDig Application

Consider splitting resources:
- **Ores** (in-run, lost on death unless returned)
- **Meta currency** (earned per run, always kept)
- **Achievements/unlocks** (permanent)

---

## 3. Dead Cells' Cells and Recovery

### The Cells System

Cells are a special currency:
- Collected from defeated enemies
- Can only be spent at end of dungeon section
- **Lost completely if player dies before reaching checkpoint**

This creates intense "almost there" tension near checkpoints.

### Rally System (Health Recovery)

When taking damage:
1. 80% of lost health turns orange
2. Orange bar shrinks over 0.08 seconds
3. Dealing damage recovers up to 12% of damage dealt
4. Each hit capped at 20% of original loss

**Purpose**: Encourages aggressive play after taking damage. "Fight back or lose it."

### One-Hit Protection

If health is above 25% and a hit would kill:
- Player drops to 1 HP instead
- Nearby enemies stunned for 1 second
- 45-second cooldown (or full heal)

**Purpose**: Prevents "gotcha" deaths while maintaining tension.

### GoDig Application

- **Rally equivalent**: Digging blocks when low health could restore small HP
- **One-hit protection**: Prevents instant death from fall damage at high HP
- **Checkpoint tension**: Reaching surface saves resources

---

## 4. The Psychology of Partial Loss

### Why Partial Loss Works Better Than Full Loss

From roguelike design research:

1. **Sense of progress preserved**
   - "At least I got something from that run"
   - Forward momentum maintained
   - Reduces frustration-quit risk

2. **Player responsibility emphasized**
   - "If I had retreated earlier..."
   - Agency over outcome
   - Learning opportunity, not punishment

3. **Meaningful decisions created**
   - Risk/reward calculations every run
   - Retreat timing becomes skill
   - Mastery beyond combat

### Why Full Preservation (No Loss) Fails

Without loss:
- No tension in exploration
- No consequence for poor decisions
- "Push luck" mechanic disappears
- Sessions feel low-stakes

### The 30% Floor

Loop Hero's 30% death retention is strategic:
- Prevents total devastation
- Always some progress
- Reduces rage-quit likelihood
- Long runs still feel partially productive

---

## 5. Trade-Off Mechanics for Fairness

### The Clear Bargain Principle

From roguelite analysis:
> "Offering a clear penalty in addition to a clearly described bonus. Everything's fair, everything's clear."

Examples:
- "You'll hit harder, but can't dash"
- "Survive a lethal hit, but max HP decreases by 25%"
- "Emergency rescue available, but costs 40% of resources"

### GoDig Application

Trade-offs could include:
- **Emergency Beacon**: Return to surface instantly, lose 40% resources
- **Insurance Upgrade**: Death only loses 50% instead of 70%
- **Risk vs Depth**: Deeper = better ore, but farther from safety

---

## 6. Mining-Specific Considerations

### Deep Rock Galactic Approach

- Dying = missing out on survival bonus, not losing collected resources
- Team extraction rewards those who survive
- Resources collected are kept if mission completes
- Failure = lost time, not lost materials

### The Extraction Tension

> "Once the objective is completed, players must backtrack through the cave to an escape pod in order to safely exit along with all collected resources."

The **return trip is the risk**. This matches GoDig's core loop.

### Dome Keeper Pattern

In Dome Keeper:
- Mining is relatively safe
- Tension comes from defense timing
- Resources have value during run (upgrades)
- Death = run ends, but meta-progress persists

---

## 7. GoDig Retreat System Recommendations

### Recommended Tier System

| Outcome | Resources Kept | How |
|---------|----------------|-----|
| Safe Return | 100% | Walk to surface |
| Ladder Rescue | 80% | Use emergency ladder from inventory |
| Beacon Rescue | 60% | Purchasable emergency item |
| Death | 40% | Fall damage, getting stuck with no escape |

### Why 40% on Death (Not 30%)

GoDig sessions are shorter than Loop Hero. 40% ensures:
- Runs feel productive
- Death stings but doesn't devastate
- Early players aren't brutalized
- Tension remains meaningful

### Rescue System Design

**Emergency Ladder** (Inventory Item):
- Always available in shop
- Costs moderate resources
- Use when stuck or about to die
- Preserves 80% of collected resources

**Rescue Beacon** (Permanent Upgrade):
- Unlocked through meta-progression
- Limited uses per run (recharges at surface)
- Teleports to surface
- Preserves 60% (worse than ladder, but faster)

### Warning Before Death

Follow Dead Cells' one-hit protection pattern:
- If fall damage would kill, reduce to 1 HP instead (once per run)
- Visual/audio warning when health critical
- Give player chance to use rescue items

### Progressive Unlock

Early game (first 3-5 runs):
- More generous preservation (60% on death)
- Extra rescue items in shop
- Teaches system without frustration

Late game:
- Standard 40% on death
- Rescue items cost more
- Skill-based preservation expected

---

## 8. Key Design Principles

### Do This

1. **Tier outcomes** - Multiple preservation levels based on player choice
2. **Warn before death** - One-hit protection, visual indicators
3. **Provide rescue options** - Items/abilities to escape danger
4. **Preserve some always** - Never 0% (except rage-quit uninstall risk)
5. **Make agency clear** - Player understands why they lost X%

### Avoid This

1. **Gotcha deaths** - Instant death from invisible hazards
2. **100% loss** - Devastating, especially early game
3. **100% preservation** - Removes tension entirely
4. **Unclear rules** - Player confused about what they'll lose
5. **Punishing new players** - Early runs should be forgiving

---

## Sources

- [Loop Hero When to Retreat Guide (Slythergames)](https://www.slythergames.com/2021/03/12/loop-hero-when-to-retreat-guide/)
- [Loop Hero What Happens When You Die (Slythergames)](https://www.slythergames.com/2021/03/11/loop-hero-what-happens-when-you-die/)
- [Hades Roguelite Formula (Lords of Gaming)](https://lordsofgaming.net/2021/08/desiring-death-how-hades-changes-the-roguelike-formula/)
- [Dead Cells Mechanics (Dead Cells Wiki)](https://deadcells.wiki.gg/wiki/Mechanics)
- [Death in Gaming: Roguelikes (Gamedeveloper)](https://www.gamedeveloper.com/design/death-in-gaming-roguelikes-and-quot-rogue-legacy-quot-)
- [Roguelites Deconstructed (LinkedIn)](https://www.linkedin.com/pulse/roguelites-deconstructed-svyatoslav-torick-oofgf)
- [Permadeath Psychology (Sidequest)](https://sidequest.zone/2021/11/22/death-is-only-the-beginning-mortality-in-the-roguelike/)
- [Deep Rock Galactic Death Penalty (Steam)](https://steamcommunity.com/app/548430/discussions/1/1744512449572914510/)

---

## Key Takeaways for GoDig

1. **Tiered outcomes**: 100% (safe return) → 80% (ladder) → 60% (beacon) → 40% (death)
2. **Player agency**: Retreat timing is a skill, not just luck
3. **Warning systems**: One-hit protection, critical health indicators
4. **Rescue items**: Purchasable ways to preserve more resources
5. **Early forgiveness**: First runs should be gentler
6. **Never 0%**: Always preserve something to maintain motivation
