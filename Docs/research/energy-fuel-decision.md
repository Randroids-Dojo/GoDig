# Energy/Fuel Mechanic Decision

## Overview
Should the game include an energy or fuel mechanic that limits mining time, or rely purely on inventory pressure to drive return trips?

## Option Analysis

### Option A: No Energy Mechanic (Inventory-Only)

**How It Works:**
- Player can mine indefinitely
- Only limitation is inventory space
- Return to surface driven by full inventory or strategic choice

**Pros:**
- Simpler system, easier to understand
- No frustrating "out of fuel" moments
- Player has full control over session length
- More casual-friendly
- Mobile-appropriate (sessions can be any length)

**Cons:**
- Less time pressure
- Player might stay underground too long
- May reduce urgency/tension

**Games Using This:**
- SteamWorld Dig (lantern refills in caves)
- Most idle miners

### Option B: Fuel Mechanic (Motherload-Style)

**How It Works:**
- Player has fuel tank that depletes over time
- Must return to surface before running out
- Can upgrade tank capacity

**Pros:**
- Creates time pressure and urgency
- Forces return trips (game loop enforcement)
- Adds resource management layer
- Upgrades feel meaningful

**Cons:**
- Can feel punishing
- Interrupts "flow state" of digging
- Frustrating if you find rare ore but must leave
- Adds complexity
- Poor fit for mobile (unpredictable interruptions)

**Games Using This:**
- Motherload (fuel is core mechanic)
- Mining Tycoon games

### Option C: Soft Energy System (Hybrid)

**How It Works:**
- Stamina/health that depletes slowly
- Hazards deplete it faster
- Can restore with consumables or resting
- Not instant death when depleted

**Pros:**
- Creates soft pressure without hard failure
- Hazards become more meaningful
- Consumables have purpose
- Player can push their luck

**Cons:**
- More complex than inventory-only
- May still feel restrictive

---

## Decision Factors

### Mobile Considerations
- Players get interrupted (phone calls, notifications)
- Short session preference (5-15 minutes)
- Hard failure states are frustrating
- "Can't put down" is bad for mobile

### Core Loop Impact
| Mechanic | Session Driver | Tension Level | Frustration Risk |
|----------|---------------|---------------|------------------|
| Inventory-only | Full bag | Low-Medium | Low |
| Fuel | Time limit | High | High |
| Soft energy | Health depletion | Medium | Medium |

### Target Experience
> "Relaxing dig-down adventure with moments of tension"

---

## Recommendation: **No Energy Mechanic (Option A)**

### Rationale:
1. **Mobile-first design** - Fuel timers are poor fit for interrupted play
2. **Inventory pressure is sufficient** - Limited slots naturally drive return trips
3. **Hazards add tension** - Deep zones have environmental dangers instead
4. **Upgrades still matter** - Inventory expansion, tools, gear all meaningful
5. **Competitive precedent** - SteamWorld Dig proved it works

### How to Maintain Tension Without Fuel:
- **Inventory limits** - Forces decisions about what to keep
- **Environmental hazards** - Damage from lava, gas, enemies
- **Death penalty** - Lose some items on death
- **Risk/reward** - Valuable ores in dangerous places
- **Stuck situations** - Strategic planning required

### Mitigating "Underground Forever":
- **Diminishing returns** - Ore spawns thin out in heavily-mined areas
- **Darkness pressure** - Limited light radius encourages surface trips
- **Shop discounts** - Time-limited deals create urgency
- **Event notifications** - "Merchant caravan arriving in 5 minutes"

---

## Implementation Notes

### If Adding Energy Later (v1.1+):
```gdscript
# Optional stamina system for harder difficulty mode
@export var use_stamina: bool = false
@export var max_stamina: float = 100.0
var current_stamina: float = 100.0

func _process(delta):
    if use_stamina and is_underground:
        current_stamina -= delta * stamina_drain_rate
        if current_stamina <= 0:
            # Force return to surface, not death
            trigger_emergency_teleport()
```

### Difficulty Modes (Future)
| Mode | Fuel | Inventory | Hazards |
|------|------|-----------|---------|
| Casual | None | Generous | Mild |
| Normal | None | Standard | Standard |
| Hardcore | Yes | Limited | Dangerous |

---

## Questions Resolved
- [x] Fuel mechanic? → **No** (inventory-only at launch)
- [x] Tension source? → Inventory limits + environmental hazards
- [x] Future fuel option? → Possible hardcore mode in v1.1+

---

## Summary

**Decision: No fuel/energy mechanic for MVP and v1.0**

The inventory system provides sufficient return-trip motivation, and environmental hazards in deeper zones add tension. A fuel mechanic would frustrate mobile players and add unnecessary complexity. This can be revisited as an optional hardcore mode in future versions.
