# GoDig SciFi Visual Redesign Plan

**Status:** Draft v1.0
**Last Updated:** 2026-01-24
**Theme:** SciFi / Alien Planet / Futuristic / Robotic Tech

---

## Executive Summary

This document outlines the comprehensive visual redesign of GoDig from its current earthy mining aesthetic to a futuristic SciFi theme featuring alien planets, advanced technology, and robotic elements. The redesign will transform the player experience while maintaining the core gameplay mechanics of mining and resource collection.

---

## 1. Current State Analysis

### 1.1 Existing Visual Assets

| Asset Category | Count | Description |
|---------------|-------|-------------|
| Sprite PNGs | 20 | Miner animations, character components |
| Scene Files | 14 | Game scenes, UI panels |
| Resource Definitions | 21 | Layers, ores, items, tools |
| Tileset Atlas | 1 | 768x384 terrain atlas (6x2 grid) |

### 1.2 Current Color Palette

**Underground Layers:**
- Topsoil: Brown `(0.545, 0.353, 0.169)`
- Subsoil: Dark brown `(0.4, 0.25, 0.12)`
- Stone: Gray `(0.5, 0.5, 0.5)`
- Deep Stone: Dark gray `(0.3, 0.3, 0.35)`

**Surface:**
- Sky: Light blue `(0.529, 0.808, 0.922)`
- Ground: Grass green `(0.4, 0.7, 0.3)`

**UI Elements:**
- Backgrounds: Dark brown/gray tones
- Accent: Gold/orange for actions
- Text: Tan and gold tones

### 1.3 Current Theme Keywords
- Earthy, mining, rustic
- Natural materials (dirt, stone)
- Hand tools (pickaxe)
- Simple structures (wooden shop)

---

## 2. Target Vision: SciFi Theme

### 2.1 Core Theme Pillars

1. **Alien Planet** - Hostile, exotic, otherworldly environment
2. **Futuristic Technology** - Advanced mining equipment, holographic UI
3. **Robotic/Mech** - Player as mining robot or mech suit operator
4. **Neon/Cyberpunk Accents** - Glowing elements, energy effects
5. **Sci-Fi Mining Colony** - Industrial extraction on distant world

### 2.2 Narrative Context (Suggested)

> *Year 2387: The megacorporation Helios Industries has deployed automated mining drones to the mineral-rich planet Kepler-442b. You control DIGBOT-7, a versatile excavation unit tasked with extracting rare xenominerals from the planet's crystalline crust. Upgrade your systems, avoid environmental hazards, and drill deeper into the alien substrate.*

### 2.3 Target Color Palette

#### Primary Colors
| Name | Hex | RGB | Use Case |
|------|-----|-----|----------|
| Void Black | `#0a0a0f` | `(10, 10, 15)` | Deep backgrounds |
| Steel Blue | `#1a2a3a` | `(26, 42, 58)` | Surface structures |
| Alien Purple | `#2d1b4e` | `(45, 27, 78)` | Deep layers |
| Toxic Green | `#1a3a1a` | `(26, 58, 26)` | Hazardous zones |

#### Accent Colors (Neon/Glow)
| Name | Hex | RGB | Use Case |
|------|-----|-----|----------|
| Cyan Glow | `#00ffff` | `(0, 255, 255)` | Energy, UI highlights |
| Magenta Pulse | `#ff00ff` | `(255, 0, 255)` | Rare resources |
| Warning Orange | `#ff6600` | `(255, 102, 0)` | Alerts, hazards |
| Data Green | `#00ff88` | `(0, 255, 136)` | Health, positive |

#### Layer-Specific Palettes
| Layer | New Name | Primary | Accent | Visual Concept |
|-------|----------|---------|--------|----------------|
| Topsoil | Regolith | `(0.2, 0.15, 0.25)` Purple-gray | `(0.3, 0.2, 0.35)` | Alien dust/sand |
| Subsoil | Substrate | `(0.15, 0.2, 0.25)` Blue-gray | `(0.2, 0.25, 0.3)` | Compressed alien rock |
| Stone | Xenolite | `(0.2, 0.25, 0.35)` Deep blue | `(0.25, 0.3, 0.4)` | Crystalline formations |
| Deep Stone | Core Mantle | `(0.1, 0.1, 0.15)` Near-black | `(0.15, 0.1, 0.2)` | Molten/radioactive |

---

## 3. Asset Transformation Plan

### 3.1 Character/Player Redesign

**Current:** Human miner with pickaxe
**Target:** Mining robot/mech suit

#### Design Concepts

**Option A: DIGBOT (Fully Robotic)**
- Spherical main body with glowing core
- Extendable drill arm (replaces pickaxe)
- Hover thrusters for movement
- LED status indicators
- Modular attachment points for upgrades

**Option B: Mech Suit (Pilot Visible)**
- Humanoid frame with pilot cockpit
- Mechanical exoskeleton design
- Plasma drill weapon
- Jetpack/thrusters
- Visible HUD elements on helmet

**Option C: Hover Drone (Minimalist)**
- Compact floating drone
- Mining laser beam
- Small but agile design
- Perfect for mobile portrait gameplay

#### Animation Requirements
| Animation | Current | SciFi Version |
|-----------|---------|---------------|
| Idle | Standing still | Hovering with subtle bob |
| Swing/Dig | Pickaxe swing (8 frames) | Drill spin/laser pulse |
| Movement | Walking | Thruster propulsion |
| Damage | Flash red | Sparks + shield flicker |

### 3.2 Terrain/Tileset Redesign

**Current:** 128x128 dirt/stone blocks
**Target:** Alien crystalline/metallic terrain

#### Tile Visual Concepts

| Tile Type | Current Look | SciFi Concept |
|-----------|--------------|---------------|
| Standard Block | Solid color | Hexagonal pattern with glow edges |
| Ore Block | Color tint | Glowing crystal/vein patterns |
| Layer Transition | Color shift | Energy barrier/force field line |
| Damaged Block | Darkening | Crack patterns with energy leak |

#### New Tile Atlas Layout (768x384, 6x2)
```
Row 0: [Regolith] [Substrate] [Xenolite] [Core] [Bedrock] [Special]
Row 1: [Energy Ore] [Crystal Ore] [Metal Ore] [Plasma Ore] [Void Ore] [Artifact]
```

### 3.3 Ore/Resource Redesign

| Current Ore | SciFi Name | New Color | Visual Concept |
|-------------|------------|-----------|----------------|
| Coal | Carbon Nodules | `(0.1, 0.1, 0.15)` | Dark crystals with faint glow |
| Copper | Xenocopper | `(0.2, 0.8, 0.8)` | Cyan metallic, iridescent |
| Iron | Ferrosteel | `(0.4, 0.5, 0.6)` | Brushed metal, blue tint |
| Silver | Argentium | `(0.7, 0.8, 0.9)` | Reflective, holographic sheen |
| Gold | Aurium-7 | `(0.9, 0.7, 0.1)` | Warm glow, energy particles |
| Ruby | Plasma Crystal | `(0.9, 0.1, 0.4)` | Pulsing magenta/red |

#### New Rare Resources (Potential Additions)
- **Void Shard** - Pure black with purple edge glow
- **Quantum Fragment** - Color-shifting, animated
- **Alien Artifact** - Geometric, mysterious patterns

### 3.4 Surface Scene Redesign

**Current:** Blue sky, green grass, wooden buildings
**Target:** Alien landscape, tech structures

#### Sky/Atmosphere
- Gradient: Dark purple → burnt orange (alien sunset)
- Distant stars/nebula visible
- Multiple moons/planets in sky
- Atmospheric particles (dust, spores)

#### Ground Surface
- Color: Purple-gray alien soil `(0.3, 0.25, 0.35)`
- Texture: Cracked, crystalline formations
- Glowing flora hints (bioluminescent plants)

#### Buildings Redesign

**Shop → Equipment Bay**
| Element | Current | SciFi Version |
|---------|---------|---------------|
| Structure | Brown wood | Metal/glass dome |
| Roof | Dark brown | Solar panels/antenna array |
| Door | Dark rectangle | Sliding airlock |
| Sign | "SHOP" text | Holographic display |
| Color | Tan/brown | Steel blue with cyan accents |

**Mine Entrance → Drill Shaft**
| Element | Current | SciFi Version |
|---------|---------|---------------|
| Opening | Dark rectangle | Circular shaft with lights |
| Frame | Simple | Industrial pipe frame |
| Sign | "MINE" text | Warning hologram |
| Effect | None | Steam/energy venting |

### 3.5 UI/HUD Redesign

#### Overall UI Theme
- **Style:** Holographic/transparent panels
- **Borders:** Glowing edge lines (cyan/white)
- **Backgrounds:** Semi-transparent dark `(0.05, 0.08, 0.12, 0.85)`
- **Text:** Clean sans-serif, white with glow
- **Accents:** Cyan highlights, orange warnings

#### HUD Elements

**Health Bar**
- Current: Simple bar
- SciFi: Shield/power meter with segmented cells
- Color: Green → Yellow → Red with glow effect
- Add "HULL INTEGRITY" label

**Coins → Credits**
- Rename to "CREDITS" or "CR"
- Icon: Holographic currency symbol
- Digital readout style

**Depth → Drill Depth**
- Display: "DEPTH: 247m" → "DRILL DEPTH: 247.3M"
- Add elevation graphic (mini-radar)
- Warning colors for deep zones

**Pause Button**
- Current: "||" text
- SciFi: Hexagonal icon with glow

#### Touch Controls

| Button | Current | SciFi Design |
|--------|---------|--------------|
| Jump | Blue circle | Thruster icon, cyan glow |
| Dig | Orange circle | Drill icon, orange pulse |
| Inventory | Green circle | Grid icon, green edge |
| Joystick | Gray area | Holographic ring indicator |

#### Menu Screens

**Main Menu**
- Background: Animated starfield/planet view
- Title: "GODIG" → "G0-D1G" or "DEEP CORE"
- Subtitle: "A Mining Adventure" → "Xenomineral Extraction Unit"
- Buttons: Holographic panels with hover glow

**Pause Menu**
- Overlay: Scan-line effect
- Title: "PAUSED" → "SYSTEM STANDBY"
- Background: Blurred game view with vignette

**Shop/Trading**
- Title: "TRADING POST" → "EQUIPMENT BAY"
- Item display: Holographic item previews
- Categories: "Sell" → "SALVAGE" | "Upgrades" → "MODULES"

**Inventory**
- Title: "INVENTORY" → "CARGO HOLD"
- Slots: Hexagonal or rounded tech frames
- Empty slots: Faint grid pattern

---

## 4. Visual Effects Plan

### 4.1 Shader Effects (New)

| Effect | Purpose | Implementation |
|--------|---------|----------------|
| Glow/Bloom | Neon edges, energy | Post-process or fake with sprites |
| Scan Lines | Retro-tech feel | Overlay texture |
| Hologram Flicker | UI panels | Alpha animation |
| Energy Particles | Ores, damage | GPUParticles2D |
| Force Field | Layer boundaries | Line shader with wave |

### 4.2 Animation Effects

| Effect | Application |
|--------|-------------|
| Floating particles | Background ambiance |
| Drill sparks | Mining feedback |
| Shield shimmer | Taking damage |
| Thruster flame | Player movement |
| Hologram static | Menu transitions |
| Energy pulse | Collecting rare ores |

### 4.3 Damage/Feedback System

**Current:** Block darkens
**SciFi Version:**
- Crack patterns appear (energy lines)
- Small particle bursts on each hit
- Glow intensity decreases
- Final break: Shatter effect + resource particles

---

## 5. Implementation Phases

### Phase 1: Foundation (Color & Data)
- [ ] Update layer `.tres` files with new colors
- [ ] Update ore `.tres` files with new names/colors
- [ ] Create new color constants/theme file
- [ ] Update background colors in scenes
- [ ] Test color coherence

### Phase 2: Terrain Overhaul
- [ ] Design new terrain atlas concepts
- [ ] Create new `terrain_atlas.png` (768x384)
- [ ] Update tileset resource mappings
- [ ] Add subtle glow/edge effects to blocks
- [ ] Test in-game rendering

### Phase 3: Character Redesign
- [ ] Design new player character (concept art)
- [ ] Create component sprites (body, drill, thrusters)
- [ ] Animate new swing/dig cycle
- [ ] Update `miner_animation.tres`
- [ ] Add particle effects to movement

### Phase 4: Surface Transformation
- [ ] Redesign sky gradient (alien atmosphere)
- [ ] Create new surface ground texture
- [ ] Rebuild shop_building.tscn as Equipment Bay
- [ ] Rebuild mine_entrance.tscn as Drill Shaft
- [ ] Add atmospheric effects

### Phase 5: UI Overhaul
- [ ] Create holographic panel style
- [ ] Update HUD layout and graphics
- [ ] Redesign touch control buttons
- [ ] Update all menu scenes
- [ ] Add UI sound effects cues

### Phase 6: Polish & Effects
- [ ] Implement glow/bloom (if shader support)
- [ ] Add particle systems
- [ ] Create transition effects
- [ ] Performance optimization
- [ ] Final visual QA

---

## 6. Technical Considerations

### 6.1 Compatibility

- **Renderer:** GL Compatibility (no advanced shaders)
- **Workaround:** Use sprite-based fake glow, additive blending
- **Performance:** Mobile-first, particle budget limits

### 6.2 Asset Requirements

| Asset Type | Format | Max Size |
|------------|--------|----------|
| Sprites | PNG (RGBA) | 2048x2048 per atlas |
| UI Elements | PNG or Vector | Variable |
| Particles | PNG or Procedural | 128x128 per frame |
| Backgrounds | PNG | 720x1280 (viewport) |

### 6.3 Color Management

- Use resource files for all colors (easy theming)
- Define color constants in autoload
- Support potential future theme switching

---

## 7. Open Questions & Research Needed

### Art Direction
1. What level of detail for pixel art? (16x16, 32x32, 64x64 base?)
2. Should glow effects be baked into sprites or real-time?
3. How much animation complexity for mobile performance?

### Game Design Integration
1. Should resource names change in gameplay systems?
2. New hazard types for alien planet theme?
3. Story/lore elements to add depth?

### Technical
1. Shader support level in GL Compatibility renderer?
2. Particle performance budget on target devices?
3. Need custom font for SciFi aesthetic?

---

## 8. Reference & Inspiration

### Games
- Dome Keeper (sci-fi mining)
- Motherload (underground drilling)
- Deep Rock Galactic (space mining aesthetic)
- Terraria (progression depth system)
- Subnautica (alien planet exploration)

### Visual Styles
- Cyberpunk neon aesthetics
- Retro-futurism (Alien, Blade Runner)
- Clean sci-fi (Mass Effect UI)
- Industrial sci-fi (Dead Space)

### Color Inspiration
- Cyan/magenta neon contrast
- Deep purple space backgrounds
- Warm orange alerts vs cool blue info
- Bioluminescent accent colors

---

## 9. Critique & Risk Assessment

### Strengths of This Plan
- Maintains existing data-driven architecture
- Phased approach allows incremental progress
- Clear visual direction with specific color values
- Leverages current tileset/resource system

### Potential Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| Scope creep | High | Strict phase boundaries |
| Mobile performance | Medium | Test on low-end early |
| Visual coherence | Medium | Style guide enforcement |
| GL Compatibility limits | Low | Plan for sprite-based fallbacks |
| Art asset creation time | High | Consider AI generation or asset packs |

### Gaps in Plan
1. **Audio design** not addressed (should have matching sounds)
2. **Font selection** not specified
3. **Loading screens/splash** not included
4. **Achievement/notification graphics** not covered
5. **Tutorial visuals** if applicable

### Recommended Priorities
1. Start with color palette (lowest effort, high impact)
2. Then terrain atlas (foundational visual change)
3. Then character (hero asset matters most)
4. UI and polish last (can iterate)

---

## 10. Success Metrics

### Visual Quality
- [ ] Consistent color palette across all scenes
- [ ] No jarring visual transitions between areas
- [ ] Clear visual hierarchy in UI
- [ ] Readable text at all sizes

### Performance
- [ ] Maintains 60 FPS on mobile
- [ ] No frame drops during particle effects
- [ ] Load times unchanged or improved

### Player Experience
- [ ] Theme immediately recognizable as sci-fi
- [ ] Visual feedback clear (mining, damage, collection)
- [ ] UI intuitive despite new styling

---

## Appendix A: Detailed Color Mapping

```gdscript
# Proposed color constants for SciFi theme
const COLORS = {
    # Backgrounds
    "void_black": Color(0.04, 0.04, 0.06),
    "deep_space": Color(0.06, 0.08, 0.12),
    "steel_panel": Color(0.1, 0.15, 0.2),

    # Layers
    "regolith_primary": Color(0.2, 0.15, 0.25),
    "regolith_accent": Color(0.3, 0.2, 0.35),
    "substrate_primary": Color(0.15, 0.2, 0.25),
    "substrate_accent": Color(0.2, 0.25, 0.3),
    "xenolite_primary": Color(0.2, 0.25, 0.35),
    "xenolite_accent": Color(0.25, 0.3, 0.4),
    "core_primary": Color(0.1, 0.1, 0.15),
    "core_accent": Color(0.15, 0.1, 0.2),

    # Neon Accents
    "cyan_glow": Color(0.0, 1.0, 1.0),
    "magenta_pulse": Color(1.0, 0.0, 1.0),
    "warning_orange": Color(1.0, 0.4, 0.0),
    "data_green": Color(0.0, 1.0, 0.53),

    # UI
    "ui_background": Color(0.05, 0.08, 0.12, 0.85),
    "ui_border": Color(0.0, 0.8, 0.9, 0.9),
    "ui_text": Color(0.9, 0.95, 1.0),
    "ui_highlight": Color(0.0, 1.0, 1.0),
}
```

---

## Appendix B: File Change Checklist

### Resource Files (.tres)
- [ ] `resources/layers/layer_topsoil.tres` → Regolith colors
- [ ] `resources/layers/layer_subsoil.tres` → Substrate colors
- [ ] `resources/layers/layer_stone.tres` → Xenolite colors
- [ ] `resources/layers/layer_deep_stone.tres` → Core colors
- [ ] `resources/ores/ore_coal.tres` → Carbon Nodules
- [ ] `resources/ores/ore_copper.tres` → Xenocopper
- [ ] `resources/ores/ore_iron.tres` → Ferrosteel
- [ ] `resources/ores/ore_silver.tres` → Argentium
- [ ] `resources/ores/ore_gold.tres` → Aurium-7
- [ ] `resources/ores/ore_ruby.tres` → Plasma Crystal

### Scene Files (.tscn)
- [ ] `scenes/main_menu.tscn` - Background, text colors
- [ ] `scenes/main.tscn` - Background color
- [ ] `scenes/test_level.tscn` - Underground background
- [ ] `scenes/surface.tscn` - Sky, ground colors
- [ ] `scenes/surface/shop_building.tscn` - Complete redesign
- [ ] `scenes/surface/mine_entrance.tscn` - Complete redesign
- [ ] `scenes/ui/hud.tscn` - Panel styling
- [ ] `scenes/ui/touch_controls.tscn` - Button colors
- [ ] `scenes/ui/shop.tscn` - Panel styling, labels
- [ ] `scenes/ui/pause_menu.tscn` - Overlay, styling
- [ ] `scenes/ui/inventory_panel.tscn` - Panel styling
- [ ] `scenes/ui/inventory_slot.tscn` - Slot styling
- [ ] `scenes/ui/floating_text.tscn` - Text colors

### Sprite Assets
- [ ] `resources/sprites/` - All character components
- [ ] `resources/tileset/terrain_atlas.png` - Complete redraw

---

## Appendix C: Research Tasks (Dots)

The following research items have been logged as dots tasks for deeper investigation:

| Dot ID | Priority | Research Topic |
|--------|----------|----------------|
| `GoDig-research-gl-compatibility-*` | P1 | GL Compatibility shader capabilities |
| `GoDig-research-pixel-art-*` | P1 | Pixel art size/style for mobile |
| `GoDig-research-mobile-performance-*` | P1 | Particle performance budget |
| `GoDig-evaluate-player-char-*` | P1 | Character design options evaluation |
| `GoDig-research-scifi-mining-*` | P2 | SciFi mining games inspiration |
| `GoDig-research-scifi-appropriate-*` | P2 | SciFi fonts for UI |
| `GoDig-create-color-palette-*` | P2 | Color palette test scene |
| `GoDig-research-baked-vs-*` | P2 | Baked vs real-time glow effects |
| `GoDig-research-audio-design-*` | P3 | Audio design direction |
| `GoDig-research-ai-art-*` | P3 | AI art generation tools |

Run `dot ready` to see which research tasks are ready to work on.

---

## 11. Detailed Plan Critique

### 11.1 Strengths

**Architecture Alignment**
- The plan correctly identifies that GoDig uses a data-driven resource system
- Color changes can be made by editing `.tres` files without code changes
- The tileset atlas structure is well-understood (768x384, 6x2 grid)
- Phase-based approach allows incremental validation

**Technical Feasibility**
- Proposed color palette uses standard RGB values, no special features needed
- Sprite-based glow workaround is practical for GL Compatibility
- Mobile-first constraints are acknowledged throughout
- Existing animation frame count (8) can be maintained

**Visual Coherence**
- Consistent naming scheme (Regolith, Substrate, Xenolite, Core)
- Color families are well-defined (purple-blues for depth progression)
- Neon accents contrast clearly against dark backgrounds
- Layer progression maintains visual logic (lighter → darker)

### 11.2 Weaknesses & Gaps

**Critical Gaps**

| Gap | Severity | Impact |
|-----|----------|--------|
| No mockups/concept art | High | Risk of misaligned vision |
| Font selection undefined | Medium | UI may lack cohesion |
| Animation complexity unclear | Medium | Development time unknown |
| Audio not addressed | Medium | Incomplete sensory experience |
| Loading/splash screens missing | Low | First impression affected |

**Scope Concerns**
1. **Phase 3 (Character Redesign)** - Underestimated complexity
   - Current character has 20+ PNG files
   - New character concept may need completely different anatomy
   - Animation system assumes 8-frame swing cycle - new design may differ
   - Risk: 2-4x expected effort

2. **Phase 2 (Terrain Atlas)** - Art skill dependency
   - Requires pixel art expertise to execute
   - Current atlas is functional but simple
   - SciFi aesthetic demands more detail (glowing edges, patterns)
   - Risk: May need external artist/AI assistance

3. **Phase 5 (UI Overhaul)** - Consistency challenge
   - 14+ scene files contain UI elements
   - Theme overrides scattered per-node
   - No centralized theme system
   - Risk: Inconsistent application

**Technical Concerns**

1. **GL Compatibility Limitations**
   - No true bloom/glow shader support
   - Particle systems limited compared to Forward+
   - Workarounds may look cheap or dated
   - *Mitigation:* Baked glow sprites, additive blending

2. **Performance on Low-End Mobile**
   - Particle budget unknown
   - More visual complexity = more draw calls
   - ColorRect + modulation may be slower than TileMap
   - *Mitigation:* Early profiling on target devices

3. **Color Blending System**
   - Current: 50% lerp between ore and layer color
   - New palette has more saturated colors
   - Blending may produce muddy results
   - *Mitigation:* Test color combos, adjust blend factors

### 11.3 Risk Assessment Matrix

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Scope creep to "perfect" visuals | High | High | Strict MVP definition per phase |
| Character redesign delays | High | High | Choose simpler design (Drone) |
| UI inconsistency | Medium | Medium | Create theme constants file first |
| Performance regression | Medium | Medium | Profile after each phase |
| Vision misalignment | Medium | High | Create mockups before Phase 2 |
| Art skill gap | High | High | Plan for AI/asset pack fallbacks |
| Breaking existing functionality | Low | High | Maintain integration tests |

### 11.4 Recommended Improvements

**Immediate (Before Phase 1)**
1. Create a visual mockup document with reference images
2. Define minimum viable visual change per phase
3. Establish a `scifi_theme.gd` constants file for centralized colors
4. Choose a specific font and import it

**During Phase 1**
1. Update only background colors first (lowest risk)
2. Screenshot before/after for each scene
3. Run all existing tests to verify no breakage
4. Get visual sign-off before proceeding

**Phase 2 Preparation**
1. Complete dots research on pixel art size FIRST
2. Create terrain tile concepts as sketches before full art
3. Evaluate AI art tools for rapid prototyping
4. Define "good enough" criteria explicitly

**Character Decision**
- **Recommended:** Option C (Hover Drone)
  - Simplest animation requirements
  - No complex joint/limb animation
  - Can evolve to more complex design later
  - Better fits mobile viewport constraints
  - Easier to implement "upgrade modules" visually

### 11.5 Alternative Approaches

**Minimal Viable SciFi (Low Effort)**
1. Only change color palette (Phase 1)
2. Rename resources in data files
3. Update UI labels/text
4. Skip character/terrain redesign
- *Pros:* Fast, low risk
- *Cons:* Half-hearted, may feel inconsistent

**Asset Pack Approach**
1. Purchase/download SciFi game asset pack
2. Adapt existing systems to new assets
3. Modify colors to match pack style
- *Pros:* Professional quality, faster
- *Cons:* Less unique, licensing concerns, integration work

**AI-Assisted Approach**
1. Use AI art tools for concept art
2. Create pixel art from AI concepts
3. Iterate rapidly with AI feedback
- *Pros:* Fast prototyping, exploration
- *Cons:* Consistency challenges, may need manual cleanup

**Hybrid Approach (Recommended)**
1. Phase 1: Color palette only (manual)
2. Phase 2-3: AI-assisted concepts → manual cleanup
3. Phase 4-5: Reference existing SciFi UI kits
4. Phase 6: Evaluate if polish is worth effort

### 11.6 Decision Points

At each phase gate, answer:
1. Does the game feel more SciFi than before?
2. Is visual coherence maintained?
3. Are tests still passing?
4. Is mobile performance acceptable?
5. Should we continue or ship current state?

### 11.7 Success Criteria (Measurable)

| Metric | Target | Measurement |
|--------|--------|-------------|
| Color palette applied | 100% of scenes | Manual audit |
| FPS on mid-range mobile | ≥55 FPS | Profiler |
| Player recognizes theme | >80% "sci-fi" | User feedback |
| Visual bugs introduced | 0 critical | Testing |
| Test suite passing | 100% | CI/CD |

---

## 12. Conclusion

This plan provides a solid foundation for the SciFi visual redesign, but success depends on:

1. **Completing research tasks** before major art production
2. **Starting with low-risk color changes** to build momentum
3. **Making a character design decision** early (recommend Drone option)
4. **Creating mockups** before committing to full asset production
5. **Maintaining test coverage** throughout the redesign

The phased approach allows for validation gates where the project can ship with partial redesign if needed. The data-driven architecture of GoDig is well-suited for this kind of visual overhaul.

**Next Steps:**
1. Run `dot ready` to see research tasks
2. Complete P1 priority research items
3. Create mockup document with reference images
4. Execute Phase 1 (color palette only)
5. Review and decide on Phase 2 approach

---

*Document maintained by: Development Team*
*Version: 1.0*
*Created: 2026-01-24*
*Next review: After Phase 1 completion*
