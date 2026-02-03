# Tutorial Pacing in Exploration Games: Teaching Without Spoiling Discovery

*Research Session 26 - Onboarding Design*

## Overview

Mining and exploration games must teach mechanics while preserving the joy of discovery. This document analyzes how landmark games achieve this balance and provides recommendations for GoDig's progressive tutorial system.

## The Core Tension

**Players need to learn:**
- Controls and movement
- Core loop mechanics
- Progression systems
- Survival/safety

**Players want to discover:**
- Hidden mechanics
- Secret areas
- Advanced strategies
- Emergent interactions

**The challenge**: Teach enough that players don't quit from confusion, but not so much that discovery is spoiled.

## Case Study: Hollow Knight

### The King's Pass Tutorial

From [IndieGameCulture - Hollow Knight's Tutorial Is A Design Masterclass](https://indiegameculture.com/hollow-knight/hollow-knights-tutorial-is-a-design-masterclass/):

> "The game manages to deliver so much key information with practically no prompts or menus whatsoever, which is considered staggeringly good design."

### Teaching Through Environment

**Attacking roadblocks**:
> "The game urges players to attack roadblocks, teaching them not only how to attack, but also that portions of the world are destructible."

This creates a habit: "Players are taught to attack walls and structures as a habit, just in case the game is hiding a secret, which it often is."

**Upward attacks**:
> "Players are introduced to their first flying enemy (a Vengefly), and while they can lure it down to ground level, the reason the game does this so early in a safe setting is to teach the player they can attack upward."

**Variable jump height**:
> "The platforming section teaches players that holding the jump button offers a higher jump, as a standard press won't reach the platforms ahead."

### Environmental Visual Cues

> "When the player learns an ability to dash over long distances, there are pink crystals clustered around the learning area. There's a hall full of these pink crystals that act as hazards that the player's normal jump can't clear."

**Key principle**: The environment where you learn an ability hints at where you'll use it.

### Wordless Storytelling

From [Medium - Hollow Knight: A lesson in Game Design](https://dimasgibi.medium.com/hollow-knight-a-lesson-in-game-design-8cc4ff8aa1cd):

> "What makes metroidvania unique is the ability to teach through design, without explicit tutorials."

This approach is called "implicit onboarding" - learning without interruptions.

## Case Study: Breath of the Wild

### Great Plateau Design

From [ScreenRant - BOTW's Great Plateau is the Gold Standard](https://screenrant.com/zelda-breath-wild-tutorial-best-game-great-plateau/):

> "The Great Plateau is a large elevated landmass high enough that the player cannot descend from it without dying of fall damage or using the paraglider item."

This creates a **safe sandbox** - players can experiment freely without risk of getting lost in the larger world.

### Natural Boundaries

From [GameRant - Why Zelda: Breath of the Wild's Great Plateau is Effective](https://gamerant.com/zelda-breath-of-the-wild-great-plateau-tutorial-introduction-design-effective/):

> "The game tells players where to go either explicitly or implicitly, but not how to get there, how long to get there, or what to do once they've arrived."

**Key principle**: Give direction, not instructions.

### Organic Discovery

> "As the player explores throughout the Great Plateau on their way to the shrines, they are introduced to multiple of Breath of the Wild's core mechanics."

Mechanics learned organically:
- Cooking
- Weather and temperature management
- Stamina management
- Object physics

> "Examples include boulders next to enemy camps that can be pushed to crush enemies below, and an area too cold to travel through without cooking specific food items."

### Miniature Mirror

From [ResetEra - Why Breath of the Wild's Great Plateau Is Gaming's Greatest Tutorial](https://www.resetera.com/threads/why-breath-of-the-wild%E2%80%99s-great-plateau-is-gaming%E2%80%99s-greatest-tutorial-art-of-the-level.532264/):

> "The way the plateau mirrors the game at large is 'no coincidence, and is a testament to its design.'"

The tutorial area contains a small version of everything in the full game.

## Case Study: Dark Souls

### Undead Asylum Design

From [The Level Design Book - Undead Burg](https://book.leveldesignbook.com/studies/sp/undead-burg):

> "The Northern Undead Asylum was the final level to have been designed in Dark Souls so it could accurately reflect the overall game as a preceding tutorial sequence."

Designing the tutorial **last** ensures it prepares players for what's actually in the game.

### Learning Through Failure

From [WordPress - Dark Souls Tutorial Review](https://lazystreamofthoughtlessness.wordpress.com/2019/02/06/video-game-level-reviews-dark-souls-northern-undead-asylum/):

> "Dark Souls opens with a boss encounter that tells the player from the get-go that they will learn through persistence."

The Asylum Demon teaches:
- You will die
- Look for alternatives when blocked
- Be aware of your surroundings

**Key principle**: Failure IS the tutorial.

### Environmental Cues

> "Inside the boss arena is a small opening that leads to a separate part of the asylum, and a gate promptly slams down behind the player, signaling the correct course of action."

The door slamming says "go this way" without text.

### Teaching Through Boss Design

> "The Asylum Demon is a boss designed to teach the basics of dodge roll, with easy-to-read movement animations."

The first boss prepares players for later bosses. Each boss teaches a new lesson.

## Case Study: Spelunky

### What You DON'T Learn

From [Medium - Spelunky: a Study in Good Game Design](https://alconost.medium.com/spelunky-a-study-in-good-game-design-669a18f1a178):

> "What's important here is not what the player learns, but what he does NOT learn — what is not covered. This is considerable, which contributes to the second task: the pleasure of discovering things for oneself."

**Key principle**: Deliberate gaps in the tutorial create discovery opportunities.

### Difficulty as Tutorial

> "Derek found that a punishing gameplay experience caused players to behave in unique ways, forcing the player to think more about their actions."

> "Even Edmund McMillen told him that the starting area's arrow traps should do less damage, but Derek was adamant that the immediate difficulty was necessary."

**Key principle**: Punishment teaches respect for game systems.

### Progressive Complexity

> "At each new level new opponents, traps, and obstacles are added, making it almost a new game entirely. The shift is very sudden. Players once again find themselves outside their comfort zone, and everything must be relearned."

**Key principle**: Tutorial never really ends - each zone re-teaches.

## Case Study: Tunic

### Manual as Discovery

From [The Gamer - Unravelling The Meaning of Tunic's Mysterious Language](https://www.thegamer.com/meaning-of-tunic-mysterious-language-andrew-shouldice/):

> "In Tunic, you're dropped into a world where you aren't given any instructions other than how to move. As you play, you learn more about the world by collecting manual pages."

The **manual pages** are collectibles that teach mechanics. Finding tutorial is part of the game.

### Language as Easter Egg

From developer Andrew Shouldice:

> "The glyphs exist to make the player feel like they're in a place that they don't belong... Here is something that has meaning, something that is trying to communicate to you, but maybe it's not meant for you."

**Key principle**: Mystery itself can be satisfying, even without resolution.

### Optional Depth

From [Steam Community](https://steamcommunity.com/app/553420/discussions/0/3281443422910376527/):

> "Except for one secret treasure, you can pretty much solve everything else in the game with only visual/auditory clues and corresponding deductions."

**Key principle**: Deep secrets are optional; core game is accessible.

## Tutorial Design Principles

### 1. Environmental Teaching

| Method | Example | GoDig Application |
|--------|---------|-------------------|
| Blocking path | Wall requires dig | First blocks block obvious path |
| Visual cue | Crystals near dash | Ore shimmer near first ore |
| Forced use | Must jump to proceed | Must dig down to continue |
| Safe practice | No enemies at first | No hazards in first 10 blocks |

### 2. Implicit vs Explicit

| Implicit (Preferred) | Explicit (When Needed) |
|---------------------|------------------------|
| Level design forces action | Button prompt overlay |
| Visual/audio cues | Text instruction |
| Trial and error | Step-by-step guide |
| Environmental hints | NPC dialogue |

Use explicit teaching ONLY when:
- Player has failed 3+ times
- Control scheme is non-standard
- Mechanic is counter-intuitive
- Mobile input requires specifics

### 3. Progressive Disclosure

From [Medium - From metroidvania to UX](https://medium.com/@lorenzoardeni/from-metroidvania-to-ux-what-we-can-learn-from-game-design-classics-5d9f29d72649):

> "The real magic... lies in their ability to teach complex mechanics without ever making use of explicit tutorials: the player learns independently."

**Disclosure stages**:
1. **Immediate**: Controls, movement, basic dig
2. **First 30s**: First ore, inventory
3. **First 2min**: Return trip, selling
4. **First 5min**: First upgrade, shop
5. **First 15min**: Ladder management, depth danger
6. **First hour**: Advanced mechanics, secrets

### 4. Safe Sandbox

| Breath of the Wild | GoDig Equivalent |
|-------------------|------------------|
| Great Plateau boundary | First 50m safe zone |
| Paraglider unlock gates exit | First ore triggers progression |
| All mechanics in miniature | Full loop in surface/shallow |

### 5. Failure as Teacher

| Game | Failure Teaching |
|------|------------------|
| Dark Souls | Asylum Demon forces retreat |
| Spelunky | Arrow traps punish carelessness |
| Hollow Knight | Fall into danger areas |
| GoDig | Getting stuck teaches ladder value |

## Recommendations for GoDig

### What to Teach Explicitly

**Touch controls** (first 10 seconds):
- Virtual joystick visualization
- Tap-to-dig indicator
- "Swipe to look" if applicable

**Core loop** (first 30 seconds):
- Dig down direction
- Ore pickup auto-collect
- Inventory indicator

### What to Teach Implicitly

**Through environment**:
- Ore slightly visible through first wall
- First ore guaranteed within 3 blocks
- Dead-end that requires ladder (after player has some)

**Through failure**:
- First stuck moment teaches ladder value
- First death teaches surface return importance
- First full inventory teaches sell timing

### What to NOT Teach

**Let players discover**:
- Rare ore existence
- Cave systems
- Deep layer mechanics
- Secret areas
- Advanced traversal techniques
- Synergy combinations

### Tutorial Flow

```
0s - Touch control overlay (explicit, 3 seconds)
     |
5s - Move to see ore (implicit - ore glimmers)
     |
10s - Dig toward ore (tap-to-dig works)
      |
20s - Pick up ore (auto-collect)
      |
30s - Inventory shows item (implicit)
      |
60s - Surface arrow appears (if player goes too far)
      |
2min - Sell at shop (NPC prompt)
       |
3min - Upgrade available (shop highlight)
       |
5min - First real descent (deeper, ladders matter)
       |
10min - First stuck OR low ladder moment
        |
15min - Full loop mastered, player on their own
```

### Anti-Patterns to Avoid

1. **Text walls** - Never pause game for reading
2. **Hand-holding** - Don't force optimal path
3. **Early spoilers** - Don't show rare ores in tutorial
4. **Explicit everything** - Let some things be discovered
5. **Unskippable** - Returning players should skip quickly

## Sources

- [IndieGameCulture - Hollow Knight's Tutorial Is A Design Masterclass](https://indiegameculture.com/hollow-knight/hollow-knights-tutorial-is-a-design-masterclass/)
- [Medium - Hollow Knight: A lesson in Game Design](https://dimasgibi.medium.com/hollow-knight-a-lesson-in-game-design-8cc4ff8aa1cd)
- [GameRant - Zelda BOTW Great Plateau Introduction](https://gamerant.com/zelda-breath-of-the-wild-great-plateau-tutorial-introduction-design-effective/)
- [ScreenRant - BOTW's Great Plateau is the Gold Standard](https://screenrant.com/zelda-breath-wild-tutorial-best-game-great-plateau/)
- [WordPress - Dark Souls Tutorial Review](https://lazystreamofthoughtlessness.wordpress.com/2019/02/06/video-game-level-reviews-dark-souls-northern-undead-asylum/)
- [The Level Design Book - Undead Burg](https://book.leveldesignbook.com/studies/sp/undead-burg)
- [Medium - Spelunky: a Study in Good Game Design](https://alconost.medium.com/spelunky-a-study-in-good-game-design-669a18f1a178)
- [The Gamer - Tunic's Mysterious Language](https://www.thegamer.com/meaning-of-tunic-mysterious-language-andrew-shouldice/)
- [Medium - From metroidvania to UX](https://medium.com/@lorenzoardeni/from-metroidvania-to-ux-what-we-can-learn-from-game-design-classics-5d9f29d72649)

## Related Implementation Tasks

- `GoDig-implement-progressive-tutorial-3a7f7301` - Progressive tutorial
- `GoDig-implement-ftue-60-94baf4fa` - FTUE 60-second hook
- `GoDig-implement-ftue-timing-5dce84cc` - FTUE timing validation
- `GoDig-implement-guaranteed-first-99e15302` - Guaranteed first ore within 3 blocks
