---
title: "implement: Parallax background"
status: open
priority: 3
issue-type: task
created-at: "2026-01-16T01:52:20.990655-06:00"
after:
  - GoDig-dev-surface-area-379633b2
---

## Description

Add parallax scrolling background layers to the surface area for visual depth. Includes sky gradient, clouds, and distant mountains that scroll at different rates.

## Context

- Parallax creates visual polish and depth perception
- Surface should feel open compared to underground
- Layers scroll slower than camera for depth effect
- Underground doesn't need parallax (solid rock feeling)

## Affected Files

- `scenes/surface.tscn` - Add ParallaxBackground node
- `scenes/backgrounds/surface_parallax.tscn` - NEW: Parallax layers
- `assets/backgrounds/` - Sky, clouds, mountains textures (placeholder)

## Implementation Notes

### Scene Structure

```
Surface (Node2D)
├── ParallaxBackground
│   ├── SkyLayer (ParallaxLayer)
│   │   └── ColorRect (gradient blue to light blue)
│   ├── CloudLayer (ParallaxLayer)
│   │   └── Sprite2D (tiling cloud texture)
│   └── MountainLayer (ParallaxLayer)
│       └── Sprite2D (mountain silhouette)
├── Ground
├── Buildings
└── ...rest of surface
```

### Parallax Layer Settings

| Layer | Motion Scale | Position (Y) | Notes |
|-------|--------------|--------------|-------|
| Sky | (0, 0) | -600 | Static, fills background |
| Clouds | (0.1, 0.05) | -400 | Very slow drift |
| Mountains | (0.3, 0.15) | -200 | Moderate parallax |
| Surface | (1, 1) | 0 | Normal scrolling (not parallax) |

### Sky Gradient Implementation

```gdscript
# For MVP, use ColorRect with shader or simple gradient texture
# Shader approach (optional polish):
shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(0.4, 0.7, 1.0, 1.0);
uniform vec4 bottom_color : source_color = vec4(0.7, 0.9, 1.0, 1.0);

void fragment() {
    COLOR = mix(top_color, bottom_color, UV.y);
}
```

### Cloud Layer Setup

```gdscript
# CloudLayer ParallaxLayer
motion_scale = Vector2(0.1, 0.05)
motion_offset = Vector2.ZERO

# Child Sprite2D
texture = preload("res://assets/backgrounds/clouds.png")
region_enabled = true
region_rect = Rect2(0, 0, 2000, 200)  # Wide for scrolling
```

### Mountain Layer Setup

```gdscript
# MountainLayer ParallaxLayer
motion_scale = Vector2(0.3, 0.15)

# Child Sprite2D - silhouette
texture = preload("res://assets/backgrounds/mountains.png")
modulate = Color(0.2, 0.3, 0.4)  # Dark silhouette
```

### Underground Transition

When player descends underground, hide parallax:

```gdscript
# In camera or surface manager
func _on_player_depth_changed(depth: int) -> void:
    if depth > 0:  # Underground
        _fade_parallax(0.0)
    else:
        _fade_parallax(1.0)

func _fade_parallax(target_alpha: float) -> void:
    var tween := create_tween()
    tween.tween_property($ParallaxBackground, "modulate:a", target_alpha, 0.5)
```

### Asset Requirements (Placeholder for MVP)

For MVP, use solid colors or simple shapes:
- Sky: ColorRect with blue gradient
- Clouds: White ellipses or simple shape texture
- Mountains: Dark triangular silhouettes

Future polish can replace with proper art assets.

## Edge Cases

- Player moves horizontally on surface: Parallax scrolls smoothly
- Player descends underground: Parallax fades out
- Player ascends back to surface: Parallax fades in
- Very fast camera movement: Parallax shouldn't "pop" or jump

## Verify

- [ ] Build succeeds
- [ ] Sky gradient visible at surface
- [ ] Clouds scroll slower than camera horizontally
- [ ] Mountains scroll at medium speed
- [ ] Moving left/right shows parallax effect
- [ ] Parallax fades when entering underground
- [ ] Parallax reappears when returning to surface
- [ ] No visual tearing or popping during movement
- [ ] Performance acceptable with parallax enabled
