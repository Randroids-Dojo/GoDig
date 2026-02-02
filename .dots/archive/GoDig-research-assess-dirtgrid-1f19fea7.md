---
title: "research: Assess DirtGrid vs ChunkManager architecture for MVP"
status: open
priority: 2
issue-type: task
created-at: "2026-01-19T12:04:07.136450-06:00"
---

Current DirtGrid uses row-by-row generation with object pooling. Specs describe 16x16 chunk system (ChunkData, ChunkManager). Evaluate: Is chunk migration required for MVP? What are the trade-offs? Should we keep DirtGrid for MVP and add chunk system for v1.0?
