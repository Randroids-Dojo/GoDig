---
title: "research: Stuck-recovery flow analysis"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"2026-02-01T01:09:16.578282-06:00\\\"\""
closed-at: "2026-02-01T01:12:17.760256-06:00"
close-reason: "Completed wall-jump physics analysis, stuck scenario matrix, gap analysis. Key finding: 1-wide shafts are inescapable without ladders. P1 fixes identified: Supply Store at 0m, starting ladders, Forfeit Cargo option."
---

Map out all stuck scenarios and ensure each has a viable recovery path.

## Research Findings
- SteamWorld Dig: 'Wall-jumping transformed stuck from binary failure to recoverable'
- Getting stuck should feel like a challenge, not a failure
- Players who escape feel clever and satisfied
- Emergency options should exist but not trivialize challenge

## Wall-Jump Physics Analysis (Completed)

Current constants in `player.gd`:
- `WALL_JUMP_FORCE_Y = 450.0` px/s (upward)
- `WALL_JUMP_FORCE_X = 200.0` px/s (horizontal)
- `GRAVITY = 980.0` px/s²
- `BLOCK_SIZE = 128` px

### Calculated Escape Capability

| Metric | Value |
|--------|-------|
| Max height per jump | 0.81 blocks |
| Time to peak | 0.46 seconds |
| Net vertical gain per wall-jump cycle | ~0.68 blocks |

### Shaft Escape Analysis

| Shaft Width | Wall-Jump Escape | Notes |
|-------------|------------------|-------|
| 1 block | IMPOSSIBLE | No opposing walls - must use ladder |
| 2 blocks | POSSIBLE (tedious) | Gains ~0.7 blocks per cycle |
| 3+ blocks | RISKY | Can't reach opposite wall before falling |

**Key Finding**: The most common "stuck" scenario is a 1-wide vertical shaft dug straight down. This CANNOT be escaped via wall-jump alone.

## Stuck Scenarios & Recovery Matrix

| Scenario | Wall-Jump | Ladder | Forfeit Cargo | Emergency Rescue |
|----------|-----------|--------|---------------|------------------|
| 1-wide shaft | NO | YES | YES | YES |
| 2-wide shaft | YES (slow) | YES | YES | YES |
| 3+ wide pit | DEPENDS | YES | YES | YES |
| Deep, no ladders | NO | N/A | YES | YES |
| Inventory full at depth | N/A | YES | YES (lose cargo) | YES (lose all) |

## Current Recovery Options Status

1. **Wall-Jump**: Implemented, works for 2-wide shafts
2. **Starting Ladders**: NOT IMPLEMENTED (see `GoDig-give-player-2-8f4b2912`)
3. **Forfeit Cargo**: NOT IMPLEMENTED (see `GoDig-add-forfeit-cargo-e9e163d7`)
4. **Emergency Rescue**: Implemented but loses ALL inventory (too punishing?)
5. **Teleport Scroll**: Available but costs $500 (may be too expensive early)

## Gap Analysis

### Critical Gap: New Player First Stuck Experience
A new player who:
1. Digs straight down (1-wide shaft)
2. Has no ladders (Supply Store locked until 100m)
3. Gets stuck at 15-20m

**Only options**: Emergency Rescue (lose everything) or reload save

This is the worst possible first experience. Fix with:
- Starting ladders (`GoDig-give-player-2-8f4b2912`)
- Supply Store at 0m (`GoDig-move-supply-store-61eb95a1`)
- Forfeit Cargo option (`GoDig-add-forfeit-cargo-e9e163d7`)

### Medium Gap: Punishment Severity
Emergency Rescue loses ALL inventory. This may be:
- Too harsh for early game (player has little)
- Appropriate for late game (high risk/reward)

**Recommendation**: Scale punishment by depth (already in death penalty code)

## Implementation Recommendations

### P1 Fixes (Core Loop Critical)
1. `GoDig-move-supply-store-61eb95a1` - Ladders available at game start
2. `GoDig-give-player-2-8f4b2912` - 3 free ladders on new game
3. `GoDig-add-forfeit-cargo-e9e163d7` - Middle-ground escape option

### P2 Improvements (Polish)
1. Add "You're getting deep!" warning at certain depths without ladder path back
2. Show ladder count prominently when player has none
3. Tutorial that demonstrates wall-jump AND ladder placement

### P3 Quality of Life
1. Auto-place ladder on the way down (toggle setting)
2. "Breadcrumb" ladder mode: place ladder every N blocks automatically
3. Map/minimap showing ladder positions

## Stuck Scenario Flowchart

```
Player gets stuck
       │
       ├─> Can wall-jump? (2+ wide shaft)
       │         │
       │         ├─> YES: Escape via wall-jump (takes time)
       │         │
       │         └─> NO: 1-wide shaft
       │                    │
       │                    ├─> Has ladders?
       │                    │         │
       │                    │         ├─> YES: Place ladder, climb out
       │                    │         │
       │                    │         └─> NO: Need rescue option
       │                    │                    │
       │                    │                    ├─> Forfeit Cargo (P2: NOT IMPL)
       │                    │                    │      Lose: ores/gems
       │                    │                    │      Keep: ladders, tools
       │                    │                    │
       │                    │                    └─> Emergency Rescue (IMPL)
       │                    │                           Lose: ALL inventory
       │                    │                           Return: Surface
       │                    │
       │                    └─> Has teleport scroll?
       │                              │
       │                              ├─> YES: Use it
       │                              │
       │                              └─> NO: Rescue or reload save
       │
       └─> Inventory full scenario
                  │
                  └─> Can climb back? → Normal return
                  │
                  └─> Can't climb? → Forfeit Cargo to make room for ladder
```

## Deliverables Complete
- [x] Wall-jump physics analysis
- [x] Stuck scenario matrix
- [x] Gap analysis
- [x] Implementation recommendations
- [x] Flowchart

## Follow-up Implementation Dots Created
- `GoDig-move-supply-store-61eb95a1` (enriched with research)
- `GoDig-give-player-2-8f4b2912` (promoted to P1)
- `GoDig-add-forfeit-cargo-e9e163d7` (existing, critical)
