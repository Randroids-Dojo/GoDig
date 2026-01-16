# Competitive Analysis: Mining Games

## Overview
Deep analysis of successful mining/digging games to inform GoDig's design decisions.

---

## 1. Motherload (2004 / 2013 Remaster)

### Core Mechanics
- **Movement**: Pod vehicle with fuel consumption
- **Digging**: Down, left, right only (no digging up)
- **Return**: Fly back up using remaining fuel
- **Resource**: Fill cargo hold, return to sell

### What Works
- Clear tension: fuel vs depth vs cargo capacity
- Simple but effective progression (better hull, engine, fuel tank)
- Satisfying "full cargo" feeling
- Mystery/story elements underground

### What Doesn't Work
- Can feel punishing (stranded = death)
- Repetitive mid-game
- Limited surface interaction
- Dated graphics

### Key Takeaways for GoDig
- Fuel mechanic creates tension but can frustrate
- "Pod" feel different from platformer movement
- Story elements add motivation beyond grinding
- Keep "full cargo = return" loop but soften punishment

---

## 2. SteamWorld Dig (2013) / SteamWorld Dig 2 (2017)

### Core Mechanics
- **Movement**: Platformer with wall-jump
- **Digging**: Grid-based, can unlock upward digging
- **Return**: Climb back manually, later teleport
- **Resource**: Collect orbs, sell for upgrades

### What Works
- Metroidvania progression (new abilities unlock areas)
- Wall-jump transforms gameplay feel
- Pre-designed caves with puzzles
- Satisfying "pop" feedback on dig
- Characters and story add charm

### What Doesn't Work
- Finite world (not endless)
- Can feel linear despite open structure
- Backtracking can be tedious before teleporter

### Key Takeaways for GoDig
- Wall-jump is essential for mobility
- Mix procedural with handcrafted content?
- Unlock abilities over time (drill for upward, etc.)
- Audio/visual feedback crucial for satisfaction

---

## 3. Terraria (2011)

### Core Mechanics
- **Movement**: Full 2D platformer
- **Digging**: Any direction, varied by tool
- **Return**: Build tunnels, use ropes, teleporters
- **Resource**: Craft, build, fight

### What Works
- Massive content depth
- Crafting creates goals beyond selling
- Boss progression gives milestones
- Multiplayer adds longevity

### What Doesn't Work
- Overwhelming for new players
- Combat focus may not suit casual mobile
- Complex crafting system
- Not idle-friendly

### Key Takeaways for GoDig
- Layer system works well (sky → underground → hell)
- Rare events (meteors, blood moon) add variety
- Don't need combat to be engaging
- Biome variety keeps exploration fresh

---

## 4. Mr. Mine (2015 - Web Idle)

### Core Mechanics
- **Movement**: Automated miners
- **Digging**: Passive/idle progression
- **Return**: Not applicable (idle)
- **Resource**: Accumulate offline, sell, upgrade

### What Works
- Perfect for mobile/casual
- Clear upgrade paths
- Satisfying number growth
- Low commitment, high reward
- Scientists/special mechanics add depth

### What Doesn't Work
- Limited active gameplay
- Can feel like just waiting
- Less "game" more "progress bar"

### Key Takeaways for GoDig
- Idle elements can complement active play
- Offline progress keeps players returning
- Multiple resource types add complexity
- Don't make idle the ONLY mechanic

---

## 5. Dome Keeper (2022)

### Core Mechanics
- **Movement**: Jet pack in underground
- **Digging**: Mine resources, return to defend dome
- **Return**: Time pressure (waves attack dome)
- **Resource**: Upgrade dome defenses and mining gear

### What Works
- Unique tension (defense vs mining)
- Roguelike runs create variety
- Tight core loop
- Satisfying resource discovery

### What Doesn't Work
- Can be stressful (defense pressure)
- Limited progression between runs
- Not endless (session-based)

### Key Takeaways for GoDig
- Tension doesn't need to be combat
- Session structure can work
- Upgrade choices matter
- Discovery moments are key

---

## 6. Core Keeper (2022)

### Core Mechanics
- **Movement**: Top-down exploration
- **Digging**: Any direction, tool-dependent
- **Return**: Craft paths, rails, portals
- **Resource**: Farm, craft, fight bosses

### What Works
- Exploration is compelling
- Base building satisfying
- Multiplayer community
- Farming adds passive income

### What Doesn't Work
- Top-down loses "digging down" feel
- Complex systems can overwhelm
- Combat focus

### Key Takeaways for GoDig
- Farming/passive income works well
- Base building is satisfying
- Keep systems focused, not sprawling

---

## 7. Forager (2019)

### Core Mechanics
- **Movement**: Top-down grid movement
- **Digging**: Mine nodes, not terrain
- **Return**: Not applicable (surface focus)
- **Resource**: Craft, build, expand islands

### What Works
- "One more thing" loop extremely effective
- Constant unlocks and discoveries
- Satisfying resource collection
- Land expansion is addictive

### What Doesn't Work
- Can become overwhelming
- Too many systems eventually
- Performance issues late-game

### Key Takeaways for GoDig
- Constant unlocks maintain engagement
- Land expansion (horizontal surface) works
- Keep systems manageable
- Performance must scale

---

## Feature Comparison Matrix

| Feature | Motherload | SWD | Terraria | Mr.Mine | Dome Keeper | GoDig Target |
|---------|------------|-----|----------|---------|-------------|--------------|
| Dig Direction | D/L/R | All* | All | Auto | All | D/L/R (unlock up) |
| Return Method | Fly | Climb | Build | N/A | Fly | Climb/Ladder |
| Resource Limit | Cargo | Inventory | Inventory | None | Timer | Inventory |
| Progression | Upgrades | Abilities | Crafting | Upgrades | Roguelike | Upgrades+Buildings |
| Endless Depth | No | No | Soft | Yes | No | Yes |
| Surface Building | No | No | Yes | Yes | No | Yes |
| Mobile Friendly | No | Moderate | No | Yes | No | Yes (Target) |
| Idle Elements | No | No | No | Yes | No | Optional |

---

## Lessons for GoDig

### Must Have
1. **Satisfying dig feedback** (SteamWorld Dig's "pop")
2. **Clear progression** (Motherload's upgrade path)
3. **Discovery moments** (Terraria's rare finds)
4. **Mobile-first controls** (Mr. Mine's simplicity)
5. **Surface building** (Forager's expansion loop)

### Should Have
1. **Wall-jump** (SteamWorld Dig's breakthrough)
2. **Depth layers** (Terraria's variety)
3. **Offline progress** (Mr. Mine's retention)
4. **Milestones** (Depth records, achievements)

### Consider Carefully
1. **Fuel/energy** (Can frustrate - make optional or soft)
2. **Combat** (Adds complexity, may not fit casual mobile)
3. **Crafting** (Keep simple or skip for sell-only)
4. **Multiplayer** (High effort, maybe v2.0+)

### Avoid
1. **Permadeath/harsh punishment** (Mobile players will quit)
2. **Complex crafting trees** (Overwhelming on mobile)
3. **Required grinding walls** (Respect player time)
4. **Intrusive monetization** (Build trust first)

---

## Unique Opportunities for GoDig

### 1. Endless Horizontal Surface
No competitor has truly endless surface building with endless depth.

### 2. Mobile-Native Design
Most mining games are PC-first. Building for mobile from start is advantage.

### 3. Casual + Deep
Bridge gap between idle (Mr. Mine) and active (SteamWorld Dig).

### 4. Modern Polish
Apply 2024+ mobile game UX standards to classic genre.

---

## Questions Answered by Analysis

| Question | Answer | Rationale |
|----------|--------|-----------|
| Dig up from start? | No, unlock later | SteamWorld Dig proves unlock feels rewarding |
| Fuel mechanic? | Soft/optional | Motherload shows it can frustrate |
| Combat? | No for MVP | Keeps focus, adds complexity |
| Crafting? | Minimal (sell-focused) | Mobile simplicity wins |
| Idle elements? | Yes (late game) | Mr. Mine retention model |
| Endless depth? | Yes | Unique differentiator |
