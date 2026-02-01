---
title: "implement: Post-launch economy tuning framework"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T08:11:11.691809-06:00"
---

Create infrastructure for remote economy balancing based on Hades 2 early access learnings.

## Context
Hades 2 achieved Metacritic 94 by iterating on balance based on player feedback. Supergiant found their 'sweet spot' for Early Access timing. Plan for post-launch tuning is critical for retention.

## Description
Create a system that allows economy values to be tuned without app updates:
- Remote config for key economy values (ore prices, upgrade costs, ladder counts)
- Analytics tracking for economy metrics
- A/B testing capability for balance experiments
- Fallback to bundled defaults if remote unavailable

## Affected Files
- scripts/autoload/config_manager.gd - Remote config loading
- scripts/autoload/analytics_manager.gd - Economy event tracking
- scripts/data/economy_config.gd - Tunable values
- resources/economy_defaults.tres - Bundled fallback values

## Key Metrics to Track
- Time to first upgrade
- Session length distribution
- Depth reached per session
- Ladder purchase rate
- Stuck/death rate by depth
- Upgrade purchase funnel

## Implementation Notes
- Firebase Remote Config or similar service
- Cache remote values locally
- Update on app launch, not mid-session
- Document all tunable values and their ranges
- Include A/B test group assignment

## Verify
- [ ] Economy values load from remote config
- [ ] Fallback works when offline
- [ ] Values don't change mid-session
- [ ] Analytics events fire for key economy moments
- [ ] Can run A/B test on ore prices
