---
title: "implement: Numbers go up visibility"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T08:40:58.809827-06:00"
---

## Description

Make all the 'numbers going up' highly visible and satisfying. This is the core psychological hook of incremental games.

## Context

Research (Session 14) found:
- Incremental game hook: 'you click the cookie, you have a cookie'
- 'Number go up. Happy.' captures the core appeal
- Ore count, coin count, depth record are all 'numbers going up'
- Make each visible and satisfying

Numbers that matter in GoDig:
1. Coins (wealth/progress)
2. Ore in inventory (current haul value)
3. Depth (how far down this run)
4. Depth record (all-time best)
5. Ladder count (resource management)

## Implementation

### HUD Number Display
- **Coins**: Top-right, with coin icon. Flash gold when increasing.
- **Inventory value**: Show estimated sell value near inventory icon
- **Current depth**: Show with down-arrow icon. Update as player descends.
- **Depth record**: Show small 'Best: Xm' below current depth
- **Ladders**: Show with ladder icon. Flash red when low (<3)

### Number Animation
When any number increases:
1. Number pulses slightly larger (1.2x scale)
2. Color flash (gold for coins, green for ore, blue for depth)
3. Small '+X' floater rises from the number
4. Settling animation (return to normal size with slight bounce)

### Milestone Celebrations
- New depth record: 'NEW RECORD!' toast + number flash
- First 100 coins: 'First hundred!' toast
- Inventory full: 'Full load!' warning + visual indicator

### Sound Design
- Coin increase: Satisfying 'cha-ching'
- Ore pickup: Soft 'clink'
- Depth record: Triumphant chime
- Ladder place: Wooden 'clunk'

## Affected Files
- `scenes/ui/hud.tscn` - Number display layout
- `scripts/ui/hud.gd` - Number update animations
- `scripts/ui/number_animator.gd` - Reusable animation component
- `scripts/audio/ui_sounds.gd` - Number change sounds

## Verify
- [ ] All five key numbers visible on HUD at all times
- [ ] Number increase triggers pulse animation
- [ ] '+X' floater visible on coin/ore gain
- [ ] Depth record updates immediately when beaten
- [ ] Milestone toasts trigger at appropriate thresholds
- [ ] Sound effects sync with number changes
- [ ] Animations don't cause performance issues
