# Player Frustration Recovery Patterns

> Research into how games detect player frustration and offer assistance without breaking immersion or feeling condescending.

## Executive Summary

Player frustration is inevitable in challenging games, but how a game responds to frustration determines whether players persist or quit. The best assistance systems share key traits: they're **opt-in** (player retains agency), **gradual** (escalating help rather than sudden), **non-shaming** (no penalty for use), and **invisible** when possible (Dynamic Difficulty Adjustment).

**Key Insight for GoDig**: Our ladder-based stuck states create predictable frustration points. The forfeit cargo system and emergency rescue need careful framing to feel like a strategic choice, not a shameful bailout.

---

## The Celeste Model: Granular Assist Mode

Celeste's Assist Mode is widely considered the gold standard for accessibility-focused difficulty adjustment.

### How It Works

- **Always available**: Toggleable anytime from the save slot menu
- **Granular controls**: Players adjust specific parameters:
  - Game speed (50-100%)
  - Infinite stamina while climbing
  - Invincibility
  - Dash mode (infinite/two dashes)
  - Chapter skip
- **No content lockout**: All achievements and content remain accessible
- **Respectful messaging**: "If the default game proves inaccessible to you, we hope that you can still find that experience with Assist Mode"

### Design Philosophy

The key innovation is treating difficulty as a spectrum of tools rather than binary settings:
- "Some of these options are arguably reminiscent of old-school cheat codes, but the fact that the game offers them in a way that doesn't feel like cheating is key"
- "There's no jeering like in Wolfenstein 2, and none of the content is withheld like in Cuphead"

### Critical Perspectives

Some critics note that even with Assist Mode, Celeste's base design creates barriers:
- Seven-button requirement for "accessible" controls
- Core difficulty spikes that frustrate before players discover Assist Mode
- Promotional materials overpromise accessibility

### GoDig Application

| Celeste Pattern | GoDig Implementation |
|-----------------|---------------------|
| Granular toggles | Individual difficulty sliders (block hardness, ladder consumption rate) |
| No content lockout | Full game access regardless of settings |
| Respectful framing | "Customize your experience" not "make it easier" |
| Always available | Settings accessible from pause menu mid-run |

---

## The Hades Model: Progressive Resistance

Hades' God Mode represents a different philosophy: assistance that grows with persistence.

### How It Works

- **Starts modest**: 20% damage resistance when enabled
- **Grows with failure**: +2% resistance after each death (caps at 80%)
- **Resets on disable**: Remembers percentage if toggled off, then on
- **Mid-run toggling**: Can enable/disable during a run

### Design Philosophy

Creative Director Greg Kasavin explained: "The part where roguelikes can be brutally difficult is, ironically, directly at odds with the part where they're so replayable."

The key insight: **dying is central to the experience**, so assistance should work *with* the death loop, not around it:
- "If you could just blow through it, what's interesting about the game goes away"
- God Mode lets players "learn the patterns of whatever defeated them"
- The 2% increment ensures players still experience the core challenge

### Why It Works

1. **Thematically coherent**: "God Mode" fits the narrative (you're literally a god's child)
2. **Skill still matters**: Resistance reduces damage, doesn't eliminate it
3. **Progress feels earned**: Each death makes you slightly stronger
4. **No shame triggers**: No achievements locked, no content restricted

### GoDig Application

| Hades Pattern | GoDig Implementation |
|---------------|---------------------|
| Progressive buff | "Veteran Miner" passive that slightly increases based on runs completed |
| Thematic framing | "Experience makes you wiser" not "game made easier" |
| Death-tied progression | After X deaths in a zone, reveal more ore locations |
| No lockouts | All achievements available regardless of mode |

---

## The Dead Cells Model: Modular Accessibility

Dead Cells' "Breaking Barriers" update (2022) added extensive accessibility options developed with AbleGamers.

### Assist Mode Options

- **Continues**: 0, 1, 3, 7, or infinite
- **Auto-hit**: Automatically attack nearby enemies
- **Parry window**: Slower timing for parries
- **Trap/enemy damage**: Adjustable percentages
- **Map reveal**: Full level visibility option

### Custom Mode (Separate)

For experienced players wanting different challenges:
- Limit item/mutation pools
- Adjust flask charges
- Modify starter items
- Timer adjustments

### Key Design Decision

"Make specific, tailored adjustments to remove barriers rather than introducing arbitrary difficulty options."

This modular approach lets players address their **specific frustration** without changing unrelated mechanics.

### GoDig Application

| Dead Cells Pattern | GoDig Implementation |
|-------------------|---------------------|
| Modular toggles | Separate controls for mining speed, ladder economy, fall damage |
| Map reveal option | "Ore Detector" always showing nearby ores |
| Damage adjustment | Optional "padded suit" reducing fall damage |
| Auto-hit | "Auto-mine adjacent blocks" option |

---

## The Anti-Pattern: Cuphead's Content Lockout

Cuphead demonstrates what NOT to do with difficulty assistance.

### The Problem

- **Simple Mode exists** but locks out final 10% of content
- Players must beat ALL previous bosses on Regular to see the ending
- Creates two-tier experience: "real players" vs "Simple Mode players"

### Player Response

"The way Cuphead implements its easier mode makes players feel bad for using it."

This approach:
- Punishes players for using accessibility features
- Creates shame around needing assistance
- Implies "correct" and "incorrect" ways to play

### Lesson for GoDig

**Never lock content behind difficulty settings.** If a player uses forfeit cargo to escape, they should still:
- Keep all progress
- Access all areas
- Unlock all achievements (possibly with different flavor text)

---

## Dynamic Difficulty Adjustment (DDA)

DDA refers to systems that automatically adjust difficulty based on player performance.

### How DDA Works

The game monitors player performance (deaths, time spent, resource consumption) and adjusts parameters in real-time to maintain "flow" state - neither bored nor frustrated.

### Famous Examples

| Game | DDA Implementation |
|------|-------------------|
| Crash Bandicoot | Slows obstacles, adds hit points, creates checkpoints after repeated deaths |
| Resident Evil 4 | "Difficulty Scale" (1-10) adjusts enemy behavior based on performance |
| Left 4 Dead | "AI Director" spawns enemies based on player stress levels |
| Racing games | "Rubber banding" speeds up AI opponents when player is ahead |

### The Visibility Problem

**Critical finding**: DDA works best when invisible. When players notice adjustment:
- Perceived agency decreases
- Achievement feels hollow
- Players may "game" the system (dying deliberately to make next section easier)

Research shows: "explicit awareness of dynamic difficulty triggers negative affect, reducing immersion and perceived achievement."

### Transparent vs Hidden DDA

Studies comparing approaches found:
- **Blind Adaptation**: 55-56% retention
- **Transparent Adaptation**: 67% retention, +1.3 satisfaction

The key: players tolerate adaptation **if they understand why and can control it**.

### GoDig Application

Consider two approaches:

**Hidden DDA** (risky):
- Slightly increase ore spawn rate after consecutive deaths
- Reduce block hardness by 5-10% after 3+ attempts at same depth
- Risk: Players notice and feel patronized

**Transparent DDA** (safer):
- "Struggling? Enable Veteran Mode for a boost"
- "You've died 3 times here. Would you like to reveal nearby ores?"
- Keeps player agency while offering help

---

## Detecting Player Frustration

Games need signals to know when to offer help. Common detection methods:

### Quantitative Signals

| Signal | Threshold Example | Action |
|--------|-------------------|--------|
| Deaths in area | 3+ in same zone | Offer hint |
| Time without progress | 5 min at same depth | Suggest alternative |
| Resource depletion rate | Using ladders 2x faster than earning | Warning + tip |
| Repeated attempts | Same action 5+ times | Contextual help |
| Session abandonment | Quit mid-run | Welcome back message |

### Qualitative Signals

Harder to detect but important:
- Erratic movement (frustration behavior)
- Pause menu access frequency
- Settings menu visits
- Time between inputs (giving up vs thinking)

### GoDig Stuck Detection

For ladder-based stuck states specifically:

```
STUCK_INDICATORS:
- Player at same Y position for 30+ seconds
- All ladders consumed
- Jump attempts increasing
- Distance to surface vs remaining resources

INTERVENTION_TIERS:
1. Subtle hint (camera briefly shows route)
2. Audio cue (rope dangling sound effect)
3. Explicit offer ("Need help? Tap to reveal exit")
4. Emergency rescue prompt
```

---

## Failure Messaging Psychology

How you communicate failure dramatically impacts player response.

### Shame-Inducing Patterns (Avoid)

- "You Died" with red screen
- Leaderboards showing failure
- "Try Again?" implying expected success
- Difficulty suggestions after death
- Visible death counter
- "You broke your streak"

### Empowering Patterns (Use)

- Frame failure as learning: "You discovered a new hazard!"
- Progress-focused: "You made it to 247m - your deepest yet!"
- Normalize struggle: "Most miners need 3 attempts here"
- Offer information, not shame: "Tip: Wall-jump near the left"
- Recovery language: "47 out of 50 days - incredible progress!"

### GoDig Death Screen Design

**Current**: "You Died"
**Better**: "Expedition Ended at 247m"
**Best**: "Journey Report: Depth 247m (Personal Best!) | Ores Found: 12 | Coins Waiting: 340"

Transform death into a progress report that celebrates what was achieved rather than highlighting failure.

---

## The Forfeit Cargo Decision

GoDig's "forfeit cargo to escape" mechanic needs careful framing.

### Risk: Shame Response

If framed poorly, players may:
- Never use it (pride/stubbornness)
- Use it and feel bad
- Quit rather than "admit defeat"

### Reframing as Strategic Choice

| Shame Framing | Strategic Framing |
|---------------|-------------------|
| "Give up" | "Strategic retreat" |
| "Forfeit" | "Emergency extraction" |
| "Lose cargo" | "Sacrifice cargo for survival" |
| "Escape" | "Live to dig another day" |

### Loop Hero Model

Loop Hero's retreat system offers graduated options:
- Die: Keep 30% of resources
- Early retreat: Keep 60%
- Reach camp: Keep 100%

This creates strategic decisions, not shameful bailouts.

### GoDig Implementation

Consider tiered escape system:
1. **Surface return** (planned): Keep 100%
2. **Early retreat** (some resources lost): Keep 70%
3. **Emergency rescue** (critical): Keep 40%
4. **Death** (unplanned): Keep 20%

Frame each tier as a choice with trade-offs, not punishment for failure.

---

## Tutorial Hint Timing

When should hints appear without feeling patronizing?

### The "Just-in-Time" Principle

Hints should appear:
- **After** player has tried and failed (not before)
- **At** the moment of maximum receptivity (after failure, before frustration)
- **Before** the player quits in frustration

### Celeste's Approach

Tutorial rooms teach mechanics through design:
1. Safe space to experiment
2. Failure is low-stakes (nearby respawn)
3. Hints only after multiple attempts
4. Never force reading

### Recommended Trigger Thresholds

| Situation | Wait Time | Hint Type |
|-----------|-----------|-----------|
| New mechanic | 10 seconds of wandering | Subtle visual cue |
| Known mechanic, new context | 30 seconds | Brief text tip |
| Stuck (no progress) | 60 seconds | "Need help?" prompt |
| Critical failure imminent | Immediate | Clear warning |

### Player-Requested Hints

Best practice: Always include an explicit "hint" button that:
- Gives progressively more specific hints
- Never auto-triggers
- Respects player desire to figure it out

---

## GoDig-Specific Recommendations

Based on this research, here are specific recommendations for GoDig:

### 1. Modular Assist Options

Create a "Customize Experience" menu with toggles:
- [ ] Show optimal return routes
- [ ] Reduce fall damage (50%/75%/100%)
- [ ] Slower ladder consumption
- [ ] Highlight nearby ores
- [ ] Extend jump timing window

### 2. Progressive Assistance After Stuck States

```
STUCK_DETECTION:
  after 30s at same position with no ladders:
    → Brief camera pan showing possible route
  after 60s:
    → "Tap to reveal exit path" prompt
  after 90s:
    → "Emergency Rescue" button appears
    → Keep 40% of cargo
```

### 3. Death Screen Reframe

Transform death into a progress celebration:
- "Expedition Report"
- Highlight achievements (depth, ores, discoveries)
- "Ready for next attempt?" (not "Try Again?")
- Optional tip based on death cause

### 4. Forfeit Cargo as Strategy

Rename to "Emergency Extraction" and frame as:
- "Sacrifice cargo to survive"
- Show exact percentage being retained
- "Strategic retreat - live to dig another day"
- No shame language, just trade-off information

### 5. Transparent Difficulty Feedback

If enabling any DDA, tell the player:
- "Veteran Mode: +10% ore visibility (can disable in settings)"
- "Based on your play style, we've highlighted escape routes"
- Player can always disable

---

## Sources

- [Celeste Assist Mode - Game Accessibility Guidelines](https://gameaccessibilityguidelines.com/celeste-assist-mode/)
- [Dissecting Design - The (In) Accessible Nature of Celeste](https://www.gamedeveloper.com/design/dissecting-design----the-in-accessible-nature-of-celeste)
- [Hades God Mode - Wiki](https://hades.fandom.com/wiki/God_Mode)
- [Hades devs reveal how God Mode solves the worst thing about the genre](https://www.inverse.com/gaming/hades-god-mode-interview)
- [God Mode Is The Best Thing About Hades](https://www.thegamer.com/god-mode-hades/)
- [Dead Cells Assist Mode and Accessibility](https://deadcells.wiki.gg/wiki/Assist_Mode_and_Accessibility)
- [Dead Cells Accessibility Update](https://www.nintendolife.com/news/2022/06/dead-cells-accessibility-focused-update-adds-assist-mode-difficulty-options-and-more)
- [Dynamic Game Difficulty Balancing - Wikipedia](https://en.wikipedia.org/wiki/Dynamic_game_difficulty_balancing)
- [More Than Meets the Eye: Secrets of DDA](https://www.gamedeveloper.com/design/more-than-meets-the-eye-the-secrets-of-dynamic-difficulty-adjustment)
- [Improving User Retention Through Rubber Banding](https://www.patent355.com/resources/rubber-banding-in-gaming-a-technique-for-improved-retention)
- [Cuphead and Problems With Difficulty](https://www.gamespot.com/articles/cuphead-and-the-problems-with-difficulty-in-video-/1100-6454074/)
- [Cage: Game Over State a Design Failure](https://mcvuk.com/development-news/cage-game-over-state-a-design-failure/)
- [Emotions and Mechanics: Lessons about Shame](https://www.gamedeveloper.com/design/emotions-and-mechanics-1-lessons-about-shame)
- [Psychology of Hot Streak Game Design Without Shame](https://uxmag.com/articles/the-psychology-of-hot-streak-game-design-how-to-keep-players-coming-back-every-day-without-shame)
- [GameDev Protips: How To Design A Truly Compelling Roguelike](https://medium.com/@doandaniel/gamedev-protips-how-to-design-a-truly-compelling-roguelike-game-d4e7e00dee4)

---

*Research completed: 2026-02-02*
*Session: 29*
