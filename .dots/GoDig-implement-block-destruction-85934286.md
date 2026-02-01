---
title: "implement: Block destruction particle effects"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T07:45:03.664618-06:00"
---

## Description
Add particle debris effects when mining blocks to make each swing feel impactful.

## Context
Particles are 'a juicy game's best friend' - they give motion and feedback to otherwise flat actions. Each block type should emit appropriately colored debris.

## Affected Files
- `scripts/effects/block_particles.gd` - Enhance or create particle system
- `scripts/world/dirt_grid.gd` - Emit particles on block damage
- `scenes/effects/` - Particle scene files

## Implementation Notes
### Particle Types
| Block Type | Particle Color | Behavior |
|------------|---------------|----------|
| Dirt | Brown/tan | Small, quick settle |
| Stone | Gray | Chunky, bounce |
| Copper ore | Orange/bronze | Mix with sparkles |
| Iron ore | Dark gray/blue | Dense, heavy |
| Gems | Material color + white sparkles | Floating, magical |

### Per-Hit Particles
- 3-6 small debris pieces per swing
- Direction: away from player
- Gravity: yes, settle on ground
- Lifetime: 0.3-0.5s

### Break Burst
- 8-15 larger pieces on final break
- Radial explosion pattern
- Includes dust cloud
- Lifetime: 0.5-0.8s

### Technical Notes
1. Use GPUParticles2D for performance
2. Object pool to avoid instantiation lag
3. Color modulation based on block data
4. Don't spawn too many (performance)

## Verify
- [ ] Particles spawn on each pickaxe hit
- [ ] Color matches block material
- [ ] Burst effect on block destruction
- [ ] Performance stable with many particles
- [ ] Particles don't obscure gameplay
- [ ] Dust settles naturally
