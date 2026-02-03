# Tension Audio Design: Ambient Soundscapes and Depth Psychology

## Overview

This research documents how audio creates tension and depth perception in games, with specific focus on mining and exploration contexts. The goal is to design subtle tension audio for GoDig that communicates danger through soundscape without being overwhelming or annoying.

## Sources

- [Subnautica and Sound - The Geekwave](https://thegeekwave.com/2020/06/subnautica-and-sound/)
- [Underwater Sound Recording for Subnautica](https://unknownworlds.com/subnautica/underwater-sound-recording-subnautica/)
- [Drones and Ambient Music in Horror Games - Gamemusic](https://gamemusic.net/drones-and-ambient-music-in-horror-games/)
- [Sound Design in Horror Games - Horror Chronicles](https://horrorchronicles.com/horror-games-and-sound-design/)
- [Silence is Scary: Sound Design in Horror Games - Wayline](https://www.wayline.io/blog/silence-is-scary-sound-design-horror-games)
- [The Power of Silence: Quiet Audio in Gaming - Wayline](https://www.wayline.io/blog/power-of-silence-gaming-audio)
- [How to Make Ambiences for Games - Game Audio Learning](https://www.gameaudiolearning.com/knowledgebase/how-to-make-ambiences-for-games)
- [The Role of Sound in Creating Atmosphere - Game Pill](https://gamepill.com/the-role-of-sound-and-music-in-creating-atmosphere-in-games/)
- [Deep Rock Galactic Ambient Discussions](https://steamcommunity.com/app/548430/discussions/1/3014556944200340538/)

## The Psychology of Depth Through Sound

### How Sound Creates Depth Perception

**Subnautica's Lesson**: "The greatest use of sound design in Subnautica comes in how it creates the terror and curiosity that the game is known for. While the visuals build terror by hindering the player's vision, it is the sounds in the distance, distorted by the water, that create Subnautica's excellent atmosphere."

**Key Insight**: Sound reaches further than sight in dark environments. Players "hear" danger before they see it, creating anticipation and tension.

### The Three-Dimensional Nature of Underground

Like underwater environments, caves create three-dimensional threat spaces:
- Sound echoes from above, below, and all around
- Players can't rely on clear directional audio
- Uncertainty about sound source creates tension
- Distance estimation becomes difficult

### Frequency and Emotion

| Frequency Range | Emotional Association |
|-----------------|----------------------|
| **Low (20-200 Hz)** | Weight, pressure, danger, unease |
| **Mid (200-2000 Hz)** | Human voice range, organic sounds |
| **High (2000-20000 Hz)** | Alertness, sparkle, discovery |

For depth psychology:
- **Surface**: Full frequency spectrum, natural and alive
- **Shallow**: Reduced highs, more reverb
- **Deep**: Dominated by low frequencies, muffled highs
- **Abyss**: Ultra-low drones, absence of familiar sounds

## Case Studies

### Subnautica: Depth Through Sound

**What Works:**
- Reaper Leviathan roars audible from 5km away
- Roar only triggers when creature can see player (brilliant design)
- Player can't tell if creature is far away or right behind them
- Muffled, distorted sounds create underwater authenticity

**Philosophy**: "Too much realism in sound can diminish the player experience... Sound gives the visuals and gameplay credibility and character."

**Key Technique**: The developers weren't going for realism - they prioritized emotional impact over accuracy.

### Deep Rock Galactic: Cave Atmosphere

**What Works:**
- Persistent low hum in caves
- Biome-specific ambient tracks that match the "vibe"
- Creature sounds that create "heebiejeebies"
- Salt Pits pairs with "Let's Go Deeper" - names that evoke the feeling

**Key Technique**: Ambient tracks are designed for specific biome feelings, not just background noise.

### Dead Space: Strategic Silence

**What Works:**
- Dense environmental soundscapes with multiple layers
- Randomized one-shot sounds create uncertainty
- Players question: "Was that a Necromorph or just the ship?"
- Long periods of silence make sounds more impactful

**Key Technique**: Silence isn't absence - it's active tension building.

### Resident Evil 7: Environmental Terror

**What Works:**
- The Baker house uses unsettling quiet
- Dripping water, buzzing flies, whispers
- Absence of music makes environmental sounds prominent
- Silence amplifies tension "to an unbearable level"

## The Power of Silence

### When Music vs Silence Creates More Tension

**Music Creates Tension When:**
- Player is in active danger (combat, chase)
- Building toward a known climax
- Establishing a new area's mood initially
- Celebrating a discovery or achievement

**Silence Creates More Tension When:**
- Player is alone and exploring
- Danger is unknown or uncertain
- After a scare, allowing fear to settle
- When player needs to listen for environmental cues

### The Contrast Principle

"Silence or near-silence can act as a far greater emotive tool when it is either preceded or succeeded by loudness. The impact of the silence will provide more value if it stands in stark contrast to the events that surround it."

**Application to GoDig:**
- Surface: Music, birds, life sounds
- Descending: Music fades, ambient sounds emerge
- Deep: Near-silence with occasional distant sounds
- Discovery: Brief musical flourish, then back to silence
- Return to surface: Music returns, relief

### Avoiding Silence Pitfalls

**Don't:**
- Use unmotivated silence (silence just to be silent)
- Cut music abruptly (feels like a bug)
- Leave true silence (no sounds at all - feels broken)
- Overuse silence (becomes fatiguing)

**Do:**
- Transition smoothly between music and ambient
- Always have some base layer (wind, drips, rumbles)
- Use silence strategically for maximum impact
- Break silence with meaningful sounds

## Tension Layer System

### Layered Ambient Architecture

Effective ambient soundscapes use multiple layers that can be independently controlled:

**Layer 1: Base Drone**
- Always present (unless surface)
- Low frequency hum or rumble
- Volume increases with depth
- Creates foundation of "underground" feeling

**Layer 2: Environmental Loops**
- Wind, water, settling rocks
- Changes based on location/biome
- Creates sense of space and material
- Multiple loops prevent repetition

**Layer 3: One-Shot Events**
- Random sounds at intervals
- Distant crashes, drips, groans
- Never too frequent (every 10-30 seconds)
- Creates uncertainty: "What was that?"

**Layer 4: Danger Signals**
- Triggered by proximity to hazards
- Distinct from environmental sounds
- Provides gameplay information
- Should feel diegetic (part of the world)

### GoDig Tension Layer Design

```
Depth: Surface
├── Layer 1: No drone (surface is safe)
├── Layer 2: Birds, wind, rustling grass
├── Layer 3: Occasional animal sounds
└── Layer 4: None (no danger at surface)

Depth: 0-100m (Shallow)
├── Layer 1: Very subtle low hum
├── Layer 2: Dripping water, distant echoes
├── Layer 3: Rock settling, small debris falls
└── Layer 4: Hazard proximity cues (muffled)

Depth: 100-500m (Mid)
├── Layer 1: Noticeable pressure hum
├── Layer 2: Cave ambience, flowing water
├── Layer 3: Distant rumbles, creature sounds
└── Layer 4: Hazard cues (clearer)

Depth: 500-1000m (Deep)
├── Layer 1: Heavy low drone
├── Layer 2: Minimal - echoing emptiness
├── Layer 3: Rare, ominous sounds
└── Layer 4: Danger signals more prominent

Depth: 1000m+ (Abyss)
├── Layer 1: Intense pressure drone
├── Layer 2: Almost nothing - eerie void
├── Layer 3: Occasional deep, unknown sounds
└── Layer 4: Maximum danger awareness
```

## Audio Cues for Safety vs Danger

### Communicating Safety

Safe zones should feel distinct:

| Audio Element | Safe Zone Feeling |
|---------------|-------------------|
| **Frequency** | Fuller spectrum, more highs |
| **Reverb** | Natural, shorter decay |
| **One-shots** | Pleasant sounds (birds, chimes) |
| **Drone** | Absent or very light |
| **Music** | Gentle, major key if present |

### Communicating Danger

Danger zones should feel different:

| Audio Element | Danger Zone Feeling |
|---------------|---------------------|
| **Frequency** | Low-heavy, muffled highs |
| **Reverb** | Long, ominous decay |
| **One-shots** | Unsettling sounds (groans, crashes) |
| **Drone** | Present, increasing intensity |
| **Music** | Absent or tense, minor key |

### Transition Design

Moving from safe to danger should be gradual:

```
Shallow (Safe-ish)  →  Mid (Moderate)  →  Deep (Dangerous)
        ↓                   ↓                    ↓
Birds fade out     Drone fades in      Drone intensifies
Full spectrum      Highs reduced       Dominated by lows
Short reverb       Reverb increases    Long, echoing reverb
Frequent sounds    Moderate sounds     Sparse sounds
```

## Implementation Guidelines

### Dynamic Ambient System

```gdscript
# tension_audio_manager.gd
extends Node

# Layer references
var drone_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer
var oneshot_players: Array[AudioStreamPlayer]

# Depth-based parameters
var current_depth: float = 0.0
var drone_volume_curve: Curve  # 0 at surface, max at 1000m
var reverb_curve: Curve  # Short at surface, long at depth

func update_tension_audio(depth: float) -> void:
    current_depth = depth

    # Update drone volume based on depth
    var drone_vol = drone_volume_curve.sample(depth / 1000.0)
    drone_player.volume_db = linear_to_db(drone_vol)

    # Update reverb based on depth
    var reverb_amount = reverb_curve.sample(depth / 1000.0)
    AudioServer.get_bus_effect(ambient_bus, 0).wet = reverb_amount

    # Update ambient track if zone changed
    var new_zone = get_depth_zone(depth)
    if new_zone != current_zone:
        crossfade_ambient(new_zone)
        current_zone = new_zone

func play_random_oneshot() -> void:
    # Called by timer (10-30 second intervals)
    if current_depth < 50:
        return  # No random sounds near surface

    var sound = get_oneshot_for_depth(current_depth)
    var player = get_available_oneshot_player()
    player.stream = sound
    player.volume_db = linear_to_db(randf_range(0.3, 0.6))  # Vary volume
    player.play()
```

### Hazard Proximity Audio

```gdscript
# hazard_audio_trigger.gd
extends Area2D

@export var hazard_sound: AudioStream
@export var max_distance: float = 200.0
@export var is_continuous: bool = false

var audio_player: AudioStreamPlayer2D

func _process(delta: float) -> void:
    if not player_in_range():
        audio_player.stop()
        return

    var distance = global_position.distance_to(player.global_position)
    var volume = 1.0 - (distance / max_distance)
    volume = clampf(volume, 0.0, 1.0)

    audio_player.volume_db = linear_to_db(volume)

    if is_continuous and not audio_player.playing:
        audio_player.play()
```

### One-Shot Randomization

```gdscript
# ambient_oneshot_system.gd
extends Node

# Sounds categorized by depth appropriateness
var shallow_sounds: Array[AudioStream]  # Water drips, small rocks
var mid_sounds: Array[AudioStream]  # Rumbles, distant crashes
var deep_sounds: Array[AudioStream]  # Ominous groans, unknown noises

var min_interval: float = 10.0
var max_interval: float = 30.0

func schedule_next_oneshot() -> void:
    var delay = randf_range(min_interval, max_interval)
    # Longer intervals at greater depths (silence is part of the design)
    if TensionAudioManager.current_depth > 500:
        delay *= 1.5
    await get_tree().create_timer(delay).timeout
    play_oneshot()
    schedule_next_oneshot()

func play_oneshot() -> void:
    var depth = TensionAudioManager.current_depth
    var sounds: Array[AudioStream]

    if depth < 100:
        sounds = shallow_sounds
    elif depth < 500:
        sounds = mid_sounds
    else:
        sounds = deep_sounds

    var sound = sounds[randi() % sounds.size()]
    # Play from random direction
    var player = AudioStreamPlayer2D.new()
    player.stream = sound
    player.position = get_random_offset_position()
    add_child(player)
    player.play()
    player.finished.connect(player.queue_free)
```

## Sound Design Specifications

### Drone Sounds

| Depth Zone | Drone Character | Frequency Range | Volume |
|------------|-----------------|-----------------|--------|
| Surface | None | N/A | 0% |
| Shallow | Subtle hum | 60-100 Hz | 10-20% |
| Mid | Earth pressure | 40-80 Hz | 30-50% |
| Deep | Heavy resonance | 30-60 Hz | 60-80% |
| Abyss | Overwhelming | 20-50 Hz | 80-100% |

### Environmental Loops

| Zone | Loop Elements | Duration | Crossfade Time |
|------|---------------|----------|----------------|
| Surface | Birds, wind, rustling | 60-90s | 3s |
| Shallow | Drips, echoes, air | 45-60s | 5s |
| Mid | Flows, rumbles, settling | 60-90s | 5s |
| Deep | Sparse echoes, silence | 90-120s | 7s |
| Abyss | Near-silence, void | 120-180s | 10s |

### One-Shot Events

| Zone | Sound Types | Frequency | Volume Range |
|------|-------------|-----------|--------------|
| Shallow | Drips, pebbles, squeaks | 10-20s | 30-60% |
| Mid | Rocks, distant crashes | 15-30s | 40-70% |
| Deep | Groans, unknowns | 20-40s | 50-80% |
| Abyss | Rare ominous sounds | 30-60s | 60-90% |

## Avoiding Common Pitfalls

### Don't Overdo Tension

**Problem**: Constant tension is exhausting and becomes background noise
**Solution**: Vary intensity, provide relief moments, let players relax at surface

### Don't Telegraph Too Obviously

**Problem**: Obvious danger music says "monster here" and breaks immersion
**Solution**: Use environmental sounds that feel diegetic (part of the world)

### Don't Annoy the Player

**Problem**: Repetitive sounds become irritating after 10 minutes
**Solution**: Large sound pools, randomization, varied intervals

### Don't Forget Accessibility

**Requirements**:
- All audio can be disabled
- Visual alternatives for audio cues
- Subtitle system for important sounds
- Volume controls per category

## Testing Checklist

- [ ] Play for 30 minutes - does any sound become annoying?
- [ ] Can you identify depth by audio alone?
- [ ] Does silence feel intentional or broken?
- [ ] Are danger cues audible but not jarring?
- [ ] Does surface feel safe and welcoming?
- [ ] Does deep feel tense and oppressive?
- [ ] Do transitions feel smooth?
- [ ] Are one-shots varied enough?
- [ ] Does audio work with music off?
- [ ] Is audio disabled accessible?

## Summary: GoDig Tension Audio Strategy

### Core Principles

1. **Depth = Audio pressure**: Deeper means heavier, lower, more oppressive
2. **Silence is active design**: Strategic absence creates more tension than constant sound
3. **Environmental > Musical**: Diegetic sounds feel more immersive
4. **Gradual transitions**: Never jarring changes between zones
5. **Randomization prevents fatigue**: Variety in timing and sound selection

### Priority Implementation

**MVP (v1.0):**
- Basic depth-based drone system
- Surface/underground ambient distinction
- Simple hazard proximity audio
- Volume controls

**Post-Launch (v1.1):**
- Full layer system (drone + ambient + one-shots)
- Smooth zone transitions
- Varied one-shot pools
- Biome-specific sounds

**Polish (v1.2+):**
- Dynamic music integration
- Advanced reverb based on cave geometry
- Creature-specific audio tells
- Audio accessibility features
