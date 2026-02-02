---
title: "implement: Progress-to-upgrade display on surface"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"2026-02-01T01:48:47.121310-06:00\\\"\""
closed-at: "2026-02-02T00:12:10.539564-06:00"
close-reason: "Upgraded progress display to surface-only, added 'Almost there\\!' text at 80%+, added motivational 'Just $X more\\!' message, improved color transitions. Updates on depth changes."
---

Show coin balance + next affordable upgrade with progress bar when at surface. Example: '250/500 - Copper Pickaxe' with progress indicator. Creates 'just 50 more coins!' motivation for one more run.

## Description
Display visible progress toward the next meaningful upgrade when player is at surface. This is a critical "one more run" trigger from roguelite psychology research.

## Context
From Session 4 research:
- "Visible progress toward goals" keeps players engaged
- Hades: "drip feeding story makes me genuinely excited to keep playing"
- Players need to see they're working toward something tangible
- "Just 50 more coins!" is a powerful motivator for another dive

## Implementation

### Logic
1. When player is at surface (y <= 0), show upgrade progress panel
2. Find next affordable upgrade across all shops:
   - Compare player coins to all available upgrades
   - Pick the CLOSEST upgrade player can't yet afford
   - If player can afford everything, show "All upgrades purchased!"
3. Display: "[coins]/[cost] - [upgrade name]" with progress bar
4. Optional: When within 20% of goal, show encouraging text: "Almost there!"

### Visual Design
```
┌─────────────────────────────┐
│ 💰 250/500                   │
│ ████████░░░░░░░ Copper Pick │
│ "Just 250 more coins!"      │
└─────────────────────────────┘
```

- Position: Below or beside coin counter in HUD
- Progress bar fills left-to-right
- Color: Gold/yellow for progress, gray for remaining
- Text size: Slightly smaller than coin counter

### Edge Cases
- Player can afford next upgrade: "You can buy Copper Pickaxe!" (no progress bar)
- All upgrades purchased: "All upgrades complete!" or hide panel
- Multiple affordable upgrades: Show the one closest to current coin amount

## Affected Files
- `scripts/ui/hud.gd` - Add upgrade progress display
- `scripts/autoload/player_data.gd` - Query upgrade costs
- `scenes/ui/upgrade_progress.tscn` - New UI component

## Verify
- [ ] Progress panel visible only at surface
- [ ] Shows correct next upgrade and cost
- [ ] Progress bar fills correctly as coins increase
- [ ] "Almost there!" message at 80%+ progress
- [ ] Updates immediately after selling
- [ ] Hidden when all upgrades purchased
- [ ] Does not obscure other HUD elements
