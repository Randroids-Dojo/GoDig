---
title: "implement: FTUE first 60 seconds - block in 5s, ore in 30s, sell in 60s"
status: closed
priority: 0
issue-type: task
created-at: "\"2026-02-01T09:58:25.000840-06:00\""
closed-at: "2026-02-01T09:58:50.604718-06:00"
close-reason: Duplicate of GoDig-implement-ftue-60-94baf4fa which has more comprehensive spec. The timing targets (5s/30s/60s) should be added to the existing dot.
---

## Description
Optimize the first-time user experience to hit critical engagement milestones: first block breaks within 5 seconds of control, first ore discovery within 30 seconds, first sell within 60 seconds.

## Context
Research shows: 'First few minutes often determine whether a player will continue or uninstall.' D1 retention issues = FTUE problem. Players must feel the core loop immediately. 88% of users return after experiencing a satisfying cycle.

## Affected Files
- `scenes/main.tscn` - Starting position optimization
- `scripts/world/terrain/chunk_manager.gd` - Guaranteed shallow ore spawn
- `scripts/ui/tutorial/ftue_manager.gd` - New file for timing tracking
- `scripts/autoload/game_manager.gd` - FTUE state tracking

## Implementation Notes
- Player should start directly above first mineable block
- First ore MUST spawn within 3 blocks depth (guaranteed, not random)
- Surface shop should be immediately accessible (no walking distance)
- Skip any intro screens for returning players
- Track FTUE completion metrics for analytics

## Verify
- [ ] New player breaks first block within 5 seconds of gaining control
- [ ] First ore appears within 30 seconds of play
- [ ] First sell completes within 60 seconds
- [ ] No friction between dig and sell (shop immediately accessible)
- [ ] Stopwatch test with fresh install confirms timings
