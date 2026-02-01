---
title: "implement: Emergency rescue fee proportional to depth"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T09:17:21.319185-06:00"
---

Research shows: soft permadeath works best when consequences scale with risk taken. Emergency rescue should cost a PERCENTAGE of cargo (not all), proportional to depth. Deeper = higher fee percentage. This makes rescue feel fair (chose to go deep) not punishing (lost everything). Include 'rescue flare' rare drop that reduces fee when used. Affected files: scripts/autoload/game_manager.gd, rescue logic. Verify: Rescue at 50m costs less than rescue at 200m, rescue flare reduces cost by 50%, player retains some cargo always, fee is displayed before rescue is triggered.
