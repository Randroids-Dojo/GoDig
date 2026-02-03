---
title: "implement: Juice calibration - medium level"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-02T18:40:53.681905-06:00\\\"\""
closed-at: "2026-02-02T22:40:00.322774-06:00"
close-reason: Added juice_level setting (Off/Low/Medium/High) to SettingsManager with Medium as default. Particle amounts and screen shake now respect juice level multipliers. Settings popup includes Visual Effects dropdown.
---

Calibrate game feel 'juice' to medium level. Research (N=3018) shows both None and Extreme juice decrease play time - Medium/High is optimal. Implementation: progressive crack pattern on blocks, particle burst on break, subtle screen shake on hard blocks. Avoid over-juicing that causes stuttering or overwhelming feedback. Reference Session 29 game feel research.
