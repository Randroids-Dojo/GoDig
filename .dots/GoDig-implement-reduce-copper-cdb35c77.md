---
title: "implement: Reduce Copper Pickaxe cost for faster first upgrade"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T01:14:20.276464-06:00"
---

Alternative/complementary to ore value increase. Reduce upgrade cost barrier.

## Change
- Copper Pickaxe cost: $500 -> $300

## Why
- First upgrade should happen at ~3-5 minutes
- Combined with ore value increase, achievable in 2-3 trips

## Files
- resources/tools/copper_pickaxe.tres (cost: 300)

## Verify
- [ ] Shop shows Copper Pickaxe at $300
- [ ] Player can afford after 2-3 successful trips
