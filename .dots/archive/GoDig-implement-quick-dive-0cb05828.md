---
title: "implement: Quick-dive button after selling"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"\\\\\\\"2026-02-01T01:48:48.500220-06:00\\\\\\\"\\\"\""
closed-at: "2026-02-02T01:50:49.812267-06:00"
close-reason: Implemented quick-dive button after selling at General Store
---

After selling at General Store, show 'Dive Again' button that returns player to mine entrance immediately. Reduces friction between runs. Only show if player has at least 3 ladders.

## Description
Reduce friction between runs by offering quick return to mine after selling. Captures the "just one more run" momentum.

## Context
From Session 4 research:
- "In roguelikes, you can die and restart in a matter of seconds"
- Quick restart speed is a key trigger for "one more run" psychology
- Don't force long shop visits between runs
- Reduce decision fatigue when player is ready to dive again

## Implementation

### After Sell Transaction
1. When player completes a "Sell All" or sells items at General Store
2. Check if player has >= 3 ladders in inventory
3. If yes, show "Dive Again" button at bottom of sell confirmation
4. If no, show "Need ladders! Visit Supply Store"

### "Dive Again" Button Behavior
1. Close shop UI
2. Teleport player to mine entrance (x=0, y=-16 or similar)
3. Auto-save game
4. Brief "whoosh" transition effect (optional)

### Visual Design
```
┌─────────────────────────────┐
│ Sold: 3x Coal, 2x Copper    │
│ Earned: +80 coins           │
│ Balance: 330 coins          │
│                             │
│ [Browse Shop] [DIVE AGAIN!] │
└─────────────────────────────┘
```

- "Dive Again" button should be prominent/highlighted
- Use action color (green?) to indicate readiness
- "Browse Shop" is secondary option

### Safety Checks
- Require minimum 3 ladders (configurable)
- Show ladder count on button: "Dive Again (5 🪜)"
- If low on ladders, change button text to warning state

## Affected Files
- `scripts/ui/shop.gd` - Add post-sell dive option
- `scripts/autoload/game_manager.gd` - Teleport to mine function
- `scenes/ui/sell_confirmation.tscn` - Add dive button

## Verify
- [ ] Button appears after selling at General Store
- [ ] Button hidden if <3 ladders
- [ ] Clicking teleports player to mine entrance
- [ ] Game auto-saves on dive
- [ ] Works from any shop position (not just at counter)
- [ ] Ladder count displayed on button
- [ ] "Browse Shop" alternative available
