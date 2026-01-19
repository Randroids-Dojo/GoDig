---
title: "implement: Backpack upgrade system"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T00:43:21.066182-06:00"
after:
  - GoDig-dev-inventory-ui-71ea78b3
---

## Description

Allow players to upgrade their backpack capacity from the starting 8 slots to larger sizes (12, 16, 20, 25, 30). Upgrades are purchased at the shop and persist across sessions.

## Context

Inventory pressure is a core game mechanic - limited slots force return-to-surface loops. Backpack upgrades reduce trips while maintaining the pressure. The progression:
- Early game: Frequent returns (8 slots fills fast)
- Mid game: Longer expeditions (16-20 slots)
- Late game: Extended deep dives (25-30 slots)

## Affected Files

- `scripts/autoload/inventory_manager.gd` - Add max_slots variable, upgrade method
- `scripts/autoload/player_data.gd` - Store backpack_tier
- `resources/upgrades/backpack_upgrades.gd` - Define upgrade tiers and costs
- `scripts/ui/shop.gd` - Add backpack upgrade purchase option
- `scripts/autoload/save_manager.gd` - Persist backpack tier

## Implementation Notes

### Backpack Upgrade Tiers

```gdscript
# resources/upgrades/backpack_data.gd
const BACKPACK_TIERS := [
    { "tier": 1, "slots": 8, "cost": 0, "name": "Starter Pouch" },
    { "tier": 2, "slots": 12, "cost": 100, "name": "Small Backpack" },
    { "tier": 3, "slots": 16, "cost": 300, "name": "Medium Backpack" },
    { "tier": 4, "slots": 20, "cost": 700, "name": "Large Backpack" },
    { "tier": 5, "slots": 25, "cost": 1500, "name": "Deluxe Backpack" },
    { "tier": 6, "slots": 30, "cost": 3500, "name": "Miner's Rucksack" },
]
```

### InventoryManager Changes

```gdscript
# inventory_manager.gd
var max_slots: int = 8  # Updated on upgrade

signal slots_upgraded(new_max: int)

func set_max_slots(slots: int) -> void:
    max_slots = slots
    slots_upgraded.emit(max_slots)
    # Note: existing items are preserved, just more room now

func get_max_slots() -> int:
    return max_slots

func can_add_item(_item: ItemData, count: int = 1) -> bool:
    # Check if there's room in existing stacks or empty slots
    # ... existing logic, uses max_slots ...
```

### PlayerData Storage

```gdscript
# player_data.gd
var backpack_tier: int = 1

func upgrade_backpack() -> bool:
    var next_tier := backpack_tier + 1
    var tiers := BackpackData.BACKPACK_TIERS

    if next_tier > tiers.size():
        return false  # Max tier reached

    var upgrade := tiers[next_tier - 1]
    if coins < upgrade.cost:
        return false  # Can't afford

    coins -= upgrade.cost
    backpack_tier = next_tier
    InventoryManager.set_max_slots(upgrade.slots)
    return true

func get_next_backpack_upgrade() -> Dictionary:
    var next_tier := backpack_tier + 1
    if next_tier > BackpackData.BACKPACK_TIERS.size():
        return {}  # Max reached
    return BackpackData.BACKPACK_TIERS[next_tier - 1]
```

### Shop Integration

```gdscript
# shop.gd
func _populate_upgrades() -> void:
    # ... other upgrades ...

    var backpack_upgrade := PlayerData.get_next_backpack_upgrade()
    if backpack_upgrade.size() > 0:
        _add_upgrade_button(
            backpack_upgrade.name,
            backpack_upgrade.cost,
            "Increases inventory to %d slots" % backpack_upgrade.slots,
            _on_backpack_upgrade_pressed
        )

func _on_backpack_upgrade_pressed() -> void:
    if PlayerData.upgrade_backpack():
        _update_ui()
        # Play upgrade sound
        # Show success message
```

### UI Updates

When backpack is upgraded:
1. Inventory HUD should show new slot count
2. Shop should show next upgrade or "MAX" if fully upgraded
3. Optional: Toast notification "Backpack upgraded! (16 slots)"

```gdscript
# inventory_hud.gd
func _on_slots_upgraded(new_max: int) -> void:
    # Update display
    slot_count_label.text = "%d/%d" % [InventoryManager.get_item_count(), new_max]
    # Redraw slot grid if visible
```

### Save/Load

```gdscript
# save_manager.gd - in save data
func get_save_data() -> Dictionary:
    return {
        # ... other data ...
        "backpack_tier": PlayerData.backpack_tier,
    }

func load_save_data(data: Dictionary) -> void:
    # ... other loading ...
    if data.has("backpack_tier"):
        PlayerData.backpack_tier = data.backpack_tier
        var tier_data := BackpackData.BACKPACK_TIERS[PlayerData.backpack_tier - 1]
        InventoryManager.set_max_slots(tier_data.slots)
```

## Edge Cases

- Upgrade while inventory is full: Works fine (just adds empty slots)
- Downgrade (shouldn't happen): Not supported
- Max tier reached: Hide upgrade button or show "MAX"
- Loading old save without backpack_tier: Default to tier 1 (8 slots)

## Verify

- [ ] Build succeeds
- [ ] New game starts with 8 slots
- [ ] Shop shows backpack upgrade with cost
- [ ] Purchasing upgrade increases max slots
- [ ] Coins are deducted on purchase
- [ ] Inventory HUD updates to show new capacity
- [ ] Upgraded capacity persists after save/load
- [ ] Max tier shows no further upgrade available
- [ ] Existing items preserved when upgrading
