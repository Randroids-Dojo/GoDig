---
title: "implement: Monetization gate at Day 3"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"2026-02-01T08:11:02.658753-06:00\\\"\""
closed-at: "2026-02-03T02:08:30.112741-06:00"
close-reason: Implemented MonetizationManager with 3 unlock paths (first upgrade, 3+ runs, 15min playtime). Only rewarded videos, no interstitials. Player can decline with no penalty. State persists in save data.
---

Ensure no monetization prompts appear until player has completed several sessions (approximately Day 3 equivalent).

## Context
Research shows top idle games like Capybara Go wait until Day 3 when players chase rare drops. Front-loading monetization is a key mistake. 'Ads that bail players out, not slow them down' achieve 42% engagement vs 25-30% average.

## Description
Implement a monetization readiness gate:
- Track total playtime / session count
- NO ads or IAP prompts until:
  - Player has bought first upgrade (minimum)
  - Player has completed 3+ successful mining trips
  - OR total playtime exceeds 15 minutes
- First monetization: helpful rewarded video (3 free ladders when stuck)
- Never interrupt gameplay with ads

## Affected Files
- scripts/autoload/save_manager.gd - Track playtime/session count
- NEW: scripts/autoload/monetization_manager.gd - Gate logic
- scripts/ui/stuck_recovery_panel.gd - Optional ad offer
- scripts/ui/shop_panel.gd - Optional ad offer for bundles

## Implementation Notes
- Err on side of showing ads LATER rather than earlier
- Player must feel invested before seeing ANY monetization
- Rewarded videos only - no interstitials during MVP
- 'Watch ad for 3 ladders' when player is stuck (helpful, not intrusive)
- Track conversion rate for later tuning

## Verify
- [ ] New players see no ads in first session
- [ ] First ad offer appears after upgrade purchased
- [ ] Ad offer presented as help, not interruption
- [ ] Player can decline ad with no penalty
- [ ] Session count persists between launches
