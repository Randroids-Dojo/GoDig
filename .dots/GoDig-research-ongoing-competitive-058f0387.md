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

### Topics for Future Research
- [x] Analyze Spelunky 2's "secrets and lessons" retention (Session 9)
- [ ] Study Terraria's biome discovery system
- [ ] Review idle game monetization patterns
- [ ] Research haptic feedback patterns on iOS/Android
- [ ] Study one-hand mobile controls in similar games
- [ ] Analyze Hades 2 early access feedback on progression pacing
- [ ] Study Balatro's variable reward system (card game mining parallel)
- [ ] Research "cozy mining" games for casual appeal patterns

### Implementation Specs Created from Research
- `GoDig-implement-progressive-tutorial-3a7f7301` - One mechanic at a time
- `GoDig-implement-guaranteed-first-99e15302` - First ore within 30 seconds
- `GoDig-implement-ladder-placement-2b7d760f` - Decision feedback

## How to Use This Task

This is a **standing research task** - never closes. Each research session should:
1. Check for new games/updates in the space
2. Read recent player feedback on competitors
3. Search game design forums for relevant discussions
4. Document findings in `Docs/research/fun-factor-analysis.md`
5. Create `implement:` dots for actionable improvements

## Note

This research task supports the user directive to "research similar games and online forums around game design endlessly to keep making our design better and better."
