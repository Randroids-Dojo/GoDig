---
title: "implement: No sudden-death from RNG - always provide warning/counterplay"
status: open
priority: 1
issue-type: task
created-at: "2026-02-02T18:50:50.421962-06:00"
---

## Purpose
Ensure that no random element can instantly end a run without warning or player counterplay.

## Core Principle
'No beheading rule' from roguelike design consensus: Random elements should never instantly end run without warning or counterplay.

## Design Guidelines
1. Ladder depletion is gradual with visual warnings
2. Environmental hazards (lava, etc.) should have visual tells before damage
3. Enemy encounters (if any) should have approach warning
4. Fall damage should be predictable based on visible height
5. No 'gotcha' moments that feel unfair

## Verification Checklist
- [ ] Low ladder warning appears with time to respond
- [ ] All hazards have visual indicators before damage
- [ ] Player can always see consequences before committing
- [ ] Deaths feel 'deserved' - player can identify mistake

## Sources
Roguelike difficulty balance research - Session 31
