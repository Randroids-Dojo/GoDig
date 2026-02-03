---
title: "research: Depth-based narrative progression"
status: closed
priority: 2
issue-type: research
created-at: "\"2026-02-02T22:25:33.528488-06:00\""
closed-at: "2026-02-02T22:34:00.348500-06:00"
close-reason: Completed research on depth-based narrative from Subnautica PDA system, metroidvania biome storytelling, and environmental narrative design. Documented layered history concept and journal system design.
---

## Research Question

How can mining games use environmental storytelling through layers, found journals, and world-building without relying on cutscenes?

## Key Findings

### 1. Narrative Stratigraphy - Depth as History

**Archaeological Metaphor:**
- "Narrative stratigraphy — the layering of cultural, historical, and emotional information into the physical space itself"
- Deeper layers reveal older histories
- Each depth zone represents a different era/civilization

**Subnautica's Depth Model:**
- "Depth as both a literal and metaphorical storytelling device"
- "Progression from colourful Safe Shallows to dark and dangerous depths mirrors the story's progression"
- Players uncover "more significant story revelations" as they go deeper

### 2. Environmental Storytelling Core Principles

**Definition:**
"A game design technique that embeds narrative elements directly into the environment using visual and audio cues"

**Key Elements:**
- Level design tells the story
- Art direction communicates meaning
- Subtle details over exposition dumps
- "Story emerges as a result of player initiative"

**Discovery-Based:**
- "Finding a hidden journal tucked away in an abandoned corner"
- "Deciphering the meaning behind the placement of specific objects"
- "The more they explore, the more pieces of the puzzle they find"

### 3. PDA/Journal Systems

**Subnautica's Approach:**
- PDA functions as "semiotic bridge between the system and the fictional world"
- "Provides real-time updates, infection scans, and data logs"
- Embedded directly into fictional world, not abstract menus
- "Each scan potentially reveals new exciting story elements"

**The Degasi Narrative:**
- Survivor story told through scattered PDAs at three bases
- "Journey from optimism to despair"
- "Logs shift from journal entries into cautionary warnings"
- Player pieces together what happened

### 4. Biome Identity and Storytelling

**Color Palette as Communication:**
- "Strict control of the colors in each biome"
- "Lighting serves narrative rather than realism"
- Visual identity telegraphs "where you are — and what might be possible now"

**Regional Identity:**
- Each zone has "strongly defined identity"
- Design constraints reflect narrative (tight spaces = danger)
- "Biome tone and geometry should telegraph" location and possibility

### 5. Metroidvania Narrative Patterns

**Level as Character:**
- Environment becomes "a character in its own right"
- "An adversary that the player will encounter, explore, and eventually overcome"

**Non-Linear Discovery:**
- "A collection of interesting places that the player might stumble upon in any order"
- Works for "lore-rich exploration of a place and its inhabitants"
- Ill-suited for linear plot, perfect for world-building

**Hollow Knight Example:**
- "Hallownest's districts broadcast culture through materials and fauna"
- "City marble, fungal growths, crystalline mines"
- "Graveyards, cocoons, abandoned workshops show lifecycle stages"

### 6. Player-Driven Discovery

**Subnautica Philosophy:**
- "Player decides their own path"
- "Stitching together understanding in their own order and at their own pace"
- Guided by "resource placement, level design, and narrative incentives"

**Outer Wilds:**
- "Clues can be acquired in any order, each playthrough is unique"
- "The only thing changed is what players discovered"

## Application to GoDig

### Layered History Concept

**World History Through Depth:**

| Depth | Era | Visual Style | Story |
|-------|-----|--------------|-------|
| 0-100m | Modern | Familiar earth tones | Recent mining activity |
| 100-300m | Industrial (100 years ago) | Rusted metal, wooden beams | Abandoned mines |
| 300-500m | Ancient (1000 years) | Stone structures, carvings | Lost civilization |
| 500-1000m | Prehistoric | Fossils, crystal caves | Before humans |
| 1000-2000m | Primordial | Alien materials, void | Unknown origin |
| 2000m+ | The Deep | Otherworldly | Cosmic mystery |

### Environmental Storytelling Elements

**Visual Progression:**
- Surface: Warm browns, greens, sunlight
- Shallow: Earth tones, scattered tools
- Mid-depth: Blues and grays, rusted machinery
- Deep: Purple and red, crystal formations
- Void: Black and alien colors

**Found Objects Per Layer:**
1. **Modern Layer:** Mining helmets, broken pickaxes, dated newspapers
2. **Industrial Layer:** Old machinery parts, miner journals, company signs
3. **Ancient Layer:** Stone tablets, mysterious tools, burial markers
4. **Prehistoric Layer:** Fossils, petrified wood, ancient creatures
5. **Primordial Layer:** Alien artifacts, void crystals, incomprehensible tech

### Journal System Design

**Discovery Log:**
- Auto-records first encounter with each element
- Player can review at any time
- Builds complete picture of world history

**Entry Types:**
1. **Miner's Logs** - Personal stories from past explorers
2. **Historical Records** - Facts about the underground
3. **Scientific Notes** - Analysis of materials found
4. **Mysterious Texts** - Cryptic messages from deeper layers
5. **Player Notes** - Optional personal annotations

**Placement Philosophy:**
- "Hidden journal tucked away in abandoned corner"
- Near notable landmarks (old machinery, cave entrances)
- Require slight detour from main path
- Reward exploration without blocking progress

### Narrative Without Cutscenes

**Methods:**
1. **Visual details** - Skeletons near collapsed tunnels, rusted tools
2. **Environmental cues** - Claw marks, abandoned camps
3. **Found logs** - Text entries in journal
4. **NPC dialogue** - Surface shop owners share rumors
5. **Artifact descriptions** - Flavor text on discoveries

**Key Principles:**
- Never interrupt gameplay
- Discovery is optional but rewarding
- Curiosity-driven, not forced
- Each layer tells its own story

### Depth-Gated Revelations

**Story Breadcrumbs:**
- 100m: First hint of abandoned mines
- 300m: Evidence of lost civilization
- 500m: Signs of something ancient
- 1000m: First void artifact found
- 2000m: Ultimate mystery revealed

**Connecting Threads:**
- Multiple miner journals found across depths
- Each adds to a single narrative
- Full picture only visible to deep explorers

### Anti-Frustration Design

**From Research:**
1. **Non-blocking** - Story never required for gameplay
2. **Redundancy** - Key lore in multiple locations
3. **Summary available** - Journal tracks what's been found
4. **Skip-friendly** - Text can be skipped without penalty

## Implementation Recommendations

### Phase 1 (v1.0): Visual Storytelling
- Color palette shifts by depth
- Environmental details (old tools, structures)
- Simple flavor text on ore/block descriptions

### Phase 2 (v1.1): Journal System
- Discovery log with basic entries
- Found journals at key locations
- Surface NPC rumor dialogue

### Phase 3 (v1.2+): Full Narrative
- Complete world history
- Multiple storylines to follow
- Deep mystery with satisfying resolution
- Achievement for piecing it all together

## Design Principles

1. **Show, Don't Tell** - Environment communicates before text
2. **Depth = Time** - Further down is further back in history
3. **Optional Discovery** - Rewards curious players, doesn't punish speedrunners
4. **Coherent World** - All pieces fit together
5. **Player Agency** - Discover in any order
6. **Visual Hierarchy** - Each layer immediately recognizable

## Sources

- [Environmental Storytelling in Video Games - Game Design Skills](https://gamedesignskills.com/game-design/environmental-storytelling/)
- [Beneath the Surface: Narrative Design in Subnautica - Medium](https://medium.com/@tht13/beneath-the-surface-narrative-design-and-emotional-immersion-in-subnautica-e314f958a997)
- [Subnautica: Guiding Natural Exploration - Jack Briggs](https://jackbriggs.dev/subnautica-guiding-natural-exploration/)
- [Metroidvania Explained - AllThings.how](https://allthings.how/metroidvania-explained-design-pillars-history-scope/)
- [Procedural Metroidvania Level Design - Game Developer](https://www.gamedeveloper.com/design/building-the-level-design-of-a-procedurally-generated-metroidvania-a-hybrid-approach-)
- [Environmental Storytelling Techniques - Keewano](https://keewano.com/blog/5-environmental-storytelling-techniques-every-game-writer-must-know/)

## Status

Research complete. Provides narrative framework for depth-based world-building and journal system.
