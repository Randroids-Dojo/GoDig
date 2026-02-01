---
title: "research: Variable reward and discovery moments"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"2026-02-01T01:08:19.026086-06:00\\\"\""
closed-at: "2026-02-01T01:20:55.261406-06:00"
close-reason: "Created 5 implementation dots for variable reward improvements: near-miss hints, jackpot celebrations, first-discovery bonuses, cave treasures, deep dive tension meter"
---

Analyze and improve the 'micro-discovery' moments that drive engagement in mining games.

## Research Findings

### Psychology of Variable Rewards (Sources Analyzed)

**Variable Ratio Reinforcement** (from [Number Analytics](https://www.numberanalytics.com/blog/mastering-reward-schedules-game-design), [PMC Research](https://pmc.ncbi.nlm.nih.gov/articles/PMC7882574/)):
- Variable-ratio schedules deliver rewards "after an unpredictable number of actions"
- Creates anticipation and excitement as players are unsure when next reward arrives
- "Dopamine cells are most active when there is maximum uncertainty"
- Brain releases dopamine in response to uncertain reward even before reward appears
- More psychologically compelling than fixed-ratio (predictable) rewards

**Near-Miss Psychology** (from [Psychology of Games](https://www.psychologyofgames.com/2016/09/the-near-miss-effect-and-game-rewards/)):
- Near misses activate same reward systems as actual wins
- May be MORE motivating than winning or losing
- Creates perception of "almost winning" which encourages retry
- Visual/audio cues heighten emotional impact of near-wins

**Mining Game Return Trip Tension** (from analysis of [Deep Rock Galactic](https://en.wikipedia.org/wiki/Deep_Rock_Galactic), [Dome Keeper](https://thirdcoastreview.com/games-tech/2022/10/06/review-dome-keeper)):
- Deep Rock Galactic: "delightfully tense" extraction phase - limited time to return while fighting off enemies
- Dome Keeper: "Mining is meditative, but tension hangs in background" - race back to defend
- The fear of losing collected resources drives strategic thinking
- "Do you push your luck and mine deeper, or play it safe?"

**Anticipation vs Reward** (from [Gamedeveloper Compulsion Loops](https://www.gamedeveloper.com/design/compulsion-loops-dopamine-in-games-and-gamification)):
- Counter-intuitively, dopamine is produced during ANTICIPATION, not just reward
- "Thinking about the project produces dopamine"
- Games are effective because they provide: anticipation + unpredictability + immediate feedback

### Current Implementation Analysis

**Ore Distribution (from code analysis):**
| Ore | Spawn Threshold | Min Depth | Vein Size | Sell Value |
|-----|----------------|-----------|-----------|------------|
| Coal | 0.75 | 0m | 3-8 | 1 |
| Copper | 0.78 | 10m | 2-6 | 5 |
| Iron | ~0.80 | 50m | 2-5 | 15 |
| Silver | ~0.85 | 150m | 2-4 | 50 |
| Gold | 0.92 | 300m | 1-3 | 100 |
| Ruby (gem) | 0.97 | 500m | 1-2 | 500 |

**Discovery Feedback (current):**
- Ore sparkle effect with rarity-based frequency (common: 3-5s, legendary: 0.5-1.5s)
- Rarity borders on ore blocks
- Colorblind symbols available
- `block_destroyed` signal for screen shake/particles

**Cave Generation:**
- Starts at 20m depth
- Threshold 0.85 (15% chance per eligible tile)
- Slightly more common with depth

**Fossil System:**
- 0.5% base chance per block
- Depth-tiered rarities (common at 50m, legendary at 500m+)

### Identified Gaps & Opportunities

1. **Reward Frequency Analysis:**
   - Early game (0-50m): ~22% of blocks have coal/copper (threshold 0.75-0.78 = ~22-25% spawn)
   - This is reasonable variable ratio but all common items
   - No "near-miss" excitement - blocks either have ore or don't

2. **Missing "Near-Miss" Moments:**
   - No visual indication of "almost found something"
   - No "vein indicator" showing proximity to ore clusters
   - No partial discoveries or breadcrumb trails

3. **Discovery Celebration Gaps:**
   - No special feedback for FIRST discovery of ore type
   - No "jackpot moment" visual/audio for rare finds
   - Gems should feel significantly different from common ores
   - No discovery log or collection tracking visible during mining

4. **Cave Discovery:**
   - Caves exist but no "discovery moment" - player just falls into empty space
   - No chest/treasure at cave locations
   - No "cave discovered!" celebration

5. **Return Trip Tension:**
   - Inventory warnings at 80% exist
   - No visible "distance from surface" indicator during deep runs
   - No escalating tension signals as resources accumulate

## Questions Answered

**Q1: What % of blocks contain something interesting?**
- Early game: ~22-25% have coal/copper
- Mid-game: Similar but includes rarer ores
- Issue: All discoveries feel similar - no rarity differentiation in feedback

**Q2: Are ore distributions creating enough 'surprise' moments?**
- Vein clustering creates some clump surprise
- But no "jackpot" feeling for rare finds
- Missing: treasure chests, artifact caches, bonus ore pockets

**Q3: Do rare finds feel sufficiently celebrated?**
- NO - sparkle frequency increases but discovery moment is same
- Missing: special sound, screen effect, popup, haptic for rare finds
- Missing: "first discovery" bonus/celebration

**Q4: Are caves generating discovery dopamine?**
- PARTIALLY - caves exist but feel empty
- Missing: cave treasures, chest spawns, hidden artifacts
- Missing: cave discovery notification

## Created Implementation Dots

Based on this research, I've created the following implementation specs:
- `implement: Near-miss ore hints` - Visual hints when close to ore veins
- `implement: Jackpot discovery celebration` - Enhanced feedback for rare finds
- `implement: First-discovery bonus system` - Bonus rewards/celebration for new ore types
- `implement: Cave treasures` - Chests and artifacts in cave spaces
- `implement: Deep dive tension meter` - Visual indicator of accumulated risk
