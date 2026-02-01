---
title: "implement: Block crack progression visual"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T09:15:09.630211-06:00"
---

Research (Session 19): VR games show 'texture becoming more cracked right in front of your face until they shatter.' Apply to 2D: each hit on a multi-hit block should show visible crack stage progression. Not just a health bar - actual visual crack lines appearing on the block sprite. Affected files: scripts/world/dirt_block.gd, dirt_block.tscn or tilemap shader. Implementation: 3-4 crack overlay stages, blend with block texture. Verify: Hitting iron block shows cracks accumulating, final hit shatters with particles, crack progression is visible and satisfying.
