# Inventory Weight vs Slot Systems Research

## Overview

Comparison of weight-based versus slot-based inventory systems for mining games. Understanding trade-offs, mobile UI considerations, and how inventory design affects the mining game loop.

## Weight-Based Systems

### How It Works

Player has a **weight capacity** (e.g., 100 kg). Each item has weight. When total weight exceeds capacity, player is **encumbered** (slowed or stopped).

### Pros

| Advantage | Why It Matters for Mining |
|-----------|---------------------------|
| Physicality | Ore feels heavy, paper feels light |
| Immersion | "Mentally feel the weight" of valuable ore |
| Natural progression | Strength upgrades = carry more |
| Decision-making | Valuable heavy vs. light common |

**Immersion Quote:**
> "In Fallen Earth, players were keenly aware that picking up ore and picking up paper weren't the same thing. One had much more carry weight, which made it more real to them."

### Cons

| Disadvantage | Why It's Problematic |
|--------------|----------------------|
| Tedious management | Constant weight checking |
| Interrupts flow | Must return to offload frequently |
| Character penalty | Low-strength builds suffer |
| Complex math | Players must calculate capacity |

**Frustration Quote:**
> "Weight-based systems can be annoying if you're stuck somewhere and have to keep juggling items to avoid being overencumbered."

### Mining Game Examples

**Dome Keeper (Weight + Movement Speed):**
- Carrying N resources = slowdown
- Formula: `slowdown = 0.01 × speedLossPerCarry × (N × (N+1) / 2)`
- Creates tension: "Do I grab more and move slow, or take less and move fast?"
- Resource line breaks if longer than 6 blocks (drop)

**Pro players exploit physics:**
> "Push resources instead of carrying them to not be slowed down."

## Slot-Based Systems

### How It Works

Player has **X slots** (e.g., 20 slots). Each item takes 1 slot. Items stack within slots (e.g., 99 coal per slot).

### Pros

| Advantage | Why It Matters for Mining |
|-----------|---------------------------|
| Simple | Easy to understand |
| Visual | Can see everything at once |
| Mobile-friendly | No calculations needed |
| Stack clarity | "5/20 slots used" is clear |

**Simplicity Quote:**
> "Slots are preferred when players can see everything they need in one screen without hassle."

### Cons

| Disadvantage | Why It's Problematic |
|--------------|----------------------|
| Less immersion | Diamond weighs same as dirt |
| Arbitrary limits | Why can't I carry 21 items? |
| Stack management | Different stack limits confuse |
| Tetris problem | Grid-based = spatial puzzles |

### Mining Game Examples

**SteamWorld Dig (Slot + Capacity):**
- Bag holds limited minerals
- Capacity upgradable
- Forces surface returns
- Simple, clear system

**Terraria (Slot + Stack):**
- 50 inventory slots
- 9999 items per stack (desktop/mobile)
- Mobile-specific UI adaptations
- Split button for stack management

## Hybrid Systems

### Motherload (Fuel + Cargo)

**Design:**
- Fuel limits mining time (depletes)
- Cargo bay limits minerals (slots)
- Both upgradable
- "Portable Wormhole" = unlimited storage

**Tension:** Balance fuel vs. cargo trips.

### Dome Keeper (Weight + Time)

**Design:**
- Weight slows movement
- Time pressure from waves
- Gadgets modify system (elevator, teleporter)
- "Resource Packer" merges resources

**Tension:** Efficiency under time pressure.

## Mobile UI Considerations

### The Terraria Mobile Solution

**Problem:** Desktop inventory too complex for touch screens.

**Solution:**
- Split inventory across tabs
- Separate screens for: inventory, crafting, equipment, chest, housing
- Touch delay to distinguish drag vs. scroll
- Split button for stack management
- Hotbar configurable (left column or top row)

### Mobile Inventory Best Practices

| Principle | Implementation |
|-----------|----------------|
| Large touch targets | Bigger slots than desktop |
| Minimal calculations | Avoid weight math |
| Clear capacity | "8/20 slots" visible |
| Quick actions | One-tap sell all |
| Auto-organization | Sort and stack buttons |

### Touch Gesture Challenges

> "It took iteration to discriminate between 'dragging an item with your finger' versus 'scrolling the inventory.'"

**Solutions:**
- Long-press to pick up item
- Swipe to scroll inventory
- Double-tap for quick actions

## What Creates Tension?

### Inventory-as-Pressure

The core mining loop requires return trips. Inventory limits create:

1. **Decision moment:** "Is this worth carrying back?"
2. **Risk/reward:** "Do I push deeper with full inventory?"
3. **Efficiency puzzle:** "What's the optimal load?"
4. **Progression hook:** "I need bigger inventory"

### What Doesn't Work

| Anti-Pattern | Why It Fails |
|--------------|--------------|
| Too restrictive | Constant interruption |
| Too generous | No pressure, no returns |
| Complex math | Tedious, not fun |
| Hidden limits | Surprise "inventory full" |

## Recommendations for GoDig

### Chosen System: Slot-Based

**Why Slots Over Weight:**
1. Mobile-friendly (no math)
2. Visual clarity (see all items)
3. Simple progression (add slots)
4. Consistent experience (ore = 1 slot)

### Slot Configuration

**Default (New Player):**
- 8 slots
- Stack limit: 50 per slot

**Upgraded (Mid-game):**
- 15-20 slots
- Stack limit: 99 per slot

**Max (Late-game):**
- 30 slots
- Stack limit: 99 per slot

### Stack Limits by Type

| Item Type | Stack Limit | Reasoning |
|-----------|-------------|-----------|
| Common ore (coal, copper) | 99 | Bulk collection |
| Rare ore (gold, platinum) | 50 | More valuable |
| Very rare ore (diamond) | 25 | Precious |
| Consumables (ladders) | 50 | Balance |
| Special items (artifacts) | 1 | Unique |

### UI Design

**Inventory Panel:**
```
┌─────────────────────────────┐
│ Inventory (12/20)    [Sort] │
├─────────────────────────────┤
│ [Coal 45] [Iron 23] [Gold 5]│
│ [Empty]   [Empty]   [Ladder]│
│ [Empty]   [Empty]   [Empty] │
└─────────────────────────────┘
```

**Key Features:**
- Slot count visible (12/20)
- Stacks shown with count
- Sort button auto-organizes
- Tap item for details
- Long-press for quick actions

### Inventory Full Moment

**Current Implementation:** Already has `InventoryFullPopup`

**Enhance With:**
- Warning at 80% capacity
- Visual indicator (slots turning yellow/red)
- Options: Continue, Return, Forfeit Cargo

### Alternative: Weight-Adjacent Pressure

**Consider for v1.1:**
- Movement speed reduction when inventory nearly full
- Not weight calculation, just "heavy" feeling
- Visual: player animation slows
- Audio: footstep sounds change

**Implementation:**
```gdscript
var fullness_ratio = inventory_count / max_inventory
if fullness_ratio > 0.8:
    movement_speed *= lerp(1.0, 0.75, (fullness_ratio - 0.8) / 0.2)
```

## Comparison Table

| Aspect | Weight System | Slot System | GoDig Choice |
|--------|---------------|-------------|--------------|
| Complexity | High | Low | Slot (simple) |
| Mobile-friendly | No | Yes | Slot |
| Immersion | High | Medium | Slot + speed hint |
| Math required | Yes | No | Slot |
| Visual clarity | Low | High | Slot |
| Decision depth | High | Medium | Slot + other pressures |

## Final Recommendation

**Use slot-based inventory** with:
1. Clear slot count display
2. Item stacking (variable limits by rarity)
3. 80% warning
4. Optional movement slowdown at 90%+
5. Upgradable capacity (8 → 30)

**Tension comes from:**
- Depth pressure (further = harder return)
- Time pressure (not fuel, but natural desire)
- Decision moments (full inventory popup)
- Stack management (rarer = smaller stacks)

## Sources

- [Giant Bomb Forums - Weight or Slot Based Inventory](https://www.giantbomb.com/forums/general-discussion-30/weight-or-slot-based-inventory-554481/)
- [GameDev.net - Inventory Management Mechanics](https://www.gamedev.net/forums/topic/669987-inventory-management-mechanics/)
- [GameDev.net - Inventory System Design](https://www.gamedev.net/forums/topic/629977-inventory-system-design/4972640/)
- [Bio Break - Does Inventory Weight Help RPG Immersion?](https://biobreak.wordpress.com/2020/05/19/does-inventory-weight-help-rpg-immersion/)
- [Number Analytics - Inventory Management in Game Design](https://www.numberanalytics.com/blog/ultimate-guide-inventory-management-game-design)
- [TV Tropes - Motherload](https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/Motherload)
- [Medium - SteamWorld Dig Review](https://medium.com/@KlaraMelinaca/steam-world-dig-review-3558033741b8)
- [Dome Keeper Wiki - Engineer](https://domekeeper.wiki.gg/wiki/Engineer)
- [Josh Anthony - Design Dive: Dome Keeper](https://joshanthony.info/2023/05/24/design-dive-dome-keeper/)
- [Terraria Wiki - Inventory](https://terraria.wiki.gg/wiki/Inventory)
- [Medium - Making of Terraria Mobile Part 3](https://medium.com/@watsonwelch/the-making-of-terraria-mobile-part-3-crafting-a-new-ui-4fb84708c767)

## Related Implementation Tasks

- `implement: Inventory tension visual system` - GoDig-implement-inventory-tension-30865491
- `implement: Thumb zone HUD layout optimization` - GoDig-implement-thumb-zone-f42518bd
- Existing: `InventoryFullPopup` and `InventoryManager`
