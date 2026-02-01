---
title: "implement: First-discovery bonus system"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T01:20:33.823918-06:00"
---

## Description
Award bonus coins and trigger special celebration when player discovers a new ore type for the first time.

## Context
First discoveries are memorable moments. Research shows the brain values novelty highly. Currently, finding gold for the first time feels the same as finding the 100th piece. A 'first discovery' bonus creates collection motivation and memorable milestones.

## Implementation
1. Track discovered ore types in PlayerData
2. In test_level.gd `_on_block_dropped()`, check if ore_id is newly discovered
3. If first discovery:
   - Award bonus coins (50% of sell value)
   - Show 'NEW DISCOVERY!' popup with ore icon/name
   - Play unique 'discovery' fanfare sound
   - Add to discovery log/collection
4. Consider adding a Discovery Log UI accessible from HUD

## Affected Files
- `scripts/autoload/player_data.gd` - Add discovered_ores: Array[String]
- `scripts/test_level.gd` - Check and handle first discovery
- `scripts/autoload/sound_manager.gd` - Add discovery fanfare sound
- `scenes/ui/discovery_popup.tscn` - New popup scene for discoveries

## Verify
- [ ] First ore of each type triggers NEW DISCOVERY popup
- [ ] Bonus coins awarded (visible in floating text)
- [ ] Discovery fanfare sound plays
- [ ] Subsequent finds of same ore type = normal feedback
- [ ] Discovered ores persist across sessions
- [ ] Edge case: loading save with pre-discovered ores works
