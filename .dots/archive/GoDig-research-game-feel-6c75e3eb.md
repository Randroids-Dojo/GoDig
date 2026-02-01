---
title: "research: Game feel / juice best practices"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-02-01T01:39:58.089416-06:00\""
closed-at: "2026-02-01T01:40:01.236875-06:00"
close-reason: "Completed: Mapped juice techniques to GoDig actions with priority phases. P1=mining+discovery, P2=economy, P3=polish."
---

## Question
What juice effects should GoDig prioritize, and what should we avoid?

## Research Tasks
- [x] Survey juice techniques in indie games
- [x] Identify over-juicing pitfalls
- [x] Map techniques to GoDig actions

## Research Complete

### Core Juice Techniques (from web research)

| Technique | Use Case | Priority |
|-----------|----------|----------|
| Screen shake | Block break, damage taken | High |
| Particles | Ore reveal, level up, selling | High |
| Squash/stretch | Player jump, ladder placement | Medium |
| Sound variation | Mining hits (pitch shift) | High |
| UI animations | Buttons, inventory, coins | Medium |

### GoDig Juice Map

| Action | Juice Effect | Priority |
|--------|--------------|----------|
| Mine block | Hit sound + dust particles | P1 |
| Break block | Screen shake (small) + debris | P1 |
| Discover ore | Glow + chime + particles | P1 |
| Rare ore | Flash + shake + haptic + fanfare | P1 |
| Pickup item | Squish + pop sound + float to HUD | P2 |
| Buy upgrade | Celebration particles + sound | P2 |
| Sell items | Coin arc animation + rolling counter | P2 |
| Place ladder | Click + small dust puff | P3 |
| Wall jump | Streak effect + whoosh | P3 |

### Over-Juicing Warnings

1. **Don't juice everything equally** - Reserve big effects for rare/important moments
2. **Responsiveness > Reactiveness** - Controls must feel tight first, then add effects
3. **Juice can't fix bad design** - Core loop must be fun without any juice
4. **Sensory overload** - Mining is constant; effects must not fatigue

### Recommendation

**Phase 1: Core loop juice (P1)**
- Mining feedback (hit, break)
- Ore discovery (common, rare)
- Damage/death

**Phase 2: Economy juice (P2)**
- Selling animation
- Upgrade celebration
- Inventory warnings

**Phase 3: Polish juice (P3)**
- Movement effects
- UI transitions
- Ambient particles
