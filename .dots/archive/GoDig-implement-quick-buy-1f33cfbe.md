---
title: "implement: Quick-buy ladder shortcut"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"2026-02-01T01:09:10.774999-06:00\\\"\""
closed-at: "2026-02-01T23:30:16.259752-06:00"
close-reason: Added quick-buy button below ladder quickslot, visible only at surface with enough coins, shows confirmation toast
---

Add fast ladder purchase from HUD for seamless core loop.

## Research Findings
- Mobile controls: 'Quick-slot for ladders always accessible'
- Don't break flow: returning to shop breaks immersion
- Dome Keeper: tight time cycles = every second matters
- Players should be able to buy ladders without full shop visit

## Implementation
1. Add small purchase button next to ladder count in HUD
2. Button visible only when at surface AND can afford ladder
3. Single tap = buy 1 ladder (deduct , add to inventory)
4. Optional: long-press = buy 5 ladders
5. Show brief confirmation toast (+1 Ladder!)

## Files
- scripts/ui/hud.gd (add quick-buy button)
- scripts/autoload/inventory_manager.gd (buy_ladder helper)

## Verify
- [ ] Button appears when at surface with enough coins
- [ ] Button hidden when underground or broke
- [ ] Purchase updates HUD immediately
- [ ] Quick and responsive (no lag)
