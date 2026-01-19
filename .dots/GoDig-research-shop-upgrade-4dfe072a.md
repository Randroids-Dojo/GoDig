---
title: "research: Shop upgrade progression"
status: done
priority: 0
issue-type: task
created-at: "2026-01-18T23:39:36.464348-06:00"
---

How does shop-based progression work? Questions: What upgrades can players buy? (tool tiers, backpack slots, etc.) How are prices balanced? Do upgrades unlock at depth milestones or coin thresholds? What's the upgrade order/tree? How does UI show available vs locked upgrades?

## Research Findings (Verified 2026-01-19)

### Current Implementation Status: COMPLETE

Shop progression is implemented in `scripts/ui/shop.gd` with two upgrade categories.

### Answer to Research Questions

**1. What upgrades can players buy?**

**Tool Upgrades (ToolData resources):**
| Tier | Name | Damage | Speed | Cost | Unlock Depth |
|------|------|--------|-------|------|--------------|
| 1 | Rusty Pickaxe | 10.0 | 1.0x | Free | 0 |
| 2 | Copper Pickaxe | 20.0 | 1.0x | $500 | 25 |
| 3 | Iron Pickaxe | 35.0 | 1.1x | $2000 | 100 |

**Backpack Upgrades (hardcoded in shop.gd):**
| Level | Slots | Cost | Min Depth |
|-------|-------|------|-----------|
| 1 | 8 | Free | 0 |
| 2 | 12 | $1000 | 50 |
| 3 | 20 | $3000 | 200 |
| 4 | 30 | $8000 | 500 |

**2. How are prices balanced?**
- Tools: Exponential growth (~4x per tier)
- Backpacks: Roughly 3x per tier
- Early upgrades affordable with surface mining
- Later upgrades require deeper (more valuable) resources

**3. Do upgrades unlock at depth milestones or coin thresholds?**
- **Depth milestones** gate visibility/unlock
- **Coin thresholds** gate purchase
- Both must be satisfied to buy

**4. What's the upgrade order/tree?**
- Linear progression (no branching tree)
- Tool tier 1 -> 2 -> 3 (planned: more tiers)
- Backpack level 1 -> 2 -> 3 -> 4
- No dependencies between tool and backpack tracks

**5. How does UI show available vs locked upgrades?**
```gdscript
if not depth_ok:
    upgrade_btn.text = "LOCKED - Reach %dm" % min_depth
    upgrade_btn.disabled = true
elif not can_afford:
    upgrade_btn.text = "UPGRADE - $%d (Need $%d more)" % [cost, shortfall]
    upgrade_btn.disabled = true
else:
    upgrade_btn.text = "UPGRADE - $%d" % cost
    upgrade_btn.disabled = false
```

### Shop Implementation Details

**Tool Upgrade Section:**
- Uses ToolData resources from `resources/tools/`
- `DataRegistry.get_all_tools()` returns sorted by tier
- `PlayerData.get_equipped_tool()` returns current tool
- `PlayerData.get_next_tool_upgrade()` returns next tier
- `PlayerData.can_unlock_tool(tool)` checks depth requirement
- On purchase: `GameManager.spend_coins()` + `PlayerData.equip_tool()`

**Backpack Upgrade Section:**
- Hardcoded `backpack_upgrades` array in shop.gd
- Current level derived from `InventoryManager.get_total_slots()`
- On purchase: `InventoryManager.upgrade_capacity(slots)`

### Upgrade Flow

1. Shop opens, `_refresh_upgrades_tab()` called
2. Current tool/backpack level determined
3. Next upgrade displayed with requirements
4. Button state set based on depth + coins
5. User clicks enabled upgrade button
6. Confirmation not required (instant)
7. Coins deducted, upgrade applied
8. Auto-save triggered
9. UI refreshed to show next upgrade

### Gaps Identified

1. **Backpack upgrades hardcoded** - Should be BackpackData resources like tools
2. **No upgrade confirmation** - Direct purchase, unlike rescue/reload
3. **Missing tiers** - MVP has 3 tools, v1.0 needs more

### No Further Work Needed for Research

Progression system is functional. Balance tuning is ongoing.
