---
title: "implement: First upgrade guidance flow"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T01:09:03.267020-06:00"
---

Ensure players experience their first upgrade within 2-5 minutes - critical retention moment.

## Research Findings
- 'Time to first upgrade: 2-5 minutes' (design doc target)
- First upgrade MUST feel impactful and earned
- Early game: quick upgrades, fast progress
- Tutorial should guide toward first shop visit

## Implementation
1. Ensure first ore values allow tool upgrade in ~3-4 trips
2. Tutorial prompts: 'Return to surface to sell!' at 50% inventory
3. Tutorial prompts: 'You can afford an upgrade!' when threshold met
4. First upgrade triggers special celebration (more intense)
5. Show clear before/after comparison on first upgrade

## Files
- scripts/autoload/game_manager.gd (tutorial tracking)
- scripts/ui/tutorial_overlay.gd (guidance prompts)
- scripts/ui/shop.gd (first upgrade detection)

## Verify
- [ ] New player reaches first upgrade in under 5 minutes
- [ ] Tutorial prompts guide without being annoying
- [ ] First upgrade feels like a milestone
- [ ] Clear progression visible after upgrade
