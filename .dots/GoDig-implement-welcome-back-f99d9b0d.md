---
title: "implement: Welcome back rewards for returning players"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T08:45:56.496723-06:00"
---

## Description

Implement a welcome back system that rewards returning players after absence, making them feel appreciated rather than punished.

## Context

From Session 15 research:
- 77% of mobile users churn within first 3 days - re-engagement is critical
- 'Claim your 1,000 free gems now\!' feels like gift, not ad
- Clash Royale's 'Season Reset' gives lapsed players fresh start
- 'The better the boost, the greater the incentive not to let it go to waste\!'
- Don't punish absence - Mistplay removed streak pressure, 'players were happier'

## Implementation

### Return Detection
- Track last_played_timestamp in save
- On game load, calculate days_away
- If days_away >= 3, trigger welcome back flow

### Reward Tiers
| Days Away | Reward |
|-----------|--------|
| 3-6 | 5 ladders + 100 coins |
| 7-13 | 10 ladders + 500 coins + 1 teleport scroll |
| 14-29 | 15 ladders + 2000 coins + 2 teleport scrolls |
| 30+ | 25 ladders + 5000 coins + 3 teleport scrolls + rare ore |

### Welcome Back Screen
- Warm greeting: 'Welcome back, Miner\!'
- Show days away: 'You were gone for X days'
- Progress reminder: 'You reached 247m depth\!'
- Animated reward claim (coins cascade, items appear)
- 'Ready to Dig?' button leads to surface

### Rules
- NO daily login streaks (creates guilt)
- NO punishment for absence
- Rewards scale with absence duration (incentivize return, not guilt)
- One-time per absence (can't exploit by repeatedly leaving)

## Affected Files
- scripts/autoload/save_manager.gd (add last_played_timestamp)
- scripts/autoload/game_manager.gd (check for return on load)
- scripts/ui/welcome_back_screen.gd (new)
- scenes/ui/welcome_back_screen.tscn (new)

## Verify
- [ ] Game tracks last played timestamp correctly
- [ ] Welcome back screen appears after 3+ days absence
- [ ] Rewards match absence duration tier
- [ ] Rewards only granted once per absence period
- [ ] No daily streak mechanics anywhere
- [ ] Screen shows progress reminder (depth reached)
