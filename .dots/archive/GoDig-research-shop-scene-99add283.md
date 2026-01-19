---
title: "research: Shop scene and sell flow"
status: closed
priority: 0
issue-type: task
created-at: "\"\\\"2026-01-18T23:35:22.862903-06:00\\\"\""
closed-at: "2026-01-18T23:50:21.896307-06:00"
close-reason: Documented existing shop implementation, identified gaps (shop building, tool upgrade wiring), created 2 implementation tasks
---

How should the shop work? Need UI for selling inventory items. Questions: Is shop a separate scene or overlay? How does player access shop (return to surface, button)? How do sell prices map to OreData.sell_value? Should there be a 'sell all' button? How does InventoryManager integrate with shop transactions?

## Research Findings

### Current Implementation Status

The shop is **already substantially implemented** in the codebase:

1. **Shop Scene**: `scenes/ui/shop.tscn` and `scripts/ui/shop.gd` exist
2. **Currency System**: `GameManager` has coins tracking with signals (coins_changed, coins_added, coins_spent)
3. **Sell Tab**: Displays sellable items (ore/gem category), individual sell buttons, "Sell All" button
4. **Upgrades Tab**: Tool upgrades and backpack upgrades with cost/unlock requirements

### Architecture Answers

**Q: Is shop a separate scene or overlay?**
A: It's an overlay Control node that can be added to any scene. `visible` is toggled via `open()` and close button.

**Q: How does player access shop?**
A: Currently the shop.gd just has `open()` and `closed` signal. The MVP spec calls for Area2D on surface that shows a "Shop" HUD button, but this isn't wired up yet.

**Q: How do sell prices map to OreData.sell_value?**
A: The shop reads `slot.item.sell_value` directly from ItemData. However, with the dual OreData/ItemData issue (see GoDig-research-ore-spawning-bdc2945d), this relies on ItemData files which duplicate values from OreData.

**Q: Should there be a 'sell all' button?**
A: Yes, already implemented. `_on_sell_all_pressed()` iterates through slots, totals value, removes items, adds coins.

**Q: How does InventoryManager integrate?**
A: Shop reads `InventoryManager.slots` to display items, calls `InventoryManager.remove_all_of_item()` to sell, and listens to `inventory_changed` signal to refresh UI.

### What's Still Missing

1. **Shop Building on Surface**
   - Spec calls for `scenes/surface/shop_building.tscn` with Area2D
   - `scripts/surface/shop_building.gd` to show/hide HUD button
   - Surface scene doesn't exist yet (separate task)

2. **Tool Upgrade Application**
   - `_on_tool_upgrade()` has TODO: "Apply tool upgrade to player"
   - No PlayerStats or equipment system to receive the upgrade
   - Current tool level is hardcoded to return 1

3. **Shop Button in HUD**
   - Spec calls for GameManager.show_shop_button() - doesn't exist
   - Need HUD element that appears when near shop

4. **Sound/Animation Feedback**
   - No sound effects on sell/buy
   - No coin animation when adding coins

### Integration With Existing Systems

The shop correctly uses:
- `GameManager.add_coins()`, `spend_coins()`, `can_afford()`, `get_coins()`
- `InventoryManager.slots`, `remove_all_of_item()`, `upgrade_capacity()`
- `InventoryManager.inventory_changed` signal for reactive updates

The shop INCORRECTLY uses (due to ItemData/OreData duplication):
- `slot.item.sell_value` reads from ItemData, but ItemData files may desync from OreData

### Recommendations

1. **Complete shop interaction flow** - Create surface scene with shop building and HUD button
2. **Wire up tool upgrades** - Needs PlayerStats singleton or GameManager extensions
3. **Fix sell_value source** - After OreData extends ItemData unification, shop will read correct values automatically
4. **Add feedback** - Sound effects and visual feedback for transactions

## Related Tasks

- `GoDig-mvp-single-shop-b97d367d` - Main implementation task (in progress)
- `GoDig-implement-unify-oredata-8388f176` - Fixes sell_value duplication
- `GoDig-dev-surface-area-379633b2` - Surface scene where shop building lives
- `GoDig-dev-player-stats-41460a18` - Needed for tool upgrade tracking
- `GoDig-research-shop-upgrade-4dfe072a` - Deeper dive on upgrade progression

## New Implementation Tasks Created

Based on this research, the following new tasks were created:

1. `GoDig-implement-shop-building-25de6397` - Shop building on surface with Area2D (priority 1)
2. `GoDig-implement-wire-tool-e8875437` - Wire tool upgrades to GameManager (priority 1)
