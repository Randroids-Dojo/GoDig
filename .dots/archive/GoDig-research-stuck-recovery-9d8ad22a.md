---
title: "research: Stuck recovery and save reload"
status: closed
priority: 0
issue-type: task
created-at: "\"\\\"2026-01-18T23:39:37.139024-06:00\\\"\""
closed-at: "2026-01-19T00:51:05.976966-06:00"
close-reason: "Documented stuck scenarios, recommended Emergency Rescue + Reload Save dual approach. Created 3 implementation dots: emergency rescue, reload save, and save time HUD indicator."
---

How does player recover if stuck? Questions: What counts as 'stuck'? (no ladders, can't dig up, surrounded) Can player reload last autosave from pause menu? Is there a 'rescue' teleport option? (costs coins or free?) How do we prevent soft-locks? Should there be a 'dig up' ability as last resort? What's the UX for choosing to reload?

---

## Research Findings

### What Counts as "Stuck"?

A player is potentially stuck when ALL of the following are true:
1. **Cannot dig down** (solid unbreakable surface or already at maximum hardness for their tool)
2. **Cannot dig left or right** (walls too hard for current tool)
3. **Cannot wall-jump out** (surrounded by open space or 3+ tile wide shaft)
4. **No ladders/ropes** in inventory
5. **No teleport scrolls** in inventory

**Key Insight**: With wall-jump as a core mechanic (available from start), true "stuck" situations should be rare. Wall-jump allows escape from most shafts if walls exist.

### Prevention Strategies (Design-Level)

1. **Wall-jump is always available** - Player can escape most shafts by wall-jumping
2. **Tunnel width limit** - Players naturally dig 1-2 tile wide tunnels (player-sized)
3. **Dig direction restriction** - No digging up prevents "digging into a pit" scenarios
4. **Ladder quick-slot** - HUD shows ladder count, encourages carrying spares
5. **Inventory warning at 80%** - "Full inventory" warning prompts return before stuck

### Stuck Scenarios Analysis

| Scenario | Likelihood | Prevention | Recovery |
|----------|------------|------------|----------|
| Dug down too far, no wall-jump walls | Very Low | Natural tunnel walls | Emergency Rescue |
| Surrounded by unbreakable blocks | Very Low | Tool tier gating | Rescue or Reload |
| Ran out of ladders in wide cavern | Low | Quick-slot awareness | Emergency Rescue |
| Fell into cave with no exit | Medium | Cave design (always has climbable walls) | Wall-jump |

### Competitive Analysis

**Motherload**: Getting stranded = death (harsh). Fuel management is core tension but frustrating.
**SteamWorld Dig**: Wall-jump solves most stuck issues. Teleporter unlocks later for convenience.
**Terraria**: Rope, grappling hook, recall potions provide multiple escape options.

**Lesson**: Players need at least ONE always-available escape option. Wall-jump serves this role.

---

## Recovery Options Decision

### Option 1: Emergency Rescue Teleport (Recommended)

**Implementation:**
- Always available from pause menu: "Emergency Rescue"
- Teleports player to surface
- **Cost**: Lose current inventory (NOT coins or equipment)
- **Flavor**: "A rescue team found you, but your cargo was too heavy to carry"

**Pros:**
- Always available, never truly stuck
- Has meaningful penalty (inventory loss) but not devastating
- Prevents frustration
- Simple UX

**Cons:**
- Could be "cheesed" to avoid difficult returns

### Option 2: Reload Last Autosave

**Implementation:**
- Pause menu option: "Reload Last Save"
- Returns player to last autosave state (surface return, shop visit, or 2-min auto)
- Warning: "Progress since last save will be lost"

**Pros:**
- Familiar gaming convention
- Clean slate option
- Doesn't feel like a "designed escape hatch"

**Cons:**
- May lose significant progress (10+ minutes)
- Requires robust autosave system
- More technical complexity

### Option 3: Both (Recommended Approach)

**Pause Menu:**
```
[Continue]
[Emergency Rescue] (lose inventory, keep coins)
[Reload Last Save] (lose all progress since save)
[Settings]
[Quit]
```

Player chooses based on situation:
- Just started, little progress? Reload
- Deep with good loot, just stuck? Emergency rescue (keep what you can)
- Just died? Normal respawn handles it

---

## Recommendation

### Primary Recovery: Emergency Rescue
- **Availability**: Always, from pause menu
- **Cost**: Lose all current inventory items (ores, gems, consumables)
- **Keeps**: Coins, equipped tool, backpack, progress/unlocks
- **Message**: "Call for rescue? Your cargo will be left behind."
- **Confirmation**: Yes/No dialog

### Secondary Recovery: Reload Last Save
- **Availability**: Always, from pause menu
- **Warning**: Shows time since last save ("5 minutes ago")
- **Confirmation**: "You will lose all progress since your last save. Continue?"

### Autosave Triggers (Enhanced for Stuck Prevention)
1. Returning to surface
2. Every 60 seconds (background)
3. Before entering a new layer for first time
4. After shop transactions
5. On app background (mobile)

### UX Flow for Stuck Player

```
Player realizes stuck
    |
    v
Opens Pause Menu
    |
    +---> [Emergency Rescue]
    |         |
    |         v
    |     "Call for rescue? All cargo will be lost."
    |         |
    |         +---> [Yes] --> Teleport to surface, clear inventory
    |         +---> [No] --> Return to pause menu
    |
    +---> [Reload Last Save]
              |
              v
          "Last save: 3 minutes ago. All progress since will be lost."
              |
              +---> [Reload] --> Load save, player at last position
              +---> [Cancel] --> Return to pause menu
```

---

## Questions Resolved

- [x] What counts as 'stuck'? → Can't move in any direction AND no traversal items
- [x] Can player reload autosave? → **Yes**, from pause menu with warning
- [x] Is there a 'rescue' teleport? → **Yes**, costs inventory (not coins)
- [x] How do we prevent soft-locks? → Wall-jump core mechanic + Emergency Rescue
- [x] Should there be 'dig up' as last resort? → **No** (breaks core design, drill unlocks at 500m)
- [x] What's the UX for reload? → Pause menu with time-since-save warning

---

## Implementation Tasks Created

1. `implement: Emergency rescue from pause menu` - Teleport + inventory clear
2. `implement: Reload last save from pause menu` - Save state restore
3. `implement: Show time since last save in UI` - For informed reload decision
