---
title: "implement: Underground rest station (v1.1)"
status: open
priority: 3
issue-type: task
created-at: "2026-02-01T08:18:56.467807-06:00"
---

## Description
Add underground shop/rest stations to reduce tedium of returning to surface on deep dives. Research shows: 'Repetition of going up and down gets increasingly tedious' (Motherload feedback).

## Context
Motherload solved this with 'stations at various levels underground so you don't have to go all the way back up.' They charge more but save time. This is a quality-of-life feature for late-game players.

## Implementation
1. Add rest station buildings at depth milestones (e.g., 100m, 250m, 500m)
2. Stations offer:
   - Sell resources (80% of surface price - convenience tax)
   - Buy ladders (120% of surface price)
   - Quick heal (premium cost)
3. Stations must be unlocked first (surface building upgrade)
4. Visual: small shelter with shopkeeper NPC

## Economy Balance
- Surface prices are always best
- Underground convenience comes at cost
- Players trade efficiency for time
- This is a REWARD for reaching depth milestones

## v1.1 Scope
This is marked for v1.1 because:
- Core loop must be fun first
- Requires infrastructure building system
- Nice-to-have, not launch critical

## Affected Files (Future)
- scripts/world/rest_station.gd (new)
- scenes/buildings/rest_station.tscn (new)
- scripts/autoload/shop_manager.gd (extend for underground shops)

## Verify
- [ ] Station appears at specified depths
- [ ] Prices correctly inflated vs surface
- [ ] Reduces perceived tedium on deep dives
- [ ] Doesn't break economy (still worth returning to surface sometimes)
