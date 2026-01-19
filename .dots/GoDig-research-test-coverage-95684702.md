---
title: "research: Test coverage gaps in MVP implementation specs"
status: done
priority: 2
issue-type: task
created-at: "2026-01-18T23:27:04.208517-06:00"
---

Review Verify sections in implementation specs and identify which criteria are not covered by current tests. Recommend additional tests for inventory, player, and future chunk/ore systems.

## Research Findings (2026-01-19)

### Current Test Coverage Summary

| Test File | Test Count | Coverage Area |
|-----------|------------|---------------|
| test_hello_world.py | 63 | Scene structure, node existence |
| test_mining.py | 40 | Mining mechanics, block breaking |
| test_layers.py | 37 | Layer system, depth-based colors |
| test_inventory.py | 26 | Inventory add/remove/stack |
| test_player_states.py | 19 | Player state machine |
| test_player_hp.py | 17 | HP system, damage, death |
| test_fall_damage.py | 12 | Fall damage calculation |
| test_floating_text.py | 4 | Floating text UI |
| **Total** | **218** | |

### Well-Covered Areas

**Inventory System** (26 tests)
- Add item to empty/full inventory
- Stacking within max_stack limits
- Overflow when inventory full
- Remove item (partial, full, fail)
- Clear all
- Upgrade capacity
- Serialization (to_dict)
- Death penalty helpers (remove_random_item)

**Player HP** (17 tests)
- take_damage reduces HP
- heal increases HP (capped at max)
- die() sets is_dead flag
- revive() restores HP
- HP signals emitted

**Fall Damage** (12 tests)
- No damage at threshold (3 blocks)
- Damage scales with height
- Max damage cap
- Wall-slide cancels fall tracking

**Mining** (40 tests)
- Block hit reduces health
- Block destruction
- Ore spawning at depth
- Tool damage application

### Gap Analysis: Missing Tests

**1. Shop System**
- No tests for shop UI
- No tests for sell flow
- No tests for upgrade purchase
- **Recommendation**: Add `test_shop.py`

**2. Save/Load System**
- No tests for SaveManager
- No tests for chunk persistence
- No tests for save slot selection
- **Recommendation**: Add `test_save_load.py`

**3. Ore Drop to Inventory**
- Mining tests don't verify inventory receives items
- block_dropped signal not tested end-to-end
- **Recommendation**: Add integration test in test_mining.py

**4. Pause Menu**
- No tests for pause/resume
- No tests for rescue functionality
- No tests for reload save
- **Recommendation**: Add `test_pause_menu.py`

**5. Touch Controls**
- Node existence tested but no interaction tests
- Virtual joystick direction output not tested
- **Recommendation**: Add `test_touch_controls.py`

**6. Depth Milestones**
- GameManager.current_depth tested but not milestone signals
- Depth label update not tested
- **Recommendation**: Add milestone tests to test_hello_world.py

**7. Tool System**
- PlayerData.get_equipped_tool() not tested
- Tool upgrade flow not tested
- Tool damage values not verified
- **Recommendation**: Add `test_tools.py`

### Recommended Test Additions

**High Priority (MVP-blocking):**
1. Shop sell flow (items removed, coins added)
2. Mining produces inventory items
3. Save/Load round-trip

**Medium Priority:**
1. Pause menu rescue/reload
2. Depth milestone notifications
3. Tool upgrade purchase

**Low Priority:**
1. Touch controls input
2. Floating text styling
3. Settings persistence

### No Implementation Dot Needed

This research is informational. Test improvements should be added organically as implementations are verified.
