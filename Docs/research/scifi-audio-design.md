# SciFi Audio Design Direction

**Status:** Research Complete
**Last Updated:** 2026-01-24
**Theme:** Futuristic Alien Planet Mining / Robotic Technology
**Context:** Audio companion to SCIFI_REDESIGN_PLAN.md

---

## Executive Summary

This document defines the audio design direction for GoDig's transformation from an earthy mining game to a futuristic SciFi mining experience. The player controls DIGBOT-7, an excavation unit deployed by Helios Industries on the alien planet Kepler-442b. All audio must reinforce this narrative through synthesized, mechanical, and otherworldly soundscapes.

---

## Audio Identity Pillars

### 1. Mechanical Precision
Every sound the player's robot makes should feel manufactured, precise, and engineered. Servos, hydraulics, and electronic hums.

### 2. Alien Atmosphere
The environment is not Earth. Ambience should feel foreign, mysterious, and slightly unsettling.

### 3. High-Tech Interface
UI and feedback sounds should evoke holographic displays, data processing, and advanced technology.

### 4. Satisfying Power
Mining sounds should feel powerful and futuristic - lasers, plasma, and energy weapons rather than metal striking stone.

### 5. Mobile-First Design
All audio optimized for phone speakers, small file sizes, and battery efficiency.

---

## 1. Mining/Drilling Sound Effects

### Sonic Aesthetic
**Primary:** Synthesized energy weapons, electric pulses, laser hums
**Secondary:** Mechanical servo whirs, pneumatic releases
**Tertiary:** Crystalline fracturing, alien mineral resonance

### Laser/Plasma Drilling Sounds (Replacing Pickaxe)

| Drill Action | Sound Description | Duration | Reference |
|--------------|-------------------|----------|-----------|
| Drill Start | Electric wind-up, capacitor charge | 0.1-0.2s | Lightsaber ignition (short) |
| Drill Loop | Sustained energy hum with warble | Looping | Dead Space plasma cutter |
| Drill Impact | Electrical crackle + material hit | 0.1s | Half-Life gravity gun |
| Drill End | Power-down whine, discharge | 0.2s | Shield deactivation |

#### Drill Tier Variations
```
Tier 1 (Basic Laser):    Low buzz, simple tone
Tier 2 (Plasma Drill):   Richer harmonic, slight distortion
Tier 3 (Quantum Cutter): High-pitched resonance, crystal-clear
Tier 4 (Void Beam):      Deep bass undertone, otherworldly warble
```

### Block Break Sounds by Material

| Material | SciFi Name | Sound Character | Reference |
|----------|------------|-----------------|-----------|
| Regolith (Dirt) | Alien Dust | Compressed air burst + granular scatter | Mars Rover sample collection |
| Substrate (Clay) | Compressed Ore | Dense crunch with electronic fizz | Star Trek phaser rock destruction |
| Xenolite (Stone) | Crystal Matrix | Crystalline shatter with reverb tail | Mass Effect mineral collection |
| Core Mantle | Volcanic Core | Deep crack + energy release + bass rumble | Doom eternal rock impacts |
| Bedrock | Quantum Barrier | Impossible density, glitched audio stutter | Subnautica precursor materials |

#### Implementation Pattern
```gdscript
# Layered drilling sound system
const DRILL_SOUNDS = {
    "regolith": {
        "impact": preload("res://assets/audio/sfx/drill_regolith_impact.wav"),
        "break": preload("res://assets/audio/sfx/drill_regolith_break.wav"),
        "debris": preload("res://assets/audio/sfx/debris_granular.wav"),
    },
    "xenolite": {
        "impact": preload("res://assets/audio/sfx/drill_xenolite_impact.wav"),
        "break": preload("res://assets/audio/sfx/drill_xenolite_break.wav"),
        "debris": preload("res://assets/audio/sfx/debris_crystal.wav"),
    },
}

func play_drill_sound(material: String, action: String):
    var sound = DRILL_SOUNDS[material][action]
    var player = get_sfx_player()
    player.stream = sound
    # Add slight pitch variation for organic feel
    player.pitch_scale = randf_range(0.95, 1.05)
    # Random volume variation
    player.volume_db = randf_range(-2, 0)
    player.play()
```

### Impact and Feedback Sounds

| Event | Sound | Timing | Notes |
|-------|-------|--------|-------|
| Hit confirmed | Short electrical pop | Immediate | Confirms contact |
| Progress tick | Subtle charge buildup | Per hit | Indicates drilling progress |
| Weak spot hit | Higher pitch chime | Immediate | Bonus damage indicator |
| Resistance | Lower buzz, strain | While drilling | Hard material warning |
| Critical break | Energy discharge + shatter | On block break | Satisfying payoff |

### Sound Design Notes
- **Layered approach:** Each mining action plays 2-3 short sounds simultaneously (impact + material + debris)
- **Pitch progression:** Consecutive hits increase pitch slightly (1.0 to 1.15 max) for rhythmic satisfaction
- **Stereo positioning:** Left/right drilling pans audio subtly

### Reference Games/Films
- **Dead Space:** Plasma cutter sounds, industrial sci-fi
- **Doom Eternal:** Impactful weapon feedback
- **Mass Effect 2:** Mineral scanning/collection sounds
- **Star Wars (Lightsaber):** Energy weapon ignition/loop

### Asset Creation Approach
| Method | Use For | Rationale |
|--------|---------|-----------|
| AI Generation (ElevenLabs SFX) | Base layers, variations | Fast iteration, unique sounds |
| Sound Libraries (Sonniss, Boom) | Electric/laser bases | Professional quality |
| Synthesis (Vital, Serum) | UI tones, energy hums | Total control, tiny file size |
| Recording + Processing | Mechanical servos | Unique identity |

---

## 2. UI Feedback Sounds

### Sonic Aesthetic
**Primary:** Clean digital tones, holographic interface sounds
**Secondary:** Soft confirmation beeps, data processing
**Tertiary:** Subtle mechanical clicks (for tactile elements)

### Design Philosophy
- Short, crisp, non-fatiguing
- Consistent tonal palette (all UI sounds share key/scale)
- Holographic "glass touch" quality
- Avoid harsh beeps or alarms for common actions

### Button Presses (Holographic Feel)

| Button Type | Sound | Duration | Pitch |
|-------------|-------|----------|-------|
| Primary action | Glass tap + soft chime | 0.08s | C5 (523 Hz) |
| Secondary action | Light click + release | 0.06s | E5 (659 Hz) |
| Cancel/Back | Descending two-tone | 0.1s | G4-E4 |
| Disabled/Error | Muted buzz + low tone | 0.12s | A3 (220 Hz) |
| Toggle On | Rising chime + click | 0.1s | C5-E5 |
| Toggle Off | Falling tone + click | 0.1s | E5-C5 |

#### Holographic Touch Characteristics
```
- Attack: Near-instant (5-10ms)
- Body: Short sine wave with slight filter sweep
- Release: Quick decay, no reverb
- Layering: Combine glass tap (noise) with clean tone
```

### Menu Transitions

| Transition | Sound | Duration | Description |
|------------|-------|----------|-------------|
| Menu Open | Data unfold | 0.2-0.3s | Rising harmonics, hologram materialize |
| Menu Close | Data collapse | 0.15s | Quick descending, de-materialize |
| Tab Switch | Soft swoosh | 0.1s | Horizontal movement feel |
| Panel Slide | Hydraulic whisper | 0.15s | Mechanical sliding door |
| Popup Appear | Notification ping | 0.08s | Attention-getting but pleasant |
| Loading Start | Soft drone begin | 0.2s | Processing initiation |
| Loading Complete | Resolution chime | 0.15s | Satisfying completion |

### Notifications and Alerts

| Alert Level | Sound | Characteristics | Use Case |
|-------------|-------|-----------------|----------|
| Info | Soft ping | Pleasant, ignorable | Passive notifications |
| Success | Rising major chord | Satisfying, brief | Purchase complete, save complete |
| Warning | Attention tone | Noticeable, not alarming | Inventory nearly full |
| Error | Low buzz + tone | Distinct but not harsh | Insufficient credits |
| Critical | Pulsing alert | Urgent, repeating | Low hull integrity |
| Achievement | Fanfare flourish | Celebratory, 1-2s | Milestones, unlocks |

#### Alert Sound Design
```gdscript
# Example: Warning sound with urgency scaling
func play_alert(level: String, urgency: float = 1.0):
    var sound = ALERT_SOUNDS[level]
    var player = get_ui_player()
    player.stream = sound
    player.pitch_scale = lerp(0.9, 1.1, urgency)  # Higher pitch = more urgent
    player.play()
```

### Inventory/Equipment Sounds

| Action | Sound | Description |
|--------|-------|-------------|
| Item Equip | Magnetic lock + power-up | Click into place, systems online |
| Item Unequip | Magnetic release | Quick unlock sound |
| Module Install | Servo + confirmation | Mechanical attachment + data chime |
| Cargo Bay Open | Airlock hiss | Decompression, hydraulic |
| Slot Hover | Subtle highlight | Very soft tone shift |
| Stack Combine | Merge sound | Quick blend/merge audio |
| Inventory Full | Rejection buzz | Container sealed, cannot add |

### Tonal Palette Reference
```
UI sounds use a consistent musical scale for cohesion:
Root: C (for primary actions)
Major 3rd: E (for positive feedback)
Perfect 5th: G (for confirmation)
Minor 2nd: Db (for errors/warnings)

All UI sounds: Sine/triangle waves with gentle filter sweeps
No harsh sawtooth or square waves for common UI
```

### Reference Games
- **Dead Space:** RIG interface sounds, holographic menus
- **Mass Effect:** Omni-tool interface, clean sci-fi UI
- **Destiny 2:** Director/menu transitions
- **Warframe:** Orbiter menu sounds

### Asset Creation Approach
| Method | Use For | Notes |
|--------|---------|-------|
| Synthesis (Pure) | All UI tones | Tiny file size, perfect control |
| Layered synthesis | Complex transitions | Combine simple elements |
| AI Generation | Menu whooshes | Natural-feeling movement |

---

## 3. Ambient Atmosphere

### Sonic Aesthetic
**Primary:** Alien environmental drones, otherworldly resonance
**Secondary:** Mechanical hums (player's suit/robot systems)
**Tertiary:** Distant mysterious sounds, weather phenomena

### Design Philosophy
- Create a sense of alien isolation
- Depth progression through audio (more intense/strange deeper)
- Subtle constant presence, never silent
- Support gameplay without distraction

### Underground Alien Environment

#### Depth-Based Ambient Zones

| Depth | Zone Name | Ambient Character | Key Elements |
|-------|-----------|-------------------|--------------|
| 0-200m | Regolith Layer | Settling dust, pressure | Granular settling, wind through cracks, suit hum |
| 200-500m | Substrate Zone | Dense, compressed | Distant groans, material stress, echoes |
| 500-1000m | Xenolite Caves | Crystal resonance | Harmonic tones, mineral singing, drips with reverb |
| 1000-2000m | Deep Xenolite | Otherworldly | Strange frequencies, alien "voices," energy hum |
| 2000m+ | Core Proximity | Intense, dangerous | Heat shimmer audio, pressure warning, lava flows |

#### Layer-Specific Sound Palettes

**Regolith Layer (0-200m)**
```
Base drone: Low filtered noise (40-60 Hz)
Textures:
  - Alien dust settling (granular synthesis)
  - Occasional rock shifts (processed impacts)
  - Wind through surface cracks (filtered white noise)
  - DIGBOT system hum (60 Hz electrical)
Mood: Isolation, beginning of descent
Reference: Alien (1979) ship interiors, quiet tension
```

**Substrate Zone (200-500m)**
```
Base drone: Sub-bass pulse (30-50 Hz, slow LFO)
Textures:
  - Compression sounds (hydraulic-like)
  - Distant rumbles (deep filtered impacts)
  - Echo on all sounds (medium reverb)
  - Pressure differential audio (ear-pressure simulation)
Mood: Weight, claustrophobia, depth awareness
Reference: Subnautica deep zones, pressure sounds
```

**Xenolite Caves (500-1000m)**
```
Base drone: Harmonic overtones (crystal bowl-like)
Textures:
  - Crystal resonance (sine wave clusters)
  - Mineral "singing" (random pitched tones)
  - Dripping (reverbed, musical)
  - Crystalline chimes (wind-triggered)
Mood: Wonder, beauty with danger
Reference: Journey (game) cavern sequences
```

**Deep Xenolite (1000-2000m)**
```
Base drone: Complex harmonic drone (shifting frequencies)
Textures:
  - Alien "breathing" sounds (processed organic)
  - Unknown origin sounds (reversed/pitch-shifted)
  - Energy field hum (oscillating)
  - Distant machinery? (industrial tones)
Mood: Unsettling, mysterious, not alone
Reference: Dead Space ambient, Annihilation film
```

**Core Proximity (2000m+)**
```
Base drone: Intense low rumble (20-40 Hz, modulated)
Textures:
  - Heat shimmer (high-frequency warble)
  - Magma flow (liquid fire processing)
  - Pressure warnings (intermittent tones)
  - System strain (electrical stress sounds)
Mood: Danger, intensity, endgame territory
Reference: Doom eternal hell sequences, volcanic documentaries
```

### Surface Alien Planet Sounds

#### Kepler-442b Surface Atmosphere
```
Time of Day: Perpetual alien twilight (dual sun system)

Base layer:
  - Alien wind (processed, not Earth-like)
  - Atmospheric resonance (low frequency hum)
  - Distant electrical storms (filtered thunder)

Textures:
  - Strange fauna hints (processed animal sounds)
  - Bioluminescent flora pulse (subtle synth pads)
  - Machinery from Helios base (industrial distant)
  - Crystal formations resonating (metallic wind chimes)

Mood: Hostile beauty, frontier isolation
Reference: No Man's Sky planets, Prometheus surface scenes
```

#### Surface vs Underground Transition
```gdscript
# Crossfade between surface and underground ambient
func update_ambient_for_position(depth: float):
    if depth < 0:  # Surface
        crossfade_to("surface_ambient", 1.5)
    elif depth < 200:
        var blend = depth / 200.0
        crossfade_blend("surface_ambient", "regolith_ambient", blend)
    elif depth < 500:
        var blend = (depth - 200) / 300.0
        crossfade_blend("regolith_ambient", "substrate_ambient", blend)
    # ... continue for deeper layers
```

### Environmental Hazard Warnings

| Hazard | Audio Warning | Timing |
|--------|---------------|--------|
| Magma Nearby | Rising heat hiss + warning pulse | Gradual, distance-based |
| Unstable Ground | Crackling, stress sounds | Before collapse |
| Radiation Zone | Geiger-counter clicks (alien variant) | Enters zone |
| Void Pocket | Reality-distortion audio | Proximity |
| Low Oxygen Zone | Breathing strain + alarm | Timed warning |
| Creature Nearby | Alien sound + alert tone | Detection radius |

### Implementation Notes
```
- All ambient loops: OGG format, seamless loop points
- Maximum 3 ambient layers playing simultaneously
- Use Godot AudioEffectReverb: adjustable by depth
- Distance-based sounds via AudioStreamPlayer2D
- Reverb increases with depth (0.2 surface to 0.8 deep)
```

### Reference Films/Games
- **Alien (1979):** Ship ambient, isolated tension
- **Subnautica:** Depth pressure, underwater alien life
- **Dead Space:** Industrial horror atmosphere
- **Annihilation:** Alien biology sounds
- **No Man's Sky:** Alien planet atmospheres

---

## 4. Resource Collection

### Sonic Aesthetic
**Primary:** Digital acquisition sounds, data processing
**Secondary:** Material-specific resonance (crystal, metal, energy)
**Tertiary:** Value-tier escalation (common to legendary)

### Design Philosophy
- Clear rarity communication through audio
- Combo/streak feedback for rapid collection
- Satisfying "got it" confirmation
- Subtle enough for frequent collection

### Ore Pickup Sounds by Rarity

| Rarity | SciFi Ore Example | Sound Character | Duration | Layer Count |
|--------|-------------------|-----------------|----------|-------------|
| Common | Carbon Nodules | Brief click + soft tone | 0.1s | 1 |
| Uncommon | Xenocopper, Ferrosteel | Clink + minor chime | 0.15s | 2 |
| Rare | Argentium, Aurium-7 | Bright chime + sparkle | 0.2s | 2-3 |
| Epic | Plasma Crystal | Rising chord + resonance | 0.3s | 3 |
| Legendary | Void Shard | Full flourish + bass | 0.5s | 3-4 |
| Artifact | Alien Technology | Unique musical motif | 0.6s | 4+ |

#### Sound Design Details

**Common (Carbon Nodules, Basic Ores)**
```
Components:
  - Quick digital "blip" (synthesized)
  - Subtle material clink (sample)
Pitch: Fixed (C5)
Volume: -6dB relative
No variation needed (frequently heard)
```

**Uncommon (Xenocopper, Ferrosteel)**
```
Components:
  - Digital acquisition tone
  - Short metallic ring (sample)
  - Subtle shimmer (synthesis)
Pitch: E5, slight random (0.98-1.02)
Volume: -4dB relative
```

**Rare (Argentium, Aurium-7)**
```
Components:
  - Rising two-note chime (synthesis)
  - Crystal sparkle (processed sample)
  - Soft pad swell (background)
Pitch: C5-G5 interval
Volume: -2dB relative
Includes 50ms reverb tail
```

**Epic (Plasma Crystal)**
```
Components:
  - Rising three-note arpeggio
  - Energy pulse (synthesized)
  - Harmonic sustain
  - Sparkle particle sounds
Pitch: C5-E5-G5 (major triad)
Volume: 0dB relative
Noticeable but not disruptive
```

**Legendary (Void Shard, Quantum Fragment)**
```
Components:
  - Full chord progression (2 chords)
  - Bass impact undernote
  - Sustained shimmer (2s tail)
  - Unique identifier (void = low warble, quantum = phase effect)
Pitch: Full chord voicing
Volume: +2dB relative
Should feel like an event
```

### Currency/Credit Sounds

| Action | Sound | Description |
|--------|-------|-------------|
| Earn Credits (small) | Digital tick | Quick credit increment |
| Earn Credits (large) | Credit cascade | Multiple ticks + chord |
| Spend Credits | Debit tone | Satisfying "transaction complete" |
| Insufficient Funds | Rejection buzz | Low tone + error |
| Credit Milestone | Achievement stinger | 1000, 10000, etc. |

#### Credit Sound Design
```
Credit tick: Short sine wave pulse (0.02s)
  - Frequency: 1000 Hz base
  - Multiple credits: Rapid succession with rising pitch
  - Creates "slot machine" satisfaction

Transaction complete: Confirmation chord
  - Notes: C4 + E4 + G4 (major)
  - Duration: 0.2s with soft release
```

### Level Up/Upgrade Sounds

| Upgrade Type | Sound Character | Duration | Notes |
|--------------|-----------------|----------|-------|
| Tool Upgrade | Power-up sequence | 0.5s | Increasing intensity |
| Backpack Expand | Container unlock | 0.3s | Hydraulic + confirmation |
| Module Install | Lock-in + systems online | 0.4s | Mechanical + digital |
| Skill Unlock | Achievement flourish | 0.6s | Celebratory, clear |
| Hull Upgrade | Armor power-up | 0.4s | Heavy, protective feel |

#### Upgrade Sound Structure
```
3-part structure:
  1. Initiation (0.1s) - Action beginning
  2. Processing (0.2-0.3s) - Upgrade happening
  3. Confirmation (0.1-0.2s) - Success indicator

Example: Tool Upgrade
  - Initiation: Servo engage + charge start
  - Processing: Rising energy buildup
  - Confirmation: Power lock + status chime
```

### Achievement/Milestone Sounds

| Milestone Type | Sound | Duration | Usage |
|----------------|-------|----------|-------|
| Depth Record | Triumphant brass stinger | 1.0s | First time reaching depth |
| Ore Discovery | Wonder chime | 0.6s | First time finding ore type |
| Collection Goal | Counter completion | 0.4s | X of Y collected |
| Speed Record | Racing flourish | 0.5s | Time-based achievements |
| Exploration | Discovery motif | 0.8s | Finding new areas |
| Story/Lore | Mysterious reveal | 1.0s | Alien artifact insights |

#### Achievement Sound Hierarchy
```
Minor achievement: Single stinger (0.3-0.5s)
Major achievement: Short fanfare (0.6-1.0s)
Epic achievement: Full musical phrase (1.0-1.5s)

All achievements:
  - Distinct from gameplay sounds
  - Pause-resistant (plays even if game paused)
  - Non-repetitive (random variation in each tier)
```

### Combo/Streak System Audio

```gdscript
# Pickup combo audio system
var combo_count: int = 0
var combo_timer: Timer
const COMBO_WINDOW = 1.0  # seconds
const MAX_PITCH_MULTIPLIER = 1.5
const PITCH_INCREMENT = 0.05

func play_pickup(rarity: String):
    combo_count += 1
    combo_timer.start(COMBO_WINDOW)

    # Calculate pitch based on combo
    var pitch = 1.0 + (combo_count * PITCH_INCREMENT)
    pitch = min(pitch, MAX_PITCH_MULTIPLIER)

    # Play sound with combo pitch
    var sound = PICKUP_SOUNDS[rarity]
    sfx_player.pitch_scale = pitch
    sfx_player.play()

    # Bonus sound at combo milestones
    if combo_count == 5:
        play_overlay("combo_5")
    elif combo_count == 10:
        play_overlay("combo_10")
    elif combo_count >= 20:
        play_overlay("combo_mega")

func _on_combo_timeout():
    combo_count = 0
```

### Reference Games
- **Destiny 2:** Engram pickup sounds, satisfying rarity tiers
- **Diablo series:** Loot drop audio hierarchy
- **Warframe:** Resource collection feedback
- **Subnautica:** Material acquisition sounds

---

## 5. Player Feedback

### Sonic Aesthetic
**Primary:** Robotic/mechanical operation sounds
**Secondary:** Energy systems (shields, power core)
**Tertiary:** Warning indicators (digital alerts)

### Robot/Mech Movement Sounds

#### DIGBOT-7 Movement Audio

| Movement | Sound Components | Notes |
|----------|------------------|-------|
| Idle Hover | Low thruster hum + servo micro-adjustments | Constant, very subtle |
| Forward Motion | Thruster increase + momentum | Intensity scales with speed |
| Jump/Thrust | Thruster burst + energy discharge | Punchy, satisfying |
| Landing | Impact + shock absorbers | Weight varies with fall height |
| Wall Contact | Magnetic grip engage | Quick mechanical lock |
| Wall Slide | Friction + servo strain | Continuous while sliding |
| Emergency Stop | Brake engage + stabilizer | Sudden direction change |

#### Movement Sound Design

**Idle State**
```
Components:
  - Base: Low electrical hum (60 Hz, very quiet)
  - Texture: Occasional servo micro-movement
  - Overlay: Suit/robot internal sounds (distant)

Volume: -20dB, barely perceptible
Should feel like the robot is "always on"
```

**Locomotion**
```
Base: Thruster loop (filtered noise + sine)
Dynamics:
  - Velocity 0: Idle state only
  - Velocity 0.5: 50% thruster intensity
  - Velocity 1.0: Full thruster burn

Additional:
  - Direction change: Small stabilizer burst
  - Acceleration: Rising pitch/intensity
  - Deceleration: Falling pitch + brake sound
```

**Jump/Aerial**
```
Jump initiation: Thruster burst (0.15s)
  - Compressed air release
  - Energy pulse
  - Upward pitch sweep

Airborne: Light sustained thrust (looping)
  - Reduced intensity
  - Doppler effect on horizontal movement

Landing:
  - Low fall: Soft cushion + servo (0.1s)
  - Medium fall: Impact + recovery (0.2s)
  - High fall: Heavy impact + strain warning (0.3s)
```

### Damage Taken Sounds

| Damage Type | Sound Character | Accompanying Effects |
|-------------|-----------------|----------------------|
| Physical Impact | Metal stress + alarm blip | Hull integrity warning |
| Energy/Laser | Shield crackle + system strain | Shield percentage warning |
| Environmental | Pressure/heat warning + damage | Hazard-specific warning |
| Fall Damage | Impact + system shock | Recovery sequence |
| Acid/Corrosion | Sizzle + hull warning | Ongoing damage indicator |

#### Damage Sound Layers
```
Layer 1: Impact type (physical, energy, environmental)
Layer 2: Severity indicator (light, medium, heavy)
Layer 3: System warning (hull/shield status)

Light damage:
  - Brief alert blip
  - Subtle shield flicker sound
  - No voice warning

Medium damage:
  - Distinct impact
  - System strain sound
  - Short alarm tone

Heavy damage:
  - Full impact + stress
  - Multiple warnings
  - Possible voice line "Hull breach detected"
```

### Low Health Warning

#### Hull Integrity Warning System
```
100-75%: No audio warning (HUD indicator only)
75-50%:  Occasional system beep (every 30s)
50-25%:  Periodic warning tone (every 10s) + subtle heartbeat pulse
25-10%:  Constant warning pulse (every 5s) + more intense heartbeat
<10%:    Critical alarm (continuous) + rapid heartbeat + voice warning

Audio elements:
  - Warning tone: Synthesized alert (A3, pulsing)
  - Heartbeat: Low bass pulse (simulates robot power core)
  - Voice warning: "Hull integrity critical" (processed robot voice)
  - System strain: Electrical crackle overlay
```

#### Implementation
```gdscript
# Health warning audio system
var health_warning_state: int = 0
var heartbeat_player: AudioStreamPlayer

func update_health_warning(hull_percent: float):
    var new_state = get_warning_state(hull_percent)

    if new_state != health_warning_state:
        health_warning_state = new_state
        update_warning_audio(new_state)

func get_warning_state(percent: float) -> int:
    if percent > 75: return 0
    elif percent > 50: return 1
    elif percent > 25: return 2
    elif percent > 10: return 3
    else: return 4

func update_warning_audio(state: int):
    match state:
        0: stop_all_warnings()
        1: start_occasional_beep()
        2:
            start_periodic_warning()
            start_heartbeat(60)  # 60 BPM
        3:
            increase_warning_frequency()
            start_heartbeat(90)  # Faster
        4:
            start_critical_alarm()
            start_heartbeat(120)
            play_voice_warning()
```

### Death/Respawn Sounds

#### Death Sequence
```
Phase 1 - Critical Failure (0.3s):
  - System overload sound
  - Multiple alarm triggers
  - Power fluctuation audio

Phase 2 - Shutdown (0.5s):
  - Systems powering down (descending tone)
  - Final servo release
  - Screen/visual shutdown sound

Phase 3 - Silence (0.3s):
  - Brief silence for impact
  - Distant ambient only

Total death sound: ~1.1s
```

#### Respawn Sequence
```
Phase 1 - Reconstruction (0.5s):
  - Data stream sound (digital rebuilding)
  - Energy gathering (rising)
  - Teleport materialization

Phase 2 - System Boot (0.3s):
  - Systems online (ascending)
  - Servo initialization
  - HUD activation sound

Phase 3 - Ready (0.2s):
  - Confirmation tone
  - Full operational status
  - Optional voice: "Systems restored"

Total respawn sound: ~1.0s
```

### Other Player Feedback

| Event | Sound | Notes |
|-------|-------|-------|
| Energy Recharge | Rising fill + completion ping | Battery/energy refill |
| Shield Regeneration | Electric shimmer, rebuilding | Shield recharging |
| Upgrade Collected | Power-up + systems enhanced | Field pickup |
| Inventory Full | Container sealed + rejection | Cannot collect more |
| Tool Overheating | Warning hiss + cooldown | Drilling too fast |
| Obstacle Collision | Bump + stabilization | Non-damaging impact |

### Reference Games/Films
- **Iron Man (films):** Suit HUD sounds, system warnings
- **Dead Space:** RIG health indicator sounds
- **Metroid Prime:** Suit damage and system audio
- **Portal 2:** Robot movement, impact sounds

---

## 6. Music Direction

### Overall Approach
SciFi ambient electronic music with dynamic layering based on game state.

### Surface Theme
```
Mood: Frontier isolation, alien beauty, hope
Style: Ambient electronic with organic textures
Tempo: Slow (60-80 BPM)
Key: Minor with major moments
Duration: 3-4 minute seamless loop

Elements:
  - Pad synthesizers (warm but alien)
  - Processed organic sounds (wind, breath)
  - Light percussion (distant, rhythmic)
  - Occasional melodic motif (3-note "home" theme)
```

### Underground Music (Depth-Layered)
```
System: Stems that add/remove based on depth

Stem 1 (Always): Base ambient pad
Stem 2 (200m+): Subtle rhythm/pulse
Stem 3 (500m+): Tension elements
Stem 4 (1000m+): Melodic fragments
Stem 5 (2000m+): Intensity/drama

All stems: Same BPM, key, and loop length for seamless blending
```

### Reference Artists/Tracks
- **65daysofstatic:** No Man's Sky soundtrack
- **Gustavo Santaolalla:** The Last of Us (isolated beauty)
- **Jesper Kyd:** Assassin's Creed (atmospheric)
- **Ben Frost:** Industrial tension
- **Disasterpeace:** Hyper Light Drifter (pixel game reference)

---

## 7. Implementation Considerations

### Mobile Optimization

#### File Formats
| Audio Type | Format | Reason |
|------------|--------|--------|
| Short SFX (<1s) | WAV 16-bit | Low latency, small size |
| UI Sounds | WAV 16-bit | Instant playback required |
| Music Loops | OGG Vorbis 128kbps | Compressed, good quality |
| Ambient Loops | OGG Vorbis 96kbps | Background, can be lower |

#### File Size Budgets
```
Total audio budget: ~20MB
  - SFX: 5MB (many small files)
  - UI: 1MB (synthesized, tiny)
  - Ambient: 6MB (6 zone loops)
  - Music: 8MB (2-3 tracks with stems)
```

#### Channel Limits
```gdscript
const MAX_SFX_CHANNELS = 8      # Simultaneous sound effects
const MAX_MUSIC_CHANNELS = 2     # For crossfading
const MAX_AMBIENT_CHANNELS = 3   # Layer blending

# Priority system
enum AudioPriority {
    CRITICAL,    # Death, achievement - never interrupted
    HIGH,        # Damage, pickup - rarely interrupted
    MEDIUM,      # Drilling, movement - can be interrupted
    LOW,         # Ambient details - first to be culled
}
```

### Godot Audio Bus Structure
```
Master
├── Music (user adjustable)
│   ├── Surface
│   └── Underground
├── SFX (user adjustable)
│   ├── Drilling (dedicated bus for frequent sounds)
│   ├── Pickup
│   ├── UI
│   └── Combat
├── Ambient (user adjustable)
│   ├── Environment
│   └── Hazards
└── Voice (future, user adjustable)
```

### Audio Settings
```gdscript
var audio_settings = {
    "master_volume": 0.8,
    "music_volume": 0.5,      # Lower default for mobile
    "sfx_volume": 1.0,
    "ambient_volume": 0.6,
    "haptics_enabled": true,
    "low_power_mode": false,  # Reduces audio complexity
}

# Low power mode reduces:
# - Ambient layers (1 instead of 3)
# - Reverb processing disabled
# - Lower polyphony limit
```

---

## 8. Asset Creation Plan

### Priority Order

#### Phase 1: Core Gameplay (MVP)
```
Must Have:
  - [ ] Drill sounds (3 variations x 4 materials = 12 files)
  - [ ] Block break sounds (4 materials = 4 files)
  - [ ] Basic pickup sounds (3 tiers = 3 files)
  - [ ] Core UI sounds (8 essential = 8 files)
  - [ ] Death/respawn (2 files)
  - [ ] One ambient loop (surface)

Total: ~30 files
Estimated time: 2-3 days with AI/library
```

#### Phase 2: Full Experience (v1.0)
```
  - [ ] Full material drilling sounds (all layers)
  - [ ] Complete pickup sound hierarchy
  - [ ] All UI feedback sounds
  - [ ] All ambient layers (6 zones)
  - [ ] Movement sounds (full set)
  - [ ] Health warning system
  - [ ] Achievement sounds

Total: ~80 additional files
Estimated time: 1-2 weeks
```

#### Phase 3: Polish (v1.1+)
```
  - [ ] Music stems (surface, underground)
  - [ ] Voice lines (optional)
  - [ ] Creature/hazard sounds
  - [ ] Environmental details
  - [ ] Seasonal/event sounds

Total: Variable
```

### Recommended Tools

#### Generation/Synthesis
| Tool | Use Case | Cost |
|------|----------|------|
| Vital (synth) | UI tones, base sounds | Free |
| ElevenLabs SFX | AI-generated sound effects | Paid |
| BFXR | Retro-style effects | Free |
| Surge XT | Complex synthesis | Free |

#### Libraries
| Library | Content | Cost |
|---------|---------|------|
| Sonniss GDC | Yearly free pack | Free |
| Boom Library | Sci-fi construction kit | Paid |
| Freesound.org | Community samples | Free |

#### Processing
| Tool | Use Case | Cost |
|------|----------|------|
| Audacity | Basic editing, export | Free |
| iZotope RX | Noise reduction, cleanup | Paid |
| Reaper | DAW for sound design | Low cost |

---

## 9. Reference Summary

### Games
- **Dead Space:** Industrial sci-fi horror, UI sounds
- **Mass Effect 2:** Clean sci-fi interface, resource collection
- **Subnautica:** Depth-based ambient, alien environment
- **Doom Eternal:** Impactful combat feedback
- **No Man's Sky:** Alien planet atmospheres
- **Destiny 2:** Loot hierarchy audio

### Films
- **Alien (1979):** Isolated tension, ship ambience
- **Blade Runner 2049:** Future industrial, atmospheric
- **Interstellar:** Space isolation, pressure
- **Annihilation:** Alien biology sounds

### Music
- **65daysofstatic:** Procedural ambient
- **Ben Frost:** Industrial tension
- **Disasterpeace:** Indie game ambience

---

## 10. Success Metrics

### Audio Quality
- [ ] All sounds clearly identifiable by function
- [ ] Rarity immediately recognizable through audio
- [ ] Depth progression audible through ambient
- [ ] No harsh or fatiguing sounds

### Technical
- [ ] Total audio under 20MB
- [ ] No audio latency issues on mobile
- [ ] Seamless loop points on all loops
- [ ] No clicks, pops, or artifacts

### Player Experience
- [ ] Audio enhances SciFi immersion
- [ ] Feedback sounds feel responsive
- [ ] Ambient creates appropriate mood
- [ ] Audio off does not impair gameplay (visual alternatives exist)

---

*Document prepared for: GoDig SciFi Redesign*
*Audio design complements: SCIFI_REDESIGN_PLAN.md*
*Next steps: Complete Phase 1 asset list, begin prototyping*
