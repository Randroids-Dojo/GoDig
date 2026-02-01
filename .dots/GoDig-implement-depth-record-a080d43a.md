---
title: "implement: Depth record tracking with beat-your-record goal"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T01:48:50.515983-06:00"
---

Display personal depth record on HUD or surface. 'Deepest: 125m'. When player exceeds record, celebrate and update. Creates natural 'go deeper' goal beyond just collecting resources.

## Description
Track and display the player's personal depth record, creating an intrinsic "beat your best" goal alongside resource collection.

## Context
From Session 4 research:
- "Depth as Achievement" is a primal motivation in mining games
- Going deeper = tangible progress
- Creates "just one more" urge: "I was SO close to 150m!"
- Complements the resource loop with an exploration loop

## Implementation

### Data Storage
1. Add `deepest_depth: int` to player save data (SaveManager)
2. Initialize to 0 for new games
3. Update whenever player's current depth exceeds record

### HUD Display
1. Show current depth AND record on HUD:
   ```
   Depth: 87m
   Record: 125m
   ```
2. When current depth > 80% of record, highlight (yellow text)
3. When current depth == record, pulse animation

### New Record Celebration
When player exceeds their previous record:
1. Flash "NEW RECORD!" toast
2. Particle burst effect
3. Satisfying sound (achievement-style)
4. Update record display immediately
5. Don't spam - only trigger once per "record-breaking" moment

### Visual Design Options

**Option A: Combined Display**
```
Depth: 87m (Record: 125m)
```

**Option B: Separate with Progress**
```
Depth: 87m
━━━━━━░░░░ 125m
```
Progress bar shows distance to record.

**Option C: Record Only at Surface**
- Underground: Show current depth only
- Surface: Show "Deepest: 125m" as badge

### Milestone Synergy
This complements existing depth milestone system but focuses on personal bests rather than fixed thresholds.

## Affected Files
- `scripts/autoload/save_manager.gd` - Store deepest_depth
- `scripts/autoload/player_stats.gd` - Track and update record
- `scripts/ui/hud.gd` - Display depth + record
- `scripts/effects/record_celebration.gd` - New record effect

## Verify
- [ ] New game starts with 0m record
- [ ] Record updates when player goes deeper
- [ ] "NEW RECORD!" celebrates first time reaching new depth
- [ ] Record persists across sessions (saved)
- [ ] Display visible underground
- [ ] Does not spam celebrations (once per record break)
- [ ] Record shown on surface/home base
