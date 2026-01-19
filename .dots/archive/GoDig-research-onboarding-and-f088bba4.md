---
title: "research: Onboarding and first 5 minutes"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-01-18T23:42:37.519013-06:00\\\"\""
closed-at: "2026-01-19T02:57:58.779801-06:00"
close-reason: Synthesized MVP requirements from existing research, created tutorial implementation spec
---

Research effective game tutorials and first-time user experience. How do successful mobile games teach without tutorials? What's the ideal first 5 minutes of GoDig? When should we introduce shops, upgrades, ladders? Check UX research on game onboarding, A/B testing results from similar games.

## Research Findings

### Source
Existing research in `Docs/research/tutorial-onboarding.md` is comprehensive. This dot synthesizes MVP-relevant findings and creates implementation specs.

### Core Principles (Applied to GoDig)

1. **Show, Don't Tell**: Visual cues (arrows, highlights) over text
2. **Progressive Disclosure**: One mechanic at a time (move, dig, collect, sell, upgrade)
3. **Safe Failure**: First 50m is forgiving, no fall damage in tutorial zone
4. **Quick to Fun**: First ore within 30s, first sell within 3 mins

### The First 5 Minutes Timeline

| Time | Phase | Player Action | System Response |
|------|-------|---------------|-----------------|
| 0:00 | Start | Game loads | Player on surface, joystick visible |
| 0:10 | Move | Player moves | Arrow prompts fade after movement |
| 0:30 | Dig | Player taps dig | Highlight on dig button, dirt breaks |
| 0:45 | Find | Player digs 3 blocks | GUARANTEED copper spawn in path |
| 1:00 | Collect | Walk over ore | "Copper collected!" popup, inventory pulses |
| 1:30 | Explore | Continue digging | Find more ores naturally |
| 2:30 | Return | Climb back up | Subtle "surface" arrow if stuck |
| 3:00 | Sell | Enter shop | Shop button highlighted, sell tab default |
| 3:30 | Earn | Sell ores | Ka-ching sound, coin counter animates |
| 4:00 | Upgrade | See upgrades tab | "Upgrades make digging faster!" tooltip |
| 5:00 | Complete | Buy first upgrade or dig again | Tutorial flag set, free play begins |

### Guaranteed First-Run Setup

```gdscript
# Called once per new save
func setup_tutorial_world():
    # Place guaranteed copper at depth 3-5 blocks
    var copper_pos = Vector2i(player_spawn_x, 4)
    force_spawn_ore(copper_pos, "copper")

    # Ensure easy path to surface (no hard blocks)
    for y in range(1, 10):
        ensure_soft_block(Vector2i(player_spawn_x - 1, y))
        ensure_soft_block(Vector2i(player_spawn_x, y))
```

### MVP Tutorial Implementation

**What's Needed for MVP**:
1. Joystick/movement prompt (auto-dismiss on movement)
2. Dig prompt (highlight dig button once)
3. "First ore collected" popup
4. "Return to surface to sell" hint (after 60s digging)
5. Shop entry highlight
6. Tutorial complete flag (stored in save)

**What's NOT Needed for MVP**:
- Full 7-phase tutorial sequence
- Analytics tracking
- Returning player detection
- Hint cooldown system
- Settings menu replay option

### Context-Sensitive Hints (MVP Subset)

Only 3 hints needed for MVP:
| Trigger | Hint | Show After |
|---------|------|------------|
| Stuck in hole 15s | "Climb walls to escape!" | 15s |
| Inventory full | "Return to surface to sell!" | Immediate |
| Near shop, never entered | "Enter the shop!" | 5s |

### Implementation Spec

Created: `implement: MVP tutorial sequence` (see below)

## Decisions Made

- [x] How complex for MVP? -> 5 simple prompts, no full tutorial system
- [x] Guaranteed ore? -> Yes, copper at depth 4
- [x] Skip option? -> Not for MVP (tutorial is under 1 minute)
- [x] Analytics? -> v1.0 feature
- [x] Hint system? -> 3 critical hints only
