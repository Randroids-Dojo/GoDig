---
title: "implement: Jackpot discovery celebration"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"\\\\\\\"2026-02-01T01:20:23.587604-06:00\\\\\\\"\\\"\""
closed-at: "2026-02-02T00:00:05.941642-06:00"
close-reason: Implemented jackpot discovery celebration with tiered screen flash, particle bursts, distinct audio per rarity (uncommon/rare/epic/legendary), and haptic feedback. Common ores get normal feedback; rare+ get screen flash, jackpot burst particles, and specialized discovery sounds.
---

## Description
Add enhanced celebration feedback for rare ore/gem discoveries - screen flash, unique sound, haptic burst, popup notification.

## Context
Research shows rare finds should create 'jackpot moments' with distinct visual/audio. Currently, discovering a legendary ruby feels similar to finding coal. The brain's dopamine system responds more strongly to uncertain rewards with clear celebration signals.

## Implementation
1. In test_level.gd `_on_block_dropped()`, check ore rarity
2. For rare/epic/legendary finds, trigger celebration:
   - Screen flash (white/gold)
   - Unique discovery sound
   - Larger/longer screen shake
   - Haptic burst (HapticFeedback.notification_success)
   - Floating text with rarity color
3. Add 'jackpot' particle burst effect

## Affected Files
- `scripts/test_level.gd` - Add rarity check and celebration trigger
- `scripts/autoload/sound_manager.gd` - Add rare discovery sounds (uncommon/rare/epic/legendary)
- `scripts/effects/jackpot_burst.tscn` - New particle burst scene
- `scripts/effects/screen_flash.gd` - Simple white/gold flash effect

## Verify
- [ ] Common ore: normal feedback
- [ ] Rare ore: enhanced sound + small screen flash
- [ ] Epic ore: larger flash + longer shake + haptic
- [ ] Legendary: full celebration (flash + shake + haptic + particle burst)
- [ ] Each rarity tier feels distinctly more exciting
