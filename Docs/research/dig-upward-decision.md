# Decision: Can Player Dig Upward?

## The Question
Should the player be able to dig upward (break blocks above them), and if so, when?

## Context
This is a core design decision that affects:
- Game difficulty and tension
- Traversal mechanics
- Upgrade progression
- Player agency vs challenge

## Options Analysis

### Option A: Never Dig Up
**How similar games handle it:**
- SteamWorld Dig: Cannot dig up (wall-jump is the solution)
- Motherload: Cannot dig up

**Pros:**
- Creates strategic tension about paths
- Forces planning before descent
- Makes getting "stuck" meaningful
- Ladders/ropes become valuable

**Cons:**
- Can feel restrictive
- Frustrating for new players
- Less player agency

### Option B: Always Dig Up
**Pros:**
- Maximum player freedom
- No "stuck" situations
- Intuitive (real pickaxes work both ways)

**Cons:**
- Removes core tension of genre
- Trivializes traversal
- Ladders become pointless
- Less strategic depth

### Option C: Unlock Dig Up Later (Recommended)
**How it works:**
- Start: Cannot dig upward
- Mid-game unlock: Drill tool allows digging up
- Creates progression milestone

**Pros:**
- Maintains early game tension
- Provides meaningful upgrade goal
- Rewards player progression
- Best of both worlds

**Cons:**
- Slightly more complex to implement
- Must communicate restriction clearly

## Recommendation: Option C

### Implementation Plan

**Phase 1: MVP (No dig up)**
```gdscript
# player.gd
func can_dig_direction(direction: Vector2i) -> bool:
    # Only allow down, left, right
    if direction == Vector2i.UP:
        return false
    return true
```

**Phase 2: v1.0 (Drill unlock)**
```gdscript
# With drill equipped
func can_dig_direction(direction: Vector2i) -> bool:
    if direction == Vector2i.UP:
        return has_drill_equipped()
    return true
```

### Drill Tool Design
| Property | Value |
|----------|-------|
| Unlock depth | 500m |
| Cost | 50,000 coins |
| Dig speed (up) | 50% of normal |
| Special | Required for upward digging |

### Player Communication
1. **Tutorial**: "Dig down, left, or right to mine"
2. **Attempted up-dig**: Show message "Cannot dig up... yet"
3. **Drill unlock**: "You can now dig upward!"

### Alternative Traversal (MVP)
Without dig-up, players return to surface via:
1. Wall-jumping
2. Player-placed ladders
3. Ropes
4. Teleport scrolls
5. Elevator (late game)

## Decision Record

**Decision**: Implement Option C (Unlock dig-up via Drill)

**Rationale**: 
- Preserves core genre tension in early game
- Provides satisfying progression milestone
- Maintains value of traversal items
- Follows successful precedent (SteamWorld Dig style)

**Status**: APPROVED for implementation

**Implementation Phase**: 
- MVP: No upward digging
- v1.0: Drill tool unlocks upward digging at 500m depth

## Questions Resolved
- [x] Can player dig upward? → Not at start, unlock later
- [x] What unlocks it? → Drill tool
- [x] When? → 500m depth, 50k coins
- [x] How fast? → 50% normal dig speed (harder than down)
