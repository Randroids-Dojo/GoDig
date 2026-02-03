---
title: "implement: Depth palette system - fixed palette per layer with warm→desaturated progression"
status: active
priority: 2
issue-type: task
created-at: "\"2026-02-02T18:50:56.819004-06:00\""
---

## Purpose
Implement a consistent visual identity system where each depth layer has a fixed color palette that progresses from warm/safe at surface to cold/alien at deep layers.

## Design Principles
From visual depth progression research:
- 'Warm and cool zones create contrast, depth, storytelling nuance'
- Style guide ensures consistency: palette, line style, detail level
- Light/color shifts should match gameplay narrative beats

## Implementation
- Define exactly 6-8 colors per layer (primary, secondary, accent, background)
- Surface: Warm browns, greens, golden accents
- Layer 2-3: Neutral earth tones, reduced saturation
- Layer 4-5: Cool grays, blue undertones
- Layer 6-7: Desaturated dark, alien purples/deep blues
- Each layer distinctly identifiable at a glance

## Consistency Rules
- Never mix palettes between layers
- Transition zones can blend adjacent palettes
- Ores use layer-appropriate base with bright accent for visibility

## Verify
- [ ] Each layer has documented fixed palette
- [ ] Surface feels warm and safe
- [ ] Deep layers feel cold and unfamiliar
- [ ] Player can identify current layer by color alone

## Sources
Visual depth progression design - Session 31
