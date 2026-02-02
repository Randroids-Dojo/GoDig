---
title: "research: Economy Loop"
status: closed
priority: 0
issue-type: task
created-at: "\"\\\"2026-01-16T00:41:39.648097-06:00\\\"\""
closed-at: "2026-01-19T10:09:01.174644-06:00"
close-reason: Economy loop fully implemented. Documented findings, identified 4 specs to close.
---

Currency system, shop UI, sell resources, tool upgrades (2-3 tiers). Depends on inventory.

## Research Findings

### Already Implemented

The economy loop is **fully implemented**:

1. **Currency System** (GameManager)
   - `coins` property with add/spend/can_afford methods
   - `coins_changed`, `coins_added`, `coins_spent` signals
   - Auto-save on depth milestones

2. **Shop UI** (scenes/ui/shop.tscn, scripts/ui/shop.gd)
   - Two tabs: Sell and Upgrades
   - Displays inventory items by category (ore, gem)
   - "Sell All" button calculates total value
   - Individual item sell buttons
   - Tool upgrades with depth-gating
   - Backpack upgrades (8 -> 12 -> 20 -> 30 slots)

3. **Inventory Integration**
   - InventoryManager tracks items with stacking
   - `item_added` signal for floating text
   - `inventory_full` signal for HUD warning
   - Slot-based storage with upgradeable capacity

4. **Tool System** (ToolData resources)
   - 3 tiers: Rusty (free), Copper ($500), Iron ($2000)
   - Damage and speed_multiplier properties
   - unlock_depth for shop availability
   - PlayerData tracks equipped tool

5. **Ore Values** (ItemData resources)
   - Coal: $1 (common, surface)
   - Copper: $3 (common, 20m)
   - Iron: $15 (uncommon, 50m)
   - Silver: $50 (rare, 150m)
   - Gold: $100 (rare, 300m)
   - Ruby: $500 (epic, 500m - gem)

### Remaining Integration Gaps

- Shop building on surface not yet created (GoDig-implement-shop-building-25de6397)
- Core game loop wiring not complete (GoDig-dev-core-game-73ab4a77)
- HUD shop button visibility when near shop

### Sparse Specs Needing Updates

Several economy-related specs are already implemented and should be closed:
- GoDig-dev-shop-scene-6f187cc7: Shop scene exists
- GoDig-dev-sell-resources-13af8cc8: Sell logic in shop.gd
- GoDig-dev-tool-upgrade-1a9f3f90: Tool upgrade logic in shop.gd
- GoDig-dev-ore-sell-2800d405: Ore values in ItemData .tres files
