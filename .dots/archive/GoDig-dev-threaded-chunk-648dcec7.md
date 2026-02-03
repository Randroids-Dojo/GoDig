---
title: "DEV: Threaded chunk generation"
status: closed
priority: 3
issue-type: task
created-at: "\"\\\"2026-01-16T00:59:08.597232-06:00\\\"\""
closed-at: "2026-02-03T02:35:53.064750-06:00"
close-reason: Implemented threaded chunk generation using WorkerThreadPool. Added ThreadedChunkGenerator class that offloads terrain calculations (ore spawning, cave noise, vein expansion) to background threads while keeping node creation on main thread. Integrated with DirtGrid as optional optimization - auto-disabled on web platform.
---

Generate chunk data on background thread, apply tiles on main thread. Critical for mobile performance.
