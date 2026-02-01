---
title: "implement: Progressive tutorial - one mechanic at a time"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T08:03:30.105945-06:00"
---

Implement mobile onboarding best practice: teach one mechanic at a time, let players practice before introducing next.

## Description

Replace any blocky tutorial with progressive, gameplay-integrated teaching. Players should learn by doing, not by reading.

## Context

From Session 9 research:
- Progressive onboarding: teach ONE mechanic at a time
- 'One-minute rule': win player's heart in first 60 seconds
- Tutorial levels should BE fun gameplay (Candy Crush pattern)
- Start immediately at launch - no splash screens before first action

## Implementation

### Tutorial Flow (First 2 Minutes)

**Frame 1 (0-5s)**: Player spawns on surface
- Shop buildings visible
- Dirt blocks below player
- Single tap prompt: 'Tap a block to dig'

**After first dig (5-15s)**:
- No prompt - let them dig naturally
- Ore appears within 3 blocks (guaranteed)

**After first ore pickup (15-30s)**:
- Brief toast: 'Your first ore!'
- No instruction yet - let them continue

**After 3 ores collected (30-45s)**:
- Inventory indicator pulses
- Brief toast: 'Inventory filling. Return to surface when ready.'

**After returning to surface (45-90s)**:
- Arrow points to General Store
- Toast: 'Sell your ore here'

**After first sell (90-120s)**:
- Coin animation plays
- Toast: 'You can buy ladders and upgrades with coins!'
- Tutorial essentially complete

### Key Principles
- NEVER block gameplay with popups
- NEVER explain more than one thing at a time
- NEVER show tutorial text before the relevant action is possible
- Let players discover, then confirm their discovery

## Affected Files

- scenes/ui/tutorial.tscn - Tutorial overlay scene
- scripts/ui/tutorial_manager.gd - Tutorial state machine
- scripts/autoload/save_manager.gd - Tutorial progress flags
- scripts/world/ore_spawner.gd - Guarantee ore in first 3 blocks

## Verify

- [ ] First dig happens within 10 seconds of game start
- [ ] First ore pickup within 30 seconds
- [ ] Player naturally returns to surface within 90 seconds
- [ ] First sell transaction within 2 minutes
- [ ] No popups block gameplay
- [ ] Each prompt is under 10 words
- [ ] Player can skip/dismiss any hint
- [ ] Tutorial state persists (don't repeat on reload)
