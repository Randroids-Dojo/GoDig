---
title: "research: Mining satisfaction and game feel - what makes digging fun"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-01T02:22:56.724552-06:00\\\"\""
closed-at: "2026-02-01T07:45:07.617336-06:00"
close-reason: Completed research on mining game feel. Documented Minecraft sound design, screen shake parameters, particle effects. Created 3 implementation specs for sound, shake, and particles.
---

Research what makes mining feel satisfying in games like Minecraft, SteamWorld Dig, Terraria. Document sound design, visual feedback, progressive destruction, and how to make each pickaxe swing feel good.

## Research Findings

### The Golden Rule of Game Juice

From [GameDev Academy](https://gamedevacademy.org/game-feel-tutorial/):
> "The activities that the player performs the most should be made to feel the most impactful."

For GoDig, mining is THE core activity. Every pickaxe swing must feel good.

### What Makes Mining Satisfying (Community Research)

From [ResetEra Discussion](https://www.resetera.com/threads/more-satisfying-mining-in-games.1128900/):

**Top Mentioned Games**:
1. Minecraft - Sound design is iconic
2. SteamWorld Dig 1 & 2 - Combines digging with progression
3. Deep Rock Galactic - Mining integrates into strategic gameplay
4. Terraria - 2D mining preferred for clarity
5. Stardew Valley - Time limits + enemies + bombs

**Key Satisfaction Elements**:
- Sound design and audio feedback
- "Visual texture of blocks becoming cracked" before breaking
- Progressive destruction animations
- Immediate tactile response

### Minecraft's Sound Design Excellence

From [Sportskeeda Analysis](https://www.sportskeeda.com/minecraft/top-5-best-sounds-minecraft):

What makes Minecraft's mining sounds iconic:
1. **Material-specific sounds** - Stone has satisfying "chink", wood has "thunk"
2. **Cascade effects** - Breaking bottom block of bamboo creates ripple sound
3. **Timing sync** - Break sound perfectly timed with visual destruction
4. **Pick-up chime** - Immediate reward feedback when item collected

**GoDig Application**: Each ore type should have distinct break sound. Harder blocks = more "meaty" sounds.

### The Components of "Juice"

From [Blood Moon Interactive](https://www.bloodmooninteractive.com/articles/juice.html):

1. **Screen Shake**
   - Magnitude: How far screen moves
   - Frequency: Shakes per second
   - Length: 0.1-0.3 seconds typical
   - Taper off with easing function

2. **Particles**
   - Dust clouds, debris, sparkles
   - Give motion to flat actions
   - Convey impact and destruction

3. **Hitstop/Freeze Frames**
   - Brief 20-50ms pause on impact
   - Barely visible but adds weight
   - Called "sleep" by Vlambeer

4. **Animation Squash/Stretch**
   - Anticipation before swing
   - Impact deformation
   - Bounce-back recovery

### Screen Shake Guidelines

From [Medium - Juice It Good](https://gt3000.medium.com/juice-it-adding-camera-shake-to-your-game-e63e1a16f0a6):

```
Screen Shake Parameters:
- Mining normal block: magnitude 2-4px, duration 0.1s
- Mining hard block: magnitude 4-6px, duration 0.15s
- Breaking ore: magnitude 6-8px, duration 0.2s
- Finding rare gem: magnitude 8-10px + particles, duration 0.25s
```

**Warning**: Don't overdo screen shake - can cause motion sickness.

### Progressive Block Destruction

The "cracked block" pattern:
1. Block starts pristine
2. First hit: small crack appears
3. Second hit: larger cracks
4. Third hit: about to break state
5. Final hit: explosion of particles

**Visual feedback**: Player sees progress, knows how close to breaking.

### Mining Sound Categories

| Block Type | Sound Character | GoDig Equivalent |
|------------|-----------------|------------------|
| Dirt/Soft | Soft thud, muffled | Surface dirt |
| Stone | Sharp crack, resonant | Deep stone |
| Metal/Ore | Metallic ping, echo | Copper, iron |
| Crystal/Gem | Chime, sparkle | Diamonds, gems |
| Wood | Hollow thunk | Support beams |

### The Pickup Sound

Essential: A satisfying "collection" sound when ore enters inventory.
- Short, punchy
- Slightly randomized pitch (variety)
- Can include visual pop/bounce

### Implementation Priorities for GoDig

1. **P0 - Block break sounds** (most frequent action)
   - Different sounds per block type
   - Satisfying final-break sound
   - Sync exactly with visual destruction

2. **P1 - Screen shake on break**
   - Subtle shake on each block
   - Bigger shake on harder blocks
   - Huge shake on ore discovery

3. **P1 - Particle effects**
   - Debris particles on each hit
   - Different colors per material
   - Explosion burst on final break

4. **P2 - Progressive destruction visuals**
   - Crack overlay as block takes damage
   - Health bar or crack severity indicator
   - "About to break" anticipation state

5. **P2 - Pickup feedback**
   - Item flies to player
   - Satisfying chime
   - Inventory pulse/glow

6. **P3 - Hitstop/freeze frame**
   - 20ms pause on hard block hits
   - 50ms pause on ore discovery
   - Creates "weight" to actions

### What NOT To Do

1. **Don't spam particles** - Too many = visual noise
2. **Don't overuse screen shake** - Motion sickness risk
3. **Don't have silent hits** - Every action needs audio feedback
4. **Don't make sounds annoying** - Will hear them 1000s of times
5. **Don't ignore timing** - Sound must sync with visual

## Implementation Specs to Create

### implement: Mining sound design system
Different break sounds per block type, material-specific audio feedback, pickup chimes

### implement: Mining screen shake
Subtle per-hit shake, scaled by block hardness, ore discovery celebration shake

### implement: Block destruction particles
Debris particles per hit, color-coded by material, burst effect on final break

### implement: Progressive block damage visuals
Crack overlay system, health indicator, "about to break" state

## Sources
- [ResetEra - Satisfying Mining Games](https://www.resetera.com/threads/more-satisfying-mining-in-games.1128900/)
- [GameDev Academy - Game Feel Tutorial](https://gamedevacademy.org/game-feel-tutorial/)
- [Blood Moon - Juice in Game Design](https://www.bloodmooninteractive.com/articles/juice.html)
- [Medium - Juice It Good: Camera Shake](https://gt3000.medium.com/juice-it-adding-camera-shake-to-your-game-e63e1a16f0a6)
- [Sportskeeda - Minecraft Sound Design](https://www.sportskeeda.com/minecraft/top-5-best-sounds-minecraft)
