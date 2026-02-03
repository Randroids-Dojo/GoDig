# Environmental Storytelling in Underground Games

## Overview

This research examines how mining and underground exploration games tell stories through environment rather than explicit narrative. The goal is to identify techniques for GoDig's discoverable lore system that enhance depth progression and create memorable discovery moments.

## Core Principles

### Show, Don't Tell (Or Better: Do, Don't Show)

The most effective environmental storytelling lets players experience the world directly:
- **Traditional cutscenes** = describing/explaining the world
- **Environmental storytelling** = allowing players to explain the world to themselves
- **Interactive discovery** = players becoming active archaeologists

Andrew Stanton's "2+2 Storytelling" principle: Show cool things in the best light, let the audience decide what they think. Respect player intelligence.

### The Archaeological Player

Players naturally adopt an archaeological mindset when exploring underground spaces:
- Examining ruins and abandoned structures
- Interpreting material evidence
- Reconstructing history from fragments
- Finding satisfaction in piecing together narratives

This approach transforms passive recipients of lore into active investigators.

## Case Studies

### Hollow Knight: Minimalist Mastery

**Techniques Used:**
- Sparse, utilitarian dialogue
- Opaque written lore (lore tablets)
- NPCs as "walking history" (decaying knights, wandering survivors)
- Environmental decay as narrative (crumbling walls, forgotten paths)
- Hunter's Journal entries for discovered creatures

**Key Insight:** The narrative is delivered through showing, not telling. The ruined kingdom of Hallownest IS the story - players inhabit the decay rather than being told about it.

**Application to Mining Games:**
- Abandoned mineshaft equipment tells stories of previous diggers
- Skeletal remains in dangerous areas warn without words
- Murals on cave walls hint at ancient civilizations
- Ghost NPCs sharing fragments before fading

### Dark Souls: Item Description Narrative

**Techniques Used:**
- Item descriptions contain lore fragments
- Deliberate item placement based on area relevance
- Interconnected areas telling broader stories
- "Opt-in narrative" - story participation is player choice
- Visual design of world itself as storytelling medium

**Key Insight:** Lore is tied to equipment management. Players absorb story while doing gameplay tasks (checking stats, managing inventory).

**Application to Mining Games:**
- Ore descriptions hint at geological/historical significance
- Equipment found in world tells stories of previous owners
- Tool descriptions reference their forging/history
- Artifact items with cryptic backstories

### Outer Wilds: Knowledge as Progression

**Techniques Used:**
- Time loop enables iterative discovery
- Alien writings, architecture, and experiments as narrative
- No traditional upgrades - only knowledge progression
- Systemic design (consistent physics rules)
- Discovery ties directly to ability to progress

**Key Insight:** Players become archaeologists reconstructing history through observation and deduction. Each discovery is personally meaningful because it was earned through exploration, not granted through cutscenes.

**Application to Mining Games:**
- Discovery of ancient mining techniques reveals new mechanics
- Finding journals explains world rules (why ore appears at certain depths)
- Knowledge rewards feel more personal than stat upgrades
- Consistent world rules make discoveries feel earned

### Subnautica: Biome Storytelling

**Techniques Used:**
- Each biome has distinct visual identity and emotional tone
- PDAs and logs scattered throughout world
- Survivor base locations trace narrative arc (optimism to despair)
- Audio design contributes to atmosphere
- Alien ruins integrated with exploration progression

**Key Insight:** Biomes themselves tell stories through atmosphere, danger level, and resource availability. The Degasi survivor narrative unfolds across three bases, each representing a stage of their journey.

**Application to Mining Games:**
- Each depth layer has distinct personality and implicit history
- Audio shifts to match layer mood (warm surface, ominous depths)
- Previous explorers' campsites reveal their progression/fate
- Ancient alien installations hint at why ores exist

## Procedural Generation Challenges

Environmental storytelling in procedural games faces unique challenges:

### The Problem
- Handcrafted details feel out of place in random layouts
- Static story elements conflict with infinite variety
- Players may miss scattered narrative fragments

### Solutions

**Localized Environmental Storytelling:**
- Small self-contained vignettes that work anywhere
- Scrap and broken equipment from failed expeditions
- Abandoned camps with partial notes
- Bodies positioned to suggest cause of death

**Modular Narrative Elements:**
- Pre-made "story chunks" that slot into procedural layouts
- Consistent visual language (same warning symbols, same artifact styles)
- Procedurally selected but hand-authored text fragments

**Opt-In Design:**
- Story doesn't block gameplay
- Players who want pure gameplay can ignore lore
- Collectible-style discovery (journal filling)

## Environmental Storytelling Techniques

### Visual Language of Decay

| Visual Element | Narrative Implication |
|----------------|----------------------|
| Fallen beams blocking doorways | Violent event or time passage |
| Outward-radiating broken glass | Explosion |
| Water damage patterns | Gradual abandonment |
| Rust progression | Time since last use |
| Bones with pickaxe marks | Dangerous mining accident |
| Intact equipment near skeleton | Sudden death |
| Scattered equipment trail | Desperate flight |

### Stratigraphic Storytelling

Borrowed from archaeology - deeper layers reveal older histories:

```
Surface (0-50m):    Modern equipment, recent tragedy
Shallow (50-200m):  Victorian-era mining remnants
Mid-depth (200-500m): Medieval mining artifacts
Deep (500m+):       Ancient/alien civilization remains
Abyss:              Origins, primordial mysteries
```

Each depth layer can have its own "era" of artifacts and lore.

### Object Placement as Narrative

**Intentional Juxtaposition:**
- Pickaxe next to unreachable ore vein = tragic irony
- Safety rope cut halfway down = sabotage or accident?
- Two skeletons facing each other = conflict or comfort?

**Environmental Context:**
- Items in water suggest drowning
- Items near lava suggest heat-related death
- Items in narrow passages suggest crushing/suffocation

## GoDig Implementation Recommendations

### Discoverable Lore System

**Journal/Codex:**
- Unlockable entries for found artifacts
- Fragments combine to reveal larger story
- Completion percentage as long-term goal

**Artifact Types:**

| Type | Example | Lore Function |
|------|---------|---------------|
| Journal Pages | Miner's diary entries | Personal stories |
| Ancient Carvings | Cave wall symbols | Civilization history |
| Equipment Remains | Rusted pickaxes, broken lanterns | Previous expedition fates |
| Geological Samples | Unusual ore formations | World-building science |
| Creature Fossils | Embedded in stone | Ancient ecosystem |
| Alien Tech | Glowing fragments | Deep lore mysteries |

### Layer Identity Through Environment

**Surface:**
- Bright, warm colors
- Recent wooden structures
- Cheerful NPC shopkeepers
- Safety and home feeling

**Shallow Mines (50-200m):**
- Industrial mine remnants
- Rusted rails and carts
- Abandoned tools with readable names
- "This could have been me" identification

**Deep Caves (200-500m):**
- Natural formations dominate
- Ancient torch sconces (who put them here?)
- Worn stone stairs (ancient pathways)
- Mystery introduction

**Abyssal Depths (500m+):**
- Alien architecture
- Glowing unknown materials
- Incomprehensible carvings
- Existential mystery

### Audio Environmental Storytelling

- Distant echoing pickaxe sounds (ghosts? other miners?)
- Rushing water suggesting underground rivers
- Creaking timbers in abandoned shafts
- Whispers in deepest areas (imagination or real?)
- Musical stings for discovery moments

### Implementation Priorities

**MVP (v1.0):**
- [ ] Skeleton/remains placement with implied cause
- [ ] 3-5 discoverable journal fragments per layer
- [ ] Unique visual artifacts for each depth range
- [ ] Basic codex/journal collection UI

**Post-Launch (v1.1):**
- [ ] Audio environmental storytelling
- [ ] NPC ghost encounters (brief, cryptic)
- [ ] Connected lore fragments (pieces form story)
- [ ] Achievement for lore completion

**Future (v1.2+):**
- [ ] Player-discoverable secrets changing world state
- [ ] Optional deep lore areas (Animal Well-style secrets)
- [ ] Community lore speculation support (share discoveries)

## Key Takeaways

1. **Let players be archaeologists** - Discovery feels more meaningful when players piece things together themselves
2. **Decay tells stories** - Visual state of objects implies history without words
3. **Opt-in narrative** - Story enhances but never blocks gameplay
4. **Depth = time** - Use depth layers as archaeological strata
5. **Consistent visual language** - Same symbols, same artifact styles throughout
6. **Personal stories resonate** - Individual miners' fates > abstract history
7. **Mystery maintains engagement** - Not everything needs explanation

## Sources

- [Hollow Knight Environmental Storytelling Analysis](https://medium.com/@anknguyen21/walking-through-ruin-story-space-and-cyclical-tragedy-in-hollow-knight-3bcaac4e53f6)
- [Hollow Knight Minimalist Storytelling](https://longriverreview.com/blog/2024/hollow-knight-memory-and-minimalist-storytelling/)
- [Dark Souls Narrative Design](https://www.gamedeveloper.com/design/narrative-design-in-dark-souls)
- [FromSoftware Environmental Storytelling](https://lokeysouls.com/2020/11/16/environmental-storytelling/)
- [Outer Wilds Museum Analysis](https://www.wonderfulmuseums.com/museum/outer-wilds-it-belongs-in-a-museum/)
- [Subnautica Narrative Design](https://medium.com/@tht13/beneath-the-surface-narrative-design-and-emotional-immersion-in-subnautica-e314f958a997)
- [Weaving Narratives into Procedural Worlds](https://www.gamedeveloper.com/design/weaving-narratives-into-procedural-worlds)
- [Environmental Storytelling in Video Games](https://gamedesignskills.com/game-design/environmental-storytelling/)
- [Archaeological Gameworld Affordances](https://dl.acm.org/doi/10.1145/3706598.3714036)
- [Game Maker's Toolkit](https://gamemakerstoolkit.com/)
- [2+2 Storytelling and Show Don't Tell](https://www.derek-lieu.com/blog/2018/12/16/22-storytelling-and-show-dont-tell)
