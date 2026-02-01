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

## Session 13 Research Context

From SteamWorld Dig analysis:
- Sound design critical: "tinkling noise becomes clearer with higher tempo with every subsequent hit"
- "When you get that newest upgrade so you can dig through each block with only one hit, it's immensely satisfying"
- Sound helps player know when a block is about to break

From Vampire Survivors pattern:
- Minimal input but MAXIMUM feedback (constant visual rewards)
- Our tap-to-dig is simple; feedback (particles, sounds, toasts) must be rich

From mining game consensus:
- Deep Rock Galactic: "digging away and finding caverns is so much fun"
- Discovery and exploration, not just extraction
- Mining must be inherently satisfying BEFORE any systems/upgrades

## Related Specs
- `GoDig-implement-distinct-audio-09fbd1b1` - Distinct audio/visual per pickaxe tier (Session 13)
- `GoDig-implement-mining-sound-54915d26` - Mining sound design system
