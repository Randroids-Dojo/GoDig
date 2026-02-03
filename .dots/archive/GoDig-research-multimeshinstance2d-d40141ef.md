---
title: "research: MultiMeshInstance2D optimization for repeated 2D sprites in Godot 4"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"2026-02-02T20:57:13.509382-06:00\\\"\""
closed-at: "2026-02-02T21:04:42.865685-06:00"
close-reason: Created comprehensive research doc on MultiMeshInstance2D optimization for 2D sprites. Covers batching in Godot 4.4+, MultiMesh implementation patterns, texture atlases, pooling, performance benchmarks, z-ordering challenges, and GoDig-specific recommendations for ore sparkle effects.
---

Research MultiMeshInstance2D and CanvasItem batching in Godot 4.6 for mobile 2D games. Cover: when to use MultiMesh vs TileMap vs individual sprites, implementation patterns, draw call reduction benchmarks, and texture atlas requirements. This supports the 'Ore sprite batching with MultiMesh' implementation task.
