---
title: "implement: Upgrade celebration juice"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-01T01:08:28.426433-06:00\\\"\""
closed-at: "2026-02-02T02:12:01.325976-06:00"
close-reason: "Implemented upgrade celebration juice: screen flash, particles, stats comparison popup, hitstop effect. Supports tool, backpack, warehouse, equipment, and gadget purchases."
---

Add satisfying feedback when purchasing upgrades - a key 'hook' moment in the core loop.

## Research Findings
- 'Before/After Comparison' - slow pickaxe to fast pickaxe should be FELT
- 'Earned Power' - upgrades feel deserved because player worked for them
- Dome Keeper: 'tangible feedback in form of faster digging feels great'
- Upgrade celebration should use: screen shake, particle burst, sound fanfare

## Implementation
1. Add upgrade_purchased signal in shop.gd
2. Create upgrade celebration effect (particles + screen shake)
3. Add satisfying SFX for purchase
4. Show stat comparison popup (+50% damage!)
5. Brief slowmo/hitstop on confirm (0.1s)

## Files
- scripts/ui/shop.gd (emit celebration signal)
- scripts/effects/upgrade_celebration.gd (new)
- scripts/camera/game_camera.gd (add celebration shake)

## Verify
- [ ] Purchasing tool upgrade triggers celebration
- [ ] Stats comparison clearly visible
- [ ] Sound plays on purchase
- [ ] Screen shake feels satisfying not jarring
