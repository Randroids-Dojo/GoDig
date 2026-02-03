# Resource Management Anxiety and Hoarding Psychology in Mining Games

*Research Session 26 - Consumable Psychology*

## Overview

The "Too Good to Use" syndrome (also called "Hoarder Syndrome") is a well-documented design problem where players save consumable items indefinitely instead of using them. In mining games like GoDig, this affects ladder usage, teleport scrolls, and other escape items.

## The Psychology of Hoarding

### Why Players Hoard

From [Game Wisdom - Combating the Hoarding Syndrome](https://game-wisdom.com/critical/hoarding-game-design):

> "Players will refuse to use life-saving items and instead hoard them for some time in the future... This typically stems from the player being afraid that using the item too soon will be wasteful, so they save the item until later when it will be more beneficial. This often results in the item never being used at all, so it ironically ends up being wasted in a different way."

### Core Causes

| Cause | Psychology | Example |
|-------|-----------|---------|
| **Scarcity anxiety** | "What if I need this later?" | Saving potions for boss fights |
| **Past trauma** | Burned by past item waste | Lost game because used item too early |
| **Economy mistrust** | Don't know item's true value | Uncertain if item is replaceable |
| **Completion mindset** | Want to finish with full inventory | Items feel like trophies |
| **Dopamine from collecting** | Pleasure from acquiring, not using | "Collecting feels good" |

### The Ironic Consequence

From [TV Tropes - Too Awesome to Use](https://tvtropes.org/pmwiki/pmwiki.php/Main/TooAwesomeToUse):

> "Players often held on to such consumables for far too long, resulting in otherwise survivable situations being lost because players were refusing to use their items in case they would need it later."

The item meant to save the player becomes useless because they're too afraid to spend it.

## Case Study: Resident Evil's Ink Ribbons

### The Design

From [Steemit - Resident Evil & The Horror of Saving](https://steemit.com/gaming/@arjendesign/resident-evil-and-the-horror-of-saving-as-a-limited-resource):

> "Ink Ribbons are a resource you need to find, put in your inventory and take with you just like bullets and healing items. And once you've used them, they're gone."

### Tension vs Frustration

> "The Ink Ribbons really are a double-edged sword... The fear of losing your progress and the frustration of losing your progress are two sides of the same coin."

**Key insight**: Scarcity creates tension, but too much scarcity creates frustration. The balance point is where players feel the tension but can still succeed.

### Modern Adaptation

Resident Evil abandoned ink ribbons but brought them back as an **optional hardcore mode** - players who want the tension can opt-in, others can play without.

**Lesson for GoDig**: Consider difficulty modes that vary consumable scarcity.

## Case Study: Fire Emblem Permadeath

### Item Loss Amplifies Hoarding

From [Fire Emblem Wiki - Death](https://fireemblemwiki.org/wiki/Death):

When a unit dies, their inventory is lost forever (in early games). This creates double anxiety:
- Fear of losing the character
- Fear of losing equipped items

### Player Response

> "Most players reset and repeat a map rather than let a character die... Fire Emblem is defined by a mechanic that most players refuse to abide by."

Players refuse to accept permanent loss - they reload saves instead. This suggests:
- Permadeath/permanent loss is often circumvented
- Players need escape hatches
- Punishing resource loss too harshly leads to save-scumming

## Design Solutions

### 1. Per-Run Resources (Roguelite Pattern)

From [Gamedeveloper - Avoiding the Hoarder Trap](https://www.gamedeveloper.com/design/avoiding-the-hoarder-trap-in-game-design):

> "Gold is lost upon entering a dungeon and consumable items are lost upon leaving a dungeon for any reason. This causes two interesting side effects: players are incentivized to use consumables as opposed to hoarding them."

**How it works**:
- Items don't carry between runs
- "Use it or lose it" mentality
- No long-term hoarding possible

**For GoDig**:
- Ladders already somewhat work this way (you use them or they stay in inventory)
- Consider "teleport scroll expires after returning to surface"

### 2. Refillable Resources (Dark Souls Pattern)

> "Giving the player a consumable, but infinitely refillable, healing item means every player is on the same page... Running out of Estus is not a game over or a long-term punishment—all the player needs to do is return to a bonfire."

**How it works**:
- Limited per-expedition, but refills at checkpoints
- No permanent loss possible
- Encourages use without waste anxiety

**For GoDig**:
- Ladders could auto-refill when selling at surface
- "You always start with X ladders"

### 3. Plentiful + Cheap

From [ResetEra discussion](https://www.resetera.com/threads/how-would-you-solve-the-consumable-item-hoarding-problem.1382920/):

> "Make potions or consumables plentiful and cheap enough for the player to use during any battle; that way, they're not hoarding expensive items for some late-game disaster."

**For GoDig**:
- Ladders should be cheap enough to buy frequently
- First 30 minutes should teach "ladders are meant to be used"

### 4. Auto-Consumption

> "An 'eating' mechanic where the player stocks up on food that will be consumed at regular intervals automatically... The auto-usage of items avoids the 'need to save for a rainy day' mindset."

**For GoDig**:
- Auto-place ladder when falling into dead-end?
- Automatic rescue when stuck (with penalty)?

### 5. Item Decay/Expiration

> "Making consumables 'decay' over time—like if a health potion doesn't get used in a certain amount of time, it can only heal half of what it could originally."

**For GoDig**:
- Teleport scrolls could "degrade" over time
- Creates urgency to use rather than hoard

### 6. Infinite vs High Number Framing

From [Game Wisdom](https://game-wisdom.com/critical/hoarding-game-design):

> "Even the simple act of saying that an option is unlimited vs. having a huge amount can impact the player's view of an option. Imagine if the Portal gun had 999 uses instead of just being infinite."

**For GoDig**:
- "Unlimited ladder storage" vs "999 ladder max"
- Framing matters for perception

## Encouraging Healthy Resource Use

### Trust Building

From [Rampant Games - RPG Design: Expendable](https://rampantgames.com/blog/?p=6552):

> "Player resistance to using up expendables is often tied to a mistrust of the economy of the game. So many CRPGs have broken economies that players never know the real value of their possessions."

**Solution**: Make the economy transparent and predictable
- Show how much ladders cost
- Show how much ore sells for
- Make exchange rates consistent

### Clear Signaling

Players need to know:
1. **This is when to use it** - "You're stuck, use a ladder"
2. **You can get more** - "Ladders cost 10 coins, you have 50"
3. **Not using it is worse** - "If you die, you lose all cargo"

### Positive Reinforcement

> "Acquiring is often associated with positive emotions... motivating individuals to keep acquiring."

Flip the script: Make **using** items feel good
- Satisfying placement animation for ladders
- "Close call saved!" notification for emergency items
- Celebrate smart resource use, not hoarding

## Application to GoDig

### Current GoDig Resources

| Resource | Hoarding Risk | Current Design |
|----------|---------------|----------------|
| **Ladders** | High | Consumable, requires coins |
| **Teleport Scrolls** | Very High | Rare emergency item |
| **Bombs** | Medium | Situational use |
| **Fuel/Air** | N/A | GoDig doesn't use this |

### Ladder Economy Recommendations

**Problem**: Players might hoard ladders instead of using them, leading to frustration when stuck.

**Solutions**:

1. **Start with ladders** (implemented)
   - 5 starting ladders teaches they're meant to be used

2. **Cheap early ladders**
   - First 30 minutes: ladders very affordable
   - Players learn "I can always buy more"

3. **Ladder warning system**
   - "Low ladders!" creates urgency
   - Shows exact count prominently

4. **Refill on sell**
   - Consider: free ladder refill when selling?
   - Or: bonus ladders with purchases

5. **Ladder capacity upgrade**
   - Bigger capacity = less anxiety about each ladder

### Teleport Scroll Design

**Very high hoarding risk** - rare emergency item

**Anti-hoarding solutions**:

1. **Expiration** - Scrolls expire after X dives
2. **Depth-scaling** - More valuable to use deep (opportunity cost of not using)
3. **Visible supply** - Show in shops "1 available this session"
4. **Automatic use** - Triggers when death is imminent?

### Teaching Resource Use

**First-time use moments**:

1. **Ladder tutorial**
   - Force first ladder placement in safe zone
   - Show "You placed a ladder! Now you can climb back up"

2. **Emergency item tutorial**
   - Create scenario where item use is required
   - Celebrate the use, not the hoarding

3. **Death from hoarding**
   - If player dies with items in inventory, show "You had a teleport scroll..."
   - Gentle teaching moment

## Key Metrics to Monitor

1. **Ladder usage rate** - Are players using ladders or hoarding?
2. **Items on death** - How many consumables unused when player dies?
3. **Scroll usage rate** - Are teleport scrolls ever used?
4. **Purchase patterns** - Do players buy consumables?
5. **Stuck frequency** - Are players getting stuck despite having items?

## Sources

- [TV Tropes - Too Awesome to Use](https://tvtropes.org/pmwiki/pmwiki.php/Main/TooAwesomeToUse)
- [Gamedeveloper - Avoiding the Hoarder Trap in Game Design](https://www.gamedeveloper.com/design/avoiding-the-hoarder-trap-in-game-design)
- [Gamedeveloper - How to Stop Making Hoarders in Video Games](https://www.gamedeveloper.com/game-platforms/how-to-stop-making-hoarders-in-video-games)
- [Game Wisdom - Combating the Hoarding Syndrome](https://game-wisdom.com/critical/hoarding-game-design)
- [Super Jump Magazine - How Hoarding Encourages Bad Game Design](https://www.superjumpmagazine.com/how-hoarding-encourages-bad-game-design/)
- [Rampant Games - RPG Design: Expendable](https://rampantgames.com/blog/?p=6552)
- [ResetEra - How would you solve the consumable item hoarding problem?](https://www.resetera.com/threads/how-would-you-solve-the-consumable-item-hoarding-problem.1382920/)
- [Quora - Solutions to "too good to use" problem](https://www.quora.com/What-is-a-good-solution-to-the-too-good-to-use-problem-in-video-games-wherein-players-hoard-the-best-items-and-weapons-and-never-use-them)
- [Steemit - Resident Evil & The Horror of Saving](https://steemit.com/gaming/@arjendesign/resident-evil-and-the-horror-of-saving-as-a-limited-resource)
- [Fire Emblem Wiki - Death](https://fireemblemwiki.org/wiki/Death)

## Related Implementation Tasks

- `GoDig-implement-low-ladder-e6f21172` - Low ladder warning
- `GoDig-give-player-2-8f4b2912` - 5 starting ladders
- `GoDig-implement-quick-buy-1f33cfbe` - Quick-buy ladder shortcut
- `GoDig-dev-teleport-scroll-1403d2d4` - Teleport scroll item
