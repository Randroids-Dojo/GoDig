# Procedural Content Fatigue Research

## Overview

Research into how infinite/endless games prevent content fatigue and maintain variety. Understanding what makes run 100 feel different from run 10, and how to balance novelty with mastery.

## The Problem: Procedural Fatigue

> "If the underlying generation algorithms are too simple or repetitive, players may eventually recognize patterns, leading to a sense of sameness despite technical 'uniqueness.'"

**Warning Signs:**
- Players recognize generation patterns
- Outcomes feel recycled
- "Same but different" becomes "just same"
- Exploration loses its pull

**The Core Tension:**
- Procedural = infinite variety, but can feel hollow
- Handcrafted = meaningful, but finite
- Solution = hybrid approaches that combine both

## Hybrid Approaches That Work

### Strategy 1: Handcrafted Chunks + Procedural Assembly

**Spelunky 2 Method:**
- Levels made of "rooms" (10x8 tiles)
- Rooms contain "chunks" (5x3 tiles)
- Chunks can contain "50% tiles" (random variations)

**The Magic Formula:**
```
Random rooms → containing random chunks → containing tiles
that randomly roll between choices
```

**Derek Yu's Philosophy:**
> "Strike a balance between randomness and authorship. Levels should feel handcrafted and satisfying while offering endless variety."

**Key Technique:** Room templates organized by type (entrance, corridor, drop-down, side area). Game picks appropriate template for each position.

**Spelunky 2's Two-Layer System:**
- Front layer: Main path with entrance/exit
- Back layer: Hidden areas via doors/tunnels
- Layers share grid positions (can see into back layer)

### Strategy 2: Procedural Base + Handcrafted Points of Interest

**The "Daggerfall vs Morrowind" Lesson:**
- Daggerfall: Massive procedural world, locations feel interchangeable
- Morrowind: Smaller handcrafted world, every zone memorable

**Successful Hybrid Example:**
> "Procedural generation creates the initial layout (continents, mountains, rivers), but hand-crafted points of interest (cities, dungeons, ruins). The difference was night and day."

**Diablo's Approach:**
- Procedural dungeon layouts
- Preset special areas (boss stages, story locations)
- Fixed structures support plot without compromising variety

### Strategy 3: Strong Core Gameplay Carrying the Loop

**Hades Example:**
- Procedurally generated room arrangements
- Finely curated enemy placements and room types
- Combat and story engaging enough that similar zones don't diminish experience

**The Insight:**
> "Regardless of how well-implemented the procedurally generated content is, these games require a foundation of solid and engaging gameplay."

## Keeping Runs Fresh: Unlock Systems

### Enter the Gungeon: Pool Expansion

**How It Works:**
- Boss credits unlock new items for the pool
- Unlocked items can appear in future runs
- Recently unlocked items have higher spawn chance

**Why It Works:**
- Discovery drives engagement: "What ridiculous weapon will I find next?"
- Synergies create variety: "A seemingly useless gun becomes powerful with the right item"
- Pool expansion means run 100 has more possibilities than run 1

**The Brilliance:**
> "The sense of discovery and the desire to see what new, ridiculous weapon you'll find on the next floor is what keeps players coming back."

### Dead Cells: Roguevania Progression

**Permanent Progress:**
- Cells, runes, blueprints persist
- New paths and levels unlock
- Mutations, abilities, weapons expand toolkit

**Boss Cell Difficulty:**
- Progressive difficulty scaling (0BC to 5BC)
- Each tier changes enemy behavior and mechanics
- Same levels feel different at higher difficulties

**The Loop:**
> "Learning from each failed run is how you move through the story and make progress."

### Hades: Narrative-Driven Discovery

**Wonderfully Paced:**
- Start with sword, unlock weapon classes quickly
- Then discover each weapon has aspects (deeper mythology)
- Every system links together

**What You Unlock:**
- Weapons and aspects
- Mirror of Night abilities
- Keepsakes and companions
- Story progression and relationships

**The Genius:**
> "Players might be forgiven for thinking there wasn't much more to discover. Then Supergiant uses the weapon system to delve into world mythologies."

### Slay the Spire: Ascension System

**Long-term Engagement:**
- Beat game → unlock harder level
- 20 Ascension levels total
- Same loop, escalating challenge

**Player Retention:**
- One player: 585 hours → 850 hours → 1100 hours over 4 years
- Working through all Ascension 20 with different characters

## Discovery Cadence

### When to Reveal New Content

**Early Game (Runs 1-10):**
- Frequent unlocks to establish variety
- Show the "tip of the iceberg"
- Build confidence before adding complexity

**Mid Game (Runs 10-50):**
- Unlock pacing slows but stays steady
- Introduce synergies and deeper mechanics
- Player skill improving alongside options

**Late Game (Runs 50+):**
- Major unlocks become rare but impactful
- Secrets and hidden content emerge
- Mastery challenges replace discovery

### The "10% Rule"

From Noita community:
> "An 'average' player is barely going to see 10% of the full game, even 'experienced' players will barely see ~40% of the content."

**Design Choice:** Is this good or bad?

**Pros:**
- Creates community collaboration
- Rewards dedicated players
- Endless content for superfans

**Cons:**
- Average players miss 90%
- Can feel punishing without wiki
- Secrets may require file-diving to find

### Optimal Run Length

> "Every roguelite has a certain period during a run where it starts feeling like a chore rather than fun."

**Sweet Spot:** 20-30 minutes per run

**Why This Works:**
- Good power and difficulty curve
- Natural stopping point
- Enough time for meaningful progression
- Short enough to "one more run"

**Warning Signs of Too Long:**
- Players feel stuck
- Progressing through mud
- Scenery and variety draining

## Layered Secrets: The Noita Approach

### World Structure

**Seven main biomes, each with:**
- Main area (tutorial path)
- Western extension (harder version)
- Eastern extension (different variant)
- Hidden layers and parallel worlds

**Discovery Philosophy:**
> "The game is all about discovery and exploration."

### Hidden Mechanics

- Parry system (kick at exact frame)
- Obscure wand mechanics
- Environmental interactions
- Cryptic high scores

### The Community Problem

> "A game about exploration should enable players to discover most things without needing a wiki."

**Noita's Issue:**
- Secrets so hidden they'd take years to find naturally
- Many discovered only by looking at game files
- Contradicting design decisions for average vs hardcore players

**Lesson for GoDig:** Make secrets discoverable through play, not just data-mining.

## Recommendations for GoDig

### Procedural with Handcrafted Chunks

**Apply Spelunky Method:**
- Design 20-30 room templates per layer
- Include chunk variations within rooms
- Use 50% tiles for micro-variety

**Room Types to Design:**
- Entrance/start rooms
- Vertical shaft rooms (player digs down)
- Horizontal corridor rooms
- Cave/open rooms
- Treasure rooms
- Boss/challenge rooms

### Unlock System Design

**What to Add to Pool Over Time:**
- New ore types
- New item types (ropes, gadgets)
- New hazard types
- New traversal options
- Cosmetic variants

**Recently Unlocked Boost:**
- Items unlocked in last session have 3x spawn chance
- Ensures players experience new content

### Discovery Cadence for Mining Game

**Run 1-5:**
- Basic ores only
- Introduce ladders, wall-jump
- First shop experience

**Run 6-20:**
- Rare ores start appearing
- Cave generation active
- New shop types unlock

**Run 21-50:**
- Hidden treasure rooms appear
- Special items in pool
- Biome variants unlock

**Run 51-100:**
- Secret layers accessible
- Rare artifacts discoverable
- Challenge modifiers available

**Run 100+:**
- Meta secrets for community
- ARG-style hints
- Prestige-only content

### Avoiding Fatigue

**Regular Content Injection:**
- New parameters or variants
- Seasonal themes
- Limited-time discoveries

**Hybrid Handcrafted:**
- ~30% of depth milestones have fixed interesting content
- Boss encounters at specific depths
- Story beats at memorable locations

**Strong Core Loop:**
- Mining feels good on its own
- Procedural is bonus variety, not the hook
- Player skill growth matters

### Secret Layers (Without Wiki Dependency)

**Layer 1 (All Players):**
- Visible in normal play
- Clear breadcrumbs
- No guide needed

**Layer 2 (Explorers):**
- Environmental hints (different colored walls, audio cues)
- Reward curiosity
- Discoverable through observation

**Layer 3 (Dedicated):**
- Community collaboration
- Multiple-run secrets
- Optional, not required for completion

## Sources

- [SuperJump Magazine - By Design: Procedural Generation](https://www.superjumpmagazine.com/by-design-procedural-generation/)
- [Wayline - The Illusion of Infinite Games](https://www.wayline.io/blog/illusion-of-infinite-games-procedural-generation-human-touch)
- [Toolify - Spelunky's Level Generation Explained](https://www.toolify.ai/ai-news/unveiling-the-secrets-of-spelunkys-unique-level-creation-96286)
- [PCG Wiki - Spelunky](https://procedural-content-generation.fandom.com/wiki/Spelunky)
- [Hamatti's Notes - Meta Progression in Roguelikes](https://notes.hamatti.org/gaming/video-games/meta-progression-with-gradual-tutorial-in-roguelike-games)
- [Game Developer - What Happens When You Give Players 100 Tries](https://www.gamedeveloper.com/design/what-happens-when-you-give-players-100-tries-to-beat-a-roguelike-)
- [Enter the Gungeon Wiki - Unlockables](https://enterthegungeon.fandom.com/wiki/Unlockables)
- [Noita Wiki - Secrets](https://noita.fandom.com/wiki/Category:Secrets)
- [Noita Wiki - Mysteries and Oddities](https://noita.wiki.gg/wiki/Mysteries_and_Oddities)
- [Steam Store - Dead Cells](https://store.steampowered.com/app/588650/Dead_Cells/)
- [Netflix Tudum - Dead Cells Guide](https://www.netflix.com/tudum/articles/dead-cells-game-news)
- [Positech - Procedurally Generated Blandness](https://www.positech.co.uk/cliffsblog/2015/12/12/procedurally-generated-blandness/)
- [PC Gamer Forums - Procedural Generation Discussion](https://forums.pcgamer.com/threads/would-you-be-okay-with-procedural-generation-if-it-meant-endless-good-content.143579/)

## Related Implementation Tasks

- `implement: Surprise cave biome generation` - GoDig-implement-surprise-cave-4dc57740
- `implement: Hidden treasure rooms in procedural caves` - GoDig-implement-hidden-treasure-9fd6f4c2
- `implement: Layered secret system (Animal Well-inspired)` - GoDig-implement-layered-secret-8ba7afe0
- `implement: Handcrafted cave chunk system` - GoDig-implement-handcrafted-cave-812a8dfa
- `implement: Depth-based surprise caves and discoveries` - GoDig-implement-depth-based-fdc24d45
