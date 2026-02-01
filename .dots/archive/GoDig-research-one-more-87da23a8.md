---
title: "research: One-more-run psychology - what triggers the restart urge"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-01T01:46:36.353944-06:00\\\"\""
closed-at: "2026-02-01T01:49:50.234705-06:00"
close-reason: "Completed research on one-more-run psychology. Created 3 implementation dots: progress-to-upgrade display, quick-dive button, depth record tracking. Updated dot file with detailed findings from Hades, roguelites, and Dead Cells research."
---

Deep dive into what makes players immediately want another run after returning to surface. Compare Motherload (5-hour sessions), roguelikes (Hades, Rogue Legacy), and Dome Keeper. Document specific mechanics that trigger the 'just one more' urge.

## Research Findings

### Core Triggers for "One More Run"

#### 1. Quick Restart Speed
- "In roguelikes, you can die and restart in a matter of seconds"
- Dead Cells pattern: death -> respawn at hub -> immediate dive option
- **GoDig Application**: Surface arrival should immediately enable next dive. Don't force long shop visits.

#### 2. Death = Progress, Not Punishment
- Hades: "making me slightly excited about dying"
- Every death advances story, unlocks upgrades, deepens relationships
- **GoDig Application**: Even failed trips should progress something (depth achievements, ore discovery stats, relationship with shop NPCs?)

#### 3. Meta-Progression ("Getting Stronger")
- Rogue Legacy: "injected character-building power fantasy"
- "Even when you die, you're building towards permanent upgrades"
- **GoDig Application**: Pickaxe upgrades, backpack capacity, permanent unlocks give sense of forward momentum

#### 4. Visible Progress Toward Goals
- Hades: "drip feeding story makes me genuinely excited to keep playing"
- Clear display of what you're working toward
- **GoDig Application**: Show next upgrade cost and progress toward it. "250/500 coins to Copper Pickaxe"

#### 5. Reduced Sting of Loss
- "Removing the pressure of losing it all makes for a less daunting experience"
- Dead Cells: carry certain upgrades, new runs don't sting
- **GoDig Application**: Forfeit Cargo option lets players escape without total loss. Keep ladders/tools.

#### 6. Variety and Randomization
- "Sheer variety keeps each run feeling fresh"
- Procedural generation means new discoveries possible
- **GoDig Application**: Ore placement should vary. Occasional surprise caves or bonus areas.

#### 7. Quick Run Lengths
- "Runs are pretty quick... easy to justify 'just one more'"
- 5-15 minute sessions ideal
- **GoDig Application**: Inventory size controls session length. 8 slots = ~5-8 minute trips.

### The "Itch" Moment
Players describe the experience as suffering from that "just one more run itch that's so common in roguelikes." This happens when:
1. Run ended at an interesting moment (almost got that diamond)
2. Player can see they're close to an upgrade
3. New ability/tool just unlocked and player wants to try it
4. Curiosity about what's deeper

### Motherload Specifically
- "True fear when low on fuel flying up to the surface"
- 5-hour sessions from "awesome blend of obsessive compulsive profiteering"
- The tension of near-escape creates memorable moments
- **GoDig Application**: Low ladder warning creates same tension. Near-escapes should be celebrated.

### Dome Keeper Pattern
- Wave timer creates urgency to return
- Each return is a relief, but also setup for next dive
- "Do you risk digging deeper for that juicy cobalt vein?"
- **GoDig Application**: No external timer, but inventory pressure serves similar purpose.

## Implementation Recommendations

Based on this research, create the following implementation dots:

### 1. Progress Display on Surface (P1)
Show current coin balance + next upgrade cost prominently when at surface.
"250/500 - Copper Pickaxe"

### 2. Quick-Dive Button (P2)
After selling, show "Dive Again" button that skips shop browsing if player is ready.

### 3. Near-Miss Celebration (P2)
When player returns with inventory 80%+ full or narrowly escapes (1 ladder left), celebrate the success.

### 4. Depth Record Tracking (P2)
Display personal depth record. "Deepest: 125m" creates goal to beat.

### 5. "Almost There" Teaser (P3)
When player is close to affording upgrade, show encouraging message: "Just 50 more coins!"

## Sources
- [Hades Design Philosophy - Vicious Undertow](https://viciousundertow.wordpress.com/2018/12/31/hades-and-incentivizing-death/)
- [Meta Progression in Roguelikes - Hamatti](https://notes.hamatti.org/gaming/video-games/meta-progression-with-gradual-tutorial-in-roguelike-games)
- [Roguelikes and Progression Systems - Indiecator](https://indiecator.org/2022/03/30/on-roguelikes-and-progression-systems/)
- [Best Roguelike Games - PCGamesN](https://www.pcgamesn.com/best-roguelike-games)
