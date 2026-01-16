# Sound Design Philosophy - Detailed

## Audio Pillars

### 1. Material Identity
Every material sounds distinct. Players learn to recognize materials by ear.

### 2. Depth Atmosphere
Audio changes with depth to reinforce progression and create mood.

### 3. Satisfying Feedback
Every action has responsive, punchy audio feedback.

### 4. Mobile Considerations
Audio must work with phone speakers and respect battery/data.

---

## Sound Effects (SFX)

### Digging Sounds

#### By Material Type
| Material | Sound Character | Pitch | Duration |
|----------|----------------|-------|----------|
| Dirt | Soft thud, earthy | Low | Short |
| Clay | Wet squelch | Mid-low | Short |
| Stone | Hard crack, chip | Mid | Medium |
| Granite | Deep crunch | Low | Medium |
| Obsidian | Glass-like ring | High | Medium |
| Crystal | Chime, sparkle | High | Long |
| Magma Rock | Sizzle + crack | Mid | Medium |

#### Implementation
```gdscript
# audio_manager.gd
var dig_sounds = {
    "dirt": [
        preload("res://assets/audio/sfx/dig_dirt_01.wav"),
        preload("res://assets/audio/sfx/dig_dirt_02.wav"),
        preload("res://assets/audio/sfx/dig_dirt_03.wav"),
    ],
    "stone": [...],
    # etc
}

func play_dig_sound(material: String):
    var sounds = dig_sounds.get(material, dig_sounds["dirt"])
    var sound = sounds[randi() % sounds.size()]

    var player = get_available_sfx_player()
    player.stream = sound
    player.pitch_scale = randf_range(0.9, 1.1)
    player.volume_db = randf_range(-3, 0)
    player.play()
```

### Resource Collection

#### Pickup Sounds
| Resource | Sound | Notes |
|----------|-------|-------|
| Common ore | Soft clink | Brief |
| Uncommon ore | Medium clink | Slightly longer |
| Rare ore | Bright chime | Reverb tail |
| Gem | Crystal ring | Sparkle overlay |
| Legendary | Musical flourish | Memorable |

#### Combo System
Consecutive pickups increase pitch slightly:
```gdscript
var pickup_pitch_base = 1.0
var pickup_combo = 0
var combo_reset_time = 1.0

func play_pickup_sound(rarity: String):
    pickup_combo += 1
    var pitch = pickup_pitch_base + (pickup_combo * 0.05)
    pitch = min(pitch, 1.5)  # Cap at 1.5x

    # Play with calculated pitch
    play_sfx("pickup_" + rarity, pitch)

    # Reset combo after delay
    get_tree().create_timer(combo_reset_time).timeout.connect(
        func(): pickup_combo = 0
    )
```

### Movement Sounds

| Action | Sound |
|--------|-------|
| Footstep | Soft tap, varies by surface |
| Jump | Whoosh + effort grunt |
| Land | Thud, heavier with height |
| Wall-jump | Quick scrape + jump |
| Climb ladder | Wooden rungs |

### UI Sounds

| Action | Sound | Character |
|--------|-------|-----------|
| Button press | Click | Responsive |
| Menu open | Swoosh | Smooth |
| Purchase | Coin jingle | Satisfying |
| Upgrade | Level-up fanfare | Celebratory |
| Error | Soft buzz | Non-jarring |
| Notification | Gentle chime | Attention |

---

## Music

### Philosophy
- Non-intrusive, supports gameplay
- Loops seamlessly
- Changes with context (depth, action)

### Tracks Needed

#### Surface Theme
- Mood: Hopeful, adventurous
- Tempo: Medium (100-120 BPM)
- Instruments: Acoustic guitar, light percussion
- Duration: 2-3 minute loop

#### Underground Ambient (By Layer)

| Layer | Mood | Elements |
|-------|------|----------|
| Topsoil | Curious, safe | Light melody, soft pads |
| Stone | Mysterious | Deeper tones, echoes |
| Deep Stone | Tense, exciting | Darker, more percussive |
| Crystal | Wonder, beauty | Ethereal, chimes |
| Magma | Dangerous, epic | Dramatic, drums |
| Void | Alien, unknown | Abstract, unsettling |

#### Dynamic Music System (v1.1+)
```gdscript
# music_manager.gd
func update_music_for_depth(depth: int):
    var layer = get_layer_at_depth(depth)
    var target_track = layer_music[layer]

    if current_track != target_track:
        crossfade_to(target_track, 2.0)  # 2 second crossfade
```

### Shop Music
- Each shop could have subtle variation
- Or single "town" theme for all shops
- Brighter, warmer than underground

---

## Ambient Sounds

### By Layer

#### Surface
- Birds chirping
- Wind rustling
- Distant town sounds

#### Topsoil (0-200m)
- Dirt settling
- Occasional rock fall
- Muffled surface sounds

#### Stone (200-500m)
- Dripping water
- Echo on movements
- Stone creaking

#### Deep Stone (500-1000m)
- Rumbles
- Distant lava flows
- Pressure sounds

#### Crystal (1000-2000m)
- Crystal resonance
- Magical hums
- Wind-like tones

#### Magma (2000m+)
- Constant lava flow
- Hissing, bubbling
- Heat shimmer sounds

### Implementation
```gdscript
# ambient_manager.gd
func update_ambient(depth: int):
    var layer = get_layer_at_depth(depth)

    # Crossfade ambient loops
    if current_ambient_layer != layer:
        fade_out_ambient(current_ambient_layer)
        fade_in_ambient(layer)
        current_ambient_layer = layer

    # Adjust reverb based on depth
    var reverb_amount = clamp(depth / 1000.0, 0.0, 0.8)
    AudioServer.set_bus_effect_enabled(sfx_bus, reverb_index, true)
    reverb_effect.room_size = 0.2 + reverb_amount * 0.6
```

---

## Technical Implementation

### Audio Bus Structure
```
Master
├── Music (adjustable)
├── SFX (adjustable)
│   ├── Dig
│   ├── Pickup
│   ├── UI
│   └── Environment
└── Ambient (adjustable)
```

### Mobile Optimization

#### File Formats
- Short SFX: WAV (fast load, small)
- Music loops: OGG (compressed, streaming)
- Ambient: OGG (compressed)

#### Channel Limits
```gdscript
const MAX_SIMULTANEOUS_SFX = 8
const MAX_MUSIC_CHANNELS = 2  # For crossfade
const MAX_AMBIENT_CHANNELS = 3

# Pool SFX players
var sfx_pool: Array[AudioStreamPlayer] = []

func _ready():
    for i in range(MAX_SIMULTANEOUS_SFX):
        var player = AudioStreamPlayer.new()
        player.bus = "SFX"
        add_child(player)
        sfx_pool.append(player)
```

#### Volume Settings
- Default volumes appropriate for phone speakers
- Settings for Music/SFX/Ambient individual control
- Master volume option

---

## Haptic Feedback (Mobile)

### When to Vibrate
| Event | Vibration |
|-------|-----------|
| Block break | 10ms pulse |
| Ore pickup | 15ms pulse |
| Rare find | 25ms double pulse |
| Upgrade purchase | 30ms pulse |
| Damage taken | 40ms buzz |

### Implementation
```gdscript
func haptic_light():
    if settings.haptics_enabled and OS.has_feature("mobile"):
        Input.vibrate_handheld(10)

func haptic_heavy():
    if settings.haptics_enabled and OS.has_feature("mobile"):
        Input.vibrate_handheld(40)
```

---

## Audio Settings

### Player Controls
- Master Volume: 0-100%
- Music Volume: 0-100%
- SFX Volume: 0-100%
- Ambient Volume: 0-100%
- Haptics: On/Off

### Defaults
```gdscript
var audio_settings = {
    "master": 0.8,
    "music": 0.6,
    "sfx": 1.0,
    "ambient": 0.5,
    "haptics": true
}
```

---

## Asset List

### MVP Audio Needs
- [x] MVP dig sounds → 3 per material, 4 materials = 12 total
- [x] Pickup sounds → 3 tiers (common, rare, legendary)
- [x] Jump/land → 2 sounds each
- [x] UI sounds → click, purchase, error, success
- [x] Surface music → 2-3 min loop, cheerful tone
- [x] Underground ambient → 1 looping track for MVP

### v1.0 Audio Needs
- [x] v1.0 dig sounds → 7 materials, 3 variations each
- [x] v1.0 layer music → 6 unique tracks by depth
- [x] v1.0 layer ambient → 6 atmospheric loops
- [x] Shop music → Shared upbeat loop for all shops
- [ ] Achievement fanfare
- [ ] More UI sounds

### Audio Sources
- **Royalty-free**: Freesound.org, OpenGameArt
- **Generated**: BFXR, Chiptone (SFX)
- **Commission**: Fiverr, freelance composers
- **AI-generated**: Careful with licensing

---

## Questions Resolved
- [x] Material-based sound design? **Yes**
- [x] Dynamic music by depth? **Yes (v1.1+)**
- [x] Ambient sound layers? **Yes**
- [x] Haptic feedback? **Yes, optional**
- [x] Audio file formats? **WAV (SFX), OGG (music/ambient)**
