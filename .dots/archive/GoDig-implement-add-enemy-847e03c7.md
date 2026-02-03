---
title: "implement: Add enemy-mining integration tests"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-03T06:22:28.937694-06:00\\\"\""
closed-at: "2026-02-03T06:23:16.259915-06:00"
close-reason: "Added 9 integration tests for enemy-mining system: peaceful mode, spawn depths, enemy properties, warning delay"
---

## Description
Add integration tests for enemy spawning during mining.

## Context
The enemy system is integrated with block breaking in dirt_grid.gd (lines 779-780, 867-868):
- EnemyManager.check_enemy_spawn() is called when blocks are broken
- EnemyManager.register_spawn_point() is called when caves are generated

Current tests only verify the methods exist, not the actual integration.

## Tests to Add
1. Test that breaking blocks at depth 100+ CAN spawn cave_bat (mock/verify method call)
2. Test that peaceful_mode prevents enemy spawning
3. Test that depth 0 (surface) never spawns enemies
4. Test enemy spawn rates at different depths

## Affected Files
- tests/test_mining.py (add enemy integration tests)
- tests/test_new_features.py (extend enemy tests)

## Verify
- [ ] Tests pass locally
- [ ] Peaceful mode test confirms no spawns
- [ ] Depth-based spawning is verified
