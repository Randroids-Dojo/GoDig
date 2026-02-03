---
title: "implement: Ore sprite batching with MultiMesh"
status: open
priority: 3
issue-type: task
created-at: "2026-02-02T18:44:11.695554-06:00"
---

Use Godot MultiMeshInstance2D for repeated ore/block sprites to reduce draw calls. Critical for mobile performance. Also use texture atlases and appropriate collision detection complexity. Profile regularly with Godot built-in tools. Reference Session 30 Godot mobile optimization research.
