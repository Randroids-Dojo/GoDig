# Color-Blind Accessibility Patterns in Layer-Based Games

*Research Session 26 - Visual Accessibility*

## Overview

GoDig uses depth-based color palettes to distinguish underground layers. This document explores how to maintain accessibility for the 5-8% of players with color vision deficiency (CVD).

## Color Blindness Statistics

From [Alan Zucconi - Accessibility Design](https://www.alanzucconi.com/2015/12/16/color-blindness/):

| Type | Affects | Prevalence | Impact |
|------|---------|------------|--------|
| **Deuteranomaly** | Green perception | ~3% | Red-green confusion |
| **Protanopia** | Red perception | ~1% | Red-green confusion |
| **Deuteranopia** | Green perception | ~1% | Red-green confusion |
| **Tritanopia** | Blue perception | ~0.01% | Blue-yellow confusion |
| **Achromatopsia** | All color | ~0.003% | Complete colorblindness |

**Key stat**: About 5% of the population has some form of colorblindness, with 99% having red-green deficiency.

From [ALA Games - Accessibility in Gaming](https://games.ala.org/accessibility-in-gaming-color-blindness/):

> "If six players sit down to the table, there is an estimated 4.25% chance any one of them is colorblind."

## Types of Color Blindness

### Red-Green (Most Common)

**Protanopia & Deuteranopia**:
- Cannot distinguish red from green
- Reds, greens, and browns appear similar
- Blues and yellows remain distinct

**Safe colors**: Blue, yellow, orange (with care)

### Blue-Yellow (Less Common)

**Tritanopia**:
- Cannot distinguish blue from yellow
- Blues appear greenish
- Yellows appear pinkish

**Safe colors**: Red, green

### Complete Colorblindness (Very Rare)

**Achromatopsia**:
- All colors appear as grayscale
- Relies entirely on brightness/value differences
- Must use shape, pattern, texture

## Dangerous Color Combinations

From [Smashing Magazine - Designing for Colorblindness](https://www.smashingmagazine.com/2024/02/designing-for-colorblindness/):

**Never use together**:
- Red and green
- Green and brown
- Green and blue
- Blue and gray
- Blue and purple
- Green and gray
- Green and orange
- Red and brown

**Safe combinations**:
- Blue and orange
- Blue and red
- Blue and brown
- Black and yellow
- White and dark blue

## Design Solutions

### 1. Never Rely on Color Alone

From [Chris Fairfield - Unlocking Colorblind Friendly Game Design](https://chrisfairfield.com/unlocking-colorblind-friendly-game-design/):

> "If your game is using colors to convey important game information, you shouldn't force the colors to do all of that heavy lifting on their own. Instead, pair them with some sort of pattern, texture, or icon."

**Implementation**: Every color-coded element needs a secondary identifier.

### 2. Use Patterns and Textures

From [Venngage - Color Blind Design Guidelines](https://venngage.com/blog/color-blind-design/):

> "Checkered designs implement complex checkered patterns to provide immediate visual differentiation without relying solely on color."

**For GoDig layers**:
| Layer | Color | Pattern Backup |
|-------|-------|----------------|
| Topsoil | Brown | Grass tufts, roots |
| Dirt | Dark brown | Worms, pebbles |
| Clay | Orange | Cracks, striations |
| Stone | Gray | Crystalline texture |
| Deep Stone | Dark gray | Glowing cracks |
| Magma | Red/orange | Lava bubbles |

### 3. Minecraft's Ore Solution

From [Minecraft Feedback](https://feedback.minecraft.net/hc/en-us/community/posts/360038921452-Give-every-ore-a-unique-texture-for-colourblind-accessibility-Examples-inside-):

> "The texture of ores were changed in 1.17 to make them distinct for color blind players."

Each ore has a **unique shape**:
- Diamond: Distinct crystal pattern
- Iron: Irregular chunks
- Gold: Round nuggets
- Redstone: Wire-like veins

**For GoDig ores**:
| Ore | Color | Shape Identifier |
|-----|-------|------------------|
| Copper | Orange | Round nuggets |
| Iron | Gray | Irregular shards |
| Silver | Light gray | Crystalline |
| Gold | Yellow | Smooth rounds |
| Ruby | Red | Hexagonal |
| Sapphire | Blue | Rectangular |
| Emerald | Green | Triangular |
| Diamond | Cyan | Star/burst |

### 4. Outlined Ores Pattern

From [Texture Packs - Outlined Ores](https://texture-packs.com/resourcepack/outlined-ores/):

> "These outlines serve as visual cues, making ores stand out without altering their core design."

**Consider for GoDig**:
- High-value ores get colored outlines
- Outline color differs from fill color
- Creates secondary visual signal

### 5. Colorblind Modes

From [Colorblind Games](https://colorblindgames.com/colorblind-gaming-101/):

> "Perhaps the most common way of implementing colorblind accessibility in games is including modes for the different types of colorblindness via a whole-screen filter."

**Options for GoDig**:
1. **Protanopia mode** - Shifts reds to more distinguishable hues
2. **Deuteranopia mode** - Shifts greens to more distinguishable hues
3. **Tritanopia mode** - Shifts blues to more distinguishable hues
4. **High contrast mode** - Increases value differences

### 6. Custom Color Palettes

From [Filament Games - Color Blindness Accessibility](https://www.filamentgames.com/blog/color-blindness-accessibility-in-video-games/):

> "Some color blindness tools give the player the ability to change any of the colors in those palettes. They can pick from a set of swatches or even create their own custom swatch."

**For GoDig**: Let players customize ore/layer colors.

## Safe Color Palette for GoDig

### Universal Safe Base

From [Colorblind Games](https://colorblindgames.com/colorblind-gaming-101/):

> "Use blue and orange for key elements since those colors stick out for all 3 CVD types."

**Recommended palette**:
| Purpose | Primary | Secondary |
|---------|---------|-----------|
| Common ore | Blue tones | Outlined |
| Rare ore | Orange tones | Bright outline |
| Danger | High value red | Pulsing |
| Safety | High value green | Icon backup |
| UI elements | Blue/orange | Always with icons |

### Layer Palette with Accessibility

| Depth | Layer | Primary Color | CVD-Safe Adjustment | Texture Backup |
|-------|-------|---------------|---------------------|----------------|
| 0-50m | Topsoil | Warm brown | Increase brightness | Grass, roots |
| 50-150m | Clay | Orange | Keep distinct | Horizontal lines |
| 150-300m | Stone | Blue-gray | Increase blue | Crystalline |
| 300-500m | Granite | Dark blue | High contrast | Dense cracks |
| 500-750m | Obsidian | Purple-black | Add blue | Glassy reflection |
| 750m+ | Core | Orange-red | High saturation | Lava bubbles |

## Implementation Checklist

### Layer Distinction

- [ ] Each layer has unique background texture
- [ ] Brightness/value differs between adjacent layers
- [ ] Transition zones are clearly marked
- [ ] Layer names appear in UI (not just colors)

### Ore Identification

- [ ] Each ore has unique silhouette/shape
- [ ] Ores have secondary pattern indicators
- [ ] Tooltip shows ore name on hover/tap
- [ ] Ore colors differ in value, not just hue

### UI Elements

- [ ] Never use red/green for opposite meanings
- [ ] All colored buttons have icons
- [ ] Text passes WCAG 4.5:1 contrast ratio
- [ ] Status indicators use shape + color

### Accessibility Options

- [ ] Colorblind filter modes (3 types)
- [ ] High contrast mode
- [ ] Outline toggle for important elements
- [ ] Custom color picker (advanced)

## Testing Approach

### Simulation Tools

From [Stephanie Walter - Color Accessibility](https://stephaniewalter.design/blog/color-accessibility-tools-resources-to-design-inclusive-products/):

1. **Color Oracle** - Desktop simulator
2. **Sim Daltonism** - Mac app
3. **Coblis** - Web-based simulator
4. **Chrome DevTools** - Built-in emulator

### Testing Protocol

1. **Design phase**: Run all mockups through CVD simulators
2. **Development**: Test in-game with simulators running
3. **QA**: Include CVD testers in beta group
4. **Post-launch**: Monitor feedback for accessibility issues

### Questions to Ask

For each visual element:
1. Can it be identified without color?
2. Does it have sufficient contrast?
3. Is there pattern/texture backup?
4. Does the meaning change if color is removed?

## Case Studies

### Dead Cells Accessibility Update

From [Nintendo Life - Dead Cells Accessibility](https://www.nintendolife.com/news/2022/06/dead-cells-accessibility-focused-update-adds-assist-mode-difficulty-options-and-more):

> "Texts in the Stat Selection Menu no longer use 'Red', 'Purple' and 'Green', but instead use 'Brutality', 'Tactic' and 'Survival.'"

**Lesson**: Use names, not colors, in text references.

### Hollow Knight Concerns

From [Steam Community - Silksong Accessibility](https://steamcommunity.com/app/1030300/discussions/0/546746241084882360/):

> "As someone with colorblindness some of these sections just aren't playable."

**Lesson**: Even beautiful games can fail accessibility if not designed intentionally.

## Sources

- [Alan Zucconi - Accessibility Design: Color Blindness](https://www.alanzucconi.com/2015/12/16/color-blindness/)
- [Chris Fairfield - Unlocking Colorblind Friendly Game Design](https://chrisfairfield.com/unlocking-colorblind-friendly-game-design/)
- [Smashing Magazine - Designing for Colorblindness](https://www.smashingmagazine.com/2024/02/designing-for-colorblindness/)
- [Venngage - Color Blind Design Guidelines](https://venngage.com/blog/color-blind-design/)
- [Filament Games - Color Blindness Accessibility in Video Games](https://www.filamentgames.com/blog/color-blindness-accessibility-in-video-games/)
- [Colorblind Games - Colorblind Gaming 101](https://colorblindgames.com/colorblind-gaming-101/)
- [ALA Games - Accessibility in Gaming: Color Blindness](https://games.ala.org/accessibility-in-gaming-color-blindness/)
- [Minecraft Wiki - Ore](https://minecraft.wiki/w/Ore)
- [Nintendo Life - Dead Cells Accessibility Update](https://www.nintendolife.com/news/2022/06/dead-cells-accessibility-focused-update-adds-assist-mode-difficulty-options-and-more)
- [Stephanie Walter - Color Accessibility Tools](https://stephaniewalter.design/blog/color-accessibility-tools-resources-to-design-inclusive-products/)
- [TV Tropes - Colorblind Mode](https://tvtropes.org/pmwiki/pmwiki.php/Main/ColorblindMode)

## Related Implementation Tasks

- `GoDig-implement-layer-visual-03fb3fce` - Layer visual identity system
- `GoDig-implement-distinct-layer-a60843e5` - Distinct layer identity system
- `GoDig-implement-depth-palette-92a488d3` - Depth palette system
- `GoDig-research-accessibility-4042c8e1` - Accessibility Features research
