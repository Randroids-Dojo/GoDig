---
title: "implement: Deep dive tension meter"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T01:20:50.240052-06:00"
---

## Description
Add a visual indicator showing accumulated risk during deep dives - combines depth, inventory fill, and distance from surface.

## Context
Dome Keeper research shows tension should 'hang in the background' during resource gathering. Deep Rock Galactic creates 'delightfully tense' extraction phases. Currently, players only see inventory warnings at 80%. A tension meter creates constant awareness of accumulated risk.

**NOTE: Related dots exist:**
- `GoDig-implement-return-to-9ecc2744` - Inventory fill warnings (60%/80%/100%)
- `GoDig-implement-risk-indicator-b563b726` - Risk indicator (depth + ladder count)

This dot CONSOLIDATES and EXTENDS those concepts into a unified tension meter that factors in:
- Inventory fill (from return-to-surface)
- Depth vs ladders (from risk-indicator)
- NEW: Time underground
- NEW: Distance from last placed ladder

## Implementation
1. Create TensionMeter UI component for HUD
2. Calculate tension score:
   - Base: (depth / max_reached_depth) * 0.3
   - Inventory: (slots_filled / total_slots) * 0.4
   - Time underground: (minutes * 0.05) capped at 0.2
   - Ladder deficit: (depth_in_blocks - ladders_owned) / 100 * 0.1
3. Visual representation:
   - Small pulsing heart/gem icon
   - Color gradient: green (0-30%) -> yellow (30-60%) -> orange (60-80%) -> red (80%+)
   - Pulse speed increases with tension
4. Optional: ambient music shifts with tension level

## Affected Files
- `scenes/ui/tension_meter.tscn` - New meter UI component
- `scripts/ui/tension_meter.gd` - Tension calculation and visuals
- `scripts/ui/hud.gd` - Add tension meter to HUD
- `scripts/autoload/game_manager.gd` - Track underground time

## Verify
- [ ] Tension meter visible on HUD during underground gameplay
- [ ] Meter increases with depth, inventory fill, time
- [ ] Color transitions smoothly through gradient
- [ ] Pulse speed increases at higher tension
- [ ] Meter resets to green when returning to surface
- [ ] Does not obscure other HUD elements
