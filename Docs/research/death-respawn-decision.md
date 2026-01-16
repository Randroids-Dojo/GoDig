# Death & Respawn Mechanics Decision

## Overview
How does death work in GoDig? What penalties exist? Is there a permadeath option?

## Questions to Resolve
From hazards-challenges.md:
- Permadeath option or always respawn?
- How severe should resource loss be on death?
- Enemies in addition to hazards for v1.0?
- Can hazards destroy player-placed structures?
- Tutorial for each new hazard type?

---

## Death Causes

### Environmental Hazards
| Hazard | Effect | Depth |
|--------|--------|-------|
| Fall damage | Health loss | Any |
| Lava | Instant death | 1000m+ |
| Gas pockets | Damage over time | 300m+ |
| Collapse | Heavy damage | 500m+ |
| Void mist | Confusion + damage | 3000m+ |

### Other Death Sources
- Starvation (if energy system added later)
- Enemies (if added in v1.1+)
- Getting stuck with no escape (very rare)

---

## Death Penalty Options

### Option A: No Penalty (Casual)
**On Death:**
- Respawn at surface
- Keep all inventory
- No coin loss

**Pros:**
- Zero frustration
- Mobile-friendly casual feel
- No anxiety about losing progress

**Cons:**
- No risk = less tension
- May feel pointless
- Undermines hazard importance

### Option B: Light Penalty (Balanced)
**On Death:**
- Respawn at surface
- Lose 10-25% of current inventory (random items)
- Keep coins

**Pros:**
- Creates meaningful risk
- Not devastating
- Encourages caution

**Cons:**
- Can lose rare items (frustrating)
- May feel arbitrary

### Option C: Medium Penalty (Challenging)
**On Death:**
- Respawn at surface
- Drop all inventory at death location
- Corpse run to recover
- Items despawn after X minutes

**Pros:**
- High tension
- Corpse run creates gameplay
- True risk/reward

**Cons:**
- Can lose everything to repeat deaths
- Frustrating for casual players
- Complex to implement

### Option D: Scaling Penalty (Adaptive)
**On Death:**
- Penalty scales with depth
- Surface deaths: No penalty
- Deep deaths: Lose % of inventory
- Very deep: Drop at location

**Pros:**
- Eases in new players
- Deep zones feel dangerous
- Flexible experience

**Cons:**
- Complex rules to understand
- May feel inconsistent

---

## Recommendation: **Light Penalty + Depth Scaling (Option B+D Hybrid)**

### Death Mechanics:

#### Standard Death (0-500m)
- Respawn at surface
- Lose 10% of inventory (random selection)
- Keep all coins
- "You blacked out and woke up on the surface"

#### Deep Death (500-2000m)
- Respawn at surface
- Lose 20% of inventory
- Lose 5% of current coins (not lifetime)
- Equipment damaged (repair cost)

#### Abyss Death (2000m+)
- Respawn at surface
- Lose 30% of inventory
- Lose 10% of coins
- Equipment heavily damaged
- "The depths nearly claimed you"

### Implementation:
```gdscript
func calculate_death_penalty(depth: int) -> Dictionary:
    var penalty = {
        "inventory_loss_percent": 0.1,
        "coin_loss_percent": 0.0,
        "equipment_damage": 0.0
    }

    if depth >= 500:
        penalty.inventory_loss_percent = 0.2
        penalty.coin_loss_percent = 0.05
        penalty.equipment_damage = 0.1

    if depth >= 2000:
        penalty.inventory_loss_percent = 0.3
        penalty.coin_loss_percent = 0.10
        penalty.equipment_damage = 0.25

    return penalty

func apply_death_penalty():
    var penalty = calculate_death_penalty(current_depth)

    # Randomly remove % of inventory items
    var items_to_lose = floor(inventory.count() * penalty.inventory_loss_percent)
    for i in range(items_to_lose):
        var random_slot = randi() % inventory.slots.size()
        inventory.remove_random_from_slot(random_slot)

    # Lose coins
    coins -= floor(coins * penalty.coin_loss_percent)

    # Damage equipment
    equipment.apply_damage(penalty.equipment_damage)
```

---

## Permadeath Decision

### Recommendation: **No Permadeath (Optional Hardcore Mode Later)**

**Rationale:**
1. Mobile games need low frustration
2. Permadeath doesn't fit casual mining genre
3. Would undermine prestige system investment
4. Can add as optional "Hardcore Mode" in v1.1+

### Optional Hardcore Mode (v1.1+):
- Separate save slot
- Single life per prestige cycle
- Death = forced prestige (keep prestige currency only)
- Special "Ironman" badge/achievements
- Leaderboard for hardcore players

---

## Structure Destruction Decision

### Question: Can hazards destroy player-placed structures?

### Recommendation: **No**

**Rationale:**
1. Ladders are critical for return trips
2. Losing ladders mid-run = frustrating soft-lock
3. Adds complexity without fun
4. Player agency should be respected

**Exception:** Collapse hazards can block passages temporarily but not destroy ladders/ropes permanently.

---

## Hazard Tutorials Decision

### Question: Tutorial for each new hazard type?

### Recommendation: **Yes, contextual warnings**

**Implementation:**
- First encounter with new hazard type triggers tutorial popup
- Brief explanation of hazard + counter
- Can be dismissed quickly
- Stored in "hazards seen" for no repeat

```gdscript
# First gas pocket encounter
func show_hazard_tutorial(hazard_type: String):
    if hazard_type not in seen_hazards:
        seen_hazards.append(hazard_type)
        show_tutorial_popup(HAZARD_TUTORIALS[hazard_type])

const HAZARD_TUTORIALS = {
    "gas": {
        "title": "⚠️ Gas Pocket!",
        "text": "Toxic gas damages you over time. Get a Gas Mask from the Equipment Shop!",
        "icon": "gas_icon"
    },
    "lava": {
        "title": "🔥 Lava!",
        "text": "Instant death on contact! Avoid or get Heat Protection gear.",
        "icon": "lava_icon"
    }
}
```

---

## Respawn Location

### Options:
1. **Always Surface** - Simple, consistent
2. **Last Safe Point** - Checkpoints underground
3. **Nearest Ladder** - Smart respawn

### Recommendation: **Always Surface**

**Rationale:**
- Simple and predictable
- Encourages return-trip planning
- Natural session end point
- No complex checkpoint system needed

---

## Questions Resolved

- [x] Permadeath option? → **No** (optional hardcore mode v1.1+)
- [x] Resource loss on death? → **10-30% inventory based on depth**
- [x] Enemies for v1.0? → **No** (already decided in combat-enemies-decision.md)
- [x] Hazards destroy structures? → **No** (player structures protected)
- [x] Tutorial for hazards? → **Yes** (contextual first-encounter popups)

---

## Summary

**Death Mechanics:**
- Respawn at surface (always)
- Lose 10-30% of inventory (depth-scaled)
- Lose 0-10% of coins (depth-scaled)
- Equipment damage (repairable)
- No permadeath (optional hardcore mode later)

**Player Structures:**
- Protected from hazards
- Cannot be destroyed by environment

**Hazard Tutorials:**
- First-encounter contextual popups
- Brief, dismissable, non-repeating

This system creates meaningful risk while remaining mobile-friendly and accessible. Deep zones feel dangerous without being punishing to the point of player loss.
