# Gravity and Weight Feel in 2D Mining Games

*Research Session 26 - Physics Game Feel*

## Overview

The sensation of weight in a mining game comes from three interconnected systems: jump physics, fall physics, and landing feedback. This document analyzes how platformers create satisfying gravity feel and applies these principles to mining game design.

## Core Physics Concepts

### Variable Gravity

From [2D Engine - Physics in Platformer Games](https://2dengine.com/?p=platformers):

> "A common technique is to modify the 'gravity scale' when the player releases the jump button while in the air, and reset the 'gravity scale' back to 1 immediately upon landing."

**Why variable gravity works**:
- Lower gravity during ascent = floaty peak feeling
- Higher gravity during descent = weighted fall
- Creates "weighty" feel without slow movement

### Coyote Time

> "It is recommended to allow the player to jump for a split second after falling off ledges, with a 0.1 second grace period for jumping."

**Implementation**: 0.08-0.15 second window after leaving ground where jump still works.

**Why it matters**: Prevents frustrating "I pressed jump!" moments near ledges.

### Jump Buffering

From [Pav Creations - Jumping Controls](https://pavcreations.com/jumping-controls-in-2d-pixel-perfect-platformers/):

> "It feels better to trigger the jump even when the button was pressed right before landing - accepting button presses up to 0.2 seconds before actually hitting the ground."

**Implementation**: 0.1-0.2 second buffer before landing.

**Why it matters**: Jumping feels responsive, not delayed.

## Case Study: Celeste vs Super Meat Boy

From [Critical Gaming - Super Meat Boy](https://critical-gaming.squarespace.com/blog/2011/1/5/super-meat-boy-pt1.html):

### Super Meat Boy Approach

> "The JUMP mechanic is direct, allowing players to vary the height of the JUMP by holding the button longer."

> "Meat Boy will invert your y-velocity when you release the jump button to prevent the top of your arc from feeling floaty."

**Key technique**: Instantly cutting vertical velocity when jump released = snappy, responsive.

### Celeste Approach

From [Game Wisdom - Celeste](https://game-wisdom.com/analysis/celeste):

> "Your controls are limited to move, climb, jump, and performing an air dash. You can only climb for a limited time and perform one air dash before needing to land."

**Key technique**: Limited abilities create tension; air dash as recovery.

### Philosophy Difference

> "Celeste levels are designed in a way that requires less precision in execution compared to SMB."

**For GoDig**: Mining games don't need extreme precision. Celeste's forgiving-but-tense approach fits better.

## Screen Shake and Impact

From [GameMaker - Juicy Screen Shake](https://gamemaker.io/en/tutorials/coffee-break-tutorials-juicy-screenshake-gml):

### When to Use Screen Shake

> "Screen Shake adds that extra bit of impact when firing a gun or landing in a platformer."

**Mining game triggers**:
- Landing after long fall
- Breaking through to cave
- Rare ore discovery
- Taking damage
- Block break (subtle)

### Shake Parameters

From [Dave Tech - Analysis of Screenshake Types](http://www.davetech.co.uk/gamedevscreenshake):

| Parameter | Light | Medium | Heavy |
|-----------|-------|--------|-------|
| Duration | 0.1s | 0.2s | 0.4s |
| Magnitude | 2-4px | 5-8px | 10-15px |
| Frequency | High | Medium | Low |

**Best practice**:
> "Diminishing shake is when it starts off much stronger and fades out. This allows you to have a high magnitude that goes on for longer than would normally feel comfortable."

### Directional Shake

> "When the player is making an attack, the screen should start by moving in that same direction to give the illusion that the force is being transferred to the camera."

**For mining**: Shake should push DOWN when falling, IN when breaking blocks.

## Landing Impact Design

From [Medium - Making a Game Feel Juicy](https://medium.com/@yemidigitalcash/when-you-play-a-great-game-it-feels-good-d23761b6eccf):

### Squash and Stretch

> "For jumping characters, you can use squash on landing and stretch on takeoff to enhance the feel."

**Implementation**:
- On takeoff: Vertical stretch (1.2x height, 0.8x width)
- On landing: Horizontal squash (0.8x height, 1.2x width)
- Lerp back to normal over 0.1-0.2s

### Particle Effects

> "Spawn particles at the hit location."

**Landing particles**:
- Dust puff from ground
- Small rocks/debris
- Cracks on hard surfaces

### Hit Stop (Freeze Frames)

> "Brief slow-motion can turn an ordinary moment into a memorable one. You can freeze time for 0.2 seconds after a critical hit."

**For landing**:
- 1-2 frame pause on hard landings
- Creates sense of impact without actual delay

## Mining-Specific Weight Feel

From [ResetEra - More Satisfying Mining](https://www.resetera.com/threads/more-satisfying-mining-in-games.1128900/):

### SteamWorld Dig Success

> "SteamWorld Dig's 'carefully designed gameplay loop' keeps players hooked because 'cashing in a huge payload feels great, and digging deeper with your new gear is even better.'"

### Synchronized Feedback

From [Vintage Story Immersive Mining Mod](https://mods.vintagestory.at/immersivemining):

> "The mining process needed a little more 'impact' to it... animation, particles, block damage and sound aren't synced."

**Solution**: "Frame synchronized effects... a shake effect, custom animations and sounds."

**Key insight**: All feedback elements (visual, audio, camera) must sync to the exact frame of block break.

### The Discovery Loop

> "There's just something satisfying about digging, discovery, and using those discoveries to enable more digging."

Weight feel enhances the discovery loop:
- Heavy fall = "I went deep"
- Hard landing = "This is serious"
- Block resistance = "This is valuable"

## Fall Damage Design

### The Challenge

Fall damage creates stakes but shouldn't frustrate:
- Too punishing = players avoid vertical movement
- Too forgiving = no weight/stakes
- Right balance = weight feel with recovery options

### Graduated Damage

| Fall Distance | Damage | Feedback |
|---------------|--------|----------|
| 0-3 tiles | 0% | Normal landing |
| 4-6 tiles | 5-15% | Heavy landing, dust |
| 7-10 tiles | 20-40% | Screen shake, grunt |
| 11+ tiles | 50-80% | Big shake, flash, crack sound |

### Recovery Options

- **Ladders**: Provide safe descent
- **Wall-slide**: Reduce fall speed
- **Featherfall boots**: Upgrade option
- **Soft ground**: Some blocks reduce damage

## Implementation Recommendations

### Basic Physics (MVP)

```gdscript
# Recommended values for mining game feel
const GRAVITY := 1200.0  # Moderately heavy
const JUMP_VELOCITY := -400.0  # Moderate jump
const COYOTE_TIME := 0.1  # Forgiving
const JUMP_BUFFER := 0.15  # Responsive

# Variable gravity
var gravity_multiplier := 1.0
if velocity.y > 0:  # Falling
    gravity_multiplier = 1.3  # Fall faster
elif velocity.y < 0 and not Input.is_action_pressed("jump"):
    gravity_multiplier = 2.5  # Cut jump early
```

### Landing Feedback (MVP)

```gdscript
func _on_land(fall_distance: float):
    # Squash effect
    sprite.scale = Vector2(1.2, 0.8)
    create_tween().tween_property(sprite, "scale", Vector2.ONE, 0.15)

    # Dust particles
    if fall_distance > 3:
        spawn_dust_particles()

    # Screen shake based on distance
    if fall_distance > 5:
        camera_shake(fall_distance * 0.3, 0.15)

    # Sound
    play_landing_sound(fall_distance)
```

### Block Break Sync (MVP)

```gdscript
func _on_block_broken(block_pos: Vector2):
    # All these should happen on the SAME FRAME:

    # 1. Visual
    spawn_break_particles(block_pos)

    # 2. Audio
    play_break_sound(block.material)

    # 3. Camera
    camera_shake(2.0, 0.1)

    # 4. Haptic (mobile)
    if OS.has_feature("mobile"):
        Input.vibrate_handheld(30)
```

## Weight Progression

Mining games can use weight feel to show progression:

### Early Game (Rusty Pickaxe)

- Slower movement
- Heavy falls
- Labored digging animation
- Long block break time

### Mid Game (Iron Pickaxe)

- Normal movement
- Standard falls
- Fluid digging
- Medium break time

### Late Game (Diamond Pickaxe)

- Quick movement
- Reduced fall damage (gear)
- Powerful digging animation
- Fast break time

**Key insight**: Character should feel more capable over time, not just faster.

## Audio for Weight

### Landing Sounds

| Surface | Sound Type | Example |
|---------|-----------|---------|
| Dirt | Soft thump | "Doof" |
| Stone | Hard crack | "Crack" |
| Cave | Echo + thump | "Doof... oof" |
| Water | Splash | "Sploosh" |

### Fall Wind

During long falls, add wind rushing sound that:
- Increases with velocity
- Cuts on landing
- Creates anticipation

## Sources

- [2D Engine - Physics in Platformer Games](https://2dengine.com/?p=platformers)
- [Medium - Platformer Physics Cheatsheet](https://medium.com/@brazmogu/physics-for-game-dev-a-platformer-physics-cheatsheet-f34b09064558)
- [Gamedeveloper - Platformer Controls](https://www.gamedeveloper.com/design/platformer-controls-how-to-avoid-limpness-and-rigidity-feelings)
- [Pav Creations - Jumping Controls](https://pavcreations.com/jumping-controls-in-2d-pixel-perfect-platformers/)
- [Critical Gaming - Super Meat Boy](https://critical-gaming.squarespace.com/blog/2011/1/5/super-meat-boy-pt1.html)
- [Game Wisdom - Celeste](https://game-wisdom.com/analysis/celeste)
- [GameMaker - Juicy Screen Shake](https://gamemaker.io/en/tutorials/coffee-break-tutorials-juicy-screenshake-gml)
- [Dave Tech - Analysis of Screenshake Types](http://www.davetech.co.uk/gamedevscreenshake)
- [Medium - Making a Game Feel Juicy](https://medium.com/@yemidigitalcash/when-you-play-a-great-game-it-feels-good-d23761b6eccf)
- [ResetEra - More Satisfying Mining](https://www.resetera.com/threads/more-satisfying-mining-in-games.1128900/)
- [Game Informer - SteamWorld Dig Review](https://gameinformer.com/games/steamworld_dig/b/pc/archive/2013/12/06/game-informer-steamworld-dig-review.aspx)
- [Vintage Story - Immersive Mining Mod](https://mods.vintagestory.at/immersivemining)

## Related Implementation Tasks

- `GoDig-implement-progressive-crack-1084ff76` - Progressive crack pattern on blocks
- `GoDig-implement-juice-calibration-4996b3fb` - Juice calibration - medium level
- `GoDig-implement-distinct-audio-450bc8be` - Distinct audio for each ore type
- `GoDig-implement-haptic-feedback-92e67c42` - Haptic feedback for ore discovery
