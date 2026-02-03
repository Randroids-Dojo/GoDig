# Mobile Thumb Zone Ergonomics for One-Handed Play

> Research on thumb reach zones, screen sizes, and HUD placement for mobile games.
> Last updated: 2026-02-02 (Session 33)

## Executive Summary

Over 75% of mobile interactions are thumb-driven, yet most phones now exceed 6.5 inches, making top-of-screen elements unreachable for one-handed use. For GoDig's portrait-mode mining game, **all primary interactive elements must be in the bottom half of the screen**. The top should be reserved for passive information displays only.

---

## 1. The Thumb Zone Model

### Origin and Definition

Steven Hoober introduced the "thumb zone" concept in *Designing Mobile Interfaces*. Josh Clark expanded on this, finding that **75% of all mobile interactions are thumb-driven**.

### Three Zones

| Zone | Location | User Experience |
|------|----------|-----------------|
| **Easy (Green)** | Bottom center, arc shape | Natural thumb rest, comfortable repeated use |
| **Stretch (Yellow)** | Middle, sides | Reachable but uncomfortable for frequent interaction |
| **Hard (Red)** | Top corners | Requires grip shift or two-handed use |

### Key Statistics

- **49-75%** of smartphone users operate one-handed
- **67%** of users use their right thumb for single-handed interactions
- **10-15%** of users are left-handed (design must accommodate)

**Sources**: [The Thumb Zone - Smashing Magazine](https://www.smashingmagazine.com/2016/09/the-thumb-zone-designing-for-mobile-users/), [Thumb Navigation UX Research](https://medium.com/design-bootcamp/thumb-navigation-in-mobile-usability-ux-research-5d956c4ec3fb)

---

## 2. 2025-2026 Screen Size Reality

### Common Screen Dimensions

| Resolution | Common Devices | Usage Context |
|------------|----------------|---------------|
| **1080x2400** | Most mid-range Android | Standard target |
| **1170x2532** | iPhone 15/16 | iOS target |
| **1440x3200** | Samsung Galaxy S series | Flagship Android |
| **720x1600** | Budget phones (emerging markets) | Accessibility consideration |

### Physical Screen Sizes

- **Budget phones**: 6.1-6.3 inches
- **Mid-range**: 6.4-6.7 inches
- **Flagship**: 6.7-6.9 inches
- **Foldables**: Up to 7.6 inches (unfolded)

### Thumb Reach vs Screen Size

Research shows:
- Screens over **6.3 inches** are difficult for one-handed use with smaller hands
- Screens **6.7+ inches** require software solutions (Reachability, bottom navigation)
- Gesture design accounts for **63%** of fatigue variance, screen size only **22%**

**Insight**: A well-optimized 6.7-inch game causes less strain than a poorly optimized 5.8-inch game.

**Sources**: [BrowserStack Screen Resolutions 2026](https://www.browserstack.com/guide/common-screen-resolutions), [Kobiton Mobile Testing 2025](https://kobiton.com/blog/common-screen-resolutions-for-mobile-testing-in-2025/)

---

## 3. Portrait Mode as Standard

### Why Portrait, Not Landscape

Mobile gambling industry learned this lesson:
> "Forcing a player to rotate their phone is a massive friction point—it requires two hands."

**Portrait mode enables genuine thumb-only operation**.

For GoDig specifically:
- Vertical gameplay matches natural phone holding
- Mining "down" aligns with scroll direction
- No rotation friction for quick sessions

### The "Emptied Top" Principle

Successful mobile games now:
1. Move navigation bars from top to bottom
2. Reserve top half for **visual information only** (not interactive)
3. Place all tap targets in bottom arc

**Sources**: [LeagueLane - Why Mobile Games Moved Controls to Bottom](https://leaguelane.com/mobile-betting-games-moved-controls-to-bottom-center-screen/)

---

## 4. Touch Target Specifications

### Minimum Sizes

| Platform | Minimum Target | Recommended |
|----------|----------------|-------------|
| **Google Material Design** | 48x48 dp | 48x48 dp with 8dp spacing |
| **Apple Human Interface** | 44x44 pt | 44x44 pt minimum |
| **General Best Practice** | 48x48 pixels | 56x56 for primary actions |

### Spacing Requirements

- **Minimum gap between targets**: 8 pixels
- **Recommended gap for important buttons**: 12-16 pixels
- **Avoid overlapping touch zones** entirely

### Context for GoDig

GoDig uses 32x32 pixel tiles. Touch targets should be:
- **Mining/dig**: Auto-detected from tap position (no button needed)
- **HUD buttons**: Minimum 48x48, ideally 56x56
- **Inventory slots**: 48x48 minimum with clear spacing

**Sources**: [Mobile Free To Play - Touch Control Design](https://mobilefreetoplay.com/control-mechanics/), [Microsoft Touch Controls Guide](https://learn.microsoft.com/en-us/gaming/gdk/docs/features/common/game-streaming/building-touch-layouts/game-streaming-tak-designers-guide)

---

## 5. HUD Placement Guidelines for GoDig

### Current GoDig HUD Analysis

Based on typical mining game HUDs, common elements:

| Element | Current Risk | Recommended Placement |
|---------|--------------|----------------------|
| Health bar | Often top-left | Move to bottom-left arc |
| Coin counter | Often top-right | Move to bottom-right arc |
| Depth indicator | Often top-center | Keep top-center (passive display) |
| Inventory | Often bottom | Good - keep in thumb zone |
| Pause button | Often top-right | Move to bottom or add pull-down |
| Ladder button | Varies | Must be bottom-right (primary action) |

### Recommended GoDig HUD Layout

```
┌─────────────────────────────┐
│    [Depth: 150m]            │  ← Passive display only (top)
│                             │
│                             │
│    [Game Area]              │  ← No interactive elements here
│                             │
│                             │
├─────────────────────────────┤
│                             │
│  ♥♥♥♥♥    [Inventory]  💰   │  ← Easy zone (bottom third)
│  [▼Dig]   [1][2][3][4] [⚙️] │  ← Primary actions (bottom)
└─────────────────────────────┘
```

### Placement Priority

**Bottom Center (Highest Priority)**:
- Dig/action button
- Inventory slots
- Quick-use items (ladder placement)

**Bottom Corners (High Priority)**:
- Health (bottom-left)
- Currency (bottom-right)
- Settings gear (bottom-right)

**Top Center (Information Only)**:
- Depth indicator
- Layer name
- Session timer (if any)

**Avoid Top Corners**:
- No buttons
- No interactive elements
- Only passive indicators if necessary

---

## 6. Accessibility Considerations

### Left-Handed Support

10-15% of users are left-handed. Solutions:
1. **Mirror Mode**: Settings toggle that flips HUD horizontally
2. **Adaptive Layout**: Primary action buttons in center (works for both hands)
3. **Avoid side-specific placement** for critical actions

### Reachability Features

For players with smaller hands or larger phones:
- **Pull-down pause menu**: Swipe from top reveals pause
- **Bottom sheet patterns**: All menus slide up from bottom
- **No hard-to-reach dismissal**: Tap anywhere to close overlays

### Visual Accessibility

- **Contrast**: HUD elements need high contrast against game background
- **Size options**: Allow HUD scale adjustment (100%, 125%, 150%)
- **Color blindness**: Don't rely on color alone for information

**Sources**: [Accessible Game Design - HUD Guidelines](https://accessiblegamedesign.com/guidelines/HUD.html), [Punchev - Mobile UX for Game Development](https://punchev.com/blog/designing-for-mobile-ux-considerations-for-mobile-game-development)

---

## 7. Gesture Best Practices

### Swipe Directions and Meanings

| Gesture | Common Meaning | GoDig Application |
|---------|----------------|-------------------|
| Swipe Up | Pull up menu/sheet | Open inventory detail |
| Swipe Down | Dismiss/pull down | Pause menu access |
| Tap | Primary action | Dig/mine |
| Long Press | Secondary action | Block info, ladder placement |
| Pinch | Zoom | Camera zoom (if supported) |

### Feedback Requirements

Touch interfaces lack tactile feedback. Provide:
- **Visual feedback**: Button state change on touch
- **Audio feedback**: Tap sounds (with mute option)
- **Haptic feedback**: Vibration on important actions (with disable option)

### Gesture Discoverability

- Provide visual hints for non-obvious gestures
- Don't overload gestures (one function per gesture)
- Tutorial hints on first use

---

## 8. Common HUD Mistakes to Avoid

### 1. Top-Corner Primary Actions
**Problem**: Buttons in top corners force thumb stretch or grip shift.
**Solution**: Move all primary actions to bottom half.

### 2. Small Touch Targets
**Problem**: Buttons smaller than 44x44 cause misclicks.
**Solution**: Minimum 48x48 with proper spacing.

### 3. Fixed Layouts That Ignore Hand Preference
**Problem**: Right-hand-optimized HUD frustrates lefties.
**Solution**: Center-aligned or mirrored layouts.

### 4. Cluttered Bottom Area
**Problem**: Too many buttons compete for thumb space.
**Solution**: Prioritize 3-4 most-used actions, hide others in menus.

### 5. No Feedback on Touch
**Problem**: Users unsure if their tap registered.
**Solution**: Immediate visual/audio/haptic response.

---

## 9. GoDig-Specific Recommendations

### Priority 1: Move Health/Currency to Bottom

Current mining games often place health top-left. For one-handed play:
- Health bar should be bottom-left
- Currency should be bottom-right
- Both remain visible but accessible

### Priority 2: Bottom-Center Action Zone

The dig action is constant. Recommendations:
- Virtual joystick in bottom-left (if used)
- Or: tap-to-dig anywhere with HUD in bottom strip
- Ladder/item buttons in bottom-right arc

### Priority 3: Collapsible/Minimal HUD

During active digging:
- Minimize HUD to essentials (health, currency, depth)
- Full HUD appears on pause or surface
- Reduces visual clutter, maximizes game view

### Priority 4: Settings Accessible from Bottom

Pause button options:
- Bottom-right corner (traditional)
- Or: swipe-down gesture from game area
- Never require top-screen reach

---

## 10. Implementation Checklist

### Before Release

- [ ] All primary buttons are in bottom third of screen
- [ ] Touch targets are minimum 48x48 pixels
- [ ] Health/currency visible in thumb-zone
- [ ] Pause accessible without top-corner buttons
- [ ] Left-handed mirror mode available in settings
- [ ] HUD scale option (100%/125%/150%)
- [ ] Tap feedback (visual + optional audio/haptic)
- [ ] No gesture conflicts with system gestures

### User Testing

- [ ] Test with one-handed hold (right hand)
- [ ] Test with one-handed hold (left hand)
- [ ] Test on 6.7"+ phone (flagship size)
- [ ] Test with users with smaller hands
- [ ] Observe thumb fatigue during 5+ minute sessions

---

## Sources

### Primary Research
- [The Thumb Zone UX in 2025 - Medium](https://medium.com/design-bootcamp/the-thumb-zone-ux-in-2025-why-your-mobile-app-needs-to-rethink-ergonomics-now-9d1828f42bd9)
- [The Thumb Zone - Smashing Magazine](https://www.smashingmagazine.com/2016/09/the-thumb-zone-designing-for-mobile-users/)
- [Thumb Navigation UX Research - Medium](https://medium.com/design-bootcamp/thumb-navigation-in-mobile-usability-ux-research-5d956c4ec3fb)

### Screen Size Statistics
- [Statcounter Mobile Screen Resolution Stats](https://gs.statcounter.com/screen-resolution-stats/mobile/worldwide)
- [BrowserStack Common Screen Resolutions 2026](https://www.browserstack.com/guide/common-screen-resolutions)
- [Kobiton Mobile Testing Resolutions 2025](https://kobiton.com/blog/common-screen-resolutions-for-mobile-testing-in-2025/)

### Mobile Game UI
- [Mobile Free To Play - Touch Control Design](https://mobilefreetoplay.com/control-mechanics/)
- [Game UI Database - Mobile Controls](https://www.gameuidatabase.com/index.php?scrn=147)
- [Microsoft Touch Controls Guide](https://learn.microsoft.com/en-us/gaming/gdk/docs/features/common/game-streaming/building-touch-layouts/game-streaming-tak-designers-guide)
- [Accessible Game Design - HUD Guidelines](https://accessiblegamedesign.com/guidelines/HUD.html)

### Ergonomics Research
- [PubMed - Ergonomics of Thumb Movements on Smartphone Touch Screen](https://pubmed.ncbi.nlm.nih.gov/24707989/)
- [ScienceDirect - Effects of Age, Thumb Length, Screen Size](https://www.sciencedirect.com/science/article/abs/pii/S0169814115300512)

### Industry Examples
- [LeagueLane - Why Mobile Games Moved Controls to Bottom](https://leaguelane.com/mobile-betting-games-moved-controls-to-bottom-center-screen/)

---

## Key Takeaways for GoDig

1. **75% of interactions are thumb-driven** - design for one hand
2. **Bottom third is the sweet spot** - all primary actions there
3. **6.5"+ screens are now standard** - top corners are unreachable
4. **48x48 minimum touch targets** - with proper spacing
5. **Mirror mode for left-handed users** - 10-15% of players
6. **Visual/haptic feedback essential** - touchscreens have no tactile response
7. **Portrait mode is correct** - matches natural phone holding
8. **Top = information, Bottom = interaction** - clear separation
