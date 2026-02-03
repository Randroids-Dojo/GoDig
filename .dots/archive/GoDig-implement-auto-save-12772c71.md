---
title: "implement: Auto-save every 30 seconds with instant resume"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-02T18:40:56.319190-06:00\\\"\""
closed-at: "2026-02-02T22:31:50.340760-06:00"
close-reason: Reduced auto-save interval to 30 seconds. System already had event-based saves for key moments and instant resume support.
---

Implement auto-save system that saves every 30 seconds and on key events (ore collected, return to surface, upgrade purchased). Support instant resume to exact game state. 70% of players prefer resuming from last action without downtime. Use tiered saving: player progress continuous, secondary elements less frequent. Reference Session 29 save state research.
