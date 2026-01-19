---
title: "research: MVP Critical Path"
status: open
priority: 0
issue-type: task
created-at: "2026-01-16T00:41:20.970354-06:00"
---

Implementation order for MVP: 1) Decisions 2) Core systems 3) Player 4) World gen 5) Economy 6) UI 7) Save 8) Controls

## Phase Status (as of 2026-01-19)

| Phase | Name | Status | Research Dot |
|-------|------|--------|--------------|
| 1 | Blocking Decisions | DONE | GoDig-phase-1-blocking-53e0d35f (closed) |
| 2 | Project Foundation | DONE | GoDig-phase-2-project-c88147f0 (closed) |
| 3 | World Generation | DONE | GoDig-phase-3-world-ed6f6bbe (closed) |
| 4 | Player Core | DONE | GoDig-phase-4-player-7b559433 (closed) |
| 5 | Economy Loop | DONE | GoDig-phase-5-economy-70c318e3 (closed) |
| 6 | UI & Polish | DONE | GoDig-phase-6-ui-342362e8 (closed) |
| 7 | Persistence | DONE | GoDig-phase-7-persistence-07268300 (closed) |

## Current Bottleneck

All individual systems are implemented. The bottleneck is **integration**:

### High Priority Implementation Tasks

1. **Core Game Loop Integration** (GoDig-dev-core-game-73ab4a77)
   - Wire player movement to touch controls
   - Connect digging to ore drops to inventory
   - Link inventory to shop selling
   - Hook up tool upgrades to dig speed

2. **Surface Area Scene** (GoDig-dev-surface-area-379633b2)
   - Create surface terrain
   - Place shop building
   - Add mine entrance
   - Set player spawn point

3. **Main Menu Flow** (GoDig-dev-main-menu-d159693f)
   - New game -> creates save -> loads Main scene
   - Continue -> loads save -> loads Main scene
   - Options -> settings menu

## Ready to Implement

The following specs are fully detailed and ready for implementation:
- GoDig-dev-virtual-joystick-345757be (full spec)
- GoDig-dev-jump-button-148cb017 (full spec)
- GoDig-dev-inventory-slots-96564574 (full spec)
- GoDig-dev-keyboard-input-c44a8907 (full spec)
- GoDig-implement-shop-building-25de6397 (full spec)
