---
title: "research: Fall damage and death"
status: done
priority: 0
issue-type: task
created-at: "2026-01-18T23:39:36.857819-06:00"
---

How does fall damage and death work? Questions: What fall height triggers damage? Does damage scale with height? What happens on death? (respawn at surface, lose items, lose coins?) Is there a death animation? How does respawn work? Are there items that reduce fall damage? (boots, parachute)

## Research Findings (Verified 2026-01-19)

### Current Implementation Status: MOSTLY COMPLETE

Fall damage and HP system are implemented in `scripts/player/player.gd`. Death signal exists but full death/respawn handling needs a separate system.

### Answer to Research Questions

**1. What fall height triggers damage?**
- `FALL_DAMAGE_THRESHOLD = 3` blocks
- Falls of 3 or fewer blocks cause no damage
- Damage starts at 4+ blocks

**2. Does damage scale with height?**
- YES: `DAMAGE_PER_BLOCK = 10.0`
- Formula: `damage = (fall_blocks - 3) * 10`
- Example: 6 block fall = (6-3) * 10 = 30 damage
- `MAX_FALL_DAMAGE = 100.0` (caps damage)

**3. What happens on death?**
- `player_died` signal emitted with cause string
- `TestLevel._on_player_died()` receives signal (currently just logs)
- **NOT YET IMPLEMENTED**: Respawn, inventory loss, coin penalty

**4. Is there a death animation?**
- No dedicated death animation
- Just red flash on damage (`_start_damage_flash()`)
- TODO: Add death animation/ragdoll

**5. How does respawn work?**
- `Player.revive(hp_amount)` method exists
- Resets `is_dead` flag, restores HP
- **NOT YET IMPLEMENTED**: Auto-respawn, respawn location, penalties

**6. Are there items that reduce fall damage?**
- Code has placeholder comment: `# damage *= (1.0 - boots_reduction)`
- **NOT YET IMPLEMENTED**: Boots equipment system
- See `GoDig-implement-boots-equipment-1d97d2fe`

### HP System Implementation

**Constants:**
```gdscript
const MAX_HP: int = 100
const LOW_HP_THRESHOLD: float = 0.25  # 25% for low health warning
```

**Key Methods:**
- `take_damage(amount, source)` - Reduces HP, emits signal, calls die() if zero
- `heal(amount)` - Increases HP up to max
- `full_heal()` - Restores to MAX_HP
- `die(cause)` - Sets is_dead flag, emits player_died signal
- `revive(hp_amount)` - Resets death state, restores HP

**Signals:**
- `hp_changed(current_hp, max_hp)` - Emitted on any HP change
- `player_died(cause)` - Emitted on death

**Visual Feedback:**
- Red flash on damage (0.1s duration)
- HUD health bar connected via `hud.connect_to_player(player)`

### Fall Tracking

**State Variables:**
- `_fall_start_y: float` - Y position when fall started
- `_is_tracking_fall: bool` - Whether currently tracking a fall

**Flow:**
1. `_start_falling()` - Sets `_is_tracking_fall = true`, records `_fall_start_y`
2. `_handle_falling()` - Applies gravity, checks for landing
3. `_start_wall_slide()` - Resets tracking (wall grab cancels fall damage)
4. `_land_on_grid()` - Calculates fall distance, calls `_apply_fall_damage()`

### Gaps Identified

1. **Death/Respawn System** - `player_died` signal exists but no handler
   - Need: Respawn location, animation, penalties
   - See: `GoDig-implement-death-and-fd4aaba6`

2. **Boots Equipment** - Fall damage reduction not implemented
   - See: `GoDig-implement-boots-equipment-1d97d2fe`

3. **Low Health Warning** - Threshold defined but no visual effect
   - Need: Red vignette, heartbeat sound

### No Further Work Needed for This Research

Fall damage calculation is complete. Death/respawn handling is a separate implementation task.
