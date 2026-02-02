---
title: "implement: Surface cozy zone visual distinction"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-02-01T08:40:16.786004-06:00\""
closed-at: "2026-02-02T09:52:01.475200-06:00"
close-reason: Duplicate of GoDig-implement-surface-home-81016105
---

## Description

Make the surface area feel distinctly safe and cozy compared to underground. Create a clear visual threshold that signals 'you are safe here'.

## Context

Research (Session 14) found:
- Coziness = safety + abundance + softness (lower stress, needs met, gentle stimuli)
- Distinct thresholds between dangerous/safe spaces heighten relief
- Protection signals: warm tones, enclosed spaces, familiar settings
- Mundanity matters: tea rooms/pantries cozier than exotic locations
- Undertale cited: warm tones + focused interior = safe haven

The surface should feel like 'coming home' after the tension of underground exploration.

## Implementation

### Visual Elements
1. **Lighting**: Warm yellow/orange ambient light at surface, cooler blues underground
2. **Background**: Blue sky with clouds visible at surface (parallax)
3. **Gradient transition**: Light fades from warm to cool as player descends
4. **Shop buildings**: Warm interior glow from windows

### Audio Elements
- Surface: Birds chirping, gentle wind, shop door chimes
- Underground: Silence/dripping, increasingly ominous with depth

### Threshold Marker
- Visual line/glow at y=0 marking the surface boundary
- Brief warm flash when crossing from underground to surface

### Shop Interiors (when entered)
- Warm color palette (browns, oranges, yellows)
- Enclosed feeling (visible walls/ceiling)
- Friendly NPC presence (relaxed pose)
- Familiar items (shelves, counters)

## Affected Files
- `scenes/test_level.tscn` - Add sky background, adjust lighting
- `scripts/environment/depth_lighting.gd` - Light color by depth
- `scripts/audio/ambient_audio_manager.gd` - Ambient sound by location
- `scenes/shops/*.tscn` - Warm interior styling

## Verify
- [ ] Surface clearly feels warmer/safer than underground
- [ ] Lighting transitions smoothly with depth
- [ ] Sky visible at surface, not underground
- [ ] Shop interiors feel enclosed and cozy
- [ ] Crossing to surface triggers brief warm visual feedback
- [ ] Audio transitions match visual transition
