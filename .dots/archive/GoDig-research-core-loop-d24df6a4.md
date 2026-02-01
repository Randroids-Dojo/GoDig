---
title: "research: Core loop satisfaction audit - fun factor priority matrix"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"2026-02-01T07:47:38.563325-06:00\\\"\""
closed-at: "2026-02-01T07:48:22.788284-06:00"
close-reason: Created comprehensive fun factor priority matrix organizing all implementation specs by core loop phase. Identified P0 blockers, P1 high-impact features, and recommended implementation order.
---

## Description
Prioritized view of all fun-factor implementation specs, organized by which part of the core loop they enhance.

## The Core Loop
```
[MINE] -> [COLLECT] -> [RETURN] -> [SELL] -> [UPGRADE] -> [RESTART] -> [MINE]
   |         |            |          |           |            |
   v         v            v          v           v            v
  Fun      Reward      Tension    Payoff      Power        "Again!"
```

## Phase 1: MINE - Mining Satisfaction

| Feature | Dot ID | Priority | Impact | Notes |
|---------|--------|----------|--------|-------|
| Mining sound design | implement-mining-sound-54915d26 | P1 | HIGH | #1 factor in mining feel |
| Mining screen shake | implement-mining-screen-bf85e4d7 | P2 | MEDIUM | Adds weight to actions |
| Block destruction particles | implement-block-destruction-85934286 | P2 | MEDIUM | Visual feedback |
| Mining combo feedback | implement-mining-combo-5de8f33a | P3 | LOW | Nice-to-have |

**Key Insight**: Mining happens thousands of times. Small improvements compound.

## Phase 2: COLLECT - Ore Discovery

| Feature | Dot ID | Priority | Impact | Notes |
|---------|--------|----------|--------|-------|
| First ore discovery celebration | implement-first-ore-9dc20570 | P1 | HIGH | Key onboarding moment |
| Ore discovery enhancement | implement-ore-discovery-b01bba40 | P2 | MEDIUM | All ores feel special |
| Jackpot discovery | implement-jackpot-discovery-aae547b3 | P2 | MEDIUM | Rare gems = excitement |
| Near-miss ore hints | implement-near-miss-c1c29f4c | P3 | LOW | Shows nearby ore |
| First-discovery bonus | implement-first-discovery-da46be53 | P3 | LOW | Extra reward for new ores |

**Key Insight**: Discovery = dopamine. Make rare finds MEMORABLE.

## Phase 3: RETURN - Tension and Escape

| Feature | Dot ID | Priority | Impact | Notes |
|---------|--------|----------|--------|-------|
| Depth-aware ladder warning | implement-depth-aware-00ae8542 | P1 | HIGH | Prevents frustration |
| Low ladder warning | implement-low-ladder-e6f21172 | P1 | HIGH | Core tension trigger |
| Inventory tension visuals | implement-inventory-tension-30865491 | P2 | MEDIUM | Graduated pressure |
| Return-to-surface tension | implement-return-to-9ecc2744 | P2 | MEDIUM | Visual urgency |
| Deep dive tension meter | implement-deep-dive-2e1f97dc | P3 | LOW | Risk indicator |
| Close-call celebration | implement-close-call-034e09a9 | P2 | HIGH | Celebrates narrow escapes |
| Safe return celebration | implement-safe-return-a8427f4a | P2 | MEDIUM | Validates successful trip |
| Subtle tension audio | implement-subtle-tension-0b659daa | P3 | MEDIUM | Ambient pressure |

**Key Insight**: Tension makes the return feel earned. Close-calls = stories.

## Phase 4: SELL - Payoff Moment

| Feature | Dot ID | Priority | Impact | Notes |
|---------|--------|----------|--------|-------|
| Sell animation with coin flow | implement-sell-animation-58af35a8 | P1 | HIGH | Validates mining effort |
| Progress-to-upgrade display | implement-progress-to-436687cb | P2 | MEDIUM | Shows goal proximity |
| Affordable upgrade indicator | implement-affordable-upgrade-248ad8fa | P2 | MEDIUM | "You can buy now!" |

**Key Insight**: Sell moment converts effort into reward. Must feel SATISFYING.

## Phase 5: UPGRADE - Power Fantasy

| Feature | Dot ID | Priority | Impact | Notes |
|---------|--------|----------|--------|-------|
| Upgrade celebration juice | implement-upgrade-celebration-9c46b6c2 | P1 | HIGH | Key hook moment |
| Immediate pickaxe power feel | implement-immediate-pickaxe-8fc4c08b | P1 | HIGH | Validates purchase |
| First upgrade guidance | implement-first-upgrade-e2c338e3 | P1 | HIGH | Onboarding critical |
| Upgrade stat comparison UI | implement-upgrade-stat-5658fcef | P2 | MEDIUM | Shows improvement |
| Pickaxe upgrade comparison | implement-pickaxe-upgrade-62880bcf | P2 | MEDIUM | Before/after |
| Reduce Copper Pickaxe cost | implement-reduce-copper-cdb35c77 | P2 | MEDIUM | Faster first upgrade |
| Increase early ore values | implement-increase-early-948e470d | P2 | MEDIUM | Faster early progress |

**Key Insight**: Upgrade = "I earned this" + "I'm stronger now". Both matter.

## Phase 6: RESTART - One More Run

| Feature | Dot ID | Priority | Impact | Notes |
|---------|--------|----------|--------|-------|
| Quick-dive button | implement-quick-dive-0cb05828 | P1 | HIGH | Reduces friction |
| Instant respawn after death | implement-instant-respawn-1327777a | P1 | HIGH | No death frustration |
| Instant restart UX | implement-instant-restart-18f90600 | P1 | HIGH | Flow state |
| Depth record tracking | implement-depth-record-a080d43a | P2 | MEDIUM | "Beat your best" |
| Depth milestone celebrations | implement-depth-milestone-9ae3f245 | P2 | MEDIUM | Progress markers |

**Key Insight**: Time from "done" to "playing again" should be <2 seconds.

## Supporting Systems

| Feature | Dot ID | Priority | Impact | Notes |
|---------|--------|----------|--------|-------|
| Give 5 starting ladders | give-player-2-8f4b2912 | P0 | CRITICAL | Enables first dive |
| Move Supply Store to 0m | move-supply-store-61eb95a1 | P0 | CRITICAL | Ladder access |
| Add Forfeit Cargo option | add-forfeit-cargo-e9e163d7 | P1 | HIGH | Escape valve |
| Rare ladder drops | add-rare-ladder-18c546b0 | P2 | MEDIUM | Discovery + utility |
| Quick-buy ladder shortcut | implement-quick-buy-1f33cfbe | P2 | MEDIUM | Reduces friction |
| One-tap ladder placement | implement-one-tap-dfc5fdcd | P2 | MEDIUM | Mobile UX |

## Priority Summary

### P0 - Blocking Fun (Do First)
- Give 5 starting ladders
- Move Supply Store to 0m

### P1 - Core Loop Feel (High Impact)
- Mining sound design
- First ore discovery celebration
- Depth-aware ladder warning
- Low ladder warning
- Sell animation
- Upgrade celebration
- Immediate pickaxe power feel
- First upgrade guidance
- Quick-dive button
- Instant respawn
- Forfeit Cargo escape

### P2 - Polish and Enhancement (Good Impact)
- Screen shake, particles
- Inventory tension visuals
- Close-call celebration
- Progress display
- Stat comparison UI
- Depth record tracking

### P3 - Nice to Have (Low Priority)
- Mining combo
- Near-miss hints
- Cave treasures
- Subtle tension audio

## Recommendations

1. **Start with P0**: Without ladders at 0m and starting inventory, core loop is broken
2. **Then P1 Sound/Feel**: Mining sound + ore discovery = most frequent actions
3. **Then P1 Tension/Reward**: Ladder warnings + sell animation complete the loop
4. **Then P1 Restart**: Quick-dive + respawn enable "one more run"
5. **P2 during polish phase**: Layer in enhancement once core feels good

## Research Complete
This audit provides implementation prioritization based on:
- Frequency of player interaction (mining > selling > upgrading)
- Impact on core loop satisfaction
- Dependencies (can't celebrate upgrades without upgrades existing)
