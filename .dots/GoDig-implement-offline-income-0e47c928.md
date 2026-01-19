---
title: "implement: Offline income system with cap"
status: open
priority: 2
issue-type: task
created-at: "2026-01-19T00:31:11.101819-06:00"
---

## Description

Implement a passive income system that generates coins while the player is away. Requires a capped offline time to motivate return.

## Context

Mobile idle game research (see GoDig-research-mobile-idle-c59e6560) shows offline income is critical for retention:
- Creates "world keeps evolving" feeling
- Cap creates "lost opportunity" (FOMO) that motivates return
- Players feel accomplishment when returning to rewards

## Affected Files

- `scripts/autoload/save_manager.gd` - Track last_played_time
- `scripts/autoload/game_manager.gd` - Calculate offline earnings on load
- `scripts/world/surface_buildings.gd` (new) - Passive income generators
- `scenes/ui/offline_reward_popup.tscn` (new) - Show earnings popup

## Implementation Notes

### Passive Income Sources
- General Store generates coins passively when built
- Rate: 1 coin per minute base (upgradeable)
- Cap: 4 hours (240 coins max at base rate)

### On Game Load
```gdscript
func _calculate_offline_earnings() -> int:
    var last_time = SaveManager.get_last_played_time()
    var now = Time.get_unix_time_from_system()
    var elapsed_seconds = min(now - last_time, MAX_OFFLINE_SECONDS)
    var elapsed_minutes = elapsed_seconds / 60
    return int(elapsed_minutes * passive_income_rate)
```

### UI Popup
- "Welcome back!"
- "Earned X coins while away"
- If capped: "(max reached - check in more often!)"
- Tap to dismiss and collect

## Verify

- [ ] Build succeeds
- [ ] Coins accumulate based on time away
- [ ] Cap limits earnings at 4 hours
- [ ] Popup shows on return with correct amount
- [ ] Popup dismisses and adds coins to balance
- [ ] Works correctly after app force-close
