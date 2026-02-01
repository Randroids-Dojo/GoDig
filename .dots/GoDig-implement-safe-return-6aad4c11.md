---
title: "implement: Safe return celebration when reaching surface with loot"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T08:39:52.629680-06:00"
---

## Description

Add a satisfying celebration moment when the player successfully returns to the surface carrying valuable ore. This is the 'relief' moment that completes the push-your-luck tension cycle.

## Context

Research (Session 14) found that:
- Cozy game design emphasizes distinct thresholds between danger/safety (snowstorm → cabin relief)
- Deep Rock Galactic extraction creates 'satisfying tension' followed by relief
- Session-end rewards create 'positive experience' - players feel appreciated
- 'Little you did it! moments' via badges, trophies, animations boost retention

The safe return is our equivalent of DRG's extraction success. It should feel like an achievement, not just 'going home'.

## Implementation

### Trigger Conditions
- Player enters surface zone (y <= 0)
- Player inventory contains at least 1 ore/resource
- First time reaching surface in current dig (don't repeat if they go back down)

### Celebration Elements
1. **Screen flash** - Brief golden/warm overlay (100ms fade in, 200ms fade out)
2. **Sound effect** - Triumphant chime/jingle (short, satisfying)
3. **Text toast** - 'SAFE!' or 'Made it!' centered on screen
4. **Inventory preview** - Brief flash showing total haul value
5. **Camera** - Slight upward pan to show sky/surface buildings

### Scaling Intensity
- Light haul (<50 coins worth): Subtle celebration
- Good haul (50-200 coins): Standard celebration
- Great haul (200-500 coins): Enhanced celebration with particle burst
- Jackpot haul (500+ coins): Full celebration with screen shake + special sound

### Deep Dive Bonus
If player returned from below 50m depth, add:
- Extra text: 'Deep Dive Complete!'
- Track as achievement/stat

## Affected Files
- `scripts/player/player.gd` - Detect surface entry with loot
- `scripts/ui/celebration_manager.gd` - New file for celebration system
- `scenes/ui/safe_return_celebration.tscn` - Celebration UI scene
- `scripts/autoload/game_manager.gd` - Track deepest depth this run

## Verify
- [ ] Celebration triggers on first surface return with loot
- [ ] Does NOT trigger when returning empty-handed
- [ ] Does NOT trigger on subsequent surface visits (same dig)
- [ ] Intensity scales with haul value
- [ ] Deep dive bonus triggers at 50m+ depth
- [ ] Celebration doesn't block player movement/actions
- [ ] Works correctly after emergency rescue (no celebration for rescue)
