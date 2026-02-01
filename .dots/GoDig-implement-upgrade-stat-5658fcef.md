---
title: "implement: Upgrade stat comparison UI"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T01:27:16.380869-06:00"
---

## Description
Show before/after stat comparison when purchasing tool or equipment upgrades.

## Context
Research: 'If the Player equips a new item, don't forget to show how the stats will change before they commit.' Players need to see the VALUE of their purchase at a glance.

## Implementation
1. In shop upgrade panel, show current vs new stats
2. Format: 'Damage: 20 → 35 (+75%)' with green arrow
3. Show all changed stats (damage, speed, tier)
4. Highlight improvements in green, reductions in red
5. Show net improvement summary: 'Overall: +50% mining power'

## Affected Files
- `scripts/ui/shop.gd` - Calculate stat differences
- `scenes/ui/upgrade_comparison.tscn` - New comparison UI component
- `scripts/ui/upgrade_comparison.gd` - Stat diff logic and formatting

## Verify
- [ ] Stats show current → new format
- [ ] Improvements shown in green with up arrow
- [ ] Reductions shown in red with down arrow
- [ ] Percentage change calculated correctly
- [ ] Comparison visible without scrolling
