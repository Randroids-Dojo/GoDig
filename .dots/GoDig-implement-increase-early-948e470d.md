---
title: "implement: Increase early ore sell values for faster first upgrade"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T01:14:18.224330-06:00"
---

Ore values too low for satisfying early progression. Current 8 minutes to first upgrade, target 3-5 minutes.

## Changes
1. Coal: $1 -> $5 (common ore should still feel rewarding)
2. Copper: $5 -> $8
3. Iron: $10 -> $15 (optional, unlocks at 50m anyway)

## Files
- resources/ores/coal.tres (sell_value: 5)
- resources/ores/copper.tres (sell_value: 8)
- resources/ores/iron.tres (sell_value: 15 optional)

## Verify
- [ ] Coal sells for $5 at General Store
- [ ] First trip earns ~$50-80 (vs current ~$46)
- [ ] Copper Pickaxe affordable in 3-5 trips (~5 min)
