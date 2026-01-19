---
title: "research: Competitive analysis - mining games"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-01-18T23:42:36.852935-06:00\\\"\""
closed-at: "2026-01-19T00:12:57.011265-06:00"
close-reason: Completed analysis of Motherload, SteamWorld Dig, Dome Keeper, Terraria, mobile idle miners, Dig Dug, Mr Driller. Documented findings and recommendations. Enhanced tap-to-dig spec with hold-to-mine.
---

Research similar mining/digging games discussed online. Look at: Motherload, SteamWorld Dig, Dome Keeper, Dig Dug, Mr. Driller, Terraria mining. What do players love/hate? What mechanics are praised? What's missing from competitors? Check Reddit, Steam reviews, YouTube comments, game forums. Document findings and create implementation tasks for good ideas.

## Research Findings

### Motherload / Super Motherload

**What Players Love:**
- "Strangely addicting" core loop - dig, mine ore, buy upgrades, repeat
- Local co-op support (rare in modern games)
- Zen-like solo gameplay
- Soundtrack praised
- "Treasure hunting" feeling of digging for goodies
- "Expertly hand-crafted" balance and pacing

**What Players Hate:**
- Gets repetitive - "first hour replicated over and over"
- Story not motivating enough
- Multiplayer has fuel-sharing issues
- No fear/tension compared to original (fuel = slow, not death)
- Arbitrary progression gates tied to story
- Lack of novelty ores, artifacts, or interesting puzzles

**Key Insight:** Simple mechanics need depth through variety (new ores to discover, artifacts, meaningful upgrades)

---

### SteamWorld Dig Series

**What Players Love:**
- Unique combo: resource gathering + platforming + steady progression
- Upgrades provide satisfying sense of progression
- "Rare gem" that blends Metroidvania with mining
- Movement abilities are fun (speed, steam jump, drill)
- SteamWorld Dig 2 praised for more puzzles and movement variety

**What Players Hate:**
- Original too short
- Repetitive, simple enemies
- Orb distribution uneven (too rare early, too common late)

**Key Insight:** Movement upgrades and exploration abilities add replay value. Breaking up digging with puzzles helps pacing.

---

### Dome Keeper

**What Players Love:**
- 92% positive on Steam (18k reviews)
- "Addictive" hybrid of peaceful mining + intense defense
- High replayability via unlocks (chars, tools, maps, modes)
- Perfect for short pick-up sessions
- "Devoid of downtime" - always tension from attack timer
- "Relaxing yet tense" paradox makes it engaging

**What Players Hate:**
- Limited content
- Can feel repetitive
- Balance issues
- Wants more content to flesh out concept

**Key Insight:** Time pressure (attack waves) creates tension that makes peaceful mining more satisfying. Unlockables drive replay.

---

### Terraria Mining

**What Players Love:**
- Mining is primary progression mechanism
- Tool upgrades are mandatory and satisfying
- Multiple methods: pickaxe, drill, bombs, rockets
- Potions enhance mining (Spelunker, Mining, Dangersense)
- Smart Cursor QoL feature
- Discovering veins is "most satisfying moment"
- Chlorophyte ore grows/spreads - dynamic ore mechanic

**Key Insight:** Multiple mining methods and enhancement options (potions, accessories) add depth. Dynamic/growing ores are innovative.

---

### Mobile Idle Mining Games (Gold and Goblins, ExoMiner, Idle Miner Tycoon, Mr. Mine)

**Common Praised Mechanics:**
- Automation and offline progression
- Satisfying visual upgrades
- Prestige/reset systems for long-term engagement
- Easy to understand, hard to master
- Check-in-for-few-minutes design
- Manager/automation systems

**Key Insight:** Mobile players value: offline progress, automation unlocks, visual feedback of growth, prestige systems.

---

### Classic Arcade (Dig Dug, Mr. Driller)

**Dig Dug Design Philosophy:**
- Player-created mazes (freedom of movement vs Pac-Man's fixed paths)
- Action + strategy combination
- Addictive gameplay, cute characters

**Mr. Driller Design Philosophy:**
- "Two buttons is all you need" - simplicity
- Actions have consequences (digging causes cave-ins)
- Chain reactions from same-color blocks
- Bright, pastel colors for wide appeal
- Cross between puzzle (Puyo Puyo) and action (Dig Dug)

**Key Insight:** Simple controls + meaningful consequences = depth. Visual appeal matters for broad audience.

---

### Common Player Pain Points Across Mining Games

1. **Mining is tedious** - too many clicks, not enough variety
2. **Getting stuck** - no way to dig upward or recover from mistakes
3. **No placeable platforms/ladders** - can't navigate cleared areas
4. **Repetitive content** - same ores, same mechanics throughout
5. **Lack of artifacts/treasures** - missing collectibles and surprises
6. **Shadow/lighting issues** - can't see in dark areas
7. **Hand strain** - "issues with hand when clicking too much" (hold-to-mine requested)

---

## Recommendations for GoDig

### Must-Have (MVP-Level)

1. **Hold-to-mine** - Reduce click fatigue, essential for mobile
2. **Clear visual progression** - Different ores with distinct colors/values
3. **Satisfying upgrade curve** - Tool upgrades should feel meaningful
4. **Simple controls** - One-button dig action (tap/hold)

### Should-Have (V1.0)

1. **Placeable ladders** - Already planned, validated by player feedback
2. **Varied ores with depth** - Discovery moments when finding new ore types
3. **Artifacts/treasures** - Unique finds beyond ores
4. **Time-based tension** - Consider optional challenge modes with timers
5. **Offline progress** - Even minimal idle gains for mobile players

### Could-Have (V1.1+)

1. **Prestige system** - Reset with bonuses for long-term engagement
2. **Dynamic ores** - Ores that grow or change over time
3. **Chain reaction mechanics** - Same-color block destruction
4. **Automation** - Auto-miners or helper NPCs
5. **Multiple mining methods** - Bombs, drills, special tools

---

## Implementation Tasks Created

### Existing Tasks Validated by Research

- `GoDig-v1-0-placeable-7d46e882` - Placeable ladders (player pain point)
- `GoDig-v1-0-artifact-76e2f78d` - Artifact spawning system
- `GoDig-v1-1-prestige-d7d2cd31` - Prestige/rebirth system
- `GoDig-dev-lighting-by-7b1d4ed0` - Lighting by depth (addresses visibility complaints)
- `GoDig-mvp-2-3-e92f5253` - Tool upgrade tiers

### Updated Tasks

- `GoDig-dev-tap-to-c2325d86` - Enhanced with hold-to-mine spec (addresses click fatigue)
