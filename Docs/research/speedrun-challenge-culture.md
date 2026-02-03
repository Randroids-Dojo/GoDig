# Speedrun and Challenge Culture in Mining Games

## Overview

This research examines how speedrun and challenge communities form around mining/digging games and what design elements support player-created challenges. Understanding these patterns helps inform GoDig's design for long-term replayability and community engagement.

## Speedrun Categories in Mining Games

### SteamWorld Dig Series
- **Any%** - Complete the game as fast as possible (current WR ~22:18)
- **4 Gold Stars** - Achieve all four gold stars in one playthrough (~1:03:21)
- Gold star requirements include: Speed (<2:30 total time), Deaths (0 deaths required for gold)
- Platform variations tracked separately (3DS, WiiU, PC)

### Motherload
- Community-created "Speedrun Edition" mod enables seeded runs
- Seed sharing allows for deterministic competition
- RNG in relic discovery creates tension between reset-heavy vs. adaptive play styles
- Original free version and Goldium Edition tracked as separate games

### Dome Keeper (Mining/Defense Hybrid)
- **Relic Hunt** - Main category (~2:32 record)
- **With Modifiers** / **No Modifiers** - Formal category split
- **Gadgetless** - Self-imposed restriction now formalized
- Guild rewards considered allowed in all categories (progressive unlocks affect runs)

### Terraria (Expansive Mining RPG)
- **Master Hardcore All Bosses NMA** - Ultimate challenge (~8+ hours)
- **No Major Abuses (NMA)** - No glitches/exploits rule set
- Explosive speedrunning meta - dynamite/bombs faster than pickaxes
- Save & Quit used to return to surface (accepted as legitimate strategy)

## Self-Imposed Challenge Patterns

### Common Challenge Types

| Challenge Type | Description | Games |
|----------------|-------------|-------|
| **No Upgrades** | Complete without purchasing/equipping upgrades | Stardew Valley, Terraria |
| **Pacifist** | Avoid killing enemies where possible | Spelunky, Terraria |
| **Low%** | Minimize item collection/pickups | Spelunky, Hollow Knight |
| **No Gold** | Complete without collecting currency | Spelunky 2 |
| **Hardcore** | Permadeath (no respawn) | Terraria, Binding of Isaac |
| **Seeded** | Use predetermined seed for fair competition | Spelunky 2, Motherload |
| **Eden Streak** | Win consecutively with randomized start (Isaac) | Binding of Isaac |

### Why Players Create Challenges
1. **Mastery expression** - Demonstrate skill beyond normal completion
2. **Renewed novelty** - Familiar game with fresh constraints
3. **Community competition** - Leaderboards and shared seeds
4. **Content extension** - More playtime from mastered game
5. **Streaming/content creation** - Engaging viewer content

## Daily Challenge Systems

### Dead Cells Model
- New map generated each day with timed competitive mode
- 4:30 time limit - different feel from main game's exploration
- Score-based leaderboards with "first run only" separate board
- Assist Mode disables leaderboard submission (accessibility without competition concerns)
- Refreshes at midnight UTC+1

### Slay the Spire Daily Climb
- Seeded run with randomly-selected character and three modifiers
- Always Ascension 0 (accessible difficulty)
- Act 4 disabled (shorter runs)
- Score modifiers: Light Speed (finish <45min = 50 bonus points)
- "Perfect" bonus for no-damage boss kills
- 24-hour availability window

### Binding of Isaac Daily Challenges
- Specific character, seed, end-stage, difficulty, and starting items
- Achievement tracking: "The Marathon" (5-win streak), "Dedication" (31 participations)
- No unlock progress during challenges (isolated from main progression)

### SANDRIPPER (Modern Example)
- Daily leaderboards with new seed each day
- Separate "Seeded Challenge Mode" with shared predetermined events
- Competition as social feature, not just individual replay value

## Pact of Punishment Pattern (Hades)

Hades' approach to difficulty scaling deserves special attention as a model for challenge-run support:

### Structure
- 15-16 conditions that can be mixed freely
- Each condition has multiple ranks (progressive severity)
- Heat gauge tracks total difficulty selected
- Bounty rewards tied to heat thresholds

### Notable Modifiers
- **Hard Labor** - Enemies deal 20-100% extra damage
- **Extreme Measures** - Bosses gain new attacks/phases
- **Damage Control** - Enemies get temporary shields
- **Lasting Consequences** - Reduced healing (20-100%)

### Infernal Gates (Perfect Clear)
- Heat-gated optional challenges (5/10/15 heat required)
- Zero-damage requirement for rewards
- 2x reward potency for success

### Design Lessons
- Players can create custom difficulty profiles
- Mix-and-match allows personal challenge expression
- Leaderboards not required - intrinsic motivation works

## Ascension/Escalating Difficulty Systems

### Slay the Spire Ascension
- 20 levels, each adding cumulative modifiers
- Unlocked per-character (separate progression tracks)
- Level 20: Double boss fight (ultimate challenge)
- Creates long-term goals beyond initial completion

### Dead Cells Boss Cells
- Similar escalating difficulty unlocks
- Each cell adds global difficulty modifiers
- Creates "true ending" gatekeeping pattern

### Terraria Difficulty Tiers
- Classic / Expert / Master modes
- Softcore / Mediumcore / Hardcore characters
- Mix-and-match creates difficulty matrix

## RNG and Seeded Runs

### Handling RNG in Competition
- **Seeded runs** - Same generation for all competitors
- **Unseeded runs** - Test adaptability + luck
- **Reset meta** - Controversial; rewards patience over skill

### Spelunky Approach
- MossRanking.com as community hub for both speedruns and scoreruns
- Seeded runs require unlocking all characters first (gatekeeping)
- Console timing adjustment (1.04x multiplier for fair IGT comparison)

### Binding of Isaac Racing+
- Community server tracks competitive races
- Seeded redemption for practicing specific items
- Cheater bans (unlike leaderboards that rely on honor system)

## Recommendations for GoDig

### Essential Features

1. **Seeded Runs**
   - Allow seed input for deterministic world generation
   - Display seed prominently for sharing
   - Consider separate leaderboard for seeded vs. unseeded

2. **Run Statistics Display**
   - Time (real-time and in-game time)
   - Depth reached
   - Ore collected / Upgrades purchased
   - Deaths / Damage taken

3. **Challenge Modifiers (Pact-style)**
   - Fragile (more fall damage)
   - Poverty (reduced sell prices)
   - Haste (time limit)
   - Minimalist (limited inventory)
   - No Upgrades (pickaxe stays base level)

### Daily Challenge System

```
Design Sketch:
- Daily seed with fixed starting conditions
- 10-minute time limit (mobile-friendly session)
- Scoring: Depth reached + Ore value + Bonuses
- Leaderboards: Global, Friends, First-run-only
- Refresh: Midnight UTC
```

### Achievement Support for Challenges

| Achievement | Description |
|-------------|-------------|
| **Speedrunner** | Complete a full run in under 15 minutes |
| **Minimalist** | Reach depth 500 without upgrades |
| **Perfect Miner** | Complete run without taking damage |
| **Lucky Break** | Find rare ore on first dig |
| **Streak Master** | Win 5 consecutive runs |
| **Daily Devotee** | Complete 30 daily challenges |
| **Depth Lord** | Reach maximum depth |

### Anti-Cheat Considerations

For leaderboard integrity:
- Server-validated run timestamps
- Replay submission for top scores
- Assist Mode flag disables leaderboard submission
- Separate leaderboards for modded runs

### Community Features

1. **Seed Sharing** - Easy copy/paste of run seeds
2. **Ghost Data** - Optional race against previous personal best
3. **Weekly Challenge** - Curated challenge with fixed modifiers
4. **Challenge Builder** - Player-created challenges with shareable codes

## Implementation Priority

### MVP (v1.0)
- [ ] Seed display and input
- [ ] Run statistics tracking
- [ ] Time-based achievement

### Post-Launch (v1.1)
- [ ] Daily challenge with leaderboards
- [ ] Challenge modifiers (3-5 options)
- [ ] Additional challenge achievements

### Future (v1.2+)
- [ ] Weekly curated challenges
- [ ] Challenge builder/sharing
- [ ] Ghost race feature
- [ ] Community leaderboards

## Sources

- [SteamWorld Dig - Speedrun.com](https://www.speedrun.com/steamworld_dig)
- [Spelunky Wiki - Special Runs](https://spelunky.fandom.com/wiki/Special_Runs)
- [MossRanking - Spelunky Community](https://mossranking.com/)
- [Dome Keeper - Speedrun.com](https://www.speedrun.com/dome_keeper)
- [Terraria Speedrun Guides](https://www.speedrun.com/terraria/guides)
- [Hades - Pact of Punishment Wiki](https://hades.fandom.com/wiki/Pact_of_Punishment)
- [Dead Cells - Daily Challenge Wiki](https://deadcells.wiki.gg/wiki/Daily_Challenge)
- [Slay the Spire - Daily Challenge Wiki](https://slay-the-spire.fandom.com/wiki/Daily_Challenge)
- [Binding of Isaac - Challenges Wiki](https://bindingofisaacrebirth.fandom.com/wiki/Challenges)
- [Racing+ - Isaac Racing Community](https://isaacracing.net/)
- [Grid Sage Games - Designing for Mastery in Roguelikes](https://www.gridsagegames.com/blog/2025/08/designing-for-mastery-in-roguelikes-w-roguelike-radio/)

## Key Takeaways

1. **Challenge culture emerges organically** - Players will create restrictions; design for visibility
2. **Seeded runs enable fair competition** - Essential for leaderboards and community challenges
3. **Modifier systems > binary difficulty** - Pact of Punishment style lets players tune their challenge
4. **Daily challenges drive retention** - Low-commitment competitive mode keeps players returning
5. **Statistics fuel sharing** - Detailed run data enables community comparison and content creation
6. **Accessibility and competition coexist** - Separate leaderboards or flags, not removal of features
