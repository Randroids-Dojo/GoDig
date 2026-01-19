---
title: "implement: Gem sparkle visual effect"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T00:49:21.548980-06:00"
---

Subtle shine/sparkle on gem/ore tiles to hint at valuable resources before mining. Adds discovery excitement.

## Description

Ore and gem blocks should occasionally sparkle to visually indicate their presence to the player. This creates anticipation and helps players identify valuable resources before mining.

## Context

- Currently all blocks look the same until mined
- Ores have unique colors defined in `resources/ores/` .tres files
- Sparkles should be subtle (not overwhelming) but noticeable
- Higher rarity = more noticeable sparkle
- See Docs/research/game-feel-juice.md for environmental effects

## Affected Files

- `scenes/effects/sparkle.tscn` - NEW: Simple sparkle particle effect
- `scripts/effects/sparkle.gd` - NEW: Sparkle controller
- `scripts/world/dirt_grid.gd` - Add sparkle nodes to ore blocks
- `scripts/world/dirt_block.gd` - Track if block contains ore

## Implementation Notes

### Sparkle Effect Scene

```
Sparkle (GPUParticles2D)
├─ ParticleProcessMaterial
└─ Script: sparkle.gd
```

### Sparkle Script

```gdscript
# sparkle.gd
extends GPUParticles2D

var _sparkle_timer: float = 0.0
var _sparkle_interval: float = 2.0  # Seconds between sparkles
var ore_color: Color = Color.WHITE

func _ready() -> void:
    emitting = false
    one_shot = true
    amount = 3
    lifetime = 0.5
    explosiveness = 1.0

func _process(delta: float) -> void:
    _sparkle_timer += delta
    if _sparkle_timer >= _sparkle_interval:
        _sparkle_timer = 0.0
        _sparkle_interval = randf_range(1.5, 4.0)  # Random next interval
        _do_sparkle()

func _do_sparkle() -> void:
    var mat := process_material as ParticleProcessMaterial
    mat.color = ore_color.lightened(0.3)  # Brighter than ore color
    emitting = true

func set_rarity(rarity: int) -> void:
    ## Rarity 0-4, higher = more frequent sparkles
    match rarity:
        0: _sparkle_interval = randf_range(3.0, 5.0)  # Common - rare sparkle
        1: _sparkle_interval = randf_range(2.0, 4.0)
        2: _sparkle_interval = randf_range(1.5, 3.0)
        3: _sparkle_interval = randf_range(1.0, 2.0)
        _: _sparkle_interval = randf_range(0.5, 1.5)  # Legendary - frequent
```

### ParticleProcessMaterial Settings

```
direction = Vector3(0, -1, 0)  # Float upward
spread = 30.0
initial_velocity_min = 20.0
initial_velocity_max = 40.0
gravity = Vector3(0, 0, 0)  # No gravity - float away
scale_min = 0.3
scale_max = 0.6
color = White (set dynamically)
```

### DirtBlock Integration

```gdscript
# dirt_block.gd additions
var has_ore: bool = false
var ore_data: OreData = null
var _sparkle: GPUParticles2D = null

func activate(pos: Vector2i) -> void:
    # ...existing code...

    # Check if this block contains ore
    ore_data = _check_for_ore(pos)
    has_ore = ore_data != null

    if has_ore and _sparkle == null:
        _add_sparkle()

func _add_sparkle() -> void:
    var sparkle_scene := preload("res://scenes/effects/sparkle.tscn")
    _sparkle = sparkle_scene.instantiate()
    _sparkle.position = Vector2(BLOCK_SIZE / 2, BLOCK_SIZE / 2)  # Center
    _sparkle.ore_color = ore_data.color
    _sparkle.set_rarity(ore_data.rarity)
    add_child(_sparkle)

func deactivate() -> void:
    # ...existing code...
    if _sparkle:
        _sparkle.queue_free()
        _sparkle = null
```

### Performance Optimization

- Only spawn sparkle on visible ore blocks
- Pool sparkle instances if too many ores on screen
- Reduce sparkle for distant ores (if zoomed out)

### Sparkle Frequency by Rarity

| Rarity | Sparkle Interval | Color Brightness |
|--------|------------------|------------------|
| Common (0) | 3-5 seconds | +10% |
| Uncommon (1) | 2-4 seconds | +20% |
| Rare (2) | 1.5-3 seconds | +30% |
| Epic (3) | 1-2 seconds | +40% |
| Legendary (4+) | 0.5-1.5 seconds | +50% |

## Verify

- [ ] Ore blocks sparkle periodically
- [ ] Sparkle color matches ore color (but brighter)
- [ ] Rare ores sparkle more frequently
- [ ] Common ores have subtle, infrequent sparkles
- [ ] Sparkles float upward and fade out
- [ ] No performance impact with many ore blocks visible
- [ ] Sparkle stops when block is destroyed
- [ ] Normal dirt/stone blocks do NOT sparkle
