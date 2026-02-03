---
title: "implement: Close-call celebration when player narrowly escapes"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-01T02:01:27.359146-06:00\\\"\""
closed-at: "2026-02-03T03:09:45.108621-06:00"
close-reason: Implemented close-call detection with 4 conditions (last-ladder, low-HP, full-inventory, depth-record), celebration effects (particles, flash, haptic, toast), and narrow_escape achievement
---

## Description
Celebrate clever escapes - when player returns to surface with 0-1 ladders remaining while deep, or reaches new depth record + returns safely. Makes players feel smart for their escape.

## Context
From Session 5 research on push-your-luck design:
- SteamWorld Dig developers knew they hit the sweet spot when "testers fell down a hole, sweated a bit, then found a clever way of getting back up again, feeling awesome"
- Player agency creates satisfaction - when players make creative escapes, celebrate it
- The "aha" moment when game validates player's clever solution = engagement

## Close-Call Detection Conditions

Detect these situations when player reaches surface:

### 1. Last-Ladder Escape
- Player returns with 0-1 ladders remaining
- AND max depth this trip was >= 30m
- Message: "Close call! Made it back with [X] ladder(s)!"

### 2. Low-HP Return
- Player returns with <30% HP
- AND had loot in inventory
- Message: "Barely made it! HP: [X]%"

### 3. Full-Inventory Clutch
- Player returns with full inventory (8/8 slots)
- AND 0-2 ladders remaining
- Message: "Perfect haul! Not a slot wasted!"

### 4. Depth Record Escape
- Player achieved new personal depth record this trip
- AND returned safely with loot
- Message: "NEW RECORD: [X]m! And you made it back!"

### 5. Multi-Condition "Hero Return"
- 2+ conditions met simultaneously
- Special celebration: "LEGENDARY ESCAPE!"
- Extra particle effects, longer celebration

## Implementation

### Detection Logic (in game_manager.gd or player.gd)
```gdscript
func _check_close_call_conditions() -> Dictionary:
    var conditions := {
        "last_ladder": ladder_count <= 1 and max_trip_depth >= 30,
        "low_hp": current_hp / max_hp < 0.3 and inventory_has_loot(),
        "full_inventory": inventory_is_full() and ladder_count <= 2,
        "depth_record": broke_depth_record_this_trip and inventory_has_loot(),
    }
    return conditions
```

### Celebration Effects
1. **Toast message** showing which condition(s) triggered
2. **Particle burst** around player on surface arrival
3. **Sound effect** - satisfying "relief" sound (exhale/sigh/chime)
4. **Brief screen flash** (white, 0.1s) for multi-condition hero return
5. **Achievement check** - "Narrow Escape" achievement for first close call

### Visual Design
```
[ Normal return ]
Player reaches surface -> small "Welcome back" toast

[ Close-call return ]
Player reaches surface ->
  [Screen brightens slightly]
  [Particle burst: stars/sparkles]
  Toast: "CLOSE CALL! Made it with 1 ladder!"
  [Satisfying chime sound]
```

### Tracking Requirements
- Track `max_depth_this_trip` - reset on surface arrival
- Track `broke_depth_record_this_trip` - compare against PlayerData.max_depth_reached
- Track `ladders_at_trip_start` vs `ladders_now` for ladder usage

## Affected Files
- `scripts/player/player.gd` - Surface arrival detection
- `scripts/autoload/game_manager.gd` - Trip tracking, close-call check
- `scripts/ui/hud.gd` - Toast display
- `scripts/effects/celebration_particles.gd` - Particle effect
- `scripts/autoload/achievement_manager.gd` - "Narrow Escape" achievement

## Related Specs
- `GoDig-implement-safe-return-a8427f4a` - Safe return celebration (simpler version)
- `GoDig-implement-depth-record-a080d43a` - Depth record tracking

## Verify
- [ ] Last-ladder escape triggers celebration (0-1 ladders, 30m+ depth)
- [ ] Low-HP return triggers celebration (<30% HP with loot)
- [ ] Full-inventory clutch triggers celebration (8/8 slots, few ladders)
- [ ] Depth record + return triggers celebration
- [ ] Multi-condition returns get enhanced "hero" celebration
- [ ] Normal returns don't spam celebrations
- [ ] Celebrations feel rewarding not annoying
- [ ] Achievement "Narrow Escape" unlocks on first close call
