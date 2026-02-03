# Audio Accessibility in Mining Games

*Research Session 26 - Sound Cues for Gameplay Information*

## Overview

Audio accessibility enables players with visual impairments to enjoy games through sound cues, spatial audio, and haptic feedback. Mining games have unique opportunities because digging creates natural audio feedback. This document explores how to make GoDig playable through audio.

## Why Audio Accessibility Matters

From [American Foundation for the Blind](https://afb.org/aw/fall2023/Blindness-Accessibility-in-Video-Games-A-Deep-Dive):

> "Game developers should follow design principles to ensure games are fully accessible to blind players. First, if two items look different, they must sound different."

**Key principle**: Every visual distinction should have an audio equivalent.

## The Gold Standard: The Last of Us Part II

From [PlayStation Blog](https://blog.playstation.com/2020/06/09/the-last-of-us-part-ii-accessibility-features-detailed/):

> "The Last of Us Part II features more than 60 accessibility settings... it was the first title to promise 100% accessibility to blind players."

### Navigation Assistance

From [Can I Play That?](https://caniplaythat.com/2020/06/18/the-last-of-us-2-review-blind-accessibility/):

> "Pressing L3 faces the camera in the direction of story progression, marking the path to follow."

**For GoDig**: Implement "point to surface" audio cue that plays distinct sound in the direction of the nearest exit.

### Audio Cue System

> "Traversal and Combat Audio Cues work alongside the game's audio to map easily identifiable sounds to commonly used actions (scavenging pickups, jumping across gaps, dodging incoming melee attacks, etc.)."

> "There are audio cues that tell you which button to push, and even the object you are interacting with."

**For GoDig**: Each interaction should have:
1. Object identification sound
2. Action feedback sound
3. Result confirmation sound

### Text-to-Speech

> "Text-to-Speech is a key feature for low vision players as it helps with all aspects of the game, from menus to in-game text, map navigation, and prompts in tutorials."

**For GoDig**: All UI text should be speakable on focus.

## Core Audio Accessibility Principles

From [Audiokinetic Blog](https://www.audiokinetic.com/en/blog/blind-accessibility-in-interactive-entertainment/):

### Spatial Positioning

> "Spatial positioning provides intuitive knowledge of the direction of an object while volume does the same for distance in most cases."

**Implementation**:
- Stereo panning shows left/right
- Volume shows distance
- Reverb shows enclosure (cave vs open)

### Distinct Sound for Distinct Items

> "Most objects in the real world make unique sounds, so developers should avoid populating games with items that make no sound and ensure that item or game state changes are accompanied by audio cues."

**Mining game application**:
| Object | Sound Characteristic |
|--------|---------------------|
| Dirt block | Soft, earthy thud |
| Stone block | Hard, sharp crack |
| Ore block | Metallic ring |
| Rare ore | Higher pitch + sparkle |
| Cave opening | Echo/reverb change |
| Hazard | Warning tone |

### Pitch for Information

> "Pitch can be used to indicate information that more natural sound might not."

**For mining**:
- Higher pitch = rarer ore
- Lower pitch = harder block
- Rising pitch = getting closer to ore
- Falling pitch = getting further from surface

## Mining-Specific Audio Design

From [Twinfinite - New World Sound Design](https://twinfinite.net/pc/new-worlds-impressive-sound-design-makes-me-want-to-mine-rocks-forever/):

> "The sound of a pickaxe plunging into an iron vein sounds different depending on location. If mining out in the open air, the audio effect sounds off once and fades out slowly. But if mining in a cave, it sounds more defined and echoey."

> "The sound effects for regular boulders, iron veins, silver veins, gold veins, and starmetal veins are all different."

### Material-Based Sounds

Each ore type needs:
1. **Proximity sound** - Ambient hum when nearby
2. **Discovery sound** - When block is revealed
3. **Mining sound** - During break animation
4. **Collection sound** - When picked up

### Environmental Audio

Cave acoustics should change based on:
- Depth (more reverb deeper)
- Cave size (larger = longer reverb tail)
- Material (stone echoes more than dirt)

## Ore Detection Audio System

### Proximity Detection

Implement "metal detector" style audio:

```gdscript
# Audio increases in pitch and tempo as player nears ore
func update_ore_proximity_audio():
    var nearest_ore = find_nearest_ore()
    if nearest_ore:
        var distance = global_position.distance_to(nearest_ore.global_position)
        var normalized = clamp(1.0 - distance / detection_range, 0, 1)

        # Pitch rises as player gets closer
        ore_detector.pitch_scale = 0.5 + (normalized * 1.5)

        # Beeps get faster
        beep_timer.wait_time = 2.0 - (normalized * 1.8)
```

### Directional Hints

From [A Sound Effect - Game Audio Accessibility](https://www.asoundeffect.com/game-audio-blind-accessibility/):

> "Developers can build consistent orientation cues into 3D environments. For example, modifying hallway noises so that north-south-oriented hallways make a slightly different sound from east-west hallways."

**For GoDig**:
- Left/right stereo panning for ore direction
- Distinct pitch for ore above vs below

## Audio Settings Menu

### Essential Controls

From [Gamedeveloper - Playing by Ear](https://www.gamedeveloper.com/audio/playing-by-ear-using-audio-to-create-blind-accessible-games):

> "Games should provide individual sliders for audio channels in the menu: music, sound effects, dialogues, accessibility sounds (or audio cues), and a mono/stereo slider."

**GoDig Audio Settings**:

```
Music Volume ................ [====|     ] 50%
Sound Effects Volume ........ [=======|  ] 80%
UI Sound Volume ............. [========| ] 90%
Accessibility Cues Volume ... [=========|] 100%

[ ] Mono Audio (combine stereo to single channel)
[ ] Audio Descriptions (TTS for visual elements)
[ ] Ore Proximity Beeps
[ ] Surface Direction Hint
```

### Sound Glossary

From [Naughty Dog Blog](https://www.naughtydog.com/blog/the_last_of_us_part_ii_accessibility_features_detailed):

> "The game provides a sound glossary menu where users can scroll through audio cues and hear what they sound like and what they are used for during gameplay."

**For GoDig**: Include a "Sound Guide" in settings where players can:
1. Play each ore type's sound
2. Play each block type's sound
3. Play each action's sound
4. Learn what each accessibility cue means

## Haptic Feedback Integration

### When to Vibrate

| Event | Vibration Pattern | Purpose |
|-------|-------------------|---------|
| Block break | Short pulse | Feedback |
| Ore discovered | Double pulse | Alert |
| Rare ore | Triple pulse | Excitement |
| Fall landing | Strong thump | Impact |
| Low health | Rhythmic pulse | Warning |
| Near surface | Gentle pulse | Navigation |

### Vibration Settings

From [Gameplay - Blind Gaming](https://gameplay.co/blind-gaming-audio-games-accessibility/):

> "Haptic feedback provides physical sensation that complements audio cues."

**Settings to offer**:
- Vibration on/off
- Vibration intensity (1-10)
- Vibration for gameplay only (no UI)
- Custom patterns for different events

## Accessibility Presets

### Vision Impaired Preset

Enable by default:
- Maximum accessibility cue volume
- Text-to-speech on
- Ore proximity beeps on
- Surface direction hints on
- High contrast mode on
- Large text

### Low Vision Preset

Enable by default:
- Enhanced visual contrast
- Larger UI elements
- Audio cues supplementing visuals
- Screen reader on demand

## Implementation Priority

### MVP (Must Have)

1. **Distinct ore sounds** - Each ore type sounds different
2. **Mining feedback** - Clear audio for block break
3. **Pickup confirmation** - Sound when item collected
4. **UI sounds** - Button presses, menu navigation
5. **Volume sliders** - Separate music/SFX/UI

### v1.0 (Should Have)

1. **Ore proximity beeps** - Getting warmer/colder
2. **Surface direction hint** - Audio pointing home
3. **Hazard warnings** - Distinct danger sounds
4. **Cave acoustics** - Reverb based on space
5. **Text-to-speech** - For menus and HUD

### v1.1 (Nice to Have)

1. **Sound glossary** - Learn all game sounds
2. **Full screen reader** - All game text spoken
3. **Custom audio cue volume** - Per-cue adjustment
4. **Directional stereo ore hints** - L/R panning

## Testing Approach

### With Blind Testers

1. Can they navigate to surface using audio?
2. Can they distinguish ore types by sound?
3. Can they avoid hazards through audio cues?
4. Can they complete a full dig-sell loop?

### Simulated Testing

1. Play with screen off - is game playable?
2. Play with low contrast filter - are cues sufficient?
3. Play in noisy environment - are cues distinct enough?

## Sources

- [Audiokinetic Blog - Blind Accessibility](https://www.audiokinetic.com/en/blog/blind-accessibility-in-interactive-entertainment/)
- [American Foundation for the Blind - Video Games](https://afb.org/aw/fall2023/Blindness-Accessibility-in-Video-Games-A-Deep-Dive)
- [Gamedeveloper - Playing by Ear](https://www.gamedeveloper.com/audio/playing-by-ear-using-audio-to-create-blind-accessible-games)
- [A Sound Effect - Game Audio Accessibility Guide](https://www.asoundeffect.com/game-audio-blind-accessibility/)
- [PlayStation Blog - TLOU2 Accessibility](https://blog.playstation.com/2020/06/09/the-last-of-us-part-ii-accessibility-features-detailed/)
- [Can I Play That? - TLOU2 Blind Review](https://caniplaythat.com/2020/06/18/the-last-of-us-2-review-blind-accessibility/)
- [Naughty Dog - Accessibility Features](https://www.naughtydog.com/blog/the_last_of_us_part_ii_accessibility_features_detailed)
- [Twinfinite - New World Sound Design](https://twinfinite.net/pc/new-worlds-impressive-sound-design-makes-me-want-to-mine-rocks-forever/)
- [Gameplay - Blind Gaming](https://gameplay.co/blind-gaming-audio-games-accessibility/)
- [Wikipedia - Audio Games](https://en.wikipedia.org/wiki/Audio_game)

## Related Implementation Tasks

- `GoDig-implement-distinct-audio-450bc8be` - Distinct audio for each ore type
- `GoDig-implement-haptic-feedback-92e67c42` - Haptic feedback for ore discovery
- `GoDig-implement-subtle-tension-0b659daa` - Subtle tension audio layer
- `GoDig-research-accessibility-4042c8e1` - Accessibility Features research
