---
title: "implement: Block destruction particle effects"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T08:40:04.352456-06:00"
---

## Description

Add satisfying particle effects when blocks are destroyed during mining. Make each dig feel like 'making a mark on the world' (Noita insight).

## Context

Research (Session 14) found:
- Noita's 'every pixel physically simulated' is 95% positive (45,499 reviews)
- Environmental destructibility is 'key to appeal and greatest asset'
- Chain reactions and debris create emergent satisfaction
- 'Amazed by pretty pixels and physics' is initial hook for many players

Mining must feel impactful BEFORE any systems/upgrades matter (Session 11 insight).

## Implementation

### Particle Types by Block
1. **Dirt/Grass**: Brown dust puff, small dirt chunks falling
2. **Stone**: Grey dust, rock chips flying outward
3. **Ore blocks**: Same as host material + sparkle particles matching ore color
4. **Hard rock**: Heavier particles, longer duration, screen shake (subtle)

### Particle Behavior
- Spawn at block center on destruction
- 5-10 particles per block
- Physics-affected: fall with gravity, collide with nearby blocks
- Fade out over 0.5-1 second
- Color matches block type

### Performance Considerations
- Pool particles (reuse instead of create/destroy)
- Limit max active particles (50-100)
- Disable on low-end device detection
- Optional setting in options menu

### Audio Sync
- Particle spawn should sync exactly with destruction sound
- Different materials = different sounds (dirt thud vs stone crack)

## Affected Files
- `scripts/world/dirt_grid.gd` - Emit particle signal on block destroy
- `scenes/effects/block_particles.tscn` - Particle scene
- `scripts/effects/block_particle_manager.gd` - Pool and spawn particles
- `resources/particles/` - Particle textures per material type

## Verify
- [ ] Particles spawn when any block is mined
- [ ] Different particle colors/types for different block materials
- [ ] Particles affected by gravity, fall realistically
- [ ] No performance degradation when mining rapidly
- [ ] Particles sync with destruction audio
- [ ] Particles work correctly on web build
