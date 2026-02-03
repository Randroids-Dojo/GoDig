---
title: "implement: Progressive crack pattern on blocks"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-02-02T18:35:51.250805-06:00\""
closed-at: "2026-02-02T22:40:47.763991-06:00"
close-reason: "Already implemented: block_crack_overlay.gd provides 4-stage progressive cracks at 25%/50%/75%/100% damage thresholds. dirt_block.gd integrates it via _update_crack_overlay() on each hit. Includes scaling shake effects."
---

Based on block break animation research (Session 28), implement progressive crack pattern on blocks before break. Multi-stage cracks create 'more immersive and satisfying' experience. Satisfying particle burst on break, subtle screen shake on hard blocks. Frame-synchronized effects for best feel.
