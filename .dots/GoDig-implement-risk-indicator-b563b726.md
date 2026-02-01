---
title: "implement: Risk indicator for deep dives"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T01:09:30.102005-06:00"
---

Visual indicator showing risk level as player ventures deeper without return path.

## Research Findings
- 'Risk/Reward Gradient' - deeper = more danger but better rewards
- Players should 'choose their risk tolerance'
- Dome Keeper: 'How long will you risk mining?'
- Risk awareness creates strategic decision making

## Implementation
1. HUD indicator showing 'escape difficulty' (based on depth + ladder count)
2. Green/Yellow/Red states for low/medium/high risk
3. Factor in: current depth, ladders owned, known ladder positions
4. Tooltip: 'You are X blocks from nearest ladder'
5. Optional: danger pulse when entering red zone

## Files
- scripts/ui/hud.gd (risk indicator)
- scripts/autoload/game_manager.gd (calculate risk level)
- scripts/world/dirt_grid.gd (track placed ladders)

## Verify
- [ ] Indicator visible but not obtrusive
- [ ] Risk calculation feels accurate
- [ ] Red zone warning is noticeable
- [ ] Doesn't spoil exploration fun
