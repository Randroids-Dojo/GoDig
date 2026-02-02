---
title: "implement: Core loop greybox validation test"
status: closed
priority: 0
issue-type: task
created-at: "\"\\\"2026-02-01T09:37:04.573331-06:00\\\"\""
closed-at: "2026-02-01T22:48:54.190928-06:00"
close-reason: Created greybox_mining_test.tscn - standalone test scene for validating core mining feel without progression. Includes player, grid, blocks, stats tracking, and playtest instructions.
---

## Description

Validate that tap-to-mine feels fun with NO systems before adding progression.

## Context

2025-2026 research consensus: 'If your core loop isn't fun, it doesn't matter how great your narrative or physics interactions are.' The micro loop must be satisfying with greyboxes before any progression systems.

## Implementation

### Greybox Test Level
Create a test scene with:
- Simple grey blocks (no textures)
- Basic tap-to-mine (no upgrades, no progression)
- Placeholder particle effect
- Placeholder sound

### Test Criteria (Playtest Checklist)
1. Does breaking a single block feel satisfying?
2. After 30 seconds of mining, does it feel repetitive?
3. Is there any 'one more block' urge?
4. Does movement between blocks feel good?
5. Is the timing of block destruction right (not too fast, not too slow)?

### Iteration
If test fails:
- Adjust block destruction timing
- Tweak particle/sound feedback
- Modify input responsiveness
- Test again until satisfying

### Metrics
- Record playtest feedback
- Note specific pain points
- Document required iterations

## Affected Files
- scenes/test/greybox_mining_test.tscn (new)
- scripts/test/greybox_player.gd (minimal player script)

## Verify
- [ ] Test level exists and is runnable
- [ ] At least 3 people playtest greybox
- [ ] Core mining feels satisfying without ANY progression
- [ ] Documented what works and what doesn't
