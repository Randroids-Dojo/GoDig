# Loading Perception: Psychology of Wait Times in Mobile Games

## Overview

This research documents how mobile games create the perception of faster loading, maintain player engagement during necessary waits, and hide loading behind gameplay elements. Applied to GoDig for chunk loading, scene transitions, save/load feedback, and surface return experiences.

## Sources

- [Effects of Interactive Loading Interfaces - Frontiers in VR](https://www.frontiersin.org/journals/virtual-reality/articles/10.3389/frvir.2025.1540406/full)
- [Shorter Wait Times: Effects of Loading Screens on Perceived Performance - ResearchGate](https://www.researchgate.net/publication/302073992_Shorter_Wait_Times_The_Effects_of_Various_Loading_Screens_on_Perceived_Performance)
- [When Fast Loading Times Change Gaming - The Koalition](https://thekoalition.com/2025/when-fast-loading-times-change-the-gaming-experience)
- [Speed Became Top Priority for Mobile Gamers 2025 - GameWatcher](https://www.gamewatcher.com/guides/how-speed-became-a-top-priority-for-mobile-gamers-in-2025)
- [Waiting to Play: Measuring Load Times - ACM FDG 2024](https://dl.acm.org/doi/10.1145/3649921.3649937)
- [Mobile Apps Initial Loading Pages Mental State - ScienceDirect](https://www.sciencedirect.com/science/article/abs/pii/S0141938221000214)
- [Best Practices for Mobile Game Optimization 2025](https://techlasi.com/mobile/best-practices-for-mobile-game-optimization/)
- [Passive and Interactive Loading Screen Types - ResearchGate](https://www.researchgate.net/publication/371897974_The_effects_of_mobile_applications'_passive_and_interactive_loading_screen_types_on_waiting_experience)
- [2025 Mobile Gaming Benchmarks - GameAnalytics](https://www.gameanalytics.com/reports/2025-mobile-gaming-benchmarks)
- [UX Best Practices for Play Instant Games - Android Developers](https://developer.android.com/topic/google-play-instant/best-practices/games)
- [Dynamic Loading - TV Tropes](https://tvtropes.org/pmwiki/pmwiki.php/Main/DynamicLoading)
- [Hidden Loading Screens in Games - GameRant](https://gamerant.com/games-best-hidden-loading-screens/)
- [How Modern Games Load Without You Knowing - Medium](https://medium.com/the-backend-deck/how-modern-games-load-without-you-knowing-dba0bd6ba9b4)
- [The Psychology of Waiting: Loaders in UX - Medium](https://medium.com/design-bootcamp/the-psychology-of-waiting-in-ux-0f0b24cdeb8f)
- [Response Time Limits - Nielsen Norman Group](https://www.nngroup.com/articles/response-times-3-important-limits/)
- [Progress Indicators - NN/g](https://www.nngroup.com/articles/progress-indicators/)
- [Interactive Loading Screens - GamesBeat](https://venturebeat.com/games/interactive-loading-screens)
- [Loading Screen Design - Steve Bromley](https://www.stevebromley.com/blog/2010/02/22/improving-the-player-experience-how-to-make-great-loading-screens/)

## Critical Time Thresholds

### Nielsen's Three Time Limits

These foundational UX thresholds from Jakob Nielsen remain relevant:

| Threshold | Player Experience | Implication |
|-----------|-------------------|-------------|
| **0.1 seconds** | System feels instantaneous | No feedback needed |
| **1.0 second** | Flow of thought stays uninterrupted | Brief indicator OK |
| **10 seconds** | Maximum focused attention | Must show progress, engagement |

### Mobile Gaming 2025 Reality

Current player expectations are stricter:

- **5 seconds**: Drop-off rates spike sharply if games take longer to load
- **3 seconds**: 53% of players abandon games that take longer to load
- **Instant**: Players equate fast performance with trust and quality

### Core Insight

Speed has evolved from a luxury into an absolute expectation. The days of waiting for loading bars or sluggish menus are over.

## The Psychology of Perceived Wait Time

### How Time Perception Works

Modifying visual and auditory stimuli during loading can direct users' attention toward these sensory inputs, effectively shortening their subjective perception of waiting time.

Key findings:
- Humans are poor at estimating time lapse on recall
- Designers can shape perception and manage tolerance
- Overly complex stimuli may overload cognitive resources and make waits seem longer
- Cognitive load decreases when users perceive more control

### The Flow State Connection

Fast loading maintains the "flow state" where players feel fully immersed and time passes quickly. Interruptions break this state, pulling players out of the experience.

### Progress Indicators vs. Nothing

Research at the University of Nebraska-Lincoln found:
- Users with moving progress bars experienced **higher satisfaction**
- They were willing to wait **3x longer** than those who saw no indicator
- Progress indicators reduce perceived time by dedicating cognitive resources to the feedback itself

## Progress Bar Design Psychology

### Speed Patterns Matter

| Pattern | Perception | Recommendation |
|---------|------------|----------------|
| Constant speed | Perceived as quickest | Good |
| Slow-to-fast | Perceived as quickest | **Best choice** |
| Fast-to-slow | Feels like slowing down | Avoid |
| Stalling/jumping | Unpredictable, frustrating | Avoid |

**Key Insight**: Starting slower and accelerating avoids establishing expectations the system can't maintain. Exceeding expectations creates satisfaction; disappointing creates frustration.

### When to Use Progress Bars

- Operations **over 10 seconds**: Use percent-done indicators
- Operations **under 10 seconds**: Consider animated spinner or interactive element
- Operations **under 1 second**: No indicator needed

Progress bars are "the ultimate tool for managing expectations." A long wait is 10x more tolerable if users can see a finish line.

## Interactive vs. Passive Loading

### Research Findings

- Interactive animations **reduced perceived wait times**
- Interactive loading led to **higher user satisfaction** vs passive loading
- Effect is strongest for **medium and long waits** (5-10+ seconds)
- For **short waits** (under 2 seconds), interactive feels "too busy"

### Color Matters

Color emerged as an influential factor:
- Color-changing interactive animations perceived as **faster and more likeable**
- Grey-scale or passive animations perceived as slower

### Mini-Games in Loading Screens

Historical context:
- Namco pioneered playable mini-games during loading (Galaxian in Ridge Racer, 1995)
- Patent prevented others from using this technique until 2015
- Now common: FIFA warm-up sessions, Okami button-mash rewards, Bayonetta practice moves

**GoDig consideration**: Mini-games are overkill for chunk loading (<1s) but could work for initial app launch or major scene transitions.

## Hidden Loading Techniques

### Disguised Loading in AAA Games

Modern games hide loading behind gameplay:

| Technique | How It Works | Examples |
|-----------|--------------|----------|
| **Tight spaces/crawls** | Player squeezes through while next area loads | God of War, Tomb Raider |
| **Elevators** | Riding time = loading time | Mass Effect, Dead Space |
| **Slow doors** | Animation plays while content streams | Dead Space's "unlocking" doors |
| **Loading tunnels** | Long corridors between zones | Tony Hawk's Unleashed |
| **Cutscenes** | Story plays while assets load | Uncharted cliff-climbing |
| **Slow walking** | Forced slow movement during streaming | Many narrative games |

### Dynamic/Level Streaming

Instead of loading the whole world at once, break into chunks:
- **GTA V**: Streams world as you drive, fly, run
- **Minecraft**: Loads chunk-by-chunk based on position
- **Elden Ring**: Only loads area around player
- **Crash Bandicoot (1996)**: Revolutionary 5-second load vs 30-40 second competitors

**GoDig already does this**: ChunkManager loads chunks dynamically as player descends.

### Mobile-Specific Tricks

Many mobile games show what looks like the game screen while still loading:
- **Boom Beach**: Shows "loaded" screen, then zooms into base (adds seconds)
- **Clash Royale**: Displays arena immediately, matchmaking happens in background
- **Pokemon GO**: AR camera warm-up disguises actual loading

## Progressive Loading Strategies

### Lazy Loading Approach

Load only what's immediately needed:
1. Essential gameplay elements first
2. Decorative assets in background
3. Future content predicted and pre-fetched

**Result**: Game feels faster despite same total data.

### Asset Prioritization

| Priority | What to Load | When |
|----------|--------------|------|
| **Critical** | Player, immediate terrain, core UI | Before "play" |
| **High** | Nearby chunks, common resources | First 100ms |
| **Medium** | Background art, music, effects | During play |
| **Low** | Future areas, rare resources | Predicted need |

### Compression Strategies

- Texture compression (ETC2 for Android, ASTC for iOS) reduces memory 60-80%
- Texture atlases combine multiple textures, reducing draw calls
- LOD (Level of Detail) switching based on distance, performance, battery

## GoDig-Specific Applications

### Chunk Loading Perception

Current state: ChunkManager streams chunks as player descends.

**Recommendations**:

1. **Pre-fetch downward chunks**
   - Player typically goes DOWN in mining games
   - Predict 2-3 chunks below current position
   - Load in background during gameplay

2. **Visual loading feedback**
   - For chunks that aren't ready: brief "fog" that clears
   - Feels intentional, like exploration fog
   - Never show loading indicator for <1 second operations

3. **Smooth chunk transitions**
   - No visible "pop-in" when chunks load
   - Fade in distant content gradually

### Scene Transition Design

Main menu -> Game, Surface -> Underground, etc.

**Recommendations**:

1. **Elevator metaphor for mine entry**
   - Player "descends" via animation
   - Matches mining theme
   - Hides loading behind thematic movement

2. **Cross-fade between scenes**
   - Brief animated transition (0.5-1s)
   - Use this time to stream assets
   - Player sees smooth transition, not loading bar

3. **Surface return as "ascent"**
   - Player rises back to surface
   - Celebration builds during transition
   - Loading happens during triumphant moment

### Save/Load Feedback

**Recommendations**:

1. **Instant resume expectation**
   - Auto-save should be invisible (<100ms perceived)
   - Show subtle icon briefly when saving
   - Never interrupt gameplay for save

2. **Cold start optimization**
   - Initial app launch: Show animated title + tip
   - Progressive disclosure: Get to gameplay ASAP
   - Load non-essential data after game is playable

3. **Continue game flow**
   - "Continue" should feel instant
   - Pre-load recent save data during menu display
   - Transition directly to gameplay state

### Return-to-Surface Transitions

This is a key moment in GoDig - selling loot and feeling accomplished.

**Recommendations**:

1. **Celebratory ascent animation**
   - Player rises while loot count animates
   - Loading happens behind celebration
   - Arrival at surface feels earned

2. **Shop loading hidden behind interaction**
   - Shop UI appears quickly
   - Detailed inventory loads while player reads
   - "Sell" animation covers any processing time

## Loading Screen Content

### What to Show (If Needed)

For unavoidable loading (initial launch, major transitions):

| Duration | Recommended Content |
|----------|---------------------|
| 1-3 seconds | Animated logo/mascot + title |
| 3-5 seconds | Tips, progress bar |
| 5-10 seconds | Interactive element, tips rotation |
| 10+ seconds | Consider mini-game or progress + story |

### Tips That Work

- Teach mechanics player hasn't mastered yet
- Reveal depth-layer lore/flavor text
- Tease upcoming content/unlocks
- Humor (but keep it brief)

### Tips to Avoid

- Obvious info ("Use ladders to climb")
- Same tip every time
- Tips that load faster than readable

## Implementation Priority for GoDig

### Phase 1: Invisible Loading (Current Priority)
- Ensure chunk loading never shows loading screen
- Pre-fetch chunks in direction of travel
- Smooth fade-in for newly loaded content

### Phase 2: Thematic Transitions
- Mine entrance "descend" animation
- Surface return "ascend" celebration
- Cross-fade scene transitions

### Phase 3: First Launch Experience
- Animated title screen during cold start
- Progressive asset loading
- Get player to gameplay in <5 seconds perceived

### Phase 4: Polish
- Tips during any unavoidable waits
- Loading tunnels/corridors if needed
- Elevator-style transitions between major areas

## Key Takeaways for GoDig

1. **Never show loading for <1 second operations** - Just do it, no indicator needed

2. **Pre-fetch downward** - Mining games have predictable traversal, use it

3. **Hide loading behind theme** - Elevator/descent fits mining perfectly

4. **Progress bars accelerate** - If showing progress, start slow, end fast

5. **Celebrate during load** - Surface return celebration covers any processing

6. **First 5 seconds are critical** - 53% abandon if loading takes longer

7. **Flow state is fragile** - Every loading screen breaks immersion; minimize them

8. **Mobile players expect instant** - No tolerance for traditional loading screens

## GoDig Loading Budget

Target loading perception by context:

| Context | Target Time | Strategy |
|---------|-------------|----------|
| Chunk load | Invisible | Pre-fetch, fade-in |
| Scene transition | <1s perceived | Animated transition |
| Initial launch | <3s to interactive | Progressive load |
| Return to surface | 0 (hidden) | Celebration animation |
| Save | <100ms flash | Icon only |
| Load saved game | <2s | Pre-load during menu |

Following these guidelines ensures GoDig feels responsive and modern, matching 2025 mobile player expectations.
