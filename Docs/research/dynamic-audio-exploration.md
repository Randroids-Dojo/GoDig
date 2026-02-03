# Procedural Music and Dynamic Audio in Exploration Games

> Research into how games use dynamic audio to enhance exploration and depth-based progression without repetition fatigue.

## Executive Summary

The best exploration games use audio as a **character in its own right** - not constant background noise, but a responsive element that reinforces gameplay states. Key principles: use **silence strategically**, **layer audio** based on context, ensure **seamless transitions** between areas, and create **distinct sonic identities** for each zone. Procedural/adaptive music is increasingly accessible to indie developers, but requires careful design to feel cohesive rather than random.

**Key Insight for GoDig**: Our depth-based progression provides natural audio layering opportunities. Surface should feel warm/cozy, underground should feel increasingly alien/isolated, with silence playing a crucial role in tension.

---

## Industry Trends: Adaptive Audio 2024-2025

### Market Growth

- Over 60% of game developers exploring AI-driven audio tools (2024 report)
- Generative audio market projected at $1.81 billion by 2025
- Studies show adaptive soundtracks increase play sessions by 68%
- Adaptive soundtracks becoming industry standard by 2026

### Technical Accessibility

"Adaptive sound scoring is now achievable even for indie developers without access to large orchestras or specialized sound designers."

**Key tools**:
- **FMOD**: Industry-standard audio middleware
- **Wwise**: Professional game audio solution
- **Pure Data**: Embedded procedural audio (used by Spore)
- **Unity/Godot built-in**: Native audio mixing and layering

### Procedural Generation Techniques

| Technique | Description | Use Case |
|-----------|-------------|----------|
| **Markov Chains** | Probability-based transitions between musical states | Melodies with continuity + variation |
| **Genetic Algorithms** | Evolve compositions over time | Complex, aesthetically pleasing music |
| **Layer-based** | Toggle/blend pre-composed layers | Combat intensity, exploration modes |
| **Rule-based** | Trigger music based on game state | Biome changes, danger levels |

---

## The Power of Silence

### Why Silence Matters

"Knowing when NOT to have music is one of the most important and overlooked aspects of music in media."

**Key insight**: "Music will always diminish other sounds and, worse, will prevent silence. Sometimes there's nothing more effective than having no music."

### When to Use Silence

| Situation | Effect | GoDig Application |
|-----------|--------|-------------------|
| **Dramatic moments** | Weight, emotional processing | Deep ore discovery, close call survival |
| **Amplifying ambiance** | Immersion, presence | Deep underground, isolated chambers |
| **Building tension** | Hyper-awareness, vulnerability | Low ladders, dangerous depth |
| **Contrasting gameplay** | Action feels exciting, exploration serene | Return trip vs active mining |
| **Player agency** | Freedom without emotional dictation | Open exploration, route planning |

### Horror Games as Teachers

"Rarely do horror games have constant backing music, because that undermines the immersion. Instead, they have an eerie ambience... punctuated by stingers when something particularly scary happens."

Examples: Silent Hill, Resident Evil, Amnesia, Soma

**GoDig lesson**: Don't fill every moment with music. Let the underground feel isolated.

---

## Case Study: Subnautica - Depth as Audio Dimension

Subnautica uses depth as a primary driver of audio atmosphere.

### Recording Philosophy

The developers used actual underwater recordings via hydrophone, but "weren't going for realism - they're not making a simulator."

Goal: "Something like Avatar/Star Wars but underwater."

**Key insight**: Real-world reference informs the design, but the result should serve the gameplay fantasy, not accuracy.

### Sound as Fear and Curiosity

"While the visuals build terror by hindering the player's vision, it is the sounds in the distance, distorted by the water, that create Subnautica's excellent atmosphere."

"The soundtrack, composed of electronic sounds flowing in and out like the ocean's currents, reinforces the intended alien atmosphere."

### Strategic Music Absence

"The game doesn't have continuous background music matching the current location... it can feel jarring when music does play during certain events."

This was a deliberate choice to make music moments more impactful.

### GoDig Application

| Subnautica Approach | GoDig Adaptation |
|--------------------|------------------|
| Distorted distant sounds | Echoing cave sounds, unknown rumbles at depth |
| Music as punctuation, not background | Music for discoveries, silence for exploration |
| Electronic + organic blend | Sci-fi tones mixed with earthy mining sounds |
| Depth changes audio character | Each layer has distinct ambient profile |

---

## Case Study: Minecraft - Biome-Based Ambient System

Minecraft's ambient system is often underappreciated for its complexity.

### Vanilla Ambient Categories

**Environmental Ambience**:
- 23 different cave ambience sounds
- 22 underwater ambience sounds
- 126 Nether ambience sounds (across 5 biomes)

**Block Ambience**:
- Specific blocks emit ambient sounds when conditions are met
- Dead bushes emit sounds on sand
- Eyeblossoms emit "eerie noise" on pale moss

### The "Mood" System

"Cave ambience and Nether mood play based on 'mood', a value ranging from 0 to 100. The mood increases when the player is in a dark place, and decreases otherwise."

This creates natural tension in darkness without explicit danger mechanics.

### Community Mods Show Desired Features

**Biome Music Mod** features:
- Biomes play mix of general + category-specific music
- Modded biome support via tags
- Customizable playback conditions (caves, night, underwater, dimensions)
- Performance optimization for sound pool limits

**MAtmos** (ambient sound mod):
- 160+ dynamic ambient effects
- Analyzes player context in real-time (biome, indoors/outdoors, cave/Nether, near water, etc.)
- True spatial sound environment

**Dynamic Ambience and Music Mod**:
- Custom region definitions with unique audio
- Runtime sound loading (no restart needed)
- Smooth transitions between regions

### GoDig Application

| Minecraft Pattern | GoDig Implementation |
|-------------------|---------------------|
| Mood-based triggers | Tension audio increases with danger state |
| Biome-specific sounds | Layer-specific ambient profiles |
| Block ambience | Ore-adjacent sparkle/hum sounds |
| Spatial audio | Sounds echo based on cave structure |

---

## Case Study: Hollow Knight - Area Identity Through Instrumentation

Christopher Larkin's Hollow Knight score demonstrates how instrument choice creates distinct area identities.

### Instrumentation by Area

| Area | Instruments | Visual Quality Matched |
|------|-------------|----------------------|
| Greenpath | Harp, marimba, earthy tones | Natural, organic forest |
| Soul Sanctum | Gothic organ | Cold, old scholarly |
| Crystal Peak | Kalimba, wine glasses, guitar harmonics | Shiny, crystal sounds |

"The visual qualities and the context of the areas have a large impact in the choice of instruments and sounds."

### Dynamic Transitions

"Individual melodies and instruments will shift in and out as you move from screen to screen."

Technical implementation: Unity's mixer system fades between mix snapshots for transitions.

### Reverb as Character

"[Hollow Knight] takes place, for the most part, in caves. So it makes sense for each space to have its own acoustic character."

Different reverb zones create sense of space - tight tunnels vs open caverns.

### Evolving Themes

"The musical scores in previously heard areas change as the player becomes capable of different abilities... Subtle transitions in sound reflect that, at times, the player develops their relation to the world."

### Leitmotifs for Recognition

"Hearing [the Shade theme] from a distance will always tell you the Shade is close."

Audio cues can communicate game state before visuals confirm it.

### GoDig Application

| Hollow Knight Technique | GoDig Implementation |
|------------------------|---------------------|
| Area-specific instruments | Topsoil: organic, Surface: cozy, Deep: electronic/alien |
| Reverb zones | Tight mining sounds vs echo in caves |
| Evolving themes | Music gains layers as player progresses/upgrades |
| Leitmotifs | Ore type sounds, danger proximity cues |

---

## Case Study: Dead Cells - Action Intensity Balance

Dead Cells composer Yoann Laulan explored adaptive music but made interesting choices.

### Original Plan vs Final Implementation

"The idea at the beginning was to have something catchy to start the level, then when you don't have a lot of enemies and action left, the music would loop into something more ambient."

"We had different ideas with more 'modern' approach with dynamic music and different layers, but it was hard to imagine them working in such a random game, especially with its audio engine, which is in some ways very limited."

### Repetition Consideration

Early music was "very ambient because the composer was afraid that having something too melodic would be annoying to listen to over and over."

But player feedback showed "more action-paced music was really appreciated."

**Lesson**: Don't assume players want less - test assumptions with real feedback.

### Influences for Mining Games

"As the game took inspiration from Castlevania and Dark Souls... there are some vibes from those games in the soundtrack."

The song "Wilderness" from Diablo 2 influenced guitar arpeggios.

---

## Adaptive Music Architecture for GoDig

Based on this research, here's a proposed audio architecture:

### Layer System (Depth-Based)

```
SURFACE (0m):
  - Cozy ambient base
  - Warm instruments (acoustic, wood)
  - Bird sounds, wind, peaceful activity
  - Full dynamic range

TOPSOIL (0-50m):
  - Muffled surface sounds
  - Earth tones, subtle percussion
  - Occasional silence
  - First underground reverb

SUBSOIL (50-200m):
  - Surface sounds fade completely
  - Dripping water, settling earth
  - Minimal music, mostly ambient
  - Medium reverb

STONE (200-500m):
  - Deeper tones, electronic elements emerge
  - Cave echoes, distant rumbles
  - Music sparse but distinctive
  - Large reverb on open areas

DEEP STONE (500-1000m):
  - Alien/unfamiliar sounds
  - Electronic drones
  - Long silences punctuated by stingers
  - Variable reverb (tight/open)

CRYSTAL+ (1000m+):
  - Full electronic/sci-fi palette
  - Crystalline tones, strange harmonics
  - Music more present but unsettling
  - Heavy processing on all sounds
```

### State-Based Layers

| Game State | Audio Layer | Transition |
|------------|-------------|------------|
| Exploring | Base ambient | Immediate |
| Mining | Add rhythmic percussion | Crossfade 0.5s |
| Ore found | Celebratory sting | Overlay, fade out |
| Low ladder | Tension layer | Fade in over 3s |
| Danger imminent | Remove music, amp ambient | Quick fade 1s |
| Return journey | Lighter version of depth music | Crossfade 2s |
| Surface reached | Full cozy theme | Swell up |

### Silence Zones

Designate specific situations for NO music:
- First 30 seconds in new depth layer (let player absorb new sounds)
- After ore discovery celebration (moment of satisfaction)
- When ladder count critical (tension through absence)
- Deep caves (isolation feeling)

### Instrument Mapping

| Layer | Primary | Secondary | Accent |
|-------|---------|-----------|--------|
| Surface | Acoustic guitar | Flute | Bells |
| Topsoil | Marimba | Soft strings | Chimes |
| Subsoil | Cello | Piano (sparse) | Water drops |
| Stone | Bass synth | String pads | Metallic hits |
| Deep Stone | Electronic drones | Distorted strings | Unknown sounds |
| Crystal | Crystalline synths | Processed choir | Alien tones |

---

## Technical Implementation Notes

### Godot Audio Considerations

- Use AudioStreamRandomizer for ambient variation
- AudioBus system for layer mixing
- Area2D triggers for zone-based audio changes
- Tween for smooth crossfades

### Performance Optimization

From Minecraft modding community:
- "Only play sounds on client-side, as server wide sounds can lag"
- Limit duplicate simultaneous sounds
- Skip inaudible distant sounds
- Monitor sound pool limits

### Transition Design

- **Crossfade duration**: 1-2 seconds for area changes
- **Layer blend**: Volume ducking on lower priority layers
- **Stinger timing**: Brief (0.5-1s) for discoveries, longer (2-3s) for major events

---

## GoDig-Specific Recommendations

### 1. Depth Audio Gradient

Create smooth progression from warm surface to alien depths:
- Surface: Cozy, safe, home
- Shallow: Muffled warmth
- Mid: Mysterious, neutral
- Deep: Tension, unfamiliarity
- Deepest: Alien, rewarding (you earned this)

### 2. Strategic Silence

Use silence as a tool:
- After ore discovery (satisfaction moment)
- When danger is high (tension through absence)
- In new areas (let player absorb)
- Before major reveals (build anticipation)

### 3. Mining Satisfaction Sounds

Mining should feel GOOD:
- Progressive crack sounds
- Satisfying break sound per block type
- Ore discovery distinct from regular blocks
- Rare ore with special audio treatment

### 4. Return Journey Audio

The return trip needs careful handling:
- Lighter/faster version of depth music
- Upward movement should feel like progress
- Surface proximity cues (birds, warmth)
- Triumphant swell when reaching surface with loot

### 5. Danger Communication

Audio should communicate danger before death:
- Low ladder warning sound
- Depth danger ambient
- Proximity to hazards
- "You've been here too long" subtle cues

---

## Implementation Phases

### Phase 1: Foundation
- [ ] Set up AudioBus structure (music, ambient, sfx)
- [ ] Create depth-based audio zones
- [ ] Implement basic ambient per layer
- [ ] Add mining sound effects

### Phase 2: Adaptive Elements
- [ ] State-based music layers
- [ ] Crossfade system for transitions
- [ ] Ore discovery stingers
- [ ] Danger tension layer

### Phase 3: Polish
- [ ] Reverb zones for cave structure
- [ ] Silence implementation
- [ ] Return journey audio progression
- [ ] Surface homecoming celebration

### Phase 4: Optimization
- [ ] Performance testing
- [ ] Sound pool management
- [ ] Volume balancing pass
- [ ] Accessibility options (music/sfx sliders)

---

## Sources

- [AI Music for Gaming: Enhancing Creativity and Immersion](https://www.soundverse.ai/blog/article/ai-music-for-gaming)
- [Adaptive Music - Wikipedia](https://en.wikipedia.org/wiki/Adaptive_music)
- [Procedural Music Generation in Video Games](https://www.ijfmr.com/papers/2025/2/39384.pdf)
- [Level Up! Procedural Game Music and Audio - Audio Developer Conference](https://conference.audio.dev/session/2025/level-up)
- [Unknown Worlds - Underwater Sound Recording for Subnautica](https://unknownworlds.com/en/news/underwater-sound-recording-subnautica)
- [Minecraft Ambience Wiki](https://minecraft.wiki/w/Ambience)
- [Biome Music Mod](https://www.curseforge.com/minecraft/mc-mods/biome-music)
- [MAtmos Ambient Sound Mod](https://www.curseforge.com/minecraft/mc-mods/matmos2)
- [The Power of Sound Design and Music in Modern Metroidvania Indie Games](https://www.thegameaudioco.com/the-power-of-sound-design-and-music-in-modern-metroidvania-indie-games-a-deep-dive-of-blasphemous-2-hollow-knight-and-nine-sols)
- [Inside Christopher Larkin's Darkly Elegant "Hollow Knight" Score](https://daily.bandcamp.com/features/christopher-larkin-review)
- [Crafting an Evocative Score for Hollow Knight](https://www.gamedeveloper.com/audio/crafting-an-evocative-score-for-i-hollow-knight-i-)
- [Dead Cells Soundtrack Interview - Bandcamp Daily](https://daily.bandcamp.com/high-scores/high-scores-yoann-laulan-interview)
- [How Video Games Use Silence To Great Effect](https://www.thegamer.com/how-video-games-use-silence-to-great-effect/)
- [How to Use Music Properly in Games - Reddit](https://www.reddit.com/r/gamedev/comments/116atow/how_to_use_music_properly_in_games_in_depth/)
- [Music in Video Games - Game Developer](https://www.gamedeveloper.com/audio/music-in-video-games)

---

*Research completed: 2026-02-02*
*Session: 29*
