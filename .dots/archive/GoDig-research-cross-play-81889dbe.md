---
title: "research: Cross-play and social features in single-player mobile games"
status: closed
priority: 2
issue-type: research
created-at: "\"2026-02-02T22:25:28.101950-06:00\""
closed-at: "2026-02-02T22:35:54.795273-06:00"
close-reason: Completed research on async social features from Spelunky daily challenges, Dark Souls messages, ghost data systems. Documented daily dig challenges, depth messages, and community goal systems.
---

## Research Question

How can single-player mobile games create communal experiences through async multiplayer, ghost data, and daily/weekly challenges without requiring real-time interaction?

## Key Findings

### 1. Ghost Data Systems

**Racing Game Model (Real Racing 3):**
- "Uses recordings of other player's races"
- "You can bump into their car and send them off course"
- "Ghost will magically re-adjust to where the original player was"
- Async competition without real-time connection

**Speedrun Ghost Data:**
- "Challenging races against ghost data from other players"
- "You can actually see other people's ghosts"
- "Adds an extra layer of pressure"

**Auto-Battler Application (Super Auto Pets):**
- "Battle snapshots of real opponents"
- "No scheduling required"
- "Timer-free Arena Mode"

### 2. Daily Challenge Systems

**Spelunky's Model - The Gold Standard:**
- "Every day, a new seed is generated"
- "Every single player doing the daily challenge is playing the same seed"
- "You can only make one attempt"
- "All procedurally generated elements that can be the same between players, are"

**Why It Works:**
- "Fun part is watching multiple people upload their daily runs"
- "Watching how they handle bouts of bad luck"
- "Play the levels differently"
- Creates shared experience without synchronous play

**Roguelite Community Building:**
- Mirrored runs: "Two players start with the same seed, play side by side"
- "Though it's partially a race, the real fun comes with seeing the branching changes"
- Players share "glitches, extraordinarily bad luck, overpowered combinations"

### 3. Leaderboards and Rankings

**Key Implementation Points:**
- "Rank players based on performance compared to others"
- Show global, regional, and friends-list rankings
- "Particularly effective among competitive players"
- "Motivating them to climb the ladder and get recognition"

**Activity Feeds:**
- "Enable viewers to see activity of gamers within their network"
- "When friend has new high score"
- "When connected gamers are active in-game"
- Personalized leaderboards based on social network

### 4. Community Without Real-Time

**Dark Souls Message System:**
- "Multiplayer essence present throughout asynchronously"
- "Messages on the floor by other players"
- "Tips, warnings, or sometimes jokes"
- "Related to that specific place where message was written"

**Key Benefit:**
- "30% increase in player retention for asynchronous games compared to synchronous ones"
- "Adapts to player lives"
- "Builds communities around shared narratives and enduring rivalries"

### 5. Event-Driven Engagement

**Time-Limited Events:**
- "Players encouraged to participate in challenges or tournaments"
- "Exclusive rewards create sense of urgency"
- "Drives players to log in and participate"

**Group Goals:**
- "Group missions to defeat a boss or reach a certain goal"
- "Team-based competitions before event ends"
- "Building anticipation, encouraging players to log in regularly"

### 6. Guild/Clan Systems

**Benefits:**
- "Team up to complete challenges and events"
- "Build communities based on interests, playing styles, and levels of engagement"
- "Sense of belonging"
- "Feel part of something larger than themselves"

**Industry Data:**
- "⅔ of top mobile games have at least one social feature"
- Social features "significantly enhance user engagement and retention"

## Application to GoDig

### Daily Dig Challenge

**Concept:**
- Same procedurally generated mine for all players each day
- One attempt only
- Global leaderboard for that day's seed

**Scoring:**
- Depth reached
- Resources collected
- Time taken
- Deaths/close calls

**Implementation:**
```
Daily seed = hash(date + "GoDig")
All players get same ore placement, cave layout, hazard positions
Leaderboard shows: Name, Depth, Coins, Time
```

### Ghost Miner System

**Concept:**
- Record best runs as "ghost data"
- See ghosts of friends/top players in your mine
- Translucent miner showing their path

**Features:**
- Optional toggle on/off
- Filter: friends only, top 10, similar skill
- Shows where they mined, what they collected
- Learn from better players

### Weekly Challenge Events

**Types:**
| Week | Challenge | Goal |
|------|-----------|------|
| 1 | Speed Run | Reach 500m fastest |
| 2 | Hoarder | Collect most coins in 10 min |
| 3 | Explorer | Find the most caves |
| 4 | Survivor | Longest run without dying |

**Rewards:**
- Participation: Small coin bonus
- Top 50%: Cosmetic item
- Top 10%: Unique pickaxe skin
- #1: Title/Badge displayed in profile

### Depth Messages (Dark Souls-style)

**Player Messages:**
- Leave notes at specific depths/locations
- "Rare ore nearby!" or "Danger ahead"
- Rate messages as helpful/not helpful
- Highly-rated messages appear for others

**Implementation:**
- 3 messages per player per run
- Predefined phrases (prevents toxicity)
- Auto-expire after 7 days
- Popular messages persist longer

### Community Goals

**Server-Wide Events:**
- "All players combined: Mine 1 million blocks this week"
- Progress bar visible to everyone
- Everyone gets reward if goal met
- Creates sense of collective achievement

**Depth Records:**
- "First player to reach 5000m this month"
- Hall of Fame visible to all
- Encourages deep exploration

### Asynchronous Multiplayer Mining

**Concept: Mine Contracts**
- Player A finds valuable vein but can't carry more
- Marks location as "Contract"
- Player B can claim contract, gets to that location
- Reward split between A (finder) and B (miner)

**Benefits:**
- Encourages cooperation without real-time play
- Rewards exploration and sharing
- Creates interconnected community

### Leaderboard Categories

| Category | Metric | Reset |
|----------|--------|-------|
| Deepest | Max depth reached | All-time |
| Richest | Total coins earned | Weekly |
| Explorer | Caves discovered | Monthly |
| Collector | Unique ores found | All-time |
| Speedrunner | Time to 500m | Daily |

### Activity Feed

**Friend Updates:**
- "Alex reached a new depth record: 847m!"
- "Jordan found a Diamond cluster!"
- "Sam completed the weekly challenge!"

**World Events:**
- "Community goal 78% complete"
- "New daily challenge available"
- "Rare ore event: Void crystals x2 today"

## Implementation Recommendations

### Phase 1 (v1.0): Basic Social
- Simple leaderboard (depth, coins)
- Activity feed showing friend progress
- Achievement sharing

### Phase 2 (v1.1): Daily Challenges
- Daily seeded mines
- Daily leaderboard
- Participation rewards

### Phase 3 (v1.2+): Full Social
- Ghost data system
- Player messages
- Weekly events
- Community goals
- Mine contracts

## Design Principles

1. **Never Block Play** - Social features enhance, never required
2. **Async Always** - No waiting for other players
3. **Fair Competition** - Same seed means fair comparison
4. **Community Over Competition** - Emphasize shared achievement
5. **Respect Privacy** - Optional social features
6. **No FOMO** - Rewards for participation, not just winning

## Sources

- [Asynchronous Multiplayer: Reclaiming Time - Wayline](https://www.wayline.io/blog/asynchronous-multiplayer-reclaiming-time-mobile-gaming)
- [Best Asynchronous Multiplayer Games - GameRant](https://gamerant.com/best-asynchronous-multiplayer-games/)
- [Social Features in Mobile Games 2025 - MAF](https://maf.ad/en/blog/social-features-in-mobile-games/)
- [Role of Social Features in Mobile Game Success - SDLC Corp](https://sdlccorp.com/post/the-role-of-social-features-in-mobile-game-success/)
- [Roguelikes, Let's Plays, and Community Building - Sprites and Dice](https://spritesanddice.com/posts/roguelikes-lets-plays-and-how-single-player-games-can-build-communities/)
- [Spelunky Wiki - Daily Challenge](https://spelunky.fandom.com/wiki/Roguelike)

## Status

Research complete. Provides foundation for social features, daily challenges, and asynchronous multiplayer systems.
