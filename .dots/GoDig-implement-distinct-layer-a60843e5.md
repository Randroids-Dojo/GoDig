---
title: "implement: Distinct layer identity system (Dead Cells-style)"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T08:59:44.977702-06:00"
---

## Description

Each depth layer should have unique visual identity and mechanical characteristics that teach players new skills. Reference Dead Cells' biome design where each area has distinct identity and skill requirements.

## Context

Dead Cells uses 20+ biomes with distinct identities. Each biome "teaches new lessons that compound into comprehensive mastery." Our 7 layers should similarly offer progressive skill challenges.

## Layer Identity Spec

| Layer | Visual Identity | Mechanical Twist | Key Skill Taught |
|-------|-----------------|------------------|------------------|
| 1 (Topsoil) | Brown/tan, open | Easy navigation, tutorial ore | Basic mining |
| 2 (Clay) | Orange/red, medium | Tighter spaces, first hazards | Resource management |
| 3 (Stone) | Gray, tight corridors | Careful positioning required | Ladder economy |
| 4 (Mineral) | Sparkling, branching | Multiple path choices | Risk assessment |
| 5 (Crystal) | Purple/pink, vertical | Vertical challenges, shafts | Vertical navigation |
| 6 (Lava) | Red/orange glow, dangerous | Timer pressure from heat | Time pressure |
| 7 (Core) | Deep blue/black, reward zone | Highest rewards, rare ores | Mastery payoff |

## Affected Files

- `scripts/world/layer_config.gd` - Define layer properties and characteristics
- `scripts/world/chunk_generator.gd` - Generate chunks per layer spec
- `assets/tilesets/` - Distinct tileset per layer (existing or update)
- `scripts/world/hazard_spawner.gd` - Layer-specific hazard placement
- `resources/layers/` - Layer data resources

## Verify

- [ ] Build succeeds
- [ ] Each layer has visually distinct appearance
- [ ] Layer 1-2: Open spaces, easy navigation
- [ ] Layer 3-4: Tighter corridors, requires planning
- [ ] Layer 5-7: Distinct challenges per layer
- [ ] Playtest: Player can identify layer by visuals alone
