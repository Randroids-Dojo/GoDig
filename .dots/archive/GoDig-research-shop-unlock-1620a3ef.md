---
title: "research: Shop unlock progression"
status: closed
priority: 0
issue-type: task
created-at: "\"\\\"2026-01-18T23:39:36.594193-06:00\\\"\""
closed-at: "2026-01-19T02:17:31.003840-06:00"
close-reason: Documented shop types, unlock triggers, surface layout, created building unlock system spec, expanded 4 building specs
---

How do new shops unlock? Questions: What shops exist? (General Store, Blacksmith, Equipment, etc.) What triggers unlock? (depth reached, coins earned, items sold?) Where do shops appear on surface? How does UI indicate locked vs unlocked shops? What order do they unlock?

## Research Findings

### Shop Types and Unlock Order

Based on `Docs/research/surface-shops.md` and MVP requirements:

#### MVP Shops (Always Available)
| Shop | Purpose | Unlock |
|------|---------|--------|
| General Store | Sell ores/gems for coins | Start |
| Supply Store | Buy ladders, ropes, torches | Start |

**Note**: MVP actually only needs ONE combined shop (current `shop.gd` has both Sell and Upgrades tabs). The separation into building types is for v1.0.

#### v1.0 Shops (Progressive Unlock)
| Shop | Purpose | Unlock Depth | Unlock Trigger |
|------|---------|--------------|----------------|
| Blacksmith | Tool upgrades | 50m | First visit to depth |
| Equipment Shop | Gear (helmet, boots, backpack) | 100m | First visit to depth |
| Gem Appraiser | Better gem prices | 200m | Find first gem |
| Gadget Shop | Compass, detector, grapple | 300m | First visit to depth |
| Warehouse | Storage expansion | 500m | First visit to depth |
| Elevator | Fast travel to depths | 500m | First visit to depth |

#### v1.1+ Shops
| Shop | Purpose | Unlock |
|------|---------|--------|
| Refinery | Process ore to ingots | 750m |
| Research Lab | Tech tree | 1000m |
| Auto-Miner Station | Automation | 1000m |
| Portal | Deep teleportation | 1500m |

### Unlock Trigger Design

**Recommendation: Depth-based primary unlock**

Pros:
- Simple to implement and understand
- Natural progression as player explores
- No hidden requirements

**Secondary triggers (optional)**:
- Collection-based: "Find your first gem" unlocks Gem Appraiser
- Milestone-based: "Sell 1000 coins worth" unlocks building upgrade

**Implementation approach**:
```gdscript
# GameManager tracks max_depth_reached
func update_depth(depth: int) -> void:
    if depth > max_depth_reached:
        max_depth_reached = depth
        _check_unlocks()

func _check_unlocks() -> void:
    for building_id in BUILDING_UNLOCK_DEPTHS:
        if max_depth_reached >= BUILDING_UNLOCK_DEPTHS[building_id]:
            if not unlocked_buildings.has(building_id):
                unlocked_buildings.append(building_id)
                building_unlocked.emit(building_id)
```

### Surface Layout

**MVP approach (slot-based)**:
- Surface is a simple horizontal strip
- Fixed building slots at predetermined positions
- Buildings unlock in order, appear at next available slot
- Player walks left/right to access different buildings

**Surface positions**:
```
[Mine Entrance] [General Store] [Supply Store] [Blacksmith] [Equipment] ...
     Slot 0         Slot 1          Slot 2        Slot 3      Slot 4
```

### UI Indication for Locked Buildings

**Option A: Show locked placeholder (recommended for v1.0)**
- Locked buildings visible but grayed out
- Walking up shows "Unlock: Reach Xm depth"
- Creates anticipation and goal visibility

**Option B: Hidden until unlock (simpler for MVP)**
- Buildings simply don't exist until unlocked
- Notification when new building unlocks
- Less cluttered surface

**MVP recommendation**: Option B (hidden), with unlock notification toast.

### Building Data Resource

```gdscript
class_name BuildingData extends Resource

@export var id: String
@export var display_name: String
@export var description: String
@export var icon: Texture2D
@export var unlock_depth: int = 0
@export var unlock_requirement: String = ""  # e.g., "find_gem"
@export var surface_position: int  # Slot index
@export var shop_scene: PackedScene  # UI to open when interacted
```

### Notification System

When a building unlocks:
1. Toast notification: "Blacksmith Unlocked!"
2. Building appears on surface with sparkle effect
3. Optional: Arrow pointing to new building

## Decisions Made

- [x] MVP shop count? → 1 combined shop, v1.0 separates into types
- [x] Unlock trigger? → Depth-based primary, collection secondary
- [x] Surface layout? → Slot-based, fixed positions
- [x] Locked UI? → MVP hides, v1.0 shows grayed placeholders
- [x] Unlock notification? → Toast message + sparkle effect

## Implementation Specs to Update

The existing building implement dots need more detail:
1. `GoDig-dev-general-store-7902991c` - Needs full spec
2. `GoDig-dev-blacksmith-tool-afe94eca` - Needs unlock logic
3. `GoDig-dev-equipment-shop-9b3978de` - Needs unlock logic
4. `GoDig-dev-supply-store-17cf31ed` - Needs full spec

Need new implement dot:
- `implement: Building unlock system` - Tracks unlocks, shows notifications
