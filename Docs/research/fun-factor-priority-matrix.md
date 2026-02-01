# Fun Factor Priority Matrix

*Last updated: Session 19 (2026-02-01)*

This document ranks fun factor improvements by impact, based on research from Sessions 1-19. Use this as a guide for implementation prioritization.

## Priority Tiers

### P0: Critical - Core Loop Must Work
These must be functional before testing fun with players. Without these, the game cannot be evaluated.

| Spec ID | Title | Why Critical |
|---------|-------|--------------|
| `GoDig-implement-core-mining-debb2ca2` | Core mining feel validation | If mining isn't fun without systems, nothing else matters |
| `GoDig-implement-guaranteed-first-99e15302` | Guaranteed first ore within 3 blocks | First dopamine hit - players churn without quick discovery |
| `GoDig-give-player-2-8f4b2912` | 5 starting ladders | First dive must succeed, not strand player |
| `GoDig-move-supply-store-61eb95a1` | Supply Store at 0m | Players must be able to buy ladders immediately |

**Key Research Finding**: "If your core loop isn't fun, it doesn't matter how great your narrative or physics interactions are."

### P1: High - First 5 Minutes
These determine retention. 46% of worst-performing games lose players by minute 5.

| Spec ID | Title | Why High |
|---------|-------|----------|
| `GoDig-implement-ftue-60-94baf4fa` | FTUE 60-second hook | First 60 seconds determine if users return |
| `GoDig-implement-first-5-0e449846` | First 5 minute economy | First upgrade in 5 min = 88% higher retention |
| `GoDig-implement-first-ore-9dc20570` | First ore discovery celebration | Anchors positive emotional memory |
| `GoDig-implement-satisfying-sell-150bde42` | Satisfying sell animation | Sell moment is KEY reward beat in core loop |
| `GoDig-implement-distinct-audio-09fbd1b1` | Distinct audio/visual per pickaxe | First upgrade must be FELT immediately |
| `GoDig-implement-block-crack-c5b298f2` | Block crack progression visual | Visual feedback makes mining satisfying |

**Key Research Finding**: "Retention can increase up to 50% with effective onboarding."

### P2: Medium - Session Satisfaction
These keep players engaged during a session and encourage return visits.

| Spec ID | Title | Impact |
|---------|-------|--------|
| `GoDig-implement-emergency-rescue-c0e6b975` | Proportional rescue fee | Fair punishment = players accept failure |
| `GoDig-implement-elevator-unlock-a0099585` | Elevator discovery celebration | Return journey tedium solution |
| `GoDig-implement-wall-jump-ec117d74` | Wall-jump mastery feedback | Makes return feel skillful, not tedious |
| `GoDig-implement-low-ladder-e6f21172` | Low ladder warning | Prevents frustrating "stuck" moments |
| `GoDig-implement-depth-aware-00ae8542` | Depth-aware ladder warning | Creates tension without punishment |
| `GoDig-implement-instant-restart-35c6a217` | Instant restart after rescue | Quick restart enables "one more run" |
| `GoDig-implement-quick-buy-1f33cfbe` | Quick-buy ladder shortcut | Reduces friction in core loop |
| `GoDig-implement-numbers-go-5805c161` | Numbers go up visibility | "Number go up" is core satisfaction |

**Key Research Finding**: "Push-your-luck works when there are NOT sudden-death situations."

### P3: Low - Polish & Delight
These enhance the experience but don't determine retention. Implement after core works.

| Spec ID | Title | Delight Factor |
|---------|-------|----------------|
| `GoDig-implement-depth-unlocks-9826143d` | Depth unlocks discoveries | Surprise moments |
| `GoDig-implement-hidden-treasure-9fd6f4c2` | Hidden treasure rooms | Exploration reward |
| `GoDig-implement-jackpot-discovery-aae547b3` | Jackpot celebration | Variable reward excitement |
| `GoDig-implement-close-call-034e09a9` | Close-call celebration | Memorable near-miss moments |
| `GoDig-implement-discoverable-lore-67646ab4` | Lore elements | Story players tell |
| `GoDig-implement-welcome-back-f99d9b0d` | Welcome back rewards | Re-engagement without punishment |

**Key Research Finding**: "Reserve intense effects for special occasions - mining is CONSTANT."

## The Greybox Test

Before adding ANY juice or systems, ask:

> Does the core tap-to-mine loop feel fun with greybox art and no rewards?

If NO: Fix the input → feedback → rhythm before proceeding.

**What to check:**
- [ ] Block break has satisfying visual feedback
- [ ] Block break has satisfying audio feedback
- [ ] Digging rhythm doesn't become monotonous
- [ ] Movement feels responsive
- [ ] Camera follows player smoothly

## Session 19 Key Insights

1. **Core loop fundamentals**: "If digging isn't satisfying by itself, the game isn't for you"
2. **Return journey**: Wall-jump mastery + elevator unlock + teleport scroll = three-tier solution
3. **Permadeath design**: Soft failure (keep some cargo) works better than total loss
4. **Game feel**: Juice moment-to-moment, reserve impact for discoveries
5. **First upgrade**: Frame as achievement, not purchase. Must happen in first 5 minutes.

## Implementation Order

```
1. Core mining feel (P0)
2. Guaranteed first ore (P0)
3. Starting ladders (P0)
4. Supply Store at 0m (P0)
   ↓
   TEST: Is basic loop functional?
   ↓
5. FTUE 60-second hook (P1)
6. First 5 minute economy (P1)
7. First ore celebration (P1)
8. Sell animation (P1)
   ↓
   TEST: Do new players get hooked?
   ↓
9. Rescue fee proportional (P2)
10. Wall-jump mastery feedback (P2)
11. Ladder warnings (P2)
12. Instant restart (P2)
   ↓
   TEST: Do players want "one more run"?
   ↓
13-N. Polish & delight (P3)
```

## Related Research Sessions

- Session 11: Vampire Survivors - minimal input, maximum feedback
- Session 12: Slay the Spire - metrics-driven balance
- Session 13: Deep Sea Adventure - push-your-luck tension
- Session 14: Cozy game design - safe zone principles
- Session 17: Animal Well - layered secrets
- Session 18: FTUE best practices 2025
- Session 19: Core loop fundamentals, fair punishment
