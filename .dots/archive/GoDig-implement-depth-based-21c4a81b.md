---
title: "implement: Depth-based visual unfamiliarity gradient"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"2026-02-01T09:52:04.997050-06:00\\\"\""
closed-at: "2026-02-03T02:34:51.827612-06:00"
close-reason: Implemented layer-based unfamiliarity gradient in LightingManager. Added fog overlay system, layer-specific ambient calculations, and smooth transitions between layers. Surface feels warm/home, depths feel increasingly alien.
---

## Description
Create increasing visual unfamiliarity as player descends, building tension without explicit threats.

## Context
Subnautica research shows: 'Every aspect intentionally designed to make players feel they do not belong.' Four fear metrics (brightness, depth, hostility, visibility) all worsen with depth.

## Implementation
1. Surface: Warm colors (amber/brown), high brightness, familiar elements
2. Layer 1-2: Gradually cooler tones, slight darkening
3. Layer 3-4: Blue-grey tones, reduced visibility range
4. Layer 5-6: Dark purples, glowing elements create eerie atmosphere
5. Layer 7 (Obsidian): Near-black with occasional glow, maximum unfamiliarity

## Affected Files
- resources/layers/*.tres (color palettes per layer)
- scripts/world/layer_manager.gd (ambient lighting)
- shaders/depth_fog.gdshader (visibility reduction)

## Verify
- [ ] Each layer has distinct color temperature
- [ ] Brightness decreases noticeably per layer
- [ ] Deepest layers feel 'alien' compared to surface
- [ ] Surface return feels like coming HOME
