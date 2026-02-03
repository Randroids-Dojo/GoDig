# Inventory Tension Systems - Dome Keeper, Spelunky, Darkest Dungeon

> Research on how games create meaningful inventory pressure.
> Last updated: 2026-02-02 (Session 27)

## Executive Summary

Inventory limits are not just about balance - they're **decision-making engines**. The best games make every inventory slot matter, creating moment-to-moment choices about what to keep, what to drop, and when to return. The key insight: **inventory can create tension, force hard decisions, and turn every run into a strategic challenge**.

---

## 1. Dome Keeper's Carrying Capacity System

### Movement Speed Tradeoff

Dome Keeper creates elegant tension through physics:
> "Carrying capacity affects movement speed—heavier loads slow the player, adding a layer of decision-making to how much to harvest per trip."

**The Formula**: Carrying N resources = carry size of N * (N + 1) / 2

This means:
- 1 resource = minimal slowdown
- 5 resources = significant slowdown
- 10 resources = very slow

### Strategic Implications

Players must constantly calculate:
- How many pieces can I carry back?
- Is one more worth the slowdown?
- Should I make multiple trips?

> "Iron typically appears in large clusters, forcing you to calculate how many pieces you can carry back after considering your current top speed and carry load."

### Upgrade Priority

From the community:
> "Priority of reinforcement is mining power > carrying power (up to 2-3) > speed > carrying power."

This shows players value the **ability to get loot** over **ability to carry more loot**. Speed and efficiency matter.

### Physics Exploitation

Pro players discovered:
> "You can move extra resources without actually carrying them, meaning they don't slow you down."

By pushing resources through horizontal shafts, players bypass the weight penalty. This creates emergent gameplay around level layout.

---

## 2. Spelunky's One-Item Limit

### Brutal Simplicity

Spelunky allows only **one carried item at a time**:
> "You can only hold one carried item, meaning you have to juggle weapons, torches, pets, and idols to get multiple to the end of the level."

### Item Categories

| Slot | Limit | Examples |
|------|-------|----------|
| Carried | 1 | Weapons, torches, idols |
| Back | 1 | Jetpack, cape, powerpack |
| Equipped | Various | Passive items |

### Strategic Juggling

Players who want multiple carried items must:
1. Pick up item A
2. Throw item A forward
3. Pick up item B
4. Throw item B forward
5. Return for item A
6. Repeat

This creates intense decision-making:
- Is this shotgun worth juggling?
- Do I drop my torch for this idol?
- Can I safely get both to the exit?

### Design Lesson

> "Grabbing a ledge causes your shotgun to drop."

The game doesn't help you juggle - it makes it harder. Every item is a commitment.

---

## 3. Darkest Dungeon's Loot vs Supplies

### The Two-Resource Problem

Players must balance:
1. **Supplies** (food, torches, shovels) - needed to survive
2. **Loot** (gold, gems, trinkets) - the actual reward

Limited inventory means carrying supplies = less room for loot.

### Value-Per-Slot Calculations

From the community:
> "One Trapezohedron or tapestry is more value per slot than gold or a stack of gems."

Players develop mental hierarchies:
- Rare loot > common loot
- Full stack > partial stack
- Guaranteed value > speculative value

### Dynamic Drop Priority

A common drop priority (first dropped to last kept):
1. Journal pages (lowest value)
2. Extra consumables
3. Low-value gems
4. Low-value trinkets
5. Region-specific supplies you don't need
6. Higher-value stacks
7. Gold/portraits/deeds (highest value)

### The Two-Phase Strategy

> "On the way in, leave curios unopened while keeping supplies. On the way out, collect those curios knowing exactly which supplies you need."

This creates a natural tension arc:
- **Outbound**: Cautious, prepared
- **Return**: Greedy, calculating

---

## 4. Design Principles for Inventory Tension

### Inventory as Risk, Not Storage

From Shifting Sands developers:
> "Inventory could do far more than store items. It could create tension, force hard decisions, and turn every run into a spatial and strategic challenge."

### Two Key Questions

Every pickup should force players to ask:
1. "Can I fit this?"
2. "What am I willing to give up to make it fit?"

### Power vs Loot Tradeoff

> "Powerful gear can open up new combat or traversal options, but every slot it occupies is space that can't be used to haul loot back out."

GoDig equivalent: Carrying ladders means less room for ore.

### Real-Time Inventory Adds Pressure

From Dark Souls and ZombiU:
> "Games make the experience more immersive and difficult by letting the game world keep going while the player interacts with their inventory."

Consider: Should managing inventory in GoDig pause the game? Probably not - maintaining tension is valuable.

---

## 5. Visual Feedback for Inventory Tension

### Inventory Fullness Indicators

| System | Effect | Tension Level |
|--------|--------|---------------|
| Slot counter | "6/8 slots" | Low - informational |
| Color change | Slots turn yellow/red | Medium - warning |
| UI animation | Slots pulse when nearly full | Medium-high - urgent |
| Sound cue | Subtle audio when 1 slot left | High - immediate |
| Movement change | Slower when full | Very high - constant reminder |

### Progressive Tension

Best practice: escalate feedback as capacity fills:
- 0-50% full: Normal
- 50-75% full: Subtle color shift
- 75-90% full: Warning indicator
- 90-100% full: Urgent feedback, can't pick up more

---

## 6. GoDig Inventory Tension Design

### Current System Reminder
- 8 starting slots (upgradeable to 30)
- Ores stack (same type)
- Ladders take inventory space

### Tension Points to Leverage

| Situation | Tension Created | Player Decision |
|-----------|-----------------|-----------------|
| Full inventory, ore ahead | "Do I drop something?" | Value comparison |
| Nearly full, unsure of path | "Do I return now or risk?" | Push-your-luck |
| Carrying ladders = less ore room | "Safety vs reward" | Risk management |
| Rare ore found, no room | "What's expendable?" | Prioritization |

### Visual Feedback Recommendations

**Slot Display**:
- Show current/max prominently
- Color shift: Green (plenty) → Yellow (half) → Orange (nearly full) → Red (full)

**Full Inventory**:
- Brief screen flash when trying to pick up with no room
- Ore floats above player (can't be collected)
- Subtle audio "can't carry" cue

**Weight/Speed (Optional)**:
- Consider Dome Keeper pattern: more items = slightly slower?
- Creates additional tension layer
- May be too complex for mobile

### Meaningful Drop Decisions

When player must drop:
- Show value comparison (what you'd drop vs what you'd gain)
- Don't auto-drop - make player choose
- Allow quick "swap" gesture

### Return Trigger

Full inventory should be a **natural stopping point**:
> "Just fill inventory then stop" mindset

Make the moment of "inventory full" feel like:
- Accomplishment (you found enough!)
- Decision point (return or push deeper?)
- Not frustration (you couldn't carry more)

---

## 7. Advanced Patterns

### Spatial Inventory (Resident Evil 4)

Items have shapes, creating puzzle-like management:
> "Briefcase system added puzzle-like mechanic, rewarding players who maximized space."

**GoDig Consideration**: Probably too complex for mobile mining game. Slots are simpler.

### Separate Slot Types

Some games use multiple inventory spaces:
- Ore slots (main resource)
- Tool slots (ladders, ropes)
- Equipment slots (pickaxe, upgrades)

This prevents tools from competing with resources.

### Auto-Stack vs Manual

- **Auto-stack**: Less management, more streamlined
- **Manual stack**: More control, more friction

For mobile, auto-stack is probably right.

---

## Sources

- [Dome Keeper General Strategy (Steam)](https://steamcommunity.com/sharedfiles/filedetails/?id=2869939597)
- [Dome Keeper Engineer Wiki](https://domekeeper.wiki.gg/wiki/Engineer)
- [Spelunky 2 Items (Fandom)](https://spelunky.fandom.com/wiki/Spelunky_2:Items)
- [Darkest Dungeon Inventory Management (Steam)](https://steamcommunity.com/app/262060/discussions/0/1471966894882530892/)
- [Darkest Dungeon Loot Priority (Steam)](https://steamcommunity.com/app/262060/discussions/0/3037102935216708380/)
- [Designing Inventory as Risk (IndieDB)](https://www.indiedb.com/games/shifting-sands/features/designing-inventory-as-risk-not-storage)
- [Inventory Management Game Design (Number Analytics)](https://www.numberanalytics.com/blog/ultimate-guide-inventory-management-game-design)
- [Cogmind Inventory Management](https://www.gridsagegames.com/blog/2014/12/inventory-management/)

---

## Key Takeaways for GoDig

1. **Inventory creates tension**: Not just storage - decision engine
2. **Full = natural stop**: Moment of accomplishment and choice
3. **Value comparisons**: Help players understand drop decisions
4. **Progressive feedback**: Escalate warnings as capacity fills
5. **Ladders compete with ore**: Built-in risk/reward tradeoff
6. **Consider speed penalty**: Dome Keeper pattern (more = slower)
7. **Don't auto-drop**: Make player choose what to lose
