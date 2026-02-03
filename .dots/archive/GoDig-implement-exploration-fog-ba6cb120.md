---
title: "implement: Exploration fog with map reveal"
status: closed
priority: 3
issue-type: task
created-at: "\"\\\"\\\\\\\"\\\\\\\\\\\\\\\"2026-02-01T08:54:07.061190-06:00\\\\\\\\\\\\\\\"\\\\\\\"\\\"\""
closed-at: "2026-02-02T21:10:09.980134-06:00"
close-reason: Created ExplorationManager autoload with fog of war system. Blocks are modulated based on exploration state (unexplored=dark, explored=desaturated, visible=full). Player exploration tracked per-chunk for memory efficiency. Mined blocks and ladder positions permanently revealed.
---

## Description

Add incomplete map knowledge that creates tension complementing the ladder economy. Players explore into unknown, revealed areas show previously mined paths.

## Context

Hollow Knight's map system creates dual reward: earned maps through exploration + incomplete maps create tense moments. For GoDig, fog adds tension without requiring a separate map purchase mechanic.

## Research Basis (Session 16)

- Hollow Knight: 'Maps are haphazardly drawn and don't feature much detail... as player explores, maps gain more detail'
- 'This mechanic serves two purposes: players rewarded with complete map if they explore, and lack of detail leads to tense situations'
- 'In both cases, exploration is made more engaging'
- Subnautica: 'Depth as storytelling device - drawn to new and more dangerous biomes'

## Affected Files

- scripts/world/map_fog_manager.gd - NEW: Fog of war system
- scenes/ui/minimap/minimap.tscn - Add fog overlay
- scripts/player/player.gd - Reveal area on movement
- scripts/autoload/save_manager.gd - Persist revealed areas

## Implementation Notes

Fog Rules:
- 5-tile vision radius around player
- Mined blocks permanently revealed
- Ore veins NOT visible through fog (must get close)
- Ladder positions visible through fog (critical for return)
- Surface always visible (home base security)

Visual Treatment:
- Unexplored: Dark/dim overlay
- Explored but not visible: Desaturated
- Currently visible: Full color
- Ore shimmer only visible in current vision radius

## Verify

- [ ] Exploration feels rewarding (revealing unknown)
- [ ] Return trip uses revealed map for planning
- [ ] Ore discovery has surprise element
- [ ] Does not interfere with ladder planning
- [ ] Mobile performance acceptable
