---
title: "research: Ladder and traversal system"
status: done
priority: 0
issue-type: task
created-at: "2026-01-18T23:39:36.724226-06:00"
---

How do ladders work to escape tunnels? Questions: Are ladders bought from shop or crafted? How are they placed? (tap to place, auto-place?) How many does player carry? Can they be picked back up? Are there other traversal items? (rope, teleport scroll) How does climbing state work? What about the mine entrance on surface?

## Research Findings (2026-01-19)

### Current Implementation Status: NOT IMPLEMENTED

Ladders are planned for v1.0 (see `GoDig-v1-0-placeable-7d46e882`). MVP relies on wall-jump.

### Design Recommendations

**1. Are ladders bought from shop or crafted?**
- **Recommendation: Bought from Supply Store**
- Simple for MVP scope
- No crafting system needed
- Crafting could be v1.1 feature

**2. How are they placed?**
- **Recommendation: Dedicated place button + tap target**
- Player selects "Place Ladder" from quick-slot
- Tap on empty tile adjacent to player
- Places ladder tile that persists in chunk save

**3. How many does player carry?**
- **Recommendation: Stackable inventory item**
- Max stack: 50 (generous for exploration)
- Takes inventory space = gameplay tradeoff
- Starting inventory: 0 (buy or find)

**4. Can they be picked back up?**
- **Recommendation: YES (with tool)**
- Tap ladder while holding pickaxe = pick up
- Returns to inventory
- Encourages reuse, reduces waste

**5. Are there other traversal items?**

**MVP:**
- Ladders only (essential for vertical traversal)

**v1.0:**
- Teleport Scroll - Single-use, returns to surface
- See `GoDig-dev-teleport-scroll-1403d2d4`

**v1.1:**
- Rope - Throwable, temporary ladder
- Grappling Hook - Reusable, skill-based
- Elevator - Permanent, high-investment

**6. How does climbing state work?**

**Proposed State Machine Addition:**
```gdscript
enum State { IDLE, MOVING, MINING, FALLING, WALL_SLIDING, WALL_JUMPING, CLIMBING }

func _handle_climbing(delta: float) -> void:
    # Cancel gravity
    velocity.y = 0

    # Move up/down based on input
    var dir := _get_input_direction()
    if dir.y != 0:
        velocity.y = dir.y * CLIMB_SPEED

    # Jump off ladder
    if _check_jump_input():
        current_state = State.FALLING
        return

    # Check if still on ladder tile
    if not _is_on_ladder():
        current_state = State.FALLING
```

**7. What about the mine entrance on surface?**
- **Recommendation: Visual only (MVP)**
- Entrance sprite marks where mine starts
- No functional interaction needed
- Future: Fast-travel point, elevator connection

### Implementation Priority

1. **Ladder placement system** - Core traversal need
2. **Climbing state** - Player can use ladders
3. **Ladder quick-slot HUD** - Easy access
4. **Teleport scroll** - Emergency escape option

### Related Implementation Dots

- `GoDig-dev-ladder-placement-7b71387f` - Place ladders
- `GoDig-dev-climbing-state-0365747d` - Climb ladders
- `GoDig-dev-ladder-quick-fd11e421` - HUD quick-slot
- `GoDig-dev-mine-entrance-333923aa` - Surface entrance
- `GoDig-dev-teleport-scroll-1403d2d4` - Teleport item

### MVP Alternative

Until ladders are implemented:
- Wall-jump handles vertical escape
- Emergency rescue (pause menu) as fallback
- Reload save for soft-lock recovery

### No Further Research Needed

Design decisions made. Implementation dots exist.
