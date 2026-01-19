---
title: "implement: General Store (sell resources)"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T00:28:41.710193-06:00"
---

First shop: sell raw ores/gems for coins. Basic UI with tabs: Buy/Sell/Upgrade. Always available. Based on surface-shops.md.

## Description

The General Store is the player's primary shop for selling mined resources. It's available from game start and serves as the core economic hub.

## Context

- Current `shop.gd` already implements sell functionality in the "Sell" tab
- For MVP, General Store IS the single shop (combined with upgrades)
- For v1.0, General Store becomes sell-only, with upgrades split to Blacksmith

## Affected Files

- `scenes/surface/general_store.tscn` - Building on surface
- `scripts/surface/general_store.gd` - Interaction trigger
- `scenes/ui/general_store_ui.tscn` - Shop UI (can reuse shop.tscn Sell tab)
- `scripts/ui/general_store_ui.gd` - Sell-only UI logic

## Implementation Notes

### v1.0 General Store Features

1. **Sell Tab** (existing in shop.gd)
   - Grid of sellable items from inventory
   - Individual sell buttons per item type
   - "Sell All" button
   - Total value display

2. **Upgradeable Sell Bonus** (v1.0+)
   - Level 1: Base prices
   - Level 2: +5% sell value (cost: 1,000)
   - Level 3: +10% sell value (cost: 5,000)
   - Level 4: +15% sell value (cost: 20,000)
   - Level 5: +25% sell value (cost: 100,000)

### Sell Value Calculation

```gdscript
func get_effective_sell_value(base_value: int) -> int:
    var bonus_multiplier = 1.0 + (store_level - 1) * 0.05
    return int(base_value * bonus_multiplier)
```

### MVP Simplification

For MVP, the existing `shop.gd` Sell tab IS the General Store. No separate building needed - just the single shop building with all tabs.

## Verify

- [ ] Player can sell ores and gems for coins
- [ ] Sell values match ore definitions
- [ ] "Sell All" button works correctly
- [ ] Sold items removed from inventory
- [ ] Coins added to player balance
- [ ] (v1.0) Store upgrade increases sell values
