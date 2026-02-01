---
title: "implement: Affordable upgrade indicator"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T01:27:22.181750-06:00"
---

## Description
Add subtle visual indicator on shop/blacksmith when player can afford a new upgrade.

## Context
Research: Signal 'ready to upgrade' without nagging. Players should notice upgrade opportunity but not feel pestered. Subtle green glow or badge is ideal.

## Implementation
1. Track player coins vs cheapest available upgrade
2. When affordable: add green dot/glow to shop building sprite
3. Inside shop: highlight affordable items with subtle glow
4. On HUD: small 'upgrade available' icon near coin counter (optional)
5. Avoid: modal popups, audio alerts, blocking UI

## Affected Files
- `scripts/surface/shop_building.gd` - Add affordable indicator
- `scripts/ui/shop.gd` - Highlight affordable items
- `scripts/autoload/player_data.gd` - Emit coins_changed signal

## Verify
- [ ] Shop building shows indicator when upgrade affordable
- [ ] Indicator disappears after purchase
- [ ] No false positives (already owned max tier)
- [ ] Indicator is subtle, not annoying
- [ ] Works for all shop types (General, Blacksmith, etc.)
