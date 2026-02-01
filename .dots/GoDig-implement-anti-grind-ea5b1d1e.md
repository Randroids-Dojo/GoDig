---
title: "implement: Anti-grind economy balance pass"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T08:18:45.579091-06:00"
---

## Description
Ensure upgrade progression doesn't follow exponential curves that make late-game feel grindy. Research shows: DRG Survivor 'very annoying boring grind slowly destroying fantastic game loop' due to exponential mineral requirements.

## Context
Multiple mining games suffer from 'soft walls due to exponential difficulty curve compared to sub-exponential permanent bonuses growth' (Mobile incremental game analysis). Players praise early game but complain about mid/late game grind.

## Implementation
Review and adjust:
1. Pickaxe upgrade costs - should be linear or soft-cap, not exponential
2. Building unlock costs - milestone-based, not exponential grind
3. Resource sell values per depth - ensure deep mining is WORTH the ladder cost
4. Time-to-upgrade curve - should feel achievable each session

## Economy Guidelines
- First upgrade: < 5 minutes (existing spec)
- Second upgrade: 8-12 minutes of play
- Third upgrade: 15-20 minutes of play
- Each session (4-6 min) should feel like meaningful progress
- Never more than 3 trips to afford next upgrade

## Avoid These Patterns
- Exponential cost increases (2x, 4x, 8x)
- Requirements that scale faster than rewards
- Upgrades that feel like 'weakening' (e.g., harder blocks)

## Affected Files
- resources/items/pickaxes/*.tres
- resources/buildings/*.tres
- scripts/autoload/economy_manager.gd
- resources/ores/*.tres (sell values by depth)

## Verify
- [ ] Plot upgrade cost curve - should be sub-exponential
- [ ] Each upgrade feels achievable within 3 mining trips
- [ ] Late-game doesn't feel like 'grinding for hours'
- [ ] Test: can reach mid-game upgrades in 30 min session
