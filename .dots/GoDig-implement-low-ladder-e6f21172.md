---
title: "implement: Low ladder warning when deep underground"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T01:32:50.706830-06:00"
---

## Description
Add warning when player has <3 ladders while more than 30m deep. Critical tension mechanic - player should feel anxiety about escape resources.

## Context
Research shows 'investment protection' is a core motivator. Players deep underground with few ladders should feel increasing tension, but still have options (wall-jump, forfeit cargo, buy more on surface).

**Relationship to other specs**:
- This is a SIMPLE, targeted warning (ladders only)
- Complements `return-to-9ecc2744` (inventory fill warnings)
- Both may eventually be superseded by `deep-dive-2e1f97dc` (unified tension meter)
- For MVP: implement this + inventory warnings separately, then unify later

## Implementation
1. Track player depth and ladder count in HUD
2. When depth > 30m AND ladders < 3: show pulsing warning icon
3. When depth > 50m AND ladders < 2: show urgent warning + subtle screen tint
4. Audio: low rumble or heartbeat at critical levels
5. Clear immediately when: reaching surface OR buying/finding ladders

## Affected Files
- scripts/ui/hud.gd - Warning display logic
- scripts/autoload/game_manager.gd - Depth tracking
- scripts/autoload/inventory_manager.gd - Ladder count signal

## Verify
- [ ] Warning appears at 30m with <3 ladders
- [ ] Urgent warning at 50m with <2 ladders
- [ ] Warning clears when reaching surface
- [ ] Warning clears when getting more ladders
- [ ] Audio cue is subtle, not annoying

## Related Specs

**NOTE**: This is a SIMPLIFIED version of the ladder warning. For the full depth-aware version with scaling formula, see:
- `GoDig-implement-depth-aware-00ae8542` (Depth-aware ladder warning system)

For MVP, implement THIS spec first (simple fixed thresholds). The depth-aware version is a P2 polish enhancement.
