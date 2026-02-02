---
title: "research: Shop scene and sell flow"
status: done
priority: 0
issue-type: task
created-at: "2026-01-18T23:35:22.862903-06:00"
---

How should the shop work? Need UI for selling inventory items. Questions: Is shop a separate scene or overlay? How does player access shop (return to surface, button)? How do sell prices map to OreData.sell_value? Should there be a 'sell all' button? How does InventoryManager integrate with shop transactions?

## Research Findings (Verified 2026-01-19)

### Current Implementation Status: COMPLETE

Shop UI is already implemented in `scripts/ui/shop.gd`.

### Answer to Research Questions

**1. Is shop a separate scene or overlay?**
- Overlay (Control node under UI in TestLevel)
- Located at `$UI/Shop` in test_level.tscn
- Uses `visible = true/false` to show/hide

**2. How does player access shop?**
- Shop button in HUD (`$UI/ShopButton`)
- Also accessible via inventory button (currently toggles shop as placeholder)
- No surface-only restriction currently - can open anywhere

**3. How do sell prices map to sell_value?**
- Shop reads `slot.item.sell_value` directly
- Calculates total: `item.sell_value * quantity`
- Uses ItemData.sell_value field (after OreData unification, will use inherited value)

**4. Should there be a 'sell all' button?**
- YES - Already implemented
- Button at `$Panel/VBox/TabContainer/Sell/TotalSection/SellAllButton`
- Sells all items with category "ore" or "gem"
- Disabled when no sellable items

**5. How does InventoryManager integrate?**
- Shop iterates `InventoryManager.slots` to find sellable items
- Calls `InventoryManager.remove_all_of_item(item)` to remove sold items
- Calls `GameManager.add_coins(total)` to credit player
- Calls `SaveManager.save_game()` after transactions

### Shop UI Structure

```
Shop (Control)
  Panel (PanelContainer)
    VBox (VBoxContainer)
      Header
        CoinsLabel - Shows current coins
      TabContainer
        Sell - Sell resources tab
          ScrollContainer
            ItemsGrid - Grid of sellable items
          TotalSection
            TotalLabel - "Total: $X"
            SellAllButton - Sell all ore/gems
        Upgrades - Buy upgrades tab
          ScrollContainer
            UpgradesVBox - List of upgrades
      CloseButton
```

### Sell Flow

1. Shop.open() called
2. _refresh_sell_tab() iterates inventory slots
3. Groups items by ID, calculates total value
4. Creates sell button for each item type
5. User clicks "Sell" or "Sell All"
6. Items removed from inventory, coins added
7. Auto-save triggered

### Upgrade Flow

1. _refresh_upgrades_tab() shows tool and backpack upgrades
2. Checks depth requirements via `PlayerData.max_depth_reached`
3. Checks affordability via `GameManager.can_afford(cost)`
4. User clicks upgrade button
5. `GameManager.spend_coins()` deducts cost
6. Tool: `PlayerData.equip_tool(tool_id)`
7. Backpack: `InventoryManager.upgrade_capacity(slots)`
8. Auto-save triggered

### No Further Work Needed

Shop scene is fully functional. Future enhancements (multiple shop types, building placement) are tracked in separate dots.
