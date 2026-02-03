# Procedural Audio for Mining Games - Implementation Patterns

> Research on procedural audio generation techniques for mining games, focusing on sci-fi aesthetics, depth-based soundscapes, and satisfying mining feedback. Supplements scifi-audio-design.md with technical implementation details.
> Last updated: 2026-02-02 (Session 27)

## Executive Summary

Procedural audio generates sound at runtime rather than playing pre-recorded samples, enabling infinite variation and dynamic response to gameplay. For GoDig's SciFi mining theme, procedural audio offers: smaller file sizes (critical for mobile), unique per-session experiences, and dynamic depth-based soundscapes. This research covers practical implementation patterns for Godot 4.

---

## 1. Why Procedural Audio for Mining Games

### Memory Efficiency

> "Sampled audio files can be used sparingly while the bulk of sound effects are generated procedurally... occupying a very small memory footprint."

**Mobile Benefit:**
- Traditional approach: 100+ sound files = 20-50MB
- Procedural approach: Synthesis engine + parameters = 1-5MB
- Critical for mobile download sizes and runtime memory

### Infinite Variation

> "Procedural audio creates sound effects based on pre-determined behaviors - like a system that generates footstep sounds on different surfaces without needing a pre-recorded sample for each step."

For mining:
- Each block break sounds slightly different
- Ore discovery has subtle variations
- Prevents audio fatigue from repetition

### Dynamic Response

> "Dynamic ambient systems are sound design techniques that create immersive auditory environments adapting to player actions and in-game events."

For GoDig:
- Soundscape changes with depth in real-time
- Mining sounds respond to tool tier and material
- Danger proximity affects audio tension

---

## 2. Mining Satisfaction Through Audio

### Deep Rock Galactic Lessons

Community feedback reveals what makes mining audio satisfying:

> "Strong audio cues are often what keep players engaged, and the auditory satisfaction of 'crunching' through a resource matters a lot more than the resource itself."

**Key Satisfaction Elements:**
- "Tink tink tink" - The rhythmic sound of hitting resources
- "Satisfying crunch" - Material-specific break sounds
- Crystal resonance - Harmonic tones for rare discoveries
- Combo feedback - Rising pitch for consecutive hits

### Mass Effect 2 Mineral Scanner

> "Uses timbre to identify which mineral you've found, and clicks that occur faster when the amount is bigger."

**Pattern:** Audio encodes information:
- Pitch = mineral type
- Speed = quantity/richness
- Volume = proximity

### What Players Want

From community feedback:
> "Love the current feedback and sound design of the pick axe, but a bit more depth to this mechanic might be great... combos or rhythms for pick axes or sensitive points in mineral veins."

**Implementation Ideas:**
- Rhythm bonuses for well-timed hits
- Sweet spot discovery through audio cues
- Combo system with escalating audio feedback

---

## 3. Procedural Audio Tools for Godot

### Native Godot Audio

Godot 4's audio system supports basic procedural concepts:

```gdscript
# AudioStreamGenerator for real-time synthesis
var generator := AudioStreamGenerator.new()
generator.mix_rate = 44100
generator.buffer_length = 0.5

var playback: AudioStreamGeneratorPlayback

func _ready():
    var player := AudioStreamPlayer.new()
    player.stream = generator
    add_child(player)
    player.play()
    playback = player.get_stream_playback()

func _process(_delta):
    _fill_buffer()

func _fill_buffer():
    var frames_available := playback.get_frames_available()
    for i in frames_available:
        # Generate sine wave at 440Hz
        var frame := sin(TAU * 440.0 * _phase)
        _phase = fmod(_phase + 1.0 / 44100.0, 1.0)
        playback.push_frame(Vector2(frame, frame))
```

### Limitations

- No built-in synthesis nodes
- Manual DSP required
- Performance cost on mobile

### Recommended Approach for GoDig

**Hybrid Model:**
1. Pre-generate base sounds at build time
2. Apply runtime modulation (pitch, filter, effects)
3. Layer procedurally selected samples

```gdscript
# Hybrid procedural system
class_name ProceduralMining
extends Node

# Pre-loaded base samples
var _drill_base: AudioStream = preload("res://audio/sfx/drill_base.wav")
var _impact_base: AudioStream = preload("res://audio/sfx/impact_base.wav")
var _break_samples: Array[AudioStream] = [
    preload("res://audio/sfx/break_01.wav"),
    preload("res://audio/sfx/break_02.wav"),
    preload("res://audio/sfx/break_03.wav"),
]

# Runtime modulation
func play_drill_sound(material: String, tool_tier: int) -> void:
    var player := _get_player()
    player.stream = _drill_base

    # Procedural pitch based on tool tier
    player.pitch_scale = 0.8 + (tool_tier * 0.1)

    # Material affects filtering (via AudioEffectFilter)
    var bus_idx := AudioServer.get_bus_index("Drilling")
    _apply_material_filter(bus_idx, material)

    player.play()

func play_break_sound(material: String, combo_count: int) -> void:
    var player := _get_player()

    # Random sample selection
    player.stream = _break_samples.pick_random()

    # Combo affects pitch
    var combo_pitch := 1.0 + (min(combo_count, 10) * 0.03)
    player.pitch_scale = combo_pitch

    # Material affects volume
    player.volume_db = _get_material_volume(material)

    player.play()
```

---

## 4. Depth-Based Ambient System

### Layer Concept

> "For ambiences, think of layers with depth - the sounds in them are from different distances and perspectives."

**Implementation for GoDig:**

```gdscript
# depth_ambient_manager.gd
class_name DepthAmbientManager
extends Node

# Ambient layers (loaded as AudioStreamOGGVorbis for looping)
var _layers: Dictionary = {
    "base": null,       # Always playing, subtle
    "texture_1": null,  # Adds at 100m
    "texture_2": null,  # Adds at 300m
    "tension": null,    # Adds at 500m
    "danger": null,     # Adds at 1000m
}

# AudioStreamPlayers for each layer
var _players: Dictionary = {}

# Crossfade duration
const FADE_DURATION := 2.0

func _ready():
    _setup_players()
    _load_default_ambience()

func update_for_depth(depth: float) -> void:
    # Calculate target volumes for each layer
    var targets := _calculate_layer_volumes(depth)

    for layer_name in _layers.keys():
        var target_volume: float = targets[layer_name]
        var player: AudioStreamPlayer = _players[layer_name]

        # Crossfade to target
        _fade_to_volume(player, target_volume)

func _calculate_layer_volumes(depth: float) -> Dictionary:
    return {
        "base": 1.0,  # Always full
        "texture_1": clamp(depth / 200.0, 0.0, 1.0),
        "texture_2": clamp((depth - 200.0) / 300.0, 0.0, 1.0),
        "tension": clamp((depth - 400.0) / 200.0, 0.0, 1.0),
        "danger": clamp((depth - 800.0) / 400.0, 0.0, 1.0),
    }

func _fade_to_volume(player: AudioStreamPlayer, target_db: float) -> void:
    var tween := create_tween()
    var target_linear := db_to_linear(target_db)
    tween.tween_property(player, "volume_db", linear_to_db(target_linear), FADE_DURATION)

func change_zone(zone_name: String) -> void:
    # Load zone-specific ambient sounds
    match zone_name:
        "regolith":
            _layers["base"] = preload("res://audio/ambient/regolith_base.ogg")
            _layers["texture_1"] = preload("res://audio/ambient/regolith_dust.ogg")
        "xenolite":
            _layers["base"] = preload("res://audio/ambient/xenolite_base.ogg")
            _layers["texture_1"] = preload("res://audio/ambient/xenolite_crystal.ogg")
        "core":
            _layers["base"] = preload("res://audio/ambient/core_base.ogg")
            _layers["tension"] = preload("res://audio/ambient/core_rumble.ogg")

    _crossfade_layers()
```

### Creating Depth Through Audio

From professional practice:

> "Ambiences often need to be diffuse, with distance and diffusion sounding more exaggerated than real life to create contrast and depth."

**Techniques:**
1. **Reverb increase** - More reverb = deeper feel
2. **Low-pass filter** - Muffled = underground
3. **Bass enhancement** - Sub frequencies = weight/pressure
4. **Echo density** - More echoes = larger caverns

```gdscript
# Depth-based audio effects
func _apply_depth_effects(depth: float) -> void:
    var reverb_bus := AudioServer.get_bus_index("Reverb")
    var reverb_effect: AudioEffectReverb = AudioServer.get_bus_effect(reverb_bus, 0)

    # Increase reverb with depth
    reverb_effect.room_size = lerp(0.2, 0.8, depth / 2000.0)
    reverb_effect.damping = lerp(0.1, 0.5, depth / 2000.0)

    # Low-pass filter for "underground" feel
    var filter_bus := AudioServer.get_bus_index("Underground")
    var filter_effect: AudioEffectFilter = AudioServer.get_bus_effect(filter_bus, 0)

    # Cut highs as depth increases
    filter_effect.cutoff_hz = lerp(20000.0, 8000.0, depth / 1000.0)
```

---

## 5. Sci-Fi Sound Synthesis Techniques

### Laser/Drill Sounds

From sound design community:

> "The standard 'laser' sound is simply a short exponential descend in pitch and can be done with just one oscillator and a pitch envelope."

**Implementation:**

```gdscript
# laser_synth.gd - Simple laser sound generator
class_name LaserSynth
extends Node

var _generator: AudioStreamGenerator
var _playback: AudioStreamGeneratorPlayback
var _player: AudioStreamPlayer

var _phase: float = 0.0
var _frequency: float = 2000.0
var _target_frequency: float = 200.0
var _envelope: float = 1.0
var _duration: float = 0.15

func _ready():
    _setup_generator()

func play_laser() -> void:
    _phase = 0.0
    _frequency = 2000.0  # Start high
    _envelope = 1.0
    _player.play()

func _process(delta: float):
    if not _player.playing:
        return

    # Exponential pitch drop
    _frequency = lerp(_frequency, _target_frequency, delta * 20.0)

    # Envelope decay
    _envelope -= delta / _duration
    if _envelope <= 0:
        _player.stop()
        return

    _fill_buffer()

func _fill_buffer():
    var frames := _playback.get_frames_available()
    for i in frames:
        var sample := sin(TAU * _phase) * _envelope
        _phase = fmod(_phase + _frequency / 44100.0, 1.0)
        _playback.push_frame(Vector2(sample, sample))
```

### Sci-Fi UI Tones

> "A button can be made literally out of anything: a sine tone, a recorded mouse click, a metal bang, or even a millisecond long snippet."

**Simple UI Synthesis:**

```gdscript
# ui_tones.gd - Generate sci-fi UI tones
class_name UITones
extends Node

# Pre-generate and cache UI sounds
var _button_press: AudioStreamWAV
var _button_release: AudioStreamWAV
var _notification: AudioStreamWAV

func _ready():
    _generate_tones()

func _generate_tones():
    _button_press = _create_tone(523.25, 0.08)  # C5
    _button_release = _create_tone(659.25, 0.05)  # E5
    _notification = _create_chime([523.25, 659.25, 783.99], 0.2)  # C-E-G

func _create_tone(frequency: float, duration: float) -> AudioStreamWAV:
    var sample_rate := 44100
    var samples := int(duration * sample_rate)
    var data := PackedByteArray()
    data.resize(samples * 2)  # 16-bit mono

    for i in samples:
        var t := float(i) / sample_rate
        var envelope := 1.0 - (t / duration)  # Linear decay
        var sample := sin(TAU * frequency * t) * envelope

        # Convert to 16-bit
        var value := int(sample * 32767)
        data[i * 2] = value & 0xFF
        data[i * 2 + 1] = (value >> 8) & 0xFF

    var stream := AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = sample_rate
    stream.data = data
    return stream

func _create_chime(frequencies: Array, duration: float) -> AudioStreamWAV:
    var sample_rate := 44100
    var samples := int(duration * sample_rate)
    var data := PackedByteArray()
    data.resize(samples * 2)

    for i in samples:
        var t := float(i) / sample_rate
        var envelope := pow(1.0 - (t / duration), 2)  # Exponential decay

        var sample := 0.0
        for freq in frequencies:
            sample += sin(TAU * freq * t)
        sample = (sample / frequencies.size()) * envelope

        var value := int(sample * 32767)
        data[i * 2] = value & 0xFF
        data[i * 2 + 1] = (value >> 8) & 0xFF

    var stream := AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = sample_rate
    stream.data = data
    return stream
```

---

## 6. Combo and Rhythm Systems

### Pitch Escalation Pattern

```gdscript
# combo_audio.gd - Mining combo audio feedback
class_name ComboAudio
extends Node

var _combo_count: int = 0
var _combo_timer: Timer
var _base_pitch: float = 1.0

const COMBO_WINDOW := 0.8  # seconds
const PITCH_INCREMENT := 0.04
const MAX_PITCH := 1.5
const COMBO_MILESTONES := [5, 10, 20, 50]

signal combo_milestone_reached(count: int)

func _ready():
    _setup_timer()

func register_hit() -> void:
    _combo_count += 1
    _combo_timer.start(COMBO_WINDOW)

    # Check milestones
    if _combo_count in COMBO_MILESTONES:
        combo_milestone_reached.emit(_combo_count)
        _play_milestone_sound()

func get_current_pitch() -> float:
    var pitch := _base_pitch + (_combo_count * PITCH_INCREMENT)
    return min(pitch, MAX_PITCH)

func get_combo_count() -> int:
    return _combo_count

func _on_combo_timer_timeout():
    _combo_count = 0

func _play_milestone_sound():
    match _combo_count:
        5:
            SoundManager.play("combo_5")  # Minor fanfare
        10:
            SoundManager.play("combo_10")  # Medium fanfare
        20:
            SoundManager.play("combo_mega")  # Major fanfare
        50:
            SoundManager.play("combo_legendary")  # Epic fanfare
```

### Rhythm Detection (Optional Feature)

```gdscript
# rhythm_bonus.gd - Reward rhythmic mining
class_name RhythmBonus
extends Node

var _last_hit_time: float = 0.0
var _hit_intervals: Array[float] = []
var _rhythm_streak: int = 0

const INTERVAL_TOLERANCE := 0.1  # seconds
const MIN_RHYTHM_STREAK := 4

signal rhythm_bonus(streak: int)

func register_hit() -> void:
    var current_time := Time.get_ticks_msec() / 1000.0
    var interval := current_time - _last_hit_time
    _last_hit_time = current_time

    if _hit_intervals.size() > 0:
        var expected_interval: float = _hit_intervals.reduce(func(a, b): return a + b) / _hit_intervals.size()

        if abs(interval - expected_interval) < INTERVAL_TOLERANCE:
            _rhythm_streak += 1
            if _rhythm_streak >= MIN_RHYTHM_STREAK:
                rhythm_bonus.emit(_rhythm_streak)
                _play_rhythm_feedback()
        else:
            _rhythm_streak = 0

    _hit_intervals.append(interval)
    if _hit_intervals.size() > 5:
        _hit_intervals.pop_front()

func _play_rhythm_feedback():
    # Subtle audio cue that player is in rhythm
    SoundManager.play_with_pitch("rhythm_hit", 1.0 + (_rhythm_streak * 0.02))
```

---

## 7. Performance Optimization

### Mobile Audio Best Practices

```gdscript
# audio_optimizer.gd
class_name AudioOptimizer
extends Node

const MAX_SIMULTANEOUS_SFX := 8
const MAX_AMBIENT_LAYERS := 3
const LOW_POWER_POLYPHONY := 4

var _active_sfx_count: int = 0
var _low_power_mode: bool = false

func play_sfx(stream: AudioStream, priority: int = 0) -> AudioStreamPlayer:
    if _active_sfx_count >= _get_max_sfx():
        if priority == 0:
            return null  # Skip low-priority sounds
        else:
            _stop_lowest_priority()

    var player := _get_pooled_player()
    player.stream = stream
    player.play()
    _active_sfx_count += 1

    player.finished.connect(func(): _active_sfx_count -= 1, CONNECT_ONE_SHOT)
    return player

func _get_max_sfx() -> int:
    return LOW_POWER_POLYPHONY if _low_power_mode else MAX_SIMULTANEOUS_SFX

func enable_low_power_mode(enabled: bool) -> void:
    _low_power_mode = enabled

    if enabled:
        # Reduce ambient layers
        _reduce_ambient_layers()
        # Disable reverb processing
        _disable_expensive_effects()

func _disable_expensive_effects():
    var reverb_bus := AudioServer.get_bus_index("Reverb")
    AudioServer.set_bus_bypass_effects(reverb_bus, true)
```

### Sound Pooling

```gdscript
# audio_pool.gd - Reuse AudioStreamPlayers
class_name AudioPool
extends Node

var _pool: Array[AudioStreamPlayer] = []
var _pool_size: int = 16

func _ready():
    for i in _pool_size:
        var player := AudioStreamPlayer.new()
        player.bus = "SFX"
        add_child(player)
        _pool.append(player)

func get_player() -> AudioStreamPlayer:
    for player in _pool:
        if not player.playing:
            return player

    # All busy - return oldest
    push_warning("Audio pool exhausted")
    return _pool[0]

func play(stream: AudioStream, pitch: float = 1.0, volume_db: float = 0.0) -> void:
    var player := get_player()
    player.stream = stream
    player.pitch_scale = pitch
    player.volume_db = volume_db
    player.play()
```

---

## 8. Implementation Checklist for GoDig

### Phase 1: Core Mining Audio
- [ ] Drill base sound with pitch modulation by tool tier
- [ ] Block break sounds with random variation
- [ ] Material-specific impact sounds
- [ ] Combo pitch escalation system
- [ ] Basic ore pickup sounds (3 tiers)

### Phase 2: Ambient System
- [ ] Base ambient loop for each zone
- [ ] Depth-based layer crossfading
- [ ] Reverb scaling by depth
- [ ] Zone transition audio

### Phase 3: UI Audio
- [ ] Synthesized button tones
- [ ] Menu transition sounds
- [ ] Notification hierarchy
- [ ] Achievement fanfares

### Phase 4: Polish
- [ ] Rhythm detection bonus (optional)
- [ ] Low-power mode optimization
- [ ] Audio ducking during important events
- [ ] Haptic feedback integration

---

## Sources

- [Procedural Audio: The Complete Beginner's Guide - eMastered](https://emastered.com/blog/procedural-audio)
- [Epic Games - Ambient and Procedural Sound Design Course](https://dev.epicgames.com/community/learning/courses/qR/ambient-and-procedural-sound-design)
- [A Sound Effect - Sci-Fi UI Sound Design](https://www.asoundeffect.com/sci-fi-ui-sound-effects/)
- [Wayline - Ambient Audio in Game Worlds](https://www.wayline.io/blog/ambient-audio-game-worlds)
- [Splice - Procedural Audio in Video Games](https://splice.com/blog/procedural-audio-video-games/)
- [Deep Rock Galactic Sound Design Discussion](https://www.zleague.gg/theportal/why-deep-rock-galactics-sound-design-is-rocking-the-gaming-world/)
- [Designing Sound - Creating Spaces of Ambience](https://designingsound.org/2012/12/29/creating-the-spaces-of-ambience/)
- [Krotos - Futurism Sound Effects Library](https://www.krotosaudio.com/products/futurism-sound-effects-library/)
- [DSP Sci-Fi - Procedural Sound Generator](https://tsugi-studio.com/web/en/products-dspscifi.html)
- [Gearspace - Synthesizing Laser Sounds](https://gearspace.com/board/post-production-forum/194722-synthesising-lasers-futuristic-gun-sounds-foley.html)

## Related Implementation Tasks

- SciFi audio redesign (SCIFI_REDESIGN_PLAN.md)
- `implement: Distinct audio for each ore type` - GoDig-implement-distinct-audio-450bc8be
- `implement: Haptic feedback for ore discovery` - GoDig-implement-haptic-feedback-92e67c42
