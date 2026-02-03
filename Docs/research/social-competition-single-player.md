# Leaderboards and Social Competition in Single-Player Mobile Games

## Executive Summary

This research examines how solo mobile games implement healthy competition without toxicity. The key insight is that **indirect, asynchronous competition** creates engagement without the negative psychological effects of direct confrontation. Successful implementations use friend-based comparisons, personal best tracking, weekly resets, and skill-based brackets to ensure all players feel competitive while preventing discouragement.

## Case Studies

### Alto's Odyssey - Minimal Competition, Maximum Zen

**Implementation:**
- Global leaderboards for high scores
- Challenge system that unlocks characters (personal progression, not competition)
- Workshop upgrades tied to coin collection, not ranking
- Game Center integration for achievements

**Design Philosophy:**
The team deliberately stripped components from the first game and challenged themselves to identify what was truly integral to the experience. The result is a game where leaderboards exist but are completely optional.

**Key Takeaway:** Competition should never compromise the core emotional experience. Alto's creates a zen-like flow state that would be disrupted by aggressive leaderboard notifications.

### Crossy Road - In-Flow Friend Markers

**Implementation:**
- Friend scores appear as markers directly on the game board during play
- Score markers visible "in the flow" of gameplay without interrupting
- No synchronous or asynchronous ghost competitors
- Game Center leaderboard accessible but not prominent

**Design Lessons:**
- **Low Friction:** Minimal delay between wanting to play and playing
- **Simplicity:** One-touch controls, no language-based cues needed
- **Inclusivity:** Same experience for all players regardless of skill

**Key Takeaway:** The in-game score markers serve as "subtle calls to action" that drive engagement through friendly rivalry without competitive pressure. Players see where friends scored and naturally want to pass them.

### Clash Royale - Trophy-Based Skill Segregation

**Implementation:**
- Four leaderboard types: Global/Local players, Global/Local clans, Friends
- Trophy system that scales matchmaking to similar skill levels
- Personal Best (PB) tracking separate from current trophies
- League divisions at specific trophy thresholds (5300, 5600, 6000, etc.)

**Bracket Design:**
Players are matched within ~200 trophies of their current score. Winning against higher-trophy opponents yields more trophies, creating risk/reward dynamics.

**Friend Competition:**
Friends leaderboard in social tab shows:
- Trophy counts
- Profile access
- Real-time spectating
- Friendly battle challenges

**Key Takeaway:** The personal best metric allows players to compare lifetime achievement while current trophies reflect current skill, separating "how good have I ever been" from "how good am I now."

### Archero 2 - Weekly Bracket Reset System

**Implementation:**
- Arena mode with 6 ranks (Bronze through Diamond)
- Weekly season from Monday UTC 0:00 to Sunday UTC 23:50
- Players grouped based on previous week's rank
- Different group sizes per tier (Bronze: 50, Gold: 100, Diamond: 200)

**Seeding Mechanics:**
- New players start at Bronze
- Promotion/demotion thresholds prevent stuck players
- Matchmaking pulls 5 opponents within ±200 points
- Free refresh to find preferred opponents

**Fair Competition Elements:**
- Winning against higher-point opponents yields more points
- Losing to higher opponents deducts fewer points
- Small group sizes (50-200) ensure achievable ranking goals

**Key Takeaway:** The weekly reset with bracket-based grouping ensures new players compete against similar-skill opponents, not veterans.

### Subway Surfers - Weekly Social Competition

**Implementation:**
- Weekly leaderboard reset (fresh start every week)
- Facebook friend integration for social ranking
- Global leaderboard accessible via trophy icon
- High score as primary metric

**Engagement Design:**
- Weekly reset creates recurring "comeback" opportunities
- Friend rankings drive social comparison without toxicity
- Simple high score metric is universally understood

**Key Takeaway:** Weekly resets are crucial for casual games - they give lower-skilled players hope and prevent discouragement from falling permanently behind.

## Anti-Toxicity Design Patterns

### 1. Indirect Competition Over Direct Confrontation

The best single-player competition uses "ghost" data rather than live opponents:

| Pattern | Example | Benefit |
|---------|---------|---------|
| Ghost teams | Super Auto Pets arena mode | No scheduling, no pressure |
| Score markers | Crossy Road friend markers | Subtle motivation, not aggressive |
| Async turns | Board game adaptations | Play at your own pace |

### 2. Limited Communication Systems

Journey's single "chirp" communication demonstrates how constraining expression prevents toxicity. For leaderboards:
- No chat on leaderboard screens
- No taunting mechanics
- Celebration is personal, not broadcast

### 3. Positive-Sum Over Zero-Sum

When one player's success doesn't diminish another's:
- Personal best tracking (everyone can improve)
- Parallel progression paths (sidegrades, not just upgrades)
- Non-competitive rewards (cosmetics, not power)

### 4. Small Leaderboard Groups

Research shows seeing rank 5/10 feels achievable, but 1005/1010 feels hopeless:
- Keep visible leaderboards to ~10-50 players
- Show nearby ranks, not full global list
- Highlight "players near you" over "top 10"

### 5. Fresh Start Opportunities

Weekly/seasonal resets prevent permanent discouragement:
- Alto's daily challenges
- Clash Royale trophy resets
- Archero weekly arena seasons

## Psychological Principles

### Competence Satisfaction vs Frustration

Research on leaderboard psychology shows:
> "Participants who received low-rank results decreased their effort after continued endeavors."

This means:
- Persistent low rankings kill motivation
- Improvement must feel possible
- Bracket seeding matters more than absolute ranking

### The "Me vs World" Problem

Solo competition can create isolation and resentment. Mitigations:
- Friend-based leaderboards (competing with known people)
- Team/clan scoring (shared achievement)
- Personal improvement tracking (competing with past self)

### Motivation Through Achievement, Not Rank

Redesign leaderboards to highlight:
- Individual progress over absolute position
- Personal achievements regardless of rank
- Improvement percentage over score

## Implementation Recommendations for GoDig

### Phase 1: Personal Best Foundation
- Track depth records, ore collected, coins earned
- Display "New Record!" celebrations
- Compare current run to personal bests

### Phase 2: Friend Leaderboards
- Game Center / Google Play Games integration
- Friend depth records visible on surface
- "Beat [Friend]'s record!" hints when close
- No chat, no taunting, pure numbers

### Phase 3: Weekly Challenges (Optional)
- Special weekly modifiers (faster mining, more rare ores)
- Small bracket groups (20-30 players)
- Cosmetic rewards only
- Reset every Monday

### Anti-Patterns to Avoid

| Don't | Why |
|-------|-----|
| Global leaderboard prominence | Discourages 99% of players |
| Pay-to-win advantages | Destroys competitive integrity |
| Real-time opponent matching | Adds pressure, doesn't fit zen mining |
| Rank decay punishment | Adds anxiety, punishes breaks |
| Ranking notifications on loss | Rubs in failure |

## Technical Implementation Notes

### Game Center Integration
```gdscript
# Report depth record
GameCenter.report_score(depth_record, "leaderboard_depth")

# Load friend scores
GameCenter.load_friends_leaderboard("leaderboard_depth", func(scores):
    for score in scores:
        display_friend_marker(score.player_name, score.value))
```

### In-Flow Score Markers (Crossy Road Pattern)
Display friend depth records as subtle UI elements:
- Show friend name + depth when player passes their record
- Brief celebration, then fade
- Optional toggle in settings

### Weekly Reset Logic
```gdscript
func should_reset_weekly_challenge() -> bool:
    var last_reset = SaveManager.get("weekly_last_reset", 0)
    var current_week = Time.get_unix_time_from_system() / (7 * 24 * 60 * 60)
    var last_week = last_reset / (7 * 24 * 60 * 60)
    return current_week > last_week
```

## Sources

- [Alto's Odyssey - Wikipedia](https://en.wikipedia.org/wiki/Alto's_Odyssey)
- [What Design Lessons Can We Learn from Crossy Road?](https://www.gamedeveloper.com/design/what-design-lessons-can-we-learn-from-crossy-road-)
- [Clash Royale Trophies - Fandom](https://clashroyale.fandom.com/wiki/Trophies)
- [Archero 2 Arena - Game Vault](https://archero-2.game-vault.net/wiki/Arena)
- [How to Design Leaderboards for Your Mobile Game?](https://www.blog.udonis.co/mobile-marketing/mobile-games/leaderboards)
- [Psychology of High Scores, Leaderboards & Competition](https://www.psychologyofgames.com/2014/11/psychology-of-high-scores-leaderboards-competition/)
- [Asynchronous Multiplayer: Reclaiming Time in Mobile Gaming](https://www.wayline.io/blog/asynchronous-multiplayer-reclaiming-time-mobile-gaming)
- [Kind Games: Designing for Prosocial Multiplayer](https://polarisgamedesign.com/2022/kind-games-designing-for-prosocial-multiplayer/)
- [How does the Subway Surfers leaderboard work?](https://www.playbite.com/how-does-the-subway-surfers-leaderboard-work/)
- [Climbing the Ranks: A Guide to Leaderboards in Mobile Gaming](https://medium.com/@alidrsn/climbing-the-ranks-a-guide-to-leaderboards-in-mobile-gaming-67f4f808e147)

## Research Session

- **Date:** 2026-02-02
- **Focus:** Healthy competition without toxicity in single-player mobile games
- **Key Insight:** Indirect async competition with friend markers and weekly resets creates engagement without discouragement
