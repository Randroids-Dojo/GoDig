---
title: "implement: Player sprite sheet"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T00:39:51.701697-06:00"
---

## Description

Create player sprite sheet with idle, walk, dig, and climb animations.

## Context

The player character is the central visual element of the game. Art style depends on fantasy vs realistic decision. For MVP, simple placeholder sprites are acceptable - full production art can come later.

## Affected Files

- `assets/sprites/player/player_sprite.png` - NEW: Sprite sheet image
- `scenes/player/player.tscn` - Update AnimatedSprite2D with new sprite sheet
- `scripts/player/player.gd` - Animations already defined, just need sprites

## Implementation Notes

### Sprite Specifications

- Size: 128x128 pixels per frame (matches BLOCK_SIZE)
- Format: PNG with transparency
- Animations needed:
  - idle: 1-2 frames (subtle breathing/bobbing)
  - walk: 4-6 frames
  - swing: 3-4 frames (mining animation)
  - fall: 1-2 frames
  - climb: 4 frames (for ladder movement)

### Placeholder Approach (MVP)

For MVP, simple colored rectangles with basic shapes work:
- Head circle
- Body rectangle
- Simple limb positions

### AnimatedSprite2D Setup

```gdscript
# Existing animations in player.tscn:
# - "idle"
# - "swing"
# - Future: "walk", "fall", "climb"
```

## Verify

- [ ] Sprite sheet loads without errors
- [ ] Animations play at correct speed
- [ ] Sprite faces correct direction when moving
- [ ] Mining (swing) animation looks intentional
- [ ] No visual glitches at animation transitions
