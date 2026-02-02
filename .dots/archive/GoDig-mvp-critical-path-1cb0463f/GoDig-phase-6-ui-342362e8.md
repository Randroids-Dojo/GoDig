---
title: "research: UI & Polish"
status: closed
priority: 0
issue-type: task
created-at: "\"\\\"2026-01-16T00:41:40.530238-06:00\\\"\""
closed-at: "2026-01-19T10:11:10.074733-06:00"
close-reason: Analyzed UI state, expanded 4 sparse specs, documented remaining gaps
---

HUD (depth, coins, inventory), portrait layout, mobile controls (joystick + tap).

## Research Findings

### Current State

1. **Touch Controls** (Partially Implemented)
   - `scenes/ui/touch_controls.tscn` exists with Left/Right/Down/Jump buttons
   - Simple button approach (not joystick yet)
   - Platform detection for auto-show/hide works
   - Signals properly emit for player integration

2. **Shop UI** (Implemented)
   - Full sell/upgrades tabs
   - Coins display
   - Works correctly

3. **Missing HUD Elements**
   - No depth indicator
   - No coins display in main game (only in shop)
   - No inventory slot preview
   - No equipped tool indicator

### Implementation Specs Improved This Session

- GoDig-dev-virtual-joystick-345757be: Expanded from 1 line to full spec
- GoDig-dev-jump-button-148cb017: Expanded from 1 line to full spec
- GoDig-dev-inventory-slots-96564574: Expanded from 1 line to full spec
- GoDig-dev-keyboard-input-c44a8907: Expanded from 1 line to full spec

### Remaining UI Gaps

1. **Main Game HUD** - Not yet created, need:
   - Depth indicator (e.g., "45m")
   - Coins display (e.g., "$1,234")
   - Inventory slots preview (e.g., "6/8")
   - Equipped tool indicator

2. **Virtual Joystick** - Spec ready, not implemented

3. **Portrait Layout** - 720x1280 configured in project, but UI needs anchoring work

### Related Implementation Tasks

- GoDig-dev-virtual-joystick-345757be: Full joystick spec ready
- GoDig-dev-jump-button-148cb017: Button spec ready (exists as basic version)
- GoDig-dev-inventory-slots-96564574: HUD preview spec ready
- GoDig-dev-portrait-ui-52fab974: Portrait layout system
- GoDig-dev-portrait-layout-82f45927: Layout constraints
