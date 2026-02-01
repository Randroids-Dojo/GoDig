---
title: "implement: Layered secret system (Animal Well-inspired)"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T08:59:42.698581-06:00"
---

## Description

Create a 3-tier secret system inspired by Animal Well's layered discovery design:
- **Layer 1** (All Players): Basic ore spawns, standard progression, clear objectives
- **Layer 2** (Explorers): Hidden rare finds, secret rooms, environmental clues that reward curiosity
- **Layer 3** (Hardcore): Community puzzles, ARG elements, secrets requiring collaboration

Trust players to discover mechanics through play rather than explicit tutorials.

## Context

Animal Well achieved 650K sales with this approach - players feel smart discovering secrets rather than being told. Our core loop already supports this: digging creates natural discovery moments.

## Affected Files

- `scripts/world/chunk_generator.gd` - Add secret room spawn logic
- `scripts/world/ore_spawner.gd` - Add rare ore placement in hidden areas
- `resources/items/` - Create new "secret" tier items/artifacts
- `scripts/managers/achievement_manager.gd` - Track Layer 2/3 discoveries
- `scripts/ui/hint_system.gd` - Subtle environmental hints for Layer 2

## Implementation Notes

- Layer 1: No changes needed (current ore spawning)
- Layer 2: Add 5-10% chance of hidden alcoves with rare ore behind breakable walls
- Layer 3: v1.1 feature - placeholder for now
- Environmental hints: Slight shimmer on walls hiding secrets, subtle audio cue when near

## Verify

- [ ] Build succeeds
- [ ] Layer 1: Normal ore spawns work as before
- [ ] Layer 2: Hidden rooms spawn at appropriate rate (5-10%)
- [ ] Layer 2: Breaking wall reveals hidden room
- [ ] Layer 2: Rare items in hidden rooms are more valuable
- [ ] No explicit tutorial mentions hidden rooms - player discovers organically
