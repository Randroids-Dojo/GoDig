---
title: "implement: Emergency rescue lesson-learned framing"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-02-01T09:31:54.526611-06:00\""
closed-at: "2026-02-02T09:51:11.500754-06:00"
close-reason: Emergency rescue with lesson framing already in pause_menu.gd
---

## Description
Reframe emergency rescue from punishment to learning opportunity. Show what was lost AND what was gained (knowledge, map memory, etc.) to make death feel like progress.

## Context
From Session 21 research on death penalty design:
- 'Permadeath works when there are NOT sudden-death situations'
- 'Death becomes opportunity' (Blazblue pattern)
- Rogue Legacy: 'death is necessity for progress, not punishment'
- Our emergency rescue should feel like 'lesson learned' not punishment

## Implementation
1. Emergency rescue summary screen shows:
   - Cargo lost (with visuals of what was forfeited)
   - Rescue fee paid
   - BUT ALSO:
   - Depth reached (new record?)
   - Ore types discovered
   - Caves explored
   - 'Knowledge gained' summary
2. Positive framing: 'You made it back alive. Here's what you learned:'
3. Optional: Persist some map fog-of-war clearing between runs

## Affected Files
- scripts/autoload/game_manager.gd - rescue logic
- scenes/ui/rescue_summary.tscn - new summary screen
- scripts/ui/rescue_summary.gd - display logic

## Verify
- [ ] Rescue screen shows both losses AND gains
- [ ] Tone is educational, not punishing
- [ ] Player feels motivated to try again
- [ ] Quick 'Try Again' button prominent
