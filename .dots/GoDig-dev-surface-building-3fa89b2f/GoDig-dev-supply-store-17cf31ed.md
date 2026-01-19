---
title: "implement: Supply Store (buy basics)"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T00:28:42.829512-06:00"
---

Buy ladders, ropes, torches, dynamite. Second starting building. Consumable items UI.

## Description

The Supply Store sells consumable traversal and utility items. It's available from game start alongside the General Store.

## Context

- Ladders are MVP-critical for vertical traversal
- Other consumables (ropes, torches, bombs) are v1.0
- Prices must balance with ore sell values
- Creates resource sink to prevent infinite coin accumulation

## Affected Files

- `scenes/surface/supply_store.tscn` - Building on surface
- `scripts/surface/supply_store.gd` - Interaction trigger
- `scenes/ui/supply_store_ui.tscn` - Buy UI
- `scripts/ui/supply_store_ui.gd` - Purchase logic
- `resources/items/consumables/*.tres` - Item definitions

## Implementation Notes

### Consumable Items

| Item | Cost | Effect | Stack |
|------|------|--------|-------|
| Ladder | 50 | Place to climb | 20 |
| Rope | 100 | Descend safely | 10 |
| Torch | 25 | Light area | 50 |
| Bomb | 500 | Destroy 3x3 blocks | 5 |
| Teleport Scroll | 1000 | Return to surface | 3 |

### Supply Store Levels (v1.0+)

- Level 1: Ladders only
- Level 2: +Ropes, -5% prices
- Level 3: +Torches, -10% prices
- Level 4: +Bombs, -15% prices
- Level 5: +All items, -20% prices

### Buy UI Design

```
┌─────────────────────────────────────┐
│  SUPPLY STORE                        │
├─────────────────────────────────────┤
│  [Ladder Icon] Ladder    $50  [+1]  │
│  In bag: 5                          │
│                                     │
│  [Rope Icon] Rope        $100 [+1]  │
│  In bag: 2                          │
│                                     │
│  [Buy 5] [Buy 10] [Buy Max]         │
└─────────────────────────────────────┘
```

### MVP Simplification

For MVP, only ladders are available. Add a "Buy" tab to the combined shop UI, or keep Supply Store as a separate building from start.

## Verify

- [ ] Player can buy ladders
- [ ] Purchase deducts coins
- [ ] Item added to inventory
- [ ] Can't buy if inventory full
- [ ] Can't buy if can't afford
- [ ] Buy quantity buttons work (x1, x5, x10)
- [ ] (v1.0) Store level affects prices and available items
