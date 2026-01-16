# Camera & View System Research

## Overview
The camera system affects how players perceive the world. For a mining game with both surface and underground areas, the camera needs to handle different contexts smoothly.

## Camera Requirements

### Core Needs
1. Follow player smoothly
2. Handle surface horizontal scrolling
3. Handle underground vertical exploration
4. Support mobile screen sizes
5. Optional zoom for overview

---

## Camera Follow Behavior

### Basic Follow
```gdscript
# camera.gd
extends Camera2D

@export var follow_speed: float = 5.0
@export var look_ahead: float = 50.0

var target: Node2D

func _process(delta):
    if target:
        var target_pos = target.global_position

        # Add look-ahead in movement direction
        if target.velocity.x != 0:
            target_pos.x += sign(target.velocity.x) * look_ahead

        global_position = global_position.lerp(target_pos, follow_speed * delta)
```

### Smoothing Options
| Mode | Best For | Implementation |
|------|----------|----------------|
| Instant | Responsive, tight | `position = target.position` |
| Lerp | Smooth, floaty | `position = lerp(position, target, speed * delta)` |
| Spring | Game feel, bouncy | Physics-based with damping |
| Predictive | Fast-paced | Lerp toward velocity direction |

### Recommended: Lerp with Look-Ahead
- Smooth enough to feel polished
- Look-ahead helps see what's coming
- Not too floaty for precise platforming

---

## Underground vs Surface

### Surface View
- Wider horizontal view
- Sky visible at top
- Buildings in frame
- Less zoom (see more horizontally)

### Underground View
- Tighter vertical framing
- Focus on immediate area
- Darkness at edges
- Slightly more zoom (detail)

### Transition
```gdscript
func update_camera_mode():
    var depth = player.get_depth()

    if depth <= 0:
        # Surface mode
        target_zoom = SURFACE_ZOOM
        offset.y = SURFACE_OFFSET_Y  # Show sky
    else:
        # Underground mode
        target_zoom = UNDERGROUND_ZOOM
        offset.y = 0

    # Smooth zoom transition
    zoom = zoom.lerp(target_zoom, 3.0 * delta)
```

---

## Zoom Levels

### Fixed Zoom (MVP)
- Single zoom level
- Simpler implementation
- Consistent experience

### Recommended Zoom Values
| Context | Zoom | View Size (approx) |
|---------|------|-------------------|
| Surface | 2.0x | 10x18 tiles |
| Underground | 2.5x | 8x14 tiles |
| Shop UI | N/A | Full screen overlay |

### Optional: Player Zoom Control (v1.1+)
```gdscript
func _input(event):
    if event is InputEventMagnifyGesture:
        # Pinch to zoom
        target_zoom *= event.factor
        target_zoom = clamp(target_zoom, MIN_ZOOM, MAX_ZOOM)
```

**Zoom Range:**
- Min: 1.5x (overview, see more)
- Max: 4.0x (detail, see less)

---

## View Distance & Darkness

### Helmet Light System
Underground visibility based on helmet light radius.

```gdscript
# light_system.gd
func update_visibility(depth: int, helmet_level: int):
    var base_radius = 3  # tiles visible in darkness
    var helmet_bonus = helmet_level * 2
    var view_radius = base_radius + helmet_bonus

    # Apply fog/darkness shader based on radius
    darkness_shader.set_shader_parameter("radius", view_radius)
```

### Visibility Tiers
| Helmet Level | View Radius | Cost |
|--------------|-------------|------|
| None | 3 tiles | Free |
| Basic | 5 tiles | 1,000 |
| Improved | 7 tiles | 5,000 |
| Advanced | 10 tiles | 20,000 |
| Master | 15 tiles | 100,000 |

### Implementation Options

**Option A: Shader-Based Darkness**
```gdscript
# Darkness shader fades edges
shader_type canvas_item;

uniform float radius : hint_range(1.0, 20.0) = 5.0;
uniform vec2 player_pos;

void fragment() {
    float dist = distance(UV * SCREEN_PIXEL_SIZE, player_pos);
    float alpha = smoothstep(radius, radius * 0.7, dist);
    COLOR.a *= alpha;
}
```

**Option B: Tile-Based Visibility**
```gdscript
# Only render tiles within radius
func is_tile_visible(tile_pos: Vector2i) -> bool:
    var distance = (tile_pos - player_tile).length()
    return distance <= view_radius
```

**Recommendation:** Shader-based for smooth visuals, tile-based for performance.

---

## Screen Boundaries

### Portrait Mode Layout
```
┌─────────────────────┐
│      HUD (top)      │
├─────────────────────┤
│                     │
│                     │
│    GAME VIEW        │
│    (centered)       │
│                     │
│                     │
├─────────────────────┤
│   CONTROLS (bottom) │
└─────────────────────┘
```

### Camera Limits
```gdscript
# Prevent camera from showing "outside" world
func clamp_camera():
    # Don't show above surface
    if position.y < SURFACE_Y:
        position.y = SURFACE_Y

    # No horizontal limits (infinite world)
    # No vertical lower limit (infinite depth)
```

### Safe Areas (Mobile)
```gdscript
func _ready():
    # Account for notches/cutouts
    var safe_area = DisplayServer.get_display_safe_area()
    $HUD.position.y = safe_area.position.y
    $Controls.position.y = safe_area.end.y - control_height
```

---

## Camera Shake Integration

### Shake System
```gdscript
var shake_amount: float = 0
var shake_decay: float = 5.0

func shake(intensity: float):
    shake_amount = intensity

func _process(delta):
    if shake_amount > 0:
        offset = Vector2(
            randf_range(-shake_amount, shake_amount),
            randf_range(-shake_amount, shake_amount)
        )
        shake_amount = lerp(shake_amount, 0.0, shake_decay * delta)
    else:
        offset = Vector2.ZERO
```

### Shake Settings
- Option to disable (accessibility)
- Intensity slider (0-100%)

---

## Performance Considerations

### Culling
Only render what camera can see:
```gdscript
func get_visible_chunks() -> Array[Vector2i]:
    var cam_rect = get_viewport_rect()
    var top_left = global_position - cam_rect.size / 2
    var bottom_right = global_position + cam_rect.size / 2

    var chunk_tl = world_to_chunk(top_left)
    var chunk_br = world_to_chunk(bottom_right)

    var visible = []
    for x in range(chunk_tl.x - 1, chunk_br.x + 2):
        for y in range(chunk_tl.y - 1, chunk_br.y + 2):
            visible.append(Vector2i(x, y))
    return visible
```

### LOD (Level of Detail)
- Near tiles: Full detail
- Far tiles: Simplified (no animations)
- Off-screen: Not rendered

---

## Mobile Optimizations

### Fixed Aspect Ratio
```gdscript
# Project Settings
# Display > Window > Stretch > Mode = canvas_items
# Display > Window > Stretch > Aspect = keep_height
```

### Touch Input for Camera
- No pan/drag in MVP (follow-only)
- Optional pinch zoom (v1.1+)
- Tap to look? (v1.1+)

---

## Implementation Priority

### MVP
- [x] Basic follow camera
- [x] Smooth lerp movement
- [x] Portrait mode bounds
- [x] Screen shake support

### v1.0
- [ ] Surface/underground zoom transition
- [ ] Helmet light radius
- [ ] Darkness shader
- [ ] Safe area handling

### v1.1+
- [ ] Pinch to zoom
- [ ] Mini-map camera
- [ ] Screenshot mode

---

## Questions Resolved
- [x] Follow style: Smooth lerp with look-ahead
- [x] Zoom levels: 2.0x surface, 2.5x underground
- [x] Darkness: Shader-based with helmet upgrades
- [x] Player zoom control: v1.1+ optional feature
