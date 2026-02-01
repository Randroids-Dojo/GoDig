---
title: "implement: Return route efficiency hints"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T08:31:14.056068-06:00"
---

## Description

Visual hint system to show efficient return routes using existing ladders. The return trip is where FUN can die - help players feel clever, not frustrated.

## Context (Session 13 Research)

From Motherload/Dome Keeper analysis:
- "Repetition of going up and down gets increasingly tedious"
- "Mining underground is strangely peaceful... but tension always hangs in background"
- Dome Keeper solution: Lift gadget "cut down time exponentially"
- First "screw this game" moment: tedium of return trip

From Deep Sea Adventure:
- "Double whammy of moving slower and the end accelerating on you punishes hubris"
- Players need to KNOW they're in trouble before it's too late

From push-your-luck research:
- "Good tension: I wish I could do both but must choose"
- "Bad frustration: I can't do anything meaningful"

## The Problem

Player digs deep, places some ladders on the way down. Now they want to return:
1. Where are my ladders? (fog of war / darkness)
2. Can I make it with wall-jumping?
3. Should I place more ladders or save them?

Without help, this becomes frustrating guesswork. With hints, it becomes strategic planning.

## Design

### Ladder Beacon System

When player is deep underground (>30m from surface):

1. **Ladder glow**: Placed ladders emit subtle upward-pointing light/particles
2. **Minimap markers**: Show ladder positions on edge of screen
3. **Route line** (optional, v1.1): Trace optimal path to surface

### "Safe Return" Indicator

In the HUD, show a simple indicator:
- **GREEN**: "You can reach surface with current ladders + wall-jump"
- **YELLOW**: "Risky - you might get stuck"
- **RED**: "Danger - place more ladders or use emergency"

### Calculation

```gdscript
func calculate_return_safety() -> int:
    var current_depth = player.position.y / TILE_SIZE
    var available_ladders = inventory.get_count("ladder")
    var placed_ladders = world.get_ladder_positions_above_player()

    # Estimate: wall-jump covers ~5m safely, each ladder covers ~2m
    var wall_jump_capacity = 25  # 5 wall-jumps at 5m each
    var placed_capacity = placed_ladders.size() * 10  # each ladder = 10m
    var inventory_capacity = available_ladders * 10

    var total_capacity = wall_jump_capacity + placed_capacity + inventory_capacity

    if total_capacity > current_depth * 1.5:
        return SAFE  # GREEN
    elif total_capacity > current_depth:
        return RISKY  # YELLOW
    else:
        return DANGER  # RED
```

### Visual Implementation

1. **Ladder glow**: Add `Light2D` or particle effect to placed ladder scene
2. **Edge markers**: Small arrow icons at screen edge pointing to nearest ladder
3. **HUD indicator**: Simple colored icon (traffic light style) near depth display

## Affected Files

- `scenes/items/ladder.tscn` - Add subtle glow/particles
- `scripts/ui/hud.gd` - Add return safety indicator
- `scripts/world/` - Query for ladder positions
- `scripts/player/` - Calculate return safety on position change

## Verify

- [ ] Placed ladders visible from a distance (glow)
- [ ] Safety indicator shows GREEN near surface
- [ ] Safety indicator shows YELLOW when borderline
- [ ] Safety indicator shows RED when definitely stuck without action
- [ ] Indicator updates as player moves/places ladders
- [ ] Does not spoil surprise (no full map reveal)
- [ ] Performance acceptable (don't recalculate every frame)

## Design Notes

This is about PREVENTING frustration, not removing challenge:
- Player still decides when to turn back
- Player still manages ladder inventory
- The hint just removes blind guessing

## Related Specs

- `GoDig-implement-low-ladder-e6f21172` - Low ladder warning
- `GoDig-implement-depth-aware-00ae8542` - Depth-aware ladder warning
- `GoDig-implement-return-to-9ecc2744` - Return-to-surface tension indicator

## Related Research

Session 13: Dome Keeper/Motherload return journey analysis
Session 9: Push-your-luck board game mechanics
