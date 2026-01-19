---
title: "research: Test coverage gaps in MVP implementation specs"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-01-18T23:27:04.208517-06:00\\\"\""
closed-at: "2026-01-18T23:33:15.962224-06:00"
close-reason: Analyzed test coverage gaps. Created 3 implementation dots for inventory tests, layer tests, and player state tests. Documented 20+ missing verification criteria from completed MVP specs.
---

Review Verify sections in implementation specs and identify which criteria are not covered by current tests. Recommend additional tests for inventory, player, and future chunk/ore systems.

## Analysis Summary

### Current Test Coverage (tests/test_hello_world.py)

The current test file has **19 tests** covering:
- Scene structure (Main, Player, DirtGrid, Camera, UI nodes exist)
- GameManager autoload existence and is_running state
- DataRegistry autoload existence
- InventoryManager autoload existence + max_slots = 8
- TouchControls + direction buttons existence and text
- Jump button existence and text
- Player wall-jump states (current_state property)
- GameManager coins property existence
- DepthLabel shows "Depth:" text

### Implemented Features vs Test Coverage

#### 1. Basic Inventory System (GoDig-mvp-basic-inventory-851ca931) - COMPLETED

**Verify criteria from spec:**
- [x] Build succeeds with no errors (implicit in CI)
- [x] InventoryManager autoload is registered (test_inventory_manager_exists)
- [ ] **GAP: Adding item to empty inventory works**
- [ ] **GAP: Adding item stacks with existing same-type item**
- [ ] **GAP: Adding item creates new slot when existing stacks full**
- [ ] **GAP: inventory_full signal fires when no space left**
- [ ] **GAP: get_item_count returns correct total across all slots**
- [ ] **GAP: remove_item decrements quantity correctly**
- [ ] **GAP: Slot clears (item = null) when quantity reaches 0**

#### 2. Wall-Jump Ability (GoDig-mvp-wall-jump-476ebfdb) - COMPLETED

**Verify criteria from spec:**
- [x] Build succeeds with no errors
- [ ] **GAP: Player can wall-slide when falling next to a wall**
- [ ] **GAP: Wall slide reduces fall speed significantly**
- [ ] **GAP: Jump button during wall slide launches player away from wall**
- [ ] **GAP: Player can chain wall-jumps to ascend a shaft**
- [x] Wall-jump works with touch controls (jump button exists)
- [ ] **GAP: Cannot wall-jump when no wall is adjacent**

#### 3. 3-4 Layer Types with Hardness (GoDig-mvp-3-4-42c5e3a3) - COMPLETED

**Verify criteria from spec:**
- [x] Build succeeds with no errors
- [x] DataRegistry autoload exists (test_data_registry_exists)
- [ ] **GAP: LayerData resources load correctly in DataRegistry**
- [ ] **GAP: Topsoil blocks at depth 0-50m have correct hardness**
- [ ] **GAP: Stone blocks at depth 200-500m require more hits to break**
- [ ] **GAP: Block colors change visually between layers**
- [ ] **GAP: Transition zones show mixed block types**
- [ ] **GAP: Break time formula correctly uses block hardness and tool damage**

#### 4. Grid-Based Digging (GoDig-mvp-grid-based-bd2f5ebf) - COMPLETED

**Verify criteria from spec (implied):**
- [x] Player exists
- [x] DirtGrid exists
- [ ] **GAP: Player can dig down (direction restriction works)**
- [ ] **GAP: Player can dig left/right**
- [ ] **GAP: Player cannot dig upward**
- [ ] **GAP: Mining animation plays during dig**
- [ ] **GAP: Block is destroyed after mining completes**

### Future MVP Features (Not Yet Implemented, But Specs Have Verify Criteria)

#### 5. 5-6 Ore Types with Depth Rarity (GoDig-mvp-5-6-9aa5456c) - PENDING

Future tests needed:
- OreData resources load in DataRegistry
- Coal appears only at depth 0-500m
- Gold appears only at depth 300m+
- Ore veins form natural 2-8 block clusters
- Rarer ores appear less frequently
- Destroying ore block adds item to inventory
- Ruby (gem) appears as single blocks at 500m+

#### 6. Single Shop (GoDig-mvp-single-shop-b97d367d) - PENDING

Future tests needed:
- EconomyManager autoload tracks coins correctly
- Shop opens when player enters shop area
- Sell tab shows sellable inventory items
- Sell All calculates correct total
- Upgrades tab shows current tool level
- Cannot buy upgrade with insufficient coins

#### 7. 2-3 Tool Upgrade Tiers (GoDig-mvp-2-3-e92f5253) - PENDING

Future tests needed:
- ToolData resources load in DataRegistry
- Rusty Pickaxe equipped at game start
- Block break time decreases with better tools
- Depth requirements for tool visibility

#### 8. Auto-Save System (GoDig-mvp-auto-save-d75d685e) - PENDING

Future tests needed:
- Auto-save triggers every 60 seconds
- App background triggers immediate save
- Debounce prevents rapid saves

### Priority Recommendations

**HIGH PRIORITY - Tests for completed features:**
1. Inventory add/remove/stack logic tests
2. Layer depth/hardness verification tests
3. Wall-jump state transition tests
4. Player dig direction tests

**MEDIUM PRIORITY - Infrastructure for future features:**
5. DataRegistry ore loading tests (stub for when ores implemented)
6. Player tool damage integration tests

**LOW PRIORITY - Will be needed later:**
7. Save/load round-trip tests
8. Shop transaction tests
