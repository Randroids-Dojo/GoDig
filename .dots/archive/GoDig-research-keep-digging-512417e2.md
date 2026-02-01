---
title: "research: Keep Digging and ITER competitive differentiation"
status: closed
priority: 3
issue-type: task
created-at: "\"\\\"2026-02-01T09:08:53.738251-06:00\\\"\""
closed-at: "2026-02-01T09:24:40.006267-06:00"
close-reason: Completed competitive analysis - GoDig differentiates via push-your-luck tension vs cozy co-op and complexity
---

## Purpose

Deep analysis of our two newest competitors (Keep Digging Jan 2026, ITER 2025) to identify differentiation opportunities and potential borrowed mechanics.

## Keep Digging Analysis Questions

1. How does their 10-layer, 1000m depth progression feel?
2. What makes co-op mining work without our tension mechanics?
3. How do they handle the return trip without ladders?
4. What upgrade systems do they use (8 technology types)?
5. How does cross-progression (solo ↔ multiplayer) work?

## ITER Analysis Questions

1. How does 2D-to-3D dimension shifting affect mining feel?
2. What roguelite elements do they combine with mining?
3. How do "shifting dimensions" create tension?
4. What's their run length and loop structure?

## Competitive Positioning

| Feature | Keep Digging | ITER | GoDig |
|---------|--------------|------|-------|
| Core tension | Depth exploration | Dimensional shifts | Ladder economy |
| Multiplayer | 8-player co-op | Unknown | Single (v1.0) |
| Combat | None | Yes (survive) | Optional (v1.1) |
| Risk mechanic | Unknown | Dimension hazards | Resource depletion |
| Unique hook | Cozy co-op | 2D/3D puzzle | Push-your-luck |

## Research Tasks

- [x] Watch Keep Digging gameplay videos
- [x] Read Keep Digging Steam reviews for pain points
- [x] Watch ITER trailer/gameplay when available
- [x] Identify features we should adopt
- [x] Identify features that dilute our core identity (avoid)

## Research Findings (Session 20)

### Keep Digging Deep Analysis

**Steam Reviews Summary** (78% Mostly Positive, 938 reviews):
- Core loop praised: "relaxing satisfaction of digging, discovery, and upgrading"
- Co-op praised: Up to 8 players working together on same dig
- NPC companions for solo players who continue working offline
- Cross-progression: "loot found in friends' worlds can be brought back to your own"

**Pain Points Identified**:
- "Performance hiccups in co-op at deeper layers"
- "Lobby/matching quirks" - poor invite system
- "Optimization needed for procedural generation and underground visuals"
- Players note it's "heavily inspired by A Game About Digging A Hole" (derivative feel)

**Key Mechanics**:
- 1000m depth across 10 layers
- Equipment upgrades to level 20
- 8 types of upgradeable technologies
- No combat, no stealth - pure mining focus
- Procedurally generated environments

### GoDig Differentiation Analysis

| Aspect | Keep Digging | GoDig Advantage |
|--------|--------------|-----------------|
| Core tension | Relaxing, low-stakes | Push-your-luck ladder economy |
| Solo experience | NPC companions (idle) | Active skill expression |
| Return trip | Unknown (likely teleport/elevator) | Ladder decision-making |
| Session feel | Cozy grind | Tension + relief cycle |
| Unique hook | Co-op exploration | Risk/reward resource management |

### Features to Borrow (Enhance Our Core)

1. **Cross-progression concept**: If we add multiplayer v1.1, allow shared progress
2. **NPC companions for offline**: Could add Auto-Miner Station as existing spec
3. **Technology types**: Our upgrade categories could be clearer (Mining, Traversal, Storage, etc.)

### Features to AVOID (Dilute Our Identity)

1. **Pure relaxation**: Our tension is the differentiator - don't remove it
2. **Massive co-op**: 8 players would overwhelm our push-your-luck mechanics
3. **No meaningful risk**: Keep Digging has no tension - that's their niche, not ours

### ITER Analysis (Limited Info)

- 2D-to-3D dimension shifting for puzzles
- Mining roguelite with tower defense elements
- Warsaw-based 2-person studio
- Focus on "extracting resources to enhance capabilities"
- Roguelite meta-progression: "replacement operative picks up where you left"

**GoDig vs ITER**: ITER adds complexity (combat, dimensions). GoDig focuses on simplicity with depth (one mechanic, infinite decisions).

## Competitive Positioning Summary

**GoDig's Unique Value Proposition**:
"The mining game where every ladder is a decision. Dig deep, but can you get back up?"

**Keep Digging's Niche**: Cozy co-op mining for groups
**ITER's Niche**: Complex roguelite with dimension-shifting puzzles
**GoDig's Niche**: Solo push-your-luck mining with elegant tension mechanics

## Output

Implementation specs created:
- Existing `GoDig-implement-automation-building-496db9d0` covers NPC-like offline helper
- Technology categories could enhance `GoDig-implement-upgrade-stat-5658fcef` (comparison UI)
