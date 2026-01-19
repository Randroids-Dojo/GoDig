---
title: "implement: Block break particle effect"
status: open
priority: 1
issue-type: task
created-at: "2026-01-16T01:01:24.194011-06:00"
---

Particle burst when block is destroyed. Color matches block type (brown for dirt, gray for stone). Core MVP feedback.

## Description

When a block is mined/destroyed, emit a burst of colored particles that match the block's material. This provides essential visual feedback that makes mining feel satisfying.

## Context

- Currently blocks just disappear when broken - no visual feedback
- Particles are one of the most impactful "juice" elements
- Must be performant on mobile (use GPUParticles2D with pooling)
- See Docs/research/game-feel-juice.md for particle configurations

## Affected Files

- `scenes/effects/block_particles.tscn` - NEW: GPUParticles2D scene
- `scripts/effects/block_particles.gd` - NEW: Particle controller
- `scripts/world/dirt_grid.gd` - Trigger particles on block destroy
- `scripts/test_level.gd` - Pool particle instances

## Implementation Notes

### Particle Scene Setup

Create a GPUParticles2D scene:

```
BlockParticles (GPUParticles2D)
├─ ParticleProcessMaterial (process_material)
└─ Script: block_particles.gd
```

### Particle Configuration

```gdscript
# block_particles.gd
extends GPUParticles2D

const LIFETIME := 0.4
const AMOUNT := 10

func _ready() -> void:
    emitting = false
    one_shot = true
    explosiveness = 1.0
    amount = AMOUNT
    lifetime = LIFETIME

func burst(world_pos: Vector2, block_color: Color) -> void:
    global_position = world_pos
    # Modify material color
    var mat := process_material as ParticleProcessMaterial
    mat.color = block_color
    emitting = true
    # Return to pool after lifetime
    await get_tree().create_timer(LIFETIME + 0.1).timeout
    _return_to_pool()

func _return_to_pool() -> void:
    var pool := get_parent()
    if pool.has_method("return_particle"):
        pool.return_particle(self)
```

### ParticleProcessMaterial Settings

```
direction = Vector3(0, -1, 0)  # Spray upward
spread = 45.0
initial_velocity_min = 100.0
initial_velocity_max = 200.0
gravity = Vector3(0, 400, 0)  # Fall back down
scale_min = 0.5
scale_max = 1.5
```

### Particle Pool

```gdscript
# test_level.gd or effects_manager.gd
const PARTICLE_POOL_SIZE := 10
var _particle_pool: Array[GPUParticles2D] = []
var _particle_scene := preload("res://scenes/effects/block_particles.tscn")

func _init_particle_pool() -> void:
    for i in PARTICLE_POOL_SIZE:
        var p := _particle_scene.instantiate()
        p.visible = false
        add_child(p)
        _particle_pool.append(p)

func get_particle() -> GPUParticles2D:
    for p in _particle_pool:
        if not p.emitting:
            return p
    # All in use - return oldest
    return _particle_pool[0]

func spawn_block_particles(world_pos: Vector2, color: Color) -> void:
    var p := get_particle()
    p.visible = true
    p.burst(world_pos, color)
```

### Integration with DirtGrid

```gdscript
# dirt_grid.gd
signal block_destroyed(grid_pos: Vector2i, color: Color)

func hit_block(grid_pos: Vector2i) -> bool:
    # ...existing hit logic...
    if destroyed:
        var color := block.base_color
        var world_pos := _grid_to_world(grid_pos) + Vector2(64, 64)  # Center
        block_destroyed.emit(grid_pos, color)
        return true
    return false
```

### Material-Specific Particle Counts

| Material | Particle Count | Spread |
|----------|----------------|--------|
| Dirt | 8 | 45deg |
| Clay | 10 | 50deg |
| Stone | 6 | 60deg |
| Granite | 5 | 70deg |
| Ore | 12 | 360deg (radial burst) |

## Verify

- [ ] Breaking dirt creates brown particle burst
- [ ] Breaking stone creates gray particle burst
- [ ] Particles spray upward then fall with gravity
- [ ] Particles fade out over ~0.4 seconds
- [ ] Mining rapidly (5+ blocks/sec) doesn't drop FPS
- [ ] Particle color matches the exact block color
- [ ] Particles spawn at block center, not corner
- [ ] No memory leak (particles return to pool)
