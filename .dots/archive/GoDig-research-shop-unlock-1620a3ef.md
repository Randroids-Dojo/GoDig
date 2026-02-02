---
title: "research: Shop unlock progression"
status: done
priority: 0
issue-type: task
created-at: "2026-01-18T23:39:36.594193-06:00"
---

How do new shops unlock? Questions: What shops exist? (General Store, Blacksmith, Equipment, etc.) What triggers unlock? (depth reached, coins earned, items sold?) Where do shops appear on surface? How does UI indicate locked vs unlocked shops? What order do they unlock?

## Research Findings (Verified 2026-01-19)

### Current Implementation Status: MVP ONLY

MVP has a single unified shop (`scripts/ui/shop.gd`). Multiple shop types are planned for v1.0.

### Answer to Research Questions

**1. What shops exist?**

**Current (MVP):**
- Single "Shop" with Sell and Upgrades tabs
- Combines selling and buying in one place

**Planned (v1.0) - from implementation dots:**
- General Store (sell resources) - `GoDig-dev-general-store-7902991c`
- Supply Store (buy basics) - `GoDig-dev-supply-store-17cf31ed`
- Blacksmith (tool upgrades) - `GoDig-dev-blacksmith-tool-afe94eca`
- Equipment Shop (gear) - `GoDig-dev-equipment-shop-9b3978de`

**2. What triggers unlock?**
- **NOT YET IMPLEMENTED**
- Proposed: Depth milestones (consistent with tool unlocks)
- Alternative: Coins earned threshold
- SaveData already has `buildings_unlocked: Array[String]` field

**3. Where do shops appear on surface?**
- **NOT YET IMPLEMENTED**
- Planned: Slot-based building placement system
- See `GoDig-dev-building-placement-8e193b79`
- See `GoDig-dev-building-slot-0c645dc8`

**4. How does UI indicate locked vs unlocked shops?**
- **NOT YET IMPLEMENTED**
- Recommendation: Greyed-out buildings with "Reach Xm to unlock"
- Similar pattern to current upgrade buttons

**5. What order do they unlock?**
- **NOT YET DEFINED**
- Proposed order (matches progression):
  1. General Store (depth 0) - Always available, sell resources
  2. Blacksmith (depth 50) - Tool upgrades
  3. Supply Store (depth 100) - Buy ladders, consumables
  4. Equipment Shop (depth 200) - Buy boots, gear

### SaveData Integration

Already prepared for building unlock tracking:
```gdscript
# save_data.gd
@export var buildings_unlocked: Array[String] = []

func has_building(building_id: String) -> bool:
    return building_id in buildings_unlocked

func unlock_building(building_id: String) -> bool:
    if has_building(building_id):
        return false
    buildings_unlocked.append(building_id)
    return true
```

### Implementation Recommendation

1. Create `BuildingData` resource class (like ToolData)
2. Define building .tres files with unlock conditions
3. Add building unlock check to depth milestone handler
4. Create surface scene with building slots
5. Render locked buildings as silhouettes

### Related Implementation Dots

- `GoDig-implement-building-unlock-c3ebfa7e` - Unlock system
- `GoDig-dev-building-placement-8e193b79` - Placement system
- `GoDig-dev-surface-area-379633b2` - Surface scene

### No Further Research Needed

Multiple shops are a v1.0 feature. Implementation dots exist with specs.
