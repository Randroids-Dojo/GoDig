---
title: "research: Auto-save frequency and player perception - finding the sweet spot"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-02T19:07:24.210606-06:00\\\"\""
closed-at: "2026-02-02T19:11:46.470231-06:00"
close-reason: Documented auto-save frequency research in Docs/research/auto-save-frequency.md - 30-second interval validated, event-based saves recommended, UI patterns documented
---

## Purpose
Research optimal auto-save frequency for mobile games to inform GoDig-implement-auto-save-12772c71.

## Background
The implementation task specifies 'every 30 seconds' but we should validate this timing. Questions:
- Do players notice/appreciate frequent saves?
- Does save frequency affect performance on mobile?
- How do players perceive save indicators?
- What do successful mobile games do?

## Games to Study
- Mobile roguelites with auto-save
- Clash Royale, Pokemon GO save patterns
- Stardew Valley mobile
- Any games praised for save UX

## Research Questions
1. What's the optimal save frequency for mobile?
2. Should saves be time-based, event-based, or both?
3. How should save progress be communicated to players?
4. What events should trigger immediate saves?
5. How do players feel about cloud vs local saves?

## Expected Outputs
- Recommended save frequency for GoDig
- Save trigger event list (depth milestones, ore collection, etc.)
- UI recommendations for save indicators
- Performance considerations
