---
title: "RESEARCH: Early game ladder economy and stuck recovery"
status: closed
priority: 0
issue-type: task
created-at: "\"2026-02-01T00:39:52.779953-06:00\""
closed-at: "2026-02-01T00:49:46.471833-06:00"
close-reason: "Design decisions made: 1) Move ladders to 0m, 2) Starting ladders, 3) Forfeit Cargo escape. Implementation dots created."
---

## Problem
Supply Store (sells ladders) unlocks at 100m, but players need ladders by 10-25m.
This breaks the core loop: dig → collect → ladder up → sell → buy ladders → dig deeper.

## Design Decisions (RESOLVED)
1. ✅ Move ladder sales to 0m (General Store or Supply Store)
2. ✅ Give 2-3 starting ladders to teach mechanic
3. ⏸️ Rare ladder drops from mining (lower priority, P3)
4. ✅ Add 'Forfeit Cargo' escape option (lose ore/gems, keep tools)

## Recovery Options (Intentional Choices)
| Option | Cost | Use Case |
|--------|------|----------|
| Wall-Jump | Free (skill) | Shallow shafts (~10-15 blocks) |
| Forfeit Cargo | Lose ore/gems only | Stuck, want to keep ladders/tools |
| Emergency Rescue | Lose ALL inventory | Desperate, full reset |
| Reload Save | Lose time since save | Made a mistake |

Note: Death is a PUNISHMENT (accidental), not a recovery option.

## Ore Economics (for reference)
- Coal: $20 (2.5 coal = 1 ladder at $50)
- Copper: $40 (1.25 copper = 1 ladder)
- Ladder sell value: $5 (can recover 10% if desperate)

## Implementation Order
1. P1: Move Supply Store to 0m (or add ladders to General Store)
2. P2: Starting ladders (2-3)
3. P2: Forfeit Cargo option
4. P3: Rare ladder drops (if needed after testing)
