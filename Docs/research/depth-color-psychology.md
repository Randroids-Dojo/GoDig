# Depth-Based Color Psychology and Environmental Storytelling

> Research on how successful games use color to communicate depth, danger, and progression. Covers warm vs cool color psychology, Dead Cells biome differentiation, the psychology of "unfamiliar" and "cozy" colors, and how lighting affects player mood.
> Last updated: 2026-02-02 (Session 26)

## Executive Summary

Color is one of the most powerful tools for communicating game state without words. Research shows warm colors (reds, oranges) evoke alertness and danger, while cool colors (blues, greens) signal safety and calm. For GoDig, this translates to: warm, saturated surface = home; cool, desaturated depths = unfamiliar territory. This research synthesizes findings from Dead Cells, Hollow Knight, and academic studies on color psychology to inform GoDig's layer visual identity system.

---

## 1. The Psychology of Warm vs Cool Colors

### Emotional Associations

| Color Range | Emotions Evoked | Common Use |
|-------------|-----------------|------------|
| **Warm (red, orange, yellow)** | Energy, excitement, urgency, danger, intimacy | Action sequences, alerts, home areas |
| **Cool (blue, green, purple)** | Calm, mystery, distance, melancholy, depth | Safe zones, underwater, unfamiliar areas |
| **Neutral (gray, brown)** | Stability, earthiness, monotony | Transition areas, caves, stone |

> "Warm colors like red and orange can be used to denote danger or important interactive objects, prompting alertness and quick reactions. Conversely, cool colors such as blue and green often indicate safety and health, helping to create a calming atmosphere."

**Note on paradox**: While cool colors suggest "safety" in many contexts, in underground/depth contexts they can signal "unfamiliar" and "mysterious" - the opposite of the warm, cozy surface home.

**Sources**: [RMCAD - Psychology of Game Art](https://www.rmcad.edu/blog/the-psychology-of-game-art-how-colors-and-design-affect-player-behavior/), [Polydin - Psychology of Colors in Games](https://polydin.com/psychology-of-colors-in-games/)

### Research Findings

Academic research on color and emotion in games found:
> "The color red evoked a highly-aroused, negative emotional response, while the color yellow evoked a positive emotional response. Inexperienced players showed much more explicit reactions to colors than experienced players."

**Implication**: New players will respond more strongly to color cues. Use this to establish safety (surface) vs danger (deep) early.

**Sources**: [ResearchGate - Colors and Emotions in Video Games](https://www.researchgate.net/publication/239842533_Colors_and_Emotions_in_Video_Games)

---

## 2. Dead Cells: A Masterclass in Biome Color

### The Three Pillars

Dead Cells' art direction was built on:
1. **Saturated color palette** - Visual clarity for fast action
2. **Celtic architecture** - Distinctive silhouettes
3. **Theme of alchemy** - Mysterious atmosphere

### Why Saturated Colors Work

> "Saturated backgrounds and characters really shine when it comes to keeping the player awake and alert, drawing the attention of the eye to any new element appearing on the screen. This leads the player to have a better understanding of the action and consequently a faster reaction time."

### The Gradient Map Workflow

Dead Cells uses a brilliant technical approach:
1. Draw textures in **grayscale**
2. Apply **gradient map** to colorize
3. Swap gradient maps to change entire biome feel

> "Modifying the gradient map is then all they need to do in order to change the color palette of a biome... The Promenade's biome was originally orangey and reminiscent of fire, which became an issue when they decided to switch the level's place for gameplay purposes."

### Creating Depth with Color

> "To trick the eye and add depth to the landscapes, the main tool is using analogous color palettes. They also rely heavily on parallax textures, particle effects giving more density to the air, and clouds placed in the foreground."

### Indoor vs Outdoor Contrast

> "They tried to make the differences between an indoor and an outdoor level as striking as possible... the feeling of bursting out of a darkened room into blinding sunlight is always nice."

### Warm/Cold Narrative Contrast

> "They like the contrast created when a peaceful, warm environment meets the gloomy tracks left by the abominations living there. In the first scene, the main character rises in a glow of warm light while the cadaver of a fallen giant rests in the shadow of cold colors."

**Sources**: [Gamedeveloper - Art Design Deep Dive: Dead Cells](https://www.gamedeveloper.com/production/art-design-deep-dive-giving-back-colors-to-cryptic-worlds-in-i-dead-cells-i-)

---

## 3. The "Cozy" Visual Language

### What Makes a Space Feel Cozy

From the Lostgarden "Cozy Games" research:

| Element | Implementation |
|---------|----------------|
| **Warmth signals** | Orange/yellow lighting, fire, sun |
| **Abundance cues** | Visible food, drink, supplies |
| **Strong boundaries** | Clear threshold between safe/unsafe |
| **Contrast enhancement** | Danger visible outside but cannot enter |

> "Gentle gradients between states, colors, or environments within the cozy area are important. However, thresholds between cozy and uncomfortable or even dangerous spaces may be more satisfying if distinct when seen and/or crossed."

### The Window Effect

> "Negating elements can be used to enhance coziness if they are safely outside the player's defined cozy space by providing contrast and juxtaposition. For example, cold rain against a window emphasizes the warmth of a reading nook without threatening to disrupt it."

**GoDig Application**: The mine entrance should show the dark underground below while the player stands in warm surface light - making the return feel like a reward.

**Sources**: [Lostgarden - Cozy Games](https://lostgarden.com/2018/01/24/cozy-games/)

---

## 4. Depth and Darkness

### Underground Psychology

Underground spaces inherently communicate:
- **Confinement** - Low ceilings, narrow passages
- **Mystery** - Limited visibility
- **Danger** - Unknown threats
- **Depth** - Increasing unfamiliarity

### Lighting for Tension

> "Lighting changes or flickering effects suddenly make players anxious. As darkness increases uncertainty, game designers use it as a tactic in horror and thriller genres to evoke fear."

> "Deep red emergency lights and inky shadows in the underground bunker might be just what you need to create tension and set the player's nerves tingling."

### Obscurity Creates Vulnerability

> "Survival horror games create their emotional effect by maintaining a state of player vulnerability, often by suspending the player in a state of incomplete knowledge. The perceptual conditions for this state of vulnerability are enhanced through visual obscurity."

### Hollywood Darkness

> "When lighting scenes for night or shadowy low light conditions, game developers generally follow the film industry convention ('Hollywood Darkness'): make it feel dark, but don't actually make it dark."

**GoDig Application**: Never make the underground so dark that gameplay suffers. Use desaturation and color shift instead of actual darkness.

**Sources**: [Game Studies - Dynamic Lighting for Tension in Games](https://gamestudies.org/0701/articles/elnasr_niedenthal_knez_almeida_zupko), [Level Design Book - Lighting for Darkness](https://book.leveldesignbook.com/process/lighting/darkness)

---

## 5. Biome Visual Identity for Wayfinding

### Color-Coding Regions

From Animal Well and Hollow Knight:
> "Each biome is color coded, making it easy to know where you are, and helps with navigation and exploration. The color-coded nature of the map also helps with identifying the type of biome it is."

### Regional Identity as Navigation

> "Make regional identity do navigational work. Biome tone and geometry should telegraph where you are — and what might be possible now."

### Hollow Knight's Approach

> "Hollow Knight features numerous biomes with their own unique style and tone. From the relaxing beauty of the City of Tears to the Deepnest that invokes a feeling of dread, each area invokes a different feeling that makes you want to keep pushing forward."

### Dead Cells' Room Identity

> "Each room pertains to a specific biome: rooms used in the prison aren't reused in the sewers. This allows developers to give each level its own strongly defined identity."

**Sources**: [DualShockers - Best Metroidvania Game Maps](https://www.dualshockers.com/best-metroidvania-game-maps/), [Gamedeveloper - Building Level Design of a Procedurally Generated Metroidvania](https://www.gamedeveloper.com/design/building-the-level-design-of-a-procedurally-generated-metroidvania-a-hybrid-approach-)

---

## 6. Desaturation and Mood

### What Desaturation Communicates

> "Desaturation can elicit a range of emotional responses, from nostalgia and melancholy to serenity and contemplation."

### Effects of Desaturation

| Effect | Description |
|--------|-------------|
| **Reduces visual noise** | Calmer, less overwhelming |
| **Emphasizes texture and tone** | Details become prominent |
| **Creates sense of depth** | Distant objects appear faded |
| **Guides the eye** | Saturated elements pop |

### Dystopian and Bleak Settings

> "A dystopian game might utilize muted, desaturated tones to evoke bleakness. The psychological effects of saturation and brightness also influence mood. High saturation energizes, while desaturation can calm or create tension."

### Journey's Color Narrative

> "The team at thatgamecompany relies on color to express different feelings: orange for the calm mystery of the desert; dark green for the spooky underground graveyard; white for the biting cold; and bright blue for the moment of rebirth."

**Sources**: [Number Analytics - Art of Desaturation](https://www.numberanalytics.com/blog/art-desaturation-color-theory-deep-dive), [Game Design Skills - Environmental Storytelling](https://gamedesignskills.com/game-design/environmental-storytelling/)

---

## 7. Practical Color Guidelines for GoDig

### The Surface: "Home" Feeling

**Palette**: Warm, saturated
- Dominant: Browns, oranges, warm yellows
- Accents: Greens (grass, life)
- Lighting: Bright, directional (sun)

**Signals**:
- Safety
- Abundance
- Rest
- Reward destination

### Shallow Underground (0-50m): "Familiar"

**Palette**: Warm-neutral, medium saturation
- Dominant: Rich browns, tans
- Accents: Orange ore glints
- Lighting: Ambient warm glow

**Signals**:
- Still comfortable
- Close to home
- Beginner territory

### Mid-Depth (50-200m): "Unfamiliar"

**Palette**: Neutral, reduced saturation
- Dominant: Grays, cool browns
- Accents: Ore colors pop more
- Lighting: Dimmer, less warm

**Signals**:
- Transition zone
- Increasing risk
- More valuable resources

### Deep Underground (200-500m): "Mysterious"

**Palette**: Cool, desaturated
- Dominant: Cool grays, muted blues
- Accents: Rare ore sparkles
- Lighting: Point lights, shadows

**Signals**:
- Unfamiliar territory
- High risk
- High reward

### Extreme Depth (500m+): "Alien"

**Palette**: Very cool/unusual, low saturation
- Dominant: Deep blues, purples, void blacks
- Accents: Glowing elements
- Lighting: Mysterious, ethereal

**Signals**:
- End-game territory
- Maximum risk
- Legendary rewards

### Color Progression Chart

| Depth | Temperature | Saturation | Mood |
|-------|-------------|------------|------|
| Surface | Hot (orange/yellow) | High | Cozy, rewarding |
| 0-50m | Warm (brown/tan) | High-Medium | Comfortable |
| 50-200m | Neutral (gray/brown) | Medium | Cautious |
| 200-500m | Cool (gray/blue) | Medium-Low | Tense |
| 500m+ | Cold (blue/purple) | Low | Alien, dangerous |

---

## 8. Contrast Techniques

### Warm/Cold Contrast

Use warm light sources (torches, lava glow) against cool backgrounds to:
- Guide player attention
- Create visual interest
- Suggest safety points in dangerous areas

> "The intentional mixing of warm and cool zones, like an orange-lit torch in a cold, blue cave, is a sophisticated technique that creates contrast, depth, and storytelling nuance."

### Saturation Contrast

Make important elements more saturated than environment:
- Ores should pop against rock
- Player character visible at all depths
- Dangers (lava, spikes) clearly visible

### Light/Dark Contrast

Use light pools to:
- Guide navigation
- Create rest points
- Highlight important objects

> "Game players are more likely to be drawn to well-lit areas while avoiding darkness instinctively."

---

## 9. Implementation Recommendations

### Layer Palettes

Create distinct palette for each layer:
```
SURFACE:     #F4A460 → #DEB887 → #8B4513 (warm browns)
TOPSOIL:     #A0522D → #8B7355 → #6B4423 (rich earth)
CLAY:        #CD853F → #A9A9A9 → #696969 (transition to gray)
STONE:       #708090 → #2F4F4F → #36454F (cool gray)
GRANITE:     #4682B4 → #5F9EA0 → #008B8B (cool blue-gray)
CRYSTAL:     #483D8B → #6A5ACD → #7B68EE (purple crystals)
VOID:        #191970 → #0D0D0D → #000000 (near black)
```

### Ore Visibility Rules

1. Ore color should contrast with layer background
2. Common ores: blend more with layer
3. Rare ores: higher saturation, glow effect
4. All ores: visible against any layer

### Lighting System

| Depth | Ambient Light | Light Sources | Shadow Density |
|-------|---------------|---------------|----------------|
| Surface | Bright, warm | Sun | Minimal |
| 0-100m | Medium, warm | Player glow | Low |
| 100-300m | Dim, neutral | Torches, crystals | Medium |
| 300-500m | Very dim, cool | Rare crystals, lava | High |
| 500m+ | Minimal, cold | Bioluminescence | Maximum |

### Surface Return Celebration

When player returns to surface with loot:
1. Color temperature shifts from cool to warm
2. Saturation increases as player ascends
3. Light increases dramatically at mine entrance
4. Sound design supports the color shift

This creates the "bursting out of a darkened room into blinding sunlight" effect.

---

## Key Takeaways for GoDig

1. **Warm surface, cool depths**: Establish clear visual language for safety vs danger
2. **Saturation decreases with depth**: Creates unfamiliarity without darkness
3. **Dead Cells gradient map technique**: Consider for efficient palette swaps
4. **Cozy thresholds**: Make surface feel distinctly safer than underground
5. **Hollywood darkness**: Never too dark to play, use color instead
6. **Biome identity for navigation**: Each layer should be instantly recognizable
7. **Ore contrast is critical**: Resources must pop against any background
8. **Warm lights in cold caves**: Create visual interest and guide navigation
9. **Return celebration through color**: Ascending should feel like coming home
10. **Color communicates without words**: Teach depth = danger through palette alone

---

## Sources

### Color Psychology
- [RMCAD - The Psychology of Game Art](https://www.rmcad.edu/blog/the-psychology-of-game-art-how-colors-and-design-affect-player-behavior/)
- [Polydin - Psychology of Colors in Games](https://polydin.com/psychology-of-colors-in-games/)
- [ResearchGate - Colors and Emotions in Video Games](https://www.researchgate.net/publication/239842533_Colors_and_Emotions_in_Video_Games)
- [GlobalStep - Impact of Color Theory on Level Design](https://globalstep.com/blog/the-impact-of-color-theory-on-level-design-using-colors-to-influence-mood-and-behavior/)

### Case Studies
- [Gamedeveloper - Art Design Deep Dive: Dead Cells](https://www.gamedeveloper.com/production/art-design-deep-dive-giving-back-colors-to-cryptic-worlds-in-i-dead-cells-i-)
- [DualShockers - Best Metroidvania Game Maps](https://www.dualshockers.com/best-metroidvania-game-maps/)

### Cozy Design
- [Lostgarden - Cozy Games](https://lostgarden.com/2018/01/24/cozy-games/)

### Lighting and Atmosphere
- [Game Studies - Dynamic Lighting for Tension in Games](https://gamestudies.org/0701/articles/elnasr_niedenthal_knez_almeida_zupko)
- [Level Design Book - Lighting for Darkness](https://book.leveldesignbook.com/process/lighting/darkness)
- [300Mind - Importance of Lighting in Game Design](https://300mind.studio/blog/lighting-in-game-design/)

### Environmental Storytelling
- [Game Design Skills - Environmental Storytelling](https://gamedesignskills.com/game-design/environmental-storytelling/)
- [Number Analytics - Art of Desaturation](https://www.numberanalytics.com/blog/art-desaturation-color-theory-deep-dive)
