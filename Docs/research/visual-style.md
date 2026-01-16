# Visual Style & Art Direction Research

## Sources
- [Pixel Art Mining Games](https://www.reddit.com/r/PixelArt/comments/mining/)
- [SteamWorld Dig Art Analysis](https://www.gamedeveloper.com/art/steamworld-dig-art-direction)
- [Mobile Game UI Best Practices](https://blog.prototypr.io/mobile-game-ui-patterns)

## Art Style Options

### Option A: Classic Pixel Art (16x16 / 32x32)
**Examples**: SteamWorld Dig, Terraria, Motherload

**Pros**:
- Nostalgic appeal
- Easier to create consistent assets
- Smaller file sizes (good for mobile)
- Timeless aesthetic
- Readable at small mobile screens

**Cons**:
- May look "dated" to casual players
- Limited detail per tile
- Requires skilled pixel artist for quality

### Option B: Modern HD 2D
**Examples**: Ori, Hollow Knight-lite

**Pros**:
- Visually impressive
- Appeals to modern audience
- More detail and effects

**Cons**:
- Much larger asset workload
- Bigger file sizes
- May not suit mining game feel

### Option C: Stylized Vector/Flat
**Examples**: Alto's Adventure, Monument Valley

**Pros**:
- Clean, modern look
- Scales well to any resolution
- Easier color consistency

**Cons**:
- Less "game-y" feel
- May not convey mining texture well
- Less industry precedent for genre

### Recommendation: Pixel Art (16x16 tiles)
- Matches genre expectations
- Readable on mobile screens
- Manageable asset creation scope
- Allows detailed animation within constraints

## Color Palette Strategy

### Layer-Based Color Themes

**Surface/Sky**
```
Primary: Sky blue #87CEEB
Secondary: Grass green #7CFC00
Accent: Sun yellow #FFD700
```

**Dirt Layer (0-100m)**
```
Primary: Brown #8B4513
Secondary: Tan #D2B48C
Accent: Root brown #654321
```

**Stone Layer (100-300m)**
```
Primary: Gray #808080
Secondary: Dark gray #696969
Accent: Blue-gray #708090
```

**Granite Layer (300-600m)**
```
Primary: Pink-gray #BC8F8F
Secondary: Dark red-brown #8B0000
Accent: Quartz white #F5F5F5
```

**Deep Stone (600-1000m)**
```
Primary: Dark blue-gray #2F4F4F
Secondary: Near-black #1C1C1C
Accent: Crystal blue #00CED1
```

**Magma Zone (1000m+)**
```
Primary: Obsidian black #1A1A1A
Secondary: Magma orange #FF4500
Accent: Ember red #FF6347
```

### Ore Color Coding
Ores should "pop" against their background:
| Ore | Color | Visual Treatment |
|-----|-------|------------------|
| Coal | Dark gray/black | Matte, subtle |
| Copper | Orange-brown | Slight metallic sheen |
| Iron | Silver-gray | Metallic |
| Silver | Bright silver | Strong shine effect |
| Gold | Yellow-gold | Sparkle particles |
| Diamond | Light blue | Prismatic sparkle |
| Ruby | Deep red | Gem glow |
| Emerald | Bright green | Gem glow |

## Visual Clarity for Mobile

### Readability Rules
1. **High contrast** between player and background
2. **Clear silhouettes** - player and ores visible at glance
3. **16x16 minimum** for important objects
4. **Bold outlines** on interactive elements

### Player Visual Design
- Distinct silhouette (helmet + pickaxe)
- Bright colors against dark underground
- Clear animation states (idle, walk, dig, climb)
- 4-8 frames per animation for smooth feel

### Tile Visibility
```
Good: High contrast ore against stone
Bad: Similar-colored ore blends in

Solution: Add bright outline/glow to valuable tiles
```

## Fantasy vs Realistic Aesthetic

### Fantasy Approach
- Glowing gems and crystals
- Magical effects on rare items
- Stylized, vibrant colors
- Unrealistic but fun

### Realistic Approach
- Muted, natural colors
- Geological accuracy
- Industrial/mining town surface
- Grounded but may be dull

### Recommended: Fantasy-Lite
- Real-world ores and gems
- Slightly magical visual effects
- Vibrant but not garish
- "Stylized realism"

## UI Visual Design

### Mobile UI Principles
1. **Large touch targets** (44px minimum)
2. **High contrast text** on all backgrounds
3. **Consistent button styles**
4. **Clear visual hierarchy**
5. **Readable fonts** (sans-serif for mobile)

### HUD Layout (Portrait)
```
┌─────────────────────────┐
│  [Coins]    [Depth]     │  <- Status bar
│                         │
│                         │
│                         │
│     GAME WORLD          │
│                         │
│                         │
│                         │
│ [Inv]            [Menu] │  <- Quick buttons
│    ┌───────────────┐    │
│    │   JOYSTICK    │[J] │  <- Controls
│    └───────────────┘[D] │
└─────────────────────────┘
```

### Visual Feedback
- Damage: Screen flash red
- Pickup: Item icon floats up
- Upgrade: Particle burst
- Low health: Vignette effect

## Lighting System

### Depth-Based Darkness
```gdscript
# Visibility decreases with depth
func calculate_light_level(depth: float) -> float:
    var surface_light = 1.0
    var min_light = 0.2  # Never fully dark (gameplay)
    var darkness_rate = 0.001  # How fast it gets dark

    return max(min_light, surface_light - (depth * darkness_rate))
```

### Light Sources
- **Helmet lamp**: Player-centered light
- **Torches**: Placeable static lights
- **Gems**: Emit subtle glow
- **Lava**: Bright ambient light in deep zones

### Godot 2D Lighting
```gdscript
# PointLight2D for player helmet
var helmet_light: PointLight2D

func _ready():
    helmet_light = PointLight2D.new()
    helmet_light.texture = preload("res://assets/light_texture.png")
    helmet_light.energy = 1.5
    helmet_light.range_z_max = 100
    add_child(helmet_light)
```

## Animation Guidelines

### Player Animations
| State | Frames | Loop |
|-------|--------|------|
| Idle | 4 | Yes |
| Walk | 6 | Yes |
| Jump | 3 | No |
| Fall | 2 | Yes |
| Dig | 4 | No |
| Climb | 4 | Yes |
| Wall slide | 2 | Yes |

### Environmental Animations
- Water drips (2-3 frames)
- Torch flicker (3 frames)
- Gem sparkle (4 frames)
- Grass sway (3 frames)

### Particle Effects
- Dig: Small dirt/stone chunks
- Pickup: Sparkle trail to player
- Damage: Red flash + shake
- Level up: Radial burst

## Asset Pipeline

### Recommended Tools
- **Aseprite**: Industry-standard pixel art
- **Piskel**: Free browser-based alternative
- **GraphicsGale**: Free, Windows-only

### File Organization
```
assets/
├── sprites/
│   ├── player/
│   │   ├── idle.png
│   │   ├── walk.png
│   │   └── dig.png
│   ├── tiles/
│   │   ├── dirt_tileset.png
│   │   ├── stone_tileset.png
│   │   └── ores/
│   ├── ui/
│   │   ├── buttons/
│   │   ├── icons/
│   │   └── frames/
│   └── effects/
│       └── particles/
└── fonts/
```

### Tile Atlas Best Practices
- Power-of-2 dimensions (256x256, 512x512)
- Consistent tile padding (1px)
- Group related tiles together
- Include variants for visual variety

## Questions to Resolve
- [ ] 16x16 or 32x32 base tile size?
- [ ] Fantasy glow effects or realistic?
- [ ] Dynamic lighting or baked shadows?
- [ ] How many animation frames per action?
- [ ] Custom font or system font?
