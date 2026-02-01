---
title: "research: Ongoing competitive analysis - mining/digging games"
status: active
priority: 3
issue-type: research
created-at: "\"2026-02-01T07:56:09.847420-06:00\""
---

## Purpose

Continuous monitoring of mining game releases, player feedback, and game design discussions to keep GoDig's design evolving and competitive.

## Research Areas

### Games to Monitor
- **Active Mining**: SteamWorld Dig series, Super Motherload, Terraria
- **Idle Mining**: Mr. Mine, Idle Miner Tycoon, Idle Mining Empire
- **Roguelite Mining**: Dome Keeper, Spelunky 2
- **New Releases**: itch.io indie mining games, Steam new releases

### Discussion Forums
- Reddit: r/gamedesign, r/indiegaming, r/roguelikes
- Steam discussions for competitor games
- BoardGameGeek for push-your-luck mechanics

### Design Principles to Track
- Core loop satisfaction
- Push-your-luck mechanics
- Mobile-specific UX patterns
- Monetization that doesn't frustrate

## Research Log

### Session 8 (2026-02-01)
**Mr. Mine Analysis**:
- Depth-based surprises key to engagement
- Fast satisfaction curve (minutes, not hours)
- Hybrid active/passive appeals to multiple playstyles
- Milestones tied to content unlocks, not just numbers

**Dome Keeper 2024-2025**:
- Hit 1M players - validates mining + defense loop
- Complaints: "too slow, repetitive, grindy"
- Mitigation: Quick-buy, elevator, procedural variety

### Session 9 (2026-02-01)
**Spelunky Risk Design Analysis**:
- Core insight: "game of information and decision-making, not execution"
- Every micro-decision has risk/reward calculation
- Risk management separates great games from good games
- Our ladder system creates similar meaningful decisions

**Push-Your-Luck Board Game Mechanics**:
- Self-balancing: deeper = better rewards but higher risk
- Gradual tension buildup (like Deep Sea Adventure) beats sudden bust
- Mathematical balance: ~80% success per moment for 50% overall bust
- Our gradual ladder depletion creates superior tension curve

**Mobile Onboarding 2025 Best Practices**:
- Progressive onboarding: one mechanic at a time
- "One-minute rule": win player's heart in first 60 seconds
- Tutorial levels should BE fun gameplay (Candy Crush)
- Never monetize before first upgrade

**"One More Run" Psychology**:
- Defeat + determination = addictive loop
- Every run teaches something new
- Meta-progression critical (Rogue Legacy pattern)
- Quick restart is essential

**Dome Keeper 2025-2026 Updates**:
- Multiplayer mode in development
- Artillery and Tesla domes add strategic variety
- Community feedback: gadget randomness being addressed
- Lesson: plan for post-launch economy tuning

**itch.io Mining Game Landscape**:
- Terminal Descent: idle mining robots - validates core loop
- Astropop: asteroid mining roguelike - space setting
- Veinrider: incremental journey into depths
- Competition growing but few do mobile well

### Session 10 (2026-02-01)

**Balatro Variable Reward System (GDCA 2025 Game of the Year)**:
- Exponential growth via multipliers creates "making numbers go up" satisfaction
- Variable ratio reinforcement: uncertainty keeps players engaged
- Randomness + player agency: "You cannot pay to win here. You have to learn how to use the chaos."
- Meta-progression: even failures yield permanent rewards
- **GoDig Application**: Each block mined is a micro-uncertainty moment. Ore discovery parallels card draw excitement.

**Terraria Biome Discovery Lessons**:
- 64M+ copies sold - biome priority system creates exploration tension
- Evil biomes (Corruption/Crimson) spread and infect - creates dynamic world
- Board game adaptation uses tile-based world generation for replayability
- **GoDig Application**: Our 7 layers serve as "biomes" - each should have distinct visual/mechanical identity

**Cozy Mining Games & Casual Market (2025)**:
- Casual games: $24.2B in 2025, 31% of global downloads
- 45+ demographic fastest growing, drawn to cozy simulations
- 70% likelihood upcoming mining games will blend with management elements
- Forager: "fast-paced loop makes mining feel satisfying"
- **GoDig Application**: Our active mining is differentiated from idle games - but we can learn from cozy pacing

**Haptic Feedback Best Practices (iOS/Android)**:
- iOS significantly outperforms Android for haptic quality/control
- Marvel Snap example: "feel the weight of each move" creates memorable interactions
- Haptics must sync precisely with visuals - even small delays feel unnatural
- Reserve custom haptic patterns for high-value scenarios (ore discovery, upgrades)
- **GoDig Implementation**: Add haptic feedback for ore discovery (short burst), upgrade celebration (longer rumble), ladder placement (subtle tap)

**One-Hand Mobile Controls Research**:
- 49-75% of smartphone users operate one-handed
- "Subway Thumb" is most casual grip - game must support this
- 59% of users disengage if controls are physically uncomfortable
- Green zone (easy reach) vs yellow (manageable) vs red (hard) - design for thumb arc
- **GoDig Application**: Dig controls are already tap-based. HUD elements must be in thumb-reachable zones.

**Hades 2 Progression Pacing (Metacritic 94/100)**:
- Early Access used to tune balance based on player feedback
- Boons rebalanced: "Rare and Epic feel even more special now"
- New foes spawn in completed areas to maintain challenge
- Ending reworked based on player feedback post-launch
- **GoDig Lesson**: Plan for post-launch economy tuning. Start with generous progression, tighten later.

**Idle Game Monetization 2025**:
- Rewarded videos = 60-70% of idle game revenue
- Best practice: don't front-load monetization - wait until Day 3
- "Ads that bail players out, not slow them down" = 42% engagement (vs 25-30% average)
- Hybrid models work: ads + IAPs + battle passes
- **GoDig Application**: First upgrade free, monetization gates only after player is invested

**Dome Keeper 2025 Community Feedback**:
- Assessor character complaints: "too much downtime waiting"
- Players want rhythm variation: "If pressure is always max, it's just exhausting"
- Developer response: community feedback integral to development success
- Versus mode in development: competing teams on shared mine
- **GoDig Learning**: Vary tension rhythm - surface visits should provide genuine relief

**itch.io Mining Games 2025**:
- Terminal Descent: "Mine, drill, blast to deepest depths" - validates incremental core loop
- Space Miner: asteroid mining clicker - casual/strategy hybrid
- PlanetCore: drill + survive + upgrade missions
- Mine is Life: 2025 game jam entry - fresh competition emerging
- **Competitive Position**: GoDig's ladder-based risk system is unique differentiator

### Session 11 (2026-02-01)

**Vampire Survivors - Gambling Psychology Applied Successfully**:
- Creator Luca Galante applied gambling industry experience to game design
- Result: "distils the essence of compelling, just-one-more-go game design"
- PENS Model: Games fulfill competence (power/mastery) and autonomy (freedom)
- Minimal input (directional only) but maximum feedback (constant visual rewards)
- **GoDig Application**: Our tap-to-dig is simple; feedback (particles, sounds, toasts) must be rich

**Mining Game Grindiness - The Player Feedback Spectrum**:
- Keep on Mining (2025): "dopamine-inducing early, repetitive mid-game" - pacing issue
- Deep Rock Galactic Survivor: "best loop mechanically" but exponential scaling ruins late game
- Super Mining Mechs: "If digging isn't satisfying by itself, the game isn't for you"
- Hytale: Developer publicly stated mining "isn't fun enough" - they're fixing it
- Key insight: Mining must be inherently satisfying BEFORE any systems/upgrades

**What Makes Mining Satisfying (Forum Consensus)**:
- Deep Rock Galactic: "digging away and finding caverns etc is so much fun"
- Stardew Valley: time limits + enemies + shortcuts + bombs = variety
- SteamWorld Dig 2: "frequently mentioned as standout" for upgrade feel
- **Common thread**: Discovery and exploration, not just extraction

**Cult of the Lamb - Two-Loop Retention**:
- Dungeon crawling feeds base building, base building motivates dungeons
- Forgiving death: lose "a little bit of progress" not everything
- "Brilliant entry point to roguelites" - accessibility praised
- **GoDig Application**: Our surface/underground loops feed each other similarly

**Push-Your-Luck: Deep Sea Adventure Model**:
- Players share single oxygen supply - greed affects everyone
- Taking treasure = slowing return + draining shared resource
- "Incredible moment of anticipation" when decisions revealed
- **GoDig Application**: Our ladder depletion is gradual like oxygen - BETTER than sudden bust

**Mobile Session Reality (2025 Data)**:
- Median session: 4-6 minutes (not 15-30 as often assumed)
- Players average 4-6 sessions daily, 3-5 min each
- 80% of players churn by Day 1 - retention is critical
- First session 10-20 minutes is vital for F2P success
- **GoDig Application**: Design for 5-minute complete loops, hook within 2 minutes

**SteamWorld Dig 2 Addiction Analysis**:
- "Gameplay loop of dungeon crawler - little progress each outing, always gathering rewards"
- "Price/benefits of items well-tuned" - creates "just a few more coins" feeling
- "Impeccably paced - new powers when comfortable" - timing matters
- Upgrade impact: "Tier 1 vs Tier 3 should feel like night and day"

**Motherload Tedium Problem**:
- "Repetition of going up and down gets increasingly tedious"
- "Best part is upgrading, everything in between is grind"
- Mitigation: underground stations charge more but save time
- **GoDig Application**: Need late-game infrastructure (elevator) to prevent tedium

### Topics for Future Research
- [x] Analyze Spelunky 2's "secrets and lessons" retention (Session 9)
- [x] Study Terraria's biome discovery system (Session 10)
- [x] Review idle game monetization patterns (Session 10)
- [x] Research haptic feedback patterns on iOS/Android (Session 10)
- [x] Study one-hand mobile controls in similar games (Session 10)
- [x] Analyze Hades 2 early access feedback on progression pacing (Session 10)
- [x] Study Balatro's variable reward system (Session 10)
- [x] Research "cozy mining" games for casual appeal patterns (Session 10)
- [x] Analyze Cult of the Lamb retention mechanics (Session 11)
- [x] Study Vampire Survivors for minimalist "just one more" design (Session 11)
- [ ] Study Satisfactory/Factorio automation for v1.1 features
- [ ] Research vertical slice playtesting methodologies
- [ ] Analyze Slay the Spire deckbuilding progression for upgrade variety
- [ ] Study loop hero for passive progression ideas

### Implementation Specs Created from Research
- `GoDig-implement-progressive-tutorial-3a7f7301` - One mechanic at a time
- `GoDig-implement-guaranteed-first-99e15302` - First ore within 30 seconds
- `GoDig-implement-ladder-placement-2b7d760f` - Decision feedback
- `GoDig-implement-haptic-feedback-2abf435a` - Mobile haptics for ore/upgrades (Session 10)
- `GoDig-implement-one-hand-5bfe1242` - One-hand friendly HUD layout (Session 10)
- `GoDig-implement-surface-home-81016105` - Surface cozy signals (Session 10)
- `GoDig-implement-monetization-gate-43da3d31` - Day 3 monetization gate (Session 10)
- `GoDig-implement-post-launch-37e1e607` - Remote economy tuning framework (Session 10)
- `GoDig-implement-ore-discovery-5f8102ab` - Balatro-style ore micro-celebrations (Session 10)
- `GoDig-implement-block-adjacent-ef98f7e1` - Near-miss ore shimmer hints (Session 10)
- `GoDig-implement-core-mining-debb2ca2` - Core mining feel validation test (Session 11)
- `GoDig-implement-anti-grind-ea5b1d1e` - Anti-grind economy balance pass (Session 11)
- `GoDig-implement-underground-rest-bf86dfe8` - Underground rest stations v1.1 (Session 11)

## How to Use This Task

This is a **standing research task** - never closes. Each research session should:
1. Check for new games/updates in the space
2. Read recent player feedback on competitors
3. Search game design forums for relevant discussions
4. Document findings in `Docs/research/fun-factor-analysis.md`
5. Create `implement:` dots for actionable improvements

## Note

This research task supports the user directive to "research similar games and online forums around game design endlessly to keep making our design better and better."
