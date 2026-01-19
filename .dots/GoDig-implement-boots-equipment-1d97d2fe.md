---
title: "implement: Boots equipment for fall damage reduction"
status: open
priority: 2
issue-type: task
created-at: "2026-01-19T00:53:02.021108-06:00"
after:
  - GoDig-implement-fall-damage-bba5eee9
---

## Description

Add boots as an equipment slot that reduces fall damage by a percentage based on tier.

## Context

Boots provide a meaningful upgrade path for players who want to explore deep areas without ladders. Creates economic sink and progression milestone.

## Affected Files

- `resources/equipment/boots/` - Create BootsData resources
- `scripts/player/player.gd` - Apply boots damage reduction
- `scripts/autoload/player_stats.gd` - Track equipped boots
- `scenes/ui/equipment_panel.tscn` - Add boots slot (if using equipment UI)

## Implementation Notes

### BootsData Resource
```gdscript
# boots_data.gd
class_name BootsData extends Resource

@export var id: String = ''
@export var display_name: String = ''
@export var fall_damage_reduction: float = 0.0  # 0.0 to 1.0
@export var cost: int = 0
@export var unlock_depth: int = 0
@export var icon: Texture2D
```

### Boots Definitions
| ID | Name | Reduction | Cost | Unlock |
|----|------|-----------|------|--------|
| none | (No boots) | 0% | - | Start |
| leather_boots | Leather Boots | 20% | 500 | 50m |
| sturdy_boots | Sturdy Boots | 40% | 2,500 | 150m |
| shock_absorbers | Shock Absorbers | 60% | 10,000 | 400m |
| antigrav_boots | Anti-Grav Boots | 80% | 50,000 | 800m |

### Integration with Fall Damage
```gdscript
# player.gd
func apply_fall_damage(fall_tiles: int):
    if fall_tiles <= FALL_DAMAGE_THRESHOLD:
        return

    var excess_tiles = fall_tiles - FALL_DAMAGE_THRESHOLD
    var damage = excess_tiles * DAMAGE_PER_TILE

    # Apply boots reduction
    var boots = PlayerStats.get_equipped_boots()
    if boots:
        damage *= (1.0 - boots.fall_damage_reduction)

    damage = min(damage, MAX_FALL_DAMAGE)
    take_damage(int(damage), 'fall')
```

### Equipment Manager (if not exists)
```gdscript
# player_stats.gd
var equipped_boots: BootsData = null

func equip_boots(boots: BootsData):
    equipped_boots = boots
    boots_equipped.emit(boots)

func get_equipped_boots() -> BootsData:
    return equipped_boots
```

### Resource Files to Create
- `resources/equipment/boots/leather_boots.tres`
- `resources/equipment/boots/sturdy_boots.tres`
- `resources/equipment/boots/shock_absorbers.tres`
- `resources/equipment/boots/antigrav_boots.tres`

## Verify

- [ ] Build succeeds
- [ ] BootsData resources load correctly
- [ ] Boots can be equipped via PlayerStats
- [ ] Leather boots reduce fall damage by 20%
- [ ] Anti-grav boots reduce fall damage by 80%
- [ ] Boots appear in equipment/shop UI
- [ ] Boots are locked until unlock depth reached
- [ ] Equipped boots persist through save/load
