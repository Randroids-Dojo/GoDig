---
title: "implement: Surface warm colors and cozy visual distinction"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"2026-02-01T09:32:06.169152-06:00\\\"\""
closed-at: "2026-02-03T02:24:46.428418-06:00"
close-reason: "Updated surface colors: warm amber sky, golden-tinted clouds, warm mountain silhouettes, warmer ground green. Shop building already had warm wood tones. Topsoil layer already warm."
---

## Description
Make the surface area visually distinct from underground with warm, cozy colors that signal safety and relief. This creates the tension-relief cycle critical for push-your-luck games.

## Context
From Session 21 research on tension and relief design patterns:
- Blue signals safety, green promotes relaxation - ideal for recovery zones
- Surface must be CLEARLY safe (warm colors, enclosed shop interiors, no threats visible)
- Underground = increasing unfamiliarity and tension
- Overcoming tension creates strong dopamine release - surface return should trigger this

From Session 14 cozy game design research:
- Coziness = safety + abundance + softness
- Distinct thresholds between dangerous/safe spaces heighten relief
- Protection signals: warm tones, enclosed spaces

## Implementation
1. Surface color palette: warm orange/amber sky, golden sunlight
2. Shop interiors: enclosed, warm lighting, wooden textures
3. Underground color gradient: neutral at top, cooler/darker as depth increases
4. Add ambient particles at surface (floating dust motes in sunlight)
5. Transition moment when reaching surface should feel like 'relief'

## Affected Files
- scenes/main.tscn - surface area coloring
- scenes/buildings/*.tscn - shop interior warmth
- scripts/world/world_generator.gd - depth-based color tinting
- assets/shaders/depth_tint.gdshader - gradient shader

## Verify
- [ ] Surface feels noticeably warmer than underground
- [ ] Reaching surface creates relief feeling
- [ ] Depth has gradual visual tension increase
- [ ] Shop interiors feel cozy and safe
