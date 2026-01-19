---
title: "research: Accessibility best practices"
status: closed
priority: 3
issue-type: task
created-at: "\"\\\"2026-01-18T23:42:37.855494-06:00\\\"\""
closed-at: "2026-01-19T03:40:34.663930-06:00"
close-reason: Researched mobile game accessibility best practices. Updated 4 existing specs (colorblind, one-hand, text size, haptics). Created 2 new tasks (SettingsManager, reduced motion). Documented key statistics and platform requirements.
---

Research accessibility in mobile games. Colorblind modes, text sizing, one-handed play, reduced motion options. What do Apple/Google require? What do players appreciate? Check Game Accessibility Guidelines, Xbox accessibility features. Create tasks for accessibility improvements.

## Research Findings

### Key Statistics

- ~8% of men and ~0.5% of women are colorblind
- 2.2 billion people globally have visual impairments
- 15% of the US population is over 65
- The four most common accessibility complaints: **remapping, text size, colorblindness, subtitle presentation**

### Game Accessibility Guidelines (Basic Level)

Per gameaccessibilityguidelines.com, basic features for mobile games:

**Motor/Controls:**
- Allow controls to be remapped/reconfigured
- Include sensitivity adjustment
- Ensure interactive elements are large and well-spaced (minimum 44x44pt per Apple HIG)
- Provide simpler control alternatives

**Vision/Color:**
- Provide high contrast between text/UI and background (WCAG: 4.5:1 for text, 3:1 for large text)
- Ensure no essential information conveyed by color alone
- Use readable default font size
- Clear text formatting

**Audio/Hearing:**
- Provide subtitles for important speech
- Separate volume controls
- Never rely solely on sound for critical information

### Mobile Platform Requirements

**iOS:**
- VoiceOver screen reader compatibility
- Dynamic Type support (text sizes from small to "accessibility XXXL")
- Reduced motion support
- Minimum tap target 44x44 points

**Android:**
- TalkBack screen reader compatibility
- Scalable text support
- Minimum touch target 48x48 dp

**Legal:**
- CVAA compliance for communication features (multiplayer chat)
- DOJ ADA Title II: WCAG 2.1 AA compliance by 2026 for government entities

### Implementation Priority

Based on research, prioritized accessibility features:

1. **SettingsManager singleton** - Foundation for all settings
2. **Text size options** - Second most common complaint
3. **Colorblind mode** - Third most common complaint
4. **Haptic toggle** - Basic accessibility feature
5. **One-hand play** - Motor accessibility
6. **Reduced motion** - Vestibular accessibility
7. **High contrast mode** - Vision accessibility

### Sources

- [Game Accessibility Guidelines](https://gameaccessibilityguidelines.com/)
- [Apple Human Interface Guidelines - Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)
- [WCAG 2.1 Color Contrast](https://www.allaccessible.org/blog/color-contrast-accessibility-wcag-guide-2025)
- [Keywords Studios - Accessibility in Mobile Games](https://www.keywordsstudios.com/en/about-us/news-events/news/accessibility-and-mobile-game-development/)

## Implementation Tasks Created

- `GoDig-implement-settingsmanager-cdf5e1be` - SettingsManager singleton (P1)
- `GoDig-v1-0-colorblind-617be493` - Updated with detailed spec
- `GoDig-v1-0-one-8a65121d` - Updated with detailed spec
- `GoDig-v1-0-text-5a5cb954` - Updated with detailed spec
- `GoDig-implement-reduced-motion-2b1487b2` - Reduced motion option (NEW)
- `GoDig-v1-0-haptic-60d1d4e2` - Already has detailed spec
