# Art Style Direction Research

## Style Recommendation: Modern Pixel Art

### Why Pixel Art?
1. **Nostalgia appeal** - Mining games (Motherload, Terraria) have pixel roots
2. **Efficient production** - Faster to create than HD art
3. **Scalable** - Looks good at any resolution
4. **Charming aesthetic** - Timeless appeal
5. **Clear readability** - Important for mobile

### Resolution: 16x16 Tile Base
- Player: 16x32 (2 tiles tall)
- Blocks: 16x16
- UI elements: Multiples of 8px
- Crisp at all device sizes

---

## Color Palette Strategy

### Overall Approach
- Warm, inviting surface
- Colors shift cooler/darker with depth
- Each layer has distinct identity
- Ores/gems pop against background

### Surface Palette
```
Sky:        #87CEEB (light blue)
Grass:      #4CAF50 (green)
Buildings:  #8B4513 (brown wood)
Accents:    #FFD700 (gold highlights)
```

### Underground Layer Palettes

#### Topsoil (0-50m)
```
Primary:    #8B4513 (brown)
Secondary:  #A0522D (sienna)
Accent:     #D2691E (chocolate)
Background: #5D4037 (dark brown)
```

#### Subsoil (50-200m)
```
Primary:    #6B4423 (dark brown)
Secondary:  #4E342E (espresso)
Accent:     #795548 (coffee)
Background: #3E2723 (very dark)
```

#### Stone Layer (200-500m)
```
Primary:    #9E9E9E (gray)
Secondary:  #757575 (dark gray)
Accent:     #BDBDBD (light gray)
Background: #424242 (charcoal)
```

#### Deep Stone (500-1000m)
```
Primary:    #616161 (med gray)
Secondary:  #455A64 (blue-gray)
Accent:     #78909C (steel)
Background: #263238 (dark blue-gray)
```

#### Crystal Caves (1000-2000m)
```
Primary:    #7E57C2 (purple)
Secondary:  #5C6BC0 (indigo)
Accent:     #E1BEE7 (light purple)
Background: #311B92 (deep purple)
Glow:       #B388FF (soft purple glow)
```

#### Magma Zone (2000-5000m)
```
Primary:    #424242 (dark rock)
Secondary:  #BF360C (burnt orange)
Accent:     #FF5722 (orange)
Background: #1A1A1A (near black)
Lava:       #FF6D00 (bright orange)
Emissive:   #FFAB00 (yellow glow)
```

#### Void Depths (5000m+)
```
Primary:    #1A1A2E (deep navy)
Secondary:  #16213E (dark blue)
Accent:     #0F3460 (midnight)
Background: #0A0A0F (near black)
Glow:       #E94560 (alien pink)
Particles:  #533483 (void purple)
```

---

## Ore & Gem Colors

### Visibility Principle
Ores must POP against layer backgrounds.

| Ore | Color | Glow | Rarity |
|-----|-------|------|--------|
| Coal | #1C1C1C | None | Common |
| Copper | #B87333 | Subtle | Common |
| Iron | #A19D94 | None | Uncommon |
| Silver | #C0C0C0 | Soft white | Uncommon |
| Gold | #FFD700 | Yellow | Rare |
| Emerald | #50C878 | Green | Rare |
| Ruby | #E0115F | Red | Very Rare |
| Sapphire | #0F52BA | Blue | Very Rare |
| Diamond | #B9F2FF | White sparkle | Legendary |
| Mythril | #4169E1 | Blue pulse | Legendary |
| Void Crystal | #8A2BE2 | Purple pulse | Mythical |

### Rarity Border System
```
Common:     No border
Uncommon:   Thin gray border
Rare:       Blue border
Very Rare:  Purple border
Legendary:  Orange/gold border
Mythical:   Animated rainbow border
```

---

## Character Design

### Player Miner

#### Base Design
- Squat, friendly proportions
- Hardhat with light
- Work clothes
- Expressive face (2-3 frames idle)
- Clear silhouette

#### Animation Frames
| Animation | Frames | Loop |
|-----------|--------|------|
| Idle | 4 | Yes |
| Walk | 6 | Yes |
| Dig (side) | 4 | No |
| Dig (down) | 4 | No |
| Jump | 3 | No |
| Fall | 2 | Yes |
| Climb | 4 | Yes |
| Hurt | 2 | No |

#### Skin Variations
Different skins = different color palettes + accessories
- Classic: Blue overalls, brown hat
- Space: White suit, helmet
- Viking: Fur, horned helmet
- Robot: Metal plating, visor

---

## Building Design

### Style: Western Mining Town
- Wood and stone construction
- Hand-painted signs
- Warm lantern lighting
- Weathered but charming

### Building Sizes
- Small: 32x48 (2x3 tiles)
- Medium: 48x48 (3x3 tiles)
- Large: 64x64 (4x4 tiles)

### Visual Upgrade Tiers
```
Tier 1: Wooden shack, simple
Tier 2: Stone foundation added
Tier 3: Two stories, sign
Tier 4: Decorated, awning
Tier 5: Grand, multiple lights
```

---

## UI Style

### Philosophy
- Clean, readable
- Consistent with game aesthetic
- Large touch targets (min 44x44 logical pixels)
- High contrast for outdoor visibility

### UI Color Scheme
```
Background:     #2D2D2D (dark gray)
Panel:          #3D3D3D (medium gray)
Text Primary:   #FFFFFF (white)
Text Secondary: #B0B0B0 (light gray)
Accent:         #FFD700 (gold)
Positive:       #4CAF50 (green)
Negative:       #F44336 (red)
Button:         #5D4037 (brown)
Button Hover:   #795548 (light brown)
```

### Button Style
```
┌─────────────────┐
│   UPGRADE $500  │  <- Gold text for cost
│   [PICKAXE]     │  <- Icon + text
└─────────────────┘
- Rounded corners (4px)
- Subtle shadow
- Press state: darker + smaller
```

### Font Recommendations
- Headers: Pixel font (8-bit style)
- Body: Clean sans-serif (readable)
- Numbers: Monospace (alignment)

---

## Effects & Polish

### Particles

#### Block Break
- 8-12 small squares
- Match block color
- Gravity affected
- 0.3s lifetime

#### Ore Pickup
- Star burst pattern
- Match ore color
- Float upward
- 0.5s lifetime

#### Gem Sparkle
- Idle sparkle on gems
- 4-point star shapes
- Subtle, not distracting
- Random timing

### Lighting

#### Surface
- Bright, natural daylight
- Soft shadows under buildings
- Golden hour warmth (optional)

#### Underground
- Helmet light cone
- Darkness fog at edges
- Torch/lantern pools
- Ore glow in dark areas

#### Layer Ambient
- Each layer has ambient color
- Affects all sprites subtly
- Creates mood/atmosphere

---

## Animation Principles

### Squash & Stretch
- Landing: 20% squash
- Jumping: 15% stretch
- Mining: Follow-through

### Anticipation
- Wind-up before dig swing
- Crouch before jump
- Slight delay on big actions

### Timing
- Snappy, responsive
- No floaty movement
- Clear start/end poses

---

## Asset Pipeline

### Tools
- Aseprite (pixel art)
- Piskel (web alternative)
- TexturePacker (sprite sheets)

### Organization
```
assets/
├── sprites/
│   ├── player/
│   │   ├── idle.png
│   │   ├── walk.png
│   │   └── ...
│   ├── tiles/
│   │   ├── topsoil.png
│   │   ├── stone.png
│   │   └── ...
│   ├── ores/
│   ├── buildings/
│   └── ui/
├── fonts/
└── audio/
```

### Naming Convention
`category_name_variant_frame.png`
- `player_idle_classic_01.png`
- `tile_stone_cracked.png`
- `ore_gold_glow.png`

---

## Reference Games (Visual)

### SteamWorld Dig
- Warm colors, charming
- Clear readability
- Expressive characters

### Spelunky
- Clean pixel art
- Good tile variety
- Readable in motion

### Forager
- Bright, cheerful
- Excellent UI clarity
- Satisfying effects

---

## Questions to Resolve
- [x] Tile resolution → 16x16 pixels confirmed
- [x] Day/night palette → v1.1+ cosmetic feature
- [x] Idle animation → 4 frames, subtle breathing
- [x] Glow effects → Simple sprite overlay, no shaders
- [x] Parallax layers → 4 (sky, clouds, mountains, hills)

## Priority Checklist

### MVP Art
1. Player walk/idle/dig animations
2. 4 basic tile types (dirt, clay, stone, granite)
3. 5 ore sprites
4. Basic UI elements
5. Mine entrance building

### v1.0 Art
1. All layer tile types
2. All ore/gem sprites
3. All building sprites (5 tiers each)
4. Full player animation set
5. Particle effects
6. Polished UI

### v1.1+ Art
1. Cosmetic skins
2. Weather effects
3. Advanced particles
4. Seasonal themes?
