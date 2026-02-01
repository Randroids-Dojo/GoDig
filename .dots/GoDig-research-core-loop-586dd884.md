---
title: "research: Core loop fun factor priority matrix"
status: open
priority: 0
issue-type: research
created-at: "2026-02-01T08:34:39.463647-06:00"
---

## Purpose

Synthesize Session 13 research into a priority matrix for fun factor implementation. This helps the implementor understand which mechanics matter most and in what order.

## The Core Loop (From Design Doc)

```
1. DIG DOWN -> Mine resources, break blocks
2. COLLECT -> Fill inventory with ores/gems
3. RETURN -> Navigate back to surface (wall-jump, ladders)
4. SELL -> Exchange resources at shops
5. UPGRADE -> Buy better tools, expand capacity
6. REPEAT -> Go deeper, find rarer resources
```

## Fun Factor Priority Matrix

Based on Session 13 competitive analysis:

### Tier 1: MUST BE FUN FIRST (Before Systems)

| Priority | Mechanic | Why | Research Source |
|----------|----------|-----|-----------------|
| **P0** | Core digging feel | "If digging isn't satisfying by itself, game isn't for you" | SteamWorld Dig, Hytale |
| **P0** | First 5 min economy | 62% abandon if no currency/resources, 80% churn by Day 1 | GameAnalytics |
| **P0** | First upgrade sensation | 40% session length increase when controls mastered in 5 min | Mobile research |

### Tier 2: TENSION & STAKES (What Makes Decisions Meaningful)

| Priority | Mechanic | Why | Research Source |
|----------|----------|-----|-----------------|
| **P1** | Ladder depletion tension | Our unique differentiator - creates gradual tension like oxygen | Deep Sea Adventure |
| **P1** | Return journey clarity | "Return trip is where FUN can die" - hints prevent frustration | Motherload, Dome Keeper |
| **P1** | Low ladder warning | Players need to KNOW they're in trouble before it's too late | Push-your-luck research |

### Tier 3: REWARD BEATS (Make Progress Feel Good)

| Priority | Mechanic | Why | Research Source |
|----------|----------|-----|-----------------|
| **P1** | Sell animation cascade | "Vivid visuals amplify perceived reward" - key payoff moment | Coin animation psychology |
| **P1** | Ore discovery celebration | Each block is a micro-uncertainty moment (like Balatro card draw) | Balatro analysis |
| **P1** | Upgrade power feel | "Tier 1 vs Tier 3 should feel like night and day" | SteamWorld Dig |
| **P2** | Distinct pickaxe tiers | Upgrades are "boringly straightforward" without sensory difference | SteamWorld Dig criticism |

### Tier 4: LOOP COMPLETION (One More Run)

| Priority | Mechanic | Why | Research Source |
|----------|----------|-----|-----------------|
| **P2** | Quick restart UX | "Games where runs are pretty quick help" - Nuclear Throne pattern | Just-one-more-run psychology |
| **P2** | Surface home comfort | "Vary tension rhythm - surface should provide genuine relief" | Dome Keeper feedback |
| **P2** | Session end celebration | Make 5-min loop feel complete | Mobile session research |

## Implementation Order Recommendation

Based on the research, implement in this order:

### Phase A: Core Feel (Before Any Systems)
1. `GoDig-implement-core-mining-debb2ca2` - Core mining feel validation test
2. `GoDig-implement-distinct-audio-09fbd1b1` - Distinct audio/visual per pickaxe tier

### Phase B: First 5 Minutes (Critical Retention Window)
1. `GoDig-give-player-2-8f4b2912` - 5 starting ladders
2. `GoDig-implement-guaranteed-first-99e15302` - First ore within 3 blocks
3. `GoDig-implement-first-5-0e449846` - First 5 minute economy tuning

### Phase C: Tension & Stakes
1. `GoDig-implement-low-ladder-e6f21172` - Low ladder warning
2. `GoDig-implement-return-route-86fe3653` - Return route efficiency hints
3. `GoDig-implement-return-to-9ecc2744` - Return-to-surface tension indicator

### Phase D: Reward Beats
1. `GoDig-implement-satisfying-sell-150bde42` - Sell animation cascade
2. `GoDig-implement-sell-animation-58af35a8` - (companion spec)
3. `GoDig-implement-first-ore-9dc20570` - First ore discovery celebration
4. `GoDig-implement-immediate-pickaxe-8fc4c08b` - Immediate pickaxe power feel

### Phase E: Loop Polish
1. `GoDig-implement-instant-restart-18f90600` - Instant restart UX
2. `GoDig-implement-surface-home-81016105` - Surface home base cozy signals

## Key Insights from Session 13

### Why GoDig's Ladder System is a Competitive Advantage

From Deep Sea Adventure analysis:
- Shared oxygen creates tension through gradual resource depletion
- GoDig's ladders do the same thing, but SOLO
- **Key difference**: In multiplayer push-your-luck, you blame other players
- **In GoDig**: Player only blames themselves = better for mobile = clearer learning

### The Return Trip Problem

From Motherload/Dome Keeper:
- "Repetition of going up and down gets increasingly tedious"
- "Mining underground is strangely peaceful... but tension always hangs in background"
- **Solution for GoDig**:
  - Early: Wall-jump + ladders = skill expression
  - Mid: Elevator unlock = reward for investment
  - Late: Teleport scroll = emergency bailout

### Why First Upgrade Matters So Much

From power progression research:
- "Each time user achieves something exciting, brain releases dopamine"
- "First few rounds feel tedious as characters move slowly"
- "Satisfaction of seeing hero improve keeps players glued"
- **GoDig Target**: First upgrade in ~5 minutes, FELT immediately

## Sources

This matrix synthesizes findings from Session 13 of the ongoing competitive analysis:
- Deep Sea Adventure board game mechanics
- SteamWorld Dig pickaxe satisfaction design
- Push-your-luck board game research (BoardGameGeek)
- Power progression psychology research
- "Just one more run" psychology analysis
- Idle Miner Tycoon economy design
- Sell animation psychology research
- Roguelite time pressure design

See `GoDig-research-ongoing-competitive-058f0387` for full research log.
