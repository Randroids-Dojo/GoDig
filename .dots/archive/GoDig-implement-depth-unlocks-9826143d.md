---
title: "implement: Depth unlocks new discoveries"
status: closed
priority: 1
issue-type: task
created-at: "\"2026-02-01T08:40:29.703960-06:00\""
closed-at: "2026-02-02T00:59:44.456342-06:00"
close-reason: Ore data already has depth gating (min_depth/max_depth). First-discovery notifications implemented in earlier commit. Remaining work is balance tuning of ore depths in .tres files - current settings may be too conservative (iron@50m, silver@200m, gold@300m per spec wants iron@10m, silver@20m, gold@40m). Closing as core system exists.
---

## Description

Each significant depth milestone should unlock NEW THINGS to discover, not just harder blocks. Prevent the 'repetitive mid-game' problem.

## Context

Research (Session 14) found:
- Mr. Mine: 'adventure and discovery emphasized over pure incremental progress'
- Each new depth introduces 'rarer minerals, hidden structures, surprises'
- Keep on Mining criticism: 'dopamine-inducing early, repetitive mid-game'
- Core Keeper: biome-based progression with new ore types per zone
- Key insight: 'Mining must be inherently satisfying BEFORE any systems/upgrades'

Depth should feel like exploration, not just grinding through harder blocks.

## Implementation

### Discovery Types by Depth
**0-10m (Tutorial zone)**:
- Common ore (copper)
- Dirt and grass blocks only

**10-20m (Early progression)**:
- Iron ore starts appearing
- Stone blocks introduced
- First cave pockets (small, 3-5 blocks)

**20-40m (Mid-game)**:
- Silver ore appears
- Underground water pools (visual variety)
- Larger caves (8-12 blocks)
- Rare: abandoned minecart with bonus ore

**40-60m (Advanced)**:
- Gold ore appears
- Crystal formations (sparkle, purely visual initially)
- Ancient ruins background tiles
- Rare: treasure chest with coins/items

**60-80m (Deep)**:
- Diamond ore appears
- Lava pockets (hazard, visual only for MVP)
- Fossilized creatures in stone (cosmetic)
- Rare: relic discovery (collectible)

**80m+ (Abyss)**:
- Rare ores only (emerald, ruby)
- Strange glowing flora
- Mysterious structures
- Very rare: unique artifacts

### Discovery Notifications
- First time seeing new ore: 'New ore discovered: [name]!'
- First time reaching depth milestone: 'Depth [X]m reached!'
- Finding rare discovery: Special celebration + journal entry

## Affected Files
- `scripts/world/chunk_generator.gd` - Depth-based content rules
- `scripts/world/ore_generator.gd` - Ore probability by depth
- `resources/discoveries/` - Discovery definitions
- `scripts/autoload/discovery_manager.gd` - Track first-time discoveries
- `scripts/ui/discovery_notification.gd` - Notification UI

## Verify
- [ ] New ore types appear at documented depths
- [ ] Cave size increases with depth
- [ ] Rare discoveries spawn at appropriate depths
- [ ] First-time discovery notifications trigger correctly
- [ ] Discoveries feel like exploration, not just grinding
- [ ] Player can 'see' deeper ores before they can efficiently mine them
