---
title: "implement: Mining combo/streak feedback"
status: closed
priority: 3
issue-type: task
created-at: "\"2026-02-01T01:08:57.199941-06:00\""
closed-at: "2026-02-02T01:37:58.202509-06:00"
close-reason: Superseded by GoDig-implement-mining-streak-1de66c2b - both implemented in this session
---

Add satisfying feedback for consecutive mining - builds rhythm and engagement.

## Research Findings
- 'Combo sounds' - ascending pitch on rapid digs creates rhythm
- Vlambeer's 'screen shake' philosophy: every action has reaction
- Mining should feel rhythmic and satisfying, not tedious
- Fast mining = earned power fantasy from upgrades

## Implementation
1. Track consecutive block breaks within time window (1.5s)
2. Ascending pitch on SFX for combo (1.0x, 1.05x, 1.1x, etc.)
3. Small screen shake intensity increase with combo
4. Visual streak counter (subtle, corner of screen)
5. Combo break plays descending note (closure)

## Files
- scripts/player/player.gd (track mining combo)
- scripts/autoload/sound_manager.gd (pitch variation)
- scripts/camera/game_camera.gd (combo shake scaling)
- scripts/ui/hud.gd (optional combo counter)

## Verify
- [ ] Rapid mining increases pitch
- [ ] Combo builds satisfyingly
- [ ] Combo break feels like closure, not punishment
- [ ] Performance: no frame drops during combo

## Note: Duplicate Spec

**This spec is superseded by `GoDig-implement-mining-streak-1de66c2b`** which has more detailed implementation notes and emphasis on SUBTLETY. Implement that spec instead; this one can be closed as duplicate when the other is complete.
