---
title: "implement: Emergency rescue as learning moment"
status: closed
priority: 1
issue-type: task
created-at: "\"2026-02-01T09:52:25.480490-06:00\""
closed-at: "2026-02-02T09:51:10.621136-06:00"
close-reason: Emergency rescue implemented in pause_menu.gd with instant teleport to surface
---

## Description
Frame emergency rescue as educational opportunity, not punishment. Show what player learned.

## Context
Roguelite research (2025) shows: 'Knowledge carries forward - learning from failure is the loop.' Hades innovation: 'Dying was no longer failure.' GoDig emergency rescue should feel like progress.

## Implementation
1. On emergency rescue trigger, show summary screen:
   - Depth reached (record? new personal best?)
   - Ores collected (how much retained vs lost)
   - Map revealed (show explored areas)
   - 'Lessons learned' hints (if applicable)
2. Tone: 'That was a close call! Here's what you discovered...'
3. Quick restart button prominent
4. Optional: 'Try again' with brief strategy tip

## Affected Files
- scenes/ui/rescue_summary.tscn (new)
- scripts/ui/rescue_summary.gd (new)
- scripts/game/emergency_rescue.gd (trigger summary)

## Verify
- [ ] Rescue screen shows useful information
- [ ] Tone is encouraging, not punitive
- [ ] Player understands what was gained (not just lost)
- [ ] Quick restart is immediate (no friction)
