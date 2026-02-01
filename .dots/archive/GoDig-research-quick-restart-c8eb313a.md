---
title: "research: Quick restart UX analysis - minimize friction between runs"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"2026-02-01T02:08:43.857880-06:00\\\"\""
closed-at: "2026-02-01T02:21:48.806954-06:00"
close-reason: Completed research on quick restart UX. Documented timing guidelines (<1.5s death-to-clickable), friction anti-patterns, and flow improvements for death/sell/forfeit scenarios. References 3 existing implementation specs.
---

Research how successful roguelikes minimize the time between death/completion and starting a new run. Key insight from research: 'Near-instant restart after failure - Menus getting in the way antagonizes frustrated players.' Investigate: Dead Cells, Spelunky 2, Hades restart flows. Document patterns for GoDig (death, forfeit cargo, after-sell).

## Research Findings

### The Core Principle: Seconds Matter

From [Genieee - Reducing Player Friction](https://genieee.com/reducing-player-friction-in-mobile-games/):
> "The FTUE is the player's very first interaction with your game. A successful FTUE removes friction so the player can start playing within seconds."

This principle extends to EVERY restart, not just the first.

### Spelunky 2: The Gold Standard

From [Spelunky 2 Steam Discussions](https://steamcommunity.com/app/418530/discussions/0/2965016081078662947/):
- **Quick Restart** button puts player right back to level 1-1
- Takes "no time and effort whatsoever to restart"
- Community created mods for EVEN FASTER restarts
- Note: "Instant restart option is off by default" - players actively want this!

**Key insight**: Players mod the game to make restart faster. This is a desired feature.

### Dead Cells: Flow State Enabler

From [Dead Cells Medium Analysis](https://matthal.medium.com/the-hook-line-and-sinker-of-dead-cells-why-its-so-hard-to-put-down-1fb5d3ac54db):
> "Dead Cells enables the player to achieve the state of flow very fast."

Restart flow:
1. Death → Brief animation
2. Respawn at hub (1-2 seconds)
3. Different dialogue each time (keeps it fresh)
4. Run to entrance → instant new run

**Key insight**: The hub visit isn't friction - it's where meta-progression happens. But the HUB TO GAME transition must be instant.

### Hades: Narrativizing Death

From previous research:
- Death = respawn in House of Hades
- New dialogue rewards the death
- Players WANT to die to see story progress
- "I'm actually looking forward to respawning"

**Key insight**: Death can be a reward moment, not just restart friction.

### Mobile Game Best Practices (2025)

From [Interaction Design Foundation](https://www.interaction-design.org/literature/article/my-head-hurts-cognitive-friction-in-the-age-of-mobile):

Three types of friction to eliminate:
1. **Emotional friction** - Frustration that prevents action
2. **Interaction friction** - Non-intuitive interfaces
3. **Cognitive friction** - Mental effort gap

**For restart UX**:
- Emotional: Don't make player feel punished
- Interaction: One tap to restart
- Cognitive: Make restart option obvious

### GoDig Restart Scenarios

| Scenario | Current Flow | Ideal Flow |
|----------|-------------|------------|
| **Death** | Death screen → Respawn | Death screen → "Quick Dive" button |
| **Forfeit Cargo** | Teleport to surface → Walk to shop | Teleport → "Dive Again" overlay |
| **After Sell** | Shop menu → Close → Walk to mine | Shop → "Dive Again" button |
| **Session Start** | Main menu → Load → Surface | Main menu → "Quick Dive" option |

### The "One More Run" Button

From archived research on one-more-run psychology:
> After selling, show "Dive Again" button that skips shop browsing if player is ready.

This is the KEY feature. Implementation:

```
After selling:
1. Show sell confirmation with coin animation
2. Display "Dive Again" button prominently
3. If clicked: immediate transition to mine entrance
4. If ignored: player can browse shop normally
```

### What Causes Friction (Anti-patterns)

1. **Unskippable animations** - Spelunky 2 players complain about "walls shifting" animation
2. **Multiple menu levels** - "pause → options → retry → confirm"
3. **Forced tutorials** - Already know how to play!
4. **Loading screens** - Should be hidden or instant
5. **Confirmation dialogs** - "Are you sure?" NO! They clicked it!

### Recommended Implementation for GoDig

#### Priority 1: Death Flow
```
Death → 1s death animation → Death screen with:
  - "Dive Again" (LARGE, prominent)
  - "Return to Surface" (smaller)
  - Stats summary (brief)
```

#### Priority 2: After-Sell Flow
```
Sell All → Coin animation (0.5s) → Overlay with:
  - Total earned
  - "Dive Again" (one tap)
  - "Keep Shopping" (secondary)
```

#### Priority 3: Forfeit Cargo Flow
```
Forfeit Cargo → Teleport animation → Surface with:
  - Brief "Safe!" text
  - Automatic "Quick Dive?" prompt
```

#### Priority 4: Session Start
```
Main Menu:
  - "Continue" (loads at surface)
  - "Quick Dive" (loads and immediately starts run)
```

### Timing Guidelines

| Action | Target Time | Maximum Acceptable |
|--------|-------------|-------------------|
| Death → "Dive Again" clickable | 1.5s | 3s |
| "Dive Again" click → gameplay | 0.5s | 1s |
| Sell → "Dive Again" visible | 0.5s | 1s |
| Menu → gameplay (Quick Dive) | 1s | 2s |

### Success Metrics

- Players complete more runs per session
- Reduced "rage quit" from death friction
- Increased "one more run" behavior
- Faster session start times

## Implementation Specs Referenced

- GoDig-implement-instant-respawn-1327777a (Instant respawn at surface after death)
- GoDig-implement-quick-dive-0cb05828 (Quick-dive button after selling)
- GoDig-implement-instant-restart-18f90600 (Instant restart UX after surface return)

## Sources
- [Spelunky 2 - Instant Restart Mod](https://spelunky.fyi/mods/m/instant-restart/)
- [Genieee - Reducing Player Friction](https://genieee.com/reducing-player-friction-in-mobile-games/)
- [Survicate - User Friction Guide 2025](https://survicate.com/blog/user-friction/)
- [Medium - Friction Design Philosophy](https://medium.com/@b.wyszkowski/friction-design-when-ux-eliminates-and-game-design-creates-fd23a5e0eafc)
