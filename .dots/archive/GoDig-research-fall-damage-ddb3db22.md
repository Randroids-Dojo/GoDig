---
title: "research: Fall damage and death"
status: closed
priority: 0
issue-type: task
created-at: "\"\\\"2026-01-18T23:39:36.857819-06:00\\\"\""
closed-at: "2026-01-19T00:53:07.892418-06:00"
close-reason: "Documented fall damage thresholds (4+ tiles), damage formula (10 HP/tile), death/respawn flow with depth-scaled penalties. Created 4 implementation dots: HP system, fall damage, death/respawn, boots equipment."
---

How does fall damage and death work? Questions: What fall height triggers damage? Does damage scale with height? What happens on death? (respawn at surface, lose items, lose coins?) Is there a death animation? How does respawn work? Are there items that reduce fall damage? (boots, parachute)

---

## Research Findings

### Player Health System

**Base Health**: 100 HP (simple mental model for players)

**Health Display**: Heart bar or HP number in HUD
- Visual feedback when taking damage (screen flash, shake)
- Low health warning at 25% (red tint, heartbeat sound)

### Fall Damage Thresholds

| Fall Distance | Damage | % of Max HP | Player Experience |
|---------------|--------|-------------|-------------------|
| 0-3 tiles (48px) | 0 | 0% | Safe jumps, normal gameplay |
| 4-6 tiles | 10-20 HP | 10-20% | Warning zone, ouch but survivable |
| 7-10 tiles | 30-50 HP | 30-50% | Dangerous, need to be careful |
| 11+ tiles | 60-100 HP | 60-100% | Critical/lethal without mitigation |

**Tile Size**: 16x16 pixels, so 1 tile = 16 pixels of fall

### Fall Damage Formula

```gdscript
const FALL_DAMAGE_THRESHOLD: int = 3  # tiles before damage starts
const DAMAGE_PER_TILE: float = 10.0   # base damage per tile above threshold
const MAX_FALL_DAMAGE: float = 100.0  # caps at max health

func calculate_fall_damage(fall_tiles: int) -> float:
    if fall_tiles <= FALL_DAMAGE_THRESHOLD:
        return 0.0

    var excess_tiles = fall_tiles - FALL_DAMAGE_THRESHOLD
    var damage = excess_tiles * DAMAGE_PER_TILE

    # Apply boot reduction
    damage *= (1.0 - equipment.boots_damage_reduction)

    # Apply surface softness
    damage *= get_surface_hardness_multiplier()

    return min(damage, MAX_FALL_DAMAGE)
```

### Surface Hardness Modifier

Landing surface affects damage:

| Surface | Damage Multiplier | Notes |
|---------|-------------------|-------|
| Dirt/soil | 0.8x | Soft landing |
| Stone | 1.0x | Normal |
| Metal/ore | 1.2x | Hard landing |
| Water | 0.3x | Cushions fall significantly |

### Fall Damage Mitigation Items

**Boots (Equipment Slot)**

| Tier | Reduction | Cost | Unlock Depth |
|------|-----------|------|--------------|
| None | 0% | - | Start |
| Leather Boots | 20% | 500 | 50m |
| Sturdy Boots | 40% | 2,500 | 150m |
| Shock Absorbers | 60% | 10,000 | 400m |
| Anti-Grav Boots | 80% | 50,000 | 800m |

**Parachute (Late Game)**
- Consumable or cooldown-based
- Activates on long fall (player presses button)
- Negates fall damage entirely
- Unlocks at 500m depth

---

## Death System

### Death Triggers
1. **HP reaches 0** from fall damage
2. **HP reaches 0** from environmental damage (lava, gas, etc.)
3. **Instant death** from lava contact (deep zones only)

### Death Penalty (Already Decided in death-respawn-decision.md)

**Depth-Scaled Penalty:**

| Depth Zone | Inventory Loss | Coin Loss | Equipment Damage |
|------------|----------------|-----------|------------------|
| 0-500m | 10% | 0% | Minor (5% durability) |
| 500-2000m | 20% | 5% | Moderate (15% durability) |
| 2000m+ | 30% | 10% | Heavy (25% durability) |

### Respawn Flow

```
Player HP hits 0
    |
    v
Death animation plays (1-2 seconds)
    |
    v
Screen fades to black
    |
    v
Calculate death penalty based on current depth
    |
    v
Apply penalty (remove inventory %, coins, damage equipment)
    |
    v
Teleport to surface spawn point
    |
    v
Fade in with "You blacked out..." message
    |
    v
Full HP restored, gameplay resumes
```

### Death Animation Options

**Simple (MVP):**
- Player sprite turns red/flashes
- Falls/collapses in place
- Poof/particle effect
- Fade to black

**Enhanced (v1.0):**
- Specific death animations per cause:
  - Fall: Splat, flattened briefly
  - Lava: Burn up, ash particles
  - Gas: Cough, collapse
- Screen shake on impact deaths
- Sound effect per death type

### Death Message Examples

- "You blacked out and woke up on the surface."
- "The rescue team found you unconscious. Some of your cargo was lost."
- "You barely escaped with your life. Better prepare next time."

---

## Implementation Priority

**MVP (Must Have):**
1. Fall damage tracking (distance fallen)
2. HP system with damage and death
3. Simple death + respawn at surface
4. Basic inventory loss penalty

**v1.0 (Should Have):**
1. Boots equipment reducing fall damage
2. Surface hardness modifier
3. Death animation
4. Depth-scaled penalties
5. Equipment durability damage

**v1.1+ (Nice to Have):**
1. Parachute item
2. Per-cause death animations
3. Death statistics tracking

---

## Questions Resolved

- [x] What fall height triggers damage? -> **4+ tiles (64+ pixels)**
- [x] Does damage scale with height? -> **Yes, 10 HP per tile above threshold**
- [x] What happens on death? -> **Respawn at surface, lose 10-30% inventory based on depth**
- [x] Is there a death animation? -> **Yes, simple for MVP (flash + fade)**
- [x] How does respawn work? -> **Fade to black, teleport to surface, restore HP**
- [x] Items that reduce fall damage? -> **Boots (20-80% reduction), Parachute (100%)**

---

## Implementation Tasks Created

1. `implement: Player HP system` - Health tracking, damage, death detection
2. `implement: Fall damage calculation` - Distance tracking, damage formula
3. `implement: Death and respawn flow` - Animation, penalty, teleport
4. `implement: Boots equipment for fall reduction` - Equipment slot, damage modifier
