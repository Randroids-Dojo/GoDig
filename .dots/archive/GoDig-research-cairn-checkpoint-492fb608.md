---
title: "research: Cairn checkpoint design - how pitons create player-defined safety"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-02T18:51:12.237265-06:00\\\"\""
closed-at: "2026-02-02T18:54:04.675618-06:00"
close-reason: "Completed: Cairn piton system analysis, recommendations for ladder checkpoint mechanic"
---

## Purpose
Analyze Cairn's piton placement system as a model for player-defined checkpointing.

## Background
From Session 31 research, Cairn uses:
- Manual piton placement creates player-defined checkpoints
- Falls reset to last piton, not start
- Stamina management creates risk around placement timing
- 200K+ copies in 4 days validates the approach

## Parallels to GoDig Ladders
- Ladders = player-defined safety points (like pitons)
- Limited resource = meaningful placement decisions
- Creates 'commit' moments - where to spend resource

## Research Questions
1. How does Cairn balance piton scarcity vs frustration?
2. What visual feedback exists for good/bad piton spots?
3. How does fall distance affect penalty?
4. What makes placement feel like player skill, not luck?

## Expected Outputs
- Best practices for player-defined checkpoint systems
- Visual feedback recommendations for ladder placement
- Potential 'partial return' mechanic using ladder positions

## Research Findings

### Cairn's Piton Mechanics

**Three-State Placement System:**
1. **Perfect placement** - Good anchor, piton reclaimed by climbot later
2. **Twisted placement** - Usable anchor but returns as ruined scrap (fixable at bivouac)
3. **Failed placement** - No anchor, piton destroyed, only get scrap back

**Skill-Based Mini-Game:**
- Hold Up on d-pad, then hit X at right moment as slider moves across bar
- Creates player skill expression in checkpoint placement
- Bad timing = worse outcomes, not just binary pass/fail

### How Cairn Balances Piton Scarcity

1. **Resource Recovery**: Climbot can make 1 piton from 2 sets of scraps - never truly "out"
2. **Different Piton Types**: Fragile pitons break after few falls, Troglodyte pitons are indestructible
3. **Rest Function**: Clipping into piton and pressing X for "off belay" fully restores stamina
4. **Strategic Value Variance**: Some spots NEED pitons (glossy rock can't accept them), others don't

### Visual Feedback for Good/Bad Spots

**Environmental Cues:**
- Gray, craggy rock = normal, can place pitons
- Smooth, glossy brown rock = too dense for pitons, dangerous
- Dirt falling when placing limb = bad handhold (even if looks good)
- Audio cues: Aava's breathing gets "fast and panicked" when in trouble

**Placement Feedback:**
- UI slider shows timing quality
- Audio/visual confirms perfect vs twisted vs failed
- "Flat" footing = stable, everything else drains stamina

### Fall Distance and Penalty

- Falls reset to last piton checkpoint, not start
- Piton durability matters - some break after multiple falls
- Progress loss is proportional to distance since last checkpoint
- Indestructible pitons are "game-changers for long climbs" - reduce mental load

### What Makes Placement Feel Like Skill

1. **Timing mini-game** - Player input determines outcome quality
2. **Strategic reading** - Must identify WHEN to place (before hard sections)
3. **Resource management** - Limited pitons means each decision matters
4. **Route planning** - Reading rock face to identify placement opportunities

**Developer Tip: Place Before:**
- Long run-outs where fall would lose tons of progress
- Tricky transitions (overhangs, wet rock, gusty ledges)
- Avoid placing on easy, low-risk sections

### Player Feedback Summary

**What Works:**
- "Very Positive" Steam reviews with 200K copies in 4 days
- "Liberation through Limitation" - constraints create satisfaction
- Audio cues more immediate than UI elements

**What Frustrates:**
- Auto-climb sometimes makes "weird choices" in limb selection
- Lack of explicit meters can feel directionless
- Learning curve for reading visual cues

## Application to GoDig Ladders

### Direct Parallels

| Cairn Mechanic | GoDig Equivalent |
|----------------|------------------|
| Piton placement | Ladder placement |
| Limited pitons | Limited ladders |
| Rest at piton | Safe climb spot on ladder |
| Fall resets to piton | Emergency rescue uses last ladder position? |

### Recommendations for GoDig

1. **Placement Feedback**: Show success/failure state when placing ladder (solid wall = good, crumbly = temporary?)

2. **Strategic Placement Value**: Not all spots equal - some paths harder to return on than others

3. **Resource Recovery Option**: Consider crafting mechanic (combine scrap → ladder) for mid-game

4. **Partial Return Mechanic**: If player has placed ladders, emergency rescue could return them to their HIGHEST ladder (not surface) - creates strategic ladder "checkpoint" system

5. **Audio/Visual Cues for Safety State**: Like Aava's breathing, player should FEEL when they're overcommitted (low ladder warning, heartbeat audio)

### Potential New Feature: Ladder Checkpoints

Instead of emergency rescue always returning to surface:
- Rescue returns player to their HIGHEST placed ladder
- Keeps 60% of inventory (Loop Hero model)
- Player must climb down from there (or use more rescue)
- Creates layered safety net: ladders = first checkpoint, surface = final safety
