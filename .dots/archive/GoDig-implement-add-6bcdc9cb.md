---
title: "implement: Add MiningBonusManager integration tests"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-03T06:40:53.407084-06:00\\\"\""
closed-at: "2026-02-03T06:42:11.083263-06:00"
close-reason: Added MiningBonusManager integration tests covering combo system, streak zones, lucky strikes, milestone rewards, vein bonuses, and signals
---

Add integration tests for MiningBonusManager that handles combo mining, lucky strikes, and depth milestone rewards.

## Implementation
1. Test autoload exists
2. Test combo system (on_block_mined, get_combo_multiplier, reset_combo)
3. Test streak zone functionality
4. Test lucky strike system
5. Test depth milestone rewards
6. Test vein bonus system
7. Test signal existence
8. Test save/load data

## Affected Files
- tests/test_mining_bonus.py (new)
- tests/helpers.py (add mining_bonus_manager path)

## Verify
- [ ] All tests pass
- [ ] Combo system works correctly
