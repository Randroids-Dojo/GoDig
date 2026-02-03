---
title: "implement: Handcrafted cave chunk system"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-01T08:53:55.802233-06:00\\\"\""
closed-at: "2026-02-03T03:54:42.209796-06:00"
close-reason: Implemented Spelunky-style handcrafted cave system with ChunkTemplate resource class, ChunkLibrary with 25+ templates, and HandcraftedCaveManager autoload. Integrated with DirtGrid chunk generation.
---

## Description

Use Spelunky-style pre-designed room chunks with procedural arrangement. Guarantee interesting cave formations while maintaining variety.

## Context

Research shows that 'constraints and careful rule design produce better results than pure randomness.' Players should feel like levels are handcrafted even when procedurally generated.

## Research Basis (Session 16)

- Spelunky: 'Assembles pre-designed rooms according to strict rules ensuring playability'
- Binding of Isaac: 'Room pool contains thousands of handcrafted designs with procedural arrangement'
- 2025 trend: 'Combining handcrafted areas with procedurally generated ones - best of both worlds'
- 'Each level segment has defined entry and exit points, guaranteeing levels always completable'

## Affected Files

- scripts/world/chunk_generator.gd - Chunk assembly system
- scripts/world/chunk_library.gd - NEW: Pre-designed chunk definitions
- resources/chunks/*.tres - NEW: Handcrafted chunk resources
- scripts/world/ore_generator.gd - Integrate with chunk system

## Implementation Notes

Chunk Types:
1. Open Chamber - Large dig space, ore veins on walls
2. Tight Squeeze - Narrow passage, concentrated ore
3. Drop Shaft - Vertical with platforms, speed descent
4. Treasure Room - Hidden behind false wall, rare loot
5. Rest Ledge - Safe platform, ladder-saving spot
6. Ore Pocket - Dense ore concentration
7. Hazard Zone - Crumbling blocks or lava pool

Assembly Rules:
- Entry/exit points must align
- No impossible dead ends
- Treasure rooms require specific approach angle
- At least one safe path exists

## Verify

- [ ] Generated worlds feel designed, not random
- [ ] Hidden treasures are discoverable but not obvious
- [ ] No impossible-to-complete situations
- [ ] Variety across multiple runs
