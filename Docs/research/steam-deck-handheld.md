# Steam Deck and Handheld Gaming Considerations

## Overview

Research into Steam Deck and handheld gaming platform design considerations. GoDig is mobile-first but may expand to Steam Deck and similar handheld PCs. This document covers control schemes, UI adaptation, performance optimization, and successful port strategies.

## Steam Deck Verification Requirements

### Input Requirements

For Steam Deck Verified status, games must:

1. **Full Controller Support:** Default controller configuration provides access to all content
2. **Controller Glyphs:** On-screen buttons match Deck or Xbox 360/One naming
3. **No Required Tweaking:** Players shouldn't need to adjust settings to enable controller support

**GoDig Consideration:** Our touch-first controls need a proper controller mapping layer. The virtual joystick maps naturally to the left stick, but dig/action buttons need clear assignment.

### Display Requirements

- **Text Legibility:** All text must be readable on 7-inch screen at 1280x800
- **UI Element Size:** Minimum touch targets translate well to controller navigation
- **Aspect Ratio:** 16:10 native (different from most mobile displays)

### Verification Categories

| Category | Meaning | Requirements |
|----------|---------|--------------|
| Verified | Fully compatible | All criteria met, plays perfectly |
| Playable | Works with tweaks | May need user adjustment |
| Unsupported | Not compatible | VR, Windows-specific features, etc. |

**Visibility Benefit:** Steam Deck store defaults to showing only Verified titles. This is significant for discoverability.

## Control Scheme Adaptation

### Mobile Touch to Controller Mapping

| Mobile Input | Steam Deck Equivalent | Notes |
|-------------|----------------------|-------|
| Virtual joystick (left) | Left analog stick | 1:1 mapping |
| Action button (right) | A button | Primary action |
| Jump button | B button | Standard platformer mapping |
| Inventory toggle | Y button | Quick access |
| Shop interaction | X button | Context-sensitive |
| Pause/menu | Start button | Universal convention |
| Quick actions | D-pad | Ladder placement, tool switch |

### Steam Deck Unique Inputs

**Trackpads:** Could enable precision dig targeting or map navigation
**Back Buttons:** Perfect for frequently-used shortcuts (ladder, torch)
**Gyro:** Optional precision aiming for precise block targeting

### Controller Profiles

Steam Input allows per-game controller customization:
- Store game-specific default configuration
- Players can customize without code changes
- Consider providing 2-3 official profile presets

## Portrait to Landscape Adaptation

### The Challenge

GoDig is designed for portrait mobile gameplay. Steam Deck is landscape (1280x800, 16:10).

### Adaptation Strategies

**Option 1: Pillarbox with Side Panels**
- Keep portrait game area centered
- Use side panels for expanded UI (inventory, map, stats)
- Similar approach: mobile games with desktop web versions

**Option 2: Responsive UI Redesign**
- Redesign HUD for landscape
- Move elements to corners and edges
- More horizontal real estate for game view

**Option 3: Camera Zoom Adjustment**
- Show more horizontal world content
- Adjust camera framing for landscape
- Vertical gameplay works differently

**Recommendation for GoDig:**
Option 1 (pillarbox with side panels) is lowest risk:
- Core vertical mining gameplay preserved
- Extra screen space adds features without redesign
- Side panels can show: expanded minimap, inventory preview, depth meter, equipment status

### UI Scale Considerations

Steam Deck screen density vs mobile:
- Mobile: varies (300-400+ ppi)
- Steam Deck: ~215 ppi

**Impact:** UI elements designed for mobile might appear too large on Steam Deck. Consider scale multiplier option.

## Performance and Battery Optimization

### Target Performance Specs

| Metric | Recommended | Notes |
|--------|------------|-------|
| Frame Rate | 40-60 FPS | 40Hz is sweet spot for battery |
| TDP | 8-12W | Balance between performance and life |
| Resolution | Native 1280x800 | FSR can help if needed |
| Battery Life | 2-4 hours | Depends on complexity |

### Optimization Priorities

**Frame Rate Caps:**
- Steam Deck 40Hz mode is popular compromise
- Provide in-game option: 30/40/60 FPS cap
- 40 FPS with 40Hz refresh feels smooth while saving battery

**Power-Efficient Features:**
- Reduce particle effects density option
- Simpler shaders for mobile build also benefit Steam Deck
- Chunk loading optimizations critical

**Per-Game Profiles:**
Steam Deck saves per-game performance settings. Provide recommended defaults:
- Suggested TDP: 10W
- Frame rate: 40 FPS
- FSR: Off (native res is manageable)

### Battery-Friendly Design Decisions

| Feature | Battery Impact | Recommendation |
|---------|---------------|----------------|
| Particle effects | Medium | Quality settings option |
| Chunk generation | High during load | Smaller chunks, lazy loading |
| Audio processing | Low-Medium | Single-threaded audio fine |
| Background processes | Variable | Pause when unfocused |

## Godot 4 Steam Deck Export

### Export Configuration

1. **Target Platform:** Linux/X11
2. **Architecture:** x86_64
3. **Resolution:** 1280x800 default
4. **Embed PCK:** Recommended (single file distribution)

### Testing Workflow

**Development Testing:**
1. Export Linux build
2. Transfer to Steam Deck via SSH or USB
3. Run as non-Steam game initially
4. Add to Steam for controller mapping testing

**Remote Deploy Plugin:**
- Godot4-DeployToSteamOS plugin enables one-click deploy
- Requires Steam Deck in Developer Mode
- SSH key configuration needed

### Linux vs Proton

Two approaches:
1. **Native Linux:** Direct, usually better battery
2. **Windows + Proton:** May work if Linux build has issues

**Recommendation:** Native Linux. Godot's Linux export is mature and Dome Keeper (also Godot) runs natively on Steam Deck with excellent reviews.

## Case Study: Dome Keeper

Dome Keeper is highly relevant - it's a Godot-built indie mining game that's Steam Deck Verified.

### Success Factors

1. **Built in Godot:** Proves Godot games work great on Deck
2. **Linux Native:** No Proton layer needed
3. **Perfect Performance:** Praised for Steam Deck experience
4. **Short Sessions:** Roguelite structure fits handheld play

### Lessons for GoDig

| Dome Keeper Approach | GoDig Application |
|---------------------|-------------------|
| Simple control scheme | Touch controls translate well |
| Quick sessions (15-30 min) | Our session design already fits |
| Visual clarity at small size | Ensure ore types distinguishable |
| Native Linux build | Prioritize Linux export quality |

## Case Study: Vampire Survivors

Mobile game that became Steam Deck phenomenon.

### Key Takeaways

1. **Session Length Match:** Short, addictive sessions perfect for portable
2. **Simple Controls:** One-stick gameplay, no complex inputs
3. **Visual Clarity:** Clear player, enemy, and pickup visibility
4. **Performance:** Smooth even with hundreds of on-screen elements

**Revenue Model Difference:**
- Mobile: Free with ads, no IAP
- Steam: Paid, no ads
- Demonstrates platform-specific monetization acceptable

## UI Adaptation for Larger Screens

### Mobile to Steam Deck Transition

**Screen Real Estate:**
- More room for UI without obscuring gameplay
- Can show information previously hidden behind menus
- Side panels viable (pillarbox approach)

**Interaction Model:**
- No touch, but no fingers blocking screen either
- Controller cursor can be more precise than finger
- D-pad navigation through menus

### Recommended UI Changes

| Element | Mobile | Steam Deck |
|---------|--------|------------|
| Inventory | Full-screen overlay | Side panel or picture-in-picture |
| Minimap | Corner with toggle | Always visible, larger |
| Depth meter | Minimal | Expanded with stats |
| Shop interface | Full-screen | Split-screen browsing |
| Tutorial hints | Center screen | Corner or margin |

### Font and Icon Scaling

**Minimum Sizes for Steam Deck:**
- Body text: 16px equivalent
- Headers: 20-24px
- Icons: 32px minimum

These are similar to mobile requirements, so existing design should transfer well.

## Platform-Specific Considerations

### Steam Deck vs Steam Machine (2026)

Valve confirmed Steam Deck Verified games are automatically Steam Machine Verified:
- Fewer constraints on Steam Machine (TV-based, larger screen)
- Text legibility less strict for TV distance
- Same controller support applies

### Handheld Competition

| Device | Screen | Controls | OS |
|--------|--------|----------|-----|
| Steam Deck | 7" 1280x800 | Full controller | SteamOS (Linux) |
| ASUS ROG Ally | 7" 1920x1080 | Full controller | Windows |
| Lenovo Legion Go | 8.8" 2560x1600 | Detachable | Windows |

**Export Strategy:** Linux build covers Steam Deck. Windows build covers other handhelds.

### iOS/Android Tablet Comparison

GoDig already targets tablets. Steam Deck's 7" screen is similar to:
- iPad Mini (8.3")
- Large Android tablets (8-10")

Tablet-optimized UI should adapt reasonably to Steam Deck.

## Implementation Recommendations

### Phase 1: Basic Compatibility

1. **Export Linux Build:** Test on Steam Deck
2. **Controller Mapping:** Create Steam Input configuration
3. **Resolution Testing:** Verify 1280x800 renders correctly
4. **Performance Baseline:** Measure FPS and battery drain

### Phase 2: Optimization

1. **UI Scale Option:** Allow 0.8x-1.2x UI scaling
2. **Frame Rate Cap:** Add 30/40/60 FPS options
3. **Side Panel Mode:** Optional landscape enhancement
4. **Battery Profile:** Reduce effects for longer play

### Phase 3: Polish

1. **Steam Input Preset:** Official controller configuration
2. **Achievement Glyphs:** Button icons match Deck
3. **Quick Resume:** Instant save/load for suspend
4. **Steam Deck Verification:** Submit for official review

## Technical Checklist

### Pre-Verification Requirements

- [ ] Full controller support without settings changes
- [ ] Controller glyphs (not keyboard/mouse icons)
- [ ] Text legible at 1280x800 on 7" screen
- [ ] No launcher or external account requirement
- [ ] Runs via Proton or native Linux
- [ ] Gamepad menu navigation
- [ ] No required typing

### Performance Targets

- [ ] 40+ FPS stable in normal gameplay
- [ ] No major frame drops during chunk loading
- [ ] Audio without glitches at 40 FPS
- [ ] Battery life competitive (2+ hours active play)

## Conclusion

Steam Deck is a natural platform expansion for GoDig:

1. **Gameplay Match:** Vertical mining, short sessions, simple controls - all fit handheld play
2. **Godot Support:** Dome Keeper proves Godot games excel on Steam Deck
3. **Minimal Redesign:** Pillarbox approach preserves mobile layout
4. **Shared Optimizations:** Performance work benefits both mobile and handheld

**Priority:** Medium-term. Focus on mobile launch first, but architect with Steam Deck compatibility in mind. Export architecture decisions (Linux support, controller abstraction) should be made early.

## Sources

- [Steam Deck Compatibility Review Process](https://partner.steamgames.com/doc/steamdeck/compat)
- [Steam Deck FAQ - Steamworks](https://partner.steamgames.com/doc/steamdeck/faq)
- [Dome Keeper Steam Deck Performance](https://www.gamingonlinux.com/2022/06/dome-keeper-is-going-to-be-my-next-craving-demo-is-great-on-linux-and-steam-deck/)
- [Vampire Survivors Steam Deck Review](https://toucharcade.com/2022/10/21/vampire-survivors-1-0-review-steam-deck-killer-app/)
- [Running Godot Games on Steam Deck](https://www.gogogodot.io/running-godot-games-on-steam-deck/)
- [Godot Steam Deck Export Guide](https://drewler.net/blog/2023/12/godot-steam-deck-export-ssh)
- [Steam Deck Battery Optimization](https://gamerant.com/optimize-steam-deck-best-performance-battery-life/)
- [GodotSteam Export Documentation](https://godotsteam.com/tutorials/exporting_shipping/)
