---
title: "implement: Ore sprite batching with MultiMesh"
status: closed
priority: 3
issue-type: task
created-at: "\"\\\"2026-02-02T18:44:11.695554-06:00\\\"\""
closed-at: "2026-02-02T21:25:27.831376-06:00"
close-reason: "Implemented MultiMesh-based ore sparkle system: MultiMeshPool utility class, OreSparkleManager for batched rendering, integrated into DirtGrid with toggle between legacy and optimized mode. Reduces draw calls from 100+ to 1 for sparkle effects."
---

Use Godot MultiMeshInstance2D for repeated ore/block sprites to reduce draw calls. Critical for mobile performance. Also use texture atlases and appropriate collision detection complexity. Profile regularly with Godot built-in tools. Reference Session 30 Godot mobile optimization research.
