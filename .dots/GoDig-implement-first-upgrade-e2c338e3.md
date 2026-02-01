---
title: "implement: First upgrade guidance flow"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T01:09:03.267020-06:00"
---

Ensure players experience their first upgrade within 2-5 minutes - critical retention moment.

## Research Findings (Session 4)
- "88% of users return after experiencing a satisfying cycle" (first loop = retention)
- "Top performers only lose 17% by minute 5" vs "worst lose 46%"
- First upgrade MUST feel impactful and earned
- Tutorial integrated into gameplay, not interruptive
- Rogue Legacy pattern: "entering with a more capable character" is the reward

## Why This is P0
The first upgrade is the moment players understand the game's promise: mine -> sell -> get stronger -> mine better. If this takes too long (>5min), they churn before experiencing the power fantasy.

## Implementation
1. **Economy tuning** (see related dots for ore values/pickaxe cost)
2. **Tutorial prompts** (non-blocking toasts):
   - At 50% inventory: "Inventory filling up! Return to surface to sell."
   - When coin balance >= Copper Pickaxe cost: "You can afford an upgrade! Visit the Blacksmith."
3. **First upgrade detection**:
   - Track flag: `first_upgrade_purchased`
   - On first tool upgrade, trigger enhanced celebration
4. **Before/after comparison**:
   - Show old damage vs new damage
   - Animate the difference (+50% POWER!)
5. **Immediate feedback**:
   - Player's next dig should feel noticeably faster
   - Consider brief "empowered" particle aura (3 seconds)

## Dependencies
This dot assumes:
- `GoDig-move-supply-store-61eb95a1` (Supply Store at 0m) - DONE FIRST
- `GoDig-give-player-2-8f4b2912` (5 starting ladders) - DONE FIRST
- Either `GoDig-implement-increase-early-948e470d` OR `GoDig-implement-reduce-copper-cdb35c77` (economy tuning)

## Files
- scripts/autoload/game_manager.gd (tutorial state tracking)
- scripts/autoload/save_manager.gd (first_upgrade_purchased flag)
- scripts/ui/tutorial_overlay.gd (guidance prompts)
- scripts/ui/shop.gd (first upgrade detection + celebration)
- scripts/effects/upgrade_celebration.gd (enhanced first-time effect)

## Verify
- [ ] New player reaches first upgrade in under 5 minutes (time this!)
- [ ] Tutorial prompts appear at correct moments
- [ ] Prompts are non-blocking toasts, not popups
- [ ] First upgrade triggers enhanced celebration
- [ ] Before/after comparison is clear and exciting
- [ ] Player FEELS the difference on next dig
- [ ] Flag persists (subsequent upgrades use normal celebration)
