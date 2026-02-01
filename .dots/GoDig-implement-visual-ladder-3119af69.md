---
title: "implement: Visual ladder urgency indicator"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T09:44:37.917644-06:00"
---

Research Session 23 identified the need for clear visual tension indicators when ladder supply runs low relative to depth.

## Context
Key research findings:
- Low health indicators are standard: flashing red around peripheries
- Progress bars create urgency and excitement  
- Red = danger/urgency is universal language
- Player should have WARNING before crisis, enabling them to CHOOSE to return or push luck

## Specification
Implement a visual urgency indicator that activates when:
1. Player's remaining ladders < estimated ladders needed to return
2. Or player's ladders < 3 and depth > 20m

### Visual Treatment
- Ladder icon in HUD begins pulsing when warning threshold hit
- Optional: subtle red vignette around screen edges (configurable)
- Color transitions: Green (safe) → Yellow (caution) → Red (danger)
- Intensity increases as situation worsens

### Calculation
- Estimate ladders needed = current depth / avg ladder coverage (e.g., 4m per ladder)
- Factor in player's wall-jump ability (reduces ladder need)
- Consider caves/air pockets in calculation

## Affected Files
- HUD.gd or CanvasLayer scene - add urgency visual
- LadderIndicator component (new or existing) - calculation logic
- Player.gd - track current depth

## Verify
- [ ] Build succeeds
- [ ] Indicator shows green when ladders are plentiful
- [ ] Indicator turns yellow when ladders = estimated need + 1
- [ ] Indicator turns red when ladders < estimated need
- [ ] Visual is noticeable but not overwhelming
