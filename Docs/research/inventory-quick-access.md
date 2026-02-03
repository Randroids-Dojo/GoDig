# Inventory Quick Access Patterns for Mobile Action Games

> Research on how action games handle inventory management without breaking flow, with specific focus on mobile touch patterns.
> Last updated: 2026-02-03

## Executive Summary

Mobile action games face a unique challenge: players need fast access to items without losing combat/exploration momentum. The best solutions combine **spatial memory** (radial menus, fixed hotbars), **minimal taps** (quick access buttons, auto-use), and **touch-optimized gestures** (swipes, holds). For GoDig's mining context, the key is making ladder placement and ore management feel instantaneous.

---

## 1. Quick Access Patterns by Game

### 1.1 Terraria Mobile

Terraria's mobile port faced the challenge of adapting a complex PC inventory for touch.

**Key Patterns:**
- **Hotbar at screen bottom**: 10 slots always visible, tap to select
- **Quick Stack button**: Instantly moves matching items to nearby chests
- **Deposit All / Loot All**: One-tap bulk inventory operations
- **Pinch-to-zoom**: Navigate large inventories without scrolling

**What Works:**
- Hotbar provides instant access to most-used items
- Bulk operations reduce tedious item management
- Touch-friendly: large tap targets, minimal precision needed

**What's Tricky:**
- Full inventory requires pause/modal
- Crafting menu navigation is complex on small screens

### 1.2 Minecraft Mobile (Bedrock)

**Key Patterns:**
- **Persistent hotbar**: 9 slots at bottom, always visible during gameplay
- **Swipe to switch**: Drag finger across hotbar to change selection
- **Auto-jump**: Reduces need for jump button, frees touch zone
- **Quick craft**: Recently crafted items appear in sidebar

**What Works:**
- Hotbar is immediately accessible during action
- Swipe-to-switch is faster than tapping individual slots
- Clear visual feedback on selected item

**Design Insight:**
> "The hotbar is the player's action palette - it should contain tools for the current activity, not storage overflow."

### 1.3 Don't Starve: Pocket Edition

**Key Patterns:**
- **Two equipment slots**: Chest slot (backpack OR armor) and hand slot
- **Quick recraft button**: "R3" equivalent for touch - replays last craft
- **Context actions**: Green button adapts to nearby objects
- **Backpack as equipment**: Storage competes with defense

**What Works:**
- Minimal slots = minimal management
- Context-sensitive actions reduce button clutter
- Trade-off design (backpack vs armor) creates interesting choices

**Touch Issues:**
- Backpack juggling can freeze controls if inventory is opened simultaneously
- Joystick + action button timing requires practice

### 1.4 Stardew Valley Mobile

**Key Patterns:**
- **Toolbar at top**: 12 slots (expandable to 36 total inventory)
- **Tap-to-move + auto-attack**: Reduces need for action buttons
- **Organize button**: Auto-sorts inventory by type
- **Hold-to-split**: Long press on stack shows quantity popup

**What Works:**
- Tap-to-move eliminates joystick complexity
- Auto-attack removes combat button during mining
- Quantity popup prevents accidental full-stack drops

**Pain Points:**
- "Touch controls need rework - holding action buttons instead of tapping repeatedly"
- Hoe/watering can sometimes skip tiles

### 1.5 Zelda Series (Item Wheels)

**Key Patterns:**
- **Radial wheel**: Hold button, drag to item, release to equip
- **D-pad quick slots**: 4 items assigned for instant access
- **Separate equipment categories**: Weapons, shields, bows, armor
- **Favorites system**: Mark items to prevent selling/discarding

**What Works:**
- Radial menus leverage muscle memory (spatial recall)
- Quick slots for most-used items avoid menu entirely
- Favorites protect valuable items from accidents

**Touchscreen Adaptation:**
- 3DS Zelda used bottom screen for instant item switching
- "Using the touch screen to allow for faster inventory management" was a key selling point

---

## 2. Design Principles for Quick Access

### 2.1 The "Thumb Zone" Rule

Mobile screens have ergonomic constraints:

```
      Hard to reach
    ┌─────────────────┐
    │   X   X   X     │  <- Corners require hand repositioning
    │                 │
    │   Natural Zone  │  <- Arcs from thumb base
    │   ┌─────────┐   │
    │   │  Thumb  │   │
    │   │  Reach  │   │
    └───┴─────────┴───┘
       Right-handed grip
```

**Quick access controls should live in the natural thumb arc**, not corners.

### 2.2 Three Tiers of Access

| Tier | Access Time | Examples | GoDig Application |
|------|-------------|----------|-------------------|
| **Instant** | 0 taps | Auto-use, passive effects | Auto-pickup ore |
| **Quick** | 1 tap | Hotbar, quick button | Ladder quick-place |
| **Full** | 2+ taps | Full inventory modal | Sell interface |

**Design Goal:** Put frequent actions in Tier 1-2, rare actions in Tier 3.

### 2.3 Radial Menu Advantages

From touch UI research:

> "Radial menus are great for quickly navigating common interactions. It's easier to recall the angle of a gesture than anticipate the exact point on screen."

**Benefits:**
- Muscle memory: "Up is always health, right is always weapon"
- Works during action: Hold to open, release to select
- Compact: Many options in small screen space

**Limitations:**
- Hard to read if options aren't aligned
- Complex hierarchies don't work well
- Requires hold-and-drag gesture

### 2.4 Context-Sensitive Quick Access

Instead of showing all items, show only relevant ones:

| Context | Quick Action |
|---------|--------------|
| At pit edge | "Place Ladder" button appears |
| Inventory nearly full | "Quick Sell" button pulses |
| Near shop NPC | "Sell All" overlay |
| In cave | "Light Torch" if dark |

This reduces cognitive load and button clutter.

---

## 3. Full Inventory Handling Patterns

### 3.1 Game World Response During Inventory

| Pattern | Description | Tension Level |
|---------|-------------|---------------|
| **Pause** | Game stops completely | Low - strategic planning |
| **Slow-motion** | Game slows (DOOM, Dishonored) | Medium - urgent choices |
| **Real-time** | Game continues (Dark Souls, ZombiU) | High - risky management |

**GoDig Consideration:** Mining doesn't have immediate threats, so **pause is fine** for full inventory. But consider real-time for deep biomes with hazards.

### 3.2 Inventory Full Scenarios

When inventory is full, games handle it differently:

| Approach | UX | Player Decision |
|----------|----|--------------------|
| **Block pickup** | "Inventory full" message | Leave item or drop something |
| **Auto-drop oldest** | Oldest item falls | Automatic, may lose good items |
| **Auto-sell lowest** | Cheap items sold | Convenient but removes agency |
| **Swap prompt** | "Replace X with Y?" | Informed choice, interrupts flow |
| **Overflow pocket** | Temporary extra slot | Forgiving, delays decision |

**Best Practice for GoDig:**
1. Visual warning at 75% capacity
2. Audio cue at 90% capacity
3. Block new pickups at 100% with swap option
4. Never auto-drop valuable items

### 3.3 Favorites/Protection System

Zelda and many RPGs allow marking items as "favorites":

> "The ability to mark items as 'favorites' to prevent being junked, sold, or tossed away will save a lot of frustration."

**Implementation:**
- Long-press item to toggle "protected" status
- Protected items skipped in "sell all" operations
- Visual indicator (star, lock icon) on protected items

---

## 4. GoDig-Specific Quick Access Design

### 4.1 Current State

GoDig has:
- 8 inventory slots (upgradeable to 30)
- Full inventory panel (modal, pauses game)
- Inventory button in HUD
- Ladders take inventory space (compete with ore)

### 4.2 Proposed Quick Access Features

#### A. Ladder Quick-Place Button

**Problem:** Opening inventory to use a ladder breaks flow.

**Solution:** Context-sensitive "Place Ladder" button.

```
Normal HUD:               Near pit/cliff:
┌──────────────────┐     ┌──────────────────┐
│       [INV]      │     │  [LADDER] [INV]  │
│                  │     │                  │
│  [JOY]    [JUMP] │     │  [JOY]    [JUMP] │
└──────────────────┘     └──────────────────┘
```

**Rules:**
- Button appears when:
  - Player has ladders in inventory
  - Standing at edge of pit OR wall
- Single tap places ladder in appropriate direction
- Button shows count: "x5"

#### B. Quick-Sell Gesture

**Problem:** Full inventory requires returning to surface, opening shop, confirming sell.

**Solution:** Quick-sell from anywhere (with penalty).

| Method | Coins Earned | Convenience |
|--------|--------------|-------------|
| Surface shop | 100% value | Must travel |
| Quick-sell from mine | 80% value | Instant, anywhere |
| Auto-sell overflow | 70% value | Automatic (optional setting) |

**Implementation:**
- Swipe-up on inventory icon = quick sell menu
- Shows total value and "Sell for $X (80%)" button
- Or toggle in settings: "Auto-sell when full"

#### C. Inventory Fill Indicator

**Current:** "6/8" text in HUD

**Enhanced:**
```
Almost empty:     Half:           Nearly full:     FULL:
[░░░░░░░░] 1/8   [████░░░░] 4/8  [███████░] 7/8  [████████] 8/8
  (gray)           (green)        (yellow)         (red, pulse)
```

Plus haptic feedback when reaching 75%, 90%, 100%.

#### D. Ore Stacking Optimization

**Problem:** Common ore (coal, stone) fills slots fast.

**Solution:** Auto-compress stacks button.

- "Compress" button in inventory combines partial stacks
- Result: Fewer slots used, more room for variety

Example:
```
Before:  [Coal x45] [Coal x32] [Iron x10]  (3 slots)
After:   [Coal x77] [Iron x10]             (2 slots)
```

### 4.3 Hotbar Consideration

**Question:** Should GoDig have a persistent hotbar?

**Pros:**
- Instant access to ladders, torches
- Visual reminder of carried items
- Familiar pattern from Minecraft/Terraria

**Cons:**
- Screen space on mobile is precious
- GoDig has simpler item set than Minecraft
- Current "context button" approach may suffice

**Recommendation:** Start with context-sensitive quick buttons. Add hotbar only if playtest shows demand.

---

## 5. Touch Gesture Patterns

### 5.1 Recommended Gestures for GoDig

| Gesture | Action | Rationale |
|---------|--------|-----------|
| Tap inventory icon | Open full inventory | Standard |
| Long-press inventory icon | Show quick stats (slots, value) | Info without opening |
| Swipe up on inventory icon | Quick-sell menu | Fast sell flow |
| Tap ladder quick-button | Place ladder at feet | One-tap placement |
| Hold ladder button + drag | Aim ladder placement | Precise control |

### 5.2 Gestures to Avoid

| Gesture | Problem |
|---------|---------|
| Multi-finger pinch | Conflicts with zoom expectations |
| Edge swipes | May trigger OS navigation |
| Double-tap | Too slow for action contexts |
| Complex patterns | Hard to discover/remember |

---

## 6. Implementation Priorities

### Phase 1 (MVP Enhancement)
1. Ladder quick-place button (context-sensitive)
2. Enhanced inventory fill indicator (progress bar + colors)
3. "Sell All" button in inventory panel

### Phase 2 (Post-Launch)
4. Quick-sell from mine (80% value)
5. Auto-sell toggle in settings
6. Stack compression button
7. Favorites/protected items

### Phase 3 (If Demanded)
8. Persistent hotbar option
9. Radial wheel for tool switching
10. Gesture customization

---

## 7. Key Takeaways

1. **Thumb zone matters**: Put quick-access in comfortable reach
2. **Context beats complexity**: Show relevant actions, not all actions
3. **Tiers of access**: Instant (auto) > Quick (1 tap) > Full (modal)
4. **Protect player investments**: Favorites system, confirmation for drops
5. **Visualize capacity**: Progress bar + color + haptics for inventory state
6. **Ladder quick-place is critical**: Most used item needs fastest access

---

## Sources

- [Game UI Database - Mobile Controls](https://www.gameuidatabase.com/index.php?scrn=147)
- [Microsoft Touch Controls Guide](https://learn.microsoft.com/en-us/gaming/gdk/docs/features/common/game-streaming/building-touch-layouts/game-streaming-tak-designers-guide)
- [Radial Menus for Touch UI](https://bigmedium.com/ideas/radial-menus-for-touch-ui.html)
- [Acagamic: Video Game Inventory UX Design](https://acagamic.com/newsletter/2023/03/21/how-to-unlock-the-secrets-of-video-game-inventory-ux-design/)
- [Stardew Valley Mobile Controls Wiki](https://stardewvalleywiki.com/Mobile_Controls)
- [Don't Starve: Pocket Edition Wiki](https://dontstarve.wiki.gg/wiki/Don't_Starve:_Pocket_Edition)
- [Terraria Mobile Wiki - Game Controls](https://terraria.wiki.gg/wiki/Game_controls)
