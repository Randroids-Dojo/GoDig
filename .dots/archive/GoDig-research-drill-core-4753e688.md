---
title: "research: Drill Core pacing lessons - what causes mining game mid-game fatigue"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-02T18:51:06.001258-06:00\\\"\""
closed-at: "2026-02-02T18:52:56.193496-06:00"
close-reason: "Completed analysis: 5-10 min loops validated, single currency confirmed, variety through depth discoveries"
---

## Purpose
Deep dive into Drill Core's identified pacing problems to avoid similar issues in GoDig.

## Background
From Session 31 research, Drill Core received criticism for:
- Runs lasting longer than other roguelikes
- Three separate meta-progression systems 'competing for attention'
- 'Gameplay gets repetitive quickly despite variations'
- Unit AI issues causing frustration

## Research Questions
1. What is the ideal run length for mining roguelites?
2. How many progression systems is too many?
3. What causes 'repetitive gameplay' feeling - mechanical or pacing?
4. How do successful games avoid mid-game fatigue?

## Investigation Areas
- Compare Drill Core run length vs SteamWorld Dig vs Dome Keeper
- Analyze 'three competing systems' problem - what systems and why they conflict
- Study player reviews specifically mentioning repetition
- Look for solutions implemented in post-launch patches

## Expected Outputs
- Run length recommendation for GoDig (target: 5-10 minutes)
- Single progression system validation (coins only)
- Variety injection points to prevent repetition

## Research Findings

### Ideal Run Length for Mining Roguelites

| Game | Run Length | Notes |
|------|------------|-------|
| Drill Core | 30-50 minutes | "A poor choice can bite you after half an hour" - frustrating |
| BORE BLASTERS | 5-15 minutes | "Ideal for battery-powered devices" |
| Wall World | ~20 minutes | Gets longer with meta upgrades |
| Dome Keeper | Variable | Player chooses map size = session length |
| General consensus | 20-30 minutes | "Before repetition feeling sets in" |

**GoDig Recommendation**: 5-10 minute complete loops. Our mobile-first design should target the shorter end - BORE BLASTERS proves 5-15 minutes works for mining roguelites. Dome Keeper's "player chooses" approach could work for us (quick dig vs deep dive options).

### What Causes Mid-Game Fatigue in Drill Core

1. **Run length is TOO LONG**: 30-50 minutes means a mistake destroys 30+ minutes of investment
2. **Triple-layered progression feels like busywork**: Even when gameplay is engaging, competing systems add friction
3. **Grind for meaningful improvements**: "Unlocking improvements requires significant time and effort"
4. **Repetitive late-game sessions "blur together"**: Even with variations, core activities don't change enough

### Multiple Progression Systems Problem

From Hades analysis, multiple currencies CAN work if:
- Each currency ties to a different type of progression
- Player gets meaningful CHOICE between currencies
- None feels mandatory or like "wasted" opportunity

From Drill Core criticism:
- Three systems "competing for attention" = cognitive overload
- Players don't understand which to prioritize
- Feels like artificial padding rather than meaningful depth

**Slay the Spire model (best practice)**:
- "No power is ever given via meta progression"
- System works as gradual tutorial (unlock new cards/relics)
- Score-based unlocks, not currency grinding
- Player plays with "full body" from run 1

### GoDig Validation: Single Currency (Coins) is Correct

Research confirms our single-currency approach:
- Simpler mental model for mobile players
- No "which currency do I need" decision paralysis
- All progress goes toward same goals
- Avoid "grindy game" perception

### Variety Injection Points to Prevent Repetition

From successful games:
1. **Depth-based surprises** (Mr. Mine): New discoveries at random depths break monotony
2. **Player choice in run structure** (Dome Keeper): Map size determines session length
3. **Meaningful upgrades change gameplay** (SteamWorld Dig): Each tier should FEEL different, not just be faster
4. **Post-run entertainment** (Drill Core corporate emails): Make return-to-hub moments fun
5. **Horizontal progression** (Slay the Spire): Unlock OPTIONS not power - keeps early game fresh

### Key Takeaway

Quote: "Every roguelite has a certain period during a run where it starts feeling like a chore. The player should be able to 'finish' before this feeling sets in."

GoDig should:
- Target 5-10 minute complete loops
- Keep single currency (coins)
- Add variety through depth discoveries and layer identities
- Ensure each upgrade changes gameplay feel, not just speed
- Allow player agency over session length (quick dig vs deep dive)
