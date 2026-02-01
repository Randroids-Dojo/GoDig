---
title: "implement: Retreat vs Death resource preservation tiers"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T09:44:26.928424-06:00"
---

Based on Loop Hero's proven retreat system, implement tiered resource preservation based on how player exits a dig session.

## Context
Research Session 23 identified Loop Hero's retreat system as gold standard for push-your-luck:
- Die = lose 70% of gathered resources
- Early retreat = lose 40%
- Camp return = keep 100%

This creates meaningful decisions and reduces frustration while maintaining stakes.

## GoDig Application
- **Surface Return (Safe)**: Keep 100% of gathered ore, all ladders used are gone
- **Emergency Rescue (Retreat)**: Keep 50-70% of ore (configurable), lose all remaining ladders, pay rescue fee
- **Death by hazard**: Keep 30% of ore, lose all ladders

## Implementation Notes
- Emergency rescue already exists - adjust ore retention %
- Need UI feedback showing what player keeps vs loses
- Rescue fee should scale with depth (already specced separately)
- Consider: forfeit cargo option (lose all ore, keep some ladders?) for players who realize they're stuck early

## Affected Files
- GameManager.gd - add rescue/death outcome logic
- Inventory system - calculate retention amounts
- HUD - show loss preview before confirming rescue

## Verify
- [ ] Build succeeds
- [ ] Player keeps 100% ore when returning to surface via ladders
- [ ] Player keeps 50-70% ore (configurable) when using emergency rescue
- [ ] Loss preview UI appears before rescue confirmation
- [ ] Rescue fee scales with depth
