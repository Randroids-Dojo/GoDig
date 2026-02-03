---
title: "implement: Optional danger zones for risk/reward"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-01T08:59:47.254006-06:00\\\"\""
closed-at: "2026-02-03T04:02:19.783751-06:00"
close-reason: Implemented Dead Cells-inspired danger zone system with 4 zone types (Collapsed Mine, Lava Pocket, Flooded Section, Gas Pocket). Each zone has unique hazards, 50-80% ore density boost, and unique drops. Added DangerZoneManager autoload, HUD warning system, and 8 danger zone templates.
---

## Description

Add optional high-risk high-reward areas that players can choose to enter. Reference Dead Cells' "Cursed Biome" mechanic where players always have a safe path option but can opt into danger for better rewards.

## Context

Dead Cells Cursed Biomes: +10% cursed chest chance, +1 loot level, but harder enemies. Player always has non-cursed option. This creates self-directed difficulty scaling.

## Danger Zone Types

| Zone Type | Visual Indicator | Risk | Reward |
|-----------|-----------------|------|--------|
| Collapsed Mine | Cracked walls, dust particles | Blocks may fall | +50% ore density |
| Lava Pocket | Red glow, heat shimmer | Timer before heat damage | Rare fire gems |
| Flooded Section | Water dripping, blue tint | Reduced visibility | Unique water crystals |
| Gas Pocket | Green mist | Poison tick damage | Fossil artifacts |

## Implementation Notes

- Danger zones spawn as special chunk variants (10-15% chance per layer 3+)
- Entry point shows clear warning icon before player commits
- Player can always see and choose the safe path around danger zone
- Reward multiplier: 1.5x-2x normal ore density
- Unique drops only available in danger zones (collectible motivation)

## Affected Files

- `scripts/world/chunk_generator.gd` - Add danger zone chunk spawning
- `scripts/world/danger_zone.gd` - New script for zone mechanics
- `scripts/ui/hud.gd` - Danger zone warning indicator
- `resources/hazards/` - Danger zone effect definitions
- `scripts/player/player.gd` - Damage effects for zone hazards

## Verify

- [ ] Build succeeds
- [ ] Danger zones spawn at correct rate (10-15% in layers 3+)
- [ ] Warning indicator visible before entering zone
- [ ] Safe path always available around danger zone
- [ ] Ore density increased in danger zones
- [ ] Unique drops only in danger zones
- [ ] Zone hazards deal appropriate damage/effects
