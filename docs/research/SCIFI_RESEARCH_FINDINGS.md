# SciFi Redesign Research Findings

**Date:** 2026-01-24
**Purpose:** Comprehensive research to inform GoDig's visual redesign to SciFi theme

---

## Executive Summary

All 10 research tasks have been completed. Key findings:

| Topic | Recommendation |
|-------|----------------|
| **Renderer** | GL Compatibility supports additive blending for fake glow; no native bloom |
| **Tile Size** | Downsize from 128x128 to 64x64 for 4x better world visibility |
| **Particles** | Max 200-300 total, 15-25 per effect, use GPUParticles2D with fixed_fps=30 |
| **Character** | DIGBOT (spherical robot) - best balance of appeal, readability, upgrades |
| **Fonts** | Orbitron (titles) + Exo 2 (body) + Share Tech Mono (numbers) |
| **Glow** | Hybrid: bake ambient glow into sprites, use additive shaders for animation |
| **AI Art** | PixelLab + Retro Diffusion for sprites; Leonardo.ai for custom model training |

---

## 1. GL Compatibility Shader Capabilities

### Supported Features
- Basic vertex/fragment shaders (GLSL ES 3.0)
- CanvasItemMaterial blend modes (ADD, MIX, MUL, SUB)
- GPUParticles2D and CPUParticles2D
- Custom post-processing via ColorRect + CanvasLayer
- Screen texture reading via `hint_screen_texture`

### NOT Supported / Limited
- **Environment glow/bloom** - NOT implemented in GL Compatibility
- Auto exposure
- FXAA antialiasing
- PointLight2D has severe performance issues on mobile

### Workarounds for SciFi Glow
```gdshader
// Additive blend for fake glow
shader_type canvas_item;
render_mode blend_add;

uniform vec4 glow_color : source_color = vec4(0, 1, 1, 1);
uniform float intensity : hint_range(0, 2) = 1.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    COLOR = tex * glow_color * intensity;
}
```

**Recommended Architecture:**
```
Scene Tree:
├── GameWorld
├── GlowLayer (CanvasLayer, additive sprites)
├── UI (CanvasLayer)
└── PostProcess (ColorRect with effects)
```

---

## 2. Pixel Art Size Recommendations

### Current vs Recommended

| Metric | Current (128x128) | Recommended (64x64) |
|--------|-------------------|---------------------|
| Tiles visible (720x1280) | 5.6 x 10 | 11 x 20 |
| Memory per sprite | 64 KB | 16 KB |
| 8-frame sheet | 512 KB | 128 KB |
| World visibility | Very zoomed in | Good overview |

### Recommendation
**Downsize to 64x64 tiles** - This is the "sweet spot" used by Stardew Valley and Celeste.

Benefits:
- 4x more world visible on screen
- 75% memory reduction
- Better animation fluidity
- Maintains sufficient detail for SciFi tech elements

---

## 3. Mobile Particle Performance Budget

### Maximum Counts

| Effect Type | Max Per Effect | Notes |
|-------------|---------------|-------|
| Burst effect (collection) | 30-50 | One-shot |
| Continuous (drilling) | 15-25 | Looping |
| Ambient (floating) | 20-40 | Low priority |
| **Total on screen** | **200-300** | Combined |

### Best Practices
- Set `fixed_fps = 30` on all GPUParticles2D
- Enable `interpolate` for smoother appearance
- Pool particle systems (don't instantiate/free at runtime)
- Use CPUParticles2D for <20 particles
- Particle textures: 32x32 max

### Frame Budget
- Total frame time at 60 FPS: 16.67ms
- Particle effects budget: **2ms maximum**

---

## 4. Character Design Evaluation

### Comparison

| Criterion | DIGBOT (Robot) | Mech Suit | Hover Drone |
|-----------|----------------|-----------|-------------|
| Animation complexity | 7/10 | 4/10 | 9/10 |
| Visual appeal | 8/10 | 9/10 | 6/10 |
| Mobile readability | 7/10 | 5/10 | 9/10 |
| Upgrade visibility | 9/10 | 6/10 | 7/10 |
| Mining theme fit | 8/10 | 7/10 | 6/10 |
| Dev effort (inverted) | 6/10 | 3/10 | 9/10 |
| **Weighted Total** | **7.55** | **5.90** | **7.55** |

### Recommendation: DIGBOT

- Spherical body with glowing core provides iconic silhouette
- Drill arm clearly communicates mining purpose
- Modular attachment points perfect for upgrade visualization
- Matches "DIGBOT-7" narrative context
- Estimated 18-22 PNG assets needed

---

## 5. SciFi Mining Game Inspiration

### Key Insights from Analyzed Games

**Dome Keeper:**
- Strict 8-12 color palette breeds recognizability
- Biome color-coding shows depth progression
- Silhouette-first character design

**Deep Rock Galactic:**
- Glowing resources discoverable in dark caves
- Natural light sources (crystals) reduce UI clutter
- Each resource needs distinct color AND shape

**SteamWorld Dig:**
- Robot character with personality (Rusty)
- Light as both resource and visual mechanic
- Equipment visibly changes with upgrades

**Subnautica:**
- "Smartphone-friendly" UI philosophy
- Minimal HUD - depth + essentials only
- Bioluminescence for natural atmosphere

### Recommended Color Strategy

| Depth | Primary | Glow | Concept |
|-------|---------|------|---------|
| Surface | Steel blue | Sunlight | Colony structures |
| 0-50m | Purple-gray | Warm | Alien regolith |
| 50-200m | Blue-gray | Cyan | Compressed rock |
| 200-500m | Deep blue | Magenta | Crystals |
| 500m+ | Near-black | Hot pink/red | Core danger |

---

## 6. Font Recommendations

### Recommended Font Stack

| Role | Font | Size Range |
|------|------|------------|
| Titles/Headers | Orbitron | 24-48px |
| Body/UI Text | Exo 2 | 12-18px |
| Numbers/Data | Share Tech Mono | 12-18px |

All fonts are:
- SIL Open Font License (free commercial use)
- Available on Google Fonts
- Compatible with Godot 4

### Alternative: Single Family
Use **Oxanium** for everything - 7 weights, designed for game HUDs.

---

## 7. Glow Effects Approach

### Hybrid Strategy (Recommended)

| Use Case | Approach | Reason |
|----------|----------|--------|
| Ore blocks | Baked + optional pulse | Many on screen, performance critical |
| Player core | Layered additive sprite | Only 1, needs animation |
| UI highlights | Pure shader | Few elements, dynamic |
| Neon outlines | Shader (limited use) | Quality matters |

### Baked Glow Specs
- Expand sprite from 64x64 to 80x80 (+8px padding)
- Gaussian blur radius: 6-8 pixels
- Opacity falloff: 100% at edge → 0% at 8px out

### Simple Pulse Shader
```gdshader
shader_type canvas_item;
uniform float pulse_speed = 1.5;
uniform float pulse_min = 0.8;
uniform float pulse_max = 1.2;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float pulse = mix(pulse_min, pulse_max, (sin(TIME * pulse_speed) + 1.0) * 0.5);
    COLOR = vec4(tex.rgb * pulse, tex.a);
}
```

---

## 8. Audio Design Direction

### Five Audio Pillars
1. **Mechanical Precision** - Servos, hydraulics, electronic hums
2. **Alien Atmosphere** - Foreign, mysterious environment
3. **High-Tech Interface** - Holographic, data processing sounds
4. **Satisfying Power** - Lasers, plasma (not metal on stone)
5. **Mobile-First** - Small files, phone speaker optimized

### Sound Categories

| Category | Sonic Character |
|----------|-----------------|
| Drilling | Wind-up → sustained laser → impact |
| Block break | Material-specific (crystalline, metallic) |
| UI | Glass-tap, holographic ping |
| Pickup | Rising pitch by rarity |
| Ambient | Depth-based zone soundscapes |

### Asset Budget
- **Phase 1 (MVP):** ~30 files
- **Phase 2 (v1.0):** ~80 files
- **Total size target:** ~20MB

---

## 9. AI Art Generation Tools

### Recommended Stack (Budget: ~$24-34/mo + $65 one-time)

| Tool | Purpose | Cost |
|------|---------|------|
| **PixelLab** | Character sprites, animations | $12/mo |
| **Retro Diffusion** | Terrain tiles (Aseprite plugin) | $65 one-time |
| **Stable Diffusion** | Batch generation, experimentation | Free (local) |
| Leonardo.ai | Custom DIGBOT model training | $12/mo (optional) |

### Workflow
1. Concept exploration with DALL-E 3/Midjourney
2. Train custom model on approved concepts (Leonardo.ai)
3. Generate production sprites (PixelLab)
4. Create seamless tiles (Retro Diffusion)
5. Manual cleanup in Aseprite (plan 30-50% of time)

### Licensing Notes
- All paid tier outputs are commercially usable
- Document human modifications for stronger copyright
- Avoid generating recognizable IP

---

## 10. Color Palette Test Scene

Created: `scenes/test/color_palette_test.tscn`

Includes:
- Primary colors (Void Black, Steel Blue, Alien Purple, Toxic Green)
- Accent colors (Cyan Glow, Magenta Pulse, Warning Orange, Data Green)
- Layer color progression (Regolith → Core Mantle)
- Ore colors (Carbon Nodules through Plasma Crystal)
- UI panel demo with holographic styling
- Depth mockup visualization

Run the scene in Godot to visually validate the palette.

---

## Next Steps

1. **Phase 1 Execution:**
   - Apply SciFi color palette to layer/ore `.tres` files
   - Update scene background colors
   - Download and import recommended fonts

2. **Character Decision:**
   - Finalize DIGBOT design
   - Create concept sketches at 64x64
   - Test silhouette readability on mobile

3. **Tool Setup:**
   - Set up PixelLab account
   - Purchase Retro Diffusion
   - Configure Stable Diffusion locally (optional)

4. **Prototype:**
   - Apply 3-4 color changes to test_level.tscn
   - Add one glow shader to test
   - Validate on mobile device

---

## Research Task Completion Summary

| Task | Status | Key Finding |
|------|--------|-------------|
| GL Compatibility shaders | Done | Additive blend for glow, no native bloom |
| Pixel art sizing | Done | Use 64x64 (not 128x128) |
| Mobile particle budget | Done | Max 200-300 total, 15-25 per effect |
| Character evaluation | Done | DIGBOT recommended |
| SciFi game inspiration | Done | 10-12 color palette, depth-based shifts |
| Font research | Done | Orbitron + Exo 2 + Share Tech Mono |
| Glow effects | Done | Hybrid baked + shader approach |
| Audio design | Done | 5 pillars defined, phase plan created |
| AI art tools | Done | PixelLab + Retro Diffusion recommended |
| Color palette scene | Done | scenes/test/color_palette_test.tscn |

---

*Research completed: 2026-01-24*
