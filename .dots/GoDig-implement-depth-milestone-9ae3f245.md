---
title: "implement: Depth milestone celebrations"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T01:08:33.680108-06:00"
---

Add celebratory moments when reaching depth milestones - critical retention hook.

## Research Findings
- 'Depth as Achievement' - reaching new depths is tangible progress
- Layer transitions should be 'mini-achievements'
- 'Just one more layer' psychology keeps players engaged
- Milestones create natural stopping points (good for mobile)

## Implementation
1. Define milestone depths: 25m, 50m, 100m, 250m, 500m, 1000m
2. Trigger celebration on first reach of each milestone
3. Show 'NEW DEPTH RECORD!' notification
4. Store milestone achievements in PlayerData
5. Optional: small coin bonus for first-time reach

## Files
- scripts/autoload/game_manager.gd (track milestones)
- scripts/autoload/player_data.gd (store reached milestones)
- scripts/ui/milestone_notification.gd (enhance celebration)

## Verify
- [ ] First time reaching 50m shows celebration
- [ ] Celebration includes screen effect + sound
- [ ] Milestone stored in save data
- [ ] Subsequent visits don't re-trigger
- [ ] Achievement tracks depth milestones
