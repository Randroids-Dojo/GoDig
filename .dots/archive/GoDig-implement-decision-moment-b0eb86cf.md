---
title: "implement: Decision moment design - ladder scarcity creates meaningful choices"
status: closed
priority: 1
issue-type: task
created-at: "\"2026-02-01T09:58:15.623375-06:00\""
closed-at: "2026-02-02T09:52:25.050922-06:00"
close-reason: Design principle implemented through ladder warnings, inventory full popup, and forfeit cargo option
---

## Description
Design the game around decision moments, not just digging satisfaction. The FUN comes from choices like 'my ladders are low but there's ore right there.'

## Context
Research shows: 'Digging is not the fun part... the FUN comes from the DECISION MOMENT.' Deep Sea Adventure's tension comes from shared oxygen creating constant risk/reward decisions. Our ladder economy creates similar tension but solo (no social blame).

## Affected Files
- `scripts/player/player.gd` - Ladder consumption logic
- `scripts/ui/hud.gd` - Decision moment UI prompts
- `scripts/world/terrain/ore_spawner.gd` - Ore placement near 'decision points'

## Implementation Notes
- Place valuable ore at strategic depths where ladders become tight
- Create visual 'temptation' when player sees ore but has low ladders
- Consider 'one more block' prompts when inventory nearly full
- Sound design should heighten tension during low-ladder moments

## Verify
- [ ] Player naturally encounters 'should I push or return' moments
- [ ] Ore placement creates temptation at appropriate depths
- [ ] Low-ladder audio/visual feedback increases tension
- [ ] Playtesters report feeling 'tough decisions'
