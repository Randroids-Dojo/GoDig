# Player-Shared Challenges and User-Generated Content in Roguelites

## Overview

This research investigates how roguelites enable players to share challenges, seeds, and custom runs with each other, finding patterns for community engagement without requiring full modding support. The goal is to identify social features that create community engagement for GoDig.

## Shareable Seeds

### Core Concept

Seeds provide deterministic generation, enabling fair competition and shared experiences:
- Same seed = same world/encounters
- Players can challenge each other on identical layouts
- Seeds enable replay/practice of specific scenarios
- Seeds create shareable "puzzles"

### Implementation Patterns

**Slay the Spire:**
- Daily runs use predetermined seeds
- Same character, same modifiers for all players
- 24-hour availability window
- Score-based leaderboards

**Spelunky:**
- Daily challenge seeds rotated regularly
- Seeded mode available for custom practice
- MossRanking.com community leaderboards
- Console timing adjustments for fairness

**Balatro:**
- Seed pre-determines boss blinds and shop options
- Seeds shareable via alphanumeric codes
- Community site (BalatroSeed.net) curates high-score seeds
- Seed entry disabled for challenge decks (to prevent trivializing unlocks)

**Nuclear Throne:**
- Daily and weekly challenge modes
- Thronebutt.com community leaderboards
- Score based on kills only
- Archives preserve historical challenges

### Seed Sharing Considerations

| Feature | Benefit | Risk |
|---------|---------|------|
| Always visible seed | Easy sharing | May encourage cheating |
| Copy-to-clipboard | Frictionless sharing | N/A |
| Disable unlocks on seeded | Protects achievement integrity | May frustrate players |
| Separate leaderboards | Fair competition | Splits community |

## Daily/Weekly Challenge Systems

### Nuclear Throne Model

**Daily:**
- New seed each day
- Same levels for all players
- Score = kill count
- Leaderboard resets daily

**Weekly:**
- Same seed all week
- Allows practice/improvement
- Best run counts for leaderboard
- Archives preserve historical data

**Thronebutt Integration:**
- Fan-created site (2015)
- Later officially integrated by Vlambeer
- Volunteer-operated with developer support
- All data tracked since 2016 relaunch

### Dead Cells Model

**Unique Approach:**
- Daily run feels different from main game
- Competitive speedrunning focus
- 4:30 time limit creates urgency
- Scoring emphasizes efficiency

**Key Features:**
- Refreshes at midnight UTC+1
- "First run only" separate leaderboard
- Assist Mode disables leaderboard submission
- Custom Mode for practice/accessibility

### Slay the Spire Daily Climb

**Structure:**
- Seeded run with random character
- Three random modifiers applied
- Always Ascension 0 (accessible)
- Act 4 disabled (shorter runs)

**Scoring:**
- Light Speed bonus (finish <45min = +50 points)
- "Perfect" bonus for no-damage boss kills
- Score optimization becomes its own meta
- 24-hour rotation

### TumbleSeed

**Simple Implementation:**
- 5 procedurally generated worlds
- 30+ unique seed powers
- Daily challenge with global leaderboard
- "Top your personal best" framing

## Leaderboards with Modifiers

### Hades Heat System

Modifiers affect leaderboard categories:
- 15+ conditions with multiple ranks
- Heat gauge tracks total difficulty
- Higher heat = more impressive runs
- Community stratifies by heat level

### Risk of Rain 2 Artifacts

**Artifact System:**
- Toggleable modifiers change gameplay
- Can be mixed and matched
- Create custom difficulty profiles
- Enable specific challenge experiences

### Cogmind Leaderboards

**Implementation:**
- Reset with each new version
- Online scoresheet links shareable
- Detailed run data preserved
- Discord integration for sharing

### Geometry Arena

**Customization Depth:**
- Wide range of classes
- Skills, runes, modifiers stack
- Player control over difficulty
- Endless modes for high-score chasing

## Social Features Without Full UGC

### Discord Integration

**Cogmind Webhook Approach:**
- Game sends updates to Discord channels
- Automatic run summaries posted
- Scoresheet links shared
- Community-visible progress

**Features:**
- Manual webhook configuration
- Spoiler-aware content filtering
- Player-specified destination channels
- Run completion announcements

**Considerations:**
- Spoiler management for discovery-based games
- Opt-in rather than default
- Player control over sharing

### Steam Community Integration

**Features:**
- Screenshots with built-in sharing
- Achievement tracking visible to friends
- Activity feeds show progress
- Trading cards/badges for engagement

### In-Game Social Features

**Without Modding:**
- Seed display and copy button
- Run statistics exportable
- Screenshot mode with relevant data visible
- Share buttons to clipboard/social

## Screenshot and Replay Sharing

### Making Screenshots Valuable

**Include Key Data:**
- Current seed visible in UI
- Relevant statistics (depth, time, score)
- Challenge modifiers if active
- Clear visual of accomplishment

**Balatro Example:**
- Seeds visible but require manual screenshot
- Community requested "Always Show Seed" mod
- In-game camera doesn't include seed (limitation)

### Replay Systems

**Lightweight Approaches:**
- Seed + inputs = deterministic replay
- Much smaller than video
- Can be shared as text/files
- Enables verification for leaderboards

**Considerations:**
- Version compatibility
- File size vs. video
- Verification vs. enjoyment

## Community-Driven Features

### BalatroSeed.net

**Community Platform:**
- Player-submitted seeds
- Curated high-score runs
- Joker combination filters
- Blind route studies
- Guides and strategy discussion

### Thronebutt.com

**Evolution:**
1. Fan-created leaderboard site
2. Developer noticed and offered support
3. Official integration with game
4. Volunteer-operated long-term
5. Archives preserve history

**Lesson:** Support community tools; don't compete with them.

### Racing+ (Binding of Isaac)

**Community Racing:**
- Server tracks competitive races
- Seeded runs for practice
- Cheater bans (unlike honor-system leaderboards)
- Organized events

## Recommendations for GoDig

### Essential Features (MVP)

**1. Visible Seed System:**
```
World Seed: MINE-7294
[Copy Seed] [New World]

"Challenge your friends with your world!"
```

**2. Run Statistics:**
- Max depth reached
- Total ore collected
- Time played
- Upgrades purchased
- Best single-run earnings

**3. Screenshot Mode:**
```
[Screenshot Mode]
- Hides UI elements
- Shows seed + stats overlay
- Saves to accessible location
- Includes "Share" prompt
```

### Daily Challenge System

**Design:**
```
DAILY CHALLENGE
Seed: DAILY-2026-0202

Goals:
- Reach depth 300m
- Collect 500g worth of ore
- Return to surface alive

Time Remaining: 14h 23m
Your Best: 247m | 380g | FAILED

[Start Daily] [View Leaderboard]
```

**Rules:**
- Same seed for all players
- First attempt counts for leaderboard
- Practice mode available (no leaderboard)
- Refreshes at midnight UTC

**Scoring:**
```
Base Score = Depth Reached × 10
+ Ore Value Collected
+ Survival Bonus (×1.5 if alive)
+ Speed Bonus (under 10min = +100)
```

### Weekly Challenge

**Format:**
```
WEEKLY CHALLENGE
Modifier: Fragile Pickaxe (breaks 2× faster)
Seed: WEEKLY-2026-W05

Best attempt counts (unlimited tries)
Ends in: 5d 14h

Your Best: #127 (2,450 pts)
Leader: #1 (8,230 pts)
```

**Why Weekly:**
- Allows practice and improvement
- Less pressure than one-shot daily
- Modifiers create variety
- Encourages return visits

### Challenge Modifiers

**Toggleable Difficulty Options:**
```
CUSTOM CHALLENGE

Modifiers:
[ ] Fragile - Tools degrade 2× faster
[ ] Poverty - Ore sells for 50%
[ ] Haste - 10 minute time limit
[ ] Minimalist - 4 inventory slots
[x] Darkness - Reduced visibility
[ ] No Upgrades - Base pickaxe only

Modifier Multiplier: 1.5×
[Generate Seed] [Copy Challenge Code]
```

**Challenge Codes:**
- Encode modifiers + seed
- Shareable text string
- Anyone can paste and play
- Leaderboard per code (optional)

### Community Integration

**Discord Webhook (Optional):**
```
Settings > Social > Discord

Webhook URL: [paste webhook]

Share:
[x] Run completions
[x] New depth records
[ ] Deaths
[ ] Daily challenge results

[Test Webhook] [Save]
```

**Steam Integration:**
- Achievements track challenge completions
- Activity feed shows records
- Screenshots include seed data
- Rich Presence shows current run

### Implementation Priority

**MVP (v1.0):**
- [ ] Visible seed on pause menu
- [ ] Seed copy button
- [ ] Custom seed input
- [ ] Basic run statistics display
- [ ] Screenshot mode with stats

**Post-Launch (v1.1):**
- [ ] Daily challenge with leaderboard
- [ ] Weekly challenge with modifier
- [ ] Challenge code system
- [ ] Basic Steam achievements

**Future (v1.2+):**
- [ ] Discord webhook integration
- [ ] Challenge modifier builder
- [ ] Community seed database
- [ ] Replay system

## Key Takeaways

1. **Seeds enable community** - Shareable seeds transform solo games into social experiences
2. **Daily challenges drive retention** - Regular reasons to return build habits
3. **Modifiers create variety** - Without requiring content updates
4. **Support community tools** - Thronebutt shows developer collaboration works
5. **First-attempt leaderboards encourage honesty** - Separate practice from competition
6. **Make sharing frictionless** - One-click copy, visible data, easy screenshots
7. **Modular social features** - Opt-in rather than required

## Sources

- [Nuclear Throne Daily Leaderboard (Thronebutt)](https://thronebutt.com/daily)
- [Nuclear Throne Challenge Runs Wiki](https://nuclear-throne.fandom.com/wiki/Challenge_Runs)
- [BalatroSeed Community Platform](https://balatroseed.net/)
- [Balatro Seeded Runs Discussion](https://steamcommunity.com/app/2379780/discussions/0/4294818244837440847/)
- [Cogmind Discord Integration Using Webhooks](https://www.gridsagegames.com/blog/2023/06/roguelike-discord-integration-using-webhooks/)
- [Designing for Mastery in Roguelikes](https://www.gridsagegames.com/blog/2025/08/designing-for-mastery-in-roguelikes-w-roguelike-radio/)
- [Building Indie Game Community with Discord](https://discord.com/blog/how-to-build-an-active-and-engaged-indie-game-community-with-discord)
- [Roguelike Wikipedia - Daily Challenges](https://en.wikipedia.org/wiki/Roguelike)
- [TumbleSeed Official Site](https://tumbleseed.com/)
- [Rogue Legacy Source Code Release](https://www.pcgamer.com/games/roguelike/the-developer-of-rogue-legacy-has-officially-released-its-source-code-in-the-pursuit-of-sharing-knowledge/)
