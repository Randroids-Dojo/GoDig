---
title: "implement: Challenge run modifier system (v1.1)"
status: active
priority: 3
issue-type: task
created-at: "\"2026-02-01T09:25:26.724719-06:00\""
---

## Description

Add optional difficulty modifiers that experienced players can enable for challenge runs. Similar to Hades' Pact of Punishment (Heat System).

## Context

From Session 20 research on difficulty scaling:
- Hades doesn't auto-scale difficulty - instead offers player-controlled challenge
- 'Pact of Punishment lets players opt-in to harder modifiers'
- 'Even failed runs yield story progress, ensuring no session feels wasted'
- Roguelikes with perfect difficulty balance reward BOTH skill AND persistence

## Challenge Modifiers

### Tier 1 Modifiers (Cosmetic rewards: recolors)
- **Scarce Ladders**: Start with only 3 ladders (vs 5)
- **No Wall-Jump**: Disable wall-jump ability
- **Fragile Cargo**: Lose 50% more ore on emergency rescue
- **Weak Pickaxe**: Mining takes 1 extra hit per block

### Tier 2 Modifiers (Cosmetic rewards: special pickaxe skins)
- **Timed Run**: Reach 100m within 3 minutes
- **Minimalist**: Complete run with max 5 ladders purchased
- **Glass Cannon**: One-hit emergency rescue trigger
- **Depth Sprint**: Reach personal best depth +50m

### Tier 3 Modifiers (Cosmetic rewards: rare badges/titles)
- **Ironman**: No emergency rescue allowed (lose all cargo on stuck)
- **Pacifist Miner**: Cannot break any non-ore blocks (path around them)
- **Speed Demon**: Complete full loop in under 90 seconds

## Reward System

- Each modifier completed unlocks cosmetic reward
- Completing multiple modifiers simultaneously = bonus rewards
- Weekly leaderboard for challenge completion count
- Achievements for completing specific modifier combinations

## UI Design

### Challenge Selection Screen
- Toggle each modifier on/off before starting run
- Show current active modifiers during run (small icons)
- Show potential rewards before confirming

### Post-Run Summary
- Highlight which challenges were completed
- Reveal unlocked cosmetics with celebration
- Show leaderboard position if applicable

## Affected Files

- scripts/autoload/challenge_manager.gd (NEW)
- scripts/ui/challenge_selection.gd (NEW)
- scripts/ui/challenge_hud.tscn (NEW)
- scripts/player/player.gd - Check active modifiers
- scripts/autoload/save_manager.gd - Track completed challenges
- resources/challenges/*.tres - Challenge definitions

## Verify

- [ ] Build succeeds
- [ ] Each modifier correctly affects gameplay
- [ ] Modifiers can be combined
- [ ] Cosmetic rewards unlock correctly
- [ ] Challenge completion persists across sessions
- [ ] Normal gameplay unaffected when no challenges active
- [ ] UI clearly shows active challenges during run

## Priority

This is a v1.1 feature. Core gameplay must be solid first. This extends mastery players' engagement after they've completed the upgrade path.

## Dependencies

- Core game loop complete
- Emergency rescue system working
- Basic cosmetic system (pickaxe skins)
