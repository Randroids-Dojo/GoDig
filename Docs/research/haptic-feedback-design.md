# Haptic Feedback Design for Mobile Mining Games

## Overview

This research documents best practices for implementing haptic feedback in GoDig, focusing on when vibrations add value versus when they become annoying, with platform-specific considerations and accessibility requirements.

## Core Design Principles

### Less is More

When it comes to haptic feedback on mobile devices, less is more. Too much vibration can be annoying and even numbing to the hands, as the device is usually in-hand with the user's full attention.

**Key Guidelines:**
- Favor rich and clear haptics over buzzy haptics
- Be consistent with system and app design
- Be mindful of frequency of use
- Consider importance of the action

### Haptic Quality Hierarchy

| Type | Description | When to Use |
|------|-------------|-------------|
| **Clear Haptics** | Crisp, clean sensations like button presses | Discrete events (mining completion, pickup) |
| **Rich Haptics** | More expressive, varied amplitude | Special discoveries (rare ore, achievement) |
| **Buzzy Haptics** | Noisy, sharp, lingering vibrations | AVOID - choose no haptics instead |

**Critical Rule:** Given the choice of buzzy haptics or no haptics, choose no haptics.

## Platform Differences

### iOS (Taptic Engine)

iOS offers more nuanced control via its Taptic Engine and Core Haptics API:

**Advantages:**
- Wider frequency range (80-230 Hz)
- Transient and continuous event types
- Built-in audio-haptic synchronization
- Consistent feel across iPhone 8 and later

**Event Types:**
- **Transient**: Single cycle, momentary (impact, tap) - ideal for mining hits
- **Continuous**: Sustained feedback - use sparingly for special events

### Android

Android capabilities differ significantly by device:

**Recommendations:**
- Use HapticFeedbackConstants for consistent cross-device behavior
- Use VibrationEffect cautiously with device support checks
- Avoid legacy vibrate() calls (deprecated)
- Test on multiple devices - perceived feel varies dramatically

## GoDig Haptic Event Mapping

### High-Value Events (Should Have Haptics)

| Event | Haptic Type | Intensity | Notes |
|-------|-------------|-----------|-------|
| **Ore discovered** | Medium transient + short rich | Medium-High | The "eureka moment" - deserves celebration |
| **Rare ore discovered** | Rich sequence | High | Pattern should differ by rarity tier |
| **Block break** | Light transient | Low | Subtle confirmation, not every hit |
| **Achievement unlocked** | Success pattern | Medium | Match system achievement haptics |
| **Depth milestone** | Medium transient | Medium | Mark progression clearly |

### Medium-Value Events (Optional Haptics)

| Event | Haptic Type | Intensity | Notes |
|-------|-------------|-----------|-------|
| **Item pickup** | Very light transient | Very Low | Avoid overwhelming during bulk collection |
| **Sell complete** | Success pattern | Low-Medium | Satisfying completion moment |
| **Upgrade purchased** | Medium transient | Medium | Significant player action |

### Low/No-Value Events (Skip Haptics)

| Event | Reason to Skip |
|-------|----------------|
| **Every mining hit** | Too frequent - becomes numbing |
| **UI button taps** | Use system defaults only |
| **Background events** | Player isn't actively engaged |
| **Movement/walking** | Unnecessary, distracting |

## Rarity-Based Haptic Patterns

Design distinct patterns for ore rarity tiers:

| Rarity | Pattern Description | Intensity |
|--------|---------------------|-----------|
| Common | Single soft tap | 0.3 |
| Uncommon | Single medium tap | 0.5 |
| Rare | Double tap | 0.6 |
| Epic | Triple tap, ascending | 0.7 |
| Legendary | Rich sequence with pause | 0.9 |

This creates learnable feedback where players can eventually "feel" rarity without looking.

## Frequency Guidelines

### Avoid Haptic Fatigue

The haptic pattern must fit the situation and match other feedback (visual and audio) to build a cohesive experience.

**Recommended Limits:**
- Maximum 1 haptic event per second during active play
- No more than 10 haptic events per minute during intensive mining
- Space out haptics - minimum 200ms between events
- Never trigger during paused/background state

### Event Priority

When multiple haptic-worthy events occur simultaneously:
1. Highest rarity ore takes priority
2. Achievement beats regular events
3. Newer events can cancel queued haptics

## Accessibility Requirements

### Must-Have Settings

1. **Global Haptic Toggle**: Complete on/off control
2. **Intensity Slider**: 0-100% adjustment
3. **Category Toggles** (optional):
   - Ore discovery haptics
   - Achievement haptics
   - UI haptics

### Accessibility Considerations

For users with touch sensitivity or sensory processing differences:
- Unexpected or intense vibrations can be overwhelming
- Prioritize crisp, predictable, short feedback
- Ensure Minimal/Off settings are readily available

For users with motor impairments:
- Haptics confirm successful activation
- Ensure feedback is consistent and predictable

### Settings UI Placement

```
Settings > Sound & Haptics
├── Vibration: [On/Off]
├── Vibration Intensity: [Slider 0-100%]
└── Vibrate on:
    ├── Ore Discovery: [On/Off]
    ├── Achievements: [On/Off]
    └── UI Actions: [On/Off]
```

## Battery Impact

### Research Summary

Research by Immersion Corp. found that haptic technology power consumption is minimal in mobile devices:
- Even under aggressive usage (continuous game haptics), haptics consumed only 0.95-4.11% of device battery
- Need for Speed with continuous engine haptics: only 1-2% additional battery drain
- Audio from speakers actually consumes more power than haptic feedback

### Optimization Tips

1. Use short transient events instead of continuous patterns
2. Prefer low-intensity haptics where appropriate
3. Don't trigger haptics when app is backgrounded
4. Consider device battery level for optional haptics

## Implementation Notes

### Unity (Nice Vibrations)

If using Nice Vibrations plugin, leverage the 9 preset patterns:
- light, medium, heavy (intensity levels)
- rigid, soft (feel variations)
- failure, success, selection, warning (semantic patterns)

### Godot

For Godot 4:
```gdscript
# Check platform support
if OS.has_feature("mobile"):
    Input.vibrate_handheld(duration_ms, amplitude)

# iOS-specific with more control (requires plugin)
# Use GDNative/GDExtension for Core Haptics
```

### Testing Checklist

- [ ] Test on low-end Android devices
- [ ] Test on iPhone (Taptic Engine quality)
- [ ] Test with haptics disabled
- [ ] Test haptic frequency during intensive mining
- [ ] Gather user feedback on comfort levels
- [ ] Verify settings persistence across sessions

## Summary: GoDig Haptic Strategy

### Guiding Principles

1. **Celebrate discoveries, not every action** - Ore discovery deserves haptics; every mining hit does not
2. **Distinct patterns for rarity** - Players should learn to "feel" rare finds
3. **Always disable-able** - Prominent settings, respected globally
4. **Platform-appropriate** - Better haptics on iOS, graceful fallback on Android
5. **Test extensively** - Perceived feel varies dramatically across devices

### Implementation Priority

**MVP:** No haptics (focus on core gameplay)

**v1.0:**
- Ore discovery haptics (rarity-tiered)
- Achievement haptics
- Settings toggle
- Intensity slider

**v1.1+:**
- Refined patterns per ore type
- Audio-haptic synchronization
- Advanced accessibility options

## Sources

- [Android Haptics Design Principles](https://developer.android.com/develop/ui/views/haptics/haptics-principles)
- [Apple Human Interface Guidelines: Playing Haptics](https://developer.apple.com/design/human-interface-guidelines/playing-haptics)
- [Core Haptics Documentation](https://developer.apple.com/documentation/corehaptics/)
- [Haptics for Mobile Best Practices - Interhaptics](https://medium.com/nerd-for-tech/haptics-for-mobile-the-best-practices-for-android-and-ios-d2aa72409bdd)
- [2025 Guide to Haptics](https://saropa-contacts.medium.com/2025-guide-to-haptics-enhancing-mobile-ux-with-tactile-feedback-676dd5937774)
- [Immersion Corp. Battery Research](https://www.immersion.com/wp-content/uploads/2020/04/haptic-technologies-consume-minimal-power-in-smart-phones.pdf)
- [Nice Vibrations Documentation](https://nice-vibrations.moremountains.com/)
- [10 Things About Designing for Apple Core Haptics](https://danielbuettner.medium.com/10-things-you-should-know-about-designing-for-apple-core-haptics-9219fdebdcaa)
