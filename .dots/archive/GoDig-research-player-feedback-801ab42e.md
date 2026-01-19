---
title: "research: Player feedback and juice"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-01-18T23:42:37.182751-06:00\\\"\""
closed-at: "2026-01-19T01:53:02.442123-06:00"
close-reason: Created 2 new implementation specs (hit pause, UI bounce), enhanced 5 existing specs with full details and verify sections
---

Research game feel and 'juice' patterns. What makes mining satisfying? Screen shake, particles, sounds, haptics, number popups, combo systems. Look at talks by Jan Willem Nijman, Vlambeer. How can we make each dig feel rewarding? What visual/audio feedback is missing?

## Research Findings (2026-01-19)

### Existing Documentation

Comprehensive research already exists in:
- `Docs/research/game-feel-juice.md` - Core juice patterns, code examples
- `Docs/research/audio-sound-design.md` - Sound feedback patterns

### Key Juice Principles for Mining Games

1. **Every action needs a reaction** - Players should feel the weight of their inputs
2. **Intensity matches significance** - Common blocks = subtle feedback, rare finds = dramatic
3. **Mix feedback types** - Visual + audio + haptic for complete feedback loop
4. **Performance first** - Juice that causes lag is anti-juice

### Missing Implementation Specs Identified

Created/enhanced implementation specs for:

1. **Screen Shake** (`GoDig-v1-0-screen-0d21d382.md`) - Now has full spec with intensity tables
2. **Block Break Particles** (`GoDig-dev-block-break-dcb6855f.md`) - Full spec with pooling pattern
3. **Squash/Stretch** (`GoDig-dev-squash-stretch-673bbdef.md`) - Full spec with timing tables
4. **Haptic Feedback** (`GoDig-v1-0-haptic-60d1d4e2.md`) - Full spec with HapticsManager
5. **Gem Sparkle** (`GoDig-dev-gem-sparkle-b95f3498.md`) - Full spec with rarity-based frequency
6. **Hit Pause/Hitstop** (`GoDig-implement-hit-pause-95f0ed9e.md`) - NEW: Critical juice element
7. **UI Bounce/Pop** (`GoDig-implement-ui-bounce-e8bbf67f.md`) - NEW: UIEffects utility class

### Priority Order for MVP Juice

1. Block break particles (P1) - Core feedback
2. Floating pickup text (P1) - Already spec'd
3. Squash/stretch on landing (P2) - Low effort, high impact
4. Screen shake (P2) - Optional but satisfying
5. UI bounce effects (P2) - Makes buttons feel alive
6. Haptics (P2) - Mobile-essential
7. Hit pause (P2) - Subtle but impactful
8. Gem sparkle (P2) - Nice-to-have

### Sources

- [Game Feel: The Secret Ingredient (GDC)](https://www.youtube.com/watch?v=216_5nu4aVQ)
- [The Art of Screen Shake (Vlambeer)](https://www.youtube.com/watch?v=AJdEqssNZ-U)
- [Juice It or Lose It (GDC Talk)](https://www.youtube.com/watch?v=Fy0aCDmgnxg)
- [GameDev Academy - Game Feel Tutorial](https://gamedevacademy.org/game-feel-tutorial/)
- [GameAnalytics - Squeezing more juice](https://www.gameanalytics.com/blog/squeezing-more-juice-out-of-your-game-design)
