# Combat & Enemies Decision

## Overview
Should GoDig include enemies and combat mechanics, or focus purely on mining, traversal, and economy?

## Option Analysis

### Option A: No Enemies (Pure Mining)

**How It Works:**
- Focus entirely on digging, collecting, upgrading
- Hazards are environmental only (lava, gas, collapse)
- No combat system needed
- Player vs environment

**Pros:**
- Simpler scope (faster MVP)
- Clear identity: "mining game" not "action game"
- No combat balance needed
- Relaxing gameplay
- Broader audience appeal
- Fewer animations required

**Cons:**
- Less variety in gameplay
- May feel repetitive long-term
- Missing tension source
- Less reason for some upgrades (armor)

**Games Using This:**
- Motherload (original)
- Most idle miners
- Mining Tycoon games

### Option B: Full Combat System

**How It Works:**
- Enemies spawn in deeper zones
- Player has weapons/attacks
- Health system with death penalty
- Armor reduces damage
- Enemy variety by depth

**Pros:**
- More gameplay variety
- Justifies equipment upgrades
- Tension in deep zones
- Longer engagement potential

**Cons:**
- Significantly larger scope
- Combat balance is complex
- Touch controls for combat are tricky
- Diverts from core mining identity
- More animations, AI, systems needed

**Games Using This:**
- SteamWorld Dig 2 (enemies + combat)
- Terraria (extensive combat)
- Deep Rock Galactic

### Option C: Light Enemy Presence (Hybrid)

**How It Works:**
- Rare enemies in deep zones only
- Simple AI (patrol, chase)
- Pickaxe is weapon (no separate combat)
- Avoidance is viable strategy
- Limited enemy types (3-5 total)

**Pros:**
- Adds variety without full combat system
- Pickaxe as weapon = no new mechanics
- Deep zones feel dangerous
- Limited scope increase
- Equipment (armor) has purpose

**Cons:**
- Still requires AI, animations
- Must balance "mining game with enemies"
- Touch controls for combat still needed
- Can feel half-baked if not done well

---

## Decision Factors

### Scope Impact
| Approach | Dev Time | Art Assets | Systems |
|----------|----------|------------|---------|
| No enemies | Low | None | None |
| Light enemies | Medium | 3-5 sprites | Simple AI |
| Full combat | High | 10+ sprites | AI, weapons, balance |

### Mobile Considerations
- Touch combat is notoriously difficult
- Precise aiming/timing is frustrating
- Players expect relaxing mobile games
- Combat increases battery usage

### Core Identity
> Is GoDig a "mining game" or an "action game with mining"?

**Recommendation:** Mining game first, action secondary (if at all)

---

## Recommendation: **No Enemies at Launch (Option A)**

### MVP/v1.0 Approach:
- Focus on mining, economy, progression
- Environmental hazards provide danger:
  - Lava pools (instant death)
  - Gas pockets (damage over time)
  - Unstable blocks (collapse)
  - Water (slows movement)
  - Darkness (limited visibility)

### v1.1+ Consideration:
- **Light enemies as optional content**
- Unlock "Infested Zones" after completing base game
- Keep as optional side content, not required progression

---

## Environmental Hazards (Alternative to Enemies)

### Hazard Types
| Hazard | Depth | Effect | Counter |
|--------|-------|--------|---------|
| Water | 50m+ | Slows movement | None needed |
| Darkness | 100m+ | Limited vision | Helmet light |
| Gas pockets | 300m+ | Poison damage | Gas mask |
| Unstable rock | 500m+ | Collapse damage | Watch for cracks |
| Lava | 1000m+ | Instant death | Avoid/heat suit |
| Void mist | 3000m+ | Confusion effect | Special gear |

### Why Hazards > Enemies
1. **No AI needed** - Static/predictable behavior
2. **No combat mechanics** - Just avoid/counter
3. **Fits mining theme** - Natural underground dangers
4. **Equipment purpose** - Gear counters hazards
5. **Mobile-friendly** - No reaction-based combat

---

## If Adding Enemies Later (v1.1+)

### Design Guidelines:
```
1. Limited to optional "Infested Zones"
2. Pickaxe is primary weapon (no separate combat)
3. Simple AI: patrol, chase, attack
4. 3-5 enemy types max
5. Avoidance always viable
6. Not required for progression
```

### Potential Enemy Types:
| Enemy | Zone | Behavior | Threat |
|-------|------|----------|--------|
| Cave Bat | Crystal | Flies, swoops | Low |
| Rock Crawler | Deep Stone | Patrols, slow | Low |
| Lava Slime | Magma | Bounces, splits | Medium |
| Void Wraith | Void | Phases, fast | High |

### Implementation Approach:
```gdscript
# Simple enemy that pickaxe can defeat
class_name CaveBat extends CharacterBody2D

@export var health: int = 2  # 2 pickaxe hits to kill
@export var damage: int = 10
@export var detection_range: float = 100.0

enum State { IDLE, CHASE, ATTACK }
var state: State = State.IDLE

func take_damage(amount: int):
    health -= amount
    if health <= 0:
        queue_free()
        # Drop loot
```

---

## Questions Resolved
- [x] Enemies at launch? → **No** (focus on mining)
- [x] Combat system? → **No** (pickaxe-only if added later)
- [x] Danger source? → Environmental hazards
- [x] Future enemies? → Optional v1.1+ "Infested Zones"

---

## Summary

**Decision: No enemies for MVP and v1.0**

GoDig is a mining game first. Environmental hazards provide sufficient danger and tension without the complexity of combat systems. Enemies may be added as optional content in v1.1+ for players seeking more challenge, but the core game loop should work without them.

This decision:
- Reduces development scope significantly
- Maintains clear game identity
- Improves mobile experience
- Allows focus on polishing core mechanics
- Keeps option open for future expansion
