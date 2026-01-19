---
title: "implement: Lighting by depth"
status: open
priority: 3
issue-type: task
created-at: "2026-01-16T00:44:03.968452-06:00"
after:
  - GoDig-dev-layer-depth-89c9d8ac
---

## Description

Implement depth-based ambient lighting that progressively darkens as the player descends. Creates atmosphere and drives demand for helmet light upgrades.

## Context

- Lighting progression: Good → Medium → Low → Dark → Glow (crystals) → Red (magma) → Void
- Player light radius is upgradeable (Helmet Light in Equipment Shop)
- Dark zones without light make navigation difficult but not impossible
- See research: GoDig-research-hazards-environmental-f344e8b1

## Affected Files

- `scripts/world/lighting_manager.gd` - NEW: Controls ambient lighting
- `scripts/camera/game_camera.gd` - Apply color modulation
- `scripts/player/player.gd` - Add player light (PointLight2D)
- `scripts/autoload/player_data.gd` - Track helmet light level

## Implementation Notes

### Lighting Zones by Depth

| Zone | Depth | Ambient Light | Visibility | Notes |
|------|-------|---------------|------------|-------|
| Surface | 0-50m | 100% | Full | Daylight |
| Shallow | 50-200m | 80% | Good | Slight dimming |
| Medium | 200-500m | 50% | Medium | Noticeable darkness |
| Deep | 500-1000m | 25% | Low | Requires light |
| Dark | 1000-1500m | 10% | Very Low | Essential light |
| Crystal | 1500-2000m | 15% (+glow) | Medium | Bioluminescence |
| Magma | 2000-3000m | 30% (red tint) | Medium | Lava glow |
| Void | 3000m+ | 5% | Very Low | End game |

### Ambient Light Implementation

```gdscript
# lighting_manager.gd
class_name LightingManager
extends Node

signal lighting_changed(ambient_level: float, tint: Color)

var current_depth: int = 0
var current_ambient: float = 1.0
var current_tint: Color = Color.WHITE

func update_depth(depth: int) -> void:
    current_depth = depth
    _recalculate_lighting()

func _recalculate_lighting() -> void:
    var old_ambient := current_ambient
    var old_tint := current_tint

    # Determine zone and lighting
    if current_depth < 50:
        current_ambient = 1.0
        current_tint = Color.WHITE
    elif current_depth < 200:
        current_ambient = lerp(1.0, 0.8, (current_depth - 50) / 150.0)
        current_tint = Color.WHITE
    elif current_depth < 500:
        current_ambient = lerp(0.8, 0.5, (current_depth - 200) / 300.0)
        current_tint = Color(0.95, 0.95, 1.0)  # Slight blue
    elif current_depth < 1000:
        current_ambient = lerp(0.5, 0.25, (current_depth - 500) / 500.0)
        current_tint = Color(0.9, 0.9, 1.0)  # More blue
    elif current_depth < 1500:
        current_ambient = lerp(0.25, 0.1, (current_depth - 1000) / 500.0)
        current_tint = Color(0.8, 0.8, 1.0)  # Dark blue
    elif current_depth < 2000:
        # Crystal caves - slight glow
        current_ambient = lerp(0.1, 0.15, (current_depth - 1500) / 500.0)
        current_tint = Color(0.8, 0.9, 1.0)  # Cyan hint
    elif current_depth < 3000:
        # Magma zone - red glow
        current_ambient = lerp(0.15, 0.3, (current_depth - 2000) / 1000.0)
        current_tint = Color(1.0, 0.7, 0.5)  # Orange/red
    else:
        # Void
        current_ambient = 0.05
        current_tint = Color(0.7, 0.5, 0.8)  # Purple hint

    if current_ambient != old_ambient or current_tint != old_tint:
        lighting_changed.emit(current_ambient, current_tint)
```

### Camera Light Application

```gdscript
# game_camera.gd additions
@onready var ambient_modulate: CanvasModulate = $AmbientModulate

func _ready() -> void:
    LightingManager.lighting_changed.connect(_on_lighting_changed)

func _on_lighting_changed(ambient: float, tint: Color) -> void:
    var final_color := tint * ambient
    var tween := create_tween()
    tween.tween_property(ambient_modulate, "color", final_color, 0.5)
```

### Player Light (Helmet)

```gdscript
# player.gd additions
@onready var helmet_light: PointLight2D = $HelmetLight

func _ready() -> void:
    _update_helmet_light()
    PlayerData.equipment_changed.connect(_update_helmet_light)

func _update_helmet_light() -> void:
    var light_level := PlayerData.get_helmet_light_level()
    match light_level:
        0:
            helmet_light.energy = 0.5
            helmet_light.texture_scale = 3.0  # Small radius
        1:
            helmet_light.energy = 0.8
            helmet_light.texture_scale = 5.0
        2:
            helmet_light.energy = 1.0
            helmet_light.texture_scale = 7.0
        3:
            helmet_light.energy = 1.2
            helmet_light.texture_scale = 10.0  # Large radius
```

### Helmet Light Tiers

| Tier | Name | Cost | Radius | Energy | Unlocks At |
|------|------|------|--------|--------|------------|
| 0 | None | - | Small | 50% | Start |
| 1 | Basic Helmet | 500 | Medium | 80% | 200m |
| 2 | Miner Helmet | 2000 | Large | 100% | 500m |
| 3 | Pro Helmet | 10000 | Very Large | 120% | 1000m |

### Scene Setup

Player scene needs PointLight2D child:
```
Player (CharacterBody2D)
├── ... existing nodes ...
└── HelmetLight (PointLight2D)
    - texture: radial gradient
    - blend_mode: Add
    - shadow_enabled: false (performance)
```

## Edge Cases

- Transitioning between zones: Smooth lerp over 0.5 seconds
- Loading save at depth: Set lighting immediately, no transition
- Player dies at depth: Reset to surface lighting on respawn
- Crystal/magma glow areas: Ambient glow in addition to player light

## Verify

- [ ] Build succeeds
- [ ] Surface (0-50m) is fully lit
- [ ] 500m depth is noticeably darker (50% ambient)
- [ ] 1000m depth is very dark (25% ambient)
- [ ] Crystal caves (1500-2000m) have cyan tint
- [ ] Magma zone (2000-3000m) has red/orange tint
- [ ] Player helmet light illuminates surroundings
- [ ] Helmet upgrade increases light radius
- [ ] Lighting transitions smoothly between zones
- [ ] Performance is acceptable with lighting enabled
