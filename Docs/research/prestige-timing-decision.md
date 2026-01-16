# Prestige System Timing Decision

## Overview
When should the prestige/rebirth system be added to GoDig?

## Options

### Option A: MVP (v0.1)
Add prestige from the very beginning.

**Pros:**
- Core design considers prestige from start
- No retrofitting needed
- Players understand the loop early

**Cons:**
- Significant additional scope
- Delays initial launch
- Can't validate base loop first
- Prestige needs balance testing

### Option B: v1.0 (Initial Release)
Add prestige for the full launch version.

**Pros:**
- Base game validated in MVP/beta
- More time for balance
- Players have something new at launch
- Natural end-game content

**Cons:**
- Still adds launch complexity
- May delay v1.0 release
- Prestige balance affects core economy

### Option C: v1.1+ (Post-Launch Update)
Add prestige after initial release is stable.

**Pros:**
- Focus on core loop first
- Validate base game works
- Prestige as "content update"
- Brings players back
- Can balance based on real data

**Cons:**
- May lose early players who hit end-game
- Retrofitting economy may be needed
- Players may expect it at launch

---

## Decision Factors

### Development Scope
| Feature | Complexity | Dependencies |
|---------|------------|--------------|
| Core mining | High | None |
| Shop system | Medium | Core mining |
| Progression | Medium | Shop system |
| Prestige | High | All above |

Prestige requires ALL other systems to be working first.

### Player Retention Analysis
```
Without Prestige:
- Early Game: High engagement
- Mid Game: Good engagement
- Late Game: Engagement drops
- End Game: Players leave (nothing new)

With Prestige:
- Early Game: High engagement
- Mid Game: Good engagement
- Late Game: "Should I prestige?" tension
- End Game: Fresh start with bonuses
```

### Competitor Timing
| Game | Prestige Added |
|------|---------------|
| Cookie Clicker | After initial version |
| Adventure Capitalist | v1.0 |
| Idle Miner Tycoon | v1.0 |
| Motherload | Never (no prestige) |

Most successful idle games added prestige at or shortly after initial release.

---

## Recommendation: **v1.0 (Option B)**

### Rationale:

1. **Core game needs validation first**
   - MVP/beta tests base mining loop
   - Don't balance prestige on unvalidated foundation

2. **v1.0 needs end-game content**
   - Players will reach "end" in 10-20 hours
   - Without prestige, they leave
   - Prestige provides replay value

3. **Not MVP because scope**
   - MVP should be minimal: dig, sell, upgrade
   - Prestige adds significant complexity
   - Focus on core fun first

4. **Not v1.1+ because retention**
   - Launch window is critical
   - Early players hitting end-game will churn
   - Better to have it ready at launch

### Timeline:
```
MVP (v0.1): Core loop only (dig, sell, upgrade)
Beta: Add depth, balance, polish
v1.0: Full game + prestige system
v1.1+: Skill trees, daily challenges, events
```

---

## Implementation Approach

### Design for Prestige Early
Even though implementing in v1.0, design decisions should consider prestige:

```gdscript
# In economy design (MVP):
# - Track "lifetime earnings" from start
# - Keep statistics that will feed prestige calculation
# - Design tool tiers with prestige multipliers in mind

var lifetime_stats = {
    "total_coins_earned": 0,
    "max_depth_reached": 0,
    "blocks_mined": 0,
    "items_found": {},
    "play_time": 0.0
}
```

### MVP Hooks for Prestige
- Save lifetime statistics
- Design economy with reset in mind
- Keep "persistent" vs "run-specific" data separate
- Plan UI space for prestige button

### v1.0 Prestige Scope
Minimal viable prestige:
1. **Reset mechanic** - Returns to start
2. **Prestige currency** - Based on depth/coins
3. **Permanent upgrades** - 5-10 purchasable bonuses
4. **Visual indicator** - Prestige level badge

Advanced features deferred to v1.1+:
- Skill trees
- Prestige tiers (bronze/silver/gold)
- Challenges that modify prestige

---

## Questions Resolved
- [x] Prestige at MVP? → **No** (too much scope)
- [x] Prestige at v1.0? → **Yes** (essential for retention)
- [x] Prestige at v1.1+? → **No** (too late, players will leave)
- [x] Design considerations? → Track lifetime stats from MVP

---

## Summary

**Decision: Add prestige system in v1.0 (initial full release)**

The prestige system is essential for long-term player retention but requires the base game to be validated first. MVP focuses on core mining loop; v1.0 adds prestige as end-game content. Design decisions from MVP should account for prestige (tracking lifetime stats, separating persistent vs run data).

### MVP Deliverable:
- Core mining, selling, upgrading
- No prestige UI or mechanics
- Lifetime stats tracking (hidden)

### v1.0 Deliverable:
- Full prestige system
- Prestige currency + upgrades
- Reset functionality
- Prestige level display
