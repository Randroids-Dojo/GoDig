---
title: "implement: Upgrade solves recent frustration pattern"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T09:08:19.421210-06:00"
---

## Description

Ensure each upgrade directly addresses a frustration the player just experienced, creating a "ah, that's what I needed\!" moment.

## Context

Session 18 research (SteamWorld Dig 2 analysis):
- "Each tool serves a very specific purpose: to help you keep digging"
- "Reviewers had trouble choosing among upgrades, because each has noticeable effect"
- Creates "just one more trip" mentality
- Key insight: Upgrade should solve problem player JUST faced, not future problems

## Frustration → Upgrade Mapping

| Player Frustration | Timing | Upgrade Solution |
|-------------------|--------|------------------|
| "Digging is slow" | After 2-3 trips | Copper Pickaxe |
| "Inventory fills too fast" | After 3-4 trips | Backpack expansion |
| "Running out of ladders" | After first deep dive | Ladder bundle discount |
| "Can't reach deeper ores" | At layer boundary | Better pickaxe tier |
| "Return trip is tedious" | Mid-game | Elevator unlock |

## Requirements

1. Track player's most recent "failure" or "frustration" moment
2. Surface relevant upgrade as first shop suggestion
3. Show before/after comparison when hovering upgrade
4. Celebration animation when upgrade addresses known pain point

## Affected Files

- `scripts/autoload/game_manager.gd` - Track frustration events
- `scripts/ui/shop.gd` - Suggested upgrade highlighting
- `scripts/ui/upgrade_comparison.gd` - Before/after UI

## Verify

- [ ] After pickaxe breaks on hard block, shop highlights pickaxe upgrade
- [ ] After inventory overflow, shop highlights backpack
- [ ] After death/forfeit, shop highlights relevant survival item
- [ ] Upgrade comparison shows clear improvement numbers
