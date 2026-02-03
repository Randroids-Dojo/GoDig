---
title: "implement: Sidegrade upgrade system for late-game"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-02T18:40:50.601190-06:00\\\"\""
closed-at: "2026-02-03T02:07:47.687435-06:00"
close-reason: Implemented sidegrade system with 7 sidegrades (Precision Miner, Speed Demon, Wall Runner, Resource Magnet, Ore Sense, Second Wind, Glass Cannon). Added SidegradeData resource class, DataRegistry integration, PlayerData tracking, and Research Lab shop UI. Sidegrades provide lateral upgrades with trade-offs instead of pure stat increases.
---

Design late-game upgrades as sidegrades (new options/abilities) rather than pure stat increases. Roguelite research shows pure stat progression leads to 'inverse difficulty curve' where game gets easier over time. Sidegrades expand player options without trivializing early content. Examples: new item types, alternate abilities, inventory layouts. Reference Session 29 roguelite progression analysis.
