---
title: "implement: Blacksmith (tool upgrades)"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-16T00:28:43.449894-06:00\""
closed-at: "2026-01-24T21:51:00.443177+00:00"
close-reason: "Implemented: shop.gd Upgrades tab has tool upgrades from DataRegistry ToolData"
---

Upgrade pickaxe damage/speed/durability. Progressive unlock display. Unlocks at depth 50-200m.

## Description

The Blacksmith is a specialized shop for tool upgrades. It unlocks when the player reaches 50m depth and offers increasingly powerful pickaxe tiers.

## Context

- Current `shop.gd` has tool upgrades in the "Upgrades" tab
- For v1.0, this tab logic moves to a dedicated Blacksmith building
- Tool tier progression is critical for accessing harder ores
- See research: GoDig-research-shop-upgrade-4dfe072a for pricing details

## Affected Files

- `scenes/surface/blacksmith.tscn` - Building on surface
- `scripts/surface/blacksmith.gd` - Interaction trigger
- `scenes/ui/blacksmith_ui.tscn` - Upgrade UI
- `scripts/ui/blacksmith_ui.gd` - Tool upgrade logic (extract from shop.gd)

## Implementation Notes

### Tool Tiers (from economy research)

| Tier | Name | Damage | Cost | Unlock Depth |
|------|------|--------|------|--------------|
| 0 | Rusty Pickaxe | 10 | Free | Start |
| 1 | Copper Pickaxe | 20 | 500 | 25m |
| 2 | Iron Pickaxe | 35 | 2,000 | 100m |
| 3 | Steel Pickaxe | 55 | 8,000 | 250m |
| 4 | Silver Pickaxe | 85 | 25,000 | 400m |
| 5 | Gold Pickaxe | 100 | 50,000 | 500m |

### Blacksmith Upgrade Levels (v1.0+)

- Level 1: Basic tools (tiers 0-3)
- Level 2: -5% tool prices, tiers 0-4
- Level 3: -10% tool prices, tiers 0-5
- Level 4: -15% tool prices, all tiers
- Level 5: -20% tool prices, specializations

### UI Design

```
┌─────────────────────────────────────┐
│  BLACKSMITH - Tool Upgrades         │
├─────────────────────────────────────┤
│  [Current Tool Icon]                │
│  Iron Pickaxe (Tier 2)              │
│                                     │
│  Damage: 35 → 55 (+57%)             │
│  Cost: 8,000 coins                  │
│  Requires: Depth 250m [CHECK/X]     │
│                                     │
│  [UPGRADE TO STEEL]                 │
└─────────────────────────────────────┘
```

### MVP Simplification

For MVP, tool upgrades remain in the combined shop UI. Blacksmith building is v1.0 feature.

## Verify

- [ ] Tool upgrades show current level and next tier
- [ ] Upgrade button disabled until depth requirement met
- [ ] Upgrade button disabled if can't afford
- [ ] Purchasing upgrade deducts coins
- [ ] New tool damage applies to mining
- [ ] Tool tier persists across save/load
- [ ] (v1.0) Blacksmith building unlocks at depth 50m
