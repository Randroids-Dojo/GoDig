---
title: "research: Ore spawning integration"
status: open
priority: 0
issue-type: task
created-at: "2026-01-18T23:35:22.628926-06:00"
---

How should ores spawn in blocks? DirtBlock currently uses DataRegistry for hardness/color but doesn't check for ores. Need to decide: Should each block have a chance to BE an ore? Or should ores be separate entities? How does hit_block() integrate with OreData? How should visual appearance change for ore blocks?
