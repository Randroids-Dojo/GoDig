# Audio & Sound Design Research

## Sources
- [Mining Game Sound Design Principles](https://gameaccessibilityguidelines.com/sound-design/)
- [Godot 4 Audio Bus System](https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html)
- [Mobile Audio Best Practices](https://developer.android.com/games/optimize/audio)

## Sound Categories

### 1. Mining & Digging Sounds

**Block Break Sounds**
Each material type needs distinct audio:
| Material | Sound Character |
|----------|-----------------|
| Dirt | Soft thud, crumbly |
| Clay | Wet squelch, dense |
| Stone | Hard crack, chip sounds |
| Granite | Deep resonant crack |
| Obsidian | Glassy shatter |
| Ore | Metallic ring + base material |

**Implementation Pattern**
```gdscript
# audio_manager.gd
const BLOCK_SOUNDS = {
    BlockType.DIRT: [
        preload("res://assets/audio/sfx/dig_dirt_1.wav"),
        preload("res://assets/audio/sfx/dig_dirt_2.wav"),
        preload("res://assets/audio/sfx/dig_dirt_3.wav"),
    ],
    BlockType.STONE: [
        preload("res://assets/audio/sfx/dig_stone_1.wav"),
        preload("res://assets/audio/sfx/dig_stone_2.wav"),
    ],
}

func play_dig_sound(block_type: BlockType):
    var sounds = BLOCK_SOUNDS.get(block_type, BLOCK_SOUNDS[BlockType.DIRT])
    var sound = sounds[randi() % sounds.size()]
    sfx_player.stream = sound
    sfx_player.pitch_scale = randf_range(0.9, 1.1)  # Slight variation
    sfx_player.play()
```

**Pickaxe Swing Sound**
- Whoosh sound on each swing
- Pitch varies slightly with tool tier
- Better tools = more satisfying impact sound

### 2. Pickup & Collection Sounds

**Resource Pickup**
| Resource Tier | Sound Character |
|---------------|-----------------|
| Common (coal, copper) | Subtle clink |
| Uncommon (iron) | Medium chime |
| Rare (silver, gold) | Bright sparkle |
| Epic (diamond) | Musical flourish |
| Legendary | Full chord + sparkle |

**Sound Stacking**
When picking up multiple items rapidly:
- Don't overlap identical sounds
- Use pitch shifting for rapid pickups
- Consider "combo" sound for streaks

```gdscript
var last_pickup_time: float = 0
var pickup_combo: int = 0

func play_pickup_sound(item_tier: int):
    var now = Time.get_ticks_msec() / 1000.0
    if now - last_pickup_time < 0.3:
        pickup_combo += 1
    else:
        pickup_combo = 0

    last_pickup_time = now

    var base_pitch = 1.0 + (pickup_combo * 0.05)  # Rising pitch for combos
    base_pitch = min(base_pitch, 1.5)  # Cap it

    sfx_player.pitch_scale = base_pitch
    sfx_player.stream = PICKUP_SOUNDS[item_tier]
    sfx_player.play()
```

### 3. UI & Menu Sounds

**Essential UI Sounds**
- Button hover (subtle)
- Button click (satisfying click)
- Tab switch (soft whoosh)
- Menu open/close (swoosh)
- Purchase success (ka-ching!)
- Purchase fail (error buzz)
- Upgrade complete (fanfare)
- Inventory full (warning tone)

**Mobile Considerations**
- UI sounds should be short (<0.3s)
- No jarring or loud UI sounds
- Haptic feedback can replace some sounds

### 4. Ambient & Environmental

**Depth-Based Ambient**
| Depth Zone | Ambient Character |
|------------|-------------------|
| Surface | Birds, wind, daylight sounds |
| Shallow (0-100m) | Dripping water, distant rumbles |
| Medium (100-500m) | Cave echoes, rock settling |
| Deep (500-1000m) | Ominous hum, pressure sounds |
| Abyss (1000m+) | Eerie silence, rare distant sounds |

**Implementation**
```gdscript
# ambient_manager.gd
var ambient_tracks = {
    "surface": preload("res://assets/audio/ambient/surface_loop.ogg"),
    "shallow": preload("res://assets/audio/ambient/shallow_loop.ogg"),
    "medium": preload("res://assets/audio/ambient/medium_loop.ogg"),
    "deep": preload("res://assets/audio/ambient/deep_loop.ogg"),
    "abyss": preload("res://assets/audio/ambient/abyss_loop.ogg"),
}

func update_ambient(depth: float):
    var zone = get_depth_zone(depth)
    if zone != current_zone:
        crossfade_to(ambient_tracks[zone])
        current_zone = zone
```

### 5. Background Music

**Music Strategy Options**

**Option A: Depth-Layered Music**
- Same base track throughout
- Layers added/removed based on depth
- Creates seamless transitions
- Complex to implement well

**Option B: Zone-Based Tracks**
- Different track per depth zone
- Crossfade between zones
- Easier to create variety
- Potential for jarring transitions

**Option C: Minimal/Ambient Only**
- No traditional music
- Rich ambient soundscape
- Lets SFX shine
- May feel empty to some players

**Recommended: Hybrid Approach**
- Light ambient music at surface
- Ambient-only underground (focus on atmosphere)
- Music swells for discoveries/achievements
- Player can toggle music on/off

### 6. Event & Feedback Sounds

**Achievement/Milestone**
- Depth milestones: Triumphant brass stinger
- New ore discovered: Magical discovery chime
- Upgrade purchased: Satisfying cha-ching

**Warning Sounds**
- Low health: Heartbeat + warning tone
- Inventory nearly full: Subtle reminder
- Deep zone warning: Environmental cue

**Discovery Sounds**
- Rare ore nearby: Subtle sparkle/twinkle
- Cave entrance: Echoey wind
- Artifact found: Ancient mystical sound

## Audio Bus Structure

```
Master
├── Music (separate volume control)
├── SFX
│   ├── Dig (frequent, needs limiting)
│   ├── Pickup
│   ├── UI
│   └── Environment
└── Ambient
```

### Volume Control
```gdscript
# settings_manager.gd
func set_master_volume(value: float):
    AudioServer.set_bus_volume_db(0, linear_to_db(value))

func set_music_volume(value: float):
    var bus_idx = AudioServer.get_bus_index("Music")
    AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))

func set_sfx_volume(value: float):
    var bus_idx = AudioServer.get_bus_index("SFX")
    AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
```

## Mobile-Specific Considerations

### Audio Polyphony Limits
- Mobile devices handle fewer simultaneous sounds
- Limit concurrent dig sounds (max 2-3)
- Prioritize important sounds over ambient

### Audio Format Recommendations
- OGG Vorbis for music/ambient (compressed, loopable)
- WAV for short SFX (low latency)
- Keep individual files small for mobile

### Silence/Mute Handling
```gdscript
func _notification(what):
    match what:
        NOTIFICATION_APPLICATION_FOCUS_OUT:
            # Pause/mute when app backgrounded
            AudioServer.set_bus_mute(0, true)
        NOTIFICATION_APPLICATION_FOCUS_IN:
            AudioServer.set_bus_mute(0, false)
```

### Respect System Settings
- Check if device is in silent/vibrate mode
- Don't play sounds during phone calls
- Option to disable sound entirely

## Sound Asset Sources

### Free/CC Resources
- [Freesound.org](https://freesound.org) - Community sounds
- [OpenGameArt](https://opengameart.org) - Game-specific
- [Kenney Assets](https://kenney.nl/assets) - Consistent quality

### Paid Asset Packs
- Soniss GDC bundles (annual free releases)
- Epic asset packs
- AudioJungle

### Generation Tools
- [BFXR](https://www.bfxr.net/) - Retro SFX generator
- [ChipTone](https://sfbgames.itch.io/chiptone) - Chiptune sounds
- [LabChirp](https://labbed.itch.io/labchirp) - Sound effects

## Questions to Resolve
- [ ] Music during mining or ambient-only?
- [ ] Depth-layered music or zone tracks?
- [ ] Haptic feedback integration?
- [ ] Audio cues for nearby rare ores?
- [ ] Accessibility: visual alternatives for audio cues?
