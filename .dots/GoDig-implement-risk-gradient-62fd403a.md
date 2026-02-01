---
title: "implement: Risk gradient scaling by depth"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T08:53:47.400501-06:00"
---

## Description

Create variable risk/reward scaling where deeper = higher variance but better expected value. Players should CHOOSE their risk level.

## Context

Research shows that excessively risky scenarios discourage casual players, while overly safe experiences lack excitement. The solution is player-controlled risk through depth choice.

## Research Basis (Session 16)

- Risk vs Reward 2025: 'Safer, smaller rewards in early levels → more volatile, lucrative opportunities as players progress'
- Mobile 2025: 'Biggest titles reward long-term planning, careful timing'
- Deep Sea Adventure: 'Taking treasure = oxygen drains faster + movement slows'
- Spelunky: 'Game of information and decision-making, not execution'

## Affected Files

- scripts/data/ore_data.gd - Value variance by depth
- scripts/world/ore_generator.gd - Ore spawn probability curves
- scripts/player/inventory_manager.gd - Risk calculation
- scenes/ui/hud/risk_indicator.tscn - NEW: Visual risk display

## Implementation Notes

Depth Risk Model:
- 0-10m: Low risk, consistent rewards (100% of base value, ±5%)
- 10-25m: Moderate risk (120% base, ±20%)
- 25-50m: High risk (150% base, ±40%)
- 50-100m: Very high risk (200% base, ±60%)
- 100m+: Extreme (300% base, ±80%, rare jackpots)

Visual Indicators:
- Green → Yellow → Orange → Red depth zones
- Ore values show range, not fixed number
- 'Safe return' estimate in HUD

## Verify

- [ ] Shallow mining is consistently profitable
- [ ] Deep mining has higher variance (both big wins and disappointments)
- [ ] Players naturally calibrate their risk tolerance
- [ ] Emergency rescues feel like acceptable losses, not punishment
