---
title: "implement: Automation building simple optimization (v1.1)"
status: closed
priority: 3
issue-type: task
created-at: "\"\\\"2026-02-01T08:46:19.590156-06:00\\\"\""
closed-at: "2026-02-02T21:56:30.079987-06:00"
close-reason: Implemented AutoMinerManager with 3-tier upgrades, slot-based ore assignment, offline generation, and SaveManager persistence
---

## Description

Design the Auto-Miner Station for v1.1 that creates simple optimization puzzles without over-complicating.

## Context

From Session 15 research:
- Satisfactory: 'glossier, more accessible experience, effectively streamlining many of the ideas Factorio pioneered'
- Satisfactory's infinite resources remove tedious 'seek new veins' loop
- 'Overseeing a system of interconnected machines' creates satisfying complexity
- Player quote: 'I don't know where the factory ends and I begin'
- Key lesson: Don't over-complicate - Satisfactory succeeded by streamlining

## Design (v1.1 Feature)

### Auto-Miner Station
- Unlocks at 1000m depth
- Place on surface
- Generates passive income of basic ores over time
- Upgrade tiers increase output and ore types

### Optimization Puzzle (Simple)
- Multiple miner slots (start with 1, upgrade to 3)
- Each miner targets a specific ore type
- Players choose: diversify or specialize?
- No conveyor belts or routing - just slot assignment

### Upgrade Path
| Level | Slots | Output/Hour | Cost |
|-------|-------|-------------|------|
| 1 | 1 | 10 coal | 50,000 |
| 2 | 2 | 15 per slot | 150,000 |
| 3 | 3 | 20 per slot | 400,000 |

### Ore Type Unlocks
- Coal/Copper: default
- Iron/Tin: reach 200m
- Silver/Gold: reach 500m
- Gems: reach 1000m

### Balance Considerations
- Passive income should supplement, not replace active mining
- ~10% of active mining income at equivalent depth
- Creates 'return to surface' reward feeling
- Collected automatically, shown on return

## Affected Files (v1.1)
- scripts/buildings/auto_miner_station.gd (new)
- scenes/surface/buildings/auto_miner_station.tscn (new)
- resources/buildings/auto_miner_station.tres (new)
- scripts/autoload/save_manager.gd (persist miner state)

## Verify
- [ ] Auto-Miner appears at 1000m unlock
- [ ] Passive income accumulates while playing
- [ ] Upgrade path feels meaningful
- [ ] Income is supplemental (10% of active)
- [ ] Slot assignment is clear and simple

## Note
This is a v1.1 feature - scope for post-launch.
