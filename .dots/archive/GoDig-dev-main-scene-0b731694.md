---
title: "DEV: Main scene setup"
status: closed
priority: 1
issue-type: task
created-at: "\"2026-01-16T00:48:18.005789-06:00\""
closed-at: "2026-01-24T21:18:49.182999+00:00"
close-reason: test_level.tscn is the main game scene with player, dirt grid, HUD, and camera
---

## Description

Create the main game scene (Main.tscn) as the actual gameplay entry point, combining World, Player, and UI. Currently the game logic lives in test_level.tscn which should be refactored into a proper main scene.

## Context

The current `scenes/main.tscn` is a placeholder "Hello World" scene. The actual gameplay is in `scenes/test_level.tscn`. This task is to either:
1. Rename/refactor test_level.tscn to main.tscn, OR
2. Create a proper main.tscn that incorporates the test_level structure

## Current State

- `scenes/main.tscn` - Placeholder with title label (NOT gameplay)
- `scenes/test_level.tscn` - Actual gameplay scene with DirtGrid, Player, UI, etc.
- Main menu references `main.tscn` as the game scene

## Affected Files

- `scenes/main.tscn` - Replace placeholder with gameplay scene
- `scenes/test_level.tscn` - May be deprecated or kept for testing
- `scripts/main.gd` - Replace placeholder script with game controller
- `scenes/main_menu.tscn` - Ensure it transitions to correct scene

## Implementation Notes

The simplest approach is to copy test_level.tscn structure to main.tscn:

```
Main (Node2D)
├─ Background
├─ DirtGrid (terrain)
├─ Player (CharacterBody2D)
│  └─ Camera2D
├─ UI (CanvasLayer)
│  ├─ DepthLabel
│  ├─ CoinsLabel
│  ├─ TouchControls
│  ├─ ShopButton
│  ├─ PauseButton
│  ├─ Shop
│  └─ HUD
├─ PauseMenu
└─ FloatingTextLayer
```

## Verify

- [ ] Build succeeds
- [ ] Main menu "New Game" loads main.tscn
- [ ] Main menu "Continue" loads main.tscn with saved state
- [ ] Gameplay works identically to test_level
- [ ] All UI elements functional
- [ ] Pause menu works
- [ ] Shop button works
