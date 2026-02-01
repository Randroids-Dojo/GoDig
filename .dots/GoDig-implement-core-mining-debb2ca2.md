---
title: "implement: Core mining feel validation test"
status: open
priority: 0
issue-type: task
created-at: "2026-02-01T08:18:35.899455-06:00"
---

## Description
Before adding any systems, verify that the core dig action is inherently satisfying. Research shows: 'If digging isn't satisfying by itself, the game isn't for you' (Super Mining Mechs feedback).

## Context
Multiple mining games (Keep on Mining, Hytale, Super Mining Mechs) have received criticism that mining 'isn't fun enough.' This is a fundamental problem - no amount of upgrades or systems can fix unsatisfying core mechanics.

## Implementation
Create a validation test sequence:
1. Strip all rewards temporarily (no ore drops)
2. Play-test pure digging for 3 minutes
3. Evaluate: Does the rhythm of tap -> break -> move feel good?
4. Check particle effects, screen shake, sound variation
5. Document what's missing or unsatisfying

## Validation Checklist
- [ ] Block break has satisfying visual feedback
- [ ] Block break has satisfying audio feedback
- [ ] Different block types feel different
- [ ] Digging rhythm doesn't become monotonous
- [ ] Movement feels responsive, not sluggish
- [ ] Camera follows player smoothly

## Affected Files
- scripts/player/player.gd (dig action)
- scenes/test_level.tscn (test environment)
- scripts/world/dirt_block.gd (break feedback)

## Verify
- [ ] Playtest 3 minutes of pure digging without rewards
- [ ] Core digging feels satisfying without ore discovery
- [ ] No identified 'this feels bad' moments
- [ ] Tester wants to keep digging (intrinsic motivation)
