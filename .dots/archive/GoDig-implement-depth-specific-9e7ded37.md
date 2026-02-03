---
title: "implement: Depth-specific eureka mechanics"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-01T08:53:37.910759-06:00\\\"\""
closed-at: "2026-02-03T03:38:09.877696-06:00"
close-reason: "Implemented depth-specific eureka mechanics with EurekaMechanicManager autoload. Each layer has unique mechanic: basic_dig, ore_shimmer, crumbling_blocks, cave_sense, pressure_cracks, crystal_resonance, loose_blocks, heat_weaken, void_sight, reality_tears. Added to LayerData, SaveManager persistence, DirtGrid integration."
---

## Description

Each depth layer should introduce a subtle mechanic twist that creates 'aha' moments for players.

## Context

Research from The Witness, Bonfire Peaks, and puzzle game design shows that eureka moments are a core satisfaction driver. Players feel smart when they discover something new that changes how they play.

## Research Basis (Session 16)

- The Witness: 'Make the puzzle solution a reward for completing a puzzle that does follow rules'
- Bonfire Peaks: 'Great eureka moments from short snappy puzzles with discoverable mechanics'
- Öoo: 'Simple core mechanic then mines so much puzzling gold out of it'
- Subnautica: 'Each new depth introduces rarer minerals, hidden structures, surprises'

## Affected Files

- scripts/world/layer_manager.gd - Add layer-specific mechanic triggers
- scripts/world/ore_generator.gd - Layer-specific ore behaviors
- resources/layers/*.tres - Layer mechanic definitions
- scenes/world/blocks/ - New special block types

## Implementation Notes

Layer 1 (Topsoil): Basic dig mechanics, introduce wall-jump
Layer 2 (Clay): Introduce ore shimmer hints
Layer 3 (Stone): Introduce crumbling blocks (fall after delay)
Layer 4 (Granite): Introduce hidden cave pockets
Layer 5 (Obsidian): Introduce lava hazards
Layer 6 (Bedrock): Introduce rare artifact finds
Layer 7 (Core): Introduce jackpot ore veins

Each layer should teach ONE new thing that makes players go 'wait, I can do that?'

## Verify

- [ ] Each layer has at least one unique mechanic
- [ ] First encounter with each mechanic is tutorialized
- [ ] Mechanics build on each other (not standalone)
- [ ] Players report 'aha' moments in playtesting
