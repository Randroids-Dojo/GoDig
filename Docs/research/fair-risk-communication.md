# Fair Risk Communication: Warning Systems That Feel Fair

## Overview

This research documents how games communicate danger effectively without frustrating players. The goal is to ensure GoDig never delivers "gotcha" deaths but instead creates fair challenges where players understand risks and can respond appropriately.

## Sources

- [Anatomy of an Enemy Attack in Dark Souls 3 - Gamasutra](https://www.gamedeveloper.com/game-platforms/anatomy-of-an-enemy-attack-in-dark-souls-3)
- [Enemy Attacks and Telegraphing - Gamasutra](https://www.gamedeveloper.com/design/enemy-attacks-and-telegraphing)
- [Game Design Discussion: 'Gotcha!' Game Mechanics - Punished Backlog](https://punishedbacklog.com/game-design-discussion-gotcha-game-mechanics/)
- [How Dark Souls Changed Combat - CritPoints](https://critpoints.net/2020/09/12/how-dark-souls-changed-combat/)
- [The Design Lessons Designers Fail to Learn From Dark Souls](https://www.gamedeveloper.com/design/the-design-lessons-designers-fail-to-learn-from-dark-souls)
- [Critical Annoyance - TV Tropes](https://tvtropes.org/pmwiki/pmwiki.php/Main/CriticalAnnoyance)
- [10 Most Alarming Low-Health Warnings In Games - TheGamer](https://www.thegamer.com/most-alarming-low-health-warnings-in-games/)
- [Visualization in Games: Health Changes](http://www.diva-portal.org/smash/get/diva2:1427214/FULLTEXT01.pdf)
- [It's a Trap! - The Angry GM](https://theangrygm.com/its-a-trap/)
- [Environmental Hazards in Game Design - Meegle](https://www.meegle.com/en_us/topics/game-design/environmental-hazards)

## The "Tough But Fair" Philosophy

### What It Means

"Tough, but fair" describes the Souls formula: games that challenge players but always provide the information needed to succeed. The experience isn't about overwhelming difficulty - it's about mastery.

**Key insight**: Souls games get easier the further you play because mastering the rules equips players to deal with challenges. The difficulty comes from learning, not from unfair mechanics.

### Core Principles

1. **Every death should feel earned** - The player should know what killed them
2. **Information precedes danger** - Telegraph before damage occurs
3. **Consistent rules** - Same attack, same tell, same timing
4. **Player agency** - Always a way to respond if you know the rules

## The Anatomy of Fair Danger

### The Three Phases of Attack

From Dark Souls 3 analysis, every enemy attack has three phases:

**1. Anticipation (Wind-Up)**
- Duration: 200-500ms minimum for new attacks
- Purpose: Signal "I'm about to attack"
- Visual: Distinct pose, weapon position change
- Audio: Sound cue (growl, weapon sound)

**2. Attack (Execution)**
- Duration: 50-150ms typically
- Purpose: The actual damage event
- Visual: Clear motion, hitbox matches animation
- The player cannot react here - too fast

**3. Recovery (Cool-Down)**
- Duration: 200-500ms
- Purpose: Punish window for skilled players
- Visual: Return to neutral pose
- Player opportunity: Counter-attack, heal, reposition

### Minimum Reaction Time

Research on Dark Souls suggests:
- **Minimum 340ms** combined anticipation + attack for known moves
- **Longer** for new or complex attacks players haven't seen
- **Human reaction time**: ~250ms average
- **Margin needed**: At least 90ms buffer for decision-making

## Telegraphing Techniques

### Visual Telegraphs

| Technique | Description | Example |
|-----------|-------------|---------|
| **Wind-up animation** | Character prepares attack | Arm raised before swing |
| **Pose change** | Body position signals intent | Crouching before jump |
| **Color change** | Visual warning of danger | Enemy glows red |
| **Particle effects** | Area-of-effect preview | Ground sparkles before explosion |
| **Environmental cues** | Level design signals danger | Bones around spike trap |
| **UI indicator** | Explicit danger warning | "!" above enemy head |

### Audio Telegraphs

| Technique | Description | Example |
|-----------|-------------|---------|
| **Attack vocalization** | Enemy makes sound before attack | Growl, shout, inhale |
| **Weapon sound** | Equipment makes distinct noise | Sword scraping |
| **Environmental audio** | Danger area has distinct sound | Bubbling lava |
| **Music shift** | Soundtrack signals danger | Tempo increase |
| **Ambient warning** | Subtle sound precedes hazard | Cracking floor sound |

### For GoDig Mining Context

| Hazard | Visual Telegraph | Audio Telegraph | Timing |
|--------|-----------------|-----------------|--------|
| **Unstable ceiling** | Cracks visible, dust particles | Creaking sound | 1-2 sec before fall |
| **Gas pocket** | Discolored rock, vapor wisps | Hissing sound | 0.5 sec before release |
| **Hot zone** | Red/orange rock tint, shimmer | Low rumble | Continuous warning |
| **Enemy approach** | Glowing eyes, movement in darkness | Distinct footsteps | 2-3 sec before attack |
| **Weak floor** | Different texture, visual cracks | Hollow sound when near | Continuous warning |

## "Gotcha" Deaths vs Fair Challenges

### What Makes Death Feel Unfair

| "Gotcha" Pattern | Why It's Unfair |
|------------------|-----------------|
| **No warning** | Player couldn't know danger existed |
| **Inconsistent timing** | Same attack, different reaction windows |
| **Camera failure** | Danger off-screen with no audio cue |
| **First-time kill** | New mechanic that kills before teaching |
| **RNG death** | Random instant-kill with no counterplay |
| **Input eating** | Player action ignored during danger |

### What Makes Death Feel Fair

| Fair Pattern | Why It Works |
|--------------|--------------|
| **Clear telegraph** | Player saw/heard the warning |
| **Consistent rules** | Same situation, same result |
| **Learnable** | After one death, player knows to avoid |
| **Escapable** | With correct response, damage avoided |
| **Graduated** | Warning → minor damage → major damage |
| **Explained** | Player understands what went wrong |

### GoDig "No Gotcha" Rules

1. **No instant-kill hazards** without multi-second warning
2. **No off-screen threats** that can kill without audio cue
3. **No RNG deaths** - all hazards are deterministic
4. **First encounter** always deals warning damage, not death
5. **Visual + audio** for all danger (accessibility)
6. **Damage builds** before killing (health chip, then burst)

## Low Health Warning Systems

### The Purpose of Low Health Warnings

Warnings serve to:
1. Alert player they're in danger
2. Create tension and stakes
3. Prompt strategic change (retreat, heal, be careful)
4. Provide feedback on damage taken

### Common Warning Methods

**Visual:**
- Screen edge vignette (red, black)
- Health bar flashing
- Character visual change (limping, bleeding)
- Screen desaturation
- Pulsing/breathing screen effect

**Audio:**
- Heartbeat sound
- Music change (more tense)
- Breathing sounds
- Warning beep/alarm
- Character vocalizations

**Haptic:**
- Controller vibration matching heartbeat
- Increasing intensity as health drops

### The "Critical Annoyance" Problem

TV Tropes documents how low health warnings can backfire:
- **Zelda** heart beeping drives players "to near insanity"
- Screen filters obscure vision precisely when players need it most
- Loud heartbeats cover up gameplay-critical audio
- Warning systems compound the difficulty of survival

### Best Practices for Health Warnings

**Do:**
- Keep warnings subtle enough to not impede gameplay
- Provide clear "safe" feedback when healed
- Allow players to disable or adjust warnings
- Use graduated intensity (50% health vs 10% health)
- Provide useful information (not just "you're dying")

**Don't:**
- Obscure the screen when vision is most needed
- Drown out enemy audio cues
- Create constant annoying noise
- Make warnings louder than the actual danger
- Punish the player for being in danger

### GoDig Health Warning Design

**At 50% Health:**
```
Visual: Subtle red vignette at screen edges
Audio: None (too early for alarm)
Haptic: None
Purpose: "Be aware, but don't panic"
```

**At 25% Health:**
```
Visual: Stronger vignette, health bar pulses
Audio: Soft heartbeat (subtle, not intrusive)
Haptic: Optional gentle pulse on hit
Purpose: "Consider retreating or healing"
```

**At 10% Health (Critical):**
```
Visual: Maximum vignette, screen slightly desaturated
Audio: Faster heartbeat, but still background level
Haptic: Stronger pulse matching heartbeat
Purpose: "Immediate action needed"
```

**Key Principles:**
- Never obscure center of screen where gameplay happens
- Audio never louder than hazard sounds
- All warnings disable-able in settings
- Warnings suggest retreat (surface), not just panic

## Environmental Hazard Communication

### The Angry GM's Trap Philosophy

From tabletop gaming insights that apply to video games:

"Dark Souls, Bloodborne, and Elden Ring make everything you need to know visible in the environment. You can see pressure plates and trip wires. You can see the holes from which spikes issue. And you can see the corpses, bones, and bloodstains from previous victims."

### Telegraphing as Difficulty Control

"Telegraphing is actually a secret difficulty knob. The more noticeable the trap, the more likely the players will notice and investigate it."

| Difficulty | Telegraph Level | Example |
|------------|-----------------|---------|
| **Easy** | Obvious, multiple cues | Crumbling floor + sound + particles + bones |
| **Medium** | Clear but single cue | Crumbling texture on floor |
| **Hard** | Subtle, requires attention | Slight color difference in floor |
| **Unfair** | No telegraph | Floor identical, instant death |

### GoDig Environmental Hazards

**Hazard: Falling Rocks**
```
Telegraph:
- Visual: Cracks in ceiling, dust particles falling
- Audio: Creaking, grinding sounds
- Timing: 1.5 seconds from visual to impact
- Escape: Move 2 tiles away
- Damage: 30% health (not instant death)
```

**Hazard: Gas Pocket**
```
Telegraph:
- Visual: Different rock color (greenish), vapor wisps
- Audio: Hissing when adjacent
- Timing: 0.5 seconds after breaking rock
- Escape: Move away before cloud expands
- Damage: 20% health per second in cloud, 3 second duration
```

**Hazard: Hot Zone (Deep)**
```
Telegraph:
- Visual: Red/orange tinted rocks, heat shimmer
- Audio: Low rumble, sizzling
- Timing: Continuous (zone-based)
- Mitigation: Heat-resistant gear, or quick passage
- Damage: 5% health per 3 seconds in zone
```

**Hazard: Unstable Floor**
```
Telegraph:
- Visual: Cracked texture, slightly different color
- Audio: Hollow sound when player steps on/near
- Timing: 1 second after stepping on
- Escape: Quick movement, or don't step on
- Damage: Fall damage based on depth below
```

## Difficulty Communication Without Numbers

### The Problem with Numbers

Showing explicit damage numbers or health percentages can:
- Break immersion
- Create optimization pressure
- Make the game feel "solved" rather than experienced
- Overwhelm casual players

### Alternative Communication Methods

**1. Visual Health Representation**
- Character appearance changes with damage
- Helmet cracks, clothes tear, visible injuries
- More dust/dirt on player sprite as health drops

**2. Movement/Animation Changes**
- Slight limp at low health
- Slower movement (optional - can be frustrating)
- Changed idle animation (hunched, holding side)

**3. Environmental Feedback**
- Light radius shrinks as health drops
- Colors slightly desaturate at low health
- More dramatic screen shake when hit at low health

**4. Audio Cues**
- Character breathing becomes labored
- Movement sounds change (heavier footsteps)
- Music becomes more tense

### GoDig Difficulty Communication

**Block Hardness (Without Numbers):**
```
Easy: Soft particles, quick crumble
Medium: Stone chips, medium break time
Hard: Sparks, slow cracking
Very Hard: Tool bounces slightly, minimal progress visible
```

**Tool Effectiveness (Without Numbers):**
```
Great match: Fast swing, satisfying break
Okay match: Normal swing, standard break
Poor match: Slow swing, tool wobbles slightly
Wrong tool: "Clang" feedback, tool bounces
```

**Enemy Danger Level (Without Numbers):**
```
Low: Small, slow-moving, non-aggressive
Medium: Medium size, standard speed
High: Large, fast, or glowing elements
Boss: Distinct appearance, music change
```

## Implementation Checklist

### For Every Hazard in GoDig

- [ ] Has visual telegraph (what player sees)
- [ ] Has audio telegraph (what player hears)
- [ ] Minimum 1 second warning for instant dangers
- [ ] First encounter deals warning damage (not death)
- [ ] Consistent rules (same cause, same effect)
- [ ] Escape/counterplay exists
- [ ] Player can learn from first encounter

### For Health Warning System

- [ ] Graduated intensity (50% → 25% → 10%)
- [ ] Visual doesn't obscure center screen
- [ ] Audio doesn't cover enemy/hazard sounds
- [ ] All warnings can be disabled in settings
- [ ] Retreat suggestion included (not just panic)
- [ ] "Safe" feedback when healed

### For Environmental Storytelling

- [ ] Hazard areas have environmental hints (bones, scorch marks)
- [ ] New hazard types introduced in safer context first
- [ ] Tutorial/FTUE covers basic hazard recognition
- [ ] Consistent visual language (red = hot, green = poison, etc.)

## Summary: The Fair Warning Manifesto

### Core Beliefs

1. **Death should teach, not punish** - Every death provides learnable information
2. **Information before danger** - Telegraph gives time to respond
3. **Consistency builds trust** - Same rules, every time
4. **Escape always exists** - With knowledge, survival is possible
5. **Warnings help, not hurt** - Aids awareness without impeding play

### GoDig Commitments

- **No instant deaths** without multi-second warning
- **No off-screen kills** without audio cue
- **No RNG deaths** - all hazards deterministic
- **First encounter survives** - warning damage on new hazards
- **Retreat is valid** - surface return always safe option
- **Settings respect preference** - all warnings adjustable

### The Fair Death Test

Before shipping any hazard, ask:
1. Could a careful player have seen this coming?
2. Is there at least 1 second to react?
3. Does the telegraph match the danger?
4. Could a player learn to avoid this after one death?
5. Is there always an escape option?

If any answer is "no," redesign the hazard.
