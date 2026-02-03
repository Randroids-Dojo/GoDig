# Visual Hierarchy and Attention Guidance in Dense UIs

> Research into how games guide player attention in complex interfaces without overwhelming them, especially on mobile where screen real estate is limited.

## Executive Summary

Effective visual hierarchy in games follows a clear priority: **critical information dominates**, secondary information remains accessible but unobtrusive, and visual clutter is aggressively minimized. The best mobile game UIs communicate state changes through animation, color, and position rather than adding more elements. Players can process familiar patterns 30% faster - consistency enables split-second decisions.

**Key Insight for GoDig**: Our HUD must balance multiple information types (depth, health, inventory, coins, ladder count) in portrait mode. Following the Z-pattern and using animation for state changes will be crucial.

---

## Core Principles of Visual Hierarchy

### The Three-Tier Priority System

| Priority | Information Type | Visual Treatment | GoDig Examples |
|----------|-----------------|------------------|----------------|
| **Primary** | Critical/urgent | Large, bright, animated | Low health, low ladders, death imminent |
| **Secondary** | Persistent stats | Medium, subtle | Current depth, coin count, inventory status |
| **Tertiary** | Contextual | Hidden until relevant | Ore values, tool stats, settings |

### The Z-Pattern for HUD Layout

Players naturally scan screens in a Z pattern:
1. **Top-left**: Start point (health, primary stat)
2. **Top-right**: Secondary persistent info (coins, resources)
3. **Center**: Gameplay focus (keep clear)
4. **Bottom**: Temporary prompts, contextual info

For mobile portrait mode, this becomes more of an **inverted T**:
- Top: Persistent stats (smaller, out of thumb zone)
- Middle: Gameplay (maximum clear space)
- Bottom: Touch controls and contextual actions (thumb accessible)

---

## Mobile-Specific Constraints

### Screen Real Estate vs Information Density

Mobile games face a fundamental tension: players need information, but screens are small and fingers obscure content.

**Key findings from 2025 research**:
- 27% of players over 50 stopped playing games due to "overwhelming interfaces"
- Mobile players have "limited attention span" due to on-the-go play
- Touch screens require larger hit targets than mouse interaction
- Portrait mode preferred for casual/one-handed play

### The "Glance Test"

Mobile UI should pass the 3-second glance test:
- Can player immediately see their critical status?
- Are danger states obvious without reading text?
- Is the gameplay area unobstructed?

---

## Case Study: Dead Cells - Clarity Through Options

Dead Cells demonstrates that visual clarity can be **player-customizable** rather than one-size-fits-all.

### What They Do Right

**Status Effect Clarity**:
- Effect icons displayed in item descriptions
- Synergizing effects glow when they work together
- Critical strike feedback on HUD (with option to reduce intensity)
- Color coding applies consistently across HUD, menus, icons, and items

**Accessibility Options**:
- Outlines for player, enemies, skills, projectiles, and secrets
- Adjustable text size for item names, descriptions, and dialogues
- Adjustable HUD size
- Optional colored filter between background and foreground

### What Caused Problems

Some players felt item descriptions took up "half the screen" and scroll menus prevented seeing everything at once. The lesson: **information density has diminishing returns** - at some point, more info creates more confusion.

### GoDig Application

| Dead Cells Feature | GoDig Adaptation |
|-------------------|------------------|
| Synergy icon glow | Highlight items that combo with equipped pickaxe |
| Customizable outlines | Optional ore highlight toggle |
| HUD size slider | Accessibility menu with HUD scaling |
| Color override | Consistent color language across all UI |

---

## Case Study: Vampire Survivors - Managing Intentional Chaos

Vampire Survivors presents an extreme case: the game's appeal includes visual chaos, yet must remain playable.

### The Chaos Problem

"One of the greatest features of Vampire Survivors is the amount of chaos that occurs as players survive longer. Equipping and combining certain weapons and abilities can cause a lot of particles to clutter the screen."

Players report:
- "Very hard to see what is going on/enemies/barriers"
- Frame rate drops from visual overload
- Character getting "lost" in particle effects

### Their Solutions

**In-game options**:
- Disable flashing VFX
- Disable moving backgrounds
- Particle reduction settings

**Community mods** (indicating unmet needs):
- "No Particles mod" for performance
- "VSTweaks" to turn off weapon particle alpha
- Manual "wipes" to clear visual clutter

### GoDig Relevance

While GoDig won't have Vampire Survivors-level chaos, mining effects can accumulate:
- Multiple blocks breaking
- Ore discovery celebrations
- Falling debris
- Depth milestone notifications

**Lesson**: Provide particle/effect density options and cap simultaneous effects.

---

## Case Study: Slay the Spire - Information Density Challenge

Slay the Spire demonstrates both successes and failures in dense information presentation.

### Mobile Port Issues

"The Android screen isn't optimized for easy readability, so Slay the Spire's text-rich design requires some strain or effort to read."

"Right from the get-go, players are thrown into a world populated with tons of often inscrutable icons, all of which are meaningful."

"Highlighting a card to read it during combat makes it hard to highlight a different card. There is a real possibility of accidentally playing one while simply trying to read it."

### What Works

**Information hierarchy principles**:
- Critical information (health, energy, threats) dominates visual space
- Secondary info (deck count, discard) accessible but not distracting
- Immediate feedback while maintaining visual appeal

**Community solutions** (EUI mod):
- Quick filters for finding card/relic information
- Reduced search friction for experienced players

### GoDig Application

For our inventory and shop screens:
- **Large touch targets**: Cards/items should be big enough to tap without precision
- **Avoid info overlap**: Don't require highlighting one item to read while browsing
- **Progressive detail**: Show summary by default, tap for full description
- **Consistent iconography**: Once learned, icons should work across all contexts

---

## Case Study: Loop Hero - Minimalism as Design Philosophy

Loop Hero takes a radically minimal approach to HUD design.

### Design Philosophy

"A minimalist and retro Role-Playing and Strategy game incorporating elements of multiple other genres to create a unique gaming experience."

"Hands-off approach to combat, where players cannot directly control their hero's actions, is seen as a core mechanic that requires strategic card placement and resource management."

### Information Presentation

- **Day progress bar**: Simple indicator of loop cycle
- **Clean loop map**: Visual clarity in the circular path
- **Card-based interaction**: All complexity happens through card placement, not HUD reading
- **Retro aesthetic**: Pixel graphics naturally limit detail density

### GoDig Lesson

**Consider what information is actually needed**:
- Does the player need to see exact health numbers, or is a bar sufficient?
- Does depth need to be precise, or can it be approximate until hovering?
- Can ore values be shown only when relevant (near shop)?

---

## Case Study: Marvel Snap - Animation as Communication

Marvel Snap demonstrates how animation can communicate state changes more effectively than static UI.

### Visual Design Philosophy

"A key visual theme of all the UI in Snap is that of dark 'piano glass,' and buttons and other UI elements are made of light being projected as holograms."

"The location borders and power gems glow in the direction of the winning player to help communicate the current winner of a location."

### Animation as Information

Instead of adding more HUD elements, Marvel Snap uses animation:
- **Frame-breaking characters**: Cards "bust out" of frames to feel alive
- **Directional glows**: Indicate winning side without text
- **Simplified bottom HUD**: Dense information presented concisely
- **3-minute game length**: Designed for mobile attention spans

### Mobile-First Principles

"Giant play button when you load up the game."
"Players might not be giving it their full attention."
"Testing on actual mobile devices is important since touch screens have quirks."
"Portrait mode is the recommended approach—don't force players to turn their device."
"Vibration feedback can't be felt in the editor" - test on real devices.

### GoDig Application

| Marvel Snap Technique | GoDig Implementation |
|----------------------|---------------------|
| Directional glows | Health bar pulses when low, ladder indicator glows when depleting |
| Frame-breaking | Rare ore discoveries break into larger celebration |
| Simplified HUD | Depth as single number, not detailed breakdown |
| Giant primary action | Large, clear "DIG" touch target |

---

## Notification Stacking Best Practices

When multiple alerts compete for attention, proper stacking prevents chaos.

### Stacking Rules

1. **Newest on top**: Most recent notification appears at top of stack
2. **Age-based ranking**: Oldest alerts at bottom, fill upward as they dismiss
3. **Maximum threshold**: Cap at 3 visible notifications, overflow indicator for more
4. **Automatic timeout**: 4-8 seconds for non-critical toasts
5. **Hover pause**: Don't dismiss while player is reading

### Combining Similar Notifications

"Combine multiple notifications of the same type into a single summary notification showing how many notifications of a particular kind are pending."

Example: Instead of:
- "Found copper ore!"
- "Found copper ore!"
- "Found iron ore!"

Show: "Found 2 copper, 1 iron"

### Reducing Alert Fatigue

"Only send notifications where necessary. Being interrupted creates a frustrating and discouraging experience for users."

"Err on the side of showing fewer notifications... Instead, put them in a list people can access when they want to see them."

### GoDig Notification Types

| Type | Priority | Treatment | Duration |
|------|----------|-----------|----------|
| Low health warning | Critical | Screen edge pulse, center icon | Until resolved |
| Low ladder warning | High | HUD glow, audio cue | Until resolved |
| Ore discovered | Medium | Brief toast, combines with similar | 2 seconds |
| Achievement unlocked | Low | Queued toast, can dismiss | 4 seconds |
| Depth milestone | Low | Brief celebration, non-blocking | 3 seconds |

### Placement Recommendations

- **Desktop**: Right-align toast alerts over content
- **Mobile**: Center toast alerts, stack with 8px padding
- **Avoid corners**: Don't obscure critical HUD elements
- **Test viewports**: Responsive design must work across devices

---

## Color and Contrast Psychology

### Universal Color Associations

| Color | Association | GoDig Use |
|-------|-------------|-----------|
| Red | Danger, low, critical | Low health, damage, hazards |
| Green | Health, positive, go | Health restoration, safe zones |
| Gold/Yellow | Reward, currency, rare | Coins, valuable ores |
| Blue | Information, cold, depth | Depth indicator, water |
| White/Gray | Neutral, common | Standard blocks, menu backgrounds |

### Accessibility Considerations

"27% of players over 50 stopped playing due to overwhelming interfaces."

**Color-blind support**:
- Never rely on color alone - pair with icons or shapes
- Provide color-blind modes (protanopia, deuteranopia, tritanopia)
- Use pattern/texture differences as backup

**Contrast requirements**:
- Text on backgrounds: minimum 4.5:1 contrast ratio
- Interactive elements: clearly distinguishable from static
- State changes: visible through color AND animation

---

## GoDig-Specific Recommendations

### HUD Layout (Portrait Mode)

```
┌─────────────────────────┐
│  HP ████░░░  💰 1,234   │  ← Top bar: persistent stats
│  ⛏️ Tier 3   📏 247m   │
├─────────────────────────┤
│                         │
│                         │
│     [ Gameplay Area ]   │  ← Maximum clear space
│                         │
│                         │
├─────────────────────────┤
│ 🪜 x5  [ Quick Action ] │  ← Thumb zone: ladder count, actions
│   [ Inventory Preview ] │
└─────────────────────────┘
```

### Information Priority

**Always visible**:
- Health bar (with pulse when critical)
- Depth (single number)
- Coins (updating animation on collect)

**On demand**:
- Detailed inventory
- Ore values
- Tool stats

**Contextual**:
- "Hold to mine" prompt when near block
- "Place ladder?" when at gap
- "Return to surface" when inventory full

### Notification System Design

1. **Stack limit**: Maximum 3 simultaneous notifications
2. **Combine similar**: Group ore discoveries
3. **Priority queue**: Critical alerts interrupt, others queue
4. **Consistent position**: Always top-center, below persistent HUD
5. **Dismissal**: Swipe to dismiss, auto-dismiss after timeout

### Animation Guidelines

- **State changes**: Animate transitions, don't just swap values
- **Attention grabbing**: Pulse/glow for warnings, not constant
- **Performance aware**: Cap particle effects, provide reduction option
- **Consistent timing**: Similar actions should animate similarly

### Color Language

Define and maintain consistent color meanings:
- Health always green→yellow→red
- Ladders always [defined color]
- Coins always gold
- Danger always red
- Depth always blue gradient (darker = deeper)

---

## Implementation Checklist

### Phase 1: Core HUD
- [ ] Establish Z/T-pattern layout
- [ ] Define primary/secondary/tertiary hierarchy
- [ ] Implement responsive scaling
- [ ] Test on multiple mobile devices

### Phase 2: Notifications
- [ ] Build stacking system with 3-item cap
- [ ] Implement notification combining
- [ ] Add priority queue for critical alerts
- [ ] Create dismissal gestures

### Phase 3: Accessibility
- [ ] Add HUD scaling option
- [ ] Implement color-blind modes
- [ ] Provide contrast adjustment
- [ ] Test with accessibility users

### Phase 4: Polish
- [ ] Animation for all state changes
- [ ] Particle/effect density options
- [ ] Consistent color language audit
- [ ] Performance optimization pass

---

## Sources

- [Game UI Design: Complete Interface Guide 2025](https://generalistprogrammer.com/tutorials/game-ui-design-complete-interface-guide-2025)
- [Essential UI Design Principles Every Game Designer Should Know](https://moldstud.com/articles/p-essential-ui-design-principles-every-game-designer-should-know-for-success)
- [Mastering Game HUD Design](https://polydin.com/game-hud-design/)
- [UX and UI in Game Design: HUD, Inventory, and Menus](https://medium.com/@brdelfino.work/ux-and-ui-in-game-design-exploring-hud-inventory-and-menus-5d8c189deb65)
- [Dead Cells Accessibility Features](https://deadcells.wiki.gg/wiki/Assist_Mode_and_Accessibility)
- [Game UI Database](https://www.gameuidatabase.com/)
- [Slay the Spire Android Review](https://www.cbr.com/slay-spire-android-review/)
- [Deckbuilder UI Design: Best Practices](https://www.gunslingersrevenge.com/posts/development/deckbuilder-ui-design-best-practices.html)
- [Loop Hero Review](https://gameinformer.com/review/loop-hero/loop-hero-review-refreshing-reiteration)
- [Marvel Snap UI Design](https://www.tiffanysmart.com/work/marvel-snap)
- [SNAPPY U.I. - How Marvel SNAP's UI Supports Success](https://www.artstation.com/artwork/GemNDd)
- [Behind the Design: MARVEL SNAP](https://developer.apple.com/news/?id=sosm2p7q)
- [UI Playbook - Notification](https://uiplaybook.dev/play/notification)
- [Notification Design Best Practices](https://www.setproduct.com/blog/notifications-ui-design)
- [Stacked Notification - Ant Design](https://ant.design/docs/blog/notification-stack/)
- [A Comprehensive Guide to Notification Design](https://www.toptal.com/designers/ux/notification-design)

---

*Research completed: 2026-02-02*
*Session: 29*
