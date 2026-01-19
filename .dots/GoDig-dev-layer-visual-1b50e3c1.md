---
title: "implement: Layer visual differentiation"
status: open
priority: 1
issue-type: task
created-at: "2026-01-16T00:44:10.921222-06:00"
---

## Description

Create distinct visual identities for each underground layer. Each layer should have unique colors, and the background should darken with depth. Implement transition zone blending for smooth layer changes.

## Context

Players need visual feedback about their progress underground. Distinct layer visuals:
- Help players gauge depth without checking the meter
- Create visual variety during long mining sessions
- Signal increasing difficulty and value
- Make returning to previously explored areas recognizable

Layer color scheme (from research):
- Topsoil: Brown/tan (earthy, easy)
- Subsoil: Dark brown/clay (transitional)
- Stone: Gray (standard rock)
- Deep Stone: Dark gray/granite (harder)
- Future: Crystal (blue glow), Magma (red/orange), Void (purple/black)

## Affected Files

- `scripts/world/dirt_block.gd` - Apply layer colors to blocks
- `resources/layers/*.tres` - Define color_primary and color_accent values
- `scripts/camera/game_camera.gd` - Add background tint by depth
- `scenes/main.tscn` or `scenes/game.tscn` - Add background ColorRect/CanvasModulate

## Implementation Notes

### Layer Color Definitions

Update each layer's `.tres` file with appropriate colors:

```
topsoil.tres:
  color_primary: Color(0.55, 0.35, 0.2)   # Brown
  color_accent: Color(0.65, 0.45, 0.25)    # Light brown

subsoil.tres:
  color_primary: Color(0.4, 0.28, 0.18)   # Dark brown
  color_accent: Color(0.5, 0.35, 0.22)     # Clay

stone.tres:
  color_primary: Color(0.5, 0.5, 0.5)     # Gray
  color_accent: Color(0.6, 0.55, 0.5)      # Light gray

deep_stone.tres:
  color_primary: Color(0.35, 0.35, 0.38)  # Dark gray
  color_accent: Color(0.4, 0.4, 0.45)      # Granite
```

### Block Color Application

In `dirt_block.gd`, apply layer color during activation:

```gdscript
func activate(grid_pos: Vector2i) -> void:
    _grid_position = grid_pos
    visible = true

    # Get layer-based color from DataRegistry
    color = DataRegistry.get_block_color(grid_pos)

    # Set block hardness based on layer
    _max_health = DataRegistry.get_block_hardness(grid_pos)
    _health = _max_health

    # Position and size
    position = Vector2(
        grid_pos.x * GameManager.BLOCK_SIZE + GameManager.GRID_OFFSET_X,
        grid_pos.y * GameManager.BLOCK_SIZE
    )
    size = Vector2(GameManager.BLOCK_SIZE, GameManager.BLOCK_SIZE)
```

### Background Depth Tint

Add a background layer that darkens with depth:

```gdscript
# In game_camera.gd or a dedicated background script
@onready var background_tint: CanvasModulate = $BackgroundTint

const SURFACE_COLOR := Color(0.4, 0.6, 0.8)  # Sky blue
const DEEP_COLOR := Color(0.1, 0.08, 0.12)   # Near black

func update_background_for_depth(depth: int) -> void:
    # Gradually darken from surface to deep
    var max_darkness_depth := 1000
    var t := clampf(float(depth) / max_darkness_depth, 0.0, 1.0)
    background_tint.color = SURFACE_COLOR.lerp(DEEP_COLOR, t)
```

### Depth-Based Lighting Effect

Optional: Add a vignette or lighting radius effect:

```gdscript
# Simulated torch/helmet light
@onready var light_mask: CanvasModulate = $LightMask

func update_light_radius(depth: int) -> void:
    # Light radius decreases with depth (requires helmet upgrades)
    var base_radius := 300.0
    var depth_penalty := depth / 10.0
    var helmet_bonus := PlayerData.get_helmet_bonus()

    var effective_radius := base_radius - depth_penalty + helmet_bonus
    effective_radius = maxf(effective_radius, 100.0)  # Minimum visibility

    # Apply to shader or CanvasModulate
    light_mask.material.set_shader_parameter("radius", effective_radius)
```

### Layer Entry Notification

Show brief notification when entering new layer:

```gdscript
# In GameManager or HUD
signal layer_changed(layer_name: String)

var _last_layer_id: String = ""

func _on_depth_updated(depth: int) -> void:
    var layer := DataRegistry.get_layer_at_depth(depth)
    if layer and layer.id != _last_layer_id:
        _last_layer_id = layer.id
        layer_changed.emit(layer.display_name)
        # HUD shows "Entering Stone Layer" briefly
```

## Visual Reference

```
Surface (0m)
████████████████  Sky blue background
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  Grass (future)

Topsoil (0-50m)
████████████████  Light brown blocks
████████████████  Tan accents scattered
  Background: Light blue-gray

Subsoil (50-200m)
████████████████  Dark brown blocks
████████████████  Clay accent patches
  Background: Dim gray-blue

Stone (200-500m)
████████████████  Gray blocks
████████████████  Light gray accents
  Background: Dark gray

Deep Stone (500m+)
████████████████  Dark gray blocks
████████████████  Granite accents
  Background: Near black
```

## Edge Cases

- Surface (depth 0): Use topsoil colors, sky-like background
- Negative depth (above surface): Clamp to 0
- Very deep (>1000m): Cap background darkness, don't go pure black
- Transition zones: Blend block colors gradually over 10-20 tiles

## Verify

- [ ] Build succeeds with no errors
- [ ] Topsoil blocks are visibly brown
- [ ] Stone blocks are visibly gray
- [ ] Deep stone blocks are visibly darker than stone
- [ ] Background darkens as player goes deeper
- [ ] Transition zones have mixed colors from both layers
- [ ] Layer entry notification shows when crossing boundaries
- [ ] Colors are consistent across game sessions (deterministic)
