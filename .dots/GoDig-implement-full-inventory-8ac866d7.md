---
title: "implement: Full inventory decision moment"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T09:31:47.352665-06:00"
---

## Description
When player inventory becomes full while mining, create a meaningful decision moment rather than just blocking collection. This is a natural push-your-luck tension point.

## Context
From Session 21 research on inventory management as tension design:
- Limits create meaningful choices: what to keep, what to drop?
- 'Is it worth the risk to grab that rare loot or head back to camp and unload?'
- Inventory adds strategy and depth - makes you think, plan, organize

## Implementation
When inventory full:
1. Display clear 'Inventory Full' notification
2. Allow player to continue mining (blocks break, but ore is lost)
3. Show 'ore lost' visual feedback when mining with full inventory
4. Add HUD indicator showing inventory status (e.g., '8/8 slots')
5. Optional: Allow swapping (drop common ore for rare ore)

## Decision Psychology
- Player sees rare ore ahead but inventory is full
- Choice: return now safely OR drop common ore to pick up rare
- Each lost ore should have visible feedback (falling away animation)

## Affected Files
- scripts/autoload/inventory.gd - full check and swap logic
- scripts/ui/hud.gd - inventory count display
- scripts/player/player.gd - mining when full behavior
- scenes/ui/inventory_full_popup.tscn - new notification

## Verify
- [ ] Clear notification when inventory becomes full
- [ ] Mining continues but ore is visibly lost
- [ ] Player can make informed decision to return or continue
- [ ] Swapping ore works intuitively
