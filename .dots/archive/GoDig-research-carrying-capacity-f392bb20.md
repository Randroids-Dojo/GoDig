---
title: "research: Carrying capacity impact on movement speed (Dome Keeper pattern)"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-01T01:46:32.050367-06:00\\\"\""
closed-at: "2026-02-01T01:50:55.020080-06:00"
close-reason: "Completed research. Recommendation: SKIP weight/encumbrance for MVP. Current slot-based inventory + ladder economy provides sufficient tension without frustration risk. Dome Keeper's system works due to wave timer pressure which GoDig lacks."
---

Dome Keeper uses weight-based movement penalties. Investigate if this would add fun tension to GoDig's return trip or just frustrate players. Research similar games and make recommendation.

## Research Findings

### How Dome Keeper Implements It

From [Josh Anthony's Design Dive](https://joshanthony.info/2023/05/24/design-dive-dome-keeper/):

- Carrying N resources results in carry size: N * (N + 1) / 2
- Slowdown formula: 0.01 * speedLossPerCarry * carry size
- Max speed = max speed * (1 - carry slowdown)
- When slowdown exceeds 1, keeper stops entirely
- Resources drop if line exceeds 6 blocks

**Key Design Insight**: "Carrying capacity affecting movement speed adds a layer of decision-making to how much to harvest per trip."

### Why It Works in Dome Keeper

1. **Time Pressure**: Enemy waves create urgency - slow movement = real risk
2. **Visible Progress**: Carry upgrades let players feel faster over time
3. **Strategic Choice**: "Maximize time mining, minimize time carrying"
4. **Gadget Synergy**: Elevator/teleporter finds reduce need for carry upgrades

### The General Debate on Encumbrance

From [Escapist Magazine](https://www.escapistmagazine.com/why-are-games-still-throwing-their-weight-behind-encumbrance/) and [GameDev.net](https://www.gamedev.net/forums/topic/669987-inventory-management-mechanics/):

**Pro-Encumbrance Arguments:**
- Death Stranding: Physics-based movement creates rewarding challenge
- Immersion and realism in survival games
- Forces meaningful resource prioritization

**Anti-Encumbrance Arguments:**
- "What weight systems often boil down to is excessive inventory management, which is not fun"
- "Encumbrance stands in direct opposition to fun" - considered archaic by some
- Without proper implementation, becomes tedious chore

**Middle Ground (Dark Souls approach):**
- Equip load affects combat, but no carry limit for inventory
- Separates strategic decisions from hoarding frustration

### Recommendation for GoDig

**DO NOT implement carrying capacity slowdown.** Here's why:

1. **No Time Pressure**: Unlike Dome Keeper, GoDig has no wave timer. Slowdown just extends travel time without adding strategic tension.

2. **Already Have Tension Sources**:
   - Ladder count (escape resources)
   - Inventory slot limits (return triggers)
   - Depth-based hazards (future)

3. **Mobile Context**: Extra inventory management = more friction on mobile. Slot-based system is cleaner.

4. **Wall-Jumping Complexity**: Adding weight would complicate wall-jump physics and frustrate players trying to escape.

5. **Session Length Impact**: Slower movement = longer sessions. Current 5-8 minute target would be disrupted.

### Alternative Tension Mechanics (Already Planned)

Instead of weight penalties, GoDig creates return trip tension through:
- **Low ladder warnings** (pulsing HUD indicator)
- **Inventory fill warnings** (60/80/100%)
- **Deep dive tension meter** (unified risk indicator)
- **Safe return celebrations** (reward for successful trips)

These achieve similar decision-forcing without the tedium of slow movement.

### If We EVER Wanted Weight Mechanics

If future testing shows return trips lack tension, consider:
- **Stamina drain while climbing** (heavier = more stamina use)
- **Climbing speed reduction** (ladders only, not walking)
- **Upgrade to mitigate** (backpack upgrades reduce penalty)

But this is v1.1+ at earliest. Not MVP.

## Decision

**SKIP carrying capacity/weight slowdown for MVP.**

Current slot-based inventory + ladder economy provides sufficient return trip tension without the frustration risk of encumbrance systems.

## Sources
- [Dome Keeper Design Dive - Josh Anthony](https://joshanthony.info/2023/05/24/design-dive-dome-keeper/)
- [Dome Keeper Wiki - Carrying Capacity](https://domekeeper.wiki.gg/wiki/Engineer)
- [Games With Realistic Carry Capacity - GameRant](https://gamerant.com/games-realistic-carry-capacity-equip-load-systems/)
- [Why Encumbrance? - Escapist Magazine](https://www.escapistmagazine.com/why-are-games-still-throwing-their-weight-behind-encumbrance/)
