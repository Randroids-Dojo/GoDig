# Tutorial Skip Patterns Research

## Overview

Research into how games handle tutorial systems for both new and returning players. Understanding when skip buttons are appropriate, how to detect player skill, and how to handle returning players who forgot mechanics.

## The Tutorial Dilemma

### The Problem

**For New Players:**
- Need guidance to understand mechanics
- Can be overwhelmed by too much information
- May quit if frustrated early

**For Experienced Players:**
- Tutorials feel like a waste of time
- Forced tutorials create frustration
- Replay value suffers

**For Returning Players:**
- Forgot how mechanics work
- Don't want full tutorial again
- Need refresher, not restart

### User Testing Reality

> "User testing showed that users skip or otherwise ignore dialogs, tours, video demos and transparencies. At best, users find them a minor inconvenience. At worst, the patterns significantly aggravate new users."

## Design Philosophies

### Philosophy 1: Forced Tutorial (Controversial)

**Example:** Forts (Steam game)

**Reasoning:**
> "An effort to raise the level of online play for the benefit of everyone, reduce frustration in the first few games, and encourage new players to persist longer."

**Problems:**
- Experienced players frustrated
- Replay suffering
- "Skip tutorial should skip ALL tutorials, not 1 of 3"

### Philosophy 2: Minimal Tutorial (Dark Souls)

**Approach:**
> "Tutorials are streamlined to teach only the necessary fundamentals."

**Key Techniques:**
- Ground messages (optional reading)
- Environmental teaching (fall = no damage)
- Difficulty as guidance (hard area = wrong way)
- Discovery rewarded

**Miyazaki's Philosophy:**
> "I like for people to discover the world themselves."

**Pros:**
- Respects player intelligence
- Creates discovery moments
- High replay value

**Cons:**
- Some mechanics never explained
- Frustrating for some players
- Requires external resources

### Philosophy 3: Contextual Tips (Hades/Hollow Knight)

**Approach:** Tips appear when relevant, not upfront

**Hades Implementation:**
- Tips during gameplay pause moments
- God Mode for accessibility (not tutorial skip)
- No judgement for using assistance

**Hollow Knight Implementation:**
- Environmental teaching (pink crystals = use dash)
- Sound as hint system (grub crying = secret)
- Visual cues (art-nouveau signs = save point)

> "Without prompting the player with words, environmental clues hint at what they need to do."

### Philosophy 4: Assist Mode (Celeste)

**Approach:** Player-controlled difficulty, not tutorial skip

**Options:**
- Game speed (50-100%)
- Invincibility toggle
- Infinite stamina
- Chapter skip

**The Message:**
> "Celeste is intended to be challenging and rewarding. If the default game proves inaccessible, we hope you can find that experience with Assist Mode."

**Key Insight:** Accessibility framing, not "easy mode" shame.

## Returning Player Support

### The Problem

> "If someone is returning to a title months or years later, they're not going to remember how the game works."

### Solutions

**1. Replayable Tutorials**
- Tutorial accessible from menu anytime
- Doesn't reset progress
- Casual-friendly

**2. Practice Areas**
- Safe space to try mechanics
- Pre-game zone or menu option
- No pressure, no consequences

**3. Organized Information**
- Tips/information easy to find
- Searchable or categorized
- Quick reference cards

**4. Progressive Refreshers**
- First action of each type shows reminder
- "Remember: Hold A to climb"
- Auto-disables after use

### Best Practice

> "Any tips or information should be arranged in an organized fashion and be easy to surf through. The player should be able to replay through the tutorial section without affecting the rest of their account."

## Skill Detection

### Automatic Detection Methods

**1. Input Speed**
- Fast, precise inputs = experienced
- Slow, hesitant = new player

**2. Action Choices**
- Experienced players skip reading
- New players read everything

**3. Failure Rate**
- Dying to tutorial enemies = needs help
- Breezing through = can skip ahead

**4. Previous Save Detection**
- Has save file = returning player
- Fresh install = new player

### Implementation Example

```
if (has_previous_save):
    show_option("Skip tutorial? You've played before.")
elif (tutorial_deaths == 0 && speed > average):
    show_option("You're doing great! Skip to advanced?")
else:
    continue_normal_tutorial()
```

## Tutorial Delivery Methods

### Method 1: Experimentation Zones

> "Rather than trying to design tutorials, design 'experimentation zones' where players figure out mechanics through trial-and-error in a scaffolded fashion."

**How It Works:**
- Safe area with low stakes
- Mechanics introduced naturally
- Failure expected and cheap

### Method 2: Incremental Introduction

> "Players can get confused if given too much information at once. Plan when each new idea will be introduced."

**Clash Royale Example:**
- 5 short tutorials at relevant moments
- Each builds on previous
- Earlier = more guidance
- Later = challenge to demonstrate learning

### Method 3: Show Don't Tell

> "Tutorials should be interactive, so users learn by doing."

**Portal Example:**
- Each test chamber teaches one concept
- Practice before moving on
- Mastery required to progress

### Method 4: Environmental Teaching

**Hollow Knight Example:**
- Fall at start = no fall damage (learned)
- Pink crystals near dash = use dash here
- Sound cues = secrets nearby

## Best Practices Summary

### Do's

| Practice | Why |
|----------|-----|
| Allow skip for experienced | Respects their time |
| Replayable tutorials | Helps returning players |
| Contextual tips | Just-in-time learning |
| Practice areas | Low-stakes learning |
| Progressive disclosure | Prevents overwhelm |
| Environmental teaching | Discovery > instruction |

### Don'ts

| Anti-Pattern | Why It Fails |
|--------------|--------------|
| Forced lengthy tutorials | Frustrates experts |
| Text walls | Users skip them anyway |
| Frontloaded information | Forgotten by use time |
| No way to re-learn | Hurts returning players |
| Patronizing messages | Insults player intelligence |
| Skip = skip only first tutorial | Must skip ALL tutorials |

## Recommendations for GoDig

### Tutorial Structure

**Phase 1: First Launch (New Players)**
1. Drop into mine (no menu)
2. Move controls appear (fade after use)
3. First ore nearby (guaranteed)
4. "Tap ore to dig" appears
5. Dig, collect, depth counter shows
6. Surface return hint at 10m
7. First shop interaction guided
8. Tutorial complete

**Phase 2: Skip Detection**
```
On launch:
if (has_save_file):
    "Welcome back! Jump right in?"
    [Yes] → Skip to game
    [Remind me] → Quick refresher
else:
    Start tutorial
```

**Phase 3: Returning Player Refresher**
- 30-second reminder mode
- Controls shown but not forced
- Can dismiss anytime
- "Remember: Wall-jump with [button]"

### Contextual Tips System

**When to Show Tips:**
- First time near new ore type
- First time in new layer
- First time inventory full
- First death
- After long absence (7+ days)

**How to Show:**
- Small popup, bottom of screen
- Auto-dismiss after 5 seconds
- Can be disabled in settings
- "Don't show again" option

### Practice Area

**Location:** Surface, accessible anytime

**Features:**
- Infinite ladders/ropes
- No death consequences
- All mechanics available
- Timer challenges optional

### Settings Menu

**Tutorial Section:**
- [x] Show contextual hints
- [x] Show control reminders after absence
- [ ] Show tips for mechanics I've used
- [Replay Tutorial] button
- [Open Practice Area] button

### What to Skip

**Safe to Skip:**
- Movement controls (if used correctly)
- Basic digging (if already mining)
- Depth counter explanation

**Never Skip:**
- First ore discovery (moment, not tutorial)
- Shop mechanics (first time only)
- New layer introductions

### The "First 60 Seconds" Rule

Following Hollow Knight's King's Pass design:

1. **Seconds 0-10:** Player moves, learns no fall damage
2. **Seconds 10-20:** First ore visible, sparkling
3. **Seconds 20-30:** Dig prompt appears, player mines
4. **Seconds 30-45:** Item collected, feedback
5. **Seconds 45-60:** Natural progression deeper OR return hint

**No text walls. No pauses. Learn by doing.**

## Sources

- [PC Gamer - How Developers Build Tutorials](https://www.pcgamer.com/how-developers-build-the-tutorials-you-skip/)
- [Smashing Magazine - Rethinking Mobile Tutorials](https://www.smashingmagazine.com/2014/04/rethinking-mobile-tutorials-which-patterns-really-work/)
- [Celeste Wiki - Assist Mode](https://celeste.ink/wiki/Assist_Mode)
- [Game Developer - Celeste's Granular Assist Options](https://www.gamedeveloper.com/design/check-out-i-celeste-s-i-remarkably-granular-assist-options)
- [Game Developer - Dark Souls 3 Cemetery of Ash Tutorial](https://www.gamedeveloper.com/design/learning-basic-fluency-in-dark-souls-3-s-cemetery-of-ash)
- [Medium - What Dark Souls Can Teach Us About Design](https://medium.com/@lukasrathmann/what-dark-souls-can-teach-us-about-design-88aeb534c309)
- [Indie Game Culture - Hollow Knight Tutorial Masterclass](https://indiegameculture.com/hollow-knight/hollow-knights-tutorial-is-a-design-masterclass/)
- [Medium - Hollow Knight Game Design Lesson](https://dimasgibi.medium.com/hollow-knight-a-lesson-in-game-design-8cc4ff8aa1cd)
- [GameRefinery - Onboarding Best Practices Part 2](https://www.gamerefinery.com/keep-your-players-coming-back-introducing-onboarding-best-practices-part-2/)
- [Game Wisdom - Onboarding in Game Design](https://game-wisdom.com/critical/onboarding-game-design)
- [Inworld - Video Game Onboarding Best Practices](https://inworld.ai/blog/game-ux-best-practices-for-video-game-onboarding)
- [Apple Developer - Onboarding for Games](https://developer.apple.com/app-store/onboarding-for-games/)
- [Hades Wiki - How to Play Guide](https://hades.fandom.com/wiki/How_to_play_guide_for_Hades)

## Related Implementation Tasks

- `implement: FTUE timing - first ore 30s, sell 60s, upgrade 3min` - GoDig-implement-ftue-timing-5dce84cc
- `implement: Progressive disclosure - hide advanced systems` - GoDig-implement-progressive-863cee74
- `implement: Progressive tutorial - one mechanic at a time` - Already completed
