---
title: "implement: Next upgrade goal HUD display"
status: open
priority: 2
issue-type: task
created-at: "2026-01-19T00:31:11.204854-06:00"
---

## Description

Show the player's next upgrade goal in the HUD so they always have a clear target.

## Context

Mobile idle game research shows players need:
- Clear "next step" visibility
- Cost vs current coins comparison
- Bite-sized goals to work toward

## Affected Files

- `scenes/ui/hud.tscn` - Add upgrade goal panel
- `scripts/ui/hud.gd` - Logic to determine and display next goal
- `scripts/autoload/player_stats.gd` - Query next upgrade

## Implementation Notes

### Display Format
```
Next: Bronze Pickaxe
Cost: 50 coins (You have: 35)
[===----] 70%
```

### Goal Priority
1. Tool upgrade (if affordable or close)
2. Backpack upgrade (if inventory often full)
3. Building purchase (if unlocked)

### UI Updates
- Update on coin change
- Pulse/highlight when affordable
- Hide if all upgrades purchased

## Verify

- [ ] Build succeeds
- [ ] Shows next upgrade with cost
- [ ] Progress bar fills as coins increase
- [ ] Highlights when affordable
- [ ] Updates immediately on purchase
- [ ] Hides when nothing to upgrade
