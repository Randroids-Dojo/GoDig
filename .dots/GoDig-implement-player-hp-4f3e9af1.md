---
title: "implement: Player HP system"
status: open
priority: 1
issue-type: task
created-at: "2026-01-19T00:52:14.726848-06:00"
---

## Description

Add a health points (HP) system to the player with damage tracking, death detection, and HUD display.

## Context

HP is the foundation for fall damage, environmental hazards, and the death/respawn system. Simple 100 HP model for easy player understanding.

## Affected Files

- `scripts/player/player.gd` - Add HP property, damage methods
- `scripts/autoload/player_stats.gd` - Store max_hp, current_hp if using singleton
- `scenes/ui/hud.tscn` - Add health bar/hearts display
- `scripts/ui/hud.gd` - Update health display

## Implementation Notes

### Player HP Properties
```gdscript
# player.gd
const MAX_HP: int = 100
var current_hp: int = MAX_HP

signal hp_changed(new_hp: int, max_hp: int)
signal player_died

func take_damage(amount: int, source: String = 'unknown'):
    current_hp = max(0, current_hp - amount)
    hp_changed.emit(current_hp, MAX_HP)

    if current_hp <= 0:
        die(source)

func heal(amount: int):
    current_hp = min(MAX_HP, current_hp + amount)
    hp_changed.emit(current_hp, MAX_HP)

func die(cause: String):
    player_died.emit()
    # Death handling in separate system
```

### HUD Health Display
- Option A: Heart icons (3 hearts = 100 HP)
- Option B: Simple bar with number
- Recommend: Bar for mobile readability

### Visual Feedback on Damage
```gdscript
func take_damage(amount: int, source: String = 'unknown'):
    # Flash red
    modulate = Color.RED
    await get_tree().create_timer(0.1).timeout
    modulate = Color.WHITE

    # Screen shake for big hits
    if amount >= 25:
        camera.shake(0.2, 5)
```

### Low Health Warning
- At 25% HP: Red screen vignette
- Heartbeat sound effect (optional)

## Verify

- [ ] Build succeeds
- [ ] Player has 100 HP at start
- [ ] take_damage() reduces HP correctly
- [ ] HP cannot go below 0 or above MAX_HP
- [ ] hp_changed signal fires on damage/heal
- [ ] player_died signal fires when HP reaches 0
- [ ] HUD displays current HP
- [ ] Visual flash on damage
- [ ] Low health warning at 25%
