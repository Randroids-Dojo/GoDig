---
title: "research: Stuck-recovery flow analysis"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T01:09:16.578282-06:00"
---

Map out all stuck scenarios and ensure each has a viable recovery path.

## Research Findings
- SteamWorld Dig: 'Wall-jumping transformed stuck from binary failure to recoverable'
- Getting stuck should feel like a challenge, not a failure
- Players who escape feel clever and satisfied
- Emergency options should exist but not trivialize challenge

## Scenarios to Analyze
1. Dug straight down, no ladders, can't wall-jump out
2. Fell into deep hole, can't reach walls
3. Used all ladders, far from surface
4. Inventory full deep underground

## Recovery Options to Verify
- Wall-jump: what's the max escapable depth?
- Ladders: do starting items help?
- Forfeit Cargo: implemented?
- Emergency Rescue: too punishing?
- Teleport Scroll: available early enough?

## Deliverables
- Stuck scenario flowchart
- Implementation dots for any gaps
- Tuning recommendations for wall-jump height
