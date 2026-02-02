---
title: "implement: Full inventory decision moment"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"2026-02-01T09:36:53.711749-06:00\\\"\""
closed-at: "2026-02-02T03:00:50.900799-06:00"
close-reason: Implemented inventory full decision popup with quick-drop UI, return hints, and HUD FULL badge
---

## Description

When inventory is full, create a meaningful decision moment rather than just blocking collection.

## Context

Research shows inventory limits are valued because they force decisions. 'Is it worth the risk to grab that rare loot or head back to camp and unload?' This IS the push-your-luck moment in our game.

## Implementation

### Full Inventory State
- Visual indicator: inventory slots pulse/glow when full
- Audio cue: subtle 'inventory full' sound when trying to collect
- HUD shows 'FULL' badge

### Decision Moment
When player tries to mine an ore with full inventory:
1. Show small popup: 'Inventory Full'
2. Show ore that would be collected
3. Options:
   - [Drop Item] - Opens quick-drop UI
   - [Return to Surface] - Highlights current depth + ladder count
   - [Keep Mining] - Dismiss (ore stays in block)

### Quick-Drop UI
- Show all inventory items sorted by value
- Tap item to drop it (returns to world as collectible)
- Auto-suggest dropping lowest value item

### Tension Enhancement
- If depth > 50m and ladders < 3, add warning color to 'Return to Surface'
- Show estimated travel time back

## Affected Files
- scripts/ui/inventory_full_popup.gd (new)
- scenes/ui/inventory_full_popup.tscn (new)
- scripts/player/player.gd - Inventory full detection
- scripts/ui/hud.gd - Full indicator

## Verify
- [ ] Popup appears when mining ore with full inventory
- [ ] Drop item works and item appears as collectible
- [ ] Decision feels meaningful, not annoying
- [ ] Quick-drop UI is usable on mobile (touch-friendly)
