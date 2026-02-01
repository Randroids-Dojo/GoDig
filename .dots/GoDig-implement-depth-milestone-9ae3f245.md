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
1. Define milestone depths with associated rewards/content:
   - **25m**: "Getting deeper!" + First layer transition preview
   - **50m**: "Stone layer reached!" + New ore type available (iron)
   - **100m**: "Deep explorer!" + Supply Store unlocks (moved to 0m, but announces availability of better supplies)
   - **250m**: "Into the depths!" + New biome hint
   - **500m**: "Deep dive master!" + Elevator unlock hint
   - **1000m**: "Mile marker!" + Special achievement

2. Trigger celebration on first reach of each milestone
3. Show 'NEW DEPTH RECORD!' notification with milestone-specific message
4. Store milestone achievements in PlayerData
5. **Tie milestones to content unlocks** (Mr. Mine pattern):
   - Milestones should feel like progress gates, not just numbers
   - Each milestone should unlock or preview something NEW
6. Optional: small coin bonus for first-time reach (scales with depth)

## Key Insight (Session 8 Research)
From Mr. Mine analysis: "Mr Mine doesn't just reward you with cash and upgrades. It packs in surprises that trigger at specific depth milestones." Each milestone should feel like discovering a new chapter, not just incrementing a counter.

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
