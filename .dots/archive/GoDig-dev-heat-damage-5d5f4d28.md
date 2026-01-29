---
title: "implement: Heat damage system"
status: closed
close_reason: Implemented in session claude/next-ten-tasks-thE2H
priority: 3
issue-type: task
created-at: "2026-01-16T00:44:03.971404-06:00"
after:
  - GoDig-dev-layer-depth-89c9d8ac
---

## Description

Implement environmental heat damage in deep layers (Magma Zone at 2000m+). Players take continuous damage without heat protection equipment.

## Context

- Heat damage creates equipment progression gates
- Players must buy Heat Suit from Equipment Shop before exploring deep
- Creates risk/reward for exploring without protection
- See research: GoDig-research-hazards-environmental-f344e8b1

## Affected Files

- `scripts/player/player.gd` - Add heat damage tick handler
- `scripts/autoload/game_manager.gd` - Track current layer hazards
- `scripts/autoload/player_data.gd` - Track heat resistance (equipment)
- `scenes/ui/hud.tscn` - Add heat warning indicator

## Implementation Notes

### Heat Zone Detection

```gdscript
# player.gd additions
const HEAT_ZONE_START: int = 2000  # Depth in meters/blocks
const HEAT_DAMAGE_TICK: float = 2.0  # Seconds between damage
const HEAT_DAMAGE_BASE: int = 5  # HP per tick without protection

var _heat_timer: float = 0.0
var _in_heat_zone: bool = false

func _physics_process(delta: float) -> void:
    # ... existing code ...
    _check_heat_zone(delta)

func _check_heat_zone(delta: float) -> void:
    var current_depth := grid_position.y
    _in_heat_zone = current_depth >= HEAT_ZONE_START

    if _in_heat_zone:
        _heat_timer += delta
        if _heat_timer >= HEAT_DAMAGE_TICK:
            _heat_timer = 0.0
            _apply_heat_damage()

func _apply_heat_damage() -> void:
    var resistance := PlayerData.get_heat_resistance()
    var damage := int(HEAT_DAMAGE_BASE * (1.0 - resistance))
    if damage > 0:
        take_damage(damage, "heat")
```

### Heat Resistance Equipment

```gdscript
# player_data.gd additions
var heat_resistance: float = 0.0  # 0.0 to 1.0

func get_heat_resistance() -> float:
    # Base resistance + equipment bonuses
    var resistance := 0.0
    if has_equipment("heat_suit_1"):
        resistance += 0.5  # 50% reduction
    if has_equipment("heat_suit_2"):
        resistance += 0.3  # 80% total
    if has_equipment("heat_suit_3"):
        resistance += 0.2  # 100% total (immune)
    return minf(resistance, 1.0)
```

### Heat Suit Equipment Tiers

| Tier | Name | Cost | Resistance | Unlocks At |
|------|------|------|------------|------------|
| 1 | Basic Heat Suit | 5000 | 50% | 1500m |
| 2 | Advanced Heat Suit | 15000 | 80% | 2000m |
| 3 | Volcanic Suit | 50000 | 100% | 3000m |

### HUD Warning

When in heat zone without full protection:
- Show flame icon pulsing red
- Display "Heat: 5 HP/2s" damage rate
- Icon intensity increases with damage rate

```gdscript
# hud.gd
func _on_player_entered_heat_zone(damage_rate: int) -> void:
    heat_warning.visible = true
    heat_warning_label.text = "-%d HP" % damage_rate
    _start_heat_pulse_animation()

func _on_player_left_heat_zone() -> void:
    heat_warning.visible = false
```

### Visual Feedback

- Screen edge glow (orange/red) when taking heat damage
- Intensity scales with damage rate
- Player sprite tint slightly red while in heat zone

```gdscript
func _apply_heat_damage() -> void:
    # ... damage calculation ...
    if damage > 0:
        take_damage(damage, "heat")
        _flash_heat_overlay(damage / 10.0)  # Intensity based on damage

func _flash_heat_overlay(intensity: float) -> void:
    var tween := create_tween()
    heat_overlay.modulate.a = intensity
    tween.tween_property(heat_overlay, "modulate:a", 0.0, 0.5)
```

## Edge Cases

- Player enters heat zone, immediately leaves: Cancel timer, no damage
- Player has 100% resistance: No damage, no warning (comfortable)
- Player dies in heat zone: Respawn at surface with no heat effects
- Loading save in heat zone: Start timer immediately

## Verify

- [ ] Build succeeds
- [ ] No heat damage above 2000m depth
- [ ] 5 HP damage every 2 seconds at 2000m+ without protection
- [ ] Heat Suit 1 reduces damage to 2-3 HP/tick
- [ ] Heat Suit 3 (full set) prevents all heat damage
- [ ] HUD shows heat warning when taking damage
- [ ] Screen edge glows orange/red during heat damage
- [ ] Leaving heat zone stops damage immediately
- [ ] Heat resistance stacks correctly from equipment
